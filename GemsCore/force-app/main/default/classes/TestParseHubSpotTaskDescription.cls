@isTest
public class TestParseHubSpotTaskDescription {
static testMethod void createnewlead() {
      User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
      
      Test.startTest();    
      Task taskToCreate =new Task();
      List<id> Ids= New List<Id>();
      taskToCreate.ownerid= userToCreate.id;
      taskToCreate.Subject='Submitted Form \'Contact Us - Pop In/Out';
      taskToCreate.Description=' Hello, welcome Message: ok Lead Source:';
      insert taskToCreate;     
      Ids.add(taskToCreate.id);
    ParseHubSpotTaskDescription.parseTask(Ids);
    
    taskToCreate =new Task();
      taskToCreate.ownerid= userToCreate.id;
      taskToCreate.Subject='Submitted Form \'MEA Contact Us Page';
      taskToCreate.Description=' Hello, Message: ok Country:';
      insert taskToCreate;         
      Ids.add(taskToCreate.id);
      ParseHubSpotTaskDescription.parseTask(Ids);
    
      taskToCreate =new Task();
      taskToCreate.ownerid= userToCreate.id;
      taskToCreate.Subject='Submitted Form \'Contact Us - HVAC';
      taskToCreate.Description=' Hello, Comments/Questions: ok Lead Quality:';
      insert taskToCreate;         
      Ids.add(taskToCreate.id);
      ParseHubSpotTaskDescription.parseTask(Ids);
    
    taskToCreate =new Task();
      taskToCreate.ownerid= userToCreate.id;
      taskToCreate.Subject='Submitted Form \'Contact Us Form - Sidebar - Setra';
      taskToCreate.Description=' Hello, Application Description: ok Lead Source (use this one):';
      insert taskToCreate;         
      Ids.add(taskToCreate.id);
      ParseHubSpotTaskDescription.parseTask(Ids);
    
    taskToCreate =new Task();
      taskToCreate.ownerid= userToCreate.id;
      taskToCreate.Subject='Submitted Form \'Lead From 2019';
      taskToCreate.Description=' Hello, Application test: ok Artikeldetails: test Lead Source: Web Which parameters would you like measured?: test';
      insert taskToCreate;         
      Ids.add(taskToCreate.id);
      ParseHubSpotTaskDescription.parseTask(Ids);
         
      taskToCreate =new Task();
      taskToCreate.ownerid= userToCreate.id;
      taskToCreate.Subject='Submitted Form \'Lead From 2019';
      taskToCreate.Description=' Hello, welcome Add any additional notes we should know about: ok Lead Source:';
      insert taskToCreate;     
      Ids.add(taskToCreate.id);
      ParseHubSpotTaskDescription.parseTask(Ids);
      
      taskToCreate =new Task();
      taskToCreate.ownerid= userToCreate.id;
      taskToCreate.Subject='Submitted Form \'Power Meter Webinar Watch';
      taskToCreate.Description=' Hello, welcome Do you have any upcoming projects? What are your typical applications?: ok Lead Source:';
      insert taskToCreate;     
      Ids.add(taskToCreate.id);
      ParseHubSpotTaskDescription.parseTask(Ids);
      
      taskToCreate =new Task();
      taskToCreate.ownerid= userToCreate.id;
      taskToCreate.Subject='Submitted Form \'Request a Quote 2018';
      taskToCreate.Description=' Hello, welcome Optional Additional Notes: ok Lead Source (use this one):';
      insert taskToCreate;     
      Ids.add(taskToCreate.id);
      ParseHubSpotTaskDescription.parseTask(Ids);
      
      taskToCreate =new Task();
      taskToCreate.ownerid= userToCreate.id;
      taskToCreate.Subject='Submitted Form \'Sales Form';
      taskToCreate.Description=' Hello, welcome Application / Project Information: ok Additional Information:';
      insert taskToCreate;     
      Ids.add(taskToCreate.id);
    ParseHubSpotTaskDescription.parseTask(Ids);
    
      Test.stopTest();
   }
}