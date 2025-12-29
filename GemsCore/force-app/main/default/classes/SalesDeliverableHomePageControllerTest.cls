@isTest
public class SalesDeliverableHomePageControllerTest{

    @isTest
    private static void testSales(){
        User u = [select id from user where Id =: UserInfo.getUserId() limit 1];
        System.runAs(u){
            Sales_Processes__c sp = new Sales_Processes__c();
            sp.Name = 'Funnel 2.0 Task 9';
            sp.Business_Unit__c = 'GEMS_NA';
            sp.Must_complete_on_Stage__c = false;
            sp.Description__c = 'This task is required for stage 1';
            sp.Subject_Description__c = 'Update Forecast (close date, potential revenue, etc.)';
            sp.Subject__c = 'Opp Update';
            sp.Due_Date_From__c = 'Task Create Date';
            sp.Due_Date__c = 30.0;
            sp.Assignee__c = 'Owner';
            sp.Stage__c = 'Stage 1 - Qualified';
            sp.Type__c = 'Funnel Management';
            sp.Object__c = 'Opportunity';
            sp.Is_Active__c = true;
            insert sp;
            
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
            
            SalesDeliverableHomePageController obj = new SalesDeliverableHomePageController();
            List<SelectOption> criteriaList = obj.getCriteriaList();
            System.assert(criteriaList.size() > 0);
            obj.filterRecords();
            obj.first();
            obj.PNext();
            obj.previous();
            obj.last();
            obj.sortByColumns();
            obj.selectedColumn = 'ActivityDate';
            
        }        
    }
}