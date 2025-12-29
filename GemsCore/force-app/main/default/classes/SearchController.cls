/*
    // Copyright (c) 2014 All Rights Reserved
    // <author>CloudCertitude Technologies </author>
    //<email>rakesh.aggarwal
    //l@cloudcertitude.com</email>
    // <date> </date>
*/

public  class SearchController{
    public LineItem__c tempObj {get;set;}
    public Case tObj {get;set;}
    public boolean isCaseManager {get;set;}
    public LIST<SelectOption> lstContact {get;set;}
    public String selContact {get;set;}
    public Contact con {get;set;} 
    public LIST<OrderModel> modelList {get;set;}
    public LIST<Case_Detail__c> lstCaseDetail {get;set;}
    public boolean isSpecialReturn {get;set;}
    public Map<String,LIST<OrderModel>> mapModelList {get;set;}
    public Set<String> kys {get;set;}
    public Map<String,sObject> mapCompany {get;set;}
    public String specialDescription {get;set;}
    LIST<LineItem__c > lstOrder;
    String caseId;
    public LIST<SelectOption> lstCaseType {get;set;}
    public boolean isCaseIdNull  {get;set;}
    public boolean isValidUser {get;set;}
    public String company {get;set;}
    public static boolean isTesting = false;
    
    public String contactJson {get;set;}
    public Integer searchActionStatus {get;set;}
    public boolean isPaperCredit {get;set;}
    public String title {get;set;}
    public LIST<SelectOption> creditTypeSelectList {get;set;}
    public LIST<SelectOption> functionalAreaSelectList {get;set;}
    public LIST<Attachment> atchList {get;set;}
    public String internalcomment {get;set;}
        
    //Constructor with Parameter 
    public SearchController(ApexPages.StandardController sc){
    
        atchList = new LIST<Attachment>();
        for(integer i=0; i<3; i++){
            atchList.add(new Attachment());    
        }
        
        caseId = ApexPages.currentPage().getParameters().get('id');
        User u = [select id, Create_Credit_Memo__c ,Create_RA__c,Job_Title__c, Business_Unit__c, Companyid__c from user where id=: UserInfo.getUserId()];
        if(u.Job_Title__c == 'Case Manager'){
            isValidUser = true;
            company = u.Companyid__c;
        }else{
            isValidUser = false;
            company = u.Companyid__c;
        }
        LIST<Case> tempCase ; 
        System.debug('$Case Id:'+caseId);         
         if(caseId != null ){
             System.debug('caseID::::'+caseId);
             tempCase = [select id, Shipping_Carrier_Name__c,Warranty_Disposition__c,Non_Warranty_Disposition__c,Max_Repair_Cost__c,Item_Return_PO__c,Carrier_Account__c,Account.Return_requirements__c,Return_Material_Need_By__c,type,Quantity__c,CaseNumber,Description,SuppliedEmail,SuppliedName,Productid__c,SuppliedPhone,contactId,AccountId,Account.name,Gems_Invoice_Number__c,PO_No__c,Gems_SO_Number__c,Product_Number__c,Customer_Internal_Case_RA_No__c,Customer_Part_Number__c,Media__c,Email_Opt_In__c,Telephone_Opt_In__c from Case where id =: caseId and type in ('Credit Memo','RA Request','Credit Memo Request','RA')];//[select id,type from Case where id =: caseId and type in ('Paper Credit','RA Request','Credit Memo Request','RA')]; 
             if(tempCase == null || tempCase.size() == 0 ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Case type must be RA Request, Credit Memo Request or RA for this operation.'));   
                isCaseManager = false;
                return;
             }else{
                if((tempcase[0].type == 'RA Request' || tempcase[0].type == 'RA') && u.Job_Title__c != 'Case Manager'){
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You should be a Case Manager to perform this task.'));   
                    isCaseManager = false;
                }else{
                    if(tempcase[0].type == 'RA Request' || tempcase[0].type == 'RA'){
                        title = 'Validate and Create RA';
                        isPaperCredit = false;
                    }else{
                        title = 'Validate and Create Credit Memo';
                        isPaperCredit = true;    
                        fillCreditTypeList();
                    }
                    isCaseManager = true;    
                }
            }
        }
        
            
        //tempObj = new LineItem__c();
        LIST<LineItem__c> tempOrderList = [Select OrderDate__c,CancelationDate__c from LineItem__c LIMIT 1];
        if(tempOrderList != null && tempOrderList.size() > 0){
            tempObj = tempOrderList[0];
            tempObj.OrderDate__c = System.today().addYears(-2);    //.addMonths(-6);
            tempObj.CancelationDate__c = System.today();
        }
        con = new Contact();
        lstContact = new LIST<SelectOption>();
        modelList = new LIST<OrderModel>();
        lstCaseType = new LIST<SelectOption>();
        mapModelList = new Map<String,LIST<OrderModel>>();
        lstContact.add(new SelectOption('','--Select Contact--'));
        lstContact.add(new SelectOption('new','--Create New Contact--'));
        isSpecialReturn = false;
        pageSize = 10;
        internalcomment ='';
        
        lstCaseDetail =  new LIST<Case_Detail__c>();
        if(caseId == null || caseId == ''){
            tObj = new Case();
            for(Schema.PicklistEntry p : Case.Type.getDescribe().getPicklistValues()){
               
                /*
                //old logic
                if(u.Create_Credit_Memo__c){
                    if(p.getValue() == 'Credit Memo'){
                        lstCaseType.add(new SelectOption(p.getValue(),p.getValue()));
                    }
                    isCaseManager = true; 
                }else{
                    if(p.getValue() == 'RA'){
                        lstCaseType.add(new SelectOption(p.getValue(),p.getValue())); 
                    }
                    isCaseManager = true; 
                }*/
                
                
                //Change RA Security Logic -- 23/06/206
                if(u.Create_Credit_Memo__c){
                    if(p.getValue() == 'Credit Memo'){
                        lstCaseType.add(new SelectOption(p.getValue(),p.getValue()));
                    }
                    isCaseManager = true; 
                }
                if(u.Create_RA__c){
                    if(p.getValue() == 'RA'){
                        lstCaseType.add(new SelectOption(p.getValue(),p.getValue())); 
                    }
                    isCaseManager = true; 
                }
                if(!u.Create_RA__c && !u.Create_Credit_Memo__c){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'User must have permission for this operation. Please contact to System Administrator.'));   
                    isCaseManager = false;
                    return;
                }
            }
            isCaseIdNull = true;
            tobj.type=lstCaseType[0].getValue();    //'RA'; 
            settingPaperCreditFlag();
        }else{
            isCaseIdNull  = false;
            //RA Security login for Validate/Line Form --- 23/06/2016
            if(!u.Create_RA__c && !u.Create_Credit_Memo__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'User must have permission for this operation. Please contact to System Administrator.'));   
                isCaseManager = false;
                return;
            }
            
            if(tempCase == null || tempCase.size() == 0 ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Case type must be RA Request, Credit Memo Request or RA for this operation.'));   
                isCaseManager = false;
                return;
            }else{
                isCaseManager = true;
                tObj = tempCase[0];        
                
                if(tObj.AccountId != null){
                    setActIds.add(tObj.AccountId);
                    allContacts();
                }
                
                if(tObj.contactId == null){                    
                    selContact = 'new';
                    fetchContact();                          
                    
                }else{
                    selContact = tObj.ContactId;   
                    fetchContact();
                }  
            }
        }
        if(tObj.Product_Number__c != null){
            LIST<Product2> prod = [Select id from Product2 where ProductCode =: tObj.Product_Number__c];
            if(prod != null && prod.size() > 0){
                tObj.productid__c = prod[0].id;        
            }
        }
        if(tObj.PO_No__c != null){
            searchOrder();    
        }else if(tObj.productid__c != null){
            searchOrderWithPartNumber();    
        }
    }
    
    //filling Credit Type SelectOption List
    private void fillCreditTypeList(){
        creditTypeSelectList = new LIST<SelectOption>();
        creditTypeSelectList.add(new SelectOption('','--None--'));
        for(Schema.PicklistEntry p : Case_Detail__c.Credit_Type__c.getDescribe().getPicklistValues())
            creditTypeSelectList.add(new SelectOption(p.getValue(),p.getValue()));
        
        functionalAreaSelectList = new LIST<SelectOption>();
        functionalAreaSelectList.add(new SelectOption('','--None--'));
        for(Schema.PicklistEntry p : Case_Detail__c.Primary_Reason__c.getDescribe().getPicklistValues())
            functionalAreaSelectList.add(new SelectOption(p.getValue(),p.getValue()));    
        
    }
    
    //Fetching All Contacts associate with Account
    Set<String> setActIds = new Set<String>();
    public void allContacts(){
        LIST<Contact> tempList;          
        if(setActIds != null && setActIds.size() > 0){
            lstContact = new LIST<SelectOption>();
            lstContact.add(new SelectOption('','--Select Contact--'));
            lstContact.add(new SelectOption('new','--Create New Contact--'));
            tempList = [Select id,firstname,lastname,email,phone,AccountId,title, owner.job_title__c from contact where accountId in : setActIds];
            if(tempList != null && tempList.size() > 0){
                for(Contact c : tempList){
                    String valu = c.id ;
                    String labl = c.firstname + ' ' +  c.lastname + ' | ' + c.phone + ' | ' + c.email;
                    lstContact.add(new SelectOption(valu,labl)); 
                }
            }
        }
        
        if(tObj.AccountId == null){    
            tObj.AccountId = (new LIST<String>(setActIds))[0];
            fetchContact();
        }
        //contactJson = JSON.serialize(tempList);
    }
   
    //Retrieve a Contact 
    public void fetchContact(){
        
        if(selContact == 'new' && caseId != null){
            if(tObj.SuppliedName != null){
                if(tObj.SuppliedName.trim().indexOf(' ') != -1){
                    con.firstname = tObj.SuppliedName != null ?tObj.SuppliedName.trim().subString(0,tObj.SuppliedName.trim().indexOf(' ')) :'';
                    con.lastname = tObj.SuppliedName != null ?tObj.SuppliedName.trim().subString(tObj.SuppliedName.trim().indexOf(' ')+1,tObj.SuppliedName.trim().length()) : '';
                }else{
                    con.lastname = tObj.SuppliedName != null ?tObj.SuppliedName.trim() :'' ;    
                } 
            }           
            con.email = tObj.SuppliedEmail;
            con.phone = tObj.SuppliedPhone;
            con.AccountId = tObj.AccountId;

            //Added By MB
            if(tObj.Email_Opt_In__c!=null || tObj.Telephone_Opt_In__c!=null){
                con.Email_Opt_In__c=tObj.Email_Opt_In__c;
                con.Telephone_Opt_In__c=tObj.Telephone_Opt_In__c;
            }
          
        }else if(selContact == 'new' && (caseId == null || caseId == '')){
            con = new contact();
        }else{
            LIST<Contact> tempConList = [Select id,firstname,lastname,email,phone,fax,AccountId,title,owner.job_title__c from contact where id =: selContact]; 
            if(tempConList != null &&  tempConList.size() > 0){
                con = tempConList[0];
            }
        } 
    }
    
    //Code for Cancel Button
    public PageReference cancelAction(){
        if(caseId != null){
            return new PageReference('/' + tObj.id);
        }
        return new PageReference('/home/home.jsp');
    }
    
    
    LIST<String> modelKeys ;
    //Code for filling Model List 
    public void fillModel(){
        if(modelList != null){
    		System.debug('& model list is null');
            modelList.clear();
        }
        System.debug('& lstOrder.. is null or lstOrder.size() : '+lstOrder.size());
        if(lstOrder != null && lstOrder.size() > 0 ){
            kys = new Set<String>();
            mapCompany = new Map<String,sObject>();
            modelList  = new LIST<OrderModel>();
            mapModelList = new Map<String,LIST<OrderModel>>();
            Integer i=0;
            setActIds =new Set<String>();
            for(LineItem__c line : lstOrder){
                OrderModel model = new OrderModel();
                model.flg = false;
                model.orderObj = line;
                model.orderObj.QuantityShipped__c = model.orderObj.QuantityShipped__c != null ?model.orderObj.QuantityShipped__c :0;
                model.orderObj.Quantity_Returned__c = model.orderObj.Quantity_Returned__c  != null ?model.orderObj.Quantity_Returned__c :0;
                
                model.media = tObj.Media__c != null ?tObj.Media__c : '';
                if(tObj.type == 'Credit Memo' || tObj.type == 'Credit Memo Request'){
                    model.creditlimit = '0.00';
                }else{
                    model.creditlimit = line.UnitPrice__c != null ?line.UnitPrice__c + ''  :'0.00';
                }
                system.debug('Type::'+tObj.type);
                if(tObj.type == 'RA' || tObj.type == 'RA Request'){
                    String ky = line.Accountid__c + '-' + line.Productid__c;
                    if(mapCaseDetail.containsKey(ky)){
                        model.RAStatus = 'Yes';    
                    }else{
                        model.RAStatus = 'No';
                    }
                }else if(tObj.type == 'Credit Memo'){
                    String ky = line.InvoiceNumber__c;
                    if(mapCaseDetailForCM.containsKey(ky)){
                        model.RAStatus = 'Yes';    
                    }else{
                        model.RAStatus = 'No';
                    }
                }
                model.idx = i;
                i++;
                kys.add(line.accountId__c);
                mapCompany.put(line.accountId__c,line );
                modelList.add(model);
                if(line.accountId__c != null){
                    setActIds.add(line.accountId__c);
                }
                if(mapModelList.containsKey(line.accountId__c)){
                    mapModelList.get(line.accountId__c).add(model); 
                    
                }else{
                    LIST<OrderModel> tempOrderList = new LIST<OrderModel>();
                    tempOrderList.add(model);
                    mapModelList.put(line.accountId__c, tempOrderList);
                }                
            }
            allContacts();
            if(mapModelList != null  && mapModelList.size() > 0 ){
                modelKeys = new LIST<String>();
                for(String s : mapModelList.keyset()){
                    modelKeys.add(s);    
                }
            }
            if(modelKeys != null && modelKeys.size() > 0){
                if(pageSize == null){
                    pageSize = 10;
                }
                totalPages = modelKeys.size() / pageSize;
                if(Math.mod(modelKeys.size(),pageSize)!= 0){
                    totalPages++;                
                } 
            }
           
            first();
        }
    }
    
    Map<String,LIST<Case_Detail__c>> mapCaseDetail = new Map<String,LIST<Case_Detail__c>>();
    Map<String,LIST<Case_Detail__c>> mapCaseDetailForCM = new Map<String,LIST<Case_Detail__c>>();
    
    //Search Order with Purchase Order
    public void searchOrder(){       
        String NQry = 'Select id,accountId__c,accountId__r.Return_requirements__c,CurrencyIsoCode,BUID__c,InvoiceNumber__c , Line__c, Productid__c,OrderNumber__c, PONumber__c, ProdNo__c,CompanyName__c,QuantityShipped__c, Quantity_Returned__c, UnitPrice__c, ShipDate__c,OrderType__c from LineItem__c where accountId__c != null and IsShiped__c = true and OrderType__c in(\'SO\',\'SR\',\'SW\',\'SA\')';
        
        if(tObj.PO_No__c != null && tObj.PO_No__c != ''){
            String poNo =tObj.PO_No__c ;    
            NQry += ' and PONumber__c =: poNo';
            
            system.debug(' poNo '+ poNo);
            /*if(tObj.AccountId != null || tObj.AccountId == ''){
                String actId = tObj.AccountId ;
                NQry += ' and AccountId__c =: actId';
                
            } */
            
            
            if(tempObj.OrderDate__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select form date...'));
                return ;
            }
    
            if(tempObj.CancelationDate__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select to date...'));
                return ; 
            }
    
            if(tempObj.CancelationDate__c <  tempObj.OrderDate__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'To Date must be greater than or equal to From date...'));
                return ; 
            }
    
    
            Date st = tempObj.OrderDate__c;
            Date ed = tempObj.CancelationDate__c;
            
            NQry += ' and (OrderDate__c  >=: st and OrderDate__c <=: ed) order by ShipDate__c desc' ;
             System.debug('NQry '+NQry );
            if(!isTesting){
                lstOrder = Database.query(NQry);
            
            fillMapCaseDetail();         
            fillModel();
            }
        }
           
        
    }
    
    //Search Order with AccountId
    public void searchOrderWithAccountId(){
        String NQry = 'Select id,accountId__c,accountId__r.Return_requirements__c,CurrencyIsoCode,BUID__c,InvoiceNumber__c , Line__c, Productid__c,OrderNumber__c, PONumber__c, ProdNo__c,CompanyName__c,QuantityShipped__c, Quantity_Returned__c, UnitPrice__c, ShipDate__c,OrderType__c from LineItem__c where accountId__c != null and IsShiped__c = true and OrderType__c in(\'SO\',\'SR\',\'SW\',\'SA\')';
        
        String qry ='Select count(id) cnt from LineItem__c where accountId__c != null and IsShiped__c = true and OrderType__c in(\'SO\',\'SR\',\'SW\',\'SA\')'; 
        if(tObj.AccountId != null || tObj.AccountId == ''){
            String actId = tObj.AccountId ;
            NQry += ' and AccountId__c =: actId';
            qry += ' and AccountId__c =: actId';
            if(tempObj.OrderDate__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select form date...'));
                return ;
            }
    
            if(tempObj.CancelationDate__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select to date...'));
                return ; 
            }
    
            if(tempObj.CancelationDate__c <  tempObj.OrderDate__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'To Date must be greater than or equal to From date...'));
                return ; 
            }
    
    
            Date st = tempObj.OrderDate__c;
            Date ed = tempObj.CancelationDate__c;
            
            //NQry += ' and (OrderDate__c  >=: st and OrderDate__c <=: ed)';
            NQry += ' and (ShipDate__c  >=: st and ShipDate__c <=: ed) order by ShipDate__c desc';
            //qry += ' and (OrderDate__c  >=: st and OrderDate__c <=: ed)';
            qry += ' and (ShipDate__c  >=: st and ShipDate__c <=: ed)';
            
            aggregateResult agRes = Database.query(qry);
            
            if((integer)agRes.get('cnt') > 1000){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'More than 1000 records found.. Please narrow search criteria.'));
                return ;    
            }else{
                lstOrder = Database.query(NQry);
            }
            fillMapCaseDetail();         
            fillModel(); 
            
        } 
        
    }
    
    public void settingPaperCreditFlag(){
        if(isCaseIdNull){
            if(tObj.type == 'Credit Memo'){
                isPaperCredit = true;
                fillCreditTypeList();
            }else{
                isPaperCredit = false;
            } 
        }
    }
    
    //Search Order with Invoice Number 
    public void searchOrderWithInvoice(){
        String NQry = 'Select id,accountId__r.Return_requirements__c,accountId__c,CurrencyIsoCode,BUID__c,InvoiceNumber__c , Line__c, Productid__c,OrderNumber__c, PONumber__c, ProdNo__c,CompanyName__c,QuantityShipped__c, Quantity_Returned__c, UnitPrice__c, ShipDate__c,OrderType__c from LineItem__c where accountId__c != null and IsShiped__c = true and OrderType__c in(\'SO\',\'SR\',\'SW\',\'SA\')';
        if(tObj.Gems_Invoice_Number__c != null && tObj.Gems_Invoice_Number__c  != ''){
            String inv = tObj.Gems_Invoice_Number__c ; //+ '%';
            NQry += ' and InvoiceNumber__c  =: inv';
            
            if(tempObj.OrderDate__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select form date...'));
                return ;
            }
    
            if(tempObj.CancelationDate__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select to date...'));
                return ; 
            }
    
            if(tempObj.CancelationDate__c <  tempObj.OrderDate__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'To Date must be greater than or equal to From date...'));
                return ; 
            }
    
    
            Date st = tempObj.OrderDate__c;
            Date ed = tempObj.CancelationDate__c;
            
            NQry += ' and (OrderDate__c  >=: st and OrderDate__c <=: ed) order by ShipDate__c desc';            
            lstOrder = Database.query(NQry);
            fillMapCaseDetail();      
            fillModel(); 
            
        }
           
    }
    
    //Search Order with Sales Order
    public void searchOrderWithSalesOrder(){
        String NQry = 'Select id,accountId__r.Return_requirements__c,CurrencyIsoCode,BUID__c,accountId__c,InvoiceNumber__c , Line__c, Productid__c,OrderNumber__c, PONumber__c, ProdNo__c,CompanyName__c,QuantityShipped__c, Quantity_Returned__c, UnitPrice__c, ShipDate__c,OrderType__c from LineItem__c where accountId__c != null and IsShiped__c = true and OrderType__c in(\'SO\',\'SR\',\'SW\',\'SA\')';
        if(tObj.Gems_SO_Number__c != null && tObj.Gems_SO_Number__c != ''){
            String soNo = tObj.Gems_SO_Number__c ; //+ '%';
            NQry += ' and OrderNumber__c  =: soNo';
            
            if(tempObj.OrderDate__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select from date...'));
                return ;
            }
    
            if(tempObj.CancelationDate__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select to date...'));
                return ; 
            }
    
            if(tempObj.CancelationDate__c <  tempObj.OrderDate__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'To Date must be greater than or equal to From date...'));
                return ; 
            }
    
    
            Date st = tempObj.OrderDate__c;
            Date ed = tempObj.CancelationDate__c;
            
            NQry += ' and (OrderDate__c  >=: st and OrderDate__c <=: ed) order by ShipDate__c desc';
            lstOrder = Database.query(NQry);
            fillMapCaseDetail();         
            fillModel(); 
        } 
        
          
          
    }
    
    //Search Order with Product Number
    public void searchOrderWithPartNumber(){
        String NQry = 'Select id,accountId__c,accountId__r.Return_requirements__c,CurrencyIsoCode,BUID__c,InvoiceNumber__c , Line__c, Productid__c,OrderNumber__c, PONumber__c, ProdNo__c,CompanyName__c,QuantityShipped__c, Quantity_Returned__c, UnitPrice__c, ShipDate__c,OrderType__c from LineItem__c where accountId__c != null and IsShiped__c = true and OrderType__c in(\'SO\',\'SR\',\'SW\',\'SA\')';
          if(tObj.productid__c != null ){    
             
            String prod = tObj.Productid__c;    //tempObj.productid__c;
            NQry += ' and Productid__c =: prod';    
            
            if(tempObj.OrderDate__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select form date...'));
                return ;
            }
    
            if(tempObj.CancelationDate__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select to date...'));
                return ; 
            }
    
            if(tempObj.CancelationDate__c <  tempObj.OrderDate__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'To Date must be greater than or equal to From date...'));
                return ; 
            }
    
            Date st = tempObj.OrderDate__c;
            Date ed = tempObj.CancelationDate__c;
            
            NQry += ' and (ShipDate__c  >=: st and ShipDate__c <=: ed) order by ShipDate__c desc';
            
            lstOrder = Database.query(NQry);
            fillMapCaseDetail();         
            fillModel(); 
        }
          
    }
    
    //Search Order by Date
    public void searchOrderByDate(){
        String NQry = 'Select id,accountId__c,accountId__r.Return_requirements__c,CurrencyIsoCode,BUID__c,InvoiceNumber__c , Line__c, Productid__c,OrderNumber__c, PONumber__c, ProdNo__c,CompanyName__c,QuantityShipped__c, Quantity_Returned__c, UnitPrice__c, ShipDate__c,OrderType__c from LineItem__c where accountId__c != null and IsShiped__c = true and OrderType__c in(\'SO\',\'SR\',\'SW\',\'SA\')';
        if(tempObj.OrderDate__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select form date...'));
            return ;
        }
        
        if(tempObj.CancelationDate__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select to date...'));
            return ; 
        }
        
        if(tempObj.CancelationDate__c <  tempObj.OrderDate__c){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'To Date must be greater than or equal to From date...'));
            return ; 
        }
        Date st = tempObj.OrderDate__c;
        Date ed = tempObj.CancelationDate__c;
        NQry += ' and (ShipDate__c  >=: st and ShipDate__c <=: ed) order by ShipDate__c desc';
 		lstOrder = Database.query(NQry);
        fillMapCaseDetail();
        fillModel();
    }    
    
    
    //Adding Case Detail Object 
    public PageReference addCaseDetail(){
        List<Attachment> tempAttachmentList = new List<Attachment>();
        Map<String,Attachment> attachmentToCDMAp = new Map<String,Attachment>();
        
        if(modelList == null || modelList.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill any search criteria and press Search Button.'));
            return null;                
        }
        
        if(lstContact.size() > 1&& (selContact == '' || selContact == null)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select Contact Informaton for Case.'));
            return null;     
        }
        
        if(selContact == 'new'){
            if(con.lastname == '' || con.lastname == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill LastName for Contact.'));
                return null; 
            }
        }
        
        system.debug(' caseId : '+ caseId);
        if(caseId == null){
            tObj.origin = 'Web';
            if(tObj.type == 'Credit Memo'){
                tObj.subject = 'Credit Memo Request';
            }
            if(!Test.isRunningTest()){
                LIST<RecordType> rType = [select id,name from RecordType where SObjectType='Case' order by name ];
                if(rType != null && rType.size() > 0 ){
                    /*if(tObj.type == 'Credit Memo'){
                        tObj.recordTypeId = rType[0].id;
                    }else{
                        tObj.recordTypeId = rType[1].id;    
                    }*/
                    for(RecordType rt : rType) {
                         if(tObj.type == 'Credit Memo' && rt.Name =='Credit Memo')
                         {
                             tObj.recordTypeId = rt.Id;
                             break;
                         }
                         else if(tObj.type == 'RA' && rt.Name=='RMA')
                         {
                         	tObj.recordTypeId = rt.Id;
                             break;
                         }
                     }
                }    
            }
            insert tObj;
            system.debug('AccountID : '+tObj.Account.Return_requirements__c+' Case ID : '+tObj.id);
            caseId = tObj.id;
        }
        settingPaperCreditFlag();
        List<Case_Detail__c> lstForLineNumber ;
        Integer lineNumber;
        String CurrencyIsoCode;
        if(caseId != null ){
            lstForLineNumber = [Select Line_Number__c from Case_Detail__c where case__c =: caseId order by Line_Number__c desc];
            
            if(lstForLineNumber != null && lstForLineNumber.size() > 0 ){
                lineNumber = Integer.valueOf(lstForLineNumber[0].Line_Number__c) + 1;
            }else{
                lineNumber = 1;
            }
        }
        String AccountId;
        if(isSpecialReturn){
             LIST<Case> tempCase =  [Select id,CaseNumber,AccountId from Case where id =: tObj.id];
             if(tempCase.get(0).AccountID != null)
                 AccountId = tempCase.get(0).AccountID;
             Case_Detail__c temp = new Case_Detail__c(name = tempCase[0].CaseNumber + ' - ' + lineNumber,Line_Number__c = lineNumber, Case__c = tobj.id,Special_Return_Type__c ='Government Return');                  
             insert temp;
             if(tObj.type == 'Credit Memo Request' || tObj.type == 'Credit Memo'){
                tObj.Type = 'Credit Memo';
            }else{
                tObj.Type = 'RA'; 
            }   
             update tObj;
        }else{
            LIST<Case_Detail__c> caseDetailList = new LIST<Case_Detail__c>();
            LIST<Case_Detail__c> existingLineItems = new LIST<Case_Detail__c>();
            LIST<LineItem__c> orders = new LIST<LineItem__c>();
            if(modelList.size() > 0 ){
                
                LIST<Case> tempCase =  [Select id,CaseNumber,AccountID from Case where id =: tObj.id];
                if(tempCase.get(0).AccountID != null)
                    AccountId = tempCase.get(0).AccountID;
                LIST<RecordType> recType ; 
                if(!Test.isRunningTest()){
                    recType = [select id from RecordType where SObjectType='Case_Detail__c' order by name];
                }
                
                for(OrderModel m : modelList){
                    if(m.flg){
                        Case_Detail__c temp = new Case_Detail__c();
                        temp.Case__c = caseId;
                        temp.Order_Shipment__c = m.orderObj.id;
                        temp.CurrencyIsoCode = m.orderObj.CurrencyIsoCode;
                        CurrencyIsoCode = m.orderObj.CurrencyIsoCode;
                        
                        if(tObj.type == 'Credit Memo' || tObj.type == 'Credit Memo Request'){
                            existingLineItems = [select id from Case_Detail__c where Order_Shipment__c =: m.orderObj.id and stage__c in ('Credit','Closed as Complete')];//case__c =: caseId
            				system.debug(' existingLineItems.size () : '+existingLineItems.size());
                            if(existingLineItems.size () >= 1)
                            {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Credit Memo cannot be created for same PO if another request is already in process'));
                                return null;      
                            }
                        }
                        if(!isPaperCredit){
                            if(m.qtyRet ==  null || m.qtyRet == 0){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Quantity value '));
                                return null;   
                            }
                            if(m.qtyRet >  (m.orderObj.QuantityShipped__c + m.orderObj.Quantity_Returned__c)){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity must be less than or equal to Quantity Shipped + Quantity Returned '));
                                return null;   
                            }
                            
                            if( m.orderObj.QuantityShipped__c < (m.orderObj.Quantity_Returned__c + m.qtyRet)){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Shipped Quantity can not be less than Quantity Returned + Quantity '));
                                return null;   
                            }
                            
                            if(m.media == null || m.media == ''){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill Media value '));
                                return null;    
                            }
                        }else{
                            if(m.creditlimit != '0.00' && Double.valueOf(m.creditlimit) > m.orderObj.UnitPrice__c  ){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Credit Per Unit cannot be grater then Unit Price '));
                                return null;    
                            }
                            
                            if(m.qtyRet != null && m.qtyRet >  m.orderObj.QuantityShipped__c ){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity cannot be grater then Quantity Shipped '));
                                return null;    
                            }
                            
                            if((m.functionArea==null || m.functionArea=='') && (m.tempCaseDetail.Reason_Code__c ==null) ){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a functional area and reason code.'));
                                return null;    
                            }
                        }
                        
                        temp.Customers_Eval_Expectation__c = m.tempCaseDetail.Customers_Eval_Expectation__c;
                        temp.Gems_to_provide__c = m.tempCaseDetail.Gems_to_provide__c;
                        temp.Quantity__c = m.qtyRet;
                        temp.name = tempCase[0].CaseNumber + ' - ' + lineNumber;
                        temp.Line_Number__c = lineNumber;
                        lineNumber++;
                        double unitP = m.orderObj.UnitPrice__c == null ?0.0 :m.orderObj.UnitPrice__c;
                        temp.Amount__c = (m.qtyRet *  double.valueOf(m.creditlimit));    //unitP );
                        temp.media__c = m.media;
                        
                        temp.Credit_per_unit__c = double.valueOf(m.creditlimit);    //m.creditlimit;
                       
                        
                        if(tObj.type == 'Credit Memo' || tObj.type == 'Credit Memo Request'){                          
                            temp.Credit_Type__c = m.creditType;
                            temp.Primary_Reason__c = m.tempCaseDetail.Primary_Reason__c;
                            temp.Reason_Code__c = m.tempCaseDetail.Reason_Code__c;
                        }else{
                            m.orderObj.Quantity_Returned__c +=  m.qtyRet;    
                        }
                        if(!Test.isRunningTest()){
                            if(recType != null && recType.size() > 0 ){
                                if(tObj.type == 'Credit Memo' || tObj.type == 'Credit Memo Request'){
                                    temp.recordTypeId = recType[0].id;
                                }else{
                                    temp.recordTypeId = recType[1].id;    
                                }
                            }
                        }
                        temp.productid__c = m.orderobj.productid__c;
                        orders.add(m.orderObj);
                        temp.Description_Problem__c = tObj.Description;
                        if(m.RAStatus == 'Yes'){
                            temp.Has_another_credit__c = true;    
                        }else{
                            temp.Has_another_credit__c = false;
                        }
                        caseDetailList.add(temp);
                        if(m.attachment.body != null)
                            attachmentToCDMAp.put(temp.Name,m.attachment);
                        system.debug('LI A : '+m.attachment.name+'----'+m.attachment.body+'---'+temp.Name);
                    }
                }
            }
            if(caseDetailList.size() > 0){
                Set<String> setCustomer = new Set<String>();
                for(LineItem__c li: orders){
                    setCustomer.add(li.Accountid__c);
                } 
                if(setCustomer.size() > 1){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can not approve RA request for 2 different customers.'));
                    return null;      
                }else{
                    insert caseDetailList;
                    for(Case_Detail__c cd : caseDetailList){
                        if(attachmentToCDMAp.get(cd.Name) != null && attachmentToCDMAp.get(cd.Name).body != null){
                            Attachment att = attachmentToCDMAp.get(cd.Name);
                            att.parentId = cd.Id;    
                            tempAttachmentList.add(att);
                            attachmentToCDMAp.remove(cd.Name);
                        }
                    }
                }
                attachmentToCDMAp.clear();
                
                if(orders.size() > 0 ){
                    update orders;
                }
                Case tCaseObj = new Case(id=caseId);
                
                //Assinging AccountId to Case Object same as Order Object AccountId
                if(orders[0].AccountId__c != tCaseObj.AccountId){
                    tCaseObj.AccountId = orders[0].AccountId__c;
                    AccountId = orders[0].AccountId__c;
                }else{
                    AccountId = tCaseObj.AccountId;
                }
                
                
                if(tCaseObj.contactId == null){
                    con.Accountid = tCaseObj.AccountId;
                    upsert con;
                    tCaseObj.contactId = con.id;
                }
                
                if(caseId != null && !isCaseIdNull){
                    if(tObj.type == 'Credit Memo Request' || tObj.type == 'Credit Memo'){
                        tCaseObj.Type = 'Credit Memo';
                    }else{
                        tCaseObj.Type = 'RA'; 
                    }
                        
                }
                
                if(internalcomment != null && internalcomment != ''){
                    CaseComment obj = new CaseComment();
                    obj.CommentBody = internalcomment;
                    obj.ParentId = tCaseObj.id;
                    insert obj;    
                }
                tCaseObj.CurrencyIsoCode = CurrencyIsoCode;
                tCaseObj.ownerId = UserInfo.getUserId();
                tCaseObj.Description = tObj.Description;
                update tCaseObj;
                modelList.clear();
                
                //Created by Ketan - 25/06/2016
                if(AccountId != null && mapCompany.get(AccountId) != null){
                    LineItem__c li = (LineItem__c)mapCompany.get(AccountId);

                    Account acc = [Select Id,Return_requirements__c From Account where Id = :AccountId];
                    acc.Return_requirements__c = li.accountId__r.Return_requirements__c;
                    try{
                        
                    update acc;
                    }
                    catch(Exception ex)
                    {
                        system.debug('Exception : '+ex.getMessage());
                    }
                }
                
                for(Attachment att :  atchList){
                    if(att.body != null){ 
                        att.parentId = tObj.id;   
                        tempAttachmentList.add(att);
                    } 
                }
                
                if(tempAttachmentList.size() > 0){
                    insert tempAttachmentList;
                }
                
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select at leaset one row...'));
                return null;    
            }
        }
        
        return new PageReference('/' + tObj.id);
    }
   
    public void fillMapCaseDetail(){
        Set<String> custIds = new Set<String>();
        Set<String> prodIds = new Set<String>();
        Set<String> invoiceNum = new Set<String>();
        mapCaseDetailForCM = new Map<String,List<Case_Detail__c>>();
        mapCaseDetail = new Map<String,List<Case_Detail__c>>();
        
        if(lstOrder.size() > 0){
            for(LineItem__c ordr : lstOrder){
                if(ordr.accountId__c != null){
                    custIds.add(ordr.accountId__c);
                }
                if(ordr.Productid__c != null){
                    prodIds.add(ordr.Productid__c);    
                }
                if(ordr.InvoiceNumber__c != null && ordr.InvoiceNumber__c != ''){
                    invoiceNum.add(ordr.InvoiceNumber__c);
                }
            }
        }
        if(custIds.size() > 0 && prodIds.size() > 0){
            for(Case_Detail__c cd : [select id , name, Credit_per_unit__c,Quantity__c, Order_Shipment__c,Stage__c,Case__r.Type,CreatedDate,Order_Shipment__r.Accountid__c, Order_Shipment__r.Productid__c  from Case_Detail__c where Order_Shipment__r.Accountid__c in : custIds and  Order_Shipment__r.Productid__c in : prodIds order by Case__r.Type asc,CreatedDate desc]){
                if(mapCaseDetail.containsKey(cd.Order_Shipment__r.Accountid__c + '-'+ cd.Order_Shipment__r.Productid__c)){
                    mapCaseDetail.get(cd.Order_Shipment__r.Accountid__c + '-'+ cd.Order_Shipment__r.Productid__c).add(cd); 
                    
                }else{
                    LIST<Case_Detail__c> tempCaseDetailList = new LIST<Case_Detail__c>();
                    tempCaseDetailList.add(cd);
                    mapCaseDetail.put(cd.Order_Shipment__r.Accountid__c + '-'+ cd.Order_Shipment__r.Productid__c, tempCaseDetailList);
                } 
            }   
        }
        if(invoiceNum.size() >0){
            for(Case_Detail__c cd : [select id , name,Invoice_Number__c, Credit_per_unit__c,Quantity__c, Order_Shipment__c,Stage__c,Case__r.Type,CreatedDate,Order_Shipment__r.Accountid__c, Order_Shipment__r.Productid__c  from Case_Detail__c where Invoice_Number__c IN :invoiceNum order by Case__r.Type asc,CreatedDate desc]){
                if(mapCaseDetailForCM.containsKey(cd.Invoice_Number__c)){
                    mapCaseDetailForCM.get(cd.Invoice_Number__c).add(cd); 
                }else{
                    LIST<Case_Detail__c> tempCaseDetailList = new LIST<Case_Detail__c>();
                    tempCaseDetailList.add(cd);
                    mapCaseDetailForCM.put(cd.Invoice_Number__c,tempCaseDetailList);
                } 
            }
        }
    }
    
    public Integer selRecord {get;set;}
    public void caseDetailsObject(){
        system.debug('--->'+ selRecord);
        system.debug('caseDetailsObject');
        lstCaseDetail = new LIST<Case_Detail__c>();
        if(tObj.type == 'Credit Memo'){
            String ky = modelList[selRecord].orderObj.InvoiceNumber__c;
            if(mapCaseDetailForCM.get(ky) != null)
                lstCaseDetail = mapCaseDetailForCM.get(ky);
        }
        if(tObj.type == 'RA' || tObj.type == 'RA Request'){
            String ky = modelList[selRecord].orderObj.AccountId__c + '-' + modelList[selRecord].orderObj.ProductId__c;
            lstCaseDetail = mapCaseDetail.get(ky);
        }
    }
    
    //Code For approve and send email functionality 
    public PageReference approveAndSendEmail(){
        PageReference  pg= addCaseDetail();
        if(pg != null){
            //return null;/*new PageReference('/apex/ShowCaseDetails?id='+ tObj.id)*/
            //gazi changed it back from return null on 9/26/2016 to make sure user can send email from the search page
            return new PageReference('/apex/ShowCaseDetails?id='+ tObj.id);
        }
        return null;
    }
    
    //public LIST<OrderModel> tempModelList {get;set;}
    public Map<String,LIST<OrderModel>> tempModelList1 {get;set;}
    public Integer pageSize {get;set;}
    public Integer totalpages {get;set;}
    public Integer pageNumber {get;set;}
    public Set<String> mapPagingRecordkyes {get;set;}
    public Integer rowidx {get;set;}
    
    //Code for Showing First Page according Pagination
    public void first(){
          
          tempModelList1 = new Map<String,LIST<OrderModel>>();
          mapPagingRecordkyes = new Set<String>();
          Integer i,lim=pageSize;
          System.debug('----> modelKeys ' +  modelKeys);
          if(modelKeys.size() < pageSize){
              lim = modelKeys.size();
          }
          for(i=0; i<lim; i++){
              if(mapModelList.containsKey(modelKeys[i])){
                 
                  tempModelList1.put(modelKeys[i], mapModelList.get(modelKeys[i]));
                  mapPagingRecordkyes.add(modelKeys[i]);
              }
          }
          rowidx=i;  
          
          pageNumber = 1;
    }
    
    //Code for Showing Last Page according Pagination
    public void last(){
          
          tempModelList1 = new Map<String,LIST<OrderModel>>();
          mapPagingRecordkyes = new Set<String>();
          
          Integer i=(modelKeys.size()/pageSize)*pageSize;
           
          if(modelKeys.size() == pageSize){
            rowidx=0;
            i=0;
          }
          for(Integer j=1; j<=math.mod(modelKeys.size(),pageSize); j++){
            if(mapModelList.containsKey(modelKeys[i])){
                 
                  tempModelList1.put(modelKeys[i], mapModelList.get(modelKeys[i]));
                  mapPagingRecordkyes.add(modelKeys[i]);
                  i++;
            }  
            
          } 
          
          if(tempModelList1.size() == 0){
              if(!Test.isRunningTest()){
                  i--;
              }
             if(mapModelList.containsKey(modelKeys[i])){
                  
                  tempModelList1.put(modelKeys[i], mapModelList.get(modelKeys[i]));
                  mapPagingRecordkyes.add(modelKeys[i]);
                  
            }     
          
          }
          rowidx=i; 
          pageNumber = totalPages;
          
    }
    
    
    //Code for Showing Previous Page according Pagination
    public void previous(){
        
        integer lim=pageSize;
          if(modelKeys.size() < pageSize){
              lim = modelKeys.size();
          }
          if(rowidx<lim  || pageNumber == 1 ){
              return;
          }
          tempModelList1 = new Map<String,LIST<OrderModel>>();
          Integer i,start;
          mapPagingRecordkyes = new Set<String>();
          if(rowidx-(lim*2)<= 0){
              start=0;              
              rowidx+=lim;              
              if(rowidx<=(lim*pageSize)){
                  rowidx-=lim;
              }
          }else{
              start=rowidx-(lim*2);              
          }
        pageNumber--;
        if(pageNumber <=0){
            pageNumber = 1;
        }
        
          /*if(pageNumber == totalPages -1){
                  start=rowidx-lim;
                  lim=0;
              }*/
          
          
          for(i=start; i<rowidx-lim; i++){
            //tempModelList.add(modelList[i]);
            if(mapModelList.containsKey(modelKeys[i])){
              tempModelList1.put(modelKeys[i], mapModelList.get(modelKeys[i]));
              mapPagingRecordkyes.add(modelKeys[i]);
            }
          }    
          rowidx=i; 
    }
    
    
    //Code for Showing Next Page according Pagination
    public void PNext(){
        //tempModelList.clear();
        tempModelList1 = new Map<String,LIST<OrderModel>>();
        mapPagingRecordkyes = new Set<String>();
        Integer i;
        integer lim=pageSize;
        if(modelKeys.size() < pageSize){
          lim = modelKeys.size();
        }
        if(modelKeys.size()<=lim){
            rowidx=0;
        }
        for(i=rowidx;i<rowidx+lim && i< modelKeys.size();i++){
            //tempModelList.add(modelList.get(i));
            if(mapModelList.containsKey(modelKeys[i])){
              tempModelList1.put(modelKeys[i], mapModelList.get(modelKeys[i]));
              mapPagingRecordkyes.add(modelKeys[i]);
            }
        }

        if(rowidx<modelKeys.size()-lim){
            rowidx = rowidx+lim;
        }
        
        pageNumber++;
        if(pageNumber >= totalPages){
          pageNumber = totalPages;
        } 
        
    }
    public String caseCommentBody {get;set;}
    public void addCaseComment(){
        CaseComment obj = new CaseComment();
        obj.CommentBody = caseCommentBody;
        obj.ParentId = tObj.id;
        insert obj;
        
    }
   
    //Model Class 
    public class OrderModel{
        public boolean flg {get;set;}
        public String media {get;set;}
        public Integer qtyRet {get;set;}
        public String creditlimit {get;set;}
        public LineItem__c orderObj {get;set;}
        public String creditType {get;set;}
        public String functionArea {get;set;}
        public Case_Detail__c tempCaseDetail {get;set;}
        public String RAStatus {get;set;}
        public Integer idx {get;set;}
        public Attachment attachment{get; set;}
        
        public OrderModel(){
            tempCaseDetail = new Case_Detail__c();
            attachment = new Attachment();
            tempCaseDetail.Customers_Eval_Expectation__c = 'RA Eval';
            tempCaseDetail.Gems_to_provide__c = 'RA Eval';
        }
        
    }
    
    
}