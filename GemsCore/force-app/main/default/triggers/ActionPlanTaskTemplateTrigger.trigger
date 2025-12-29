trigger ActionPlanTaskTemplateTrigger on APTaskTemplate__c (after undelete, after insert, after update) {
//Change made by Gazi on 10/24/2013. Added isUpdate condition to update Status
	set<ID> aPTaksIds= new set<ID>();
	
	Task task;       
	List<task> list_task_update =new List<Task>(); 
	
	for( APTaskTemplate__c a : trigger.new ){
	     aPTaksIds.add( a.Id );
	}
		
	//Undelete Tasks
	if ( trigger.isUnDelete ){
	   	//only undelete Tasks that are currently on the recycle bin
	   	list <Task> aP_tasks = [ select Id from Task where TaskTemplateId__c in : aPTaksIds and isDeleted = true ALL ROWS ];

	   	try{
	   		undelete aP_tasks;
	   	} catch ( Dmlexception e ){
	   		for (APTaskTemplate__c a: trigger.new){
				a.addError('BROKEN :'+e);
			}
	   	}
	}
	//Change made by Gazi	
	
	if ( trigger.isUpdate ){
		//Change the task status if action plan task status is changed
		list <APTaskTemplate__c> ApTaskStatus = [Select Id, Status__c From APTaskTemplate__c Where Id In : aPTaksIds];
		list <Task> aP_tasks = [ select Id, TaskTemplateId__c, Status from Task where TaskTemplateId__c in : aPTaksIds]; // These are the task need to be updated with status.
		//Find the status of updated action plan tasks. And make sure status is same on related task.
		for (APTaskTemplate__c ap : ApTaskStatus){
        	for (Task t: aP_tasks){
        		if (ap.Id == t.TaskTemplateId__c && ap.Status__c != t.Status && t.Status != 'Completed'){
        			//build list of task needs to update status
        			Task tk = new Task(Id = t.Id);
        			tk.Status = ap.Status__c;
        			list_task_update.add(tk);
        		} // end of if       		
        	}  // end for inner for loop
		} // end of outer for loop
		 if (!list_task_update.isEmpty())
                update list_task_update;
	} //end of isUpdate condition
	

}