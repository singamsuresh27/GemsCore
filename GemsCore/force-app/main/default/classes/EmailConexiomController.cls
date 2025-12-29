/*
 * Class Name : EmailConexiomController
 * Description : Controller class to send mail to Gems and Setra coneixom based on button selcted from case record
 * Test class : TestEmailConexiom
 * */
public class EmailConexiomController {
    
    public EmailMessage emailMsg {get; set;}
    public List<EmailMessage> emailMsgs {get; set;}
    public Case caseItem {get;set;}
    public Case thisCase {get;set;}
    public boolean ishide {get;set;}
    public List<AttachmentWrapper> attWrapList {get; set;}
    public List<string> selectedAttId{get;set;}
    public List<string> selectedFileId{get;set;}
    private List<OrgWideEmailAddress> sender = null;   
    private static final String SUPPORT_NAME = 'OE';           
    boolean isConexiomUser;
    string jdeAccountNo,emailId1,senderType,currentInstance='';
    public string btnMode{get;set;} 
    List<id> MsgIds = new list<id>();
    
    public EmailConexiomController(ApexPages.StandardController controller) {
        
        attWrapList = new List<AttachmentWrapper>();
        selectedAttId = new List < Id >(); 
        selectedFileId = new List < Id >(); 
        ishide=true;
        emailMsg = new EmailMessage();
        try
        {
            caseItem = (Case)controller.getRecord(); 
            btnMode = Apexpages.currentPage().getParameters().get('ButtonAction'); 
            thisCase = [Select id,status,CaseNumber,subject,PO_No__c,Gems_SO_Number__c,accountid,CreatedDate, Conexiom_Validation_Error__c,account.Conexiom_User__c,account.Business_Unite__c,account.Bill_To_Acct_No__c,account.parentid,account.Parent.Bill_To_Acct_No__c,account.Parent.Conexiom_User__c  from Case where Id=:caseItem.Id limit 1 ];
            sender = [select Id,Address,DisplayName from OrgWideEmailAddress where DisplayName = :SUPPORT_NAME];
            
            emailMsgs = [ SELECT Id, ParentId,Subject,ToAddress,FromAddress,HtmlBody,TextBody from emailmessage where ParentId=: controller.getId() and Incoming=true Order By CreatedDate desc limit 1 ];
           	emailMsg = emailMsgs.size() == 1 ? emailMsgs[0] : new EmailMessage();
               
            for (EmailMessage msg: [ SELECT Id, ParentId,Subject,ToAddress,FromAddress,HtmlBody,TextBody from emailmessage where ParentId=: controller.getId() and Incoming=true]) 
                {
                    MsgIds.add(msg.Id);
                }
                MsgIds.add(controller.getId());
           for (Attachment a : [SELECT Id, Name, ContentType, BodyLength, createddate, ParentId FROM Attachment WHERE ParentId IN :MsgIds]) {            	
                attWrapList.add(new AttachmentWrapper(a));
                }
     	    // Add files to the attachment wrapper list
            for (ContentDocumentLink docLink : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :controller.getId() AND LinkedEntity.Type = 'Case']) {
                for (ContentVersion version : [SELECT Id, Title, VersionData, FileType,ContentSize,CreatedDate FROM ContentVersion WHERE ContentDocumentId = :docLink.ContentDocumentId]) {
                    AttachmentWrapper attWrap = new AttachmentWrapper(version);
                	attWrapList.add(attWrap);
                }
            }
            if(attWrapList.isEmpty())
            {
                ishide = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There should be atleast 1 attachment or file to send for correction.'));
                     
            }
        }
        catch(exception ex)
        {
            ishide = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));                
        }
        
    }

	public PageReference sendAttachment() {
    	try
    	{
            // relatedAccount = [Select id,Conexiom_User__c,Business_Unite__c,Bill_To_Acct_No__c,ParentId from Account where Id=:thisCase.accountid limit 1 ];
            for(AttachmentWrapper attWrap : attWrapList) {
                    if(attWrap.isSelected == true) {
                            selectedAttId.add(attWrap.Id);
                    }
            }
            if(!Test.isRunningTest()){
                if(selectedAttId.isEmpty())
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Select atleast 1 attachment to send for correction.'));
                        return null;  
                    }
            }
            
            if(thisCase.Account.Bill_To_Acct_No__c != null)
                jdeAccountNo = thisCase.Account.Bill_To_Acct_No__c;
            else if(thisCase.Account.Bill_To_Acct_No__c == null && thisCase.Account.ParentId != null)
                jdeAccountNo = thisCase.Account.Parent.Bill_To_Acct_No__c;
            
            if(btnMode == 'Prod')
                senderType = 'Conexiom';
            else if(btnMode == 'SetraProd')
                senderType = 'ConexiomSetra';
            else if(btnMode == 'Test')
                senderType = 'ConexiomTest';
            else if(btnMode == 'SetraTest')
                senderType = 'ConexiomSetraTest';        
            
            Constants_For_Apex__mdt senderEmail = Constants_For_Apex__mdt.getInstance(senderType);
            if(senderEmail != null)
                    emailId1 = senderEmail.Value__c;  
            Constants_For_Apex__mdt instance = Constants_For_Apex__mdt.getInstance('Instance');
            if(instance != null && string.isNotBlank(instance.Value__c))
                currentInstance = instance.Value__c+': '; 
            if((thisCase.PO_No__c != null || thisCase.Gems_SO_Number__c != null) && (btnMode == 'Prod') ) {                
                system.debug('Not allowed to send for correction if PO number or SO number is available');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not allowed to send for correction if PO number or SO number is available'));
                return null;
            }
            else
            {
                selectedAttId.clear();
                selectedFileId.clear();
                for(AttachmentWrapper attWrap : attWrapList) {
                        if(attWrap.isSelected == true && attWrap.type == 'att') {
                            selectedAttId.add(attWrap.Id);
                        }
                    else if(attWrap.isSelected == true && attWrap.type == 'file')
                        {
                            selectedFileId.add(attWrap.Id);
                        }
                    }
             } 
                
            PageReference recordPage = new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
            recordPage.setRedirect(true);
            sendEmail(selectedAttId,selectedFileId,btnMode); 
            return recordPage;
        }
        catch(exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            return null;
        }
        
    }
    // send email message per the attributes specified by user.
    public void sendEmail(List<string> attIds,List<string> fileIds,string btnMode) {
        try {            
            Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();            
            string mailBody, message, toAddress = '', fromAddress = ''; 
            list<String> toAddresses=new list<string>();            
            Messaging.EmailFileAttachment emailAttachment;  
            List<Messaging.EmailFileAttachment> lstFileAttachments = new List<Messaging.EmailFileAttachment>();
            toAddresses.add(emailId1);
            singleEmailMsg.setToAddresses(toAddresses);
            singleEmailMsg.setSubject(currentInstance + thisCase.CaseNumber+ ' ' +thisCase.Subject);
            singleEmailMsg.setPlainTextBody('Your Case: ' + thisCase.Id +' has been created.');
            
            if( string.isNotBlank(emailMsg.HtmlBody))
            {	mailBody = emailMsg.HtmlBody;
            }
            else
            {	mailBody = emailMsg.TextBody;}
            system.debug('mailBody : '+mailBody);
            
            if(mailBody == null)
            {
                mailBody = '';
            }
            else
            {
                toAddress = emailMsg.ToAddress;
                fromAddress = emailMsg.FromAddress;                
            }
            singleEmailMsg.setHtmlBody(' Hello,<br/> <br/> A new case with an order has been created on '+thisCase.CreatedDate.date().format()+' for <br/><br/>'+
                             'Line of Business : <b> ' + thisCase.Account.Business_Unite__c +' </b></br><br/>'+
                             'JDE Bill To Account Number : <b> ' + jdeAccountNo +' </b></br><br/>'+
                             'The following E-Mail details have been captured:<br/><br/>'+
                'To : '+toAddress+'<br/>'+
                'From : '+fromAddress+'<br/>'+
                'Html Body : '+mailBody+'</br>');
            singleEmailMsg.setSaveAsActivity(true);
               if(!Test.isRunningTest()){ 
            		singleEmailMsg.setOrgWideEmailAddressId(sender[0].Id);
               }
            singleEmailMsg.setWhatId(caseItem.id);
			//system.debug(' attIds : '+attIds);
            for (Attachment att : [SELECT Id, Name,Body,ContentType FROM Attachment Where Id in: attIds])
            {
                if (att.Body != null) {
                    emailAttachment = new Messaging.EmailFileAttachment();
                    emailAttachment.setBody(att.Body);
                    emailAttachment.setFileName(att.Name);
                    emailAttachment.setContentType(att.ContentType);
                    lstFileAttachments.add(emailAttachment);
                }
            }
            
            //system.debug(' fileIds :'+fileIds);
            for (ContentVersion file : [SELECT Id, Title, VersionData, FileExtension,ContentSize FROM ContentVersion  Where Id in: fileIds])
            {
                if (file.VersionData != null) {
                    emailAttachment = new Messaging.EmailFileAttachment();
                    emailAttachment.setBody(file.VersionData);
                    emailAttachment.setFileName(file.Title);
                    string fileType = file.FileExtension;
                    if(fileType.toLowercase() == 'pdf')
                    {
                     fileType = 'application/pdf';   
                    } 
                    else if(fileType.toLowercase() == 'jpg' || fileType.toLowercase() == 'png')
                    {
                     fileType = 'image/png';   
                    } 
                    emailAttachment.setContentType(fileType);
                    lstFileAttachments.add(emailAttachment);
                }
            }
            
            singleEmailMsg.setFileAttachments(lstFileAttachments);   
            List<Messaging.SendEmailResult> results =  Messaging.sendEmail(
                new List<Messaging.SingleEmailMessage> {singleEmailMsg});           
           
            if (results[0].success) { 
                system.debug('Success ');
                if(btnMode == 'Prod')
                {
                    User conexUser = [SELECT Id FROM User WHERE Name = 'User Conexiom' LIMIT 1];
                    thisCase.Sent_to_Conexiom__c=true;
                    thisCase.Status='In Progress';
                    thisCase.OwnerId=conexUser.Id;
                    thisCase.Conexiom_Validation_Error__c=false;
                    update thisCase;
                    message = 'Email sent to Conexiom for Correction';             
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,message));
                }
            } else {
                message = 'Error sending Email Message. Details = ' + results.get(0).getErrors()[0].getMessage();
                system.debug('ERROR : '+message);
            }
        
        }
        catch (Exception e) {
            String errorMsg = 'Exception thrown trying to send Email Message. Details = ' + e.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
        }
    }
    
    
     //Attachment Wrapper Class.
    //This wrapper class contains both salesforce Attachment and a Boolean value.
public class AttachmentWrapper {
    public Id Id { get; set; }
    public String Name { get; set; }
    public String ContentType { get; set; }
    public Integer ContentSize { get; set; }
    public Boolean isSelected { get; set; }
    public Attachment att { get; set; }
    public string type {get; set;}
    public string createdDate{get;set;}
    public ContentVersion cv { get; set; }
    
    public AttachmentWrapper(Attachment att) {
        Id = att.Id;
        Name = att.Name;
        ContentType = att.ContentType;
        ContentSize = att.BodyLength;
        createdDate= string.valueOf(att.CreatedDate.date());
        isSelected = false;
        att = att;
        type = 'att';
    }
    
    public AttachmentWrapper(ContentVersion cv) {
        Id = cv.Id;
        Name = cv.Title;
        ContentType = cv.FileType;
        ContentSize = cv.ContentSize;
        createdDate= string.valueOf(cv.CreatedDate.date());
        isSelected = false;
        cv = cv;
        type = 'file';
    }
}

}