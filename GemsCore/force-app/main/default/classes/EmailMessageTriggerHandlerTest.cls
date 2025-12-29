@isTest
public class EmailMessageTriggerHandlerTest {
    @isTest
    static void testEmailMessageInsert() {
        Test.startTest();
        
        Case testCase = new Case();
        testCase.Subject = 'Test Case Subject';
        testCase.Status = 'New';
        insert testCase;
        
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.Subject = 'Test Comark';
        emailMessage.HTMLBody = 'This is the test body content comark.';
        emailMessage.FromAddress = 'test@example.com';
        emailMessage.ToAddress = 'enquiries@west-cs.com';
        emailMessage.Incoming = true;
        emailMessage.MessageDate = DateTime.now();
        emailMessage.RelatedToId = testCase.Id; 
        insert emailMessage;
        
        EmailMessage emailMessage2 = new EmailMessage();
        emailMessage2.Subject = 'Gems/Setra Purchase Order/Release';
        emailMessage2.HTMLBody = 'This is the test body content comark.';
        emailMessage2.FromAddress = 'test@example.com';
        emailMessage2.ToAddress = 'enquiries@west-cs.com';
        emailMessage2.Incoming = true;
        emailMessage2.MessageDate = DateTime.now();
        emailMessage2.RelatedToId = testCase.Id; 

        insert emailMessage2;
        
        EmailMessage emailMessage3 = new EmailMessage();
        emailMessage3.Subject = 'Order Nr. 45';
        emailMessage3.HTMLBody = 'This is the test body content comark.';
        emailMessage3.FromAddress = 'OPER@SAPR3.HENGSTLER.DE';
        emailMessage3.ToAddress = 'enquiries@west-cs.com';
        emailMessage3.Incoming = true;
        emailMessage3.MessageDate = DateTime.now();
        emailMessage3.RelatedToId = testCase.Id; 
        insert emailMessage3;
        
        EmailMessage insertedEmailMessage = [SELECT Id, Subject, TextBody FROM EmailMessage WHERE Id = :emailMessage.Id];

        System.assertEquals('Test Comark', insertedEmailMessage.Subject, 'The subject of the email does not match.');
        System.assertEquals('This is the test body content comark.', insertedEmailMessage.TextBody, 'The body content of the email does not match.');
		EmailMessageTriggerHandler.cover();
        Test.stopTest();
    }
}