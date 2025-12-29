/**
* @File Name        :   CaseAutoResponse
* @Description      :   Method to send auto response email
* @TestClass        :   CaseAutoResponseTest
* -------------------------------------------------------------------------------------
**/

public class CaseAutoResponse {
    public static void sendAutoResponseEmail(List<Id> caseIds)
    {
        EmailTemplate emailTemplate;
        string sMessage;
        List<string> autoResponseEmailList= new List<string>(); 
        try
        {
            OrgWideEmailAddress sender = [select Id,Address from OrgWideEmailAddress where DisplayName = 'Gems Sensors'];        
            List<Case> caseList =[select id,contactid from Case where id in :caseIds];
            emailTemplate = [select Body, HtmlValue, Subject, DeveloperName, BrandTemplateId from EmailTemplate where DeveloperName='Case_Assigned' limit 1];
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();        
            Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();
            
            for (Case newCase: caseList) 
            {
                singleEmailMsg = new Messaging.SingleEmailMessage();
                singleEmailMsg.setOrgWideEmailAddressId(sender.id); 
                singleEmailMsg.setTemplateId(emailTemplate.Id); 
                singleEmailMsg.setSaveAsActivity(true);   
                singleEmailMsg.setTargetObjectId(newCase.contactid);
                singleEmailMsg.setWhatId(newCase.id);
                emailList.add(singleEmailMsg);
            }
            if(emailList.size() >0)
            {
                Messaging.sendEmail(emailList);
            }
        }
        catch(exception ex)
        {
            system.debug(' CaseAutoResponse Exception : '+ ex.getMessage());
        }
    }
}