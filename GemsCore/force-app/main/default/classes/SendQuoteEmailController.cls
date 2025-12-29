/*
** Class:  SendQuoteEmailController
** Description: Controller for the SendQuoteEmail custom Visual Force page. 
*/
public with sharing class SendQuoteEmailController {

    public String addlRecipients {get; set;}
    private Quotation_Setra__c thisQuote {get; set;}
    private Quotation_Setra__c quote {get;set;}    
    private contact quoteContact{get; set;}
    public EmailMessage emailMsg {get; set;}
   // private OrgWideEmailAddress sender = null;
    ID parentID{get; set;}
    public String fileName{get;set;}
    List<Id> entityIds;
    ContentVersion contentVer;
    private static final String SUPPORT_NAME = 'Setra Customer Service';

    public SendQuoteEmailController(ApexPages.StandardController controller) {
        parentID = controller.getId();
        thisQuote = (Quotation_Setra__c)controller.getRecord();
        fileName=thisQuote.Name;
        emailMsg = new EmailMessage();
        // get org-wide email address to set from/sender field
       // sender = [select Id,Address from OrgWideEmailAddress where DisplayName = :SUPPORT_NAME];
    }

    public Attachment attachment {
        get {
            if (attachment==null) {
                attachment = new Attachment();
            }
            return attachment;
        }
        set;
    }    
    // send email message per the attributes specified by user.
    public PageReference sendEmail() {
        try {
            quote= [SELECT Name,Contact__c,Contact__r.Name,Contact__r.Id,Contact__r.Email,Owner.name,Owner.email FROM Quotation_Setra__c WHERE Id=:thisQuote.Id limit 1];  

            Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();
            
            if (emailMsg.CcAddress != null && emailMsg.CcAddress != '') {
                singleEmailMsg.setCcAddresses(emailMsg.CcAddress.split(';'));
            }
            //singleEmailMsg.setOrgWideEmailAddressId(sender.Id); 
            singleEmailMsg.setSubject(emailMsg.Subject);
            singleEmailMsg.setPlainTextBody(emailMsg.TextBody);
            singleEmailMsg.setSaveAsActivity(true);
            singleEmailMsg.setWhatId(thisQuote.id);
            singleEmailMsg.setTargetObjectId(quoteContact.id);

            // now add additional recipients
            String[] addlToAddresses = null;
            if (addlRecipients != null && addlRecipients != '') {
                addlToAddresses = addlRecipients.split(';');
            }
            List<String> lstToAddresses = null;
            if (addlToAddresses != null) {
                lstToAddresses = new List<String>(addlToAddresses);
            } else {
                lstToAddresses = new List<String>();
            }
            lstToAddresses.add(emailMsg.ToAddress);
            singleEmailMsg.setToAddresses(lstToAddresses); 

            emailMsg.ToAddress += (addlRecipients != null ? ';' + addlRecipients : '');
            
            //Messaging.EmailFileAttachment emailAttachment;
            ContentVersion contentVer2;
           if (attachment.Body != null) {
               // attach file to email if there is one. Have to check the Body as Attachment
                // itself will never be null as it is always created first time it is accessed.
                contentVer2 = new ContentVersion();
                contentVer2.versionData = attachment.Body; 
                contentVer2.title = attachment.Name;
                contentVer2.pathOnClient = attachment.Name;
                insert contentVer2;
               
                //emailAttachment = new Messaging.EmailFileAttachment();
                //emailAttachment.setBody(attachment.Body);
                //emailAttachment.setFileName(attachment.Name);
            }
            
			Blob pdf=savePDF();
            
            Messaging.EmailFileAttachment mailAtt = new Messaging.EmailFileAttachment();
            mailAtt.setBody(pdf);
            mailAtt.setContentType('application/pdf');
            mailAtt.setFileName(fileName +'.pdf');
            if(attachment.Body != null){
            	//singleEmailMsg.setFileAttachments(new Messaging.EmailFileAttachment[]{mailAtt,emailAttachment});
            	entityIds = new List<Id>{contentVer.id,contentVer2.id};
            	singleEmailMsg.setEntityAttachments(new List<Id>(entityIds));
        	}
            else{
               // singleEmailMsg.setFileAttachments(new Messaging.EmailFileAttachment[]{mailAtt});
                entityIds = new List<Id>{contentVer.id};
            	singleEmailMsg.setEntityAttachments(new List<Id>(entityIds));
            }
            List<Messaging.SendEmailResult> results =  Messaging.sendEmail(
                new List<Messaging.SingleEmailMessage> {singleEmailMsg});
            if (results[0].success) {                
                PageReference pgRef = new PageReference('/' + thisQuote.Id);
                pgRef.setRedirect(true);
                return pgRef;
            } else {
                String errorMsg = 'Error sending Email Message. Details = ' + results.get(0).getErrors()[0].getMessage();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
                return null;
            }
        }
        catch (Exception e) {
            String errorMsg = 'Exception thrown trying to send Email Message. Details = ' + e;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
            return null;
        }
    }
    public Blob savePDF(){ 
       	Id userId =UserInfo.getUserId();
        User Information = [SELECT Id, Business_Unit__c FROM User WHERE Id =: userId];
        PageReference VFPageToSave;
        if(Information.Business_Unit__c == 'GEMS_EU'){
            VFPageToSave = Page.CustomQuotePDFLayoutEMEA;
        }
        else{
            VFPageToSave = Page.CustomQuotePDFLayout; 
        }
         VFPageToSave.getParameters().put('id', parentID);
         VFPageToSave.setRedirect(true);
         Blob attachBody;
         try {
             attachBody = VFPageToSave.getContentAsPDF();
         } catch (VisualforceException e) {
             System.debug(e.getMessage());
             attachBody = Blob.valueOf('Error generating the PDF. Please contact your administrator.');
         }
         contentVer = new ContentVersion();
         contentVer.versionData = attachBody;         
         contentVer.title = fileName;
         contentVer.pathOnClient = fileName + '.pdf'; 
         insert contentVer;
         
         ContentDocumentLink conDocLink = new ContentDocumentLink();
         conDocLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = : contentVer.Id].ContentDocumentId;
         conDocLink.LinkedEntityId = quote.id;
         conDocLink.ShareType = 'V';
         insert conDocLink;
        return attachBody;
     }
    // cancel creation of emailMessage. 
    public PageReference cancel() {
        PageReference pgRef = new PageReference('/' + thisQuote.Id);
        pgRef.setRedirect(true);
        return pgRef;
    }

    // populate Email Message Template from the database.
    public PageReference populateTemplate() {
        try
        {
        EmailTemplate emailTemplate = [select Body, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where DeveloperName='CustomQuote' limit 1];
		quote= [SELECT Name,Contact__c,Contact__r.Name,Contact__r.Id,Contact__r.Email,Owner.name,Owner.email FROM Quotation_Setra__c WHERE Id=:thisQuote.Id limit 1];  
		quoteContact = [Select Id,Name,Email FROM contact WHERE ID =:quote.Contact__c][0];
        Messaging.SingleEmailMessage dummyEmailMsg = new Messaging.SingleEmailMessage();
        dummyEmailMsg.setTemplateId(emailTemplate.Id); 
        dummyEmailMsg.setSaveAsActivity(false);

        // send dummy email to populate HTML letterhead in our EmailMessage object's html body.
        String[] toAddresses = new String[]{quote.Contact__r.Email};
        dummyEmailMsg.setToAddresses(toAddresses);
        
        // now send email and then roll it back but invocation of sendEmail() 
        // means merge of letterhead & body is done
        // TargetObject is User. This tells the emailMsg to use the email message
        // associated with our dummy User. This is necessary so we can populate our
        // email message body & subject with merge fields from template
        Savepoint sp = Database.setSavepoint();

        dummyEmailMsg.setTargetObjectId(quoteContact.Id);
        dummyEmailMsg.setWhatId(thisQuote.Id);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {dummyEmailMsg});
        // now rollback our changes.
        Database.rollback(sp);

        // now populate our fields with values from SingleEmailMessage.
        //emailMsg.BccAddress  = UserInfo.getUserEmail();
        emailMsg.Subject     = dummyEmailMsg.getSubject();
        emailMsg.TextBody    = dummyEmailMsg.getPlainTextBody();
        emailMsg.ToAddress   = dummyEmailMsg.getToAddresses().get(0);
        //emailMsg.FromAddress = sender.Address; 
        emailMsg.CcAddress   = UserInfo.getUserEmail();
        emailMsg.ParentId    = thisQuote.Id;
        	return null;
        }
        catch (Exception e) {
            String errorMsg = e.getMessage();
            if(errorMsg.contains('INVALID_EMAIL_ADDRESS'))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Kindly verify contact email address is valid.'));
            }
            else
            {
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
        	}
            return null;
        }
    }
}