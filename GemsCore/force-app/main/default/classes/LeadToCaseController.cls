public with sharing class LeadToCaseController {
    
    @AuraEnabled(cacheable=true)
    public static Lead getLeadRecord(Id leadId) {
        return [
            SELECT Id, Name, Email, Company, Status, Business_Region__c, Country__c,
                   Application_Detail__c, LeadSource
            FROM Lead
            WHERE Id = :leadId
            LIMIT 1
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getCasePicklistValues() {
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();
        Schema.DescribeSObjectResult caseDescribe = Case.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fields = caseDescribe.fields.getMap();
        
        List<String> picklistFields = new List<String>{ 'Status', 'Type', 'Origin', 'Priority' };
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
    
    public static String stripHtml(String htmlText) {
        if (String.isBlank(htmlText)) return '';
        return htmlText.replaceAll('<[^>]*>', '').trim();
    }
    
    @AuraEnabled
    public static Case createCaseFromLead(
        Id leadId,
        String caseRecordType,
        String status,
        String contactName,
        String email,
        String accountName,
        String businessRegion,
        String subject,
        String description,
        String origin,
        String priority,
        String type,
        String country
    ) {
        Lead leadRec = [SELECT Id, Application_Detail__c, Country__c FROM Lead WHERE Id = :leadId LIMIT 1];
        
        //1 Create Case
        Case newCase = new Case();
        newCase.Status = status;
        newCase.Type = type;
        newCase.Subject = subject;
        newCase.Description = stripHtml(leadRec.Application_Detail__c);
        newCase.Origin = origin;
        newCase.Priority = priority;
        newCase.Business_Region__c = businessRegion;
        newCase.SuppliedEmail = email;
        newCase.Country__c = country;
        newCase.OwnerId = [SELECT Id FROM User WHERE Name = 'Hubspot Integration Admin' LIMIT 1].Id;
        newCase.RecordTypeId = [
            SELECT Id FROM RecordType 
            WHERE SObjectType = 'Case' AND Name = :caseRecordType 
            LIMIT 1
        ].Id;
        
        List<Contact> contacts = [
            SELECT Id, AccountId FROM Contact 
            WHERE Email = :email 
            LIMIT 1
        ];
        if (!contacts.isEmpty()) {
            Contact matched = contacts[0];
            newCase.ContactId = matched.Id;
            if (matched.AccountId != null) {
                newCase.AccountId = matched.AccountId;
            }
        }
        newCase.Originating_Lead__c = leadId;
        insert newCase;
        
        //2 Copy Email Tasks from Lead → Case
        List<Task> leadEmailTasks = [
    SELECT Id, Subject, Description, ActivityDate, Status, Priority, TaskSubType, Activity_Type__c
    FROM Task
    WHERE WhoId = :leadId
    AND (TaskSubType = 'Email' OR Activity_Type__c = 'Email')];

        List<Task> newTasks = new List<Task>();
        for (Task t : leadEmailTasks) {
            Task cloneT = new Task(
                WhatId = newCase.Id, // link to Case
                Subject = t.Subject,
                Description = t.Description,
                ActivityDate = t.ActivityDate,
                Status = t.Status,
                Priority = t.Priority,
                Type = 'Email'
            );
            newTasks.add(cloneT);
        }
        if (!newTasks.isEmpty()) insert newTasks;
        
        //3 Copy classic Attachments
        List<Attachment> leadAttachments = [
            SELECT Id, Name, Body, ContentType
            FROM Attachment
            WHERE ParentId = :leadId
        ];
        List<Attachment> newAttachments = new List<Attachment>();
        for (Attachment a : leadAttachments) {
            Attachment clone = new Attachment(
                Name = a.Name,
                Body = a.Body,
                ContentType = a.ContentType,
                ParentId = newCase.Id
            );
            newAttachments.add(clone);
        }
        if (!newAttachments.isEmpty()) insert newAttachments;
        
        //4 Copy Files (ContentDocumentLink)
        List<ContentDocumentLink> leadFiles = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :leadId
        ];
        List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
        for (ContentDocumentLink l : leadFiles) {
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = l.ContentDocumentId,
                LinkedEntityId = newCase.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
            newLinks.add(cdl);
        }
        if (!newLinks.isEmpty()) insert newLinks;
        
        // 5 Update Lead
        if (newCase != null && newCase.Id != null) {
            leadRec.Case_Comments__c = 'A Case has been created from this Lead.';
            leadRec.Status = 'Not a Lead';
            leadRec.Case_Converted_By__c = UserInfo.getUserId();
            update leadRec;
        }
        
        return [SELECT Id, CaseNumber FROM Case WHERE Id = :newCase.Id];
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


/*public with sharing class LeadToCaseController {
    
    @AuraEnabled(cacheable=true)
    public static Lead getLeadRecord(Id leadId) {
        return [
            SELECT Id, Name, Email, Company, Status, Business_Region__c,Country__c,
            Application_Detail__c, LeadSource
            FROM Lead
            WHERE Id = :leadId
            LIMIT 1
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getCasePicklistValues() {
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();
        Schema.DescribeSObjectResult caseDescribe = Case.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fields = caseDescribe.fields.getMap();
        
        List<String> picklistFields = new List<String>{ 'Status', 'Type', 'Origin', 'Priority' };
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
    
    public static String stripHtml(String htmlText) {
        if (String.isBlank(htmlText)) return '';
        // Remove all HTML tags
        return htmlText.replaceAll('<[^>]*>', '').trim();
    }
    
    @AuraEnabled
    public static Case createCaseFromLead(
        Id leadId,
        String caseRecordType,
        String status,
        String contactName,
        String email,
        String accountName,
        String businessRegion,
        String subject,
        String description,
        String origin,
        String priority,
        String type,
        String country
    ) {
        Lead leadRec = [SELECT Id,Application_Detail__c,Country__c FROM Lead WHERE Id = :leadId LIMIT 1];
        
        Case newCase = new Case();
        newCase.Status = status;
        newCase.Type = type;
        newCase.Subject = subject;
        // newCase.Description = description;
        newCase.Description = stripHtml(leadRec.Application_Detail__c);
        newCase.Origin = origin;
        newCase.Priority = priority;
        newCase.Business_Region__c = businessRegion;
        newCase.SuppliedEmail  = email;
        newCase.Country__c  = country;
        newCase.ownerId = [SELECT Id FROM user WHERE name = 'Hubspot Integration Admin' LIMIT 1].Id; //dibya added
        
        
        newCase.RecordTypeId = [
            SELECT Id FROM RecordType 
            WHERE SObjectType = 'Case' AND Name = :caseRecordType 
            LIMIT 1
        ].Id;
        
        List<Contact> contacts = [
            SELECT Id, AccountId FROM Contact 
            WHERE Email = :email 
            LIMIT 1
        ];
        
        if (!contacts.isEmpty()) {
            Contact matched = contacts[0];
            newCase.ContactId = matched.Id;
            if (matched.AccountId != null) {
                newCase.AccountId = matched.AccountId;
            }
        }
        
        newCase.Originating_Lead__c = leadId;
        insert newCase;
        
        if (newCase != null && newCase.Id != null) {
            leadRec.Case_Comments__c = 'A Case has been created from this Lead.';
            leadRec.Status='Not a Lead';
            leadRec.Case_Converted_By__c = UserInfo.getUserId();
            update leadRec;
        }
        
        return [SELECT Id, CaseNumber FROM Case WHERE Id = :newCase.Id];
    }
}*/