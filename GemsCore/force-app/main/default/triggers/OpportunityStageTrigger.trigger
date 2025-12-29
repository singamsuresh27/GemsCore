/* 
########################################################################### 
# Project Name..........: <<Gems Sensors >> 
# File..................: <<OpportunityStageTrigger>> 
# Version...............: <<27.0>> 
# Created by............: <<Balkishan Kachawa>> 
# Created Date..........: <<May 14 2013>> 
# Last Modified by......: <<Gazi Ahmed>> 
# Last Modified Date....: <<May 4 2013>>
# Last Modified Date....: <<July 16 2020>>
# Last Modified by......: <<Udo Faulhaber>> 
# Description...........: << Remove stage checks>>
# Description...........: <<This trigger is for moving the big OPP through every stage/funnel based on the Milestones. Sach stage has Milestones.>> 
########################################################################### 
*/

trigger OpportunityStageTrigger on Opportunity (before insert, before update) {
     oppTriggerHandlerClass triggerHandler = new oppTriggerHandlerClass();
     
     if(Trigger.isInsert) {
         for(Opportunity opp: trigger.new) {
             if(string.isEmpty(opp.stagename))
             opp.stagename = 'Stage 1 - Qualified';
         }
         oppTriggerHandlerClass.addToFunnel(Trigger.New,null);
     }
    if(Trigger.isBefore && Trigger.isUpdate) {
    	oppTriggerHandlerClass.validateOpportunityRevenueForecastCreated(Trigger.New,Trigger.oldMap);
        oppTriggerHandlerClass.addToFunnel(Trigger.New,Trigger.oldMap);
    }
     //fire this only when record type is not OPP Junior
/*     if(Trigger.isUpdate){
        if(oppTriggerHandlerClass.runTrigger){
             oppTriggerHandlerClass.OnBeforeUpdate(Trigger.New,Trigger.newMap,Trigger.old,Trigger.oldMap);
             oppTriggerHandlerClass.runTrigger = false;
         }
     }
*/
 }