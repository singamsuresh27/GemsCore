/*
###########################################################################
# File..................: <<Class - LeadNotesAndAttachments >>
# Version...............: <<1.0>>
# Created by............: <<Siddharth Jain>>
# Created Date..........: <<20-Oct-2010>>
# Last Modified by......: <<Siddharth Jain>>
# Last Modified Date....: <<20-Oct-2010>>
# Description...........: <<Class processing the assignment of Notes and Attachment to project only if a lead is converted
#							and also populate the Lead Creator field on Opportunity. If the no new project    
#                           is created then keep the notes attached to Accounts only >>
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

public with sharing class LeadsNotesAndAttachments 
{
	public List<Id> lstLeadsContactIds = new List<Id>();
	public List<Opportunity> lstOpportunity = new List<Opportunity>();
	public List<Note> lstNotes = new List<Note>();
	public List<Note> lstNewNotes = new List<Note>();
	public List<Attachment> lstAttachment = new List<Attachment>();
	public List<Attachment> lstNewAttachments = new List<Attachment>();
	
	public List<ID> lstOldNoteIds = new List<ID>();
	public List<ID> lstOldAttachmentIds = new List<ID>();
	
	
	public void LinkNotesAndAttachments(List<Lead> lstConvertedLeads)
	{
		//Separate the Leads based on the Project existence as Notes and Attachments
		//needs to be linked to Project instead of Accounts
		for (Lead l : lstConvertedLeads)
		{
			if (l.ConvertedOpportunityId != null)
			{
				lstLeadsContactIds.add(l.ConvertedContactId);
				Opportunity opp = new Opportunity(Id=l.ConvertedOpportunityId);
				opp.Lead_Generator__c = l.CreatedById;
				lstOpportunity.add(opp);
			}
		}
		
		if (!lstOpportunity.isEmpty())
			update lstOpportunity;
		
		//Get the list of Notes and Attachments
		if (!lstLeadsContactIds.isEmpty())
		{
			lstNotes = [Select id, Title, Body, ParentId, IsPrivate,CreatedDate, CreatedBy.Name, CreatedById from Note where ParentId in : lstLeadsContactIds order by CreatedDate desc];
			lstAttachment = [Select ParentId, Name, IsPrivate, Id, CreatedDate, CreatedBy.Name, CreatedById,Description, ContentType, Body From Attachment where ParentId in : lstLeadsContactIds order by CreatedDate desc];
		}
		
		//Iterate through Leads and respective Notes, Create new Notes and attach them to Project, delete old ones attached to Account
		for (Lead l : lstConvertedLeads)
		{
			for (Note n : lstNotes)
			{
				if (n.ParentId == l.ConvertedContactId){
					Note nt = new Note();
					nt.Body =n.Title + '\n' + n.Body;
					string title='Note Created On '+n.CreatedDate + 'by ' + n.CreatedBy.Name;
					if(title.length()>80){
						title=title.substring(0,79);
					}
					nt.Title = title;
					nt.IsPrivate = n.IsPrivate;
					nt.ParentId = l.ConvertedOpportunityId;
					lstNewNotes.add(nt);
					lstOldNoteIds.add(n.Id);
				}
			}
		}
		
		if (!lstNewNotes.isEmpty())
		{
			//system.debug('------------> New Notes available ' + lstNewNotes.size());
			
			insert lstNewNotes;
			Database.Deleteresult[] dr = Database.delete(lstOldNoteIds);
			/*
			if(dr[0].isSuccess())
			{
				// Indicates success
			}
			else 
			{
				// Get first save result error.
				Database.Error err = dr[0].getErrors()[0];
				//system.debug('---------------> Error while deleting Notes' + err.getStatusCode() + '   Message: ' + err.getMessage());
			}
			*/
		}
		
		//Iterate through Leads and respective Attachments, Create new Attachments and attach them to Project, delete old ones attached to Account
		for (Lead l : lstConvertedLeads)
		{
			for (Attachment a : lstAttachment)
			{
				if (a.ParentId == l.ConvertedContactId)
				{
					Attachment att = new Attachment();
					string name='Note Created On '+a.CreatedDate + 'by ' + a.CreatedBy.Name;
					if(name.length()>80){
						name=name.substring(0,79);
					}
					att.Name = name;
					att.ContentType = a.ContentType;
					att.IsPrivate = a.IsPrivate;
					att.ParentId = l.ConvertedOpportunityId;
					att.Description =a.Name + '\n' + a.Description;
					att.Body = a.Body;
					lstNewAttachments.add(att);
					lstOldAttachmentIds.add(a.Id);
				}
			}
		}
		
		if (!lstNewAttachments.isEmpty())
		{
			//system.debug('------------> New Attachments available ' + lstNewAttachments.size());

			insert lstNewAttachments;
			Database.Deleteresult[] dr = Database.delete(lstOldAttachmentIds);
			if(dr[0].isSuccess())
			{
				// Indicates success
			}
			else 
			{
				// Get first save result error.
				Database.Error err = dr[0].getErrors()[0];
				system.debug('---------------> Error while deleting Attachments' + err.getStatusCode() + '   Message: ' + err.getMessage());
			}
		}
		
		
	}
}