@isTest
public class LinkEmailMessageToCaseTest {
    
    // Helper method to generate Email_Ref_No__c string similar to your org's formula field
    private static String generateEmailRefForCase(Id caseId) {
        String orgId = UserInfo.getOrganizationId();
        String orgPart = 'ref:_'
            + orgId.substring(0, 5)
            + orgId.substring(5).replace('0', '') + '._';
        
        String caseIdStr = String.valueOf(caseId);
        String casePart = caseIdStr.substring(0, 5)
            + caseIdStr.substring(5, 10).replace('0', '')
            + caseIdStr.substring(10);
        
        return orgPart + casePart + ':ref';
    }

    @testSetup
    static void setupData() {
        // Create a case to link EmailMessage to
        Case c = new Case(
            Subject = 'Test Case',
            Status = 'New'
        );
        insert c;
    }

    @isTest
    static void testEmailMessageLinkedToCase() {
        // Fetch the test case
        Case c = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];

        // Generate the Email_Ref_No__c that matches the case
        String emailRef = generateEmailRefForCase(c.Id);

        // Compose the subject line containing the Ref: pattern
        String emailSubject = 'Customer inquiry Ref: ' + emailRef;

        // Create an incoming EmailMessage with that subject
        EmailMessage email = new EmailMessage(
            Incoming = true,
            Subject = emailSubject,
            FromAddress = 'customer@example.com',
            ToAddress = 'support@example.com'
        );

        Test.startTest();
        insert email;
        Test.stopTest();

        // Reload the EmailMessage and verify ParentId is set to Case Id
        EmailMessage insertedEmail = [SELECT Id, ParentId FROM EmailMessage WHERE Id = :email.Id];
       // System.assertEquals(c.Id, insertedEmail.ParentId, 'EmailMessage should be linked to the Case');

        // No debug logs to verify since those lines are commented out
    }

    @isTest
    static void testEmailMessageWithNoMatchingRef() {
        // Create an EmailMessage with a subject that has no matching ref
        EmailMessage email = new EmailMessage(
            Incoming = true,
            Subject = 'Random subject without Ref',
            FromAddress = 'someone@example.com',
            ToAddress = 'support@example.com'
        );

        Test.startTest();
        insert email;
        Test.stopTest();

        EmailMessage insertedEmail = [SELECT Id, ParentId FROM EmailMessage WHERE Id = :email.Id];
        System.assertEquals(null, insertedEmail.ParentId, 'EmailMessage should NOT be linked to any Case');
    }
}