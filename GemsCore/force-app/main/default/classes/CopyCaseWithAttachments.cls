/**
* @File Name        :   CopyCaseWithAttachments
* @Description      :   Invocable method called from "EmailMessage - Create New Case if Closed" flow to create new case and email if existing closed case have reach threshold limit
* @TestClass        :   CopyCaseWithAttachmentsTest
* -------------------------------------------------------------------------------------
**/
public class CopyCaseWithAttachments {

    @InvocableMethod(label='Copy Case with Attachments' description='Copies a Case and its Attachments to a new Case')
	public static void copyCaseWithAttachments(List<EmailAndCaseIds> emailAndCaseIds) {        
    	
        
        string messageSubject, newSubject, newTextBody, newHtmlBody,removeString='';
        List<Case> newCases = new List<Case>();
        List<CaseComment> newCaseComments = new List<CaseComment>();
        List<EmailMessage> newEmailMessages = new List<EmailMessage>();
        Id sourceEmailMessageId,sourceCaseId;
        List<Id> sourceEmailMessageIdList = new List<Id>();
        List<Id> sourceCaseIdList = new List<Id>();
        Case oldCase = new Case();
        Case newCase = new Case();        
        system.debug('copyCaseWithAttachments'+emailAndCaseIds);
        EmailMessage emailMessage = new EmailMessage();
        EmailMessage newEmailMessage = new EmailMessage();
        Map<Id, EmailMessage> emailIdWithMessageMap = new Map<Id, EmailMessage>();
        Map<Id, List<Attachment>> emailIdWithAttachmentsMap = new Map<Id, List<Attachment>>();
        List<Attachment> attachments = new List<Attachment>();
        List<Attachment> emailAttachments = new List<Attachment>();  
        List<Attachment> newCaseAttachments = new List<Attachment>();
        List<Attachment> newEmailAttachments = new List<Attachment>();
        List<Id> caseIds = new List<Id>();
		Case sourceCase = new Case();
        Map<Id, Case> emailIdWithSourceCaseMap = new Map<Id, Case>();
        Map<Id, List<Attachment>> emailIdWithSourceAttachmentsMap = new Map<Id, List<Attachment>>();
        
        try{        
		Group customerServiceQueue = [SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' And DeveloperName ='Customer_Service' limit 1];

        for (EmailAndCaseIds emailAndCase : emailAndCaseIds) {
            sourceCaseId = emailAndCase.caseId;
            sourceEmailMessageId = emailAndCase.emailMessageId;
            
            sourceCaseIdList.add(sourceCaseId);
            sourceEmailMessageIdList.add(sourceEmailMessageId);
            
            /*sourceCase = [select id,CaseNumber,AccountId,BU__c,ContactId,Description,Origin,OwnerId,Priority,RecordTypeId,Status,Subject,SuppliedEmail,Type,CaseCreatedByFlow__c from Case where id =:sourceCaseId];
        	emailIdWithSourceCaseMap.put(sourceEmailMessageId, sourceCase);
            
            attachments = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE ParentId = :sourceCaseId];
            emailIdWithSourceAttachmentsMap.put(sourceEmailMessageId, attachments);
            
            emailMessage = [SELECT Id, Subject, TextBody, HtmlBody, CcAddress,FromAddress, ToAddress,Status,ParentId,FromName FROM EmailMessage WHERE Id = :sourceEmailMessageId];
  			emailIdWithMessageMap.put(sourceEmailMessageId, emailMessage);      
            
            emailAttachments = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE ParentId = :sourceEmailMessageId];
			emailIdWithAttachmentsMap.put(sourceEmailMessageId, emailAttachments);*/
        }
        sourceCase = [select id,CaseNumber,AccountId,BU__c,ContactId,Description,Origin,OwnerId,Priority,RecordTypeId,Status,Subject,SuppliedEmail,Type,CaseCreatedByFlow__c from Case where id IN: sourceCaseIdList];
        emailIdWithSourceCaseMap.put(sourceEmailMessageId, sourceCase);
            
        attachments = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE ParentId IN :sourceCaseIdList];
        emailIdWithSourceAttachmentsMap.put(sourceEmailMessageId, attachments);      
            
        emailMessage = [SELECT Id, Subject, TextBody, HtmlBody, CcAddress,FromAddress, ToAddress,Status,ParentId,FromName FROM EmailMessage WHERE Id IN :sourceEmailMessageIdList];
        emailIdWithMessageMap.put(sourceEmailMessageId, emailMessage);      
            
        emailAttachments = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE ParentId IN :sourceEmailMessageIdList];
        emailIdWithAttachmentsMap.put(sourceEmailMessageId, emailAttachments);
                    
        for (EmailAndCaseIds emailAndCase : emailAndCaseIds) {
            sourceEmailMessageId = emailAndCase.emailMessageId;
            sourceCaseId = emailAndCase.caseId;
			system.debug('sourceCaseId : '+sourceCaseId);
            oldCase = emailIdWithSourceCaseMap.get(sourceEmailMessageId);
            attachments = emailIdWithSourceAttachmentsMap.get(sourceEmailMessageId);
         
            newCase = new Case();
            newCase.AccountId = oldCase.AccountId;
            newCase.BU__c = oldCase.BU__c;
            newCase.CaseCreatedByFlow__c = true;
            newCase.ContactId = oldCase.ContactId;
            newCase.Subject	= oldCase.Subject;
            newCase.Description = oldCase.Description;
            newCase.Origin = oldCase.Origin;
            newCase.OwnerId = customerServiceQueue.Id;
            newCase.Priority = oldCase.Priority;
            newCase.RecordTypeId = oldCase.RecordTypeId;
            newCase.Status = 'New';
            newCase.SuppliedEmail = oldCase.SuppliedEmail;
            newCase.Type = oldCase.Type;
            insert newCase;
            newCases.add(newCase);
			system.debug('newCase.BU__c : '+oldCase.BU__c);
            system.debug('oldCase.BU__c : ' + oldCase.BU__c);
            newCaseAttachments = new List<Attachment>();
            for (Attachment oldAttachment : attachments) {
                Attachment newAttachment = new Attachment(
                    ParentId = newCase.Id,
                    Name = oldAttachment.Name,
                    Body = oldAttachment.Body,
                    ContentType = oldAttachment.ContentType
                );
                newCaseAttachments.add(newAttachment);
            }
            if (!newCaseAttachments.isEmpty()) {
            	insert newCaseAttachments;
            }

            CaseComment newCaseComment = new CaseComment(
                ParentId = newCase.Id,
                CommentBody = 'Created from Closed Case : ' + oldCase.CaseNumber
            );
            newCaseComments.add(newCaseComment);
			emailMessage = emailIdWithMessageMap.get(sourceEmailMessageId);
            emailAttachments = emailIdWithAttachmentsMap.get(sourceEmailMessageId);
            
    		messageSubject=''; newSubject=''; newTextBody=''; newHtmlBody='';removeString='';
           	messageSubject = emailMessage.Subject;
            newSubject = messageSubject;
            newTextBody = emailMessage.TextBody;
            newHtmlBody= emailMessage.HtmlBody;
            removeString='';
            integer startIndex = messageSubject.IndexOf(' [ ref:');
            system.debug('startIndex : '+startIndex);
            if(startIndex > 0)
            {
            removeString = messageSubject.SubString(startIndex+1);        
            newSubject = messageSubject.Substring(0, startIndex);
            System.debug('newSubject : '+newSubject);
            system.debug('removeString : '+removeString);
                if(string.isNotEmpty(newTextBody))
                {                 
                    newTextBody = newTextBody.replace(removeString,'');   
                }
                if(string.isNotEmpty(newHtmlBody))
                {
            		newHtmlBody = newHtmlBody.replace(removeString,'');
                }
            }
            
            newEmailMessage = new EmailMessage();
            newEmailMessage.ParentId = newCase.Id;
            newEmailMessage.CcAddress = emailMessage.CcAddress;
            newEmailMessage.FromAddress = emailMessage.FromAddress;
            newEmailMessage.ToAddress = emailMessage.ToAddress;
            newEmailMessage.FromName = emailMessage.FromName;
            newEmailMessage.Incoming = true;
            newEmailMessage.Subject = newSubject;
            newEmailMessage.TextBody = newTextBody;
            newEmailMessage.HtmlBody = newHtmlBody;
            newEmailMessage.Status = emailMessage.Status;
            insert newEmailMessage;            
            //newEmailMessages.add(newEmailMessage);
            
            newEmailAttachments = new List<Attachment>();
            for (Attachment oldAttachment : emailAttachments) {
                Attachment newAttachment = new Attachment(
                    ParentId = newEmailMessage.Id,
                    Name = oldAttachment.Name,
                    Body = oldAttachment.Body,
                    ContentType = oldAttachment.ContentType
                );
                newEmailAttachments.add(newAttachment);
            }
                      
            system.debug('newAttachments size'+newEmailAttachments.size());
            if (!newEmailAttachments.isEmpty()) {
             	insert newEmailAttachments;
            }
        }
            system.debug('newCaseComments size:'+newCaseComments.size());
        if (!newCaseComments.isEmpty()) {
            insert newCaseComments;
        }
        Long startTime = DateTime.now().getTime();
        Long finalTime = DateTime.now().getTime();
        Long millisecondsToWait = 8000; 
        while (finalTime - startTime < millisecondsToWait) {
        	finalTime = DateTime.now().getTime();
        }
            
        for(case newCaseCreated: newCases)
        {
            caseIds = new List<Id>();
            caseIds.add(newCaseCreated.Id);
            CaseAutoResponse.sendAutoResponseEmail(caseIds);
        }
                
        }
        catch(Exception ex)
        {
            system.debug('CopyCaseWithAttachments Exception : '+ ex.getMessage());
        }
    }

    public class EmailAndCaseIds {
        @InvocableVariable(label='Email Message ID' required=true)
        public Id emailMessageId;

        @InvocableVariable(label='Case ID' required=true)
        public Id caseId;
    }
}