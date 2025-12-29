public class PreCallPlanController{
    public Account acc{get;set;}
    public Opportunity opp {get;set;}
    public Percall_Plan__c preCallPlan{get;set;}
    private Id accountId{get;set;}
    private Id oppId {get;set;}
    public LIST<String> lstOppFields {get;set;}
    public LIST<String> lstContactFields {get;set;}
    public LIST<Opportunity> lstOpps {get;set;}
    public LIST<Precall_Objective__c> lstObjectives {get;set;}
    public LIST<Precall_question__c> lstQuestions {get;set;}
    public LIST<Precall_Objection__c> lstObjections {get;set;}
    public LIST<Precall_Contact__c> lstContacts {get;set;}
    public LIST<Contact> lstAllContacts {get;set;} 
    public LIST<ContactModel> lstConModel {get;set;}
    
    public LIST<PreCallPlanContactModel> lstPreCallContactModel {get;set;}
    public LIST<CallObjectiveModel> lstCallObjectiveModel {get;set;}
    public LIST<KeyQuestionsNotesModel> lstKeyQuestionsModel {get;set;}
    public LIST<ObjectionModel> lstObjectionModel {get;set;}
    public LIST<TaskModel> lstTaskModel {get;set;}
    
    public String isNewPreCallPlanContact {get;set;}
    public String isNewCallObjective {get;set;}
    public String isNewQuestion {get;set;}
    public String isNewObjection {get;set;}
    public String isNewTask {get;set;}
    
    String preCallPlanId ; 
    String actId;
    Map<String,String> urlmap;
    public String linkToReport {get;set;}
    
    public boolean isRecordSaved {get;set;}
    public boolean isTripSummaryOn {get;set;}
    
    public String sections {get;set;}
    
    public Account actObj  {get;set;}
    public String productProducedModelBrandsText {get;set;}
    public String marketDriversSalesOutlookText {get;set;}
    public Decimal targetYTD {get;set;}
    public Decimal gapsVal {get;set;}
    public LIST<AccountPotentialModel> lstActPotentialModel {get;set;}
    public LIST<AccountPotentialModel> lstActPotentialModelMachineName {get;set;}
    public AccountPotentialModel actPotModelObj {get;set;}
    public String currentYear {get;set;}
    public String risksText {get;set;}
    public String curCode {get;set;}
    public LIST<SelectOption> lstReportsToContact {get;set;}
    public String reportsToValue {get;set;}
    Map<String,Contact> mapReportToContact = new Map<String,Contact>();
    public String orgChartDataInJson {get;set;}
    public LIST<ContactAndReportsToModel> lstreportToModel {get;set;}
    public Contact newConObj {get;set;}
    
    public list<OpportunityModel> oppModelList{get;set;}
    public string checkedPngUrl{get;set;}
    public string unCheckedPngUrl{get;set;}
    
    public time nextVisitTime{get;set;}
    public string nextVisitTimeSTR{get;set;}
    public contact conDateOfVisit{get;set;}
    public AccountInfoModel AIMObj{get;set;}
    //Constructor    
    public PreCallPlanController(ApexPages.StandardController sc){
        actObj = new Account();
        conDateOfVisit = new contact();
        List<Document> lstCheck = [ select id from document where name = 'checked_png' ];
        List<Document> lstunCheck = [ select id from document where name = 'unchecked_png' ];
        if( lstCheck.size() > 0 ){
            checkedPngUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+lstCheck[0].id+'&oid='+UserInfo.getOrganizationId();
        }
        if( lstunCheck.size() > 0 ){
            unCheckedPngUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+lstunCheck[0].id+'&oid='+UserInfo.getOrganizationId();
        }
        
        lstObjectives = new LIST<Precall_Objective__c>();
        lstQuestions = new LIST<Precall_question__c>();
        lstObjections = new LIST<Precall_Objection__c>();
        lstContacts = new LIST<Precall_Contact__c>();
        newConObj = new Contact();
        newConObj.LastName = 'LastName';
        lstOppFields = new LIST<String> {'Opp#','Opp Name', 'Opp Value', 'Stage','Product','Next Step','Close Date'};
        lstContactFields = new LIST<String> {'','','Internal Contact','Name','Email','Phone','DMU','Title','Reports To',  'Notes'};
        
        //Getting PrecallPlan Record
        Percall_Plan__c preCall = (Percall_Plan__c)sc.getRecord();
        //Populating PreCallPlan on the basis of PreCall
        isTripSummaryOn = false;
        if(preCall.Id != null){
            preCallPlan = [SELECT Convert_to_Post_Call__c,id,Name,Account__c,Date_of_last_visit__c,Date_of_Visit__c,Opportunity__c,Opportunity__r.id,
                            Products_Produced_Model_Brands__c,Market_Drivers_Sales_Outlook__c,
                            Product_Goal_1__c,Product_Goal_2__c,Product_Goal_3__c,
                            Revenue_Goal_1__c,Revenue_Goal_2__c,Revenue_Goal_3__c,Meeting_Address__c,account__r.ownerid,Situation_Update__c,
                            Has_Supplier_Scorecard__c,Trip_Summary__c,Risks__c,(Select id, Subject,OwnerId, ActivityDate,Status,Subject_Description__c,Description,whatId from Tasks) 
                            FROM Percall_Plan__c 
                            WHERE ID =: preCall.Id ];

            nextVisitTime = Time.newInstance(0, 0, 0, 0);            
            conDateOfVisit.birthdate = Date.newInstance(0, 0, 0);
            if( preCallPlan.Date_of_Visit__c != null ){
                conDateOfVisit.birthdate = Date.newInstance(preCallPlan.Date_of_Visit__c.year(),preCallPlan.Date_of_Visit__c.month(),preCallPlan.Date_of_Visit__c.day());
                nextVisitTime = preCallPlan.Date_of_Visit__c.time();
            }
            if(preCallPlan.Trip_Summary__c == null || preCallPlan.Trip_Summary__c == ''){
                //preCallPlan.Trip_Summary__c = '<b><u>Challenges to business: </u></b>   <br/><br/>  <b><u>History \\ Product Trends \\ Market Information: </u></b> <br/><br/> <b><u>Pocurement Information:</u></b> <br/><br/> <b><u>Key Takeaways:</u></b> <br/><br/>';   
                preCallPlan.Trip_Summary__c = '<b><u>Business \\ Market Conditions & Forecast: </u></b>   <br/><br/>  <b><u>VOC \\ Product Trends: </u></b> <br/><br/> <b><u>Opportunity Updates \\ Information:</u></b> <br/><br/> <b><u>Account Management Needs:</u></b> <br/><br/> <b><u>Other Account Information:</u></b> <br/><br/> <b><u>Key Takeaways \\ Key to Winning:</u></b> <br/><br/>';
            }
            
            accountId = preCallPlan.Account__c;
            oppId = preCallPlan.Opportunity__c;
            productProducedModelBrandsText = preCallPlan.Products_Produced_Model_Brands__c;
            marketDriversSalesOutlookText = preCallPlan.Market_Drivers_Sales_Outlook__c;
            risksText = preCallPlan.Risks__c;
            if(oppId != null){
                opp  = [select id,AccountId,Name,Opportunity_Number__c,Estimated_Amount__c,StageName,Product_Model__c,NextStep,CloseDate from Opportunity where id =: oppId LIMIT 1];
            }            
            fillAllObjects();
        }else{
            preCallPlan = new Percall_Plan__c(); 
            nextVisitTime = DateTime.now().Time();
            //preCallPlan.Trip_Summary__c = '<b><u>Challenges to business: </u></b>   <br/><br/>  <b><u>History \\ Product Trends \\ Market Information: </u></b> <br/><br/> <b><u>Pocurement Information:</u></b> <br/><br/> <b><u>Key Takeaways:</u></b> <br/><br/>';
            preCallPlan.Trip_Summary__c = '<b><u>Business \\ Market Conditions & Forecast: </u></b>   <br/><br/>  <b><u>VOC \\ Product Trends: </u></b> <br/><br/> <b><u>Opportunity Updates \\ Information:</u></b> <br/><br/> <b><u>Account Management Needs:</u></b> <br/><br/> <b><u>Other Account Information:</u></b> <br/><br/> <b><u>Key Takeaways \\ Key to Winning:</u></b> <br/><br/>';
                            
        }

        //Getting AccountId and OppId From URL
        urlmap = ApexPages.CurrentPage().getParameters();
        if(urlmap.size() > 0){
            for(String key : urlMap.keySet()){
                if(key.contains('_lkid')){
                    accountId = urlMap.get(key).startsWith('001') ? (Id)urlMap.get(key) : null;
                    oppId = urlMap.get(key).startsWith('006') ? (Id)urlMap.get(key) : null;
                }
            }
        }
        if(accountId == null){
            accountId = urlMap.get('actId')!= null && urlMap.get('actId')!= '' && urlMap.get('actId')!= 'null' ? (Id)urlMap.get('actId') : null;    
        }
        if(oppId == null){
            oppId = urlMap.get('opId')!= null && urlMap.get('opId')!= '' && urlMap.get('opId')!= 'null' ? (Id)urlMap.get('opId') : null;       
        }

        if(urlmap.get('id') == null){
            isRecordSaved = false;             
        }else{
            isRecordSaved = true;
        }
        
        //Populating Account on the basis of AccountId
        if(accountId != null){
            acc = [SELECT gap__c,Business_Unite__c,id,name,accountnumber,shippingstreet,shippingcity,shippingstate,shippingpostalcode,shippingcountry, description FROM Account WHERE Id =: accountId LIMIT 1];   
            linkToReport = 'https://boe.icgna.com:443/OpenDocument/opendoc/openDocument.jsp?iDocID=257606517&sType=wid&sRefresh=Y&sWindow=Same&lsSCustomer=' + acc.AccountNumber;
        }else if(oppId != null){
            opp = [select id,AccountId,Name,Opportunity_Number__c,Estimated_Amount__c,StageName,Product_Model__c,NextStep,CloseDate from Opportunity where id =: oppId LIMIT 1];
            acc = [SELECT gap__c,Business_Unite__c,id,name,accountnumber,shippingstreet,shippingcity,shippingstate,shippingpostalcode,shippingcountry, description FROM Account WHERE Id =: opp.AccountId LIMIT 1];   
            linkToReport = 'https://boe.icgna.com:443/OpenDocument/opendoc/openDocument.jsp?iDocID=257606517&sType=wid&sRefresh=Y&sWindow=Same&lsSCustomer=' + acc.AccountNumber;
        }
        actId = accountId != null ?accountId : opp.AccountId;
        
        //Set default address in metting address
        if(preCallPlan.id == null ){
            preCallPlan.Meeting_Address__c = acc.shippingStreet + ',' + acc.shippingCity + ',' + acc.shippingState;
        }
        
        //Code for Filling Contact Model List and LastVisitDate of Precall Plan Object
        fillConModel();
        initForFunnel();
        if(ApexPages.currentPage().getParameters().get('RecordType') == 'Precall Plan'){
            filllingLastVisitDateField();
        }
        
        //Memory Allocation For all ModelLists 
        lstPreCallContactModel  = new LIST<PreCallPlanContactModel>();
        lstCallObjectiveModel = new LIST<CallObjectiveModel>();
        lstKeyQuestionsModel = new LIST<KeyQuestionsNotesModel>();
        lstObjectionModel = new LIST<ObjectionModel>();
        lstTaskModel = new LIST<TaskModel>();
        mapPreCallContact = new Map<String,Precall_Contact__c>();

        //If the RecordType is 'Precall Plan' initializing Contact,Objective,Objection,Question & Task Model Lists
        if(ApexPages.currentPage().getParameters().get('RecordType') == 'Precall Plan' || ApexPages.currentPage().getParameters().get('id') != null){

            //Code for PreCallPlan Contacts Section
            if(lstContacts == null || lstContacts.size() == 0){
                //PreCallPlan Contact Model
                PreCallPlanContactModel preConMod = new PreCallPlanContactModel();
                preConMod.idx = 0;
                preConMod.preConObj= new Precall_Contact__c();
                preConMod.tempConObj = new Contact();
                preConMod.tempConObj.LastName = 'LastName';
                preConMod.tempConObj.Business_Unit__c = acc.Business_Unite__c;
                lstPreCallContactModel.add(preConMod);
                preConMod = new PreCallPlanContactModel();
                preConMod.idx = 1;
                preConMod.preConObj= new Precall_Contact__c();
                preConMod.tempConObj = new Contact();
                preConMod.tempConObj.LastName = 'LastName';
                preConMod.tempConObj.Business_Unit__c = acc.Business_Unite__c;
                lstPreCallContactModel.add(preConMod);
                isNewPreCallPlanContact = 'true';
            }else{
                integer i = 0 ;
                Map<String,Contact> mapContactFill = new Map<String,Contact>();
                Set<String> conIds = new Set<String>();
                for(Precall_Contact__c pc : lstContacts){
                    if(pc.Contact__c != null){
                        conIds.add(pc.Contact__c);
                    }
                }
                
                for(Contact c : [Select id, firstname,lastname,phone,email,Business_Unit__c,title,DMU__c from Contact where id in : conIds]){
                    mapContactFill.put(c.id, c);
                }
                for(Precall_Contact__c pc : lstContacts){
                    PreCallPlanContactModel preConMod = new PreCallPlanContactModel();
                    preConMod.idx = i++;
                    preConMod.preConObj= pc ;
                    if(pc.Contact__c == null){
                        preConMod.tempConObj = new Contact();
                        preConMod.tempConObj.FirstName = preConMod.preConObj.Name.substring(0,preConMod.preConObj.Name.indexOf(' '));    
                        preConMod.tempConObj.LastName = preConMod.preConObj.Name.substring(preConMod.preConObj.Name.indexOf(' ')+1); 
                        preConMod.tempConObj.Title = preConMod.preConObj.Title__c;   
                        preConMod.tempConObj.Email = preConMod.preConObj.Email__c;  
                        preConMod.tempConObj.Phone = preConMod.preConObj.Phone__c;      
                        preConMod.donotAddContact = true;    
                    }else{
                        preConMod.tempConObj = mapContactFill.get(pc.Contact__c);
                        preConMod.donotAddContact = false;
                    }
                    preConMod.notesText = pc.Notes__c;
                    preConMod.reportsToValue = preConMod.preConObj.ReportsTo__c;
                    lstPreCallContactModel.add(preConMod);
                }
                isNewPreCallPlanContact = 'false';
            }
            //Code for PreCallPlan Objectives Section
            if(lstObjectives.size() == 0){
                //Call Objective Model
                CallObjectiveModel md = new CallObjectiveModel();
                md.idx = 0;
                md.callObjectiveObj = new Precall_Objective__c();
                lstCallObjectiveModel.add(md);
                md = new CallObjectiveModel();
                md.idx = 1;
                md.callObjectiveObj = new Precall_Objective__c();
                lstCallObjectiveModel.add(md);
                isNewCallObjective = 'true';
            }else{
                Integer i=0;
                for(Precall_Objective__c pObj : lstObjectives){
                    CallObjectiveModel md = new CallObjectiveModel();
                    md.idx = i++;
                    md.callObjectiveObj = pObj;
                    md.objectiveText  = pObj.Objective__c;
                    md.PostCallComment = pObj.Post_Call_Comment__c;
                    lstCallObjectiveModel.add(md); 
                    isNewCallObjective = 'false';   
                }
            }
            
            //Code for PreCallPlan Question Section
            if(lstQuestions.size() == 0){
                //Key Questions Model
                KeyQuestionsNotesModel keymodel = new KeyQuestionsNotesModel();
                keymodel.idx = 0;
                keymodel.qstObj = new Precall_question__c();
                lstKeyQuestionsModel.add(keymodel);
                keymodel = new KeyQuestionsNotesModel();
                keymodel.idx = 1;
                keymodel.qstObj = new Precall_question__c();
                lstKeyQuestionsModel.add(keymodel);
                isNewQuestion = 'true';
            }else{
                integer i=0;
                for(Precall_question__c qst : lstQuestions){
                    KeyQuestionsNotesModel keymodel = new KeyQuestionsNotesModel();
                    keymodel.idx = i++;
                    keymodel.qstObj = qst;
                    keymodel.questions = qst.Question__c;
                    keymodel.notes = qst.Note__c;
                    lstKeyQuestionsModel.add(keymodel);
                    isNewQuestion = 'false';
                }
            }
            //Code for PreCallPlan Objection Section
            if(lstObjections.size() == 0 ){
                //Objection Model
                ObjectionModel objModel = new ObjectionModel();
                objModel.idx = 0 ;
                objModel.objectionObj  = new Precall_Objection__c();
                lstObjectionModel.add(objModel);
                objModel = new ObjectionModel();
                objModel.idx = 1 ;
                objModel.objectionObj  = new Precall_Objection__c();
                lstObjectionModel.add(objModel);
                isNewObjection = 'true';
            }else{
                integer i=0;
                for(Precall_Objection__c objet : lstObjections){
                    ObjectionModel objModel = new ObjectionModel();
                    objModel.idx = i++ ;
                    objModel.objectionObj  = objet;
                    objModel.objectionText = objet.Objection__c;
                    objModel.responseText = objet.response__c;
                    lstObjectionModel.add(objModel);  
                    isNewObjection = 'false';  
                }
            }
        }
        
        //Code for Task Section
        if(preCallPlan.Tasks.size() == 0){
            //Task model
            TaskModel tkmd = new TaskModel();
            tkmd.idx = 0;
            tkmd.taskObj = new Task();
            tkmd.taskObj.OwnerId = UserInfo.getUserId();
            tkmd.taskObj.Status = 'In Progress';
            lstTaskModel.add(tkmd);
            tkmd = new TaskModel();
            tkmd.idx = 1;
            tkmd.taskObj = new Task();
            tkmd.taskObj.OwnerId = UserInfo.getUserId();
            tkmd.taskObj.Status = 'In Progress';
            lstTaskModel.add(tkmd);
            isNewTask = 'true';
        }else{
            Integer i=0;
            for(Task tsk : preCallPlan.Tasks){
                TaskModel tkmd = new TaskModel();
                tkmd.idx = i++;
                tkmd.taskObj = tsk;
                tkmd.taskSubject = tsk.Subject;
                //tkmd.taskObj.OwnerId = UserInfo.getUserId();
                lstTaskModel.add(tkmd);
                isNewTask = 'false';
            }
        }
        
        //If RecordType is Account Plan  then fetching Account information,currenecy code and GEMS Revenue & Share for Account Potential
        lstMachineMatrixModel = new LIST<MachineMatrixModel>();        
        if(ApexPages.currentPage().getParameters().get('RecordType') == 'Account Plan' || ApexPages.currentPage().getParameters().get('id') != null){
            currentYear = System.today().year() + '';
            curCode = UserInfo.getDefaultCurrency();
            if(accountId == null){
                accountId = opp.AccountId;    
            }
            actObj = [select id,name,accountnumber,shippingstreet,shippingcity,shippingstate,shippingpostalcode,shippingcountry,
                     description,OwnerId,Owner.Name,Key_Account_Specialist__c,Market__c,Sub_Market__c,Customer_Classification__c,
                     Current_Year_Forecast__c,YTD_Sale__c,OTD_Goal__c,PPM_Goal__c ,Target_YTD__c, Gap__c,(select id,name,Estimated_Annual_Volume__c from Machines__r) 
                     from Account where id =: accountId];
             if(actObj != null){
                 if(actObj.Current_Year_Forecast__c != null){
                     targetYTD = ((actObj.Current_Year_Forecast__c * 12) / System.Today().month()).setScale(2);

                     if(actObj.YTD_Sale__c == null ){
                         actObj.YTD_Sale__c = 0;
                     }
                     gapsVal = actObj.Target_YTD__c != null ?actObj.YTD_Sale__c - actObj.Target_YTD__c : 0.0;
                     gapsVal = gapsVal.setScale(2);
                 }else{
                     targetYTD = 0.0;
                     gapsVal = 0.0;
                 }
                                  
                 if(!Test.isRunningTest()){                    
                     LIST<AggregateResult> agRes = [select Machine_Matrix__r.Account__c act, sum(Total_Rev_Per_Machine__c) totSum from Application__c where Machine_Matrix__r.Account__c =: actObj.id group by Machine_Matrix__r.Account__c];
                     LIST<AggregateResult> agResGEMS = [select Machine_Matrix__r.Account__c act, sum(Total_Rev_Per_Machine__c) totSum from Application__c where Machine_Matrix__r.Account__c =: actObj.id and Supplier__c = 'GEMS' group by Machine_Matrix__r.Account__c];
                     
                     actPotModelObj = new AccountPotentialModel();                     
                     if(agRes != null && agRes.size() > 0)
                         actPotModelObj.totalRevnue = ((Decimal) agRes[0].get('totSum')).setScale(2);
                     if(agResGEMS != null && agResGEMS.size() > 0)
                         actPotModelObj.gemsRev =  ((Decimal)   agResGEMS[0].get('totSum') ).setScale(2);
                     
                     if(actPotModelObj.totalRevnue != null && actPotModelObj.totalRevnue > 0 && actPotModelObj.gemsRev  != null && actPotModelObj.gemsRev  > 0 ){
                         actPotModelObj.gemsShare = ((actPotModelObj.gemsRev / actPotModelObj.totalRevnue) * 100).setScale(2);
                     }
                     else{
                         actPotModelObj.gemsShare = 0;
                     }
                 }
                 
                 accountPotentialCalculation();
                 accountPotentailCalculationByMachineName();
                 isMachineAdding = actObj.Machines__r.size() == 0 ? true : false; 
                                 
                 machineObj = new MachineMatrix__c();
                 machineObj.Account__c = actObj.id;
                            
             }
         }
         
        AIMObj = new AccountInfoModel();
        
        decimal temp = actObj.Target_YTD__c == null ?0:actObj.Target_YTD__c;
        AIMObj.TargetYTDTT = temp.format().contains('.') ? temp.format() : temp.format()+'.00';
        AIMObj.TargetYTD = convertCurrencyToKOrMFormat(temp);  
        temp = actObj.YTD_Sale__c ;
        temp = temp == null ? 0 : temp;
        AIMObj.YTDSaleTT = temp.format().contains('.') ? temp.format() : temp.format()+'.00';
        AIMObj.YTDSale = convertCurrencyToKOrMFormat(temp); 
        temp = actObj.Gap__c;
        temp = temp == null ? 0 : temp;
        AIMObj.GapTT = temp.format().contains('.') ? temp.format() : temp.format()+'.00';
        AIMObj.Gap = convertCurrencyToKOrMFormat(temp); 
        temp = actObj.Current_Year_Forecast__c;
        temp = temp == null ? 0 : temp;
        AIMObj.CurrentYearForecastTT = temp.format().contains('.') ? temp.format() : temp.format()+'.00';
        AIMObj.CurrentYearForecast = convertCurrencyToKOrMFormat(temp); 

         fillTripReportModel();
         creatingOrgChartData();
         initForAttachments();
         fecthGemsUsers();
    }
    
    public class AccountInfoModel{
        public string CurrentYearForecast{get;set;}
        public string CurrentYearForecastTT{get;set;}
        public string TargetYTD{get;set;}
        public string YTDSale{get;set;}
        public string Gap{get;set;}
        public string TargetYTDTT{get;set;}
        public string YTDSaleTT{get;set;}
        public string GapTT{get;set;}
    }
    
    /*Functionality for meeting Attendees start here*/
    public list<GemsUserModal> gemsUsrList{get;set;}
    public void fecthGemsUsers(){
        Set<String> idsOfuserInPercallCon = new Set<String>();
        for( Precall_Contact__c preConObj : [ select id,Gems_Contact__c from Precall_Contact__c where Percall_Plan__c =: preCallPlan.id AND Gems_Contact__c != null ]){
            idsOfuserInPercallCon.add( preConObj.Gems_Contact__c );
        }
        gemsUsrList = new list<GemsUserModal>();
        for( user usrObj : [select id,email,firstname,lastname,Title,name from user where isActive=true order by name] ){
            GemsUserModal GUMObj = new GemsUserModal();
            GUMObj.usrObj = usrObj;
            GUMObj.isChecked = idsOfuserInPercallCon.contains(usrObj.id);
            GUMObj.isPrevChecked = idsOfuserInPercallCon.contains(usrObj.id);
            gemsUsrList.add(GUMObj);
        }
    }
    
    public void saveGemsContactUser(){
        list<Precall_Contact__c> preConInst = new list<Precall_Contact__c>();
        for( GemsUserModal GUMObj : gemsUsrList ){
            if( GUMObj.isChecked && !GUMObj.isPrevChecked ){
                Precall_Contact__c preConObj = new Precall_Contact__c();
                preConObj.Name = GUMObj.usrObj.name;
                preConObj.Email__c = GUMObj.usrObj.email;
                preConObj.Title__c = GUMObj.usrObj.title;
                preConObj.Percall_Plan__c = preCallPlan.id;
                preConObj.Gems_Contact__c = GUMObj.usrObj.id;
                preConInst.add(preConObj);
            }
        }
        if( preConInst.size() > 0 ){
            insert preConInst;
        }
    }
        
    public class GemsUserModal{
        public boolean isChecked{get;set;}
        public boolean isPrevChecked{get;set;}
        public user usrObj{get;set;}
    }
    /*Functionality for meeting Attendees End here*/
    
    /*Funnel section start here*/
    public boolean isFunnelEdit{get;set;}
    public class OpportunityModel{
        public boolean isChecked{get;set;}
        public boolean isPrevChecked{get;set;}
        public Opportunity oppObj{get;set;}
    }
    
    public List<OpportunityModelFunnel> lstOppFunnel{get;set;}
    public void initForFunnel(){
        isFunnelEdit = false;
        lstOppFunnel = new List<OpportunityModelFunnel>();
        Map<String,string> mapOfPreOpp = new Map<String,string>();
        for( Precall_Opportunity__c preOppObj : [ select id,Account_Percall_Plan__c,Opportunity__c from Precall_Opportunity__c where Account_Percall_Plan__c =: preCallPlan.id ] ){
            mapOfPreOpp.put( preOppObj.Opportunity__c, preOppObj.id );
        }
        
        lstOpps = [select id,AccountId,Name,Opportunity_Number__c,Estimated_Amount__c,StageName,Product_Model__c,NextStep,CloseDate from Opportunity where AccountId =: actId and StageName != 'Closed Lost' and StageName != 'Closed Won'];
        oppModelList = new list<OpportunityModel>();
        for( Opportunity oppObj : lstOpps ){
            OpportunityModelFunnel OPMF = new OpportunityModelFunnel();
            decimal temp = oppObj.Estimated_Amount__c;
            temp = temp == null ? 0 : temp;
            OPMF.EstimatedAmountTT = temp.format().contains('.') ? temp.format() : temp.format()+'.00' ;
            OPMF.EstimatedAmount = convertCurrencyToKOrMFormat(temp);            
            OPMF.oppObj = oppObj;
            lstOppFunnel.add(OPMF);
            
            OpportunityModel OMObj = new OpportunityModel();
            OMObj.oppObj = oppObj;
            if( mapOfPreOpp.get(oppObj.id) != null ){
                OMObj.isChecked = true;
                OMObj.isPrevChecked = true;
            }else{
                OMObj.isChecked = false;
                OMObj.isPrevChecked = false;
            }
            oppModelList.add(OMObj);
        }
    }
    
    private string convertCurrencyToKOrMFormat(Decimal temp){
        String INKM = '';
        if( temp > 1000000 ){                
            temp = temp/1000000;
            INKM = temp.setScale(2)+'M';
        }
        else if( temp > 1000 ){
            temp = temp/1000;
            INKM = temp.setScale(2)+'K';
        }else{
            INKM = temp+'';
        }
        return INKM;
    }
    
    public class OpportunityModelFunnel{
        public Opportunity oppObj{get;set;}
        public string EstimatedAmount{get;set;}
        public string EstimatedAmountTT{get;set;}
    }
    
    public void goToEditForFunnel(){
        isFunnelEdit = true;
    }
    
    public void saveFunnelOpp(){
        List<Precall_Opportunity__c> instList = new List<Precall_Opportunity__c>();
        for( OpportunityModel OMObj : oppModelList ){
            if( OMObj.isChecked && !OMObj.isPrevChecked ){
                Precall_Opportunity__c PreObj = new Precall_Opportunity__c();
                PreObj.Account_Percall_Plan__c = preCallPlan.id;
                PreObj.Opportunity__c = OMObj.oppObj.id;
                instList.add(PreObj);
            }
        }                
        if(instList.size() > 0 ){
            insert instList;
        }                
        initForFunnel();
    }

    /*Funnel section end here*/
    private void creatingOrgChartData(){
        orgChartDataInJson = '[';
        LIST<OrgChartDataModel> lstOrgChartDataModel = new LIST<OrgChartDataModel>();
        LIST<Contact> tempConList =  [select id,Name, Phone,email,ReportsToId,title,DMU__c from Contact where accountId =: actId];       
        Map<String,OrgChartDataModel> mapContactForOrgChart = new Map<String,OrgChartDataModel>();
        Integer i=2;        
        for(Contact con : tempConList ){
            OrgChartDataModel md = new OrgChartDataModel();
            md.id = i++ +'';
            md.conObj = con;
            lstOrgChartDataModel.add(md); 
            mapContactForOrgChart.put(con.id, md);          
        }
        
        LIST<OrgCharDataModelWithParent> tempList = new LIST<OrgCharDataModelWithParent>();
        OrgCharDataModelWithParent rootNode = new OrgCharDataModelWithParent();
        rootNode.id = '1';
        string Conname = acc.Name;
        if( acc.Name.length() > 28 ){
            Conname = Conname.subString(0,28)+'..';
        }
        rootNode.name = '<div style="width:100%;height:100%;"><a title="'+acc.Name+'" href="/'+acc.id+'" target="_blank">'+ Conname + '</a></div>';
        rootNode.parent = '0';        
        tempList.add(rootNode);
        
        for(OrgChartDataModel conMd : lstOrgChartDataModel){
            String conColor = 'white';
            String fontColor = 'black';
            if( conMd.conObj.DMU__c == 'Gems Friend' ){
                conColor= 'green';
                fontColor = 'white';
            }else if( conMd.conObj.DMU__c == 'Gems Foe' ){
                conColor= 'red';
                fontColor = 'white';
            }else if( conMd.conObj.DMU__c == 'Mixed' ){
                conColor= 'yellow';
                fontColor = 'black';
            }
            
            OrgCharDataModelWithParent temp = new OrgCharDataModelWithParent();
            temp.id = conMd.id;
            Conname = conMd.conObj.name;
            if( conMd.conObj.name.length() > 14 ){
                Conname = Conname.subString(0,14)+'..';
            }
            String title = '';
            if( conMd.conObj.title != null ){
                title = conMd.conObj.title;
                if( conMd.conObj.title .length() > 14 ){
                    title = conMd.conObj.title.subString(0,14)+'..';
                }
                temp.name ='<div style="padding-top: 1px;border-radius: 3px;width:100%;height:100%;background:'+conColor+';"><a title="'+conMd.conObj.name+' ('+conMd.conObj.title+ ')" style="color:'+fontColor+'" href="/'+conMd.conObj.id+'" target="_blank">'+ Conname + '\n\r(' + title + ')</a></div>';
            }else{
                temp.name ='<div style="padding-top: 1px;border-radius: 3px;width:100%;height:100%;background:'+conColor+';"><a title="' +conMd.conObj.name+ '" style="color:'+fontColor+'" href="/'+conMd.conObj.id+'" target="_blank">'+ Conname + '</a></div>';
            }
            
            
            if(conMd.conObj.reportsToId  == null){
                temp.parent = '1';    
            }else{
                temp.parent =  mapContactForOrgChart.get(conMd.conObj.reportsToId).id ;
            }
            tempList.add(temp);
        }
        orgChartDataInJson = JSON.serialize(tempList);
    }
    
    
    //Code for Account Potential Calculation by Machine Name
    private void accountPotentailCalculationByMachineName(){
        lstactPotentialModelMachineName = new LIST<AccountPotentialModel>();                
        map<String,Decimal> mapOfProFamliyAndAccountPot = new map<String,Decimal>();
        map<String,Decimal> mapOfProFamliyGemsRev = new map<String,Decimal>();
        for( Application__c  app : [select Machine_Matrix__r.name,Supplier__c ,Machine_Matrix__r.Estimated_Annual_Volume__c,Product_Family__c,Total_Rev_Per_Machine__c from Application__c where Machine_Matrix__r.Account__c =: actObj.id ] ){
            Decimal calc = 0;
            if( mapOfProFamliyAndAccountPot.get(app.Machine_Matrix__r.name) != null ){
                calc = mapOfProFamliyAndAccountPot.get(app.Machine_Matrix__r.name) + (app.Total_Rev_Per_Machine__c * app.Machine_Matrix__r.Estimated_Annual_Volume__c);
            }else{
                calc = (app.Total_Rev_Per_Machine__c * app.Machine_Matrix__r.Estimated_Annual_Volume__c);
            }
            mapOfProFamliyAndAccountPot.put(app.Machine_Matrix__r.name,calc);
            
            Decimal gemsRev = 0;
            if( mapOfProFamliyGemsRev.get(app.Machine_Matrix__r.name) != null ){                
                if( app.Supplier__c == 'GEMS' ){
                    gemsRev = mapOfProFamliyGemsRev.get(app.Machine_Matrix__r.name) + ( app.Total_Rev_Per_Machine__c * app.Machine_Matrix__r.Estimated_Annual_Volume__c);
                }else{
                    gemsRev = mapOfProFamliyGemsRev.get(app.Machine_Matrix__r.name);
                }
            }
            else{
                if( app.Supplier__c == 'GEMS' ){
                    gemsRev = ( app.Total_Rev_Per_Machine__c * app.Machine_Matrix__r.Estimated_Annual_Volume__c);
                }else{
                    gemsRev = 0;
                }
            }
            mapOfProFamliyGemsRev.put(app.Machine_Matrix__r.name,gemsRev);
        }
        
        for( String proF : mapOfProFamliyGemsRev.keySet() ){
            AccountPotentialModel AMD = new AccountPotentialModel();
            AMD.MachineName = proF;
            AMD.totalRevnue = mapOfProFamliyAndAccountPot.get(proF).setScale(2);
            Decimal temp = mapOfProFamliyAndAccountPot.get(proF).setScale(2);
            temp = temp == null ? 0 : temp;
            AMD.StrtotalRevnueTT = temp.format().contains('.') ? temp.format() : temp.format()+'.00' ;
            AMD.StrtotalRevnue = convertCurrencyToKOrMFormat(temp);            
            AMD.gemsRev = mapOfProFamliyGemsRev.get(proF).setScale(2);
            temp = mapOfProFamliyGemsRev.get(proF).setScale(2);
            temp = temp == null ? 0 : temp;
            AMD.StrgemsRevTT = temp.format().contains('.') ? temp.format() : temp.format()+'.00' ;
            AMD.StrgemsRev = convertCurrencyToKOrMFormat(temp);
            Decimal AccountPotVal = mapOfProFamliyAndAccountPot.get(proF)== 0 ? 1 : mapOfProFamliyAndAccountPot.get(proF);
            AMD.gemsShare = ( ( mapOfProFamliyGemsRev.get(proF)/ AccountPotVal ) * 100 ).setScale(2);
            lstactPotentialModelMachineName.add(AMD);
        }        
    } 
    
    //Code for Account Potential Calculation by Product Family 
    private void accountPotentialCalculation(){
        lstactPotentialModel = new LIST<AccountPotentialModel>();                        
        
        map<String,Decimal> mapOfProFamliyAndAccountPot = new map<String,Decimal>();
        map<String,Decimal> mapOfProFamliyGemsRev = new map<String,Decimal>();
        for( Application__c  app : [select Supplier__c ,Machine_Matrix__r.Estimated_Annual_Volume__c,Product_Family__c,Total_Rev_Per_Machine__c from Application__c where Machine_Matrix__r.Account__c =: actObj.id ] ){
            Decimal calc = 0;
            if( mapOfProFamliyAndAccountPot.get(app.Product_Family__c) != null ){
                calc = mapOfProFamliyAndAccountPot.get(app.Product_Family__c) + (app.Total_Rev_Per_Machine__c * app.Machine_Matrix__r.Estimated_Annual_Volume__c);
            }else{
                calc = (app.Total_Rev_Per_Machine__c * app.Machine_Matrix__r.Estimated_Annual_Volume__c);
            }
            mapOfProFamliyAndAccountPot.put(app.Product_Family__c,calc);
            
            Decimal gemsRev = 0;
            if( mapOfProFamliyGemsRev.get(app.Product_Family__c) != null ){                
                if( app.Supplier__c == 'GEMS' ){
                    gemsRev = mapOfProFamliyGemsRev.get(app.Product_Family__c) + ( app.Total_Rev_Per_Machine__c * app.Machine_Matrix__r.Estimated_Annual_Volume__c);
                }else{
                    gemsRev = mapOfProFamliyGemsRev.get(app.Product_Family__c);
                }
            }
            else{
                if( app.Supplier__c == 'GEMS' ){
                    gemsRev = ( app.Total_Rev_Per_Machine__c * app.Machine_Matrix__r.Estimated_Annual_Volume__c);
                }else{
                    gemsRev = 0;
                }
            }
            mapOfProFamliyGemsRev.put(app.Product_Family__c,gemsRev);
        }
        
        for( String proF : mapOfProFamliyGemsRev.keySet() ){
            AccountPotentialModel AMD = new AccountPotentialModel();
            AMD.productFamily = proF;
            AMD.totalRevnue = mapOfProFamliyAndAccountPot.get(proF).setScale(2);
            Decimal temp = mapOfProFamliyAndAccountPot.get(proF).setScale(2);
            temp = temp == null ? 0 : temp;
            AMD.StrtotalRevnueTT = temp.format().contains('.') ? temp.format() : temp.format()+'.00' ;
            AMD.StrtotalRevnue = convertCurrencyToKOrMFormat(temp);
            AMD.gemsRev = mapOfProFamliyGemsRev.get(proF).setScale(2);
            temp = mapOfProFamliyGemsRev.get(proF).setScale(2);
            temp = temp == null ? 0 : temp;
            AMD.StrgemsRevTT = temp.format().contains('.') ? temp.format() : temp.format()+'.00' ;
            AMD.StrgemsRev = convertCurrencyToKOrMFormat(temp);
            Decimal AccountPotVal = mapOfProFamliyAndAccountPot.get(proF) == 0 ? 1 : mapOfProFamliyAndAccountPot.get(proF) ;
            AMD.gemsShare = ( ( mapOfProFamliyGemsRev.get(proF) / AccountPotVal ) * 100 ).setScale(2);
            lstactPotentialModel.add(AMD);
        }        
    }
    
    
    //Code for filling TripReortModelList on basis of RecordType
    public LIST<TripReportModel> lstTripReportModel {get;set;}
    public Map<String,String> mapSectionNames {get;set;}
    String preCallPlanRecordType ;
    private void fillTripReportModel(){
        
        lstTripReportModel = new LIST<TripReportModel>();
        Map<String,String> urlParameters  = ApexPages.CurrentPage().getParameters();
        RecordType recType ;
        if(urlParameters.size() > 0){
            if(urlParameters.containsKey('RecordType')){
                //recType  = [Select id,Name from RecordType where id =: urlParameters.get('RecordType') LIMIT 1]; 
                preCallPlanRecordType =  urlParameters.get('RecordType');     
                if(preCallPlanRecordType != null && preCallPlanRecordType  == 'Precall Plan'){
                    lstTripReportModel = new LIST<TripReportModel>();
                    lstTripReportModel.add(new TripReportModel(true,  'Account over view', 'aov'));
                    lstTripReportModel.add(new TripReportModel(true,  'Situation  Update', 'su'));
                    lstTripReportModel.add(new TripReportModel(true,  'Funnel', 'fn'));
                    lstTripReportModel.add(new TripReportModel(true,  'Precall Contact' ,'pc'));
                    lstTripReportModel.add(new TripReportModel(true,  'Call Objective/Agenda' ,'obs'));
                    lstTripReportModel.add(new TripReportModel(true,  'Precall Questions' , 'qst'));
                    lstTripReportModel.add(new TripReportModel(true,  'Precall Objections' , 'objet'));
                    lstTripReportModel.add(new TripReportModel(true,  'Precall Other Key Actions' ,'ka'));                
                    lstTripReportModel.add(new TripReportModel(true,  'Trip Summary' ,'tp'));
                }else if(preCallPlanRecordType  != null && preCallPlanRecordType  == 'Account Plan'){
                    lstTripReportModel = new LIST<TripReportModel>();
                    lstTripReportModel.add(new TripReportModel(true,  'GEMS Revenue' , 'gr'));
                    lstTripReportModel.add(new TripReportModel(true,  'Quality & Delivery ' , 'qd'));    
                    lstTripReportModel.add(new TripReportModel(true,  'Account Potential' , 'ap'));
                    lstTripReportModel.add(new TripReportModel(true,  'Funnel' , 'fn'));
                    lstTripReportModel.add(new TripReportModel(true,  'Gems Current Strategy & Goals ', 'cs'));
                    lstTripReportModel.add(new TripReportModel(true,  'Risks ', 'rs'));
                    lstTripReportModel.add(new TripReportModel(true,  'Other Key Actions ', 'ka'));
                }    
            }else{
                Percall_Plan__c tempObj = [select id, recordTypeId from Percall_Plan__c where id =:urlParameters.get('id') LIMIT 1] ;
                if(tempObj!= null){
                    recType  = [Select id,Name from RecordType where id =: tempObj.recordTypeId LIMIT 1];       
                    preCallPlanRecordType =  recType.Name;
                    if(recType != null && recType.Name == 'Precall Plan'){
                        lstTripReportModel = new LIST<TripReportModel>();
                        lstTripReportModel.add(new TripReportModel(true,  'Account over view', 'aov'));
                        lstTripReportModel.add(new TripReportModel(true,  'Situation  Update', 'su'));
                        lstTripReportModel.add(new TripReportModel(true,  'Funnel', 'fn'));
                        lstTripReportModel.add(new TripReportModel(true,  'Precall Contact' ,'pc'));
                        lstTripReportModel.add(new TripReportModel(true,  'Call Objective/Agenda' ,'obs'));
                        lstTripReportModel.add(new TripReportModel(true,  'Precall Questions' , 'qst'));
                        lstTripReportModel.add(new TripReportModel(true,  'Precall Objections' , 'objet'));
                        lstTripReportModel.add(new TripReportModel(true,  'Precall Other Key Actions' ,'ka'));    
                        lstTripReportModel.add(new TripReportModel(true,  'Trip Summary' ,'tp'));
                    }else if(recType != null && recType.Name == 'Account Plan'){
                        lstTripReportModel = new LIST<TripReportModel>();
                        lstTripReportModel.add(new TripReportModel(true,  'GEMS Revenue' , 'gr'));
                        lstTripReportModel.add(new TripReportModel(true,  'Quality & Delivery ' , 'qd'));    
                        lstTripReportModel.add(new TripReportModel(true,  'Account Potential' , 'ap'));
                        lstTripReportModel.add(new TripReportModel(true,  'Funnel' , 'fn'));
                        lstTripReportModel.add(new TripReportModel(true,  'Gems Current Strategy & Goals ', 'cs'));
                        lstTripReportModel.add(new TripReportModel(true,  'Risks ', 'rs'));
                        lstTripReportModel.add(new TripReportModel(true,  'Othere Key Actions ', 'ka'));                      
                    }
                }
            }
        }
        
        LIST<String> sectionList = ApexPages.currentPage().getParameters().get('sectnames') != null && ApexPages.currentPage().getParameters().get('sectnames') != '' ?ApexPages.currentPage().getParameters().get('sectnames').split(',') : null;
        mapSectionNames = new Map<String,String>();
        
        if(sectionList  != null && sectionList.size() > 0){
            for(String sc : sectionList){
                mapSectionNames.put(sc , 'true');    
            }
            
            if(lstTripReportModel != null && lstTripReportModel.size() > 0){
                for(TripReportModel trp : lstTripReportModel){
                    if(!mapSectionNames.containsKey(trp.sectionAbr)){
                        mapSectionNames.put(trp.sectionAbr, 'false');    
                    }
                }
            }            
        }else{
            if(lstTripReportModel != null && lstTripReportModel.size() > 0){
                for(TripReportModel trp : lstTripReportModel){
                    if(!mapSectionNames.containsKey(trp.sectionAbr)){
                        mapSectionNames.put(trp.sectionAbr, 'false');    
                    }
                }
            }    
        }
    }
    
    //Code for enabling TripSummary Section
    public void editTripSummary(){
        isTripSummaryOn = true;
    }
    
    //Code for disabling TripSummary Section
    public void cancelTripSummary(){
        isTripSummaryOn = false;
    }
    
    //Code for Saving TripSummary Section
    public string postcallError{get;set;}
    public void saveTripSummary(){         
        postcallError = '';
        //Checking for previous Convert_to_Post_Call__c is false and current Convert_to_Post_Call__c is true
        List<Percall_Plan__c> lstPrecPlanTemp = [select id,Convert_to_Post_Call__c from Percall_Plan__c where id=:preCallPlan.id];
        if( lstPrecPlanTemp[0].Convert_to_Post_Call__c == false && preCallPlan.Convert_to_Post_Call__c ){
            for( Precall_Objective__c  PreObj : lstObjectives ){
                if( PreObj.Post_Call_Comment__c == '' || PreObj.Post_Call_Comment__c == null ){
                    preCallPlan.Convert_to_Post_Call__c = false;
                    postcallError = 'Error: Post-Call Comments are required on Call Objective / Agenda and Key Questions to Ask section before converting to post call.';
                    break;
                }
            }
            
            for( Precall_question__c PreQues : lstQuestions ){
                if( PreQues.Note__c == '' || PreQues.Note__c == null ){
                    preCallPlan.Convert_to_Post_Call__c = false;
                    postcallError = 'Error: Post-Call Comments are required on Call Objective / Agenda and Key Questions to Ask section before converting to post call.';
                    break;
                }
            }
            
        }
        if( postcallError == '' ){
            update preCallPlan;
            isTripSummaryOn = false;
        }
        
        //Logic for create notes in opportunities : Code By Vishnu on 27-9-2015
        Set<String> CheckedOppIds = new Set<String>();        
        for( OpportunityModel OMObj : oppModelList ){
            if( OMObj.isChecked ){                
                CheckedOppIds.add(OMObj.oppObj.id);
            }
        }
        Map<String,Note> MapOfOppIdAndNote = new Map<String,Note>();
        String[] filters = new String[]{ '%'+preCallPlan.id+'%'};
        for( Note notObj : [select Title,ParentId from Note where parentid in : CheckedOppIds And title like : filters ] ){
            MapOfOppIdAndNote.put( notObj.parentId,notObj );
        }
        List<Note> lstOfNoteToInsNUps = new List<Note>();
        for( string strId : CheckedOppIds ){
            Note notObj;
            if( MapOfOppIdAndNote.get(strId) == null ){
                notObj = new Note();
                notObj.ParentId = strId;                
            }else{
                notObj = MapOfOppIdAndNote.get(strId);
            }
            notObj.Title = 'Pre call plan trip summary : ' + preCallPlan.id;
            notObj.Body = preCallPlan.Trip_Summary__c.stripHtmlTags();
            lstOfNoteToInsNUps.add(notObj);
        }
        if( lstOfNoteToInsNUps.size() > 0 ){
            upsert lstOfNoteToInsNUps;
        }
        
    }
    
    
    //Code for Passing Sections code for Opening PDF Page
    public void openPDFPage(){
        
        sections = '';
        if(lstTripReportModel != null && lstTripReportModel.size() > 0){
            for(TripReportModel trp : lstTripReportModel){
                if(trp.isShow){
                    sections += trp.sectionAbr + ',' ;
                }
            }
        }
        //Removing last comma from the sections varriable
        sections = sections != '' ?sections.substring(0,sections.length()-1) :sections;
        
        /*if(preCallPlanRecordType  == 'Precall Plan'){
            //pg = new PageReference('/apex/PreCallPlanPDFPage?id=' + preCallPlan.id + '&sectnames=' + sections ); 
            //pg.setRedirect(true);   
        }else if(preCallPlanRecordType  == 'Account Plan'){
             //pg = new PageReference('/apex/AccountPlanPDFPage?id=' + preCallPlan.id + '&sectnames=' + sections);
             //pg.setRedirect(true);
        }
        //pg.setRedirect(true);*/
        //return null;
    }
    
    
    //Code for Checking RecordType and Redirecting control to the Related Page
    public PageReference checkingRecordTypes(){
        Map<String,String> urlParameters  = ApexPages.CurrentPage().getParameters();
        RecordType recType ;
        PageReference pg;
        if(urlParameters.size() > 0){
            if(urlParameters.containsKey('RecordType')){
                recType  = [Select id,Name from RecordType where id =: urlParameters.get('RecordType') LIMIT 1];       
                if(recType != null && recType.Name == 'Precall Plan'){
                    pg = new PageReference('/apex/PreCallPlanPageNew?opId=' + oppId + '&actId=' + accountId + '&retURL=' + urlParameters.get('retURL') + '&RecordType=' + recType.Name);
                    pg.setRedirect(true);
                }else if(recType != null && recType.Name == 'Account Plan'){
                    pg = new PageReference('/apex/AccountPlanPageNew?opId=' + oppId + '&actId=' + accountId + '&retURL=' + urlParameters.get('retURL') + '&RecordType=' + recType.Name);
                    pg.setRedirect(true);
                }
                return pg;
            }else{
                Percall_Plan__c tempObj = [select id, recordTypeId from Percall_Plan__c where id =:urlParameters.get('id') LIMIT 1] ;
                if(tempObj!= null){
                    recType  = [Select id,Name from RecordType where id =: tempObj.recordTypeId LIMIT 1];       
                    if(recType != null && recType.Name == 'Precall Plan'){
                        pg = new PageReference('/apex/PreCallPlanPageNew?opId=' + oppId + '&id='+ urlParameters.get('id') + '&actId=' + accountId + '&retURL=' + urlParameters.get('retURL'));
                        //pg.getParameters().put('nooverride','1');
                        pg.setRedirect(true);
                    }else if(recType != null && recType.Name == 'Account Plan'){
                        pg = new PageReference('/apex/AccountPlanPageNew?opId=' + oppId + '&id='+ urlParameters.get('id') + '&actId=' + accountId + '&retURL=' + urlParameters.get('retURL'));    
                        //pg.getParameters().put('sfdc.override','1');                    
                        pg.setRedirect(true);                    
                    }
                }
                return pg;
            }
        }
        return null;
        
    }
    
    //Code for enabling Precall Plan section for editing
    public void editPreCallPlan(){
        isRecordSaved = false;
    }
    
    //Code for Filling LastVisitDate for Precall Plan Object for RecordType 'Precall Plan'
    private void filllingLastVisitDateField(){
        LIST<Percall_Plan__c> tempObj ; 
        RecordType recType = [select id from RecordType where name='Precall Plan' and SObjectType = 'Percall_Plan__c' LIMIT 1];
        if(recType != null){
            if(urlmap.get('id') != null){
                tempObj = [select id,Date_of_Visit__c,Date_of_last_visit__c,Meeting_Address__c from Percall_Plan__c where id =: urlmap.get('id') and recordTypeId =: recType.id];    
                if(tempObj != null && tempObj.size() > 0){
                    preCallPlan.Date_of_last_visit__c = tempObj[0].Date_of_last_visit__c;    
                }
            }else{
                if(accountId != null){
                    tempObj = [select id,Date_of_Visit__c from Percall_Plan__c where Account__c =: accountId and recordTypeId =: recType.id and Date_of_Visit__c !=null order by Date_of_Visit__c desc];  
                }else if(oppId != null){                    
                    tempObj = [select id,Date_of_Visit__c from Percall_Plan__c where Opportunity__c =: oppId and recordTypeId =: recType.id and Date_of_Visit__c !=null order by Date_of_Visit__c desc];      
                }                
                if(tempObj != null && tempObj.size() > 0 ){
                    preCallPlan.Date_of_last_visit__c = tempObj[0].Date_of_Visit__c;    
                }
            }
        }
    }
    
    //Code for Showing AccountPage
    public PageReference openAccount(){
        return new PageReference('/'+acc.id);    
    }
    
    //Code for Showing OpportunityPage
    public PageReference openOpportunity(){
        return new PageReference('/'+opp.id);    
    }
    
    //Code for Showing Account/Precall Page
    public PageReference openPreCallPlan(){
        return new PageReference('/'+preCallPlan.id);    
    }
    
    //Code for Adding New Row in ContactModel
    boolean isAddingContact;
    public void addingMorePreCallPlanContactModel(){
        PreCallPlanContactModel preConMod = new PreCallPlanContactModel();
        preConMod.idx = lstPreCallContactModel.size();
        preConMod.preConObj= new Precall_Contact__c();
        preConMod.tempConObj = new Contact();
        preConMod.tempConObj.LastName = 'LastName';
        preConMod.tempConObj.Business_Unit__c = acc.Business_Unite__c;
        lstPreCallContactModel.add(preConMod);
        isAddingContact = true;
    }
    
    //Canceling the added row in Contact Model
    public void cancelMoreContact(){
        if(isAddingContact){
            lstPreCallContactModel.remove(lstPreCallContactModel.size()-1);
            isAddingContact = false;
        }
    }
    
    //Code for Adding New Row in CallObjectiveModel
    boolean isAddingObjective;
    public void addingMoreCallObjectiveModel(){
        CallObjectiveModel md = new CallObjectiveModel();
        md.idx = lstCallObjectiveModel.size();
        md.callObjectiveObj = new Precall_Objective__c();
        lstCallObjectiveModel.add(md);
        isAddingObjective = true;
    }
    
    //Canceling the added new row in CallObjectiveModel
    public void cancelMoreObjective(){
        if(isAddingObjective){
            lstCallObjectiveModel.remove(lstCallObjectiveModel.size()-1);
            isAddingObjective = false;
        }
    }
    
    //Code for Adding New Row in KeyQuestionNotesModel
    boolean isAddingQuestion;
    public void addingMoreQuestions(){
        KeyQuestionsNotesModel keymodel = new KeyQuestionsNotesModel();
        keymodel.idx = lstKeyQuestionsModel.size();
        keymodel.qstObj = new Precall_question__c();
        lstKeyQuestionsModel.add(keymodel);
        isAddingQuestion = true;
    }
    
    //Canceling the added new row in KeyQuestionNotesModel
    public void cancelMoreQuestions(){
        if(isAddingQuestion){
            lstKeyQuestionsModel.remove(lstKeyQuestionsModel.size()-1);
            isAddingQuestion = false;
        }    
    }
    
    //Code for Adding new row in ObjectionModel 
    boolean isAddingObjection;
    public void addingMoreObjections(){
        ObjectionModel objModel = new ObjectionModel();
        objModel.idx = lstObjectionModel.size();
        objModel.objectionObj  = new Precall_Objection__c();
        lstObjectionModel.add(objModel); 
        isAddingObjection = true;   
    }
    
    //Canceling added new row in ObjectionModel
    public void cancelMoreObjection(){
        if(isAddingObjection){
            lstObjectionModel.remove(lstObjectionModel.size()-1);
            isAddingObjection = false;
        }
    }
    
    
    //Code for Adding new row in taskModel
    boolean isAddingTask;
    public void addingMoreTask(){
        TaskModel tkmd = new TaskModel();
        tkmd.idx = lstTaskModel.size();
        tkmd.taskObj = new Task();
        tkmd.taskObj.OwnerId = UserInfo.getUserId();
        tkmd.taskObj.Status = '';
        lstTaskModel.add(tkmd);    
        isAddingTask = true;
    }
    
    //Canceling added new row in taskmodel
    public void cancelMoreTask(){
        if(isAddingTask){
            lstTaskModel.remove(lstTaskModel.size() - 1);
            isAddingTask = false;
        }
    }
    
    //Filling Contact Model List with Contacts available for AccountId
    public List<SelectOption> lstDMUSelOpt{get;set;}
    private void fillConModel(){
        lstDMUSelOpt = new List<SelectOption>();
        lstDMUSelOpt.add(new selectOption('',''));
        lstDMUSelOpt.add(new selectOption('Gems Friend','Gems Friend'));
        lstDMUSelOpt.add(new selectOption('Mixed','Mixed'));
        lstDMUSelOpt.add(new selectOption('Gems Foe','Gems Foe'));
        lstDMUSelOpt.add(new selectOption('Unknown','Unknown'));
        
        lstReportsToContact = new LIST<SelectOption>();
        lstreportToModel = new LIST<ContactAndReportsToModel>();
        lstAllContacts = [select id,Title,Name,Email,phone,ReportsTo.Name,ReportsToId,DMU__c from Contact where AccountId =: actId  order by Name];        
        //Vishnu 1
        lstConModel = new LIST<ContactModel>();
        integer i= 0; 
        lstReportsToContact.add(new SelectOption('','--None--'));
        for(Contact con : lstAllContacts){
            ContactModel model = new ContactModel();
            model.idx = i++;
            if(mapPreCallContact != null && mapPreCallContact.containskey(con.id)){
                model.flg = true;    
            }else{
                model.flg = false;
            }           
            
            model.conObj = con;
            lstConModel.add(model);
            lstReportsToContact.add(new SelectOption(con.id, con.Name));
            mapReportToContact.put(con.id,con);
            ContactAndReportsToModel tempReportsTo = new ContactAndReportsToModel();
            tempReportsTo.conObj = con;
            tempReportsTo.reportsToId = con.ReportsToId;
            lstreportToModel.add(tempReportsTo);
            
        }
        
    }
    
    //Code for filling PrecallPlan,Precall Contact,Precall Objective,Precall Question,Precall Objection and Task Model Data
    Map<String,Precall_Contact__c> mapPreCallContact ;
    private void fillAllObjects(){
        mapPreCallContact = new Map<String,Precall_Contact__c>();
        if(preCallPlan != null){
            preCallPlan = [SELECT Convert_to_Post_Call__c,id,Name,Account__c,Date_of_last_visit__c,Date_of_Visit__c,Opportunity__c,Opportunity__r.id,
                            Products_Produced_Model_Brands__c,Market_Drivers_Sales_Outlook__c,
                            Product_Goal_1__c,Product_Goal_2__c,Product_Goal_3__c,
                            Revenue_Goal_1__c,Revenue_Goal_2__c,Revenue_Goal_3__c,Meeting_Address__c,account__r.ownerid,Situation_Update__c,
                            Has_Supplier_Scorecard__c,Trip_Summary__c,Risks__c,(Select id, Subject,OwnerId, ActivityDate,Status,Subject_Description__c,Description,whatId from Tasks) 
                            FROM Percall_Plan__c 
                            WHERE ID =: preCallPlan.Id];
                            
            if(preCallPlan.Trip_Summary__c == null || preCallPlan.Trip_Summary__c == ''){
                //preCallPlan.Trip_Summary__c = '<b><u>Challenges to business: </u></b>   <br/><br/>  <b><u>History \\ Product Trends \\ Market Information: </u></b> <br/><br/> <b><u>Pocurement Information:</u></b> <br/><br/> <b><u>Key Takeaways:</u></b> <br/><br/>';
                preCallPlan.Trip_Summary__c = '<b><u>Business \\ Market Conditions & Forecast: </u></b>   <br/><br/>  <b><u>VOC \\ Product Trends: </u></b> <br/><br/> <b><u>Opportunity Updates \\ Information:</u></b> <br/><br/> <b><u>Account Management Needs:</u></b> <br/><br/> <b><u>Other Account Information:</u></b> <br/><br/> <b><u>Key Takeaways \\ Key to Winning:</u></b> <br/><br/>';
            }
                            
            lstObjectives = [Select Post_Call_Comment__c,id,name,Objective__c,Percall_Plan__c from Precall_Objective__c where Percall_Plan__c =: preCallPlan.id order by Name];
                
            lstQuestions = [select id,name,Note__c,Question__c from Precall_question__c where Percall_Plan__c =: preCallPlan.id order by Name];
            
            lstObjections = [select id,name, Objection__c, Response__c from Precall_Objection__c where Percall_Plan__c =: preCallPlan.id order by Name];
            
            lstContacts =  [select id,Name, title__c, Notes__c,Contact__c,Contact__r.id,Email__c,Phone__c,ReportsTo__c,Contact__r.DMU__c from Precall_Contact__c where  Percall_Plan__c =: preCallPlan.id];

            mapPreCallContact = new Map<String,Precall_Contact__c>();
            if(lstContacts != null && lstContacts.size() > 0){
                for(Precall_Contact__c preCallCon : lstContacts){
                    mapPreCallContact.put(preCallCon.contact__c,preCallCon);
                }
            }
        }
    }
    
    
    //Code for Saving AccountPlan 
    public PageReference saveAccountPlan(){
        if(preCallPlan.Name == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please specify Pre-Call Plan Name.....'));
            return null;            
        }else{
            RecordType recType = [Select id from RecordType where Name = 'Account Plan' and SObjectType = 'Percall_Plan__c'];
            if(preCallPlan.id == null){    
                if(accountId != null){
                    preCallPlan.Account__c = actId;    
                }
                if(oppId != null){
                    preCallPlan.Account__c = actId;  
                    preCallPlan.Opportunity__c = oppId;    
                }
            }
            preCallPlan.Products_Produced_Model_Brands__c = productProducedModelBrandsText;
            preCallPlan.Market_Drivers_Sales_Outlook__c = marketDriversSalesOutlookText;
            preCallPlan.recordTypeId = recType.id;
            preCallPlan.Risks__c = risksText; 
            
            upsert preCallPlan;
            update actObj; 
            
            if(actObj.Current_Year_Forecast__c != null){
                targetYTD = ((actObj.Current_Year_Forecast__c * 12) / System.Today().month()).setScale(2);
                if(actObj.YTD_Sale__c == null ){
                     actObj.YTD_Sale__c = 0;
                 }
                gapsVal = (actObj.YTD_Sale__c != null ?actObj.YTD_Sale__c - targetYTD : 0.0).setScale(2);
            }else{
                targetYTD = 0.0;
                gapsVal = 0.0;
            }
              
            isRecordSaved = true;
            return null;
        } 
        
        return null;
    }
    
    //Code for Saving PrecallPlan Object
    public PageReference savePreCallPlan(){
        //Need to make time
        Integer hour = 0;        
        Integer minute = 0 ;
        
        try{
            hour = Integer.valueOf( nextVisitTimeSTR.substring(0,nextVisitTimeSTR.indexOf(':')) );        
            if( nextVisitTimeSTR.contains('AM') ){
                minute = Integer.valueOf( nextVisitTimeSTR.substring(nextVisitTimeSTR.indexOf(':')+1,nextVisitTimeSTR.indexOf('AM')).trim() );
            }
            if( nextVisitTimeSTR.contains('PM') ){
                minute = Integer.valueOf( nextVisitTimeSTR.substring(nextVisitTimeSTR.indexOf(':')+1,nextVisitTimeSTR.indexOf('PM')).trim());
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error : Incorrect time.'));
            return null;   
        }
        nextVisitTime = Time.newInstance(hour, minute, 0, 0);
        if(conDateOfVisit.birthdate == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please specify Pre-Call Plan Visit Date.....'));
            return null;    
        }
        preCallPlan.Date_of_Visit__c = DateTime.newInstance(conDateOfVisit.birthdate, nextVisitTime);
        if(preCallPlan.Name == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please specify Pre-Call Plan Name.....'));
            return null;            
        }else if(preCallPlan.Date_of_Visit__c == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please specify Pre-Call Plan Visit Date.....'));
            return null;    
        }else if(preCallPlan.Date_of_Visit__c <= preCallPlan.Date_of_last_visit__c ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Visit Date must be greater than Last Visit Date.....'));
            return null;
        }else{
            RecordType recType = [Select id from RecordType where Name = 'Precall Plan' and SObjectType = 'Percall_Plan__c'];
            if(preCallPlan.id == null){    //urlmap.get('id') == null){
                if(accountId != null){
                    preCallPlan.Account__c = actId;    
                }else if(oppId != null){
                    preCallPlan.Account__c = actId;  
                    preCallPlan.Opportunity__c = oppId;    
                }
                preCallPlan.recordTypeId = recType.id;
            }
            
            upsert preCallPlan;
            nextVisitTime = Time.newInstance(0, 0, 0, 0);
            if( preCallPlan.Date_of_Visit__c != null ){
                conDateOfVisit.birthdate = Date.newInstance(preCallPlan.Date_of_Visit__c.year(),preCallPlan.Date_of_Visit__c.month(),preCallPlan.Date_of_Visit__c.day());
                nextVisitTime = preCallPlan.Date_of_Visit__c.time();
            }
            update acc;
            PageReference pg = urlmap.get('retURL') != null ?new PageReference('/'+urlmap.get('retURL')) : null; 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Pre-Call Plan Record Saved......!!!!!'));
            
            lstContacts =  [select id,Name, title__c, Notes__c,Contact__c,Contact__r.id,Email__c,Phone__c,ReportsTo__c,Contact__r.DMU__c from Precall_Contact__c where  Percall_Plan__c =: preCallPlan.id];
            isRecordSaved = true;
        }
        return null;    
            
    }
    
    //Code for Canceling the Page and Return to the page where we come (Account/Opportunity)
    public PageReference cancelPage(){
        String returningURL ;          
        PageReference pg = urlmap.get('retURL') != null ?new PageReference('/'+urlmap.get('retURL')) : null;
        
        if(pg == null || urlmap.get('retURL') == 'null' ){
            if(oppId != null){
                pg = new PageReference('/'+oppId);   
            }else if(accountId != null){
                 pg = new PageReference('/'+accountId);   
            }
        }
        return pg;
    }
    
    //Code for saving Precall Contact and Contact also
    public void savePreCallPlanContact(){
        LIST<Precall_Contact__c> savePreCallPlanContactList = new  LIST<Precall_Contact__c>();
        List<Contact> saveContactList = new List<Contact>();
        if(lstPreCallContactModel != null && lstPreCallContactModel.size() > 0 ){
            for(PreCallPlanContactModel preConModel : lstPreCallContactModel){                
                if(preConModel.tempConObj.FirstName != null && preConModel.tempConObj.FirstName != '' && 
                    preConModel.tempConObj.LastName != null && preConModel.tempConObj.LastName != '' && preConModel.tempConObj.LastName != 'LastName' &&
                    preConModel.tempConObj.Email != null && preConModel.tempConObj.Email != '' && preConModel.donotAddContact == false){
                    
                    preConModel.tempConObj.AccountId = accountId; 
                    if(preConModel.reportsToValue != '' && mapReportToContact.containsKey(preConModel.reportsToValue)){
                        preConModel.tempConObj.ReportsToId = mapReportToContact.get(preConModel.reportsToValue).id ;
                    }else{
                        preConModel.tempConObj.ReportsToId = null;    
                    }
                    preConModel.tempConObj.Business_Unit__c = acc.Business_Unite__c;
                    saveContactList.add(preConModel.tempConObj);
                }
            }

            //Saving Contact Object             
            Map<String, Contact> mapContact = new Map<String,Contact>();
            if(saveContactList != null && saveContactList.size() > 0){
                upsert saveContactList;
                for(Contact c : saveContactList){
                    String ky = c.FirstName + c.LastName + c.Email;
                    mapContact.put(ky , c);
                }
            }
            //Code for Saving Precall Contact Object
            for(PreCallPlanContactModel preConModel : lstPreCallContactModel){
                if(preConModel.tempConObj.FirstName != null && preConModel.tempConObj.FirstName != '' && 
                    preConModel.tempConObj.LastName != null && preConModel.tempConObj.LastName != '' && preConModel.tempConObj.LastName != 'LastName' &&
                    preConModel.tempConObj.Email != null && preConModel.tempConObj.Email != ''){
                        String ky = preConModel.tempConObj.FirstName + preConModel.tempConObj.LastName + preConModel.tempConObj.Email;
                        if(mapContact.containsKey(ky)){
                            Contact cn = mapContact.get(ky);
                            preConModel.preConObj.Name = cn.FirstName + ' ' + cn.LastName ;
                            preConModel.preConObj.Title__c = cn.title;
                            preConModel.preConObj.Email__c = cn.email;
                            preConModel.preConObj.Phone__c = cn.Phone;
                            preConModel.preConObj.Contact__c = cn.id;
                            preConModel.preConObj.ReportsTo__c = cn.ReportsToId;
                            preConModel.preConObj.Notes__c = preConModel.notesText;
                            if(preConModel.preConObj.id == null)
                                preConModel.preConObj.Percall_Plan__c = preCallPlan.id;
                            savePreCallPlanContactList.add(preConModel.preConObj);
                        }else if(preConModel.donotAddContact){
                            preConModel.preConObj.Name = preConModel.tempConObj.FirstName + ' ' + preConModel.tempConObj.LastName ;
                            preConModel.preConObj.Title__c = preConModel.tempConObj.title;
                            preConModel.preConObj.Email__c = preConModel.tempConObj.email;
                            preConModel.preConObj.Phone__c = preConModel.tempConObj.Phone;
                            preConModel.preConObj.Contact__c = null;
                            preConModel.preConObj.Notes__c = preConModel.notesText;
                            if(preConModel.preConObj.id == null)
                                preConModel.preConObj.Percall_Plan__c = preCallPlan.id;
                            savePreCallPlanContactList.add(preConModel.preConObj);
                        }
                        
                    }
            }
            
            if(savePreCallPlanContactList.size() > 0){
                upsert savePreCallPlanContactList;
            }
            //fillAllObjects();
            
            //Code for Filling Precall Contact Model List with the saved records
            lstContacts =  [select id,Name, title__c, Notes__c,Contact__c,Contact__r.id,Email__c,Phone__c,ReportsTo__c, Contact__r.DMU__c from Precall_Contact__c where  Percall_Plan__c =: preCallPlan.id];
            mapPreCallContact = new Map<String,Precall_Contact__c>();
            if(lstContacts != null && lstContacts.size() > 0){
                for(Precall_Contact__c preCallCon : lstContacts){
                    mapPreCallContact.put(preCallCon.contact__c,preCallCon);
                }
            }
            fillConModel();
            
            if(savePreCallPlanContactList.size() > 0){
                Set<String> conIdSet = new Set<String>();
                for(Precall_Contact__c pc : savePreCallPlanContactList){
                    if(pc.Contact__c != null){
                        conIdSet.add(pc.Contact__c);
                    }
                } 
                mapContact.clear();
                for(Contact  c : [select id, title, Firstname, lastname, email, phone, Business_Unit__c,ReportsToId,DMU__c from contact where id in : conIdSet]){
                    mapContact.put(c.id, c);
                }
                lstPreCallContactModel.clear();
                integer i=0;
                for(Precall_Contact__c pc : savePreCallPlanContactList){
                    PreCallPlanContactModel pModel = new PreCallPlanContactModel ();
                    pModel.idx = i++;
                    pModel.preConObj = pc ;
                    if(pc.Contact__c == null){
                        pModel.tempConObj = new Contact();
                        pModel.tempConObj.FirstName = pModel.preConObj.Name.substring(0,pModel.preConObj.Name.indexOf(' '));    
                        pModel.tempConObj.LastName = pModel.preConObj.Name.substring(pModel.preConObj.Name.indexOf(' ')+1); 
                        pModel.tempConObj.Title = pModel.preConObj.title__c;  
                        pModel.tempConObj.Email = pModel.preConObj.Email__c;  
                        pModel.tempConObj.Phone = pModel.preConObj.Phone__c;   
                        pModel.donotAddContact = true;
                    }else{
                        pModel.tempConObj = mapContact.get(pc.Contact__c);    //pc.Contact__r.FirstName + pc.Contact__r.LastName + pc.Contact__r.Email);
                        pModel.donotAddContact = false;
                    }                   
                    pModel.notesText = pc.notes__c;
                    pModel.reportsToValue = pModel.preConObj.ReportsTo__c;
                    lstPreCallContactModel.add(pModel);
                }    
            }
        }
        
        creatingOrgChartData();
    }
    
    //Code for Saving Precall Contact with available/existing Contacts
    public void saveContact(){
        saveGemsContactUser();
        fecthGemsUsers();
        //Vishnu 2
        LIST<Precall_Contact__c> savePreCallPlanConList = new LIST<Precall_Contact__c>();
            for(ContactModel cm : lstConModel){
                if(cm.flg && !mapPreCallContact.containsKey(cm.conObj.id) ){
                    Precall_Contact__c tempObj = new Precall_Contact__c();
                    tempObj.Contact__c = cm.conObj.id;
                    tempObj.Title__c = cm.conObj.Title;
                    tempObj.Name = cm.conObj.Name;
                    tempObj.Email__c = cm.conObj.email;
                    tempObj.Phone__c = cm.conObj.Phone;
                    tempObj.ReportsTo__c = cm.conObj.ReportsToId;
                    tempObj.Notes__c = cm.notesValues;
                    tempObj.Percall_Plan__c = preCallPlan.id;
                    savePreCallPlanConList.add(tempObj);
                }
            }
            if(savePreCallPlanConList != null && savePreCallPlanConList.size() > 0){
                insert savePreCallPlanConList;
            }
        //fillAllObjects();
        lstContacts =  [select id,Name, title__c, Notes__c,Contact__c,Contact__r.id,Email__c,Phone__c,ReportsTo__c,Contact__r.dmu__c from Precall_Contact__c where  Percall_Plan__c =: preCallPlan.id];
        mapPreCallContact = new Map<String,Precall_Contact__c>();
        if(lstContacts != null && lstContacts.size() > 0){
            for(Precall_Contact__c preCallCon : lstContacts){
                mapPreCallContact.put(preCallCon.contact__c,preCallCon);
            }
        }
        //filling ModelList for Showing
        if(savePreCallPlanConList != null && savePreCallPlanConList.size() > 0){
            if(lstPreCallContactModel != null){
                
                Integer j = 0;
                while (j < lstPreCallContactModel.size()){
                    if(lstPreCallContactModel[j].tempConObj.FirstName == null || lstPreCallContactModel[j].tempConObj.FirstName == '' || lstPreCallContactModel[j].donotaddContact == false){
                        lstPreCallContactModel.remove(j);
                    }else{
                        j++;
                    }
                }
                
                Map<String,Contact> mapContactFill = new Map<String,Contact>();
                Set<String> conIds = new Set<String>();
                for(Precall_Contact__c pc : savePreCallPlanConList){
                    conIds.add(pc.Contact__c);
                }
            
                for(Contact c : [Select id, firstname,lastname,phone,email,Business_Unit__c,title,DMU__c from Contact where id in : conIds]){
                    mapContactFill.put(c.id, c);
                }
                integer i=lstPreCallContactModel.size();
                for(Precall_Contact__c prc : savePreCallPlanConList){
                     PreCallPlanContactModel prd = new PreCallPlanContactModel(); 
                     prd.idx = i++;  
                     prd.preConObj = prc;
                     prd.tempConObj = mapContactFill.get(prc.Contact__c);
                     prd.notesText = prc.Notes__c;
                     lstPreCallContactModel.add(prd); 
                }
            }
        }
    }
    
    //Code for Saving Precall Objective Data
    public void saveCallObjectives(){
        LIST<Precall_Objective__c> saveList = new LIST<Precall_Objective__c>();
        if(lstCallObjectiveModel != null && lstCallObjectiveModel.size() > 0 ){
            for(CallObjectiveModel clm : lstCallObjectiveModel){
                if(clm.objectiveText != null && clm.objectiveText != ''){
                    clm.callObjectiveObj.Name = String.valueOf(clm.idx + 1) ;
                    if(clm.callObjectiveObj.id == null)
                        clm.callObjectiveObj.Percall_Plan__c = preCallPlan.id;
                    clm.callObjectiveObj.Objective__c = clm.objectiveText;
                    clm.callObjectiveObj.Post_Call_Comment__c = clm.PostCallComment ;
                    saveList.add(clm.callObjectiveObj);        
               }
            }
            
            if(saveList != null && saveList.size() > 0 ){
                upsert saveList;
            }
            //fillAllObjects();
            lstObjectives = [Select Post_Call_Comment__c,id,name,Objective__c,Percall_Plan__c from Precall_Objective__c where Percall_Plan__c =: preCallPlan.id order by Name];

            if(saveList.size() > 0){
                lstCallObjectiveModel.clear();
                Integer i=0;
                for(Precall_Objective__c callObj : saveList){
                    CallObjectiveModel cmodel = new CallObjectiveModel();
                    cmodel.callObjectiveObj = callObj;
                    cmodel.objectiveText = callObj.Objective__c;
                    cmodel.PostCallComment = callObj.Post_Call_Comment__c;
                    cmodel.idx = i++;
                    lstCallObjectiveModel.add(cmodel);
                }
            }
        }    
    }
    
    //Code For saving Precall Question Data
    public void saveKeyQuestions(){
        LIST<Precall_question__c> saveList = new LIST<Precall_question__c>();
        if(lstKeyQuestionsModel != null && lstKeyQuestionsModel.size() > 0 ){
            for(KeyQuestionsNotesModel kym : lstKeyQuestionsModel){
                if((kym.questions != null && kym.questions  != '') || (kym.notes != null && kym.notes != '') ){  
                    kym.qstObj.Name = String.valueOf(kym.idx + 1) ;
                    if(kym.qstObj.id == null)
                        kym.qstObj.Percall_Plan__c = preCallPlan.id;
                    if(kym.questions  != null && kym.questions != ''){
                        kym.qstObj.Question__c = kym.questions;
                    }
                    //if(kym.notes != null && kym.notes != ''){
                        kym.qstObj.Note__c = kym.notes;
                    //}
                    
                    saveList.add(kym.qstObj);  
                }      
               
            }
            
            if(saveList != null && saveList.size() > 0 ){
                upsert saveList;
            }
            //fillAllObjects();
            lstQuestions = [select id,name,Note__c,Question__c from Precall_question__c where Percall_Plan__c =: preCallPlan.id order by Name];
            
            if(saveList.size() > 0){
                lstKeyQuestionsModel.clear();
                integer i=0;
                for(Precall_question__c qstObj : saveList){
                    KeyQuestionsNotesModel qmodel = new KeyQuestionsNotesModel();
                    qmodel.qstObj = qstObj;
                    qmodel.questions = qstObj.Question__c;
                    qmodel.notes = qstObj.Note__c;
                    qmodel.idx = i++;
                    lstKeyQuestionsModel.add(qmodel);
                }
            }
        }    
    }
    
    
    //Code for Saving Precall Objection Data
    public void saveObjections(){
        LIST<Precall_Objection__c> saveList = new LIST<Precall_Objection__c>();
        if(lstObjectionModel != null && lstObjectionModel.size() > 0 ){
            for(ObjectionModel objm : lstObjectionModel){
                if((objm.objectionText != null && objm.objectionText != '') ||(objm.responseText != null && objm.responseText != '')){
                    objm.objectionObj.Name = String.valueOf(objm.idx + 1) ;
                    if(objm.objectionObj.id == null)
                        objm.objectionObj.Percall_Plan__c = preCallPlan.id;
                    if(objm.objectionText != null && objm.objectionText != ''){
                        objm.objectionObj.Objection__c = objm.objectionText;
                    }
                    if(objm.responseText != null && objm.responseText != ''){
                        objm.objectionObj.Response__c = objm.responseText;
                    }
                    
                    saveList.add(objm.objectionObj);    
                }    
               
            }
            
            if(saveList != null && saveList.size() > 0 ){
                upsert saveList;
            }
            //fillAllObjects();
            lstObjections = [select id,name, Objection__c, Response__c from Precall_Objection__c where Percall_Plan__c =: preCallPlan.id order by Name];
            
            if(saveList.size() > 0){
                lstObjectionModel.clear();
                integer i=0;
                for(Precall_Objection__c objet : saveList){
                    ObjectionModel obmodel = new ObjectionModel();
                    obmodel.objectionObj = objet;
                    obmodel.objectiontext = objet.Objection__c;
                    obmodel.responseText = objet.response__c;
                    obmodel.idx = i++;
                    lstObjectionModel.add(obmodel);
                }
            }
            
        }    
    }
    
    //Code for Saving Task Data
    public void saveTask(){
        //update preCallPlan;

        LIST<Task> saveList = new LIST<Task>();
        RecordType precallPlanRecType;
        if(preCallPlan.id != null){
            Percall_Plan__c tempPreCallObj = [select id,recordTypeId from Percall_Plan__c where id =: preCallPlan.id LIMIT 1];
            precallPlanRecType = [Select name from RecordType where id =: tempPreCallObj.recordTypeId ];
            
        }
        RecordType recType ;
        if(precallPlanRecType.Name == 'Precall Plan'){
            recType = [Select id from RecordType where name='Precall Plan' and SObjectType='Task' LIMIT 1];
        }else if(precallPlanRecType.Name == 'Account Plan'){
            recType = [Select id from RecordType where name='Account Plan' and SObjectType='Task' LIMIT 1];    
        }
        if(lstTaskModel != null && lstTaskModel.size() > 0){
            for(TaskModel tm : lstTaskModel){
                if(tm.taskSubject != null && tm.taskSubject != ''){
                    if(tm.taskSubject != null){
                        tm.taskObj.Subject = tm.taskSubject;
                    }
                    if(tm.taskObj.id == null)
                        tm.taskObj.whatId = preCallPlan.id;
                    if(recType != null){
                        tm.taskObj.recordTypeId = recType.id;
                    }
                    saveList.add(tm.taskObj);
                }
            }
            
            if(saveList != null && saveList.size() > 0 ){
                upsert saveList;
            }
            fillAllObjects();
            
            if(saveList.size() > 0){
                lstTaskModel.clear();
                for(Task tsk : saveList){
                    TaskModel tmodel = new TaskModel();
                    tmodel.taskObj = tsk;
                    tmodel.taskSubject = tsk.subject;
                    lstTaskModel.add(tmodel);
                }
            }
        }        
    }
     
    //Code for removing Precall Contact with passing Record Id
    public String preCallPlanContactId {get;set;}
    public void removeContact(){
        if(preCallPlanContactId  != null){
            delete [select id  from Precall_Contact__c where id =: preCallPlanContactId];
        }
        fillAllObjects();
        fillConModel();
        
        if(lstContacts == null || lstContacts.size() == 0){
            //PreCallPlan Contact Model
            PreCallPlanContactModel preConMod = new PreCallPlanContactModel();
            preConMod.idx = 0;
            preConMod.preConObj= new Precall_Contact__c();
            preConMod.tempConObj = new Contact();
            preConMod.tempConObj.LastName = 'LastName';
            lstPreCallContactModel.add(preConMod);
            isNewPreCallPlanContact = 'true';
        }
        fecthGemsUsers();
    }
    
    //Code for removing Precall Objective with passing Record Id
    public String callObjectiveId {get;set;}
    public void removeCallObjective(){
        if(callObjectiveId != null){
            delete [select id from Precall_Objective__c where id =: callObjectiveId];
        }    
        //fillAllObjects();
        //fillConModel();
        lstObjectives = [Select Post_Call_Comment__c,id,name,Objective__c,Percall_Plan__c from Precall_Objective__c where Percall_Plan__c =: preCallPlan.id order by Name];

        if(lstObjectives.size() == 0){
            CallObjectiveModel md = new CallObjectiveModel();
            md.idx = 0;
            md.callObjectiveObj = new Precall_Objective__c();
            lstCallObjectiveModel.add(md);
            md = new CallObjectiveModel();
            isNewCallObjective = 'true';
        }
    }
    
    //Code for removing Precall Quesiton with passing Record Id
    public String questionId {get;set;}
    public void removeQuestion(){
        if(questionId != null){
            delete [select id from Precall_question__c where id =: questionId ];
        }    
        //fillAllObjects();
        //fillConModel();
        lstQuestions = [select id,name,Note__c,Question__c from Precall_question__c where Percall_Plan__c =: preCallPlan.id order by Name];
        
        if(lstQuestions.size() == 0){
            //Key Questions Model
            KeyQuestionsNotesModel keymodel = new KeyQuestionsNotesModel();
            keymodel.idx = 0;
            keymodel.qstObj = new Precall_question__c();
            lstKeyQuestionsModel.add(keymodel);
            isNewQuestion = 'true';
        }
    }
    
    //Code for removing Precall Objection with passing Record Id
    public String objectionId {get;set;}
    public void removeObjection(){
        if(objectionId != null){
            delete [select id from Precall_Objection__c where id =: objectionId ];
        }    
        //fillAllObjects();
        //fillConModel();
        
        lstObjections = [select id,name, Objection__c, Response__c from Precall_Objection__c where Percall_Plan__c =: preCallPlan.id order by Name];
        
        if(lstObjections.size() == 0 ){
            //Objection Model
            ObjectionModel objModel = new ObjectionModel();
            objModel.idx = 0 ;
            objModel.objectionObj  = new Precall_Objection__c();
            lstObjectionModel.add(objModel);
            isNewObjection = 'true';
        }
    }
    
    //Code for removing Task with passing Record Id
    public String taskId {get;set;}
    public void removeTask(){
        if(taskId != null){
            delete [select id from Task where id =: taskId ];
        }    
        fillAllObjects();
        fillConModel();
        if(preCallPlan.Tasks.size() == 0){
            //Task model
            TaskModel tkmd = new TaskModel();
            tkmd.idx = 0;
            tkmd.taskObj = new Task();
            tkmd.taskObj.OwnerId = UserInfo.getUserId();
            tkmd.taskObj.Status = '';
            lstTaskModel.add(tkmd);
            
            isNewTask = 'true';
        }
    }
    
    //Code for Initializing the New Machine Object and its Application
    public boolean isMachineAdding {get;set;}
    public MachineMatrix__c machineObj {get;set;}
    public LIST<MachineMatrixModel> lstMachineMatrixModel {get;set;}
    public void initializeMachineObject(){
        machineObj = new MachineMatrix__c();
        machineObj.Account__c = actObj.id;
        lstMachineMatrixModelNew = new LIST<MachineMatrixModel>();
        lstMachineMatrixModelNew.add(new MachineMatrixModel( lstMachineMatrixModelNew.size()+1,machineObjId));
        isMachineAdding = true;
    }
    
    //Canceling the added row in lstMachineMatrixModelNew  List
    public void cancelMachineMartixRow(){

        if(lstMachineMatrixModelNew != null && isClickOnAddButton != null && isClickOnAddButton ){
            lstMachineMatrixModelNew.remove(lstMachineMatrixModelNew.size()-1);
            isClickOnAddButton = false;
        } 
        isMachineAdding = false;   
    }
    
    //Code for Adding One Row in lstMachineMatrixModelNew  List
    boolean isClickOnAddButton;
    public void addMachineMatrixRow(){        
        if(lstMachineMatrixModelNew != null){
            lstMachineMatrixModelNew.add(new MachineMatrixModel( lstMachineMatrixModelNew.size()+1,machineObjId));
            isClickOnAddButton = true;
        }
    }
    
    //Code for saving Machine Matrix Object Data
    public void saveMachiMatrix(){
        if(machineObj.Name != null && machineObj.Estimated_Annual_Volume__c != null){
            machineObj.Account__c = actObj.id;
            insert machineObj;
            
            actObj = [select gap__c,id,name,accountnumber,shippingstreet,shippingcity,shippingstate,shippingpostalcode,shippingcountry,
                     description,OwnerId,Owner.Name,Key_Account_Specialist__c,Market__c,Sub_Market__c,Customer_Classification__c,
                     Current_Year_Forecast__c,YTD_Sale__c,OTD_Goal__c,PPM_Goal__c ,Target_YTD__c,(select id,name,Estimated_Annual_Volume__c from Machines__r) 
                     from Account where id =: accountId];
            isMachineAdding = false;
        }       
    }
    
    //Code for fetching ApplicationData on the basis of Machine Object Id
    public String machineObjId {get;set;}
    public LIST<MachineMatrixModel> lstMachineMatrixModelNew {get;set;}
    public void gettingApplicationRecords(){
       lstMachineMatrixModelNew = new LIST<MachineMatrixModel>();
       integer i=1;
       for(Application__c app : [Select Units_per_machine__c, Total_Rev_Per_Machine__c, Supplier__c, Supplier_Part_Number__c,Sell_Price__c, Product_Family__c, Name, Machine_Matrix__c, Id, Gems_Part_Number__c, Customer_Part_Number__c, Comments__c From Application__c where Machine_Matrix__c =: machineObjId order by name]){
           MachineMatrixModel mod = new MachineMatrixModel();
           mod.machApp  = app;
           mod.idx = i++;
           lstMachineMatrixModelNew.add(mod);            
       }
       
       if(lstMachineMatrixModelNew.size() == 0){
           lstMachineMatrixModelNew.add(new MachineMatrixModel( lstMachineMatrixModelNew.size()+1,machineObjId));    
       } 
    }
    
    //Code for Saving Machine Matrix with Applications
    public void saveMachiMatrixNew(){
        if(isMachineAdding){
            if(machineObj.Name != null && machineObj.Estimated_Annual_Volume__c != null){
                machineObj.Account__c = actObj.id;
                insert machineObj;
                
                machineObjId = machineObj.id;
            }
            
        }
        LIST<Application__c> saveAppList = new LIST<Application__c>();
        if(lstMachineMatrixModelNew.size() > 0){
            for(MachineMatrixModel matrixMod : lstMachineMatrixModelNew){
                if(matrixMod.machApp.Name != null  && matrixMod.machApp.Name != ''){
                    if(matrixMod.machApp.id == null)
                        matrixMod.machApp.Machine_Matrix__c = machineObjId;
                    saveAppList.add(matrixMod.machApp);
                }    
            }
            
            if(saveAppList != null && saveAppList.size() > 0){
                upsert saveAppList;
                
                
                if(!Test.isRunningTest()){
                    LIST<AggregateResult> agRes = [select Machine_Matrix__r.Account__c act, sum(Total_Rev_Per_Machine__c) totSum from Application__c where Machine_Matrix__r.Account__c =: actObj.id group by Machine_Matrix__r.Account__c];
                    LIST<AggregateResult> agResGEMS = [select Machine_Matrix__r.Account__c act, sum(Total_Rev_Per_Machine__c) totSum from Application__c where Machine_Matrix__r.Account__c =: actObj.id and Supplier__c = 'GEMS' group by Machine_Matrix__r.Account__c];
                    actPotModelObj = new AccountPotentialModel();
                    if(agRes != null && agRes.size() > 0)
                    actPotModelObj.totalRevnue = ((Decimal)agRes[0].get('totSum')).setScale(2);
                    if(agResGEMS != null && agResGEMS.size() > 0)
                    actPotModelObj.gemsRev =  ((Decimal)agResGEMS[0].get('totSum')).setScale(2);
                    
                    if( actPotModelObj.totalRevnue != null && actPotModelObj.totalRevnue > 0 && actPotModelObj.gemsRev !=null && actPotModelObj.gemsRev > 0 )
                        actPotModelObj.gemsShare = ((actPotModelObj.gemsRev / actPotModelObj.totalRevnue) * 100).setScale(2);
                    else
                        actPotModelObj.gemsShare = 0;
                }
                accountPotentialCalculation();
                accountPotentailCalculationByMachineName();
                isMachineAdding = false;
                
             }
        }
        actObj = [select gap__c,id,name,accountnumber,shippingstreet,shippingcity,shippingstate,shippingpostalcode,shippingcountry,
                    description,OwnerId,Owner.Name,Key_Account_Specialist__c,Market__c,Sub_Market__c,Customer_Classification__c,
                    Current_Year_Forecast__c,YTD_Sale__c,OTD_Goal__c,PPM_Goal__c ,Target_YTD__c, (select id,name,Estimated_Annual_Volume__c from Machines__r) 
                    from Account where id =: accountId];
        
    }
    
    //Method to ChangeReportsToSetting 
    public void saveReportsToSetting(){
        if(lstreportToModel != null && lstreportToModel.size() > 0 ){
            LIST<Contact> tempConList = new LIST<Contact>();
            for(ContactAndReportsToModel crm : lstreportToModel){
                crm.conObj.ReportsToId = crm.reportsToId;
                tempConList.add(crm.conObj);
            }
            
            if(tempConList != null && tempConList.size() > 0){
                update tempConList;
            }
            lstreportToModel.clear();
            for(Contact con : tempConList){
                ContactAndReportsToModel  crmd = new ContactAndReportsToModel ();
                crmd.conObj = con;
                crmd.reportsToId = con.reportsToId;
                lstreportToModel.add(crmd);
            }
            creatingOrgChartData();
        }
    }
    
    //Attachments section   
    public list<AttachmentModel> lstAttachs{get;set;}
    public string removeAtcId{get;set;}
    public boolean isNewAttach{get;set;}
    public void initForAttachments(){
        isNewAttach = false;
        lstAttachs = new list<AttachmentModel>();
        integer i=1;
        for( Attachment atc : [ select id,name,Description from attachment where parentid =: preCallPlan.id ]){
            AttachmentModel AM = new AttachmentModel();
            AM.atcObj = atc;
            AM.index = i ;
            i++;
            lstAttachs.add(AM);
            
        }
    }
    
    public void removeAttach(){
        list<Attachment> lstRemove = [ select id from attachment where id =: removeAtcId];
        if( lstremove.size() > 0 ){        
            delete lstRemove;
        }
        initForAttachments();
    }
    
    public Pagereference cancelForAttach(){
        initForAttachments();
        return null;
    }
    
    public Pagereference saveAttachs(){
        List<Attachment> lsInstAttach = new List<Attachment>();
        for( AttachmentModel AmObj : lstAttachs ){
            lsInstAttach.add(AmObj.atcObj);
        }        
        insert lsInstAttach;
        initForAttachments();
        return null;
    }
    
    public Pagereference AddOneRowAtc(){
        lstAttachs = new list<AttachmentModel>();
        return AddOneMoreRow();
    }
    
    public Pagereference AddOneMoreRow(){
        isNewAttach = true;        
        AttachmentModel AmNew = new AttachmentModel();
        AmNew.atcObj = new Attachment();
        AmNew.atcObj.parentId = preCallPlan.id;
        AmNew.index = lstAttachs.size()+1;
        lstAttachs.add(AmNew);
        return null;
    }
    
    public class AttachmentModel{
        public Attachment AtcObj{get;set;}
        public Integer Index{get;set;}
    }
    
    public void saveNewContact(){
        if(newConObj != null){
            newConObj.accountId = actId;
            insert newConObj;
            
            creatingOrgChartData();
            fillConModel();
            newConObj = new Contact();
            newConObj.LastName = 'LastName';
        }
    }
    public class ContactModel{
        public boolean flg {get;set;}
        public integer idx {get;set;}
        public Contact conObj {get;set;}
        public String notesValues {get;set;}
        
    }
    
    public class ContactAndReportsToModel{
        public Contact conObj {get;set;}
        public String reportsToId {get;set;}
    }
    
    public class PreCallPlanContactModel{
        public Precall_Contact__c preConObj {get;set;}
        public integer idx {get;set;}
        public String notesText {get;set;}
        public Contact tempConObj {get;set;}
        public boolean doNotAddContact {get;set;}
        public String reportsToValue {get;set;}
    }
    
    public class CallObjectiveModel{
        public integer idx {get;set;}
        public Precall_Objective__c callObjectiveObj {get;set;}
        public String objectiveText { get{ return objectiveText == null ? '':objectiveText.unescapeHtml4();} set;}
        public String PostCallComment { get{ return PostCallComment == null ? '':PostCallComment.unescapeHtml4();} set;}
    }
    
    public class KeyQuestionsNotesModel{
        public integer idx {get;set;}
        public Precall_question__c qstObj {get;set;}
        public String questions { get{ return questions == null ? '':questions.unescapeHtml4();} set;}  
        public String notes { get{ return notes == null ? '':notes.unescapeHtml4();} set;}
    }
    
    public class ObjectionModel{
        public integer idx {get;set;}
        public Precall_Objection__c objectionObj {get;set;}
        public String objectionText { get{ return objectionText == null ? '':objectionText.unescapeHtml4();} set;} 
        public String responseText { get{ return responseText == null ? '':responseText.unescapeHtml4();} set;} 
    }
    
    public class TaskModel{
        public integer idx {get;set;}
        public Task taskObj {get;set;}
        public String taskSubject {get;set;}
    }
    
    public class AccountPotentialModel{
        public String productFamily {get;set;}
        public String MachineName {get;set;}
        public String SupplierName {get;set;}
        public Decimal totalRevnue {get;set;}
        public Decimal gemsRev {get;set;}
        public Decimal gemsShare {get;set;}
        public string StrtotalRevnue {get;set;}
        public string StrtotalRevnueTT {get;set;}
        public string StrgemsRev {get;set;}
        public string StrgemsRevTT {get;set;}
        public String Comments {get;set;}
    }
    
    public class TripReportModel{
        public boolean isShow {get;set;}
        public String sectionName {get;set;}
        public String sectionAbr {get;set;}
        
        public TripReportModel(boolean s , String n,String ab){
            isShow = s;
            sectionName = n;
            sectionAbr = ab;
        }
    }
    
    public class MachineMatrixModel{
        public integer idx {get;set;}
        public Application__c machApp {get;set;}
        
        public MachineMatrixModel(integer i,String machineId){
            machApp = new Application__c();
            machApp.Machine_Matrix__c = machineId;
            idx = i;
        }
        public MachineMatrixModel(){ }
    }
    
    public class OrgChartDataModel{
        public String id {get;set;}
        public Contact conObj {get;set;}
    }
    public class OrgCharDataModelWithParent{
        public String id {get;set;}
        public String name {get;set;}
        public String parent {get;set;}
    }
    
    public void justCalling(){}  
    
    public void justCalling1(){
        if(lstMachineMatrixModelNew != null)
            lstMachineMatrixModelNew.clear();    
    }
}