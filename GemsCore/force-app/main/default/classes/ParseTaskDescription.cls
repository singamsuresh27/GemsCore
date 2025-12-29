// This apex class is called from GemsHubSpotFlow to parse task descriptions and return the value back to Flow
public class ParseTaskDescription {
     
    public static integer howCanWeHelpIndex;
    public static string descLabel;
    public static string apexParsedValueNew; 
    public static string apexParsedValue;
    public static integer descLength;
    @InvocableMethod        
    public static List<string> parseTask(List<Id> TaskIds)
    {
        List<Task> tskList =[select id,subject,description from task where task.id in :TaskIds];
        List<string> listTaskDesc= new List<string>(); 
    	Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
       // while ((finishTime - startTime) < 10000) {
            //sleep for 9s
            //finishTime = DateTime.now().getTime();
        //}
        for (Task c: tskList) 
        {
        string taskComments= c.Description;
        string taskSubject = c.Subject;
        boolean containValue = false;
        List<String> lstRows = taskComments.split('\n|\r\n');
            for ( String row : lstRows ) {
                row = row.trim();            
            }
            if(taskSubject.indexOf('Technical Support Request') >0)
            {
                //system.debug(' Old Value - '+taskComments);
                howCanWeHelpIndex = taskComments.indexOf('Technical Help Request:');
                descLabel='Technical Help Request:';
                if(howCanWeHelpIndex == -1)
                {
                    howCanWeHelpIndex = taskComments.indexOf('Veuillez remplir le formulaire ci-dessous pour envoyer votre demande:');
                    descLabel='Veuillez remplir le formulaire ci-dessous pour envoyer votre demande:';
                    if(howCanWeHelpIndex == -1)
                    {
                        howCanWeHelpIndex = taskComments.indexOf('Technische Details der Support-Anfrage:');
                        descLabel='Technische Details der Support-Anfrage:'; 
                        if(howCanWeHelpIndex == -1)   
                        	containValue = false;
                        else                        
                        	containValue = true;
                    }
                    else
                        containValue = false;
                  //system.debug(' containValue :'+containValue);
                }
                else
                {
                    containValue = true;
                }
               //system.debug(' containValue - '+containValue);
                if(containValue)
                {
                    descLength = descLabel.length();
                    apexParsedValue = taskComments.substring(howCanWeHelpIndex+descLength);
                    //system.debug('Technical Help Request Old value- '+apexParsedValue);
                    List<String> lstHelp = apexParsedValue.split('\n|\r\n');
                    for ( String row : lstHelp ) {
                        row = row.trim();               
                       Boolean contain = row.contains('Lead Sources Detail:');
                       // system.debug( row +' - Contain : -' +contain);
                        if(contain)
                        {
                            apexParsedValueNew = apexParsedValue.substring(0, apexParsedValue.indexOf(row));
                            //system.debug(' New Value - ' + apexParsedValueNew);
                            break;
                        }
                    }
                }
                else
                {
                     apexParsedValueNew= parseCommentsQuestions(taskComments);                    
                }
                 
        	}
           else if(taskSubject.indexOf('Contact Us') >0)
            {
               howCanWeHelpIndex = taskComments.indexOf('Application Description:');
                descLabel='Application Description:';
                if(howCanWeHelpIndex == -1)
                 	containValue = false;
                else
                    containValue = true;
                if(containValue)
                {
                    descLength = descLabel.length();
                    apexParsedValue = taskComments.substring(howCanWeHelpIndex+descLength);
                    //system.debug('Technical Help Request Old value- '+apexParsedValue);
                    List<String> lstHelp = apexParsedValue.split('\n|\r\n');
                    for ( String row : lstHelp ) {
                        row = row.trim();               
                       Boolean contain = row.contains('Estimated Yearly Quantity Required:');
                       // system.debug( row +' - Contain : -' +contain);
                        if(contain)
                        {
                            apexParsedValueNew = apexParsedValue.substring(0, apexParsedValue.indexOf(row));
                            //system.debug(' New Value - ' + apexParsedValueNew);
                            break;
                        }
                    }
                }
                else
                {
                     apexParsedValueNew= parseCommentsQuestions(taskComments);                    
                }            
        	}
           else if(taskSubject.indexOf('Quote Request') >0)
            {
               system.debug('taskComments : '+taskComments);
               howCanWeHelpIndex = taskComments.indexOf('Application Detail:');
               descLabel='Application Detail:';
                if(howCanWeHelpIndex == -1)
                {
                    howCanWeHelpIndex = taskComments.indexOf('Détails sur le produit:');
                    descLabel='Détails sur le produit:';
                    if(howCanWeHelpIndex == -1)
                    {
                        howCanWeHelpIndex = taskComments.indexOf('Artikeldetails:');
                        descLabel='Artikeldetails:';
                        if(howCanWeHelpIndex == -1) 
                        {
                            howCanWeHelpIndex = taskComments.indexOf('Project Details:');
                            descLabel='Project Details:';
                            if(howCanWeHelpIndex == -1)
                            {
                                howCanWeHelpIndex = taskComments.indexOf('Application Description:');
                                descLabel='Application Description:';
                                if(howCanWeHelpIndex == -1)
                                    containValue = false;
                                else
                                    containValue = true;
                            }
                            else     
                            {
                                containValue = true;
                            }
                        }
                        else   
                        {
                        	containValue = true;
                        }
                    }
                    else
                        containValue = false;
                }
                else
                {
                    containValue = true;
                }
                if(containValue)
                {
                    descLength = descLabel.length();
                    apexParsedValue = taskComments.substring(howCanWeHelpIndex+descLength);
                    system.debug('apexParsedValue : '+apexParsedValue);
                    List<String> lstHelp = apexParsedValue.split('\n|\r\n');
                    for ( String row : lstHelp ) {
                        row = row.trim(); 
                        
                        Boolean contain = row.contains('Lead Sources Detail:');
                        if(contain)
                        {
                            apexParsedValueNew = apexParsedValue.substring(0, apexParsedValue.indexOf(row));
                            break;
                        }
                        else if(row.contains('Estimated Yearly Quantity Required:'))
                        {
                           apexParsedValueNew = apexParsedValue.substring(0, apexParsedValue.indexOf(row));
                            break; 
                        }
                    }
                }
                //return apexParsedValueNew;
        	}
            
        
        system.debug(' Apex value : -' + apexParsedValueNew);
      	listTaskDesc.add(apexParsedValueNew);
        }
        return listTaskDesc;
    }
    
    public static string parseCommentsQuestions( string taskComments)
    {
        //system.debug('taskComments : '+taskComments);
       howCanWeHelpIndex = taskComments.indexOf('Comments/Questions:');
       descLabel='Comments/Questions:';
        boolean containValue = false;
        if(howCanWeHelpIndex == -1)
        {
            howCanWeHelpIndex = taskComments.indexOf('Anfrage:');
            descLabel='Anfrage:';
            if(howCanWeHelpIndex == -1)
            {
                howCanWeHelpIndex = taskComments.indexOf('Enquête:');
                descLabel='Enquête:';
                 if(howCanWeHelpIndex == -1)   
                     containValue = false;
                else                        
                    containValue = true;
            }
            else
                containValue = false;
        }
        else
        {
            containValue = true;
        }
        if(containValue)
        {
            descLength = descLabel.length();
            apexParsedValue = taskComments.substring(howCanWeHelpIndex+descLength);
            List<String> lstHelp = apexParsedValue.split('\n|\r\n');
            for ( String row : lstHelp ) {
                row = row.trim();               
                Boolean contain = row.contains('Lead Sources Detail:');
                if(contain)
                {
                    apexParsedValueNew = apexParsedValue.substring(0, apexParsedValue.indexOf(row));
                    break;
                }
        	}
        }        
        return apexParsedValueNew;        
    }
        
}