/*
    // Copyright (c) 2014 All Rights Reserved
    // <author>CloudCertitude Technologies </author>
    //<email>rakesh.aggarwal@cloudcertitude.com</email>
    // <date> </date>
*/

public class GBASController{
    public Case caseObj {get;set;}
    public LIST<Attachment> atchList {get;set;}
    public LIST<String> wStatusList {get;set;}    
    public String tempStatus {get;set;}
    public boolean isSubmiting {get;set;}
    public String finalMsg {get;set;}
    public String returnCW{get; set;}
    public String AccCW{get; set;}
    public String returnNCW{get; set;}
    public String AccNCW{get; set;}
    public boolean checkTermsAndCondtion{get; set;}
    
    public boolean warFirstVal{get; set;}
    public boolean warSecondVal{get; set;}
    public boolean warThirdVal{get; set;}
    public boolean nonWarFirstVal{get; set;}
    public boolean nonWarSecondVal{get; set;}
    public boolean nonWarThirdVal{get; set;}
    
    public boolean emailOptIn{get; set;}
    public boolean telephoneOptIn{get; set;}
    private boolean emailOptOut;

    public GBASController(){   
        startupAction();
        finalMsg = 'Your request has been received and is being processed.  We will contact you shortly with additional instructions.  \n If you have any questions in the meantime, please contact our customer service team @ (800) 378-1600.';
    }
    
    public void startupAction(){
        checkTermsAndCondtion = false; 
        warFirstVal = false; 
        warSecondVal = false; 
        warThirdVal = false; 
        nonWarFirstVal = false; 
        nonWarSecondVal = false; 
        nonWarThirdVal = false; 
        emailOptIn = false;
        telephoneOptIn = false;
            
        returnCW = '';    
        AccCW = '';
        returnNCW = '';
        AccNCW = '';
        caseObj = new Case();
        atchList = new LIST<Attachment>();
        for(integer i=0; i<3; i++){
            atchList.add(new Attachment());    
        }
        caseObj.type = 'RA Request'; 
        isSubmiting = true;
    }
    
    /*private LIST<String> getPickListValues(Schema.DescribeFieldResult fieldResult){
        List<String> options = new List<String>(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
            options.add(p.getValue()); 
        return options;
    }*/
    
    public PageReference saveCase(){
       try{
            if(caseObj.SuppliedCompany == null || caseObj.SuppliedCompany == '' ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Company name'));
                return null;
            }else if(caseObj.SuppliedName == null || caseObj.SuppliedName == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Requestor  name'));
                return null;
            }else if(caseObj.SuppliedPhone == null || caseObj.SuppliedPhone == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Phone Number'));
                return null;
            }else if(caseObj.SuppliedEmail == null || caseObj.SuppliedEmail == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Email Address '));
                return null;
            }else if(caseObj.Product_Number__c == null || caseObj.Product_Number__c == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Gems Part  number'));
                return null;
            }/*else if(caseObj.Customer_Part_Number__c == null || caseObj.Customer_Part_Number__c == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Customer Part Number'));
                return null;
            }*/else if(caseObj.Quantity__c == null || caseObj.Quantity__c <= 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Quantity'));
                return null;
            }else if(caseObj.PO_No__c == null || caseObj.PO_No__c == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Purchase Order '));
                return null;
            }else if(caseObj.Media__c  == null || caseObj.Media__c  == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Media '));
                return null;
            }else if(caseObj.Description  == null || caseObj.Description  == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Reason for Return '));
                return null;
            }else if(!checkTermsAndCondtion){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please accept all service terms before submitting your request.'));
                return null;
            }
            if(warFirstVal){
                caseObj.Warranty_Disposition__c  = 'Repair and return';
            }else if(warSecondVal){
                caseObj.Warranty_Disposition__c  = 'Issue credit/scrap';
            }else if(warThirdVal){
                caseObj.Warranty_Disposition__c  = 'Return for credit';
            }
            
            if(nonWarFirstVal){
                caseObj.Non_Warranty_Disposition__c  = 'Scrap';
            }else if(nonWarSecondVal){
                caseObj.Non_Warranty_Disposition__c  = 'Repair';
                if(caseObj.Max_Repair_Cost__c != null && caseObj.Max_Repair_Cost__c > 500){
                    caseObj.Max_Repair_Cost__c = 500;
                }
                if(returnCW != null)
                    caseObj.Shipping_Carrier_Name__c = returnCW;
                if(AccCW != null)
                    caseObj.Carrier_Account__c = AccCW;
            }else if(nonWarThirdVal){
                caseObj.Non_Warranty_Disposition__c  = 'Return as is';
                if(returnNCW != null)
                    caseObj.Shipping_Carrier_Name__c = returnNCW;
                if(AccNCW != null)
                    caseObj.Carrier_Account__c = AccNCW;
            }
                 
            LIST<Contact> conlist = [Select id,AccountId from contact where email =: caseObj.SuppliedEmail];
            if(conlist != null && conlist.size() > 0){
                caseObj.contactId = conlist[0].id;
                if(conlist[0].AccountId != null){
                    caseObj.AccountId = conlist[0].AccountId;
                }
            } 
           
            caseObj.Warranty_Status__c = tempStatus;
            caseObj.Companyid__c = '00018'; 
            caseObj.Subject = 'Return authorization request'; 
            
            caseObj.origin = 'Web';
            LIST<RecordType> recType = [select id from RecordType where name='RMA' and SObjectType='Case'];
            if(recType != null && recType.size() > 0){
                caseObj.recordTypeId = recType[0].id;
            }
             //Added By MB
            if(conlist==null || conList.size()==0){
                caseObj.Email_Opt_In__c=emailOptIn;
                caseObj.Telephone_Opt_In__c=telephoneOptIn;
            }
            upsert caseObj;
            
            List<Attachment> tempList = new List<Attachment>();
            for(Attachment at : atchList){
                system.debug('Body : '+ atchList);
                if(at.body != null){ 
                    at.parentId = caseObj.id;   
                    tempList.add(at);
                }                
            }
            
            if(tempList.size() > 0){
                upsert tempList;
            }
            
            List<Contact> conListToUpate= new List<Contact>();
            //emailOptOut=emailOptIn==true?false:true;
            //HasOptedOutOfEmail=emailOptOut, Add this if required..
            if(conList!=null && conlist.size() > 0){
                conListToUpate.add(new Contact(Id=conlist[0].id,Email_Opt_In__c=emailOptIn,Telephone_Opt_In__c=telephoneOptIn));
            }
            update conListToUpate;
            
            //finalMsg = 'Your request has been received and is being processed.  We will contact you shortly with additional instructions.  \n If you have any questions in the meantime, please contact our customer service team @ (800) 378-1600.';
            isSubmiting = false;
            return null;
            
            
        }catch(Exception e){
            
        }
        
        return null;
    }
    
    public PageReference openCaseRecord(){
        return new PageReference('/' + caseObj.id);    
    } 
    
}