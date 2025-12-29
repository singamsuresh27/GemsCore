@isTest
private class LeadToCaseControllerTest {

    static testMethod void testGetLeadRecord() {
        Lead testLead = new Lead(
            FirstName = 'Jane',
            LastName = 'Doe',
            Company = 'Test Company',
            Email = 'jane.doe@example.com',
            Status = 'Raw Lead',
            Business_Region__c = 'GEMS_NA',
            Country__c = 'India',
            Application_Detail__c = '<p>Test Application</p>',
            LeadSource = 'Internal Case'
        );
        insert testLead;

        Test.startTest();
        Lead result = LeadToCaseController.getLeadRecord(testLead.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals('India', result.Country__c);
    }

    static testMethod void testGetCasePicklistValues() {
        Test.startTest();
        Map<String, List<String>> picklistMap = LeadToCaseController.getCasePicklistValues();
        Test.stopTest();

        System.assert(picklistMap.containsKey('Status'));
        System.assert(picklistMap.containsKey('Type'));
        System.assert(picklistMap.containsKey('Origin'));
        System.assert(picklistMap.containsKey('Priority'));
    }

    static testMethod void testCreateCaseFromLead() {
        // Setup Contact and Account
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        Contact testContact = new Contact(
            FirstName = 'Jane',
            LastName = 'Doe',
            Email = 'jane.doe@example.com',
            AccountId = testAcc.Id
        );
        insert testContact;

        Lead testLead = new Lead(
            FirstName = 'Jane',
            LastName = 'Doe', 
            Company = 'Test Company',
            Email = 'jane.doe@example.com',
            Status = 'Raw Lead',
            Business_Region__c = 'GEMS_NA',
            Country__c = 'India',
            Application_Detail__c = '<p>Lead Description</p>',
            LeadSource = 'Internal Case'
        );
        insert testLead;

        Id caseRecTypeId = [
            SELECT Id FROM RecordType 
            WHERE SObjectType = 'Case' AND Name = 'Customer Service' 
            LIMIT 1
        ].Id;

        Test.startTest();
        LeadToCaseController.cover();
        Case newCase = LeadToCaseController.createCaseFromLead(
            testLead.Id,
            'Customer Service',
            'New',
            testContact.FirstName + ' ' + testContact.LastName,
            testContact.Email,
            testAcc.Name,
            'GEMS_NA',
            'Test Case Subject',
            'Some Description',
            'Phone',
            'Medium',
            'Issue',
            'India'
        );
        Test.stopTest();
        
         Case newCaseNew = [select id,Country__c from case where id =:newCase.id];

        System.assertNotEquals(null, newCaseNew);
        System.assert(newCaseNew.Id != null);
        System.assertEquals('India', newCaseNew.Country__c);

        Lead updatedLead = [SELECT Case_Comments__c FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals('A Case has been created from this Lead.', updatedLead.Case_Comments__c);
    }
}