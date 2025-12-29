trigger CalculateBusinessHoursAges on Case (before insert, before update) {
    try
    {
        if (Trigger.isInsert) {
            for (Case updatedCase:System.Trigger.new) {
                updatedCase.Last_Status_Change__c = System.now();
                updatedCase.Time_With_Customer__c = 0;
                updatedCase.Time_With_Support__c = 0;
            }
        } else {
            //Get the stop statuses
            Set<String> stopStatusSet = new Set<String>();
            for (Stop_Status__c stopStatus:[Select Name From Stop_Status__c]) {
                stopStatusSet.add(stopStatus.Name);
            }
    
            //Get the default business hours (we might need it)
            BusinessHours defaultHours = [select Id from BusinessHours where IsDefault=true];
    
            //Get the closed statuses (because at the point of this trigger Case.IsClosed won't be set yet)
            Set<String> closedStatusSet = new Set<String>();
            for (CaseStatus status:[Select MasterLabel From CaseStatus where IsClosed=true]) {
                closedStatusSet.add(status.MasterLabel);
            }
    
            //For any case where the status is changed, recalc the business hours in the buckets
            for (Case updatedCase:System.Trigger.new) {
                Case oldCase = System.Trigger.oldMap.get(updatedCase.Id);
                System.debug(' Before Business Hour update');
                if (oldCase.Status!=updatedCase.Status && updatedCase.Last_Status_Change__c!=null) {
                    //OK, the status has changed
                    if (!oldCase.IsClosed) {
                        //We only update the buckets for open cases
    
                        //On the off-chance that the business hours on the case are null, use the default ones instead
                        Id hoursToUse = updatedCase.BusinessHoursId!=null?updatedCase.BusinessHoursId:defaultHours.Id;
                        system.debug(' hoursToUse : '+hoursToUse);
                        string activeRTId;
                        Double timeSinceLastStatus;
                        LIST<RecordType> recType = [select id from RecordType where name='Active' and SObjectType='Case'];
                        if(recType.size()>0)
                            activeRTId = recType[0].id;
                        if(updatedCase.recordTypeId == activeRTId && updatedCase.Case_received__c != null)
                        {
                            System.debug(' 1 ');
                            if(updatedCase.Date_Closed__c == null)
                            {
                             timeSinceLastStatus = BusinessHours.diff(hoursToUse, updatedCase.Case_received__c, System.now())/3600000.0;
                            }
                            else
                            {
                             timeSinceLastStatus = BusinessHours.diff(hoursToUse, updatedCase.Case_received__c, updatedCase.Date_Closed__c)/3600000.0;
                            }
                            updatedCase.Time_With_Support__c = timeSinceLastStatus;
                            if (closedStatusSet.contains(updatedCase.Status)) {
                                updatedCase.Case_Age_In_Business_Hours__c = timeSinceLastStatus;
                                System.debug('CASE Age in Business Hour : '+updatedCase.Case_Age_In_Business_Hours__c);
                            }
                        }
                        else if(updatedCase.recordTypeId != activeRTId)
                        {     
                            System.debug(' 2 ');
                            //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
                             timeSinceLastStatus = BusinessHours.diff(hoursToUse, updatedCase.Last_Status_Change__c, System.now())/3600000.0;
                            //We decide which bucket to add it to based on whether it was in a stop status before
                            if (stopStatusSet.contains(oldCase.Status)) {
                                updatedCase.Time_With_Customer__c += timeSinceLastStatus;
                            } else {
                                updatedCase.Time_With_Support__c += timeSinceLastStatus;
                            }
                            
                            if (closedStatusSet.contains(updatedCase.Status)) {
                                updatedCase.Case_Age_In_Business_Hours__c = updatedCase.Time_With_Customer__c + updatedCase.Time_With_Support__c;
                                System.debug('CASE Age in Business Hour : '+updatedCase.Case_Age_In_Business_Hours__c);
                            }
                        }
                         System.debug(timeSinceLastStatus);
                    }
    
                    updatedCase.Last_Status_Change__c = System.now();
                }
            }
        }
    }
    catch(exception ex)
    {
        System.debug(' CalculateBusinessHoursAges Exception : ' + ex.getMessage());
    }
}