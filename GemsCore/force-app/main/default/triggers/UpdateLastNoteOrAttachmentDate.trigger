trigger UpdateLastNoteOrAttachmentDate on Note (after insert, after update) {
    //Create a List to store the Ids of Attachments to be deleted
    Map<Id,Opportunity> mapUpdateOpportunity=new Map<Id,Opportunity>();
    List<ID> opptyIds = New List<ID> ();
    List<FeedItem> feedList=new List<FeedItem>(); 
    Set<String> setFeedItems = new Set<String>();
    Date noteDate = Date.Today();
    String sNoteDate = String.valueOf(noteDate);
    for (Note n : trigger.new){
        //Check to see if the Attachment has an Opportunity as the Parent Record
        String parentIdString = String.valueof(n.parentId);
        if (parentIdString.substring(0,3) == '006'){
        	opptyIds.add(n.parentId);
            Opportunity oppUpdate=new Opportunity(id=n.parentId);
            oppUpdate.Last_Note_or_Attachment_Date__c = System.now();
            mapUpdateOpportunity.put(n.parentId,oppUpdate);                                    
        } // end if
    } // end for
    
    if(mapUpdateOpportunity!=null && mapUpdateOpportunity.size()>0){
        update mapUpdateOpportunity.values(); 
        /*
        if(Trigger.isInsert) 
        {                   
        List<FeedItem> fedLst=[Select  Id, parentId, Body  From FeedItem Where parentId IN:opptyIds And CreatedDate = TODAY AND Type= 'TextPost'];       
        if (fedLst.size() > 0){ 
        	for (FeedItem fed : fedLst){
        		if (fed.Body == 'New note or attachment(s) added to this opportunity on '+sNoteDate+'. Click on the link to view https://c.na4.visual.force.com/apex/ViewAllNotes_Atachments?RecordId='+fed.ParentId){
        			setFeedItems.add(fed.parentId); // this is the list of all unique opp id that already has a fed today.
        		} // end if     	      		
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
    }*/
     
    }  
}