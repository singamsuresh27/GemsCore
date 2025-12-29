trigger ChangeTaskStatus on Task (after update){

    if (!(Test.isRunningTest()) || (Test.isRunningTest() &&  OppAddTaskHandler.checkTest == true)) {
    
    List<StageAutomation__c> customList = new List<StageAutomation__c>([select Name,IsChecked__c From StageAutomation__c Where Name = 'CheckTrigger' AND IsChecked__c = true Limit 1]);
    
    //Querying Record Type                                       
    RecordType rc = [select id,name from RecordType Where name = 'Sales Deliverable' limit 1];
        
    if(customList.size() > 0){
    System.debug('heelo:::::: '+Trigger.isUpdate);
        if(Trigger.isUpdate){
        System.debug('heelo::::::insert '+TaskTriggerHandlerClass.runME);
            if(TaskTriggerHandlerClass.runME){
                Boolean flag = false;
                
                Map<String,Id> oppMap = new Map<String,Id>();
                for(Task tsk : Trigger.New){
                    if(tsk.OwnerId == trigger.oldmap.get(tsk.Id).OwnerId){
                        if(tsk.Status == 'Completed'){
                            oppMap.put(tsk.Opportunity_Stage__c,tsk.WhatId);
                        }
                    }
                }
                
                List<Task> tskList = new List<Task>();
                Map<Id,Map<String,List<Task>>> stageMap = new Map<Id,Map<String,List<Task>>>();
                List<Opportunity> oppList = new List<Opportunity>();
                Map<Id,Opportunity> oppObjMap = new Map<Id,Opportunity>();
                List<Opportunity> oppListToUpdate = new List<Opportunity>();
                
                if(oppMap.size() > 0){
                    tskList = [select id,Status,Subject,WhatId,Opportunity_Stage__c from task where whatid in: oppMap.values() AND Opportunity_Stage__c in: oppMap.keyset() AND RecordTypeId =: rc.Id];
                    oppList = [select id,StageName from Opportunity where id in: oppMap.values()];
                }
                
                if(oppList.size() > 0){
                    for(Opportunity opp : oppList){
                        oppObjMap.put(opp.Id,opp);
                    }
                }
                
                if(tskList.size() > 0){
                    for(Task tsk : tskList){
                        if(stageMap.containsKey(tsk.WhatId)) {
                            Map<String,List<Task>> tempMap = stageMap.get(tsk.WhatId);
                            if(tempMap.containsKey(tsk.Opportunity_Stage__c)){
                                List<Task> tkList = tempMap.get(tsk.Opportunity_Stage__c);
                                tkList.add(tsk);
                                tempMap.put(tsk.Opportunity_Stage__c,tkList);
                            }else{
                                tempMap.put(tsk.Opportunity_Stage__c,new List<Task>{tsk});
                            }
                            
                            stageMap.put(tsk.WhatId, tempMap);
                        } else {
                            List<Task> tsks = new List<Task>{tsk};
                            stageMap.put(tsk.WhatId, new Map<String,List<Task>> { tsk.Opportunity_Stage__c => new List<Task>{tsk} });
                        }
                    }
                    
                    if(stageMap.size() > 0){
                        for(Id oppId : stageMap.Keyset()){
                            Map<String,List<Task>> tempMap = stageMap.get(oppId);
                            for(String stageName : tempMap.keyset()){
                                if(oppObjMap.get(oppId).StageName != null){
                                    if(stageName == oppObjMap.get(oppId).StageName){
                                        List<Task> tkList = tempMap.get(stageName);
                                        for(Task tk : tkList){
                                           if(tk.status != 'Completed' ){
                                               flag = true;
                                           } 
                                        }
                                        if(!flag){
                                            if(stageName.contains('Stage 1')){
                                                //Gazi added comment on 12/23
                                                //This processes is trying to resubmit the same record when it is already in approval processes
                                                //User can update a stage 1 task/sales deliverable while the record in in approval processes. 
                                                //In order to fix the bug, must check if the record is already in approval processes or not. 
                                                //Must add approved, not approved/reject, recall, and submitted processes                                                                                      
                                                /*List<ProcessInstance> pi = [SELECT Id, TargetObjectId
                                                        FROM ProcessInstance 
                                                        WHERE TargetObjectId =: oppId];
                                                        
                                                System.debug('!!!! '+pi.size());
                                                if(pi.size() == 0){
                                                    approval.ProcessSubmitRequest aprlPrcs = new Approval.ProcessSubmitRequest();     
                                                    aprlPrcs.setComments('Submitting record for approval.');
                                                    aprlPrcs.setObjectId(oppId);
                                                    approval.ProcessResult result = Approval.process(aprlPrcs);
                                                }else{
                                                    for(Task tsk : Trigger.New){
                                                        tsk.addError('Can not Update SalesDeliverable , Opportunity associated with this Sales Deliverable is already in Approval Process Please Approved it first.');
                                                    }
                                                }*/
                                                Opportunity op = oppObjMap.get(oppId);
                                                op.ApproveStatus__c = 'Ready for Approval';
                                                oppListToUpdate.add(op);    
                                            }else{
                                                TaskTriggerHandlerClass obj = new TaskTriggerHandlerClass();
                                                Opportunity op = obj.updateOppStage(oppObjMap.get(oppId));
                                                System.debug('-----> == '+op.StageName);
                                                oppListToUpdate.add(op);
                                            }
                                        }
                                    }
                                }    
                            }      
                        }
                        //Update Opportunity
                        if(oppListToUpdate.size() > 0)
                            update oppListToUpdate;
                    }
                }               
            }   
            TaskTriggerHandlerClass.runME = false;     
        }
    }
    }
}