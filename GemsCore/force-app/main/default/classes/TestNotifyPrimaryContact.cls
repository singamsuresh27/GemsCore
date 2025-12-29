@isTest
public class TestNotifyPrimaryContact {
     public static testMethod void createNewPreview() {
    	String contactId;
        User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
        Account act = new Account(name='test');
        insert act;
        
        Contact  con = new Contact(firstname='test',lastname='kumar',email='test1@gmail.com', role__c='Primary', phone='1234567890', fax='1234567890', AccountId = act.id);
        insert con;
         
        Contact  con1 = new Contact(firstname='test1',lastname='kumar1',email='test2@gmail.com',role__c='Finance', phone='1334567890', fax='1234567890', AccountId = act.id);
        insert con1;
         
        Contact  con2 = new Contact(firstname='test2',lastname='kumar2',email='test3@gmail.com',role__c='Shipping', phone='1294567890', fax='1234567890', AccountId = act.id);
        insert con2;
              
      	contactId = con.id;
         NotifyPrimaryContact.FlowInputs firstInput = new NotifyPrimaryContact.FlowInputs();
         firstInput.ContactId=contactId;
         firstInput.accountType='CCA';
         NotifyPrimaryContact.SendEmail(
            new List<NotifyPrimaryContact.FlowInputs>{firstInput}
        );
        //NotifyPrimaryContact.SendEmail(contactId,'CCN');
       	Test.startTest();   
     }
}