public class EditTaskInlineController{
    public String selectedStatus{get;set;}
    public Task task{get;set;}
    public List<Attachment> attList{get;set;}
    public List<Attachment> attTaskList{get;set;}
    public TaskComment__c tcomment{get;set;}
    public Boolean showPanel{get;set;}
    public Attachment attach{get;set;}
    public Id taskId{get;set;}
    public Boolean hideButton{get;set;}
    public Boolean showAttDetail{get;set;}
    public Opportunity opp{get;set;}
    public boolean isSD {get;set;}
    String check;
    
    //Constructor without parameter
    public EditTaskInlineController(){
        //To update existing attachment
        showAttDetail = false;
        attach = new Attachment();    
        String attId = ApexPages.CurrentPage().getParameters().get('attId');
        String showAttDet = ApexPages.CurrentPage().getParameters().get('showAttDetail');
        if(showAttDet != null && showAttDet.trim().length() > 0){
            showAttDetail = true;
        }
        if(attId != null && attId.trim().length() > 0){
            showAtt(attId);
        }
        
    }
    
    //Constructor with parameter
    public EditTaskInlineController(ApexPages.StandardController sc){
        showPanel = false;
        hideButton = false;
        String checkButton = ApexPages.CurrentPage().getParameters().get('hideButton');
        String checkPanel = ApexPages.CurrentPage().getParameters().get('showPanel');
        if(checkButton != null && checkButton.trim().length() > 0){
            if(checkButton == 'true')
                hideButton = true;
        }
        if(checkPanel != null && checkPanel.trim().length() > 0){
            if(checkPanel == 'true')
                showPanel = true;
        }
        
        //List for adding new attachment to task
        attList = new List<Attachment>{new Attachment(),new Attachment(),new Attachment()};
        tcomment = new TaskComment__c();
        attTaskList = new List<Attachment>();
        opp = new Opportunity();
        
        //Getting existing task record
        Task tsk = (Task)sc.getRecord();
        if(tsk != null){
            //Gazi added SD_Number__c, Opportunity_Stage__c to the SOQL 12/19/2014
            List<Task> tskList = [select id,status,subject,Owner.Name,ActivityDate,Description,Subject_Description__c,What.Name, SD_Number__c, Opportunity_Stage__c,Is_closing_note__c from task where id =: tsk.Id];
            if(tskList.size() > 0){
                task = tsklist.get(0);
                if(task.status == 'Completed'){
                    selectedStatus = 'Completed';
                }
            }
        }
        
        if(task.Subject_Description__c == 'Strategy To Win'){
           tcomment.Body__c = '<b>Do Not Delete Original Questions: You Must Answer All 4 Items</b><br/>'+
                                '1. What\'s the priority for this project within your company?<br/>'+
                                '[Q1 answer]<br/>'+
                                '2. Who is Gems\' competition, what are their advantages / disadvantages and how will we win against them?<br/>'+
                                '[Q2 answer].<br/>'+
                                '3. What price is Gems offering vs. the customer\'s target price?<br/>'+
                                '[Q3 answer].<br/>'+
                                '4. How will Gems win (outline value proposition and key differentiators that will give Gems the advantage)?<br/>'+
                                '[Q4 answer].';
           System.debug('-------> '+ tcomment.Body__c);
        }
               
        if(task.Is_closing_note__c){
        //Querying Opportunity Object
            List<Opportunity> oppList = [SELECT OPP_closing_note__c,StageName FROM Opportunity WHERE Id =: task.WhatId limit 1];
            if(oppList.size() > 0)
                opp = oppList.get(0);
        }   
        //Querying attachments associated with existing task
        if(tsk != null){
            attTaskList =  [select Id,Description,Body,Name,Owner.Id,Owner.Name from Attachment where parentId =:tsk.Id];         
        }
        
        
        //Querying body text of associated task
        if(tsk != null){
           List<TaskComment__c> tcList = [select id,Body__c,TaskId__c from TaskComment__c where TaskId__c =: tsk.Id];
           if(tcList.size() > 0){
               tcomment = tcList.get(0);
               
           }
        }
    }
    
    
    //Method to redirect whether on SalesDeliverable or General Task
    public PageReference checkSD(){
        if(task != null){
            List<Task> tskList = [select id,RecordType.Name from task where id =: task.Id];
            if(tskList.size() > 0){
                Task tk = tskList.get(0);    
                if(tk.RecordType.Name == 'General'){
                    PageReference pg = new PageReference('/'+tk.Id+'/e?retURL=/'+tk.Id);
                    pg.getParameters().put('nooverride','1');
                    return pg;
                }
                if(tk.RecordType.Name == 'Sales Deliverable'){
                    PageReference pg = new PageReference('/apex/EditTaskInlinePage?id='+tk.Id+'&hideButton=true&showPanel=true');
                    pg.setRedirect(true);
                    return pg;
                }
                PageReference pg = new PageReference('/'+tk.Id+'/e?retURL=/'+tk.Id);
                pg.getParameters().put('nooverride','1');
                return pg;
            } 
        }
        return null;
    }
    
    //Method to redirect to General Task or Salesdeliverable detail page
    public PageReference redirectToDetail(){
        if(task != null){
            List<Task> tskList = [select id,RecordType.Name from task where id =: task.Id];
            if(tskList.size() > 0){
                Task tk = tskList.get(0);    
                if(tk.RecordType.Name == 'General'){
                    PageReference pg = new PageReference('/'+tk.Id);
                    pg.getParameters().put('nooverride','1');
                    return pg;
                }
                if(tk.RecordType.Name == 'Sales Deliverable'){
                    PageReference pg = new PageReference('/apex/EditTaskInlinePage?id='+tk.Id);
                    pg.setRedirect(true);
                    return pg;
                }
                PageReference pg = new PageReference('/'+tk.Id);
                pg.getParameters().put('nooverride','1');
                return pg; 
            }
        }
        return null;
    }
    
    //Method to redirect whether an user is trying to delete a Salesdeliverables   
    public PageReference methodToDeleteTask(){
        if(task != null){
            List<Task> tskList = [select id,RecordType.Name from task where id =: task.Id];
            if(tskList.size() > 0){
                Task tk = tskList.get(0);
                if(tk.RecordType.Name == 'General'){
                    delete tk;
                    isSD = false;
                    PageReference pg = new PageReference('/'+ ApexPages.currentPage().getParameters().get('retURL') );
                    pg.setRedirect(true);
                    return pg;
                }else if(tk.RecordType.Name == 'Sales Deliverable'){
                    isSD = true;                    
                }
            }
        }
        return null;
    }
    
    //Method to redirect page to returing URL 
    public pageReference goBack(){
        if(ApexPages.currentPage().getParameters().get('retURL') != null){
            PageReference pg = new PageReference('/'+ ApexPages.currentPage().getParameters().get('retURL') );
            pg.setRedirect(true);
            return pg;
        }
        return null;    
    }
    

    
    //Method to query attachment to edit
    public void showAtt(String attId){
        List<Attachment> attList =  [select Id,Description,Body,Name,Owner.Id,Owner.Name from Attachment where Id =: attId];
        if(attList.size() > 0)
            attach = attList.get(0);
    }
    
    //Method to update attachment
    public PageReference editAttachment(){
        update attach;
        PageReference pg = new PageReference('/apex/EditAttachment?attId='+attach.Id+'&showAttDetail=true');
        pg.setRedirect(true);
        return pg;
    }
    
    public void detailAttachment(){
        showAttDetail = false;
    }
    
    //Method to show Inline editing of task
    public void editTask(){
        showPanel = true;
    }
    
    //Method to update task and attachments to task
    public PageReference updateTask(){
        System.debug('-------> '+ task.Subject_Description__c);
        /*if(task.Subject_Description__c == 'Strategy To Win'){
                   tcomment.Body__c = '<b>Do Not Delete Original Questions: You Must Answer All 4 Items</b><br/>'+
                                        '1. What\'s the priority for this project within your company?<br/>'+
                                        '[Q1 answer]<br/>'+
                                        '2. Who is Gems\' competition, what are their advantages / disadvantages and how will we win against them?<br/>'+
                                        '[Q2 answer].<br/>'+
                                        '3. What price is Gems offering vs. the customer\'s target price?<br/>'+
                                        '[Q3 answer].<br/>'+
                                        '4. How will Gems win (outline value proposition and key differentiators that will give Gems the advantage)?<br/>'+
                                        '[Q4 answer].';
                   System.debug('-------> '+ tcomment.Body__c);
               }                                */
        if(selectedStatus != null && selectedStatus != ''){
            task.Status = selectedStatus;
        }
        
        if(task.Is_closing_note__c){
            if(opp.OPP_closing_note__c.trim().length() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Body Field Can Not Be Null For Stage 5'));
                return null;        
            }
            
            update opp;
        }
        
        try{
            update task;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
        
        
            
        
        if(tcomment.id != null){
            if(task.Is_closing_note__c)
                tcomment.Body__c = opp.OPP_closing_note__c;
                
            tcomment.Is_closing_note__c = task.Is_closing_note__c;
            update tcomment;
        }else{
            if(task.Is_closing_note__c)
                tcomment.Body__c = opp.OPP_closing_note__c;
            tcomment.TaskId__c = task.Id;
            tcomment.Is_closing_note__c = task.Is_closing_note__c;
            tcomment.Opportunityid__c = task.WhatId;
            tcomment.Subject__c = task.subject;
            tcomment.OwnerId = task.OwnerId;
            tcomment.Due_Date__c = task.ActivityDate;
            tcomment.Status__c = task.status;
            tcomment.SD_Number__c = task.SD_Number__c;
            //Gazi made change 12/19/2014. It should be OPP stage from task object not from opportunity object
            tcomment.Opportunity_Stage__c = task.Opportunity_Stage__c;
            //if(oppStage != null && oppStage.trim().length() > 0)
                //tcomment.Opportunity_Stage__c = oppStage;
                
            insert tcomment;
        }
        
        User u = [select id,name from user where Id =: UserInfo.getUserId() limit 1];
          
        List<Attachment> tempAttList = new List<Attachment>();
        for(Attachment att : attList){
            if(att.body != null && att.Name != null){
                att.ParentId = task.Id;
                att.OwnerId = task.OwnerId;
                //att.CreatedBy = u.name;
                tempAttList.add(att);
            }
        }          
        
        insert tempAttList;
        
        if(hideButton){            
            PageReference pg = new PageReference('/apex/EditTaskInlinePage?id='+task.Id+'&hideButton=true');
            pg.setRedirect(true);
            return pg;
        }else{
            PageReference pg = new PageReference('/apex/EditTaskInlinePage?id='+task.Id);
            pg.setRedirect(true);
            return pg;
        }
        
        return null;
    }
    
    
}