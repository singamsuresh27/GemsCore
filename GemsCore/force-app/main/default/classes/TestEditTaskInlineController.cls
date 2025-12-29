@isTest
public class TestEditTaskInlineController{
    @isTest
    
    private static void testTaskInlinePage(){
        Test.startTest();
        
        Account acc = new Account();
        acc.Name = 'test account';          
        insert acc;
        
        Product_Type__c pt = new Product_Type__c();
        pt.Name = 'test product type';
        pt.CurrencyIsoCode = 'USD';
        insert pt;
        
        Product_Model__c pm = new Product_Model__c();
        pm.Name = 'test product model';
        pm.CurrencyIsoCode = 'USD';
        pm.Product_Type__c = pt.Id;
        insert pm;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.Product_Model__c = pm.Id;
        opp.StageName = 'Stage 1 - Qualified';
        opp.Business_Unit__c = 'GEMS_NA';
        opp.CloseDate = System.today();
        opp.Next_Step_Due_date__c = System.today();
        opp.NextStep = '2';
        insert opp;
        
        Task tk = new Task();
        tk.status = 'In Progress';
        tk.subject = 'Opp Update';
        tk.OwnerId = UserInfo.getUserId();
        tk.ActivityDate = System.today(); 
        tk.Description = 'This task is required for stage 1';
        tk.Subject_Description__c = 'Update Forecast (close date, potential revenue, etc.)';
        tk.WhatId = opp.Id;
        insert tk;
        
        String rId = [select id from recordtype where name = 'Sales Deliverable' limit 1].Id;
        System.assert(rId != null);
        
        Task tk1 = new Task();
        tk1.status = 'In Progress';
        tk1.subject = 'Opp Update';
        tk1.OwnerId = UserInfo.getUserId();
        tk1.ActivityDate = System.today(); 
        tk1.Description = 'This task is required for stage 1';
        tk1.Subject_Description__c = 'Update Forecast (close date, potential revenue, etc.)';
        tk1.WhatId = opp.Id;
        tk1.RecordTypeId = rId;
        insert tk1;
        
        Blob b = Blob.valueOf('Test Data');
        
        Attachment att = new Attachment();
        att.ParentId = tk.id;
        att.Body = b;
        att.Name = 'Test Attachment for Parent';
        insert att;
        
        ApexPages.CurrentPage().getParameters().put('attId',att.Id);
        EditTaskInlineController obj1 = new EditTaskInlineController();
        PageReference pg1 = obj1.editAttachment();
        System.assert(pg1 != null);
        obj1.detailAttachment();
        
        ApexPages.CurrentPage().getParameters().put('hideButton','true');
        ApexPages.CurrentPage().getParameters().put('showPanel','true');
        ApexPages.StandardController sc = new ApexPages.StandardController(tk);
        EditTaskInlineController obj = new EditTaskInlineController(sc);
        obj.selectedStatus = 'Completed';
        PageReference pg = obj.updateTask();
        System.assert(pg != null);
        
        obj.selectedStatus = '';
        pg = obj.updateTask();
        System.assert(pg != null);
        
        pg = obj.checkSD();
        System.assert(pg != null);
        
        pg = obj.redirectToDetail();
        System.assert(pg != null);
        
        obj.editTask();
        obj.methodToDeleteTask();
        obj.goBack();
        
        ApexPages.CurrentPage().getParameters().put('hideButton','false');
        ApexPages.StandardController sc1 = new ApexPages.StandardController(tk1);
        EditTaskInlineController obj2 = new EditTaskInlineController(sc1);
        pg = obj2.checkSD();
        System.assert(pg != null);
        pg = obj2.redirectToDetail();
        System.assert(pg != null);
        pg = obj2.updateTask();
        System.assert(pg != null);
        
        Test.stopTest();
    }
}