/* 
########################################################################### 
# Project Name..........: <<Gems Sensors >> 
# File..................: <<lastChatterDateTrigger>> 
# Version...............: <<24.0>> 
# Created by............: <<Moseen Khan>> 
# Created Date..........: <<22 May 2012>> 
# Last Modified by......: <<Moseen Khan>> 
# Last Modified Date....: <<22 May 2012>>
# Description...........: <<This trigger is used to update the field called Last Chatter Date in Opportunity>> 
########################################################################### 
*/
 
trigger lastChatterDateTrigger on FeedItem (after insert) {

    List<Opportunity> updateOpportunity=new List<Opportunity>();
    String oppKeyPrefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();

    for(FeedItem fdItem:Trigger.New){
          
     String parentId = fdItem.parentId;   
     if(parentId.startsWith(oppKeyPrefix)){
     Opportunity objOpp = new Opportunity(Id=fdItem.parentId);
     objOpp.Last_Chatter_Date__c = system.now();
     updateOpportunity.add(objOpp);
     
     }
    
    }
    
    update updateOpportunity;
}