@IsTest
public class TestSendDocuSignEnvelope {
    @IsTest
   public static void testSendEnvelope() {

        // Mock the DocuSign eSignature API
		dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
		
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        System.runAs(dfsle.UserMock.createDocuSignSender()) {
    
    	// Create test data
        Account myAccount = new Account(Name = 'Test Account');
        insert myAccount;
                 
        Contact myContact = new Contact(
            AccountId = myAccount.Id,
            FirstName = 'Test',
            LastName = 'Contact',
            Phone = '555-1234-5678',
            Email = 'test.contact@example.com');
        insert myContact;
        
        SendDocuSignEnvelope.FlowInputs flwInput = new SendDocuSignEnvelope.FlowInputs();
        flwInput.record = myContact;
        flwInput.formName='Contact';
        
        SendDocuSignEnvelope.sendEnvelope(
            new List<SendDocuSignEnvelope.FlowInputs>{flwInput}
        );          
        }
	}
}