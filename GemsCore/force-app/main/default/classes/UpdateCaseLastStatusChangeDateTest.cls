@isTest
public class UpdateCaseLastStatusChangeDateTest {
   @isTest
    public static void test() {
        Case c = new Case();
        
        c.Status = 'Closed';
        //string rcType = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Active').getRecordTypeId();
        string rcType = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Customer Service').getRecordTypeId();
            
        c.RecordTypeId=rcType;
        c.Last_Status_Change__c = System.Now();
        insert c;
        
        c.Status='Resolved';
        update c;
        
        system.debug('test Case id: '+c.id);
       // UpdateCaseLastStatusChangeDate obj = new UpdateCaseLastStatusChangeDate();
        UpdateCaseLastStatusChangeDate.UpdateCaseLastStatusChangeValue();
        List<Case> tstCase = [select id,Status, CaseNumber,CreatedDate,ClosedDate,Last_Status_Change__c from case where Id=:c.id];
        
         system.debug(' Case size : ' + tstCase.size());
        for (Case item:tstCase) {
            system.debug('item.Status : '+item.Status);
            system.debug('item.CreatedDate : '+item.CreatedDate);
            system.debug('item.ClosedDate : '+item.ClosedDate);
            if(item.CreatedDate == item.ClosedDate)
            {
                system.debug('Updating Last_Status_Change__c for CaseNumber :'+item.CaseNumber);                
         		item.Last_Status_Change__c= item.CreatedDate;
                update item;
            }
        }     
        }
}