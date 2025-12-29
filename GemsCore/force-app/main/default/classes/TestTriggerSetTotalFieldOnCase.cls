@isTest
private class TestTriggerSetTotalFieldOnCase{
    @isTest
    private static void test(){
        Case caseObj = new Case(Status = 'New',Origin='Email');
        insert caseObj;
        
        Case caseObj1 = new Case(Status = 'New',Origin='Email');
        insert caseObj1;
        
        Account act = new Account(name='test');
        insert act;
        
        LineItem__c orders = new LineItem__c(name='test',AccountId__c = act.id,QuantityShipped__c = 10,Quantity_Returned__c = 2);
        insert orders;
        
        Case_Detail__c caseDetail = new Case_Detail__c(case__c = caseObj.id, Quantity__c = 2, Credit_per_unit__c = 100.0,Order_Shipment__c = orders.id);
        insert caseDetail;
        
        LIST<Case> tempCase = [select total__c from Case where id =: caseObj.id];
        //System.assertEquals(tempCase[0].Total__c,200.0);
        
        caseDetail.case__c = caseObj1.id;
        update caseDetail;
        
        tempCase = [select total__c from Case where id =: caseObj1.id];
        //System.assertEquals(tempCase[0].Total__c,200.0);
        
        delete caseDetail;
        
        tempCase = [select total__c from Case where id =: caseObj1.id];
        //System.assertEquals(tempCase[0].Total__c,0.00);
        
        undelete casedetail;
        tempCase = [select total__c from Case where id =: caseObj1.id];
        //System.assertEquals(tempCase[0].Total__c,200.0);
        
        caseDetail.quantity__c = 3;
        CaseDetailTriggerHandler.FromSearch = false;
        update caseDetail;
        LIST<LineItem__c> orderList = [select Quantity_Returned__c from LineItem__c where id =: orders.id];
        //System.assertEquals(orderList[0].Quantity_Returned__c, 3);
        
    }
}