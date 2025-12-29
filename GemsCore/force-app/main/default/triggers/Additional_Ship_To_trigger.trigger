trigger Additional_Ship_To_trigger on Additional_Ship_To__c (before insert, before delete,after update) {
	 if (!(Test.isRunningTest()) || (Test.isRunningTest() &&  opprtunity_trigger_handler.Checktest == true)) {
            List<CommissionManagerSettings__C> customList = new List<CommissionManagerSettings__C>([select Name,Check__C From CommissionManagerSettings__C Where Name = 'CheckTrigger' AND Check__C = true Limit 1]);
    if(customList.size() > 0)
    
        {
    
            if(trigger.isbefore){
                if(trigger.isinsert){
                    opprtunity_trigger_handler.trigger_handler_method(trigger.new,true,false,false,null,null);
                    opprtunity_trigger_handler.runTrigger = false;
                }
                if(trigger.isdelete){
                    opprtunity_trigger_handler.trigger_handler_method(trigger.old,false,true,false,null,null);
                    opprtunity_trigger_handler.runTrigger = false;
                }
            }
            if(trigger.isafter){
                if(trigger.isupdate){
                    opprtunity_trigger_handler.trigger_handler_method(trigger.old,false,false,true,trigger.newmap,trigger.oldmap);
                    opprtunity_trigger_handler.runTrigger = false;
                }
            }

        }
    
    }
}