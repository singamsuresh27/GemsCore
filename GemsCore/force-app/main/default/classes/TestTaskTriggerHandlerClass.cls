@isTest
public class TestTaskTriggerHandlerClass{
    @isTest
    private static void testUpdateOppStage(){
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
        
        TaskTriggerHandlerClass obj = new TaskTriggerHandlerClass();           
        Opportunity op = obj.updateOppStage(opp);
        System.assert(op != null);
        
        List<SelectOption> stage = obj.StageValue();
        System.assert(stage.size() > 0);
        
        Test.stopTest();
    }
    
    
}