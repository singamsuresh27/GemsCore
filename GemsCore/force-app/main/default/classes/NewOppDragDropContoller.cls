global with sharing class NewOppDragDropContoller{
    public List<Opportunity_Dashboard_Stages__c> lstStages{get;set;}
    public String groupByField{get;set;}
    public String groupByFieldType {get;set;}
    public static List<NewOppDragDropContoller.OpportunityWrapper> lstOpportunities;
    public LIST<String> lstTempContainer {get;set;}
    public String jStr {get;set;}
    
    public Map<String,List<Opportunity>> mapOpps {get;set;} 
    public set<String> allUsers {get;set;}
    public set<String> allProjectManager {get;set;}
    public String jUserStr {get;set;} 
    
    
    public Integer ownerflg {get;set;}
    public String groupbypanel {get;set;}
    public String usrId {get;set;}
    public String sortingfld {get;set;}
    public Date todayDate {get;set;}
    public Date nextSixthDate {get;set;}
    public String curCode {get;set;}
    public Double convertRate {get;set;}
    
    //Constructor 
    public NewOppDragDropContoller(){
        todayDate = System.Today();
        nextSixthDate = System.Today().addDays(6);     
        groupbypanel = 'all';
        sortingfld ='Estimated_Amount__c';
        
        //Code for checking User Profile to Access EntitySubscription Object 
        usrId = UserInfo.getUserId();
        curCode = UserInfo.getDefaultCurrency();
        
        
        User usr = [select id,profile.name from  User where id =: usrId LIMIT 1];
        if(usr != null && usr.profile.name != 'System Administrator' ){
            //usrId = '' ;
        }
        
        CurrencyType ctype = [Select conversionRate from CurrencyType where ISOCode =: curCode LIMIT 1];
        if(ctype != null ){
            convertRate = ctype.conversionRate;
        }else{
            convertRate = 1.0;
        }
        
        //Code for setting Wall Panel default is AllUser/AllOwner Panel
        ownerflg = 1;
        
        groupByField = 'StageName';
        
        //code for filling Stages from Custom Setting
        lstStages = [SELECT Id, Name, Index__c, Stage_Color_Code__c FROM Opportunity_Dashboard_Stages__c Order By Index__c asc LIMIT 1000];
        lstTempContainer  = new LIST<String>();
        
        
        Set<String> settempStg = new Set<String>();
        for(Schema.PicklistEntry ple : Opportunity.StageName.getDescribe().getPicklistValues()){
            String stgv = ple.getValue();
            if(stgv != 'Closed Lost' && stgv != 'Closed Won'){
                settempStg.add(stgv);  
            }
        }
        for(String st : settempStg){
            lstTempContainer.add(st);    
        }
        lstTempContainer.sort();
        
        
        groupByFieldType = 'PICKLIST';    
        
        lstOpportunities = new List<NewOppDragDropContoller.OpportunityWrapper>();
        
        tempSetController = new ApexPages.StandardSetController([select id from Opportunity LIMIT 1]);
        if(filterId == null || filterId == ''){
            filterId = (tempSetController.getListViewOptions())[0].getValue();
        }
        
        showingOppMethod();
    } 
    
    //Code for Showing Wall Panel flag
    public void showingPanel(){
        if(groupbypanel == 'all'){
            ownerflg = 1;
        }else if(groupbypanel == 'ow'){
            ownerflg = 2;    
        }else{
            ownerflg = 3;
        }
    }
    
   
    
    
    
    
    //Method for creating OpportuntiyWrapper List 
    public List<NewOppDragDropContoller.OpportunityWrapper> tempMethod(){
        System.debug('-----> stageWiseOppList '  + stageWiseOppList.size() );
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>(stageWiseOppList);    //getOpps());    
        
        Map<Id, EntitySubscription> mapEntitySubs = new Map<Id, EntitySubscription>();
        
        
        Map<String,Set<String>> mapSubs1 = new Map<String,Set<String>>();
       
        if(Schema.sObjectType.EntitySubscription.isAccessible()){
            for(EntitySubscription entitySubs : [Select e.SubscriberId, e.ParentId, e.Id From EntitySubscription e
                                                 WHERE e.ParentId in: mapOpportunities.keySet() LIMIT 1000]){
                mapEntitySubs.put(entitySubs.parentId, entitySubs); 
                
                if(mapSubs1.containskey(entitySubs.parentId)){
                    mapSubs1.get(entitySubs.parentId).add(entitySubs.SubscriberId);
                }else{
                    Set<String> tempSet = new Set<String>();
                    tempSet.add(entitySubs.SubscriberId);
                    mapSubs1.put(entitySubs.parentId,tempSet);
                }                       
            }        
        }
        lstOpportunities = new List<NewOppDragDropContoller.OpportunityWrapper>();
        
        // Get Task Owner Photo URL.
        Set<String> setUsers = new Set<String>();
        Map<Id, String> mapUserPhotoUrl = new Map<Id, String>();
        /*for(Opportunity oppRecord : mapOpportunities.values()){
            setUsers.add(oppRecord.OwnerId);
        }                             
        for(User usr: [SELECT Id, SmallPhotoUrl From User WHERE Id in:setUsers]){
            mapUserPhotoUrl.put(usr.Id, usr.SmallPhotoUrl);
        }*/
        
        //Code for showing Last Contact information
        LIST<Task> CVTask = [Select id,Subject,Owner.Name,ActivityDate,WhatId from Task where subject = 'Call' and Status = 'Completed' and WhatId in : oppIds order by ActivityDate];
    
        LIST<Event> CVEvent = new LIST<Event>();
        Map<String,Task> mapTask = new Map<String,Task>();
        Map<String,Event> mapEvent = new Map<String,Event>();
        if(CVTask != null && CVTask.size() > 0 ){
            CVEvent = [Select id,Subject,Owner.Name,ActivityDate,WhatId from Event where (Subject LIKE 'CV%' OR Subject LIKE 'Customer Visit%' ) and ActivityDate <: System.Today() and WhatId in : oppIds order by ActivityDate];        
            for(Task tsk : CVTask){
                mapTask.put(tsk.WhatId,tsk);
            }
            
            if(CVEvent != null && CVEvent.size() > 0){
                for(Event ev : CVEvent){
                    mapEvent.put(ev.WhatId,ev);
                }   
            }
        }
        
        Map<String,String> mapSubs2 = new Map<String,String>();
        if(mapSubs1 != null && mapSubs1.size() > 0){
            for(String opId : mapSubs1.keyset()){
                for(String st : mapSubs1.get(opId)){
                    if(st == usrId){
                        mapSubs2.put(opId,st);
                        break;
                    }
                        
                }
            }
        }
        Integer index = 0;
        for(Opportunity oppRecord: mapOpportunities.values()){
            NewOppDragDropContoller.OpportunityWrapper wrapperObj = new NewOppDragDropContoller.OpportunityWrapper();
            wrapperObj.index = index;
            wrapperObj.oppRecord = oppRecord;
            //wrapperObj.oppOwnerPhoto = mapUserPhotoUrl.get(oppRecord.OwnerId);
            wrapperObj.isUserFollowing = mapSubs2.keyset().contains(oppRecord.Id) && mapSubs2.get(oppRecord.Id).contains(usrId);//mapEntitySubs.keyset().contains(oppRecord.Id);
            wrapperObj.subscriberId = mapSubs2.keyset().contains(oppRecord.Id) ? mapSubs2.get(oppRecord.Id) :'-';  //mapEntitySubs.keyset().contains(oppRecord.Id) ?mapEntitySubs.get(oppRecord.Id).SubscriberId+'' : '-';
            wrapperObj.subsCount = mapSubs1.keyset().contains(oppRecord.Id) ? mapSubs1.get(oppRecord.Id).size() :0; 
            wrapperObj.taskCircle1 = taskMapList.get(oppRecord.Id);
           
            
            if(mapEvent.containsKey(oppRecord.Id)){
                wrapperObj.lastContactDate = mapEvent.get(oppRecord.Id).ActivityDate + 'n' + mapEvent.get(oppRecord.Id).Subject  +'n' + mapEvent.get(oppRecord.Id).Owner.Name;    
            }else if(mapTask.containsKey(oppRecord.Id)){
                wrapperObj.lastContactDate = mapTask.get(oppRecord.Id).ActivityDate + 'n' + mapTask.get(oppRecord.Id).Subject  +'n' + mapTask.get(oppRecord.Id).Owner.Name;    
            }else{
                wrapperObj.lastContactDate = 'No Contact';    
            }
            
            lstOpportunities.add(wrapperObj);
        }
            
                
        
        return lstOpportunities;
    }
    
    //Remote Action Method from Chaning Opportunity Stage
    @RemoteAction
    global static void changeOpportunityStage(String opportunityId, String newStage,String fld,String fldtype){
        
        if(checkIsNotNullBlank(opportunityId) && checkIsNotNullBlank(newStage)){
            Opportunity oppRecord = [SELECT Id, StageName FROM Opportunity WHERE Id=:opportunityId];
            String newqry = 'SELECT id,' + fld + ' FROM Opportunity WHERE Id=:opportunityId';
            Opportunity oppRecord1 = Database.query(newqry);            
            
            SObject SO = oppRecord1;

            if(fldtype == 'PICKLIST'){
                SO.put(fld, newStage);
            }
            
            if(newStage == 'Closed Lost'){
                SO.put('OPP_closing_note__c','test');
                SO.put('Reason__c','test');
            }
            oppRecord.StageName = newStage;
            update SO;
            
        }
    }  
    
    @RemoteAction
    global static void toggleFollowingOpportunity(String opportunityId, String action){
        if(Schema.sObjectType.EntitySubscription.isAccessible()){
            if(action == 'following'){
                EntitySubscription entitySubs = new EntitySubscription();
                entitySubs.ParentId = opportunityId;
                entitySubs.SubscriberId = UserInfo.getUserId();
                insert entitySubs;
            }
            else{
                List<EntitySubscription> lstEntitySubs = [SELECT Id FROM EntitySubscription 
                                                          WHERE ParentId=:opportunityId AND SubscriberId=:UserInfo.getUserId() LIMIT 1000];
                if(lstEntitySubs.size() > 0){
                    delete lstEntitySubs;
                }                                          
            }
        }
    }
    
    
    private static Boolean checkIsNotNullBlank(String str){
        if(str != null && str.trim().length() > 0)
            return true;
        return false;
    }
    
    
    global class OpportunityWrapper{
        global Integer index{get;set;}
        global Boolean isUserFollowing{get;set;}
        global String subscriberId {get;set;}
        global Integer subsCount {get;set;}
        global String oppOwnerPhoto{get;set;}
        global Opportunity oppRecord{get;set;}
        global Date nextStageDate {get;set;}
        global String lastContactDate {get;set;}
        global Map<String,LIST<Task>> taskCircle1 {get;set;}
         
    }

    public class OppOnwerWrapper{
        public Double totalAmount {get;set;}
        public Integer recordCount {get;set;}
    }
    
    Set<String> setStageName ;
    LIST<Opportunity> myList ;
    private static String baseQuery ;
    public String filterId {get;set;}
    public Integer totalpages {get;set;}
    public Integer pageNum {get;set;}
    private static Integer pageSize = 20;
    ApexPages.StandardSetController tempSetController ; 
    
    public Map<String,Double> mapStageTotal {get;set;}
    public Map<String,Integer> mapStageRecordCount {get;set;}  
    public Map<String,Map<String,OppOnwerWrapper>> wrraperMap {get;set;}
    public Map<String,Map<String,OppOnwerWrapper>> wrraperMapPM {get;set;}
    
    
    public Map<String,Double> getMapStageTotal(){
        return mapStageTotal;
    }
    
    public Map<String,Integer> getMapStageRecordCount (){
        return mapStageRecordCount ;
    }
    
    public Map<String,Map<String,OppOnwerWrapper>> getWrraperMap (){
        return wrraperMap;
    }
    
    public Map<String,Map<String,OppOnwerWrapper>> getWrraperMapPM (){
        return wrraperMapPM;
    }
    
    Set<String> oppIds ; 
    String myqry ='' ;
    
    String filterWhereClause  = '';
    
    
    Integer recount;
    Integer maxCount=0;
    Integer offsetVar = 0;
    
    boolean fromShowButton = false; 
    
    /*public void fromShowButtonMethod(){
        fromShowButton = true;
        showingOppMethod();
    }
    
    public void notFromShowButtonMethod(){
        fromShowButton = false;
        showingOppMethod();    
    }*/
    
    public void showingOppMethod(){
        offsetVar = 0;
        groupbypanel = 'all';
        filterWhereClause  = '';
        System.debug('--->  First Time :  '+ filterId );
        
        if(filterId != null){
          String filterQuery = getQueryFilter('Opportunity',filterId);
          filterWhereClause = filterQuery.substringAfter('WHERE').substringBefore('ORDER BY'); 
          System.debug('--->  filterWhereClause  '  + filterWhereClause ); 
        }
        
        String queryFields = 'Select CloseDate, Id, name, OwnerId, Owner.Name, NextStep, Next_Step_Due_date__c, StageName, Project_Manager__c,Project_Manager__r.Name, NextStageDate__c, Current_Stage_Duration__c,Estimated_Amount__c, Owner.LastName, Project_Manager__r.LastName,CurrencyIsoCode   ';
        AggregateResult agr = Database.query('Select count(id) cnt from Opportunity where StageName Not in (\'Closed Lost\',\'Closed Won\')  ' + (filterWhereClause != '' ?' AND (' + filterWhereClause +')' : '' ));
        if(agr != null){
            recount = Integer.valueOf(agr.get('cnt'));               
        }else{
            recount = 0;
        }
        
        
                
        myqry = queryFields + ' from Opportunity  where StageName Not in (\'Closed Lost\',\'Closed Won\') ' + (filterWhereClause != '' ?' AND (' + filterWhereClause +')' : '' )+' order by '+ sortingfld +' DESC LIMIT 20 OFFSET ' + offsetVar;       
        System.debug('---> ' + myqry);
        myList=  Database.query(myqry); 
        //tempSetController = new ApexPages.StandardSetController(Database.query(myqry1));
        //System.debug('---> ' + tempSetController.getResultSize()); 
        
        fetchingStageWiseOpps();
        
        
        
        
        afterPageingCode();
        
        maxCount=0;
        for(Integer v : mapStageRecordCount.values()){
            if(v > maxCount){
                maxCount = v;
            }
        }
        System.debug('---->   maxCount   ' +   maxCount  );
        totalpages = maxCount /pagesize;
        if(totalpages != 0){
            if(Math.mod(maxCount ,pageSize) != 0){
                totalpages++;    
            }
        }else{
            totalpages = 1;
        }
        pageNum = 1;
        
        
        
    }
    
    LIST<Opportunity> stageWiseOppList ;
    private void fetchingStageWiseOpps(){
        String queryFields = 'Select CloseDate, Id, name, OwnerId, Owner.Name, NextStep, Next_Step_Due_date__c, StageName, Project_Manager__c,Project_Manager__r.Name, NextStageDate__c, Current_Stage_Duration__c,Estimated_Amount__c, Owner.LastName, Project_Manager__r.LastName,CurrencyIsoCode   ';
        String qry = queryFields + ' from Opportunity  where StageName = \'Stage 1 - Qualified\'' + (filterWhereClause != '' ?' AND (' + filterWhereClause +')' : '' )+' order by '+ sortingfld +' DESC LIMIT 20 OFFSET ' + offsetVar;       
        LIST<Opportunity> stage1Opps = Database.query(qry);
        
        qry = queryFields + ' from Opportunity  where StageName = \'Stage 2 - Needs Identified & Accepted\'' + (filterWhereClause != '' ?' AND (' + filterWhereClause +')' : '' )+' order by '+ sortingfld +' DESC LIMIT 20 OFFSET ' + offsetVar;           
        LIST<Opportunity> stage2Opps = Database.query(qry);
        
        qry = queryFields + ' from Opportunity  where StageName = \'Stage 3 - Solution Presented & Accepted\'' + (filterWhereClause != '' ?' AND (' + filterWhereClause +')' : '' )+' order by '+ sortingfld +' DESC LIMIT 20 OFFSET ' + offsetVar;           
        LIST<Opportunity> stage3Opps = Database.query(qry);
        
        qry = queryFields + ' from Opportunity  where StageName = \'Stage 4 - Specific Price / Budget\'' + (filterWhereClause != '' ?' AND (' + filterWhereClause +')' : '' )+' order by '+ sortingfld +' DESC LIMIT 20 OFFSET ' + offsetVar;           
        LIST<Opportunity> stage4Opps = Database.query(qry);
        
        qry = queryFields + ' from Opportunity  where StageName = \'Stage 5 - Order Placement\'' + (filterWhereClause != '' ?' AND (' + filterWhereClause +')' : '' )+' order by '+ sortingfld +' DESC LIMIT 20 OFFSET ' + offsetVar;           
        LIST<Opportunity> stage5Opps = Database.query(qry);
        
        stageWiseOppList = new LIST<Opportunity>();
        stageWiseOppList.addAll(stage1Opps);
        stageWiseOppList.addAll(stage2Opps);
        stageWiseOppList.addAll(stage3Opps);
        stageWiseOppList.addAll(stage4Opps);
        stageWiseOppList.addAll(stage5Opps);
        
        System.debug('---->  stageWiseOppList Values  :    ' + stageWiseOppList);
        
    }
    
    
    public LIST<String> owList {get;set;}
    public LIST<String> pmList {get;set;}
    
    private void afterPageingCode(){
        mapOpps = new Map<String,List<Opportunity>>();
        
        allUsers = new Set<String>();
        allProjectManager = new Set<String>();
        owList = new LIST<String>();
        pmList = new LIST<String>();
        
        oppIds = new Set<String>();
        
        String qry = 'Select id,owner.name,ownerId,project_manager__r.name, project_manager__c from Opportunity where StageName Not in (\'Closed Lost\',\'Closed Won\') ' + (filterWhereClause != '' ?' AND (' + filterWhereClause +')' : '' ) + ' LIMIT 20000';
        System.debug('----> ' + qry);
        
        //LIST<Opportunity> tempOppList = Database.query(qry);
        /*if(stageWiseOppList == null || stageWiseOppList.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There are no Open Opportunity in this View.'));
            return;            
        }*/
        
        for(Opportunity op : stageWiseOppList){
            oppIds.add(op.id);
            if(op.Owner.Name.indexOf('\'') != -1){
                allUsers.add(op.Owner.Name.replace('\'',''));                
            }else{
                allUsers.add(op.Owner.Name);               
            }
            if(op.Project_Manager__c != null){
                if(op.Project_Manager__r.Name.indexOf('\'') != -1){
                    allProjectManager.add(op.Project_Manager__r.Name.replace('\'',''));                   
                }else{
                    allProjectManager.add(op.Project_Manager__r.Name);
                }
            }    
        }
        for(String st: allUsers){
            owList.add(st);    
        }
        
        for(String st : allProjectManager){
            pmList.add(st);        
        }
        owList.sort();
        pmList.sort();
        
        
       
        mapStageTotal = new Map<String,Double>();
        mapStageRecordCount = new Map<String,Integer>();
        
        
        
        String agQuery = 'select StageName stg , sum(Estimated_Amount__c) sumAmt , count(id) cnt  from Opportunity where StageName Not in (\'Closed Lost\',\'Closed Won\')' + (filterWhereClause != '' ? ' AND ('+ filterWhereClause + ')  ' : '' ) + 'group by StageName'; 
        //Code for filling Map for All Opportunities Total and Count
        for(AggregateResult ag : Database.query(agQuery)){    
            String st = (String) ag.get('stg');
            mapStageTotal.put(st,Double.valueOf(ag.get('sumAmt')) * convertRate );
            mapStageRecordCount.put(st,Integer.valueOf(ag.get('cnt')));    
        }
        if(lstTempContainer != null && lstTempContainer.size() > 0 ){
            for(String st : lstTempContainer){
                if(!mapStageTotal.containsKey(st)){
                    mapStageTotal.put(st , 0.0);
                    mapStageRecordCount.put(st,0);
                }
            }
        }
        
        //Code for filling Map for Ownerwise Total and Count
        wrraperMap = new Map<String,Map<String,OppOnwerWrapper>>();
        for(String us : allUsers){
            Map<String, OppOnwerWrapper > tMap = new Map<String,OppOnwerWrapper >();
            for(String stg : lstTempContainer){
                OppOnwerWrapper modelObj = new OppOnwerWrapper();
                modelObj.totalAmount = 0.0;    
                modelObj.recordCount = 0; 
                tMap.put(stg, modelObj);
            }
            wrraperMap.put(us,tMap);
        }
        agQuery = 'select owner.name owd ,StageName stg , sum(Estimated_Amount__c) sumAmt, count(id) cnt from Opportunity where StageName Not in (\'Closed Lost\',\'Closed Won\')' +  (filterWhereClause != '' ? ' AND ('+ filterWhereClause + ')  ': '' ) + ' group by owner.name,StageName';
        for(AggregateResult agRes : Database.query(agQuery)){
            String ky = String.valueOf(agRes.get('owd')).trim();
            String stgg = String.valueOf(agRes.get('stg')).trim();
            OppOnwerWrapper modelObj = new OppOnwerWrapper();
            modelObj.totalAmount = Double.valueOf(agRes.get('sumAmt')) * convertRate ;    
            modelObj.recordCount = Integer.valueOf(agRes.get('cnt'));
            if(wrraperMap.containsKey(ky)){
                if(wrraperMap.get(ky).containsKey(stgg)){
                    OppOnwerWrapper mObj = wrraperMap.get(ky).get(stgg);
                    mObj.totalAmount = modelObj.totalAmount;
                    mObj.recordCount = modelObj.recordCount;
                }                  
            }               
        }   
        
        
        
        
        
        //Code for filling Map for Project Manager Wise Total and Count
        wrraperMapPM = new Map<String,Map<String,OppOnwerWrapper>>();
        for(String us : allProjectManager){
            Map<String, OppOnwerWrapper > tMap = new Map<String,OppOnwerWrapper>();
            for(String stg : lstTempContainer){
                OppOnwerWrapper modelObj = new OppOnwerWrapper();
                modelObj.totalAmount = 0.0;    
                modelObj.recordCount = 0; 
                tMap.put(stg, modelObj);
            } 
            wrraperMapPM.put(us,tMap);
        }
        
        agQuery = 'select Project_Manager__r.name pm ,StageName stg , sum(Estimated_Amount__c) sumAmt, count(id) cnt from Opportunity where project_Manager__c != null and StageName Not in (\'Closed Lost\',\'Closed Won\')' +  (filterWhereClause != '' ? ' and ( '+ filterWhereClause +')' : '' ) +'  group by project_Manager__r.name,StageName';
        for(AggregateResult agRes : Database.query(agQuery)){
            String ky = String.valueOf(agRes.get('pm')).trim();
            String stgg = String.valueOf(agRes.get('stg')).trim();
            OppOnwerWrapper modelObj = new OppOnwerWrapper();
            modelObj.totalAmount = Double.valueOf(agRes.get('sumAmt')) * convertRate ;    
            modelObj.recordCount = Integer.valueOf(agRes.get('cnt'));
            if(wrraperMapPM.containsKey(ky)){
                if(wrraperMapPM.get(ky).containsKey(stgg)){
                    OppOnwerWrapper mObj = wrraperMapPM.get(ky).get(stgg);
                    mObj.totalAmount = modelObj.totalAmount;
                    mObj.recordCount = modelObj.recordCount;
                }                  
            }             
        }  
        
        taskCounting();
        jstr = JSON.serialize(tempMethod()); 
        
        
    }
    
    
   
    Map<String,Map<String,LIST<Task>>>  taskMapList ;
    
    public LIST<String> taskStageList {get;set;} 
    
    public void taskCounting(){
        taskMapList = new Map<String,Map<String,LIST<Task>>>();
        RecordType rc = [select id from RecordType Where SObjectType='Task' and Name = 'Sales Deliverable' limit 1];
        
        taskStageList = new List<String>();
        Set<String> tmpSet = new Set<String>();
        
        for(Task tsk : [select id,Subject, Owner.Name , ActivityDate,whatId, Opportunity_Stage__c, Status,Status_Color_Text__c  from Task where Opportunity_Stage__c != null and whatId in : oppIds and recordTypeId =: rc.id ]){
            tsk.Subject = tsk.Subject.replace('\'','');
                    
            if(taskMapList.containsKey(tsk.whatId)){
                if(taskMapList.get(tsk.whatId).containsKey(tsk.Opportunity_Stage__c)){
                    taskMapList.get(tsk.whatId).get(tsk.Opportunity_Stage__c).add(tsk);    
                }else{
                    LIST<Task> tmpLst = new LIST<Task>();
                    tmpLst.add(tsk);
                    taskMapList.get(tsk.whatId).put(tsk.Opportunity_Stage__c,tmpLst);    
                }  
            }else{
                //Adding first value in MapList
                LIST<Task> tmpLst = new LIST<Task>();
                tmpLst.add(tsk);

                Map<String,LIST<Task>> mpLst = new Map<String,LIST<Task>>();    
                mpLst.put(tsk.Opportunity_Stage__c,tmpLst);
                
                taskMapList.put(tsk.whatId,mpLst);
            } 
            
            if(tsk.Opportunity_Stage__c != null){
                tmpSet.add(tsk.Opportunity_Stage__c);
                //taskStageList.add(tsk.Opportunity_Stage__c);
            }       
        }
        
        
        for(String st : tmpSet){
             taskStageList.add(st);   
        } 
        taskStageList.sort();
        
    }
    
    
    
    public void myPrev(){
        
        
        if(offsetVar <= 0){
            offsetVar = 0;
            pageNum =1;
        }else{
            offsetVar -= 20;
            pageNum --;
        }
        //String queryFields = 'Select CloseDate, Id, name, OwnerId, Owner.Name, NextStep, Next_Step_Due_date__c, StageName, Project_Manager__c,Project_Manager__r.Name, NextStageDate__c, Current_Stage_Duration__c,Estimated_Amount__c, Owner.LastName, Project_Manager__r.LastName   ';
        //String myqry1 = queryFields + ' from Opportunity  where StageName != null ' + (filterWhereClause != '' ?' AND (' + filterWhereClause +')' : '' )+' order by '+ sortingfld +' DESC LIMIT 20 OFFSET ' + offsetVar ; 
        
        
        //myList = Database.query(myqry1);
        
        
        
        fetchingStageWiseOpps();
        oppIds = new Set<String>();
        for(Opportunity op : stageWiseOppList){
            oppIds.add(op.id);
        }
        taskCounting();
        jstr = JSON.serialize(tempMethod());
        //afterPageingCode();
        
        
         
    }
    
    
    public void myNext(){
            
        if(pageNum > = totalpages){
            return;
        } 
        if(offsetVar >= recount-pagesize){
            offsetVar = 0;
            pageNum =1;
        }else{
            offsetVar += 20;
            pageNum ++;
        }
        
        if(offsetVar > 2000){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The Record size is more then 2000,Please filter your view .'));
            return;            
        }
        
        //String queryFields = 'Select CloseDate, Id, name, OwnerId, Owner.Name, NextStep, Next_Step_Due_date__c, StageName, Project_Manager__c,Project_Manager__r.Name, NextStageDate__c, Current_Stage_Duration__c,Estimated_Amount__c, Owner.LastName, Project_Manager__r.LastName   ';
        //String myqry1 = queryFields + ' from Opportunity  where StageName != null ' + (filterWhereClause != '' ?' AND (' + filterWhereClause +')' : '' )+' order by '+ sortingfld +' DESC LIMIT 20 OFFSET ' + offsetVar ; 
        
        
        //myList = Database.query(myqry1);        
        
       
        fetchingStageWiseOpps();
        oppIds = new Set<String>();
        for(Opportunity op : stageWiseOppList){
            oppIds.add(op.id);
        }
        taskCounting();
        jstr = JSON.serialize(tempMethod());
        //afterPageingCode();
       
    }
    
    
    public void myFirst(){        
        offsetVar = 0;
        pageNum =1;
        //String queryFields = 'Select CloseDate, Id, name, OwnerId, Owner.Name, NextStep, Next_Step_Due_date__c, StageName, Project_Manager__c,Project_Manager__r.Name, NextStageDate__c, Current_Stage_Duration__c,Estimated_Amount__c, Owner.LastName, Project_Manager__r.LastName   ';
        //String myqry1 = queryFields + ' from Opportunity  where StageName != null ' + (filterWhereClause != '' ?' AND (' + filterWhereClause +')' : '' )+' order by '+ sortingfld +' DESC LIMIT 20 OFFSET ' + offsetVar ; 
        
        
        //myList = Database.query(myqry1);
        
        
        
        fetchingStageWiseOpps();
        oppIds = new Set<String>();
        for(Opportunity op : stageWiseOppList){
            oppIds.add(op.id);
        }
        taskCounting();
        jstr = JSON.serialize(tempMethod());
    }
    
    public void myLast(){
        offsetVar = maxCount - Math.mod(maxCount,pageSize);
        
        if(offsetVar > 2000){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The Record size is more then 2000,Please filter your view .'));
            return;            
        }
        pageNum = totalpages ;
        //String queryFields = 'Select CloseDate, Id, name, OwnerId, Owner.Name, NextStep, Next_Step_Due_date__c, StageName, Project_Manager__c,Project_Manager__r.Name, NextStageDate__c, Current_Stage_Duration__c,Estimated_Amount__c, Owner.LastName, Project_Manager__r.LastName   ';
        //String myqry1 = queryFields + ' from Opportunity  where StageName != null ' + (filterWhereClause != '' ?' AND (' + filterWhereClause +')' : '' )+' order by '+ sortingfld +' DESC LIMIT 20 OFFSET ' + offsetVar ; 
        
        
        //myList = Database.query(myqry1);
        
        
        
        fetchingStageWiseOpps();
        oppIds = new Set<String>();
        for(Opportunity op : stageWiseOppList){
            oppIds.add(op.id);
        }
        taskCounting();
        jstr = JSON.serialize(tempMethod());
    }
    
    //Get all available list view for Account
    public SelectOption[] getAccountExistingViews(){
        return tempSetController.getListViewOptions();
    }
    
    public SelectOption[] getOppsExistingViews(){
        LIST<SelectOption> lst = new LIST<SelectOption>();
        LIST<String> tLst = new List<String>();
        Map<String,SelectOption> mapSO = new Map<String,SelectOption>();
        for(SelectOption so : tempSetController.getListViewOptions()){
            tLst.add(so.getLabel());
            mapSO.put(so.getLabel(), so);
        }
        if(tLst != null && tLst.size() > 0){
            tLst.sort();
            for(String s : tLst){
                SelectOption tso = mapSO.get(s);
                lst.add(new SelectOption(tso.getValue(),tso.getLabel()));
            }   
        }
        return lst;
    }
    
    
    
    private static String getQueryFilter(String objectName, String fltrId){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v32.0/sobjects/'+ objectName +'/listviews/' + fltrId + '/describe');
        req.setMethod('GET'); 
        req.setHeader('Authorization', 'Bearer '+ UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        Http http = new Http();
        HTTPResponse res;
        
        String resData = '';
        if(!Test.isRunningTest()){
            res = http.send(req);
            resData = res.getBody();
        }
        return resData.substringAfter('query').substringBefore('scope');
    }  
     
}