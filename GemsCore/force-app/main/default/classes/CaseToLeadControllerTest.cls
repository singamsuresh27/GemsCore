@isTest
private class CaseToLeadControllerTest {
    
    @isTest
    static void testGetCaseRecord() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Case testCase = new Case(
            Subject = 'Test Subject',
            SuppliedEmail = 'test@example.com',
            Description = 'Test Description',
            Business_Region__c = 'GEMS_NA',
            Priority = 'High',
            Origin = 'Lead Conversion',
            Type = 'Forward Lead',
            Status = 'New',
            AccountId = acc.Id,
            Country__c = 'India'
        );
        insert testCase;
        
        Test.startTest();
        Case result = CaseToLeadController.getCaseRecord(testCase.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(testCase.Id, result.Id);
        System.assertEquals('India', result.Country__c);
    }
    
    @isTest
    static void testGetLeadPicklistValues() {
        Test.startTest();
        Map<String, List<String>> picklistValues = CaseToLeadController.getLeadPicklistValues();
        Test.stopTest();
        
        System.assert(picklistValues.containsKey('LeadSource'));
        System.assert(picklistValues.containsKey('Status'));
        System.assert(picklistValues.containsKey('Business_Region__c'));
        System.assert(picklistValues.containsKey('Country__c'));
    }
    
    @isTest
    static void testCreateLeadFromCase() {
        // Create Case record
        Id caseRecTypeId = [
            SELECT Id FROM RecordType 
            WHERE SObjectType = 'Case' AND Name = 'Customer Service' 
            LIMIT 1
        ].Id;
        
        Case testCase = new Case(
            Subject = 'Test Subject',
            SuppliedEmail = 'lead@example.com',
            Description = 'Lead from Case',
            Status = 'In Progress',
            RecordTypeId = caseRecTypeId
        );
        insert testCase;
        
        // Create EmailMessage for the Case
        EmailMessage em = new EmailMessage(
            Subject = 'Case Email',
            FromAddress = 'from@test.com',
            ToAddress = 'to@test.com',
            ParentId = testCase.Id,
            Status = '3',
            TextBody = 'This is a test email body'
        );
        insert em;
        
        // Create a File (ContentVersion) and link it to Case
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Sample PDF body'),
            IsMajorVersion = true
        );
        insert cv;
        
        Id contentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id
        ].ContentDocumentId;
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = testCase.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
        
        // Get Lead RecordType
        Id leadRecTypeId = [
            SELECT Id FROM RecordType 
            WHERE SObjectType = 'Lead' AND Name = 'GEMS-SETRA' 
            LIMIT 1
        ].Id;
        
        // Execute controller method
        Test.startTest();
        caseToLeadController.cover();
        Lead newLead = CaseToLeadController.createLeadFromCase(
            testCase.Id,
            'John Doe',
            'john.doe@example.com',
            'OpenAI Inc.',
            'Raw Lead',
            'Internal Case',
            'GEMS_NA',
            'GEMS_NA',
            'Application Detail Text',
            'India'
        );
        Test.stopTest();
        
        // Verify Lead was created
        Lead asserts = [
            SELECT Id, FirstName, LastName, Country__c 
            FROM Lead 
            WHERE Id = :newLead.Id
        ];
        System.assertNotEquals(null, asserts);
        System.assertEquals('John', asserts.FirstName);
        System.assertEquals('Doe', asserts.LastName);
        System.assertEquals('India', asserts.Country__c);
        
        // Verify Case closed
        Case updatedCase = [SELECT Status FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Closed', updatedCase.Status);
        
        // Verify File was copied to Lead
        List<ContentDocumentLink> leadFiles = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :newLead.Id
        ];
        System.assertEquals(1, leadFiles.size(), 'File should be linked to Lead');
        
        // Verify Task created for EmailMessage
        List<Task> leadTasks = [
            SELECT Id, Subject, WhoId 
            FROM Task 
            WHERE WhoId = :newLead.Id
        ];
        System.assertEquals(1, leadTasks.size(), 'One Task should be created for the EmailMessage');
    }
}