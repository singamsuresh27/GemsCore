@isTest
public class TestOpportunityInlineController{
    @isTest
    
    private static void testOppInlineCls(){
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
        
        RecordType rc = [select id,name from RecordType Where name = 'Sales Deliverable' limit 1];
        System.assert(rc != null);
        
        Task tk = new Task();
        tk.status = 'In Progress';
        tk.RecordTypeId = rc.Id;
        tk.subject = 'Opp Update';
        tk.OwnerId = UserInfo.getUserId();
        tk.ActivityDate = System.today().addDays(-1); 
        tk.Description = 'This task is required for stage 1';
        tk.Subject_Description__c = 'Update Forecast (close date, potential revenue, etc.)';
        tk.Opportunity_Stage__c = 'Stage 1 - Qualified';
        tk.WhatId = opp.Id;
        insert tk;
        
        Task tk1 = new Task();
        tk1.status = 'In Progress';
        tk1.RecordTypeId = rc.Id;
        tk1.subject = 'Opp Update';
        tk1.OwnerId = UserInfo.getUserId();
        tk1.ActivityDate = System.today().addDays(7); 
        tk1.Description = 'This task is required for stage 1';
        tk1.Subject_Description__c = 'Update Forecast (close date, potential revenue, etc.)';
        tk1.Opportunity_Stage__c = 'Stage 1 - Qualified';
        tk1.WhatId = opp.Id;
        insert tk1;
        
        Task tk2 = new Task();
        tk2.status = 'In Progress';
        tk2.RecordTypeId = rc.Id;
        tk2.subject = 'Opp Update';
        tk2.OwnerId = UserInfo.getUserId();
        tk2.ActivityDate = System.today().addDays(18); 
        tk2.Description = 'This task is required for stage 1';
        tk2.Subject_Description__c = 'Update Forecast (close date, potential revenue, etc.)';
        tk2.Opportunity_Stage__c = 'Stage 1 - Qualified';
        tk2.WhatId = opp.Id;
        insert tk2;
        
        Task tk3 = new Task();
        tk3.status = 'Inactive';
        tk3.RecordTypeId = rc.Id;
        tk3.subject = 'Opp Update';
        tk3.OwnerId = UserInfo.getUserId();
        tk3.ActivityDate = System.today().addDays(8); 
        tk3.Description = 'This task is required for stage 1';
        tk3.Subject_Description__c = 'Update Forecast (close date, potential revenue, etc.)';
        tk3.Opportunity_Stage__c = 'Stage 1 - Qualified';
        tk3.WhatId = opp.Id;
        insert tk3;
        
        Task tk4 = new Task();
        tk4.status = 'Completed';
        tk4.RecordTypeId = rc.Id;
        tk4.subject = 'Opp Update';
        tk4.OwnerId = UserInfo.getUserId();
        tk4.ActivityDate = System.today().addDays(8); 
        tk4.Description = 'This task is required for stage 1';
        tk4.Subject_Description__c = 'Update Forecast (close date, potential revenue, etc.)';
        tk4.Opportunity_Stage__c = 'Stage 1 - Qualified';
        tk4.WhatId = opp.Id;
        insert tk4;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        OpportunityInlineController obj = new OpportunityInlineController(sc);
        
        Test.stopTest();
    }
}