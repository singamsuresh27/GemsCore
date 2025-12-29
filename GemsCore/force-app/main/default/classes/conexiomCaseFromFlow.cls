public class conexiomCaseFromFlow {
@InvocableMethod        
    public static List<flowOutputs> parseCase(flowInputs[] currentInput)
    {
        string msgSubject, BU='', jdeAccountNo='',caseSubject,mailBody,emailId,senderType,currentInstance='';
        List<id> MsgIds = new list<id>();
        List<id> caseIds = new list<id>();
        list<String> toAddresses=new list<string>();
        List<Attachment> allAttachments = new List<Attachment>();
        Map<id,String> senderMap = new Map<id,String>();
        Map<id,EmailMessage> msgCaseMap = new Map<id,EmailMessage>();
        Map<id,list<Attachment>> emailAttachmentsMap = new Map<id,list<Attachment>>();
        flowOutputs returnValues = new flowOutputs();
        List<FlowOutputs> returns = new List<FlowOutputs>();
       	try{ 
        	system.debug(' conexiomCaseFromFlow ');
        	List<OrgWideEmailAddress> sender = [select Id,Address,DisplayName from OrgWideEmailAddress where DisplayName = 'OE'];
           	for(flowInputs singleID :currentInput ){
              	MsgIds.add(singleID.currentRecordId);
            	senderMap.put(singleID.currentRecordId,singleID.myCustomString);
            }
        	List<EmailMessage> msgList =[select id,Subject,ParentId,ToAddress,FromAddress,Incoming,HasAttachment,HtmlBody,TextBody from EmailMessage where EmailMessage.id in :MsgIds];
        	List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();
           	for (EmailMessage msg: msgList) 
            {
                caseIds.add(msg.ParentId);
            }
            for (Attachment a : [SELECT Id, Name, ParentId, Body,ContentType FROM Attachment WHERE ParentId IN :MsgIds]) {            	
                if(emailAttachmentsMap.containsKey(a.ParentId)){
                    List<Attachment> tempLst = emailAttachmentsMap.get(a.ParentId);                    
                    tempLst.add(a);
                    emailAttachmentsMap.put(a.ParentId,tempLst);
                }else{
                    List<Attachment> initalLst = new List<Attachment>();
                    initalLst.add(a);
                    emailAttachmentsMap.put(a.ParentId,initalLst);
                }
    		}
           List<Case> caseList =[select id,subject,accountid,CreatedDate, CaseNumber,OwnerId,account.Conexiom_User__c,account.Business_Unite__c,account.Bill_To_Acct_No__c,account.parentid,account.Parent.Bill_To_Acct_No__c from case where case.id in: caseIds];
           for (EmailMessage emailMsg: msgList) 
            {
                 for (Case cas: caseList) 
            	{
                    if(emailMsg.ParentId == cas.id)
                        msgCaseMap.put(cas.id, emailMsg);
            	}  
            }     
           
           	for (Case c: caseList) 
                {
                    EmailMessage msg = msgCaseMap.get(c.id);
                    if(c.accountid != null)
                    {
                        if(c.Account.Business_Unite__c != null)
                            BU= c.Account.Business_Unite__c;                        
                        if(c.Account.Bill_To_Acct_No__c!=null)
                            jdeAccountNo =c.Account.Bill_To_Acct_No__c;
                        else if(c.Account.ParentId != null && c.Account.Parent.Bill_To_Acct_No__c != null)
                         	jdeAccountNo =c.Account.Parent.Bill_To_Acct_No__c;
                    }
                    caseSubject = c.Subject;  
                    senderType = senderMap.get(msg.Id);                    
                    Constants_For_Apex__mdt senderEmail = Constants_For_Apex__mdt.getInstance(senderType);
                    if(senderEmail != null)
                        emailId = senderEmail.Value__c; 
                    Constants_For_Apex__mdt instance = Constants_For_Apex__mdt.getInstance('Instance');
                    if(instance != null && string.isNotBlank(instance.Value__c))
                		currentInstance = instance.Value__c+': ';
                    
                    toAddresses.add(emailId);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(toAddresses);
                        if(!Test.isRunningTest()){ 
                            mail.setOrgWideEmailAddressId(sender[0].Id);
                        }
                    mail.setWhatId(msg.ParentId); 
                    mail.setPlainTextBody('Your Case: ' + c.Id +' has been created.');
                        
                    if( string.isNotBlank(mail.HtmlBody))
                        mailBody = msg.HtmlBody;
                    else
                        mailBody = msg.TextBody;
                        
                    mail.setHtmlBody(' Hello,<br/> <br/> A new case with an order has been created on '+c.CreatedDate.date().format()+' for <br/><br/>'+
                                     'Line of Business : <b> ' + BU +' </b></br><br/>'+
                                     'JDE Bill To Account Number : <b> ' + jdeAccountNo+' </b></br><br/>'+
                                     'The following E-Mail details have been captured:<br/><br/>'+
                        'To : '+msg.ToAddress+'<br/>'+
                        'From : '+msg.FromAddress+'<br/>'+
                        'Html Body : '+mailBody+'</br>');
                        
                    /*Integer numAtts=[SELECT count() FROM attachment WHERE parentid=: msg.Id];
                    List<Attachment> allAttachment = [
                        SELECT id,name,Body,ContentType FROM Attachment 
                        WHERE ParentId =: msg.Id];*/
                    if(emailAttachmentsMap.get(msg.Id) != null)
               			allAttachments = emailAttachmentsMap.get(msg.Id);
                    mail.setSubject(currentInstance + c.CaseNumber+ ' ' +c.Subject);
                    List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
                    for(Attachment att:allAttachments){
                        system.debug(' Attachment Name : '+att.Name);
                        system.debug(' Attachment ContentType : '+att.ContentType);
                        if(senderType == 'Conexiom')
                        {
                            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                            efa.setFileName(att.Name);
                            efa.setBody(att.Body);
                            efa.setContentType(att.ContentType);
                            efaList.add( efa );
                        }
                        else if(att.Name.contains('.pdf') ||att.Name.contains('.PDF'))
                        {
                            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                            efa.setFileName(att.Name);
                            efa.setBody(att.Body);
                            efa.setContentType('application/pdf');
                            efaList.add( efa );
                        }
                        
                    }
                    if(efaList.size() >0)
                        mail.setFileAttachments(efaList);
                    mailList.add(mail);
           		}
           	if(mailList.size() > 0)
               system.debug(' mailList Size : '+mailList.size());
           	for(Messaging.SendEmailResult rslt:Messaging.sendEmail(mailList))
           	{
               if(rslt.isSuccess())
               {
                   returnValues.result='Success'; 
                   system.debug(' Email Sent Successfully');
               }
               else
               {
                   //do something with ser.getErrors().getTargetObjectId()
                   	String errorMsg = 'Error sending Email Message. Details = ' + rslt.getErrors()[0].getMessage();
                   	System.debug('==========> ' + errorMsg);
                   	returnValues.result='Failed'; 
               }
                   returns.add(returnValues);               
           	}
        	return returns;
        }
        catch (Exception e) {
            System.debug('The following exception has occurred in conexiomCaseFromFlow class : ' + e.getMessage());
            returnValues.errorMsg = e.getMessage();
            returnValues.result='Exception';            
            returns.add(returnValues);
            return returns;
        }
    }
    public class flowInputs  {                  
        @InvocableVariable public id currentRecordId;        
        @InvocableVariable public string myCustomString;
    }
    public class flowOutputs{
        @InvocableVariable public String result;  
        @InvocableVariable public String errorMsg;  
    }
}