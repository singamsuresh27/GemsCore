@isTest
public class CalculateCaseBusinessHoursTest {
    @isTest
    public static void testCalculateBusinessHours() {
        Case c = new Case();
        c.Status = 'Open';
        string rcType = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Customer Service').getRecordTypeId();
        c.RecordTypeId=rcType;
        //insert c;
                
        c.Last_Status_Change__c = System.Now();
        insert c;
             
        /*c.Status='Resolved';
        c.Level1__c='not required';
        c.Resolved__c='Yes';
        update c;*/
        CaseHistory ch=new CaseHistory();
        ch.CaseId=c.id;
        ch.Field='Status';
        insert ch;
               
        CalculateCaseBusinessHours.CalculateBusinessHours(c.id);
        Case testCase = [select id,Last_Status_Change__c,Time_With_Support__c,Case_Age_In_Business_Hours__c from case where Id=:c.id];
        system.debug('Last_Status_Change__c : '+testCase.Last_Status_Change__c);
        system.debug('Time_With_Support__c : '+testCase.Time_With_Support__c);
        system.debug('Case_Age_In_Business_Hours__c : '+testCase.Case_Age_In_Business_Hours__c);
        //System.assert(testCase.Case_Age_In_Business_Hours__c!=null);
    }     
}