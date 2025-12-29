/*
###########################################################################
# File..................: <<Trigger - autoFollowOpportunity >>
# Version...............: <<2.0>>
# Created by............: <<Gazi Ahmed>>
# Created Date..........: <<22-Oct-2013>>
# Last Modified by......: <<Gazi Ahmed>>
# Last Modified Date....: <<02-Jan-2014>>
# Description...........: <<Trigger to make sure OPP team is following the OPP
#                           and make sure if an OPP is closing from Stage 0 to close as lost set value to 0.00 >>
# Change Log............: << make sure if an OPP is closing from Stage 0 to close as lost set value to 0.00 
#                            If an OPP is reopen , change state form close lost to stage 1, populate reopoen date   
#                            Another requirement for this trigger is to email project managers when they are removed
#                            from an OPP. This is not done yet. Gazi Deactivating this trigger. 19 November 2014>>                        
#
# Copyright (c) 2000-2010. Danaher, All Rights Reserved.
#
# Created by the Danaher. Modification must retain the above copyright notice.
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any commercial purpose, without fee, and without a written
# agreement from Gems Sensors and Control, is hereby forbidden. Any modification to source
# code, must include this paragraph and copyright.
#
# Permission is not granted to anyone to use this software for commercial uses.
#
# Contact address: Gems Sensors and Controls, 1 Cowles Rd., Plainville, CT USA 06062
# Company URL : http://www.gemssensors.com
###########################################################################
*/

trigger autoFollowOpportunity on Opportunity (after insert, after update) {
	List<ID> opptyIds = New List<ID> (); 	
    List<ID> oppOwnerId = New List<ID> (); 
    List<ID> listOfOppOwnerChange = New List<ID>();   
    List<ID> listOfProjectManagerChange = New List<ID>(); 
    List<ID> listOfAdditionalPMChange = New List<ID>();   
    List<ID> lstOldOwnerId = New List<ID> ();
    List<ID> lstNewOwnerId = New List<ID> ();
    List<ID> lstOldPmId = New List<ID> ();
    List<ID> lstNewPmId = New List<ID> ();
    integer oppOwnerCount = 0; 
    integer oppProjectManagerCount = 0;
    integer oppAProjectManagerCount = 0; 
    integer oppOwnerManagerCount = 0; 
    List<ID> opptyIdStageChange = New List<ID> ();
    Map<Id,Opportunity> mapUpdateOpportunity=new Map<Id,Opportunity>();
    List<ID> opptyIdStageChange2 = New List<ID> ();
    Map<Id,Opportunity> mapUpdateOpportunity2=new Map<Id,Opportunity>();
	for (Opportunity opp : Trigger.New) {
		//if (opp.IsClosed != True){
			opptyIds.add(opp.Id);
			oppOwnerId.add(opp.OwnerId);	
		//}	
     if(Trigger.isUpdate){	
	 	Opportunity oldOpp = Trigger.oldMap.get(opp.ID);    
     	Opportunity newOpp = Trigger.newMap.get(opp.ID);
     	//Retrieve the old and new Field            
     	ID oldOwnerId = oldOpp.OwnerId;
     	ID newOwnerId = newOpp.OwnerId;
     	lstOldOwnerId.add(oldOpp.OwnerId);
     	lstNewOwnerId.add(newOpp.OwnerId);    	      	    	   	     
     	ID oldPmId = oldOpp.Project_Manager__c;
     	ID newPmId = newOpp.Project_Manager__c; 
     	ID oldAPmId = oldOpp.Additional_Project_Manager__c; 
     	ID newAPmId = newOpp.Additional_Project_Manager__c;  
     	String oldStage =  oldOpp.StageName; 
     	String newStage =  newOpp.StageName;      	
     	//If the fields are different, build a list of old owners    
        if(oldOwnerId != newOwnerId){
           listOfOppOwnerChange.add(oldOwnerId);
         }
         //build a list of old project manager. This is the list that will be removed from following and will get email notification.
         if(oldPmId != newPmId){
           listOfProjectManagerChange.add(oldPmId);
         }  
         //build a list of old additional project manager. This is the list that will be removed from following and will get email notification.
         if(oldAPmId != newAPmId){
           listOfAdditionalPMChange.add(oldAPmId);
         }
         //build a list of opp that are changing stage from  stage 0 to close as lost
         if (oldStage == 'Stage 0 - Pre Project' && newStage == 'Closed Lost')  {
         	opptyIdStageChange.add(opp.ID); 
            Opportunity oppUpdate=new Opportunity(id=opp.ID);
            oppUpdate.Estimated_Quantity__c = 0;
            oppUpdate.Unit_Price__c = 0.00;
            mapUpdateOpportunity.put(opp.ID,oppUpdate);        	
         }  
         if (oldStage == 'Closed Lost' && ( newStage == 'Stage 0 - Pre Project' || newStage == 'Stage 1 - Needs Analysis' || newStage == 'Stage 2 - Solution Presentation/NBO' || newStage == 'Stage 3 – Test and Evaluation' || newStage == 'Stage 4 - Negotiation/Review' || newStage == 'Stage 5 - Commitment' ))  {
         	opptyIdStageChange2.add(opp.ID); 
            Opportunity oppUpdate2=new Opportunity(id=opp.ID);
            oppUpdate2.OPP_Reopen_Date__c = system.today();
            mapUpdateOpportunity2.put(opp.ID,oppUpdate2);        	
         }
                                       
		}	 				     
    }  
    List<Opportunity> opptys=[Select Id, IsClosed, Opportunity_Number__c, Project_Manager__c, Additional_Project_Manager__c, Type, AccountId, StageName, Amount, OwnerId, Owner.isActive, Owner.Managerid, Owner.Job_Title__c  From Opportunity Where Id IN:opptyIds And IsClosed = false];     
    if (listOfOppOwnerChange.size() > 0){
    	List<EntitySubscription> followersToRemove=[SELECT Id FROM EntitySubscription WHERE SubscriberId IN:listOfOppOwnerChange And  ParentId IN : opptyIds LIMIT 1000];
    	try{
        	delete followersToRemove;}catch(DMLException e){system.debug('Followers were not removed properly.  Error: '+e);}
    }
    
    if (listOfProjectManagerChange.size() > 0){
    	List<EntitySubscription> pmFollowersToRemove=[SELECT Id FROM EntitySubscription WHERE SubscriberId IN:listOfProjectManagerChange And  ParentId IN : opptyIds LIMIT 1000];            
    	try{
        	delete pmFollowersToRemove;}catch(DMLException e){system.debug('Followers were not removed properly.  Error: '+e);}
        //Also send this list an email saying they are removed from the OPP	
        /*
        List<User> pm = [SELECT Id, Email From User WHERE Id IN: listOfProjectManagerChange And IsActive = True LIMIT 100];
        //SingleEmailMessage message = new SingleEmailMessage();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        for (Opportunity o : opptys){
        	for (User u: pm){
        		String emailAddr = u.Email;
        		String[] toAddresses = new String[] {emailAddr};
        		mail.setToAddresses(toAddresses);
        		mail.setSubject('Project Manager changed for OPP: '+o.Opportunity_Number__c);
        		mail.setPlainTextBody('Project Manager changed to:');
        		//mail.setPlainTextBody('Project Manager changed to: '+o.Project_Manager__r.FirstName);
        		//mail.setSubject('Owner Changed for Account : ' + trigger.new[0].Name);
           		//mail.setPlainTextBody('Owner of Account: ' + trigger.new[0].Name + ' Changed to ' + newOwnerName);
           		//mail.setHtmlBody('Owner of Account: <b>' + trigger.new[0].Name + '</b> Changed to <b>' + newOwnerName  + '</b>');
           		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        	}
        } */              
    }
    
    if (listOfAdditionalPMChange.size() > 0){
    	List<EntitySubscription> apmFollowersToRemove=[SELECT Id FROM EntitySubscription WHERE SubscriberId IN:listOfAdditionalPMChange And  ParentId IN : opptyIds LIMIT 1000];            
    	try{
        	delete apmFollowersToRemove;}catch(DMLException e){system.debug('Followers were not removed properly.  Error: '+e);}
        //Also send this list an email saying they are removed from the OPP
        /*	
        List<User> apm = [SELECT Id, Email From User WHERE Id IN: listOfAdditionalPMChange And IsActive = True  LIMIT 100];	
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        for (Opportunity o : opptys){
        	for (User u: apm){
        		String emailAddr = u.Email;
        		String[] toAddresses = new String[] {emailAddr};
        		mail.setToAddresses(toAddresses);
        		mail.setSubject('You are no longer the Additional Project Manager for OPP: '+o.Opportunity_Number__c);
        		mail.setPlainTextBody('Additional Project Manager changed.');
           		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        	}
        } */               
    }
 
    //Build list of old and new opp owners manager id here. Then compair to see which one changed. Then delete old manager from following list
    List<ID> listOfOppOwnerManagerChange = New List<ID>();
    if (listOfOppOwnerChange.size() > 0){
    	List<User> oldOwnerManagerId =[SELECT Managerid From User WHERE Id IN : lstOldOwnerId];
    	List<User> newOwnerManagerId =[SELECT Managerid From User WHERE Id IN : lstNewOwnerId];
    	//Now do the two loops to find and build a list on the old manager changed
		for (User oldManager : oldOwnerManagerId){    
			for (User newManager: newOwnerManagerId){        
				if (oldManager.Managerid != newManager.Managerid){           
					//myCount += 1;
					listOfOppOwnerManagerChange.add(oldManager.Managerid);        
				}    
			} 
		} 
		//build the list of SubscriptionId of manager to be deleted 
		if (listOfOppOwnerManagerChange.size() > 0 ){ 
    		List<EntitySubscription> managerFollowersToRemove=[SELECT Id FROM EntitySubscription WHERE  SubscriberId IN : listOfOppOwnerManagerChange And ParentId IN : opptyIds LIMIT 1000];
    		try{delete managerFollowersToRemove;}catch(DMLException e){system.debug('Followers were not removed properly.  Error: '+e);} 
		}
    }       
    
    //List<Opportunity> opptys=[Select Id, Project_Manager__c, Additional_Project_Manager__c, Type, AccountId, StageName, Amount, OwnerId, Owner.isActive, Owner.Managerid, Owner.Job_Title__c  From Opportunity Where Id IN:opptyIds]; 
    List<EntitySubscription> oppOwnerSubs=new List<EntitySubscription>();
    List<EntitySubscription> projectManagerSubs=new List<EntitySubscription>(); 
    List<EntitySubscription> aprojectManagerSubs=new List<EntitySubscription>();    
    List<EntitySubscription> oppOwnerManagerSubs=new List<EntitySubscription>();   
    //Does Subscription exists for opp owner, PM, owners manager
    //Does any Subscription exists for these OPPs
    List<EntitySubscription> oppSubsList=[SELECT ID, SubscriberId, ParentId from EntitySubscription where ParentId IN : opptyIds LIMIT 1000];    
    //Now create a map for EntitySubscription and Opportunity that we can do look-ups on. 
    map<STRING, EntitySubscription> oppSubsMap = new map<STRING, EntitySubscription>(); 
    for (EntitySubscription s1 : oppSubsList){    
         oppSubsMap.put(s1.SubscriberId, s1); 
     }   
    //Now do the matching loop to see if owner is already following the OPP
    for ( Opportunity o1: opptys){
    	//Does Subscription exists for opp owner
    	if ( oppSubsMap.containsKey(o1.OwnerId) ){
    		oppOwnerCount+=1;
    	}
    	//Does Subscription exists for project manager
    	if (oppSubsMap.containsKey(o1.Project_Manager__c)){
    		oppProjectManagerCount+=1;
    	}
    	//Does Subscription exists for opp owners manager. If the OPP owner is not a TM, then managers does not have to follow. Only TM and thier manager needs to follow the OPP. 
    	if (oppSubsMap.containsKey(o1.Owner.Managerid) || o1.Owner.Job_Title__c != 'Territory Manager'){
    		//if(o1.Owner.Job_Title__c != 'Territory Manager'){
    		oppOwnerManagerCount+=1;
    		//}
    	} 
    	//Does Subscription exists for additional project manager (this is not done yet) 
    	if (oppSubsMap.containsKey(o1.Additional_Project_Manager__c)){
    		oppAProjectManagerCount+=1;
    	}         
    }        
   //If  Subscription does not exist for OPP owner add a new Subscription  
   for (Opportunity thisOppty : opptys) {
    	if ( oppOwnerCount > 0 ){//Do nothing
    	
        }
        else
        {  
    	  oppOwnerSubs.add(new EntitySubscription(parentId=thisOppty.id, SubscriberId=thisOppty.OwnerId));	  
        }   	
    }       
  try{
      insert oppOwnerSubs;}catch (DMLException e){system.debug('Oppty Swarm subscriptions were not all inserted successfully.  Error: '+e);}//catch      
  //If  Subscription does not exist for OPP owners manager add a new Subscription  
    for (Opportunity omOppty : opptys) {
    	if ( oppOwnerManagerCount > 0 ){//Do nothing
        }
        else
        {  
    	  oppOwnerManagerSubs.add(new EntitySubscription(parentId=omOppty.id, SubscriberId=omOppty.Owner.Managerid)); 	  
        }   	
    }       
  try{
      insert oppOwnerManagerSubs;}catch (DMLException e){system.debug('Oppty Swarm subscriptions were not all inserted successfully.  Error: '+e); }//catch           
  //If  Subscription does not exist for OPP Project manager add a new Subscription  
    for (Opportunity pmOppty : opptys) {
    	if ( oppProjectManagerCount > 0 ){//Do nothing
        }
        else
        {  
    	  projectManagerSubs.add(new EntitySubscription(parentId=pmOppty.id, SubscriberId=pmOppty.Project_Manager__c)); 	  
        }   	
    }       
  try{
      insert projectManagerSubs;}catch (DMLException e){system.debug('Oppty Swarm subscriptions were not all inserted successfully.  Error: '+e); }//catch   
  //If  Subscription does not exist for OPP Additional Project manager add a new Subscription  
    for (Opportunity apmOppty : opptys) {
    	if ( oppAProjectManagerCount > 0 ){//Do nothing
        }
        else
        {  
    	  aprojectManagerSubs.add(new EntitySubscription(parentId=apmOppty.id, SubscriberId=apmOppty.Additional_Project_Manager__c)); 	  
        }   	
    }       
  try{
      insert aprojectManagerSubs;}catch (DMLException e){system.debug('Oppty Swarm subscriptions were not all inserted successfully.  Error: '+e); }//catch  
  // update the opp value to zero, when stage 0 opps are getting closed as lost.       
	if(mapUpdateOpportunity!=null && mapUpdateOpportunity.size()>0){
        update mapUpdateOpportunity.values(); 
	}
 // set the OPP reopen date when a lost opp is openning	
 	if(mapUpdateOpportunity2!=null && mapUpdateOpportunity2.size()>0){
        update mapUpdateOpportunity2.values(); 
	}
}