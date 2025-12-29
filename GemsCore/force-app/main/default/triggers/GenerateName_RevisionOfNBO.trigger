/*
###########################################################################
# File..................: <<Trigger - LeadNotesAndAttachments >>
# Version...............: <<1.0>>
# Created by............: <<Anand Singh>>
# Created Date..........: <<4-Jan-2011>>
# Last Modified by......: <<Anand Singh>>
# Last Modified Date....: <<4 - Jan-2011>>
# Description...........: <<Use All NBO in Single Objects >>
# Change Log............: << >>  
#                           
#
# Copyright (c) 2000-2010. Astadia, Inc. All Rights Reserved.
#
# Created by the Astadia, Inc. Modification must retain the above copyright notice.
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any commercial purpose, without fee, and without a written
# agreement from Astadia, Inc., is hereby forbidden. Any modification to source
# code, must include this paragraph and copyright.
#
# Permission is not granted to anyone to use this software for commercial uses.
#
# Contact address: 2839 Paces Ferry Road, Suite 350, Atlanta, GA 30339
# Company URL : http://www.astadia.com
###########################################################################
*/

trigger GenerateName_RevisionOfNBO on NBO_Forms__c (before insert,before Update) {

	if(Trigger.isInsert){
		List<RecordType> RecordTypeList=Utility.NBORecordTypeList();
		Map<string,string> MapRecordTypeDev=new map<string,string>();
		Map<String,NBO_Form_Record_Type_Name__c> mapRecordType = NBO_Form_Record_Type_Name__c.getAll();	
		if(RecordTypeList.size()>0){
			for(RecordType retc:RecordTypeList){
				MapRecordTypeDev.put(retc.id,retc.DeveloperName);
			}
		}	
		Map<string,string> MapNBO=new Map<string,string>(); 
		string OppId,FromClonedRecordName,NewRevisionNumber;
		string MasterRecordForClone;		
		set<Id> RecordTypeId=new Set<Id>();
		integer MaxNumber=1;
		//Get Record Type of NBO Form
		for(NBO_Forms__c NBO:Trigger.New){
			
			if(NBO.Clone_Record__c==null){
				RecordTypeId.add(NBO.RecordTypeId);
				OppId=NBO.Opportunity__c;
			}
			if(NBO.Clone_Record__c!=null){
				//get the Name of record
				FromClonedRecordName=NBO.Name;
				MasterRecordForClone=NBO.Clone_Record__c;
			}
		}
		
		if(FromClonedRecordName==null){
			//get Last record Of This Record type
			List<NBO_Forms__c> ListNBO=[select Name from NBO_Forms__c where RecordTypeId in :RecordTypeId and Opportunity__c=:OppId order by CreatedDate desc limit 1 ];
			if(ListNBO.size()>0){
				//get Number from NBO Name
				string NBOName=ListNBO[0].Name;
				integer IndexOf=NBOName.indexOf('-');
				MaxNumber=integer.valueOf(NBOName.substring(IndexOf+1,NBOName.length()))+1;
			}
			
			for(NBO_Forms__c NBO:Trigger.New){
				if(NBO.Clone_Record__c==null){
					string NBOType=Utility.getNBOType(MapRecordTypeDev.get(NBO.RecordTypeId), mapRecordType);
					NBO.Name=NBOType+NBO.Opportunity_Number__c+'-'+MaxNumber;	
					NBO.Revision_Number__c='A';
				}
			}
		}
		if(FromClonedRecordName!=null){
			List<NBO_Forms__c> ListNBO1=[select Id, Name from NBO_Forms__c where Id=:MasterRecordForClone limit 1];
			List<NBO_Forms__c> ListNBO=[select Revision_Number__c from NBO_Forms__c where Name=:FromClonedRecordName order by CreatedDate desc limit 1 ];
			
			if(ListNBO.size()>0){
				NewRevisionNumber=Utility.getRevisionNumber(ListNBO[0].Revision_Number__c);
			}
			
			for(NBO_Forms__c NBO:Trigger.New){
				if(ListNBO1.size()==0 || ListNBO.size()==0){
					 NBO.addError('You cannot change clone record field. Please click Cancel and try again.');
				}
				else if(NBO.Clone_Record__c!=null){
					//Changes as on 25th May 2012 as per Gazi by Anand
					string NewName=ListNBO1[0].Name;
						if(ListNBO1[0].Name.substring(0,3)=='LES'){
							NewName=ListNBO1[0].Name.replace('LES','PTL');
						} 
						if(ListNBO1[0].Name.substring(0,3)=='FLT'){
							NewName=ListNBO1[0].Name.replace('FLT','PTL');
						} 
					NBO.Name=NewName;
					NBO.Revision_Number__c=NewRevisionNumber;
				}
			}
		}
	}
	if(Trigger.isUpdate){
		for(NBO_Forms__c NBO:Trigger.New)
        {
            NBO.Name=Trigger.oldMap.get(NBO.id).Name;
            NBO.Revision_Number__c=Trigger.oldMap.get(NBO.id).Revision_Number__c;
        }
	}
}