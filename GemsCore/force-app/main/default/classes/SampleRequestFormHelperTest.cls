@isTest
public class SampleRequestFormHelperTest {

    @testSetup
    static void setupTestData() {
        Sample_Request_Form__c srf = new Sample_Request_Form__c(
            Status__c = 'New Sample Request',
            Part_Number__c = '123',
            Date_Required__c = 	Date.Today(),
            Shipping_Name__c = 'test',
            Business_Unit__c = 'Gems_NA',
            Status_Change_Timestamp__c = Datetime.now().addDays(-1) 
        );
        insert srf;
    }

    @isTest
    static void testCalculateBusinessHours() {
        
        BusinessHours defaultBH = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
        Sample_Request_Form__c srf = [SELECT Id, Status_Change_Timestamp__c, CreatedDate 
                                      FROM Sample_Request_Form__c LIMIT 1];

       	srf.Status__c = 'Sample Request Approved';
        Test.startTest();
        update srf;
        Test.stopTest();

        srf = [SELECT Id, Status_Change_Timestamp__c, New_Sample_Request__c 
               FROM Sample_Request_Form__c LIMIT 1];

        System.assertNotEquals(null, srf.New_Sample_Request__c, 'Business hours should be calculated.');
        System.assertNotEquals(null, srf.Status_Change_Timestamp__c, 'Status change timestamp should be updated.');
    }
}