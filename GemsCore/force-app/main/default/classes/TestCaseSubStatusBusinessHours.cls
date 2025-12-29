@isTest
public class TestCaseSubStatusBusinessHours {

    	static testMethod void calculateBusinessHours() {
            
            Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        	insert cas;
            
            Datetime dt = DateTime.parse('01/01/2022 11:00 AM');
            CaseSubStatusHistory__c casHistory = new CaseSubStatusHistory__c(Name='123',case__c=cas.id,Entry_Time__c=dt, Entry_Status__c='Pending – Customer');
            insert casHistory;
            
            cas.Sub_Status__c='Pending Customer';
            update cas;
            casHistory.Exit_Status__c='Pending Customer';
            dt = DateTime.parse('01/01/2022 11:46 AM');
            casHistory.Exit_Time__c=dt;
            update casHistory;
        }
}