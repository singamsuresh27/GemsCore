trigger CaseBusinessHoursCalculator on Case (after insert, after update) {
  if (CaseBusinessHoursHelper.alreadyRunning) return;
    CaseBusinessHoursHelper.alreadyRunning = true;

    try {
        // Get Business Hours record for GEMS_NA
        Id bhId = [
            SELECT Id 
            FROM BusinessHours 
            WHERE Name = 'GEMS_NA' AND IsActive = TRUE 
            LIMIT 1
        ].Id;

        // Get all Closed Statuses once
        Set<String> closedStatuses = new Set<String>();
        for (CaseStatus cs : [SELECT MasterLabel FROM CaseStatus WHERE IsClosed = TRUE]) {
            closedStatuses.add(cs.MasterLabel);
        }

        List<Case> casesToUpdate = new List<Case>();

        for (Case c : Trigger.new) {
            Case oldC = Trigger.isInsert ? null : Trigger.oldMap.get(c.Id);
            Case upd = new Case(Id = c.Id);

            // On insert → initialize
            if (Trigger.isInsert) {
                upd.Last_Status_Changed__c = System.now();
                upd.Accumulated_Business_Hours__c = 0;
                casesToUpdate.add(upd);
                continue;
            }

            // Only run when Status changes
            if (c.Status != oldC.Status) {
                // Determine open/closed transitions
                Boolean wasOpen = !closedStatuses.contains(oldC.Status);
                Boolean isNowClosed = closedStatuses.contains(c.Status);
                
                // Only accumulate when moving FROM open → TO closed
                if (wasOpen && isNowClosed) {
                    Double diffHours = 0.0;
                    
                    if (oldC.Last_Status_Changed__c != null) {
                        Long diffMs = BusinessHours.diff(bhId, oldC.Last_Status_Changed__c, System.now());
                        if (diffMs != null && diffMs > 0) {
                            diffHours = diffMs / 3600000.0;
                        }
                    }
                    
                    upd.Accumulated_Business_Hours__c =
                        (oldC.Accumulated_Business_Hours__c == null ? 0 : oldC.Accumulated_Business_Hours__c) + diffHours;
                }
                
                // Always update timestamp
                upd.Last_Status_Changed__c = System.now();
                
                casesToUpdate.add(upd);
            }
        }

        //  Commit all updates
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }

    } catch (Exception e) {
        System.debug('Error in CaseBusinessHoursCalculator: ' + e.getMessage());
    } finally {
        CaseBusinessHoursHelper.alreadyRunning = false;
    }
}