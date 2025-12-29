/*
    // Copyright (c) 2014 All Rights Reserved
    // <author>CloudCertitude Technologies </author>
    //<email>rakesh.aggarwal@cloudcertitude.com</email>
    // <date> </date>
*/

public class ShowCaseDetailsController{
    public LIST<Case_Detail__c> lstCaseDetails {get;set;}
    public LIST<CaseDetailModel> modelList {get;set;}
    public Case caseObj {get;set;}
    public boolean isDecline {get;set;}
    public boolean isCaseManager {get;set;}
    public String emailIds {get;set;}
    public String businessUnit{get;set;}
    public String companyId{get;set;}    
    private contact caseContact{get; set;}    
    public EmailMessage emailMsg {get; set;}
    public String fileName{get;set;}
    
    List<Id> entityIds;
    ContentVersion contentVer;
     
    public ShowCaseDetailsController(ApexPages.StandardController sc) {
        LIST<User> u = [select id,Job_Title__c from user where id=: UserInfo.getUserId() and Job_Title__c = 'Case Manager'];
        if(u == null || u.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You should be a Case Manager to perform this task.'));   
            isCaseManager = false;
        }else{
            isCaseManager = true;
        
            Case tempcaseObj = (Case)sc.getRecord();
            caseObj = [select id, ContactId,AccountId,Product_Number__c,Contact.email, Type from Case where id =: tempcaseobj.id];
            lstCaseDetails = [select id,Companyid__c, name,Line_Number__c,Quantity__c,Amount__c, Gems_Part_Number__c,Date_Shipped__c from Case_Detail__c where case__c =: caseObj.id and Case__r.type =: 'RA' and Email_Sent__c = false];
            modelList = new LIST<CaseDetailModel>();
            emailMsg = new EmailMessage();
            isDecline = false;
            fileName='Return Label';
            if(lstCaseDetails != null && lstCaseDetails.size() > 0 ){
                for(Case_Detail__c caseDetail : lstCaseDetails ){
                    companyId = caseDetail.Companyid__c;
                    CaseDetailModel model = new CaseDetailModel();
                    model.flg = false;
                    model.caseDetailObj = caseDetail;
                    modelList.add(model);
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There is No Records for sending email....'));
                return ;    
            }
        }
    }
    
    public PageReference declineMail(){
        isDecline = true;
        return sendingEmail();
    }
    
    public PageReference approvalMail(){
        isDecline = false;
        return sendingEmail();
    }
    
    public PageReference sendingEmail(){
        LIST<Case_Detail__c> updateList = new LIST<Case_Detail__c>();

        EmailTemplate template;
        if(isDecline){
            template = [Select id from EmailTemplate where developername like 'SendingEmailToCaseDetailObjectForDecline'];
        }else{
            if (companyId=='00018'){
                template = [Select id from EmailTemplate where developername like 'EUReturnMaterialAuthorizationApproval'];
            }
            else{
                template = [Select id from EmailTemplate where developername like 'NAReturnMaterialAuthorizationApproval'];
            }
        }
        LIST<Messaging.SingleEmailMessage> mailList = new LIST<Messaging.SingleEmailMessage>();
        
        if(modelList.size() > 0 ){
            for(CaseDetailModel m : modelList){
                if(m.flg){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
                    mail.saveAsActivity = false;
                    mail.setTargetObjectId(caseObj.contactId); 
                   if(emailIds == ''){   
                      	mail.setToAddresses(new String[]{caseObj.contact.email});
                      }else{  
                        LIST<String> tempEIds = new LIST<String>();
                       
                        if(emailIds.indexOf('\n') != -1){
                            tempEIds =  emailIds.split('\n');
                        }else if(emailIds.indexOf(';') != -1){
                            tempEIds =  emailIds.split(';');
                        }else if(emailIds.indexOf(',') != -1){
                            tempEIds =  emailIds.split(',');
                        }
                        else
                        {
                          tempEIds.add(emailIds);
                        }
                       mail.setToAddresses(tempEIds);
                      }
                    
                   // mail.WhatId = m.caseDetailObj.id;
                    mail.WhatId= caseObj.id;
                    mail.setTemplateId(template.id);
                    mail.setSaveAsActivity(false);
                    mail.setSubject(emailMsg.Subject);
                    mail.setHtmlBody(emailMsg.TextBody);
                    mail.setSaveAsActivity(true);
                    
                    Blob pdf=savePDF();
                    List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                    Messaging.EmailFileAttachment mailAtt = new Messaging.EmailFileAttachment();
                    mailAtt.setBody(pdf);
                    mailAtt.setContentType('application/pdf');
                    mailAtt.setFileName(fileName + '.pdf');
                    attachments.add(mailAtt);
                    mail.setFileAttachments(attachments);
                    mailList.add(mail); 
                    m.caseDetailObj.Email_Sent__c = true;
                    updateList.add(m.caseDetailObj);  
                }        
            }
        }
        
        if(!Test.isRunningTest()){
            if(mailList.size() > 0){
                try{
                   
                Messaging.sendEmail(mailList);
                mailList.clear();
                }
                catch(Exception err)
                {
                    System.debug(err);
                }
            }
        }
        if(updateList.size() > 0 ){
            update updateList; 
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select atleast one record to send email.'));
            return null ;     
        }
        return new PageReference('/' + caseObj.id);   
    }
    
    
    
    public PageReference cancelAction(){
        return new PageReference('/' + caseObj.id);
    }
    
    public class CaseDetailModel{
        public boolean flg {get;set;}
        public Case_Detail__c caseDetailObj {get;set;}
        
    }
     public Blob savePDF(){ 
         PageReference VFPageToSave = Page.CaseReturnLabel;
         VFPageToSave.getParameters().put('id', caseObj.Id);
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
         
         /*ContentDocumentLink conDocLink = new ContentDocumentLink();
         conDocLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = : contentVer.Id].ContentDocumentId;
         conDocLink.LinkedEntityId = quote.id;
         conDocLink.ShareType = 'V';
         insert conDocLink;*/
        return attachBody;
     }
    // populate Email Message Template from the database.
    public PageReference populateTemplate() {
		caseObj= [SELECT  CaseNumber,AccountId,ContactId,contact.Email,Companyid__c FROM Case WHERE Id=:caseObj.Id limit 1];
        EmailTemplate emailTemplate;
         if (caseObj.Companyid__c=='00018'){
                emailTemplate = [Select id from EmailTemplate where developername like 'EUReturnMaterialAuthorizationApproval'];
            }
            else{
                emailTemplate = [Select id from EmailTemplate where developername like 'NAReturnMaterialAuthorizationApproval'];
            }
		caseContact = [Select Id,Name,Email FROM contact WHERE ID =:caseObj.ContactId][0];
        Messaging.SingleEmailMessage dummyEmailMsg = new Messaging.SingleEmailMessage();
        dummyEmailMsg.setTemplateId(emailTemplate.Id); 
        dummyEmailMsg.setSaveAsActivity(false);
        // send dummy email to populate HTML letterhead in our EmailMessage object's html body.
        String[] toAddresses = new String[]{caseObj.Contact.Email};
        dummyEmailMsg.setToAddresses(toAddresses);
        
        Savepoint sp = Database.setSavepoint();
        dummyEmailMsg.setTargetObjectId(caseContact.Id);
        dummyEmailMsg.setWhatId(caseObj.Id);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {dummyEmailMsg});
        // now rollback our changes.
        Database.rollback(sp);
        // now populate our fields with values from SingleEmailMessage.
        //system.debug('emailMsg : '+emailMsg);
        emailMsg.ToAddress     = dummyEmailMsg.getToAddresses().get(0);
        emailMsg.Subject     = dummyEmailMsg.getSubject();
        emailMsg.TextBody = dummyEmailMsg.getHtmlBody();//textBody.replaceAll('<[^>]+>',' '); 
        emailMsg.ToAddress   = dummyEmailMsg.getToAddresses().get(0);
        return null;
    }
}