/*
    // Copyright (c) 2014 All Rights Reserved
    // <author>CloudCertitude Technologies </author>
    //<email>rakesh.aggarwal@cloudcertitude.com</email>
    // <date> </date>
*/

@isTest
public class TestSearchController{
    @isTest
    private static void test(){
        Account act = new Account(name='test');
        insert act;
        
        Contact  con = new Contact(firstname='test',lastname='kumar',email='test@gmail.com', phone='1234567890', fax='1234567890', AccountId = act.id);
        insert con;
        
        Case caseObj = new Case(AccountId=act.id,
                            Origin ='Email',
                            contactId = con.id,
                            type = 'RA Request',
                            PO_No__c='1234',
                            Gems_SO_Number__c='1234',
                            Gems_Invoice_Number__c= '1234',
                            Customer_Internal_Case_RA_No__c = '1234',
                            Product_Number__c = '111');
        insert caseObj;
        
        
        Product2 prod = new Product2(Name='one', 
                                ProductCode='111', 
                                isActive=true, 
                                Description='Test Product');
        insert prod;
        
        LineItem__c line = new LineItem__c(AccountId__c = act.id,
                                         PONumber__c = '1234',
                                         OrderNumber__c = '1234',
                                         InvoiceNumber__c = '1234',
                                         ProdNo__c = '1234',
                                         OrderDate__c = System.today(),
                                         ShipDate__c = System.today(),
                                         IsShiped__c = true,
                                         UnitPrice__c = 2,
                                         QuantityShipped__c = 5,
                                         Quantity_Returned__c = 3,
                                         BUID__c = '00018',
                                         productid__c = prod.id,
                                         OrderType__c = 'SO');
        insert line;                        
        
        
        SearchController  testObj = new SearchController(new ApexPages.StandardController(caseObj));
        
        User u = [Select id, Job_title__c, Companyid__c from User where id =: UserInfo.getUserId()];                
        u.job_title__c = 'Case Manager'; 
        u.Companyid__c='00018';
        update u;
        
        //testObj = new SearchController();
       
        testObj = new SearchController(new ApexPages.StandardController(caseObj));
        
        ApexPages.currentPage().getParameters().put('id',caseObj.id);
        //testObj = new SearchController();
        
        testObj = new SearchController(new ApexPages.StandardController(caseObj));
        testObj.tObj = caseObj;
        testObj.pageSize = 20;
        
        //testObj.cancelAction();
        
        Test.startTest();
        
        testObj.tObj.PO_No__c = '1234';
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.searchOrder();
        
        testObj.tObj.PO_No__c = '1234';
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.searchOrder();
        
        testObj.tObj.PO_No__c = '1234'; 
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = System.today().addDays(-1);
        testObj.searchOrder();
        
        testObj.tObj.PO_No__c = '1234'; 
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = System.today();
        testObj.searchOrder();
        //pageSize
        testobj.first();
        testObj.last();
        testObj.previous();
        testObj.pnext();
        
        testObj.tObj.accountId = act.id;
        testObj.tempObj.OrderDate__c = System.today();
        //testObj.tempObj.BUID__c='00018';
        testObj.searchOrderWithAccountId();
        
        testObj.tObj.accountId = act.id; 
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = System.today().addDays(-1);
        testObj.searchOrderWithAccountId();
        
        testObj.tObj.accountId = act.id; 
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = System.today();
        testObj.searchOrderWithAccountId();
        
        testObj.tObj.Gems_Invoice_Number__c= '1234';
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.searchOrderWithInvoice();

        
        testObj.tObj.Gems_Invoice_Number__c= '1234'; 
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = System.today().addDays(-1);
        testObj.searchOrderWithInvoice();
        
        testObj.tObj.Gems_Invoice_Number__c= '1234';  
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = System.today();
        testObj.searchOrderWithInvoice();
                
        testObj.tObj.Gems_SO_Number__c='1234';
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.searchOrderWithSalesOrder();
        
        testObj.tObj.Gems_SO_Number__c='1234'; 
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = System.today().addDays(-1);
        testObj.searchOrderWithSalesOrder();
        
        testObj.tObj.Gems_SO_Number__c='1234';  
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = System.today();
        testObj.searchOrderWithSalesOrder();

        testObj.tempObj.productid__c = prod.id;    //'1234';
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.searchOrderWithPartNumber();
        
        testObj.tempObj.productid__c = prod.id;    //'1234';
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = System.today().addDays(-1);
        testObj.searchOrderWithPartNumber();
        
        testObj.tempObj.productid__c = prod.id;    //'1234';  
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = System.today();
        testObj.searchOrderWithPartNumber();
        
        testObj.searchOrderByDate();
        
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.searchOrderByDate();
        
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = System.today().addDays(-1);
        testObj.searchOrderByDate();
        
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.CancelationDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.searchOrderByDate();
        
        testObj.addCaseDetail();
        
        testObj.modelList[0].flg = true;
        testObj.addCaseDetail();
        
        testObj.modelList[0].flg = true;
        testObj.modelList[0].qtyRet = 8;
        testObj.addCaseDetail();
        
        testObj.modelList[0].flg = true;
        testObj.modelList[0].qtyRet = 1;
        testObj.addCaseDetail();
        
        testObj.modelList[0].flg = true;
        testObj.modelList[0].qtyRet = 1;
        testObj.modelList[0].media= 'test';
        testObj.internalcomment = 'test';
        CaseDetailTriggerHandler.FromSearch = true;
        testObj.addCaseDetail();
        
        LIST<Case_Detail__c> caseDetail = [Select id from Case_Detail__c];
        //System.assertEquals(caseDetail.size() , 1);
        
        testObj.isSpecialReturn = true;
        CaseDetailTriggerHandler.FromSearch = true;
        testObj.addCaseDetail();
        
        testObj.tempObj.productid__c = prod.id;    //'1234';
        testObj.searchOrderWithPartNumber();
        
        testObj.isSpecialReturn = true;
        CaseDetailTriggerHandler.FromSearch = true;
        testObj.addCaseDetail();
        
        caseDetail = [Select id from Case_Detail__c];
        //System.assertEquals(caseDetail.size() , 2);
        
        //Test.stopTest();
        
        testObj.approveAndSendEmail();
        caseDetail = [Select id from Case_Detail__c];
        //System.assertEquals(caseDetail.size() , 3);
        
        testObj.selContact = '';
        testObj.addCaseDetail();
        
        testObj.selContact = 'new';
        testObj.con.lastname = null;
        testObj.addCaseDetail();
        
        testObj.selRecord = 0;
        
        
        testObj.caseCommentBody = 'testbody';
        testObj.addCaseComment();
        LIST<CaseComment> caseComment = [select id from caseComment];
        //System.assertEquals(caseComment.size() , 2);      
        
        testObj.settingPaperCreditFlag();
        testObj.isCaseIdNull = true;
        testObj.tObj.type = 'Credit Memo';
        testObj.settingPaperCreditFlag(); 
        testObj.selContact = 'new';
        testObj.tObj.suppliedName = 'test kumar';
        testObj.fetchContact(); 
        testObj.tObj.suppliedName = 'test';
        testObj.fetchContact();
        
        testObj.addCaseDetail();
        
        Case caseObj1 = new Case(AccountId=act.id,
                            Origin ='Email',
                            contactId = con.id,
                            PO_No__c='1234',
                            type = 'Credit Memo Request');
        insert caseObj1;
        
        
        ApexPages.currentPage().getParameters().put('id',caseObj1.id);
        SearchController.isTesting = true;
        testObj = new SearchController(new ApexPages.StandardController(caseObj));
        testObj.tObj = caseObj;
        testObj.atchList[0] .name='test.jpg';
        testObj.atchList[0].body = Blob.valueOf('testing');
        testObj.addCaseDetail();
        //testObj.tObj.type = 'Credit Memo';
        //testObj.caseDetailsObject();
    }
    
    @isTest
    private static void unitTest2(){
        Account act = new Account(name='test');
        insert act;
        
        Contact  con = new Contact(firstname='test',lastname='kumar',email='test@gmail.com', phone='1234567890', fax='1234567890', AccountId = act.id);
        insert con;
        
        Case caseObj = new Case(AccountId=act.id,
                            Origin ='Email',
                            contactId = con.id,
                            type = 'Credit Memo',
                            PO_No__c='1234',
                            Gems_SO_Number__c='1234',
                            Gems_Invoice_Number__c= '1234',
                            Customer_Internal_Case_RA_No__c = '1234',
                            Product_Number__c = '111');
        insert caseObj;
        
        
        Product2 prod = new Product2(Name='one', 
                                ProductCode='111', 
                                isActive=true, 
                                Description='Test Product');
        insert prod;
        
        LineItem__c line = new LineItem__c(AccountId__c = act.id,
                                         PONumber__c = '1234',
                                         OrderNumber__c = '1234',
                                         InvoiceNumber__c = '1234',
                                         ProdNo__c = '1234',
                                         OrderDate__c = System.today(),
                                         ShipDate__c = System.today(),
                                         IsShiped__c = true,
                                         UnitPrice__c = 2,
                                         QuantityShipped__c = 5,
                                         Quantity_Returned__c = 3,
                                         BUID__c = '00018',
                                         productid__c = prod.id,
                                         OrderType__c = 'SO');
        insert line;                        
        
        
        SearchController  testObj = new SearchController(new ApexPages.StandardController(caseObj));
        
        User u = [Select id, Job_title__c,Create_RA__c,Create_Credit_Memo__c,Companyid__c from User where id =: UserInfo.getUserId()];                
        u.Companyid__c='00018';
        u.Create_RA__c = false;
        u.Create_Credit_Memo__c = false;
        update u;
        
        //testObj = new SearchController();
       
        testObj = new SearchController(new ApexPages.StandardController(caseObj));
        
        User user = [Select id, Job_title__c,Create_RA__c,Create_Credit_Memo__c,Companyid__c from User where id =: UserInfo.getUserId()];                
        user.Create_RA__c = false;
        user.Create_Credit_Memo__c = false;
        update user;
    
        ApexPages.currentPage().getParameters().put('id',caseObj.id);
        //testObj = new SearchController();
        testObj = new SearchController(new ApexPages.StandardController(caseObj));
        testObj.tObj = caseObj;
    }
    
    @isTest
    private static void unitTest3(){
        Account act = new Account(name='test');
        insert act;
        
        Contact  con = new Contact(firstname='test',lastname='kumar',email='test@gmail.com', phone='1234567890', fax='1234567890', AccountId = act.id);
        insert con;
        
        Case caseObj = new Case(AccountId=act.id,
                            Origin ='Email',
                            contactId = con.id,
                            type = 'Credit Memo',
                            Gems_SO_Number__c='1234',
                            Gems_Invoice_Number__c= '1234',
                            Customer_Internal_Case_RA_No__c = '1234',
                            Product_Number__c = '111');
        insert caseObj;
        
        
        Product2 prod = new Product2(Name='one', 
                                ProductCode='111', 
                                isActive=true, 
                                Description='Test Product');
        insert prod;
        
        LineItem__c line = new LineItem__c(AccountId__c = act.id,
                                         PONumber__c = '1234',
                                         OrderNumber__c = '1234',
                                         InvoiceNumber__c = '1234',
                                         ProdNo__c = '1234',
                                         OrderDate__c = System.today(),
                                         ShipDate__c = System.today(),
                                         IsShiped__c = true,
                                         UnitPrice__c = 2,
                                         QuantityShipped__c = 5,
                                         Quantity_Returned__c = 3,
                                         BUID__c = '00018',
                                         productid__c = prod.id,
                                         OrderType__c = 'SO');
        insert line;                        
        
        
        SearchController  testObj = new SearchController(new ApexPages.StandardController(caseObj));
        
        User u = [Select id, Job_title__c, Companyid__c from User where id =: UserInfo.getUserId()];                
        u.job_title__c = 'Case Manager'; 
        u.Companyid__c='00018';
        update u;
        
        //testObj = new SearchController();
       
        testObj = new SearchController(new ApexPages.StandardController(caseObj));
        
        ApexPages.currentPage().getParameters().put('id',caseObj.id);
        //testObj = new SearchController();
        
        testObj = new SearchController(new ApexPages.StandardController(caseObj));
        testObj.tObj = caseObj;
        testObj.pageSize = 20;
        
        //testObj.cancelAction(); 
        
        Test.startTest();
        
        testObj.tObj.PO_No__c = '1234';
        testObj.tempObj.OrderDate__c = null;
        testObj.tempObj.BUID__c='00018';
        testObj.searchOrder();
        
        testObj.tObj.PO_No__c = '1234'; 
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = null;
        testObj.searchOrder();
        
        testObj.tObj.PO_No__c = '1234'; 
        testObj.tempObj.OrderDate__c = System.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = System.today();
        testObj.searchOrder();
        
        //pageSize
        testobj.first();
        testObj.last();
        testObj.previous();
        testObj.pnext();
        
        testObj.tObj.accountId = act.id; 
        testObj.tempObj.OrderDate__c = null;
        testObj.tempObj.BUID__c='00018';
        testObj.searchOrderWithAccountId();
        
        testObj.tObj.accountId = act.id; 
        testObj.tempObj.OrderDate__c = system.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = null;
        testObj.searchOrderWithAccountId();
        
        testObj.tObj.Gems_Invoice_Number__c= '1234'; 
        testObj.tempObj.OrderDate__c = null;
        testObj.tempObj.BUID__c='00018';
        testObj.searchOrderWithInvoice();
        
        testObj.tObj.Gems_Invoice_Number__c= '1234'; 
        testObj.tempObj.OrderDate__c = system.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = null;
        testObj.searchOrderWithInvoice();
        
        testObj.tObj.Gems_SO_Number__c='1234'; 
        testObj.tempObj.OrderDate__c = null;
        testObj.tempObj.BUID__c='00018';
        testObj.searchOrderWithSalesOrder();
        
        testObj.tObj.Gems_SO_Number__c='1234'; 
        testObj.tempObj.OrderDate__c = system.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = null;
        testObj.searchOrderWithSalesOrder();
        
        testObj.tempObj.productid__c = prod.id;    //'1234';
        testObj.tempObj.OrderDate__c = null;
        testObj.tempObj.BUID__c='00018';
        testObj.searchOrderWithPartNumber();
        
        testObj.tempObj.productid__c = prod.id;    //'1234';
        testObj.tempObj.OrderDate__c = system.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = null;
        testObj.searchOrderWithPartNumber();
        
        testObj.tempObj.OrderDate__c = null;
        testObj.tempObj.BUID__c='00018';
        testObj.searchOrderByDate();
        
        testObj.tempObj.OrderDate__c = system.today();
        testObj.tempObj.BUID__c='00018';
        testObj.tempObj.CancelationDate__c = null;
        testObj.searchOrderByDate();
        
        Test.stopTest();
    }
    
}