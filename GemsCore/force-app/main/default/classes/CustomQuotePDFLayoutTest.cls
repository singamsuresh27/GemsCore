@isTest
public class CustomQuotePDFLayoutTest {
public static testMethod void createNewPreview() {
        User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
        Account act = new Account(name='test');
        insert act;
        
        Contact  con = new Contact(firstname='test',lastname='kumar',email='test@gmail.com', phone='1234567890', fax='1234567890', AccountId = act.id);
        insert con;
         
         // Insert Product
        Product2 p = new Product2();
        p.Name = ' Test Product ';
        p.Description='Test Product Entry 1';
        p.productCode = 'ABC';
        p.isActive = true;
        insert p;
         
        Quotation_Setra__c quoteObj1 = new Quotation_Setra__c(Account__c=act.id,
                            Name ='TestQuote',
                            Contact__c = con.id,
                            Status__c='Draft',
                            Validity__c='30',
                            Incoterms__c='EXW - Ex Works',
                            Payment__c='To be agreed');
        insert quoteObj1;
         
         // Insert Quote Item
         Quotation_Setra_LineItem__c quoteItem = new Quotation_Setra_LineItem__c(Quote__c=quoteObj1.Id,Product__c= p.Id,SalesPrice__c=100);
        insert quoteItem;
         
      CustomQuotePDFLayoutControllerEMEA cont = new CustomQuotePDFLayoutControllerEMEA(new ApexPages.StandardController(quoteObj1));
      Test.startTest();    
      PageReference testPage = Page.CustomQuotePDFLayoutEMEA;
      Test.setCurrentPage(testPage);         
      Test.stopTest();
   }
}