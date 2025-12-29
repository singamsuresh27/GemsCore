/*
    // Copyright (c) 2014 All Rights Reserved
    // <author>CloudCertitude Technologies </author>
    //<email>rakesh.aggarwal@cloudcertitude.com</email>
    // <date> </date>
*/

@isTest
public class TestShowCaseDetailsController{
    
    @isTest
    private static void test(){
        
         Account act = new Account(name='testaccoout');
        insert act;
        
        Contact con = new Contact(lastname='test',email='test@gmail.com',accountId = act.id);
        insert con;
        
        Case caseObj = new Case(Origin ='Email',
                            PO_No__c='1234',
                            Gems_SO_Number__c='1234',
                            Gems_Invoice_Number__c= '1234',
                            Customer_Internal_Case_RA_No__c = '1234',
                            type = 'RA',
                            ContactId=con.id,
                            Product_Number__c = '1234');
        insert caseObj;
        Case_Detail__c caseDetail = new Case_Detail__c(name='test',
                                    Line_Number__c = 1,
                                    Quantity__c = 0,
                                    Date_Shipped__c = System.today(),
                                    case__c = caseObj.id,
                                    Email_Sent__c = false);
        insert caseDetail;
        
        ShowCaseDetailsController testObj = new ShowCaseDetailsController (new ApexPages.StandardController(caseObj));
        if (testObj.modelList != null) {
            testObj.modelList[0].flg = true;
            testObj.emailIds = '';
            testObj.declineMail();
            testObj.emailIds = 'test1@gmail.com;test@gmail.com';
            testObj.approvalMail();
            testObj.emailIds = 'test1@gmail.com,test@gmail.com';
            testObj.approvalMail();
            testObj.emailIds = 'test1@gmail.com\ntest@gmail.com';
            testObj.approvalMail();
            testObj.populateTemplate();
            LIST<Case_Detail__c> caseDetailList = [select id , Email_Sent__c from Case_Detail__c];
            System.assertEquals(caseDetailList[0].Email_Sent__c, true);
            testObj.cancelAction();
        }
    }
}