@isTest
public class TestSetraHubSpotPreview {
     public static testMethod void createNewPreview() {
         User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
        Account act = new Account(name='test');
        insert act;
        
        Contact  con = new Contact(firstname='test',lastname='kumar',email='test1@gmail.com', role__c='Primary', phone='1234567890', fax='1234567890', AccountId = act.id);
        insert con;
         
         Contact  con1 = new Contact(firstname='user2FirstName',lastname='user2LastName',email='user2@gmail.com',role__c='Finance', phone='1234567891', fax='1234567891', AccountId = act.id);
        insert con1;
         
         Contact  con2 = new Contact(firstname='firstName',lastname='lastName',email='test3@gmail.com',role__c='Shipping', phone='1234567892', fax='1234567892', AccountId = act.id);
        insert con2;
         
        SetraHubSpotPreviewController cont = new SetraHubSpotPreviewController(new ApexPages.StandardController(act));
      	Test.startTest();   
     }
}