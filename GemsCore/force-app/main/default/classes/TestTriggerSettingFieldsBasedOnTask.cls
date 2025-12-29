@isTest
private class TestTriggerSettingFieldsBasedOnTask{
    @isTest
    private static void test(){
        Account act = new Account(name='testaccount');
        insert act; 
        
        Product_Type__c prodType = new Product_Type__c(Name = 'testproduct type',CurrencyIsoCode = 'USD');
        insert prodType;
        
        Product_Model__c prodModel = new Product_Model__c(Name = 'test model',CurrencyIsoCode = 'USD',Product_Type__c = prodType.Id);
        insert prodModel;
        
        Opportunity op = new Opportunity();
        op.AccountId = act.id;
        op.Product_Model__c = prodModel.id;
        op.Business_Unit__c = 'GEMS_NA';
        op.name = 'test';
        op.closeDate = System.today();
        op.StageName = 'Stage 1 - Qualified';
        op.Next_Step_Due_date__c = System.today();
        op.NextStep = '2';
        insert op;
        
        LIST<Opportunity> opTest = [Select id,NextStageDate__c from Opportunity where id =: op.id];
        System.assertEquals(opTest[0].NextStageDate__c,null);
        
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
        tk.WhatId = op.Id;
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
        tk1.WhatId = op.Id;
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
        tk2.WhatId = op.Id;
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
        tk3.WhatId = op.Id;
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
        tk4.WhatId = op.Id;
        insert tk4;
        
        op.name='test1';
        update op;
        
        opTest = [Select id,NextStageDate__c from Opportunity where id =: op.id];
        System.assertNotEquals(opTest[0].NextStageDate__c,null);
    }
}