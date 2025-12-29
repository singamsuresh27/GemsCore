public class OpportunityInlineController{
    public Map<String,List<WrapperClass>> stageTaskMap{get;set;}
    public List<String> stageList{get;set;}
    
    public OpportunityInlineController(ApexPages.StandardController sc){
        stageList = new List<String>();
        stageTaskMap = new Map<String,List<WrapperClass>>();
        Opportunity opp = (Opportunity)sc.getRecord();
        
        List<Task> taskList = new List<Task>();
        if(opp.Id != null){
            RecordType rc = [select id,name from RecordType Where name = 'Sales Deliverable' limit 1];
            
            taskList = [select id,WhatId,Opportunity_Stage__c,Status,ActivityDate,Subject,Priority,Owner.Name,Status_Color__c 
                                        from Task
                                        Where whatId =: opp.Id AND RecordTypeId =: rc.Id Order By SD_Number__c];
        }                                
        if(taskList.size() > 0){
            for(Task tsk : taskList){
                System.debug('---> Status_Color__c '+tsk.Status_Color__c);
                if(stageTaskMap.containsKey(tsk.Opportunity_Stage__c)){
                    WrapperClass wc = new WrapperClass();
                    List<WrapperClass> tkList = stageTaskMap.get(tsk.Opportunity_Stage__c);
                    wc.tsk = tsk;
                    wc.dueDate = tsk.ActivityDate.format();
                    
                    tkList.add(wc);
                    stageTaskMap.put(tsk.Opportunity_Stage__c,tkList);
                }else{
                    WrapperClass wc = new WrapperClass();
                    wc.tsk = tsk;
                    wc.dueDate = tsk.ActivityDate.format();
                    stageTaskMap.put(tsk.Opportunity_Stage__c,new List<WrapperClass>{wc});
                }
            }
        }
        
        List<String> tempStageList = new List<String>();
        if(stageTaskMap.size() > 0){
            if(stageTaskMap.size() > 0){
                tempStageList.addAll(stageTaskMap.KeySet());
                tempStageList.sort();
            }
        }
        
        if(tempStageList.size() > 0){
            List<WrapperClass> stgList = new List<WrapperClass>();
            for(String stg : tempStageList){
                WrapperClass wc = new WrapperClass();
                wc.stage = stg.subStringBefore(' -');
                stgList.add(wc);
            }
            if(stgList.size() > 0){
                stageTaskMap.put('Coaching',stgList);    
            }
            
            tempStageList.add('Coaching');
            System.debug('##### '+tempStageList);
        }
        
        stageList = tempStageList;
        
    }
    
    public class WrapperClass{
        
        public String stage{get;set;}
        public Task tsk{get;set;}
        public String dueDate{get;set;}
        
    }
}