public class ContractExpirationReminder {
	
    @InvocableMethod        
    public static List<flowOutputs> parseContract(flowInputs[] currentInput)
    {
        ID rId;
        String subject, htmlBody,recordlink,reminderType,cemsEmail;
        List<String> sendTo = new list<String>(); 
        flowOutputs returnValues = new flowOutputs();
        List<FlowOutputs> returns = new List<FlowOutputs>();
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();            
        EmailTemplate emailTemplate;
        List<Contact> contList = new List<Contact>();
        try{  
            for(flowInputs singleID :currentInput ){
                rId = singleID.currentRecordId; 
            }
            reminderType = currentInput[0].myCustomString;
            OrgWideEmailAddress sender = [select Id,Address from OrgWideEmailAddress where DisplayName = 'Setra CEMS Team'];
            
            List<contract> ctractList =[select id,AccountId,enddate from contract where Id =:rId];         
            Contract ctract = ctractList[0];
            Account acct =[select id,Name,Bill_To_Acct_No__c,AccountNumber,CEMS_Renewal_Part_Number__c,CEMS_Primary_Email__c,CEMS_Renewal_Price__c,CEMS_Length_of_Contract__c,ownerid,owner.Name from Account where Id =:ctract.AccountId and CEMS_Length_of_Contract__c != null limit 1];
            if(acct != null)
             contList = [select id, Name, FirstName, LastName, Role__c,Email from Contact where AccountId =:acct.id and Role__c includes ('CEMS Primary') limit 1];
            if(contList.size() > 0)
            {
                string Day30ReminderToAddress='';
                Contact cont = contList[0]; 
                User acctOwnerUser=[select name,id,email from user where id =:acct.OwnerId limit 1];  
                cemsEmail = acct.CEMS_Primary_Email__c != null ? acct.CEMS_Primary_Email__c :'';
                
                 if (reminderType == '90')
                    emailTemplate = [Select Id,Markup,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = '90 Day Renewal Notice'];
                else if (reminderType == '60')
                    emailTemplate = [Select Id,Markup,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = '60 Day Renewal Notice'];
                else if (reminderType == '30')
                {
                    emailTemplate = [Select Id,Markup,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = '30 Day Renewal Notice to CS'];
                	Constants_For_Apex__mdt reminder30DayEmail = Constants_For_Apex__mdt.getInstance('X30DayContractReminderEmail');
					if(reminder30DayEmail.Value__c != null)
                    	Day30ReminderToAddress = reminder30DayEmail.Value__c;
                    sendTo.add(Day30ReminderToAddress);
                }
                
                if(reminderType != '30')
                {					
                    if(cemsEmail != null && cemsEmail.length() >0)
                        sendTo.add(acct.CEMS_Primary_Email__c);
                    sendTo.add(acctOwnerUser.email);                    
                }
                Messaging.SingleEmailMessage msg= new Messaging.SingleEmailMessage();
                msg.setToAddresses(sendTo);
                msg.setOrgWideEmailAddressId(sender.Id);
               // msg.setTargetObjectId(cont.Id);
                              
                msg.setTemplateID(emailTemplate.Id);
                msg.setWhatId(rId);
                // process the merge fields
                recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+acct.Id;
                subject = emailTemplate.Subject;
                htmlBody = emailTemplate.HtmlValue;
                htmlBody = cont.FirstName != null ? htmlBody.replace('{!Contact.FirstName}', cont.FirstName) : htmlBody.replace('{!Contact.FirstName}', '');
                htmlBody = ctract.enddate != null ? htmlBody.replace('{!Contract.EndDate}', string.valueOf(ctract.enddate)) : htmlBody.replace('{!Contract.EndDate}', '');  
                htmlBody = acct.CEMS_Renewal_Price__c != null ? htmlBody.replace('{!Account.CEMS_Renewal_Price__c}', String.valueOf(acct.CEMS_Renewal_Price__c)) : htmlBody.replace('{!Account.CEMS_Renewal_Price__c}','');
                htmlBody = htmlBody.replace('{!Account.OwnerFullName}', acct.owner.Name);
                htmlBody = htmlBody.replace('{!Account.Link}', recordLink);
                htmlBody = cont.Name != null ? htmlBody.replace('{!Contact.Name}', cont.Name) : htmlBody.replace('{!Contact.Name}', '');
                htmlBody = cont.Email != null ? htmlBody.replace('{!Contact.Email}', cont.Email) : htmlBody.replace('{!Contact.Email}', '');
                
                if (reminderType == '30')
                {
                    htmlBody = htmlBody.replace('{!Account.Name}', acct.Name);
                    htmlBody = acct.Bill_To_Acct_No__c != null ? htmlBody.replace('{!Account.Bill_To_Acct_No__c}', acct.Bill_To_Acct_No__c) : htmlBody.replace('{!Account.Bill_To_Acct_No__c}', '');
                    htmlBody = acct.AccountNumber != null ? htmlBody.replace('{!Account.AccountNumber}', acct.AccountNumber) : htmlBody.replace('{!Account.AccountNumber}', '');
                    htmlBody = acct.CEMS_Renewal_Part_Number__c != null ? htmlBody.replace('{!Account.CEMS_Renewal_Part_Number__c}', acct.CEMS_Renewal_Part_Number__c) : htmlBody.replace('{!Account.CEMS_Renewal_Part_Number__c}', '');            
                }
                msg.setSubject(subject);
                //msg.setPlainTextBody(plainBody);        
                msg.setHtmlBody(htmlBody);
            List<Messaging.SendEmailResult> results =  Messaging.sendEmail(
                    new List<Messaging.SingleEmailMessage> {msg});
                if (results[0].success) { 
                    returnValues.result='Success';            
                    returns.add(returnValues);
                    return returns;
                } else {
                    returnValues.result='Failed';            
                    returns.add(returnValues);
                    return returns;
                }
        	}
            else
            {
                returnValues.result='Failed'; 
                returnValues.errorMsg = 'No CEMS Primary contact';
                returns.add(returnValues);
                return returns;
            }
        }
        catch (Exception e) {
            System.debug('The following exception has occurred in ContractExpirationReminder class : ' + e.getMessage());
    		returnValues.errorMsg = e.getMessage();
            returnValues.result='Exception';            
        	returns.add(returnValues);
            return returns;
		}
    }
    
    public class flowOutputs{
    	@InvocableVariable public String result;  
        @InvocableVariable public String errorMsg;  
  	}
    public class flowInputs {                  
        @InvocableVariable
        public id currentRecordId;
        
        @InvocableVariable
        public string myCustomString;
    }
}