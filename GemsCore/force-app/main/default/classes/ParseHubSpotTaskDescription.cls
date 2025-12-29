// This apex class is called from SetraHubSpotLeads flow to parse task descriptions and return description and Which parameters would you like measured value back to Flow
public class ParseHubSpotTaskDescription {
    @InvocableMethod        
    public static List<flowOutputs> parseTask(List<Id> TaskIds)
    {
        string taskDescription,taskComments,taskSubject,parsedTaskDescription,descLabel,newParam,newTaskParam;
        integer descLength;
        Boolean contain = false;
        List<FlowOutputs> results = new List<FlowOutputs>();
        flowOutputs returnValues = new flowOutputs();
        List<Task> tskList =[select id,subject,description from task where task.id in :TaskIds];        
        List<string> listTaskDesc= new List<string>(); 
        List<String> lstRows = new List<string>(); 
        string descLabel1='Message:';
        string descLabel2='Additional questions about CEMS:';
        string descLabel3='Description:';
        string descLabel4='Comments / Questions:';
        string descLabel5='Add any additional notes we should know about:';
        string descLabel6='Do you have any upcoming projects? What are your typical applications?:';
        string descLabel7='Optional Additional Notes:';
        string descLabel8='Application / Project Information:';
        string descLabel9='Optional additional notes or questions:';
        string descLabel10='Additional questions about Wireless:';
        string descTaskLabel='Which parameters would you like measured?:';
                
        for (Task c: tskList) 
        {
            taskComments= c.Description;
            taskSubject = c.Subject;
            lstRows = taskComments.split('\n|\r\n');
            if((taskSubject.indexOf('Contact Us - Pop In/Out') >0 || taskSubject.indexOf('MEA Landing Page Form') >0 ||taskSubject.indexOf('Particle Counter - Learn More')>0) && (taskComments.indexOf(descLabel1)>0))
            {  
                parsedTaskDescription = taskComments.substringBetween(descLabel1, 'Lead Source');
            }
            else if(taskSubject.indexOf('MEA Contact Us Page') >0 && taskComments.indexOf(descLabel1) > 0)
            {                   
                parsedTaskDescription = taskComments.substringBetween(descLabel1, 'Target Region:');
            }
            else if(taskSubject.indexOf('CEMS™ Learn More') >0 && taskComments.indexOf(descLabel2) > 0)
            {                   
                parsedTaskDescription = taskComments.substringBetween(descLabel2, 'I\'d like a Setra expert to give me a call!:');
            }            
            else if(taskSubject.indexOf('CEMS™ Wireless Learn More') > 0 && taskComments.indexOf(descLabel10) > 0)
            {                   
                parsedTaskDescription = taskComments.substringBetween(descLabel10, 'I\'d like a Setra expert to give me a call!:');
            }
            else if(taskSubject.indexOf('Contact Us - HVAC') >0 && taskComments.indexOf(descLabel3) > 0)
            {                   
                parsedTaskDescription = taskComments.substringBetween(descLabel3, 'Lead Quality:');
            }
             else if(taskSubject.indexOf('Contact Us Form - Sidebar - Setra') >0 && taskComments.indexOf(descLabel4) > 0)
            {                   
                parsedTaskDescription = taskComments.substringBetween(descLabel4, 'Lead Source (use this one):');
            }
            else if(taskSubject.indexOf('Lead From 2019') > 0 && taskComments.indexOf(descLabel5) > 0)
            {                   
                parsedTaskDescription = taskComments.substringBetween(descLabel5, 'Lead Source:');
            }
            else if(taskSubject.indexOf('Power Meter Webinar Watch') > 0 && taskComments.indexOf(descLabel6)>  0)
            {                   
                parsedTaskDescription = taskComments.substringBetween(descLabel6, 'Lead Source:');
            }
             else if(taskSubject.indexOf('Request a Quote 2018') > 0 && taskComments.indexOf(descLabel7) > 0)
            {                   
                parsedTaskDescription = taskComments.substringBetween(descLabel7, 'Lead Source (use this one):');
            }
             else if(taskSubject.indexOf('Sales Form') > 0 && taskComments.indexOf(descLabel8) > 0)
            {                   
                parsedTaskDescription = taskComments.substringBetween(descLabel8, 'Additional Information:');
            }
            else if(taskSubject.indexOf('AIIR Watch Quote') > 0 && taskComments.indexOf(descLabel9) > 0)
            {                   
                parsedTaskDescription = taskComments.substringBetween(descLabel9, 'Lead Source');
            }
            else if((taskSubject.indexOf('061421 CEMS adwords') > 0 || taskSubject.indexOf('062121 CEMS adwords V2 with Video') > 0 )&& taskComments.indexOf(descLabel3) > 0)
            {                   
                parsedTaskDescription = taskComments.substringBetween(descLabel3, 'Lead Source');
            }
           
            if(taskComments.indexOf(descTaskLabel) >0)
            {                
                for (String row: lstRows) { 
                    row = row.trim();                   
                    contain = row.contains(descTaskLabel);
                    if(contain)
                    {                        
                        system.debug(' ROW : '+ row); 
                        newTaskParam = row.substring(row.indexOf(':')+2);
                        if(string.isNotBlank(newParam))
                        {
                            newParam = newParam + '; ' + newTaskParam;
                            system.debug(' New Param Value - ' + newParam);
                        }
                        else
                        {
                            newParam = newTaskParam;
                        }
                    }
                }
            }
            returnValues.taskComments=parsedTaskDescription;
            returnValues.cemsParam=newParam;            
            results.add(returnValues);
        } 
        return results;
    }
    public class flowOutputs{
    @InvocableVariable public String taskComments;
    @InvocableVariable public String cemsParam;
  
  }
}