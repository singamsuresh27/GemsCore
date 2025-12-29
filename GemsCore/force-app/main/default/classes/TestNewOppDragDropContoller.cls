@isTest
private class TestNewOppDragDropContoller{
    @isTest
    private static void test(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User usr = new User(Alias = 'standt', 
                        Email='oppwalluser@test.com', 
                        EmailEncodingKey='UTF-8', 
                        LastName='Testing', 
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', 
                        ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', 
                        UserName='oppwalluser@test.com',
                        job_title__c ='Project Sales Manager');
        insert usr;
        
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
        op.Project_Manager__c = usr.id;
        insert op;
        
        op = new Opportunity();
        op.AccountId = act.id;
        op.Product_Model__c = prodModel.id;
        op.Business_Unit__c = 'GEMS_NA';
        op.name = 'test';
        op.closeDate = System.today();
        op.StageName = 'Stage 1 - Qualified';
        op.Next_Step_Due_date__c = System.today();
        op.NextStep = '2';
        op.Project_Manager__c =usr.id;
        insert op;
        
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
        
        NewOppDragDropContoller obj = new NewOppDragDropContoller();  
        List<NewOppDragDropContoller.OpportunityWrapper> temp = obj.tempMethod(); 
        
        
        NewOppDragDropContoller.changeOpportunityStage(op.id,'Closed Lost','stagename','picklist');
        
        obj.myFirst();
        obj.myNext();
        obj.myPrev();
        obj.myLast();
        
        obj.getAccountExistingViews();
        obj.getOppsExistingViews();
        obj.showingPanel();
        obj.groupbypanel='ow';
        obj.showingPanel();
        obj.groupbypanel='pm';
        obj.showingPanel();
        //obj.notFromShowButtonMethod();
        //obj.fromShowButtonMethod();
        
        NewOppDragDropContoller.toggleFollowingOpportunity(op.id,'unfollowing');
        Map<String,Double> res1  = obj.getMapStageTotal();
        Map<String,Integer> res2  = obj.getMapStageRecordCount();
        Map<String,Map<String,NewOppDragDropContoller.OppOnwerWrapper>> res3  = obj.getWrraperMap ();
        Map<String,Map<String,NewOppDragDropContoller.OppOnwerWrapper>> res4  = obj.getWrraperMapPM ();
        System.assertNotEquals(res1, null);
        System.assertNotEquals(res4, null);
    }
}