/* 
########################################################################### 
# Project Name..........: <<Gems Sensors >> 
# File..................: <<lastChatterCommentDateTrigger>> 
# Version...............: <<24.0>> 
# Created by............: <<Moseen Khan>> 
# Created Date..........: <<25 May 2012>> 
# Last Modified by......: <<Moseen Khan>> 
# Last Modified Date....: <<25 May 2012>>
# Description...........: <<This trigger is used to update the field called Last Chatter Comment Date in Opportunity>> 
########################################################################### 
*/
 
trigger lastChatterCommentDateTrigger on FeedComment (after insert) {

    List<Opportunity> updateOpportunity=new List<Opportunity>();
    String oppKeyPrefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();

    for(FeedComment fdItem:Trigger.New){
	     String parentId = fdItem.parentId;   
	     if(parentId.startsWith(oppKeyPrefix)){
	     Opportunity objOpp = new Opportunity(Id=fdItem.parentId);
	     objOpp.Last_Chatter_Date__c = system.now();
	     updateOpportunity.add(objOpp);
     }
    
    }
    
    update updateOpportunity;
}