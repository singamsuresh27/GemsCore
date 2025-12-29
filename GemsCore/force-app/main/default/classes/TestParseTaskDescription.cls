@isTest
public class TestParseTaskDescription {
static testMethod void createnewlead() {
      User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
      
      Test.startTest();    
      Task taskToCreate =new Task();
      List<id> Ids= New List<Id>();
      taskToCreate.ownerid= userToCreate.id;
      taskToCreate.Subject='Submitted Form \'Technical Support Request';
      taskToCreate.Description=' Hello, welcome Technical Help Request: ok Lead Sources Detail:';
      insert taskToCreate;     
      Ids.add(taskToCreate.id);
    ParseTaskDescription.parseTask(Ids);
    
    taskToCreate =new Task();
      taskToCreate.ownerid= userToCreate.id;
      taskToCreate.Subject='Submitted Form \'Technical Support Request';
      taskToCreate.Description=' Hello, Comments/Questions: ok Lead Sources Detail:';
      insert taskToCreate;         
      Ids.add(taskToCreate.id);
      ParseTaskDescription.parseTask(Ids);
    
      taskToCreate =new Task();
      taskToCreate.ownerid= userToCreate.id;
      taskToCreate.Subject='Submitted Form \'Contact Us';
      taskToCreate.Description=' Hello, Comments/Questions: ok Lead Sources Detail:';
      insert taskToCreate;         
      Ids.add(taskToCreate.id);
      ParseTaskDescription.parseTask(Ids);
    
    taskToCreate =new Task();
      taskToCreate.ownerid= userToCreate.id;
      taskToCreate.Subject='Submitted Form \'Contact Us';
      taskToCreate.Description=' Hello, Application Description: ok Estimated Yearly Quantity Required:';
      insert taskToCreate;         
      Ids.add(taskToCreate.id);
      ParseTaskDescription.parseTask(Ids);
    
    taskToCreate =new Task();
      taskToCreate.ownerid= userToCreate.id;
      taskToCreate.Subject='Submitted Form \'Quote Request';
      taskToCreate.Description=' Hello, Application test: ok Artikeldetails: test Lead Sources Detail:';
      insert taskToCreate;         
      Ids.add(taskToCreate.id);
      //List<string> Ids= New List<string>();     	
      //Ids.add('00T5500000NwWoBEAV');
      ParseTaskDescription.parseTask(Ids);
      
      Test.stopTest();
   }
}