trigger opportunityaccountchangetrigger on Opportunity (after update) {
     if (!(Test.isRunningTest()) || (Test.isRunningTest() &&   opporutnityaccountchangeteiggerhandler.Checktest == true)){
          List<CommissionManagerSettings__C> customList = new List<CommissionManagerSettings__C>([select Name,Check__C From CommissionManagerSettings__C Where Name = 'CheckTrigger' AND Check__C = true Limit 1]);
    	 system.debug('customList : '+customList); 
         system.debug('customList size : '+customList.size());
         system.debug('After trigger : '+trigger.isAfter);
          system.debug('After update trigger : '+trigger.isUpdate);
          system.debug('trigger : '+trigger.isBefore);
         if(customList.size() > 0 || Test.isRunningTest())
    
        {
    
    if(trigger.isAfter){
        if(trigger.isUpdate){
            opporutnityaccountchangeteiggerhandler.handle(trigger.old,trigger.newmap,trigger.oldmap);
            opporutnityaccountchangeteiggerhandler.runTrigger = false;
        
        }
    }
}
}
}