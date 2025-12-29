trigger AddTaskToOpp on Opportunity (before insert,after insert,before update) {
    
    System.debug('--------> checkTest---   '+OppAddTaskHandler.checkTest);

   if (!(Test.isRunningTest()) || (Test.isRunningTest() &&  OppAddTaskHandler.checkTest == true)) {

    OppAddTaskHandler triggerHandler = new OppAddTaskHandler();
    List<StageAutomation__c> customList = new List<StageAutomation__c>([select Name,IsChecked__c From StageAutomation__c Where Name = 'CheckTrigger' AND IsChecked__c = true Limit 1]);
    if(customList.size() > 0){
        if(Trigger.isInsert){
            if(OppAddTaskHandler.runTrigger){    
                if(Trigger.isBefore){
                    triggerHandler.OnBeforeInsert(Trigger.New,Trigger.newMap);
                }
                if(Trigger.isAfter){
                    triggerHandler.OnAfterInsert(Trigger.New,Trigger.newMap,Trigger.old,Trigger.oldMap);
                    OppAddTaskHandler.runTrigger = false;
                }
            }
        }
        
        if(Trigger.isUpdate){
            if(OppAddTaskHandler.runTrigger){
                triggerHandler.OnBeforeUpdate(Trigger.New,Trigger.newMap,Trigger.old,Trigger.oldMap);
                OppAddTaskHandler.runTrigger = false;
                //TaskTriggerHandlerClass.runME = false;
            }
        }
    }
     System.debug('Limit queries'+System.limits.getLimitQueries() + '  '+System.limits.getQueries());


    }
}