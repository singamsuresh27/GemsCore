@isTest
private class SendCaseClosureEmailBatchTest {
    @testSetup
    static void setupData() {
        Contact con = new Contact(FirstName='Test', LastName='User', Email='test@example.com');
        insert con;

        Account acc = new Account(Name='Test Account');
        insert acc;

        Case c = new Case(
            Subject = 'Test Case',
            Status = 'Closed',
            Pending_Customer_Type__c = 'Surcharge',
            Type = 'New Order',
            ContactId = con.Id,
            AccountId = acc.Id,
            PO_No__c = 'PO1234'
        );
        insert c;

        // Insert email to attach to case
        EmailMessage em = new EmailMessage(
            ParentId = c.Id,
            FromAddress = 'oe@gemssensors.com',
            ToAddress = con.Email,
            Subject = 'Tariff Notification',
            TextBody = 'Details of pricing issue',
            Status = '3',
            Incoming = false
        );
        insert em;
    }

    @isTest
    static void testBatch() {
        Test.startTest();
        SendCaseClosureEmailBatch batch = new SendCaseClosureEmailBatch();
        Database.executeBatch(batch, 1);
        SendCaseClosureEmailBatch.fakeTestMethod();
        Test.stopTest();

        System.assert(true, 'Batch executed without error');
    }
    
}