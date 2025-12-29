/*
###########################################################################
# File..................: <<Trigger - autoFollowOpportunity >>
# Version...............: <<2.0>>
# Created by............: <<Gazi Ahmed>>
# Created Date..........: <<22-Oct-2013>>
# Last Modified by......: <<Gazi Ahmed>>
# Last Modified Date....: <<02-Jan-2014>>
# Description...........: <<This job will check the box if a action plan task is due in a week
#                           >>
# Change Log............: << 
#                            >>                        
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
global class ActionPlanBatchTaskDueStatusUpdate implements Database.Batchable<sObject> {
	// variables   
	String query;
	// Batch Constructor 
	//global ActionPlanBatchTaskDueStatusUpdate(){
		//query = q;
	//}
	// Start Method  
	global Database.QueryLocator start(Database.BatchableContext BC){
		String stas = 'Completed';
		query = 'Select Id, Due_In__c, ActivityDate__c From APTaskTemplate__c Where Status__c <> : stas ';
      	return Database.getQueryLocator(query);       
    }
    
	global void execute(Database.BatchableContext BC, List<APTaskTemplate__c> scope){
		Integer numberDaysDue = 0;
		List<APTaskTemplate__c> apTaskList = new List<APTaskTemplate__c>(); 
		if(scope.size()>0){		
			for(APTaskTemplate__c apt : scope){
				if (apt.ActivityDate__c != Null){
					numberDaysDue = Date.today().daysBetween(apt.ActivityDate__c);
					apt.Due_In__c = numberDaysDue;
				}
				apTaskList.add(apt);			
			}
		}		
		update apTaskList;			
	}
	// Logic to be Executed at finish 
	global void finish(Database.BatchableContext BC){          
		// Logic to be Executed at finish     
	}
    
}