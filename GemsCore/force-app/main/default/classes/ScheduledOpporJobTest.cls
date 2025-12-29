@istest
class ScheduledOpporJobTest {

   static testmethod void test() {
   Test.startTest();


      // Schedule the test job

      String jobId = System.schedule('testBasicScheduledApex',
      '0 0 22 ? * 6L',
         new ScheduledOpporJob());

      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

    
   Test.stopTest();

 
   }
}