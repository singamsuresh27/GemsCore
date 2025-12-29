public class SalesDeliverableHomePageController{
    List<Task> taskList;
    String uId;
    List<SelectOption> criteriaList;
    public String selectedCriteria{get;set;}
    public List<SelectOption> userList{get;set;}
    public String selectedUser{get;set;}
    public List<SelectOption> taskRecordTypeList{get;set;}
    public String selectedRT{get;set;}
    
    public Integer pageSize {get;set;}
    public Integer totalPages {get;set;}
    public Integer pageNumber {get;set;}
    Integer rowidx;
    
    public List<Task> tskList{get;set;}
    public String selectedColumn{get;set;}
    Boolean isDesc;
    
    public SalesDeliverableHomePageController(){
        isDesc = false;
        criteriaList = new List<SelectOption>();
        userList = new List<SelectOption>();
        taskRecordTypeList = new List<SelectOption>();
        pageSize = 200;
        selectedUser = '';
        tskList = new List<Task>();
        
        //Default Search Criteria Selected
        selectedCriteria = 'Next 7 Days + Over Due';
        //Default task record type Selected 
        selectedRT = 'Sales Deliverable';
             
        //Current logged in userId
        uId = UserInfo.getUserId();
        //Querying Current Logged in users Team Members
        List<User> uList = [select Name,ManagerId From User Where ManagerId =: uId];
        if(uList.size() > 0){
            userList.add(new SelectOption('','--None--'));
            for(User u : uList)
                userList.add(new SelectOption(u.Id,u.Name));    
        }
        // Task record types to create Task Type picklist. Default selection should be record type Sales Deliverable
        //List<RecordType> rtList = [SELECT  Name, Id FROM RecordType Where SobjectType = 'Task' And IsActive = True Order By Name DESC];
        List<RecordType> rtList = [SELECT  Name, Id FROM RecordType Where SobjectType = 'Task' And IsActive = True];
         if(rtList.size() > 0){           
            for(RecordType rt : rtList)
            {
            	//Default task record type Selected  
            	//if (rt.Name == 'Sales Deliverable')
            	//{
            		//selectedRT = rt.Id;
            	//}
                taskRecordTypeList.add(new SelectOption(rt.Name,rt.Name));               
            }  
            taskRecordTypeList.add(new SelectOption('All','All'));      
        }
        
        taskList = [select Id,Status,Opportunity_Stage__c,What.Name,WhatId,ActivityDate,Subject,OwnerId,Owner.Name,RecordTypeId,RecordType.Name, Status_Color__c  
                    from task 
                    where status = 'In Progress' AND 
                            //RecordType.Name = 'Sales Deliverable' AND 
                            RecordType.Name =: selectedRT AND 
                            OwnerId =: uId AND
                            (ActivityDate <: System.Today() OR
                            (ActivityDate >= : System.TODAY() AND ActivityDate <= : System.TODAY().addDays(6))) Order By What.Name,ActivityDate,Opportunity_Stage__c];
        
        if(taskList.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No records found!!!'));
        }
        totalPages = taskList.size() / pageSize;
        if(Math.mod(taskList.size(),pageSize)!= 0){
            totalPages++;                
        }
        first();           
         
    }
    
    public void filterRecords(){
        String query = 'Select Id,Status,Opportunity_Stage__c,What.Name,WhatId,ActivityDate,Subject,OwnerId,Owner.Name,RecordTypeId,RecordType.Name, Status_Color__c '+
                    'From task '+
                    'Where status = \'In Progress\'  ';
                           //'RecordType.Name = \'Sales Deliverable\' ';
                           //'RecordType.Name = \'Sales Deliverable\' ';
        //(RecordType.Name =:selectedRT) '; 
        if (selectedRT == 'All')
        {
        	//query += ' AND OwnerId =: selectedUser ';
        }else{
        	query += ' AND RecordType.Name =:selectedRT ';
        }
                          
        if(selectedUser != null && selectedUser.trim().length() > 0){
            query += ' AND OwnerId =: selectedUser ';
        }else{
            query += ' AND OwnerId =: uId ';
        }
        if(selectedCriteria == 'Over Due'){
            query += ' AND ActivityDate < TODAY ';
        }
        if(selectedCriteria == 'Today'){
            query += ' AND ActivityDate = TODAY ';
        }
        if(selectedCriteria == 'Today + Overdue'){
        	//Gazi made change 12/20/2014
            query += ' AND  (ActivityDate <= TODAY) ';
            //query += 'AND (ActivityDate < TODAY OR ActivityDate = TODAY) ';
        }
        if(selectedCriteria == 'Tomorrow'){
            query += 'AND (ActivityDate = TOMORROW) ';
        }
        if(selectedCriteria == 'Next 7 Days'){
            Date thisWeek = Date.today().addDays(6);
            //Gazi made change 12/20/2014
            //LAST_N_DAYS:7
            query += 'AND (ActivityDate = NEXT_N_DAYS:7) ';
            //query += 'AND (ActivityDate >= TODAY AND ActivityDate <= : thisWeek) ';
        }
        if(selectedCriteria == 'Next 7 Days + Over Due'){
            Date thisWeek = Date.today().addDays(6);
            //Gazi made change on 12/20/2014
            query += 'AND (ActivityDate <= : thisWeek)';
            //query += 'AND (ActivityDate < TODAY OR (ActivityDate >=  TODAY AND ActivityDate <= : thisWeek)) ';
        }
        if(selectedCriteria == 'This month'){
            Date startOfMonth = Date.today().toStartOfMonth();
            Date startOfNextMonth = startOfMonth.addMonths(1);
            //Gazi made change
            //THIS_MONTH 
            query += 'AND (ActivityDate = THIS_MONTH) ';
            //query += 'AND (ActivityDate >= :startOfMonth AND ActivityDate < :startOfNextMonth) ';
        }
        query += 'Order By What.Name,ActivityDate,Opportunity_Stage__c';
        
        System.debug('---> '+query);
        
        taskList = Database.Query(query);
        if(taskList.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No records found!!!'));
        }
        
        totalPages = taskList.size() / pageSize;
        if(Math.mod(taskList.size(),pageSize)!= 0){
            totalPages++;                
        }
        first();
    }
    
    public void sortByColumns(){
        
        String query = 'select Id,Status,Opportunity_Stage__c,What.Name,WhatId,ActivityDate,Subject,OwnerId,Owner.Name,RecordTypeId,RecordType.Name, Status_Color__c '+
                    'from task '+
                    'where status = \'In Progress\'  ';
                           //'RecordType.Name = \'Sales Deliverable\' ';
        if (selectedRT == 'All')
        {
        	//query += ' AND OwnerId =: selectedUser ';
        }else{
        	query += ' AND RecordType.Name =:selectedRT ';
        }                
                           
        if(selectedUser != null && selectedUser.trim().length() > 0){
            query += 'AND OwnerId =: selectedUser ';
        }else{
            query += 'AND OwnerId =: uId ';
        }
        if(selectedCriteria == 'Over Due'){
            query += 'AND ActivityDate < TODAY ';
        }
        if(selectedCriteria == 'Today'){
            query += 'AND ActivityDate = TODAY ';
        }
        if(selectedCriteria == 'Today + Overdue'){
        	query += ' AND  (ActivityDate <= TODAY) ';
            //query += 'AND (ActivityDate < TODAY OR ActivityDate = TODAY) ';
        }
        if(selectedCriteria == 'Tomorrow'){
            query += 'AND (ActivityDate = TOMORROW) ';
        }
        if(selectedCriteria == 'Next 7 Days'){
            Date thisWeek = Date.today().addDays(6);
            query += ' AND (ActivityDate = NEXT_N_DAYS:7) ';
            //query += 'AND (ActivityDate >= TODAY AND ActivityDate <= : thisWeek) ';
        }
        if(selectedCriteria == 'Next 7 Days + Over Due'){
            Date thisWeek = Date.today().addDays(6);
            query += 'AND (ActivityDate <= : thisWeek)';
            //query += 'AND (ActivityDate < TODAY OR (ActivityDate >=  TODAY AND ActivityDate <= : thisWeek)) ';
        }
        if(selectedCriteria == 'This month'){
            Date startOfMonth = Date.today().toStartOfMonth();
            Date startOfNextMonth = startOfMonth.addMonths(1);
            query += 'AND (ActivityDate = THIS_MONTH) ';
            //query += 'AND (ActivityDate >= :startOfMonth AND ActivityDate < :startOfNextMonth) ';
        }
        
        if(selectedColumn != null && selectedColumn.trim().length() > 0){
            if(isDesc){
                query += 'Order By '+selectedColumn+' desc';
                isDesc = false;
            }else{
                query += 'Order By '+selectedColumn;
                isDesc = true;
            }
        }else{
            query += 'Order By What.Name,ActivityDate,Opportunity_Stage__c';    
        }
        System.debug('---> '+query);
        
        taskList = Database.Query(query);
        
        if(taskList.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No records found!!!'));
        }
        
        totalPages = taskList.size() / pageSize;
        if(Math.mod(taskList.size(),pageSize)!= 0){
            totalPages++;                
        }
        first();
    }
    
    public List<SelectOption> getCriteriaList(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Over Due','Over Due'));
        options.add(new SelectOption('Today','Today'));
        options.add(new SelectOption('Today + Overdue','Today + Overdue'));
        options.add(new SelectOption('Tomorrow','Tomorrow'));
        options.add(new SelectOption('Next 7 Days','Next 7 Days'));
        options.add(new SelectOption('Next 7 Days + Over Due','Next 7 Days + Over Due'));
        options.add(new SelectOption('This month','This month'));
        options.add(new SelectOption('All Open','All Open'));
        
        return options;
    }
    
    public void first(){
          tskList = new LIST<Task>();
          Integer i,lim=pageSize;
          if(taskList.size() < pageSize){
              lim = taskList.size();
          }
          for(i=0; i<lim; i++){
            tskList.add(taskList[i]);
          }
          rowidx=i;  
          
          pageNumber = 1;
    }
    
    public void last(){
          tskList = new LIST<Task>();
          
          Integer i=(taskList.size()/pageSize)*pageSize;
           
          if(taskList.size()==pageSize){
            rowidx=0;
          }
          for(Integer j=1; j<=math.mod(taskList.size(),pageSize); i++){
            tskList.add(taskList[i]);
            j++;
          } 
          rowidx=i; 
          pageNumber = totalPages;
    }
    
    public void previous(){
        integer lim=pageSize;
          if(taskList.size() < pageSize){
              lim = taskList.size();
          }
          if(rowidx<lim || pageNumber == 1 ){
              return;
          }
          tskList = new LIST<Task>();
          Integer i,start;
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
        
          if(pageNumber == totalPages -1){
                  start=rowidx-lim;
                  lim=0;
              }
          tskList.clear();
          for(i=start; i<rowidx-lim; i++){
            tskList.add(taskList[i]);
          }    
          rowidx=i; 
    }
    
    public void PNext(){
        tskList.clear();
        Integer i;
        integer lim=pageSize;
        if(taskList.size() < pageSize){
          lim = taskList.size();
        }
        if(taskList.size()<=lim){
            rowidx=0;
        }
        for(i=rowidx;i<rowidx+lim && i< taskList.size();i++){
            tskList.add(taskList.get(i));
        }

        if(rowidx<taskList.size()-lim){
            rowidx = rowidx+lim;
        }
        
        pageNumber++;
        if(pageNumber >= totalPages){
          pageNumber = totalPages;
        } 
        
    }
    
}