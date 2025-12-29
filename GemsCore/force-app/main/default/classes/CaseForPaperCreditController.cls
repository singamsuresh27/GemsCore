/*
    // Copyright (c) 2014 All Rights Reserved
    // <author>CloudCertitude Technologies </author>
    //<email>rakesh.aggarwal@cloudcertitude.com</email>
    // <date> </date>
*/

public class CaseForPaperCreditController{
    public Case caseObj {get;set;}
    public LIST<Attachment> atchList {get;set;}       
    public boolean isSubmiting {get;set;}
    public String finalMsg {get;set;}
    
    
    public CaseForPaperCreditController(){
        startupAction();  
    }
    
    public void startupAction(){
        caseObj = new Case();
        System.debug('CaseObject initialized.');
        atchList = new LIST<Attachment>();
        for(integer i=0; i<3; i++){
            atchList.add(new Attachment());    
        }       
        caseObj.type = 'Credit Memo Request';
        isSubmiting = true;
    }
    
    public PageReference saveCase(){
        try{
            
            if(caseObj.SuppliedCompany == null || caseObj.SuppliedCompany == '' ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Company name'));
                return null;
            }else if(caseObj.SuppliedName == null || caseObj.SuppliedName == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Requestor  name'));
                return null;
            }else if(caseObj.SuppliedEmail == null || caseObj.SuppliedEmail == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Email Address '));
                return null;
            }else if(caseObj.PO_No__c == null || caseObj.PO_No__c == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Purchase Order '));
                return null;
            }else if(caseObj.Gems_Invoice_Number__c == null || caseObj.Gems_Invoice_Number__c == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Gems Invoice Number '));
                return null;
            }else if(caseObj.Description  == null || caseObj.Description  == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Reason for Credit'));
                return null;
            }
            
            
            LIST<Contact> conlist = [Select id,AccountId from contact where email =: caseObj.SuppliedEmail];
            if(conlist != null && conlist.size() > 0){
                caseObj.contactId = conlist[0].id;
                if(conlist[0].AccountId != null){
                    caseObj.AccountId = conlist[0].AccountId;
                }
            }
            
            caseObj.Subject = 'Credit Memo Request';   
            
            
            
            caseObj.origin = 'Web';
            LIST<RecordType> recType = [select id from RecordType where name='Credit Memo' and SObjectType='Case'];
            if(recType != null && recType.size() > 0){
                caseObj.recordTypeId = recType[0].id;
            }
            upsert caseObj;
            
            List<Attachment> tempList = new List<Attachment>();
            for(Attachment at : atchList){
                if(at.body != null){ 
                    at.parentId = caseObj.id;   
                    tempList.add(at);
                }                
            }
            
            if(tempList.size() > 0){
                upsert tempList;
            }

            finalMsg = 'Your request has been received and is being processed.  We will contact you shortly with additional instructions.  \n If you have any questions in the meantime, please contact our customer service team @ (800) 378-1600.  Thank You.';
            isSubmiting = false;
            return null;    //new PageReference('/'+ caseObj.id);
            
            
        }catch(Exception e){   
        }
        
        return null;
    }
    
    public PageReference openCaseRecord(){
        if(caseObj != null){
            return new PageReference('/'+ caseObj.id);    
        }
        return null;
    }
}