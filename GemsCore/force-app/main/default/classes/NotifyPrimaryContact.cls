public class NotifyPrimaryContact {

        @InvocableMethod
    public static List<string> SendEmail(List<FlowInputs> request){
        //List<Id> ContactIds,string accountType){
        String sMessage='';
        try{   
             //List<FlowOutputs> results = new List<FlowOutputs>();
            string thisContact = request[0].ContactId;
            string accType = request[0].accountType;
			EmailTemplate emailTemplate;
            OrgWideEmailAddress sender = [select Id,Address from OrgWideEmailAddress where DisplayName = 'orders@setra.com'];
            system.debug(' Type : '+ accType);
            Contact contactItem =[select id,email from Contact where contact.id =: thisContact limit 1];
            if(accType=='CCA')
            {
            	emailTemplate = [select Body, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where DeveloperName='Notify_Customer_CC' limit 1];
            }
            else
            {
            	emailTemplate = [select Body, HtmlValue, Subject, DeveloperName, BrandTemplateId 
            from EmailTemplate where DeveloperName='Notify_Customer_Credit_Approved' limit 1]; 
            }
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            semail.setOrgWideEmailAddressId(sender.id); 
            semail.setTemplateId(emailTemplate.Id); 
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
        public string ContactId;
        
        @InvocableVariable
        public string accountType;
    }
}