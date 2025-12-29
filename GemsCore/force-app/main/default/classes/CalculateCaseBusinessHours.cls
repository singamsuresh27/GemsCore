public class CalculateCaseBusinessHours {
    
    public static void CalculateBusinessHours(string caseId){
        
        DateTime lastStatusChangeDate; 
        DateTime createdDate; 
        
        // List<Case> tstCases = [select id,Case_received__c,BusinessHoursId,Date_Closed__c,Last_Status_Change__c,LastModifiedDate from case
        // where Status='Resolved' and RecordType.Name='Active' and CreatedDate>=2021-02-06T00:00:00Z];
        List<Case> tstCases = [select id,Case_received__c,BusinessHoursId,Date_Closed__c,Last_Status_Change__c,CreatedDate from case
                               where id=:caseId];
        BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
        for(Case tstCase : tstCases){
            Id hoursToUse = tstCase.BusinessHoursId!=null?tstCase.BusinessHoursId:defaultHours.Id;   
            List<CaseHistory> caseHistoryTimeStamp= [SELECT CreatedDate FROM CaseHistory where CaseId =: tstCase.id and Field='Status' 
                                                     order by CreatedDate asc];
            if(caseHistoryTimeStamp!=null && caseHistoryTimeStamp.size()>0)
            {
                if(caseHistoryTimeStamp.size()<=1)
                {
                    lastStatusChangeDate= caseHistoryTimeStamp.get(caseHistoryTimeStamp.size()-1).CreatedDate;
                    createdDate=tstCase.CreatedDate;
                    system.debug(' compare '+createdDate.date().isSameDay(lastStatusChangeDate.date()));
                    
                    //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
                    Double timeSinceLastStatusOriginal = BusinessHours.diff(hoursToUse, createdDate,lastStatusChangeDate )/3600000.0;
                        
                    Decimal timeSinceLastStatus = Decimal.valueOf(timeSinceLastStatusOriginal).setScale(3);
                    System.debug('hoursToUse : '+hoursToUse);
                    System.debug('statusToResolvedDate : '+lastStatusChangeDate);
                    System.debug('createdDate : '+createdDate);
                    System.debug('timeSinceLastStatus : '+timeSinceLastStatus);
                    tstCase.Case_Age_In_Business_Hours__c=timeSinceLastStatus;//.setScale(3);
                    tstCase.Time_With_Support__c=timeSinceLastStatus;//.setScale(3);
                    tstCase.Last_Status_Change__c=lastStatusChangeDate;
                    System.debug('Case_Age_In_Business_Hours__c : '+tstCase.Case_Age_In_Business_Hours__c);
                          if(createdDate.date().isSameDay(lastStatusChangeDate.date()))
                          {
                              System.debug('Case Id with Same day:' +tstCase.id);
                          }
                        else
                        {
                            // update tstCase;
                        }
                }
                else
                {
                    System.debug('TestCase Id with more than 2 status changes:' +tstCase.id);                   
                }
            }
            else
            {
                system.debug(' caseHistoryTimeStamp: '+caseHistoryTimeStamp.size());
            }
            
        }
    }
}