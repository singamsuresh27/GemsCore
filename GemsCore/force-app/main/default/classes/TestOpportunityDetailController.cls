@isTest
private class TestOpportunityDetailController{
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
        
        op = new Opportunity();
        op.AccountId = act.id;
        op.Product_Model__c = prodModel.id;
        op.Business_Unit__c = 'GEMS_NA';
        op.name = 'test';
        op.closeDate = System.today();
        op.StageName = 'Stage 1 - Qualified';
        op.Next_Step_Due_date__c = System.today();
        op.NextStep = '2';
        insert op;
        
        ApexPages.currentPage().getParameters().put('id',op.id);
        OpportunityDetailController obj = new OpportunityDetailController(new ApexPages.StandardController(op));
        obj.toggleEdit();
        obj.saveOpportunity();
        obj.cancelSave();
        obj.toggleEdit();
    }
}