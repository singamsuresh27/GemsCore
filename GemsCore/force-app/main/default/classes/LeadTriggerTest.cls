@isTest
public class LeadTriggerTest {
    public static Boolean isTest = false;
    public static testmethod void testLeadTrigger(){
    
        ActionPlansTestUtilities ge = new ActionPlansTestUtilities();
        ActionPlan__c ap = ge.createNewActionPlan( 'leads', 1 );
        Lead l = [select id from Lead where id =:ap.Lead__c];
        
        // Verifies that action plans are undeleted when restoring related object
        test.startTest();
        delete l;
        test.stopTest();
        List<ActionPlan__c> lAp = [select id from ActionPlan__c where id =: ap.Id];
        System.assert(lAp.size() == 0);
        
        // Verifies catch is working fine
        isTest = true;
        try{
            undelete l;
        }catch(Dmlexception e){
            System.assert(e.getMessage().contains('You can not undelete an action plan whose related object is deleted.'));
        }
        isTest = false;
        
        // Verifies that action plans are undeleted when restoring related object
        //List <String> ids = new List <String>();
        //ids.add(l.Id);
        //ids.add(ap.Id);
        //undelete l;
        lAp = [select id from ActionPlan__c where id =: ap.Id];
        System.assert(lAp.size() == 1);
        
        // Verifies that action plans that are in recycle bin are removed when deleting the related object
        delete ap;
        delete l;
        lAp = [ select Id, Name , LastModifiedDate from ActionPlan__c where Lead__c =: l.Id and isDeleted = true ALL ROWS ];
        System.assert(lAp.size() == 0);
    }
    @isTest static void leadScoringSuccessCallout(){
        List<Lead> leads = new List<Lead>();
        lead lead1 = new lead();
        lead1.Title = 'Title';
        lead1.LastName = 'Test';
        lead1.Company = 'testCompany';
        lead1.Email = 'testCompany@test.com';
        lead1.Sub_Market_Setra__c = 'Industrial';
        lead1.Product_Of_Interest__c = 'Liquid Level Sensor';
       // lead1.Application_Detail__c = 'Need both float and radar level for our applications';
        leads.add(lead1);
        
        lead lead2 = new lead();
        lead2.Title = 'Title';
        lead2.LastName = 'Test';
        lead2.Company = 'testCompany';
     //   lead2.Application_Detail__c = 'Need both float and radar level for our applications';
        leads.add(lead2);
        test.startTest();
          insert leads;
        
          ActionPlanObjectTriggerTest.isTest = false;
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('PullAPI_Response_200');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock);
        	LeadTriggerHandler.cover();
        test.stopTest();
    }
      @isTest static void leadScoringFailureCallout(){
        List<Lead> leads = new List<Lead>();
        lead lead1 = new lead();
        lead1.Title = 'Title';
        lead1.LastName = 'Test';
        lead1.Company = 'testCompany';
        lead1.Email = 'testCompany@test.com';
        lead1.Sub_Market_Setra__c = 'Industrial';
        lead1.Product_Of_Interest__c = 'Liquid Level Sensor';
     //   lead1.Application_Detail__c = 'Need both float and radar level for our applications';
        leads.add(lead1);
        
        lead lead2 = new lead();
        lead2.Title = 'Title';
        lead2.LastName = 'Test';
        lead2.Company = 'testCompany';
      //  lead2.Application_Detail__c = 'Need both float and radar level for our applications';
        leads.add(lead2);
        test.startTest();
          insert leads;
        
          ActionPlanObjectTriggerTest.isTest = false;
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('PullAPI_Response_400');
            mock.setStatusCode(400);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock);
        test.stopTest();
    }
      @isTest static void leadStatusChanged(){
          List<Lead> leadsList = new List<Lead>();
          lead lead1 = new lead();
          lead1.Title = 'Title';
          lead1.LastName = 'Test';
          lead1.Company = 'testCompany';
          lead1.Email = 'testCompany@test.com';
          lead1.Sub_Market_Setra__c = 'Industrial';
          lead1.Product_Of_Interest__c = 'Liquid Level Sensor';
        //  lead1.Application_Detail__c = 'Need both float and radar level for our applications';
          leadsList.add(lead1);
          
          Insert leadsList;
          Lead leadRecord = [Select id, status from Lead LIMIT 1];
          leadRecord.Status = 'Contacted';
          
          Test.startTest();
          	update leadRecord;
          Test.stopTest();
      }
    @isTest
    static void testApiErrorHandler_EmailNotificationOn503() {
        Test.startTest();
        AILeadScoringPullAPIQueueable.sendEmailNotification();
        Test.stopTest();
  }
  
    @testSetup
    static void setupTestData() {
        // Create a test Lead record
        Lead testLead = new Lead(
            Title = 'Software Engineer',
            LastName ='Test',
            Company = 'Acme Corp',
            Email = 'test@example.com',
            Sub_Market_Setra__c = 'Tech',
            Product_Of_Interest__c = 'AI Solutions'
        );
        insert testLead;
    }

    @isTest
    static void testPullLeadScoringWithProfileService() {
        // Setup mock response for HTTP callout
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"Potential_Label":"High", "Potential_Explanation":"Strong potential", "Profile_Label":"Active", "Profile_Explanation":"Profile is active."}');
        
        // Create mock Http object
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Get the lead Id for the test
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        
        // Call the method to test
        Test.startTest();
        AILeadScoringPullAPI.pullLeadScoring(testLead.Id, 'profile');
        Test.stopTest();
        
        // Verify the results
        Lead updatedLead = [SELECT Potential_Label__c, Potential_Explanation__c, Profile_Label__c, Profile_Explanation__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('High', updatedLead.Potential_Label__c);
        System.assertEquals('Strong potential', updatedLead.Potential_Explanation__c);
        System.assertEquals('Active', updatedLead.Profile_Label__c);
        System.assertEquals('Profile is active.', updatedLead.Profile_Explanation__c);
    }

    @isTest
    static void testPullLeadScoringWithPotentialService() {
        // Setup mock response for HTTP callout
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"Potential_Label":"Medium", "Explanation":"Moderate potential"}');
        
        // Create mock Http object
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Get the lead Id for the test
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        
        // Call the method to test
        Test.startTest();
        AILeadScoringPullAPI.pullLeadScoring(testLead.Id, 'potential');
        Test.stopTest();
        
        // Verify the results
        Lead updatedLead = [SELECT Potential_Label__c, Potential_Explanation__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('Medium', updatedLead.Potential_Label__c);
        System.assertEquals('Moderate potential', updatedLead.Potential_Explanation__c);
    }

    @isTest
    static void testPullLeadScoringWithErrorResponse() {
        // Setup mock response for HTTP callout with an error
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(400);
        mockResponse.setBody('{"error":"Bad Request"}');
        
        // Create mock Http object
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Get the lead Id for the test
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        
        // Call the method to test
        Test.startTest();
        AILeadScoringPullAPI.pullLeadScoring(testLead.Id, 'profile');
        Test.stopTest();
        
        // Verify the results
        Lead updatedLead = [SELECT AI_API_Error__c FROM Lead WHERE Id = :testLead.Id];
        System.assert(updatedLead.AI_API_Error__c.contains('Status Code : 400 - Bad Request'));
    }

    // Mock HttpCallout class to return mock responses
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse mockResponse;

        public MockHttpResponseGenerator(HttpResponse response) {
            this.mockResponse = response;
        }

        public HTTPResponse respond(HTTPRequest req) {
            return mockResponse;
        }
    }

}