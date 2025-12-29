public class ViewAllTaskController{
    public LIST<TaskModel> modelList {get;set;}
    public String oppName {get;set;}
    public String oppId {get;set;}
    public boolean isEditMode {get;set;}
    public Integer editTaskIndex {get;set;}
    public String selectedAtch {get;set;} 
    public String opportunityName {get;set;}
    public String acctName {get;set;}
    public String oppOwner {get;set;}
    public String projManager {get;set;}
    public String nextStep {get;set;}
    public String nextStepDate {get;set;}
    public String stage {get;set;}
    public String closDate {get;set;}
    public Decimal EstimatedAmount {get;set;}
    public String oppNumber {get;set;}
    public String opType {get;set;}
    public String opMarket {get;set;}
    public String opProductModel {get;set;}
    public Decimal opUnitPrice {get;set;}
    public String opAppDetail {get;set;}
    public String opComTrigger {get;set;}
    public String opKeyDecMaker {get;set;}
    public boolean oppBudgAvailable {get;set;}
    public String opProjStartDate {get;set;}
    public String opProtoDate {get;set;}
    public String opLaunchDate {get;set;}
    public String opProjTimeline {get;set;}
    public String opPerProdLaunchDate {get;set;}   
    Map<String,TaskComment__c> mapTaskComment;
    RecordType recType ; 
    public ViewAllTaskController(){
        oppId = ApexPages.currentPage().getParameters().get('id');
        isEditMode = false;
        editTaskIndex =-1;
        //Select o.StageName, o.Project_Manager__r.Name, o.Project_Manager__c, o.Next_Step_Due_date__c, o.NextStep, o.Name, o.Estimated_Amount__c, o.CloseDate, o.Account.Name, o.AccountId From Opportunity o
        
        if(oppId != null || oppId != ''){
            Opportunity op = [Select o.name,o.Opportunity_Number__c, o.Owner.Name, o.Account.Name, o.Project_Manager__r.Name, o.Next_Step_Due_date__c, o.NextStep, o.Estimated_Amount__c, o.CloseDate, o.Application_Detail__c,o.Market__c,o.Product_Model__c,o.Type,o.Unit_Price__c, o.Commercial_Triggers__c, o.Key_Decision_Maker__c,o.Budget_Availability__c, o.Project_Start_Date__c,o.Proto_Type_Need_by__c, o.Product_Launch__c,o.Pre_production_Launch__c,o.Project_Timeline__c, Product_Model__r.Name from Opportunity o where id =: oppId];
            oppName = op.name + ' (' + op.Opportunity_Number__c + ')'; 
            opportunityName = op.name;
            acctName = op.Account.Name;
            oppOwner = op.Owner.Name;
            projManager = op.Project_Manager__r.Name;
            nextStep =  op.NextStep;
            nextStepDate= op.Next_Step_Due_date__c.format(); 
            EstimatedAmount =  op.Estimated_Amount__c; 
            oppNumber = op.Opportunity_Number__c; 
            closDate = op.CloseDate.format();
            opType = op.Type;
            opMarket = op.Market__c;
            opProductModel=op.Product_Model__r.Name;
            opUnitPrice = op.Unit_Price__c;
            opAppDetail = op.Application_Detail__c;
            opComTrigger = op.Commercial_Triggers__c;
            opKeyDecMaker = op.Key_Decision_Maker__c;
            oppBudgAvailable = op.Budget_Availability__c;
            if(op.Project_Start_Date__c != null )
                opProjStartDate = op.Project_Start_Date__c.format();
            if(op.Proto_Type_Need_by__c != null )    
                opProtoDate = op.Proto_Type_Need_by__c.format();
            if(op.Product_Launch__c != null )    
                opLaunchDate = op.Product_Launch__c.format();
            opProjTimeline = op.Project_Timeline__c;
            if(op.Pre_production_Launch__c != null )    
                opPerProdLaunchDate = op.Pre_production_Launch__c.format();
            fillModel();
        }
    }
        
    public void editTask(){
        isEditMode = true;       
    }
       
    private void fillModel(){
        recType = [select id from RecordType Where SObjectType='Task' and Name = 'Sales Deliverable' limit 1];
            
        Set<String> taskIds = new Set<String>();
        for(Task tsk : [Select id from Task where recordTypeId =: recType.id and WhatId =: oppId ORDER BY SD_Number__c]){
            taskIds.add(tsk.id);
        }
        mapTaskComment = new Map<String,TaskComment__c>();
        for(TaskComment__c tskcmt : [Select id, Body__c,TaskId__c from TaskComment__c where TaskId__c in : taskIds]){
            mapTaskComment.put(tskcmt.TaskId__c, tskcmt);
        }
        modelList = new LIST<TaskModel>();
        Integer i=0;    
        for(Task tsk : [select id,Subject,Subject_Description__c, ownerId,Owner.Name,ActivityDate,whatId, Status,Status_Color__c,Opportunity_Stage__c,SD_Number__c, (Select id,Name,Description,LastModifiedBy.Name, CreatedBy.Name,Owner.Name,CreatedDate,LastModifiedDate from Attachments)   from Task where Opportunity_Stage__c != null and whatId =: oppId and recordTypeId =: recType.id ORDER BY SD_Number__c]){
            TaskModel model = new TaskModel();
            model.idx = i;
            model.taskObj = tsk;
            system.debug('-----> '+tsk.Subject);
            model.selStatus = tsk.Status;
            
            if(mapTaskComment.containsKey(tsk.id)){
                model.taskCommentObj = new TaskComment__c();
                model.taskCommentObj = mapTaskComment.get(tsk.id);
                if(tsk.Subject == 'Strategy To Win'){
                   system.debug('-----> model.taskCommentObj.Body__c '+model.taskCommentObj.Body__c);
                   if(model.taskCommentObj.Body__c == null || model.taskCommentObj.Body__c == '')                
                       model.taskCommentObj.Body__c = '<b>Do Not Delete Original Questions: You Must Answer All 4 Items</b><br/>'+
                                        '1. What\'s the priority for this project within your company?<br/>'+
                                        '[Q1 answer]<br/>'+
                                        '2. Who is Gems\' competition, what are their advantages / disadvantages and how will we win against them?<br/>'+
                                        '[Q2 answer].<br/>'+
                                        '3. What price is Gems offering vs. the customer\'s target price?<br/>'+
                                        '[Q3 answer].<br/>'+
                                        '4. How will Gems win (outline value proposition and key differentiators that will give Gems the advantage)?<br/>'+
                                        '[Q4 answer].';
                                        
                }
            }else{
                model.taskCommentObj = new TaskComment__c();
                if(tsk.Subject == 'Strategy To Win'){
                   system.debug('-----> model.taskCommentObj.Body__c '+model.taskCommentObj.Body__c);
                   if(model.taskCommentObj.Body__c == null || model.taskCommentObj.Body__c == '')                
                       model.taskCommentObj.Body__c = '<b>Do Not Delete Original Questions: You Must Answer All 4 Items</b><br/>'+
                                        '1. What\'s the priority for this project within your company?<br/>'+
                                        '[Q1 answer]<br/>'+
                                        '2. Who is Gems\' competition, what are their advantages / disadvantages and how will we win against them?<br/>'+
                                        '[Q2 answer].<br/>'+
                                        '3. What price is Gems offering vs. the customer\'s target price?<br/>'+
                                        '[Q3 answer].<br/>'+
                                        '4. How will Gems win (outline value proposition and key differentiators that will give Gems the advantage)?<br/>'+
                                        '[Q4 answer].';
                                        
                }
            }
            //model.taskCommentObj = mapTaskComment.containsKey(tsk.id) ?mapTaskComment.get(tsk.id) :new TaskComment__c();
            modelList.add(model);
            i++;
        }    
        
    }
       
    public void cancelEdit(){
        isEditMode = false;
        editTaskIndex =-1;
    }
    
    public void saveTask(){
        LIST<Task> tempTaskList = new LIST<Task>();
        LIST<TaskComment__c> tempTaskCommentList = new LIST<TaskComment__c>();
        LIST<Attachment> tempAttList = new LIST<Attachment>(); 
        for(TaskModel m : modelList){
             if(m.selStatus != null && m.selStatus != ''){
                 m.taskObj.Status = m.selStatus;
             }
             tempTaskList.add(m.taskObj);
             /*if(m.taskCommentObj != null){
                   
                 tempTaskCommentList.add(m.taskCommentObj);
             }*/
             
             for(Attachment at : m.atchList){
                 if(at.body != null && at.Name != null){
                     at.parentId = m.taskObj.id;
                     at.ownerId = m.taskObj.ownerId;
                     tempAttList.add(at);    
                 }    
             }
             
             if(!mapTaskComment.containsKey(m.taskObj.id)){
                if(m.taskCommentObj != null){                         
                    m.taskCommentObj.TaskId__c = m.taskObj.Id;
                    m.taskCommentObj.Opportunityid__c = m.taskObj.WhatId;
                    m.taskCommentObj.Subject__c = m.taskObj.subject;
                    m.taskCommentObj.OwnerId = m.taskObj.OwnerId;
                    m.taskCommentObj.Due_Date__c = m.taskObj.ActivityDate;
                    m.taskCommentObj.Status__c = m.taskObj.status;
                }
             }
             System.debug('-----> m.taskCommentObj '+m.taskCommentObj);
             tempTaskCommentList.add(m.taskCommentObj);
        }
        
        if(tempAttList!= null && tempAttList.size() > 0){
            insert tempAttList;
        }
        
        
        if(tempTaskList != null && tempTaskList.size() > 0){
            update tempTaskList;
        }
        
        if(tempTaskCommentList != null && tempTaskCommentList.size() > 0){
            upsert tempTaskCommentList;
        }
        isEditMode = false;
        fillModel();
    }
    
    public void settingAttachmentId(){
        System.debug('---> selectedAtch' +   selectedAtch);
    }
    
    public pageReference deleteAttachment(){
        if(selectedAtch != null && selectedAtch != ''){
            delete [select id from Attachment where id =: selectedAtch];
        }
        return new PageReference('/apex/ViewAllTaskPage?id=' + oppId);
    }
    
    public class TaskModel{
        public Integer idx {get;set;}
        public Task taskObj {get;set;}
        public String selStatus {get;set;}
        public TaskComment__c taskCommentObj {get;set;}
        public LIST<Attachment> atchList {get;set;}
        
        public TaskModel(){
            atchList = new LIST<Attachment>();
            for(Integer i=1; i<=3; i++){
                atchList.add(new Attachment());
            }    
        }
    }
    
    
}