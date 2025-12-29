public class UpdateCaseLastStatusChangeDate {        
        public static void UpdateCaseLastStatusChangeValue(){
            
           // string crDate= '2/5/2021';
           // Date dt = Date.parse(crDate);
             List<Case> tstCase = [select id,CaseNumber,CreatedDate,ClosedDate,Last_Status_Change__c,WEST_Case_ID__c from case where CreatedDate >=2021-02-06T00:00:00Z and Status='Resolved' and RecordType.Name='Active' and WEST_Case_ID__c ='' order by CaseNumber];
            
             system.debug(' Case size : ' + tstCase.size());
            List<Case> lstCase = new List<Case>();
            List<String> count=new List<String>();
            for (Case item:tstCase) {
                if(item.CreatedDate == item.ClosedDate)
                {
                    system.debug('Updating Last_Status_Change__c for CaseNumber :'+item.CaseNumber);                
                    item.Last_Status_Change__c= item.CreatedDate;
                    lstCase.add(item);
                    //update item;
                }
            }
            system.debug(' Case to update count : ' + lstCase.size());
            if(lstCase.size()>0)
            {
             //   update lstCase;
               try{
                Database.SaveResult[] srList = Database.update(lstCase,false);
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                      System.debug('Successfully updated Case Last_Status_Change__c ID: ' + sr.getId());
                    }
                    else {
                        System.debug('The following error has occurred Last_Status_Change__c case updation.');
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                }
            catch(Exception e)
            {
              System.debug('Error: '+e.getMessage() +' '+e.getLineNumber() + ' '+ e.getStackTraceString());
            }    
            }
        }
    }