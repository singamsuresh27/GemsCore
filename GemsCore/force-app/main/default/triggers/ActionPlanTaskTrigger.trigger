trigger ActionPlanTaskTrigger on Task ( after update, after delete , before delete) {
 //Gazi made change on 10/24/2013 to make sure is task status is changed, action plan task status also change. Befor it was changing for only
 //complete and In Progress status   
    if (trigger.isUpdate && trigger.isAfter){
        
        List<String> closedTasks = new List<String>();
        List<String> inProgressTasks = new List<String>();
        List<String> otherTasks = new List<String>();
        List<String> APTasksIds = new List<String>();
        //************************************
        //APTaskTemplate__c task;       
        List<APTaskTemplate__c> list_task_update =new List<APTaskTemplate__c>(); 
        //************************************
        
        ActionPlansUtilities apUtil = new ActionPlansUtilities();
    
        //Get all my Updated complete Task Id's.
        for( Task t : Trigger.new ) {
    
            if (t.TaskTemplateId__c != null){
                //store APTasks Id in a list to obtain all asociated APTasks objects
                APTasksIds.add(t.TaskTemplateId__c);
                //Gazi comment out this if condition
                //if( t.Status == 'Completed' || t.Status == 'In Progress'){
                if( t.Status == 'Completed'){   
                    //check that the task does not depent on another task with status = In Progress
                    if (apUtil.validateChangeStatus(t.TaskTemplateId__c)){
                         if( t.Status == 'In Progress' ){
                            inProgressTasks.add( t.TaskTemplateId__c );
                        }else{
                            closedTasks.add( t.TaskTemplateId__c );
                        }
                    }else{
                        //throw exception
                        trigger.new[0].Status.addError(Label.ap_UpdateStatusError);
                    }
                }
                else{
                    //Gazi comment out this if condition
                    //Update action plan task status for other status 
                    otherTasks.add( t.TaskTemplateId__c );
                }
            }
            
        }
        
        //Call to ActionPlansUtilities in order to proceed with creation of dependent Task
        if( !closedTasks.isEmpty() ) {
            ActionPlansTaskTriggerUtilities.initDependentTaskWork( closedTasks);
        }
        //update status to in progress for AP Tasks
         if( !inProgressTasks.isEmpty() ) {
            ActionPlansTaskTriggerUtilities.updateAPTasksStatus( inProgressTasks );
        }
        //************************************
        // change status of action plan task other then complete and in peogress
        
        if( !otherTasks.isEmpty() ) {
            // update
            list <APTaskTemplate__c> ApTaskStatus = [Select Id From APTaskTemplate__c Where Id In : otherTasks];
            list <Task> aP_tasks = [ select Id, TaskTemplateId__c, Status from Task where TaskTemplateId__c in : otherTasks];
            for (APTaskTemplate__c ap : ApTaskStatus){
                    for (Task t: aP_tasks){
                        if (ap.Id == t.TaskTemplateId__c){
                            //build list of task needs to update status
                            APTaskTemplate__c tk = new APTaskTemplate__c(Id = ap.Id);
                            tk.Status__c  = t.Status;
                            list_task_update.add(tk);
                        } // end of if              
                    }  // end for inner for loop
            } // end of outer for loop
            if (!list_task_update.isEmpty())
                update list_task_update;            
        }
        
        //************************************
           //Query APTaskTemplate__c objects to update fields
        if (APTasksIds.size()>0){
            Map<String,APTaskTemplate__c> mapAPTasks = new Map<String,APTaskTemplate__c>();
            List<APTaskTemplate__c> aptList =  [select  a.Status__c,a.Id,a.APTaskTemplate__r.Status__c,a.ActivityDate__c,a.Minutes_Reminder__c
                                            from APTaskTemplate__c a 
                                            where a.Id in: APTasksIds ];
            //create a MAP with APTask id, and APTask object                        
            for(APTaskTemplate__c apt : aptList){
                mapAPTasks.put(apt.Id, apt);
            }
            List<APTaskTemplate__c> lUpsert = new List<APTaskTemplate__c>();
            APTaskTemplate__c tmp ;
            Integer taskTemplateNameLength  = APTaskTemplate__c.Name.getDescribe().getLength();
            for( Task t : Trigger.new ) {
                tmp = mapAPTasks.get(t.TaskTemplateId__c);
                if (tmp != null){
                    tmp.Subject__c  = t.Subject;
                    tmp.Name  = t.Subject.substring( 0, math.min( taskTemplateNameLength, t.Subject.length() ) ) ;//t.Subject;
                    tmp.Comments__c = t.Description;
                    tmp.Priority__c = t.Priority;
                    tmp.User__c     = t.OwnerId; 
                    lUpsert.add(tmp);   
                }
            }
            if (lUpsert.size()>0){
                upsert lUpsert;
            }
        }
        
      
    }
    
    if ( trigger.isDelete  ){
        
        List<String> taskTempIds = new List<String>();  
            
         if (trigger.isAfter){
            List<String> finalIds = new List<String>();
            for( Task t : trigger.old ){
                if( t.TaskTemplateId__c != null ){
                    taskTempIds.add( t.TaskTemplateId__c );
                } 
            }
            //only delete Action Plan Template Tasks that are not deleted
            
            for( APTaskTemplate__c ta : [select  a.Id ,a.Action_Plan__c 
                                        from APTaskTemplate__c a 
                                        where id  in: taskTempIds and isDeleted = false  ALL ROWS ] ){
                finalIds.add( ta.Id );
            }                                   
                                                        
            if (finalIds.size()>0){
                  if (ProcessorControl.inBatchContext){
                    //delete 
                    delete [select aPT.id from APTaskTemplate__c aPT where aPT.id in : finalIds];
                }else{
                    ActionPlansTaskTriggerUtilities.deleteAPTasks( finalIds );
                }
            }
        }
        if (trigger.isBefore){
            
            for( Task t : trigger.old ){
                if( t.TaskTemplateId__c != null ){
                    taskTempIds.add( t.TaskTemplateId__c );
                } 
            }
            //only delete Action Plan Template Tasks that are not deleted
            //create any task depending on this one 
            ActionPlansTaskTriggerUtilities.initDependentTasksAndReset( taskTempIds);
        }
        
    }
    
}