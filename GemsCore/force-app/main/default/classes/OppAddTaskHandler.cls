public class OppAddTaskHandler{
    
    public static Boolean runTrigger = true;
    public static Boolean checkTest;
    
    //Fire on before insert event
    public void OnBeforeInsert(List<Opportunity> newOpportunities,Map<Id,Opportunity> newOpportunityMap){
        for(Opportunity opp : newOpportunities){
            
            //Give error when opportunity stage is not equal to "Stage 1"
            if(!opp.StageName.contains('Stage 1')){
                opp.StageName.addError('Default Stage should be Stage 1');
            }
        }
    }
    
    public void OnAfterInsert(List<Opportunity> newOpportunities,Map<Id,Opportunity> newOpportunityMap,List<Opportunity> oldOpportunities,Map<Id,Opportunity> oldOpportunityMap){
        
        //Querying Sales Process
        List<Sales_Processes__c> spList = new List<Sales_Processes__c>(
                                                                          [SELECT Id,Business_Unit__c,Description__c,Object__c,Is_Active__c,Is_closing_note__c,
                                                                          Stage__c,Assignee__c,Due_Date__c,Due_Date_From__c,Subject_Description__c,
                                                                          Subject__c,Type__c,User_Assignee__c,CreatedDate,Must_complete_on_Stage__c, Task_Number__c 
                                                                          FROM Sales_Processes__c WHERE Is_Active__c = true]
                                                                      );
                                               
        //Querying Record Type                                       
        RecordType rc = [select id,name from RecordType Where name = 'Sales Deliverable' limit 1];
        
        List<Task> taskList = new List<Task>();
        
        //Adding task to taskList
        if(spList.size() > 0){
            for(Opportunity opp : newOpportunities){
                for(Sales_Processes__c sp : spList){
                    Task tsk = new Task();
                    tsk.WhatId = opp.Id;
                    tsk.Opportunity_Stage__c = sp.Stage__c;
                    tsk.Must_complete_on_Stage__c = sp.Must_complete_on_Stage__c;
                    tsk.Subject_Description__c = sp.Subject_Description__c;
                    //Associating with record Type
                    tsk.RecordTypeId = rc.Id;
                    tsk.Subject = sp.Subject__c;
                    tsk.SD_Number__c = sp.Task_Number__c;
                    tsk.Is_closing_note__c = sp.Is_closing_note__c;
                    
                    //Assigning Owner On the basis of Owner,ProjectManager,AdditionalProjectManager
                    if(sp.Assignee__c == 'Owner')
                        tsk.OwnerId = opp.OwnerId;
                    if(sp.Assignee__c == 'Project Manager'){
                        if(opp.Project_Manager__c != null)
                            tsk.OwnerId = opp.Project_Manager__c;
                        else
                            tsk.OwnerId = opp.OwnerId;    
                    }
                    if(sp.Assignee__c == 'Additional Project Manager'){
                        if(opp.Additional_Project_Manager__c != null)
                            tsk.OwnerId = opp.Additional_Project_Manager__c;
                        else
                            tsk.OwnerId = opp.OwnerId;
                    }
                    
                    //Due Date calculation on the basis of SalesDeliverable fields
                    if(sp.Due_Date_From__c == 'Opportunity Create Date'){
                        Date dt = opp.CreatedDate.date();
                        tsk.ActivityDate = dt.addDays(Integer.valueOf(sp.Due_Date__c));
                    }
                    if(sp.Due_Date_From__c == 'Close Date'){
                        tsk.ActivityDate = opp.CloseDate.addDays(Integer.valueOf(sp.Due_Date__c));
                    }
                    if(sp.Due_Date_From__c == 'Task Create Date'){
                        Date dt = sp.CreatedDate.date();
                        tsk.ActivityDate = dt.addDays(Integer.valueOf(sp.Due_Date__c));
                    }
                    if(sp.Due_Date_From__c == 'Opportunity Stage Change Date'){
                        tsk.ActivityDate = System.Today().addDays(Integer.valueOf(sp.Due_Date__c));
                    }
                    
                    //Assigning Stage
                    if(opp.StageName == sp.Stage__c){
                        tsk.Status = 'In Progress';
                    }else{
                        if(!tsk.Must_complete_on_Stage__c)
                            tsk.Status = 'In Progress';
                        else
                            tsk.Status = 'Inactive';
                    }
                    
                    taskList.add(tsk);
                }
            }
            //Inserting task
            insert taskList;
        }
    }
    
    public void OnBeforeUpdate(List<Opportunity> newOpportunities,Map<Id,Opportunity> newOpportunityMap,List<Opportunity> oldOpportunities,Map<Id,Opportunity> oldOpportunityMap){
        Set<String> closeStage = new Set<String>();
        Map<Id,String> oppOwnerMap = new Map<Id,String>();
        Map<Id,String> oppOwnerTypeMap = new Map<Id,String>();
        
        for(Opportunity opp : newOpportunities){
            //Checking if opportunity Owner,Project Manager,APM get changed
            if(opp.OwnerId != oldOpportunityMap.get(opp.Id).OwnerId){
                oppOwnerMap.put(opp.Id,opp.OwnerId);
                oppOwnerTypeMap.put(opp.Id,'Owner');
            }
            if(opp.Additional_Project_Manager__c != oldOpportunityMap.get(opp.Id).Additional_Project_Manager__c){
                oppOwnerMap.put(opp.Id,opp.Additional_Project_Manager__c);
                oppOwnerTypeMap.put(opp.Id,'Additional Project Manager');
            }
            if(opp.Project_Manager__c != oldOpportunityMap.get(opp.Id).Project_Manager__c){
                oppOwnerMap.put(opp.Id,opp.Project_Manager__c);
                oppOwnerTypeMap.put(opp.Id,'Project Manager');
            }
            
            System.debug('----oppstage = '+opp.StageName);
            
            //Moving other stages forward and backward
            if(opp.StageName != 'Closed Lost'){
                if(opp.StageName != oldOpportunityMap.get(opp.Id).StageName){
                    String newStage = '';
                    String oldStage = '';
                    
                    if(opp.StageName.contains('Closed Won')){
                        newStage = '6';
                    }else{
                        newStage = opp.StageName.subStringAfter('Stage ');
                        newStage = newStage.subString(0,1);
                    }
                    
                    if(oldOpportunityMap.get(opp.Id).StageName.contains('Closed Won')){
                        oldStage= '6';
                    }else if(oldOpportunityMap.get(opp.Id).StageName.contains('Closed Lost')){
                        oldStage = '7';
                    }else{
                        oldStage = oldOpportunityMap.get(opp.Id).StageName.subStringAfter('Stage ');
                        oldStage = oldStage.subString(0,1);
                    }    
                    
                    //Checking condition to move stage backward
                    if(Integer.valueOf(newStage) < Integer.valueOf(oldStage)){
                        moveStageBackward(opp,oldOpportunityMap.get(opp.Id));     
                    }
                    //Checking condition to move stage forward
                    if(Integer.valueOf(newStage) > Integer.valueOf(oldStage)){
                        moveStageForward(opp,oldOpportunityMap.get(opp.Id));
                    }
                    
                }
            }else{
                //Creating a map of "Closed Lost" opportunities
                closeStage.add(oldOpportunityMap.get(opp.Id).StageName);
            }
            
            //For moving stage1 to stage2 when record get approved by manager
            if(opp.ApproveStatus__c != oldOpportunityMap.get(opp.Id).ApproveStatus__c && opp.ApproveStatus__c == 'Approved'){
                if(opp.StageName.contains('Stage 1')){
                    opp.StageName = 'Stage 2 - Needs Identified & Accepted';
                    //opp.ApproveStatus__c = '';
                    moveStageForward(opp,oldOpportunityMap.get(opp.Id));
                }
            }
        }
        
        //If there is any change in Owner,Project Manager,APM then change owner of Salesdeliverable
        if(oppOwnerMap.size() > 0){
            List<Task> taskList = [select id,WhatId,Opportunity_Stage__c,Status,OwnerId
                                            from Task 
                                            Where WhatId in: oppOwnerMap.keyset()
                                      ];
                                      
            List<Task> tempTaskList = new List<Task>();
            
            Map<Id,List<Task>> taskMap = new Map<Id,List<Task>>();
            if(taskList.size() > 0){
                for(Task tsk: taskList){                      
                    if(taskMap.containsKey(tsk.WhatId)){
                        List<Task> tkList = taskMap.get(tsk.WhatId);
                        tkList.add(tsk);
                        taskMap.put(tsk.WhatId,tkList);
                    }else{
                        taskMap.put(tsk.WhatId,new List<Task>{tsk});
                    }
                }
            }
            
            if(taskMap.size() > 0){
                for(Id oppId : oppOwnerMap.keyset()){
                    List<Task> tkList = taskMap.get(oppId);
                    if(tkList.size() > 0){
                        for(Task tk:tkList){
                            // Had to remove this because if task owner is deactivated SFDC does not allow to edit task. So all task needs to move to new owner
                            //if(tk.Status != 'Completed'){  
                                if(oppOwnerTypeMap.get(oppId) == 'Owner' ){
                                    if(tk.OwnerId == oldOpportunityMap.get(oppId).OwnerId){
                                        tk.OwnerId = oppOwnerMap.get(oppId);
                                        tempTaskList.add(tk);
                                    }
                                }
                                if(oppOwnerTypeMap.get(oppId) == 'Additional Project Manager' ){
                                    if(tk.OwnerId == oldOpportunityMap.get(oppId).Additional_Project_Manager__c){
                                        tk.OwnerId = oppOwnerMap.get(oppId);
                                        tempTaskList.add(tk);
                                    }
                                }
                                if(oppOwnerTypeMap.get(oppId) == 'Project Manager' ){
                                    if(tk.OwnerId == oldOpportunityMap.get(oppId).Project_Manager__c){
                                        tk.OwnerId = oppOwnerMap.get(oppId);
                                        tempTaskList.add(tk);
                                    }
                                }
                                
                            //}
                        }
                    }
                }
            }
            if(tempTaskList.size() > 0){
                update tempTaskList;
            }        
        }
            
        //when opportunity's stage set to "closed lost"
        //Gazi changing from  Where Opportunity_Stage__c in: closeStage  to  Where Opportunity_Stage__c in: closeStage And WhatId In : Trigger.oldMap.keySet() 
        
        //02/07/2015 Changed By Bala
        Integer count = 0;
        if(closeStage.size() > 0){
            List<Task> taskList = [select id,WhatId,Opportunity_Stage__c,Status 
                                    from Task 
                                    Where Opportunity_Stage__c in: closeStage and WhatId In : Trigger.oldMap.keySet()
                                  ];
                if(taskList.size() > 0){
                    for(Task tsk : taskList){
                        //if( (tsk.Status != 'Completed') && (tsk.Status != 'Inactive'))
                        
                        if(tsk.Status != 'Completed'){
                            tsk.Status = 'Inactive';  
                        }else{
                            count++; //02/07/2015 Changed By Bala
                        } 
                    }
                    //02/07/2015 Changed By Bala
                    if(count != tasklist.size())
                        update taskList;
                }    
        }
        
    }
    
    //Fire when opportunity stage move backward
    public void moveStageBackward(Opportunity opp, Opportunity oldOpp){
        //Creating list of stages
        TaskTriggerHandlerClass obj = new TaskTriggerHandlerClass();
        List<String> stageList = new List<String>();
        List<SelectOption> stageOptions = obj.StageValue();
        for(SelectOption so : stageOptions){
            stageList.add(so.getValue());
        }
        
            
            
        Set<String> stageSet = new Set<String>();
        
            String newStage = '';
            String oldStage = '';
            //Getting value for new Stage
            if(opp.StageName.contains('Closed Won')){
                newStage = '6';
            }else{
                newStage = opp.StageName.subStringAfter('Stage ');
                newStage = newStage.subString(0,1);    
            }
            
            //Getting value for old Stage
            if(oldOpp.StageName.contains('Closed Won')){
                oldStage= '6';
            }else if(oldOpp.StageName.contains('Closed Lost')){
                oldStage = '7';
            }else{
                oldStage = oldOpp.StageName.subStringAfter('Stage ');
                oldStage = oldStage.subString(0,1);
            }
            
            //Creating a set of stages from oldStage to newStage
            for(Integer i = Integer.valueOf(newStage)-1;i<Integer.valueOf(oldStage);i++){
                stageSet.add(stageList.get(i));   
            }  
            
            if(opp.StageName.contains('Stage 1'))
                opp.ApproveStatus__c = '';
                
        
        //Query all the task between newStage to oldStage
        List<Task> taskList = [select id,WhatId,Opportunity_Stage__c,Status 
                                        from Task 
                                        Where Opportunity_Stage__c in: stageSet AND WhatId =: opp.Id
                                  ];
                                  
        List<Task> tempTaskList = new List<Task>();
       
        //Creating a map of opportunity id to task list
        Map<Id,List<Task>> taskMap = new Map<Id,List<Task>>();
        if(taskList.size() > 0){
            for(Task tsk: taskList){                      
                if(taskMap.containsKey(tsk.WhatId)){
                    List<Task> tkList = taskMap.get(tsk.WhatId);
                    tkList.add(tsk);
                    taskMap.put(tsk.WhatId,tkList);
                }else{
                    taskMap.put(tsk.WhatId,new List<Task>{tsk});
                }
            }
        }else{
            createSalesDeliverables(stageSet,opp);
        }
        
        //Updating the task if opportunity stage matches to current task stage to "In Progress" otherwise "Inactive"
        if(taskMap.size() > 0){
            
                List<Task> tskList = taskMap.get(opp.Id);
                if(tskList.size() > 0){
                    for(Task tk : tskList){
                        if(opp.StageName == tk.Opportunity_Stage__c){
                            tk.Status = 'In Progress';
                        }else{
                            if(tk.Opportunity_Stage__c == oldOpp.StageName){
                                if(tk.Status != 'Completed')
                                    tk.Status = 'Inactive';
                            }else{
                                tk.Status = 'Inactive';
                            }
                        }
                        tempTaskList.add(tk);
                    }
                }
            
            if(tempTaskList.size() > 0){
                update tempTaskList;
            }
        }
    }
    
    //Fire when opportunity stage moves forward
    public void moveStageForward(Opportunity opp,Opportunity oldOpp){
        Set<String> stageSet = new Set<String>();
        Map<String,List<Task>> stageTaskMap = new Map<String,List<Task>>();
        Boolean flag = false;
        
        //Querying opportunity's oldstage tasks
        List<Task> taskList = [select id,WhatId,Opportunity_Stage__c,Status 
                                        from Task 
                                        Where WhatId =: opp.Id AND Opportunity_Stage__c =: oldOpp.StageName];
        
        //Checking whether all the task of an opportunity is completed or not
        if(taskList.size() > 0){
            for(Task tsk : taskList){
                //Gazi made change on 4/28/2015 because user ware able to move OPP from stage 1 to stage 2 without approval
                //if(tsk.Status != 'Completed'){
                if( (tsk.Status != 'Completed') || (opp.ApproveStatus__c == 'Ready for Approval') || (opp.ApproveStatus__c == 'Recall') || (opp.ApproveStatus__c == 'Rejected')){
                    flag = true;
                }
            }        
        }
        
        
        if(flag){
            //if all the task are not completed then give error
            //Also give error when OPP is on stage 1 and approval status is Ready for Approval. 
            //Because stage 1 to stage 2 move is different then all other stage move.
            //For all other stages system automacally moves the stage when all task are completed.
            //For stage1 to stage 2 all task needs to be completed and user have to submit for approval. When approved
            //it moves to stage 2
            
            //Gazi made change on 4/28/2015 because user ware able to move OPP from stage 1 to stage 2 without approval
            //if (opp.StageName != 'Closed Lost'){
            if ((opp.StageName != 'Closed Lost') || (opp.ApproveStatus__c == 'Ready for Approval') || (opp.ApproveStatus__c == 'Recall') || (opp.ApproveStatus__c == 'Rejected')){              
                opp.StageName.addError('You can only change stage to "Closed Lost" or "Submit for Approval" to move from Stage 1 to Stage 2.');
            }else{
                //if opportunity stage is closed lost,set the close date to today
                opp.closeDate = System.today();
            }
        }else{
            if(opp.StageName == 'Closed Won'){
                //if opportunity stage is closed won,set the close date to today
                opp.closeDate = System.today();    
            }else{
                //Getting the new Stage value            
                String completedStage = '';
                String notCompletedStage = '';
                String newStage = opp.StageName.subStringAfter('Stage ');
                newStage = newStage.subString(0,1);
                
                //Creating set of all the stages after newStage
                for(Integer i=Integer.valueOf(newStage);i<=5;i++){
                    stageSet.add(stageMapWithIndex().get(i));
                }
                
                //Querying all the tasks associated with stageSet
                List<Task> tskList = [select id,WhatId,Opportunity_Stage__c,Status 
                                                from Task 
                                                Where WhatId =: opp.Id AND Opportunity_Stage__c in: stageSet];
                                                
                //Creating a map of opportunity stage to list of task
                if(tskList.size() > 0){
                    for(Task tsk : tskList){
                        if(stageTaskMap.containsKey(tsk.Opportunity_Stage__c)){
                            List<Task> tkList = stageTaskMap.get(tsk.Opportunity_Stage__c);
                            tkList.add(tsk);
                            stageTaskMap.put(tsk.Opportunity_Stage__c,tkList);
                        }else{
                            stageTaskMap.put(tsk.Opportunity_Stage__c,new List<Task>{tsk});
                        }
                    }        
                }
                
                //Sorting the list of stageTaskMap keyset
                List<String> tempStageList = new List<String>();
                if(stageTaskMap.size() > 0){
                    tempStageList.addAll(stageTaskMap.KeySet());
                    tempStageList.sort();
                }
                
                //Checking whether all the task of current stage is completed or not,and whether forward stages tasks arecompleted
                //or not.Move stage to other stage on completing of all tasks
                if(tempStageList.size() > 0){
                    for(String stg : tempStageList){
                        List<task> tkList = stageTaskMap.get(stg);
                            
                        if(tkList.size() > 0){
                            if(childForLoop(tkList)){
                                notCompletedStage = stg;
                                break;
                            }else{
                                completedStage = stg;
                            }
                        }
                    }
                    if(completedStage != ''){
                        if(completedStage.contains('Stage 5')){
                            opp.StageName = 'Closed Won';
                            opp.closeDate = System.today();
                        }
                    }
                    if(notCompletedStage != ''){
                        opp.StageName = notCompletedStage;
                        List<task> tkList = stageTaskMap.get(notCompletedStage);
                        if(tkList.size() > 0){
                            for(Task tk : tkList){
                                if(tk.Status != 'Completed'){
                                    tk.Status = 'In Progress';
                                }
                            }
                            update tkList;
                        }
                    }
                }
                
            }//inner else block end
            
        }//else block end
        
        
    }
    
    public void createSalesDeliverables(Set<String> stageSet,Opportunity opp){
        //Querying Sales Process
        List<Sales_Processes__c> spList = new List<Sales_Processes__c>(
                                                                          [SELECT Id,Business_Unit__c,Description__c,Object__c,Is_Active__c,Is_closing_note__c,
                                                                          Stage__c,Assignee__c,Due_Date__c,Due_Date_From__c,Subject_Description__c,
                                                                          Subject__c,Type__c,User_Assignee__c,CreatedDate,Must_complete_on_Stage__c, Task_Number__c 
                                                                          FROM Sales_Processes__c WHERE Is_Active__c = true]
                                                                      );
                                               
        //Querying Record Type                                       
        RecordType rc = [select id,name from RecordType Where name = 'Sales Deliverable' limit 1];
        
        List<Task> taskList = new List<Task>();
        
        //Adding task to taskList
        if(spList.size() > 0){
            
            for(Sales_Processes__c sp : spList){
                Task tsk = new Task();
                tsk.WhatId = opp.Id;
                tsk.Opportunity_Stage__c = sp.Stage__c;
                tsk.Must_complete_on_Stage__c = sp.Must_complete_on_Stage__c;
                tsk.Subject_Description__c = sp.Subject_Description__c;
                //Associating with record Type
                tsk.RecordTypeId = rc.Id;
                tsk.Subject = sp.Subject__c;
                tsk.SD_Number__c = sp.Task_Number__c;
                tsk.Is_closing_note__c = sp.Is_closing_note__c;
                
                //Assigning Owner On the basis of Owner,ProjectManager,AdditionalProjectManager
                if(sp.Assignee__c == 'Owner')
                    tsk.OwnerId = opp.OwnerId;
                if(sp.Assignee__c == 'Project Manager'){
                    if(opp.Project_Manager__c != null)
                        tsk.OwnerId = opp.Project_Manager__c;
                    else
                        tsk.OwnerId = opp.OwnerId;    
                }
                if(sp.Assignee__c == 'Additional Project Manager'){
                    if(opp.Additional_Project_Manager__c != null)
                        tsk.OwnerId = opp.Additional_Project_Manager__c;
                    else
                        tsk.OwnerId = opp.OwnerId;
                }
                
                //Due Date calculation on the basis of SalesDeliverable fields
                if(sp.Due_Date_From__c == 'Opportunity Create Date'){
                    Date dt = opp.CreatedDate.date();
                    tsk.ActivityDate = dt.addDays(Integer.valueOf(sp.Due_Date__c));
                }
                if(sp.Due_Date_From__c == 'Close Date'){
                    tsk.ActivityDate = opp.CloseDate.addDays(Integer.valueOf(sp.Due_Date__c));
                }
                if(sp.Due_Date_From__c == 'Task Create Date'){
                    Date dt = sp.CreatedDate.date();
                    tsk.ActivityDate = dt.addDays(Integer.valueOf(sp.Due_Date__c));
                }
                if(sp.Due_Date_From__c == 'Opportunity Stage Change Date'){
                    tsk.ActivityDate = System.Today().addDays(Integer.valueOf(sp.Due_Date__c));
                }
                
                //Assigning Stage
                if(stageSet.contains(sp.Stage__c)){
                    if(opp.StageName == sp.Stage__c){
                        tsk.Status = 'In Progress';
                    }else{
                        if(!tsk.Must_complete_on_Stage__c)
                            tsk.Status = 'In Progress';
                        else
                            tsk.Status = 'Inactive';
                    }
                }else{
                    tsk.Status = 'Completed';
                }
                
                if(!opp.StageName.contains('Stage 1'))
                    opp.ApproveStatus__c = 'Approved';
                    
                taskList.add(tsk);
            }
            
            //Inserting task
            insert taskList;
        }
    }
    
    //Child for loop for moving stages forward
    public Boolean childForLoop(List<Task> tkList){
        for(Task tk : tkList){
            if(tk.Status != 'Completed'){
                return true;  
            }
        }
        return false;
    }
    
    //Map of stages
    public Map<Integer,String> stageMapWithIndex(){
        Map<Integer,String> stageMap = new Map<Integer,String>{
            1=>'Stage 1 - Qualified',
            2=>'Stage 2 - Needs Identified & Accepted',
            3=>'Stage 3 - Solution Presented & Accepted',
            4=>'Stage 4 - Specific Price / Budget',
            5=>'Stage 5 - Order Placement',
            6=>'Closed Won'
        };
        
        return stageMap;
    }
    
}