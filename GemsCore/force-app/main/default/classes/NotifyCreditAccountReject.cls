public class NotifyCreditAccountReject {

        @InvocableMethod
    public static List<string> SendEmail(List<FlowInputs> request){
        //List<Id> ContactIds,string accountType){
        String sMessage='';
        try{   
             //List<FlowOutputs> results = new List<FlowOutputs>();
            string thisContact = request[0].contactId;
            string thisAccount = request[0].accountId;
			EmailTemplate emailTemplate;
            OrgWideEmailAddress sender = [select Id,Address from OrgWideEmailAddress where DisplayName = 'orders@setra.com'];
            Contact contactItem =[select id,email,accountid from Contact where contact.id =: thisContact limit 1];
            Account accountItem =[select id,ownerid from Account where account.id =: thisAccount limit 1];
            
            	emailTemplate = [select Body, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where DeveloperName='Notify_Customer_Credit_Rejected' limit 1];
            
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            semail.setOrgWideEmailAddressId(sender.id); 
            semail.setTemplateId(emailTemplate.Id); 
            
            List<String> lstToAddresses = new List<String>();            
            lstToAddresses.add(contactItem.Email);
            lstToAddresses.add(accountItem.ownerid);
            system.debug(' contact '+contactItem.Email);
            system.debug(' account '+accountItem.ownerid);
            semail.setToAddresses(lstToAddresses); 
            
        	semail.setSaveAsActivity(false);   
            semail.setTargetObjectId(contactItem.id);
            List<String> returnList = new List<String>();
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
            sMessage='Success';
            system.debug(sMessage);
            returnList.add(sMessage);
            return returnList;
        }
        catch(Exception ex){
            sMessage=ex.getMessage()+'\n'+ex.getLineNumber()+'\n'+ex.getCause();
            system.debug(' ERROR : '+sMessage);
            return null;
        }
    }
    //input details that comes to apex from process builder
    public class FlowInputs{
    
        @InvocableVariable
        public string contactId;
        
        @InvocableVariable
        public string accountId;
    }
}