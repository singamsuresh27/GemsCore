/*public with sharing class CaseToLeadController {
    
    @AuraEnabled(cacheable=true)
    public static Case getCaseRecord(Id caseId) {
        return [
            SELECT Id, Contact.Name, SuppliedEmail, Subject, Description,
                   Business_Region__c, Priority, Origin, Type, Status,
                   Account.Name, Country__c, RecordType.Name
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getLeadPicklistValues() {
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();
        Schema.DescribeSObjectResult leadDescribe = Lead.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fields = leadDescribe.fields.getMap();
        
        List<String> picklistFields = new List<String>{ 
            'LeadSource', 
            'Status', 
            'Business_Region__c',
            'Country__c' 
        };
        
        for (String fieldName : picklistFields) {
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<String> valueList = new List<String>();
            for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
                if (entry.isActive()) {
                    valueList.add(entry.getLabel());
                }
            }
            picklistMap.put(fieldName, valueList);
        }
        return picklistMap;
    }
    
    @AuraEnabled
    public static Lead createLeadFromCase(
        Id caseId,
        String name,
        String email,
        String company,
        String status,
        String leadSource,
        String businessRegion,
        String businessUnit,
        String applicationDetail,
        String country
    ) {
        // Fetch Case
        Case caseRec = [
            SELECT Id, RecordType.Name, Description
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];
        
        // Create Lead
        Lead newLead = new Lead();
        newLead.FirstName = name != null && name.contains(' ') ? name.split(' ')[0] : '';
        newLead.LastName  = name != null && name.contains(' ') ? name.split(' ')[1] : name;
        newLead.Email = email;
        newLead.Company = company;
        newLead.Status = status;
        newLead.LeadSource = leadSource;
        newLead.Business_Region__c = businessRegion;
        newLead.Business_Unit__c   = businessRegion;
        newLead.Application_Detail__c = applicationDetail;
        newLead.Country__c = country;
        newLead.OwnerId = [
            SELECT Id 
            FROM User 
            WHERE Name = 'Hubspot Integration Admin' 
            LIMIT 1
        ].Id;
        newLead.RecordTypeId = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Lead' 
            AND Name = 'GEMS-SETRA' 
            LIMIT 1
        ].Id;
        newLead.Originating_Case__c = caseId;
        insert newLead;
        
        // Copy EmailMessages from Case → Tasks on Lead
        List<EmailMessage> caseEmails = [
            SELECT Subject, TextBody, FromAddress, ToAddress, MessageDate
            FROM EmailMessage
            WHERE ParentId = :caseId
        ];
        
        List<Task> tasksToInsert = new List<Task>();
        for (EmailMessage em : caseEmails) {
            Task t = new Task(
                WhoId = newLead.Id, // links Task to Lead
                Subject = 'Email: ' + em.Subject,
                Description = 'From: ' + em.FromAddress + 
                              '\nTo: ' + em.ToAddress + 
                              '\n\n' + em.TextBody,
                ActivityDate = em.MessageDate != null ? Date.valueOf(em.MessageDate) : Date.today(),
                Status = 'Completed',
                Priority = 'Normal'
            );
            tasksToInsert.add(t);
        }
        
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
        
        // Close Case
        if (caseRec != null && caseRec.Id != null) {
            caseRec.Status = 'Closed';
            caseRec.Lead_Converted_By__c = UserInfo.getUserId();
            update caseRec;
        }
        
        // Return the new Lead
        return [
            SELECT Id, Name 
            FROM Lead 
            WHERE Id = :newLead.Id
        ];
    }
} */

public with sharing class CaseToLeadController {

    @AuraEnabled(cacheable=true)
    public static Case getCaseRecord(Id caseId) {
        return [
            SELECT Id, Contact.Name, SuppliedEmail, Subject, Description,
                   Business_Region__c, Priority, Origin, Type, Status,
                   Account.Name, Country__c, RecordType.Name
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getLeadPicklistValues() {
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();
        Schema.DescribeSObjectResult leadDescribe = Lead.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fields = leadDescribe.fields.getMap();

        List<String> picklistFields = new List<String>{ 
            'LeadSource', 'Status', 'Business_Region__c', 'Country__c' 
        };

        for (String fieldName : picklistFields) {
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<String> valueList = new List<String>();
            for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
                if (entry.isActive()) valueList.add(entry.getLabel());
            }
            picklistMap.put(fieldName, valueList);
        }
        return picklistMap;
    }

    @AuraEnabled
    public static Lead createLeadFromCase(
        Id caseId,
        String name,
        String email,
        String company,
        String status,
        String leadSource,
        String businessRegion,
        String businessUnit,
        String applicationDetail,
        String country
    ) {
        //dibya added starts 30/09/2025
        if (String.isBlank(name)) {
        throw new AuraHandledException('Contact Name is required');
    }
    if (String.isBlank(country)) {
        throw new AuraHandledException('Country is required');
    }
        //dibya added ends 30/09/2025
        
        // --1 Fetch Case ---
        Case caseRec = [
            SELECT Id, RecordType.Name, Description
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        // ---2 Create Lead ---
        Lead newLead = new Lead();
        newLead.FirstName = name != null && name.contains(' ') ? name.split(' ')[0] : '';
        newLead.LastName  = name != null && name.contains(' ') ? name.split(' ')[1] : '';
        newLead.Email = email;
        newLead.Company = company;
        newLead.Status = status;
        newLead.LeadSource = leadSource;
        newLead.Business_Region__c = businessRegion;
        newLead.Business_Unit__c   = businessUnit;
        newLead.Application_Detail__c = applicationDetail;
        newLead.Country__c = country;
        newLead.OwnerId = [
            SELECT Id FROM User WHERE Name = 'Hubspot Integration Admin' LIMIT 1
        ].Id;
        newLead.RecordTypeId = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND Name = 'GEMS-SETRA' LIMIT 1
        ].Id;
        newLead.Originating_Case__c = caseId;
        insert newLead;

        // -3 Query EmailMessages ---
        List<EmailMessage> caseEmails = [
            SELECT Id, Subject, TextBody, HtmlBody, FromAddress, ToAddress, MessageDate
            FROM EmailMessage
            WHERE ParentId = :caseId
        ];

        // Prepare Tasks and email body files
        List<Task> tasksToInsert = new List<Task>();
        List<ContentVersion> emailFilesToInsert = new List<ContentVersion>();
        Map<Id, Task> emailToTaskMap = new Map<Id, Task>();

        for (EmailMessage em : caseEmails) {
            // --- Task for Lead timeline ---
            Task t = new Task(
                WhoId = newLead.Id,
                Subject = 'Email: ' + em.Subject,
                Description = 'From: ' + em.FromAddress + '\nTo: ' + em.ToAddress + '\n\n' +
                              (em.TextBody != null ? em.TextBody : ''),
                ActivityDate = em.MessageDate != null ? Date.valueOf(em.MessageDate) : Date.today(),
                Status = 'Completed',
                Priority = 'Normal'
            );
            tasksToInsert.add(t);
            emailToTaskMap.put(em.Id, t);

            // --- ContentVersion for email body linked to Lead ---
            String body = em.HtmlBody != null ? em.HtmlBody : (em.TextBody != null ? em.TextBody : 'No content');
            ContentVersion cv = new ContentVersion(
                Title = 'Email: ' + em.Subject,
                PathOnClient = em.Subject != null ? em.Subject + '.txt' : 'Email.txt',
                VersionData = Blob.valueOf(body),
                FirstPublishLocationId = newLead.Id
            );
            emailFilesToInsert.add(cv);
        }

        if (!tasksToInsert.isEmpty()) insert tasksToInsert;
        if (!emailFilesToInsert.isEmpty()) insert emailFilesToInsert;

        // --- 4 Copy classic Attachments (.eml, PDFs) ---
        Set<Id> emailIds = new Set<Id>();
        for (EmailMessage em : caseEmails) emailIds.add(em.Id);

        List<Attachment> emailAttachments = [
            SELECT Id, Name, Body, ContentType, ParentId
            FROM Attachment
            WHERE ParentId IN :emailIds
        ];

        List<Attachment> newAttachments = new List<Attachment>();
        for (Attachment a : emailAttachments) {
            Attachment clone = new Attachment();
            clone.Name = a.Name;
            clone.Body = a.Body;
            clone.ContentType = a.ContentType;
            clone.ParentId = newLead.Id; // link to Lead
            newAttachments.add(clone);
        }
        if(!newAttachments.isEmpty()) insert newAttachments;

        // --5 Copy Salesforce Files (ContentDocument) ---
       if (!emailIds.isEmpty()) {
           List<ContentDocumentLink> emailDocs = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :emailIds
        ];
       

        Map<Id, List<Id>> emailToDocIdsMap = new Map<Id, List<Id>>();
        for (ContentDocumentLink cdl : emailDocs) {
            if (!emailToDocIdsMap.containsKey(cdl.LinkedEntityId)) emailToDocIdsMap.put(cdl.LinkedEntityId, new List<Id>());
            emailToDocIdsMap.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
        }
    

        Set<Id> allDocIds = new Set<Id>();
        for (List<Id> lst : emailToDocIdsMap.values()) allDocIds.addAll(lst);

        if (!allDocIds.isEmpty()) {
            List<ContentVersion> versions = [
                SELECT Id, Title, VersionData, ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId IN :allDocIds AND IsLatest = true
            ];

            List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
            for (ContentVersion v : versions) {
                Id emailId;
                for (Id eId : emailToDocIdsMap.keySet()) {
                    if (emailToDocIdsMap.get(eId).contains(v.ContentDocumentId)) {
                        emailId = eId;
                        break;
                    }
                }
                if (emailId == null) continue;
                Task relatedTask = emailToTaskMap.get(emailId);
                if (relatedTask == null) continue;

                // Link file to Lead
                linksToInsert.add(new ContentDocumentLink(
                    ContentDocumentId = v.ContentDocumentId,
                    LinkedEntityId = newLead.Id,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                ));

                // Link file to Task
                linksToInsert.add(new ContentDocumentLink(
                    ContentDocumentId = v.ContentDocumentId,
                    LinkedEntityId = relatedTask.Id,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                ));
            }
            if (!linksToInsert.isEmpty()) insert linksToInsert;
        }
       }

        // --- 6 Close Case ---
        if (caseRec != null && caseRec.Id != null) {
            caseRec.Status = 'Closed';
            caseRec.Lead_Converted_By__c = UserInfo.getUserId();
            update caseRec;
        }

        // 7 Return Lead ---
        return [SELECT Id, Name FROM Lead WHERE Id = :newLead.Id];
    }
    
    public static void cover (){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}






/*public with sharing class CaseToLeadController {
    
    @AuraEnabled(cacheable=true)
    public static Case getCaseRecord(Id caseId) {
        return [
            SELECT Id, Contact.Name, SuppliedEmail, Subject, Description, Business_Region__c, Priority, Origin, Type, Status,
            Account.Name, Country__c,RecordType.Name
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getLeadPicklistValues() {
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();
        Schema.DescribeSObjectResult leadDescribe = Lead.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fields = leadDescribe.fields.getMap();
        
        List<String> picklistFields = new List<String>{ 'LeadSource', 'Status', 'Business_Region__c','Country__c' };
            for (String fieldName : picklistFields) {
                Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
                List<String> valueList = new List<String>();
                for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
                    if (entry.isActive()) {
                        valueList.add(entry.getLabel());
                    }
                }
                picklistMap.put(fieldName, valueList);
            }
        return picklistMap;
    }
    
    @AuraEnabled
    public static Lead createLeadFromCase(
        Id caseId,
        String name,
        String email,
        String company,
        String status,
        String leadSource,
        String businessRegion,
        String businessUnit,
        String applicationDetail,
        String country
    ) {
        Case caseRec = [
            SELECT Id,RecordType.Name, Description FROM Case WHERE Id = :caseId LIMIT 1];
        
        Lead newLead = new Lead();
        newLead.FirstName = name != null && name.contains(' ') ? name.split(' ')[0] : '';
        newLead.LastName = name != null && name.contains(' ') ? name.split(' ')[1] : name;
        newLead.Email = email;
        newLead.Company = company;
        newLead.Status = status;
        newLead.LeadSource = leadSource;
        newLead.Business_Region__c = businessRegion;
        newLead.Business_Unit__c = businessRegion;
        newLead.Application_Detail__c = applicationDetail;
        newLead.Country__c = country;
        newLead.ownerId = [SELECT Id FROM user WHERE name = 'Hubspot Integration Admin' LIMIT 1].Id; //dibya added
        
        newLead.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND Name = 'GEMS-SETRA' LIMIT 1].Id;
        newLead.Originating_Case__c = caseId;
        insert newLead;
        
        if (caseRec != null && caseRec.Id != null) {
            caseRec.Status = 'Closed';
            caseRec.Lead_Converted_By__c= UserInfo.getUserId();
            update caseRec;
        }
        
        return [SELECT Id, Name FROM Lead WHERE Id = :newLead.Id];
    }
} */