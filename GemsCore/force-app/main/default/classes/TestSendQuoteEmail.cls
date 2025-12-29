@isTest
public class TestSendQuoteEmail {
 
    static testMethod void sendQuoteEmail() {
        
        // Create the heirarchy of objects
        // starting with Account
        test.starttest();
        ContentVersion cv=new Contentversion();
        Account act = new Account(
            Name = 'Test Account', BillingCity = 'Hartland', BillingState = 'Wisconsin', BillingCountry = 'United States', 
            BillingPostalCode = '55009', BillingStreet = '1234 First St.');
        insert act;
        
        // Then the contact
        Contact con = new Contact(
            FirstName = 'Unit', LastName = 'Test', Email = 'noN@non.com', AccountId = act.Id);
        insert con;
       
        // Insert Quote    
        Quotation_Setra__c quote = new Quotation_Setra__c(Account__c=act.id,
                                Name ='TestQuote',
                                Contact__c = con.id,
                                Status__c='Draft',
                                Validity__c='30');    
        insert quote;

        PageReference pageRef = Page.SendQuoteEmail;
        
        // Create the controller
        SendQuoteEmailController controller = new SendQuoteEmailController(new ApexPages.StandardController(quote));
          
        // call the template
        pageRef = controller.populateTemplate();
        
        Attachment attachment = new Attachment();
        attachment.ParentId   = quote.Id;
        Blob bodyBlob  = Blob.valueOf('Unit Test Attachment Body');
        attachment.body       = bodyBlob;
        attachment.Name       = 'attachHarry';
        Insert attachment;
        
        Messaging.EmailFileAttachment emailAttachment;
           if (attachment.Body != null) {
                emailAttachment = new Messaging.EmailFileAttachment();
                emailAttachment.setBody(attachment.Body);
                emailAttachment.setFileName(attachment.Name);
            }
        
      //  Blob pdf = controller.savePDF();
        // send the email
        pageRef = controller.sendEmail();
        
        // cancel it
        pageRef = controller.cancel();
        test.stoptest();

    }        
}