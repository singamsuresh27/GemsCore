/* 
########################################################################### 
# Project Name..........: <<Gems Sensors >> 
# File..................: <<UpdateLastNoteOrAttachmentDate>> 
# Version...............: <<27.0>> 
# Created by............: <<Gazi Ahmed>> 
# Created Date..........: <<May 14 2013>> 
# Last Modified by......: <<Gazi Ahmed>> 
# Last Modified Date....: <<May 4 2013>>
# Description...........: <<This trigger will add a new chatter when a new note or attachment is added to the opp. This will be once a day.>> 
########################################################################### 
*/
trigger newNoteOrAttachmentChatter on Opportunity (after update) {
	Map<Id,Opportunity> newOppMap = Trigger.newMap;
	Map<Id,Opportunity> oldOppMap = Trigger.oldMap;
	List<ID> opptyIds = New List<ID> ();
	
	List<FeedItem> feedList=new List<FeedItem>(); 
    Set<String> setFeedItems = new Set<String>();    
	Date noteDate = Date.Today();
    String sNoteDate = String.valueOf(noteDate);
	
	//Loop through the map and build a list of opp id that changed note date value
	for(Id opportunityId:newOppMap.keySet()){
 	Opportunity newOpp = newOppMap.get(opportunityId);
 	Opportunity oldOpp = oldOppMap.get(opportunityId);
 		if (newOpp.Last_Note_or_Attachment_Date__c<> oldOpp.Last_Note_or_Attachment_Date__c && oldOpp.Product_Model__c != Null){
   			//build list of opp id that was just uptated the field value.
   			opptyIds.add(newOpp.Id);
 		}
	}
	// find which one of these opp has a new note chatter, if not add a new note chatter to the opp.		
	    if (opptyIds.size() > 0){                    
        	List<FeedItem> fedLst=[Select Id, parentId, Body  From FeedItem Where parentId IN:opptyIds And CreatedDate = TODAY AND Type= 'TextPost' LIMIT 20]; // list of all feed for today      
        	if (fedLst.size() > 0){ 
        		for (FeedItem fed : fedLst){
        			if (fed.Body == 'New note or attachment(s) added to this opportunity on '+sNoteDate+'. Click on the link to view https://c.na4.visual.force.com/apex/ViewAllNotes_Atachments?RecordId='+fed.ParentId){
        				setFeedItems.add(fed.parentId); // this is the list of all unique opp id that already has a chatter feed today.
        			} // end if
        			// find which OPP does not have a feed today for new notes. If no feed exists add a new feed for the first note added to this OPP.
        			// remember this chatter feed for new notes will be only one time every day.     	      		
        			for (FeedItem fed1 : fedLst){
        				for (String fed2 : setFeedItems){
        					if (fed1.ParentId != fed2){
        						feedList.add(new FeedItem(parentId=fed1.parentId, Body = 'New note or attachment(s) added to this opportunity on '+sNoteDate+'. Click on the link to view https://c.na4.visual.force.com/apex/ViewAllNotes_Atachments?RecordId='+fed.ParentId));  
        					} // end if       			
        				} // end inner for loop
        	 		} // end outer for loop	
           	}// end first for loop
        	}
        	else{
        		for (Integer j = 0; j< opptyIds.size(); j++){
        			if(j==0){
        			feedList.add(new FeedItem(parentId=opptyIds[j], Body = 'New note or attachment(s) added to this opportunity on '+sNoteDate+'. Click on the link to view https://c.na4.visual.force.com/apex/ViewAllNotes_Atachments?RecordId='+opptyIds[j]));
        			} 
        		}
        	} // end second if else               
    	}// end first if
    	if (feedList!=null && feedList.size() > 0){
    		insert feedList;  
    	}     		
}