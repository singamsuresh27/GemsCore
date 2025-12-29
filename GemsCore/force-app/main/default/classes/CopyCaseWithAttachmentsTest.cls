@isTest
private class CopyCaseWithAttachmentsTest {

    static testMethod void testCopyCaseWithAttachments() {
        // Create a test Case
        Case testCase = new Case(
            Subject = 'Test Case',
            Description = 'Test Description',
            Origin = 'Web',
            Status = 'New',
            Priority = 'High',
            Type = 'Inquiry'
        );
        insert testCase;
        
        Attachment testAttachment = new Attachment(
            ParentId = testCase.Id, // Associate the Attachment with the Case
            Name = 'Test Attachment',
            Body = Blob.valueOf('Test Body'),
            ContentType = 'text/plain'
        );
        insert testAttachment;

        
        EmailMessage testEmailMessage = new EmailMessage(
            Subject = 'Test Email',
            TextBody = 'Test Body',
            Incoming = true,
            ParentId = testCase.Id
        );
        insert testEmailMessage;

        Attachment testAttachmentEmail = new Attachment(
            ParentId = testEmailMessage.Id, // Associate the Attachment with the email message
            Name = 'Test Attachment',
            Body = Blob.valueOf('Test Body'),
            ContentType = 'text/plain'
        );
        insert testAttachmentEmail;
        List<CopyCaseWithAttachments.EmailAndCaseIds> testEmailAndCaseIdsList = new List<CopyCaseWithAttachments.EmailAndCaseIds>();
        CopyCaseWithAttachments.EmailAndCaseIds testEmailAndCaseIds = new CopyCaseWithAttachments.EmailAndCaseIds();
        testEmailAndCaseIds.emailMessageId = testEmailMessage.Id;
        testEmailAndCaseIds.caseId = testCase.Id;
        testEmailAndCaseIdsList.add(testEmailAndCaseIds);

        Test.startTest();
        system.debug('Before start test');
        CopyCaseWithAttachments.copyCaseWithAttachments(testEmailAndCaseIdsList);
        Test.stopTest();
        
        List<Case> newCases = [SELECT Id, Subject, Description FROM Case];
        System.assertEquals(2, newCases.size());

        List<EmailMessage> newEmailMessages = [SELECT Id, Subject, TextBody FROM EmailMessage];
        System.assertEquals(2, newEmailMessages.size());
    }
}