public class CalculateCaseInitialContactBusinessHours {
    
    @InvocableMethod 
    public static List<flowOutputs> CalculateBusinessHours(flowInputs[] currentInput){
        flowOutputs returnValues = new flowOutputs();
        List<FlowOutputs> returns = new List<FlowOutputs>();
        Decimal timeForInitialContact,totalHours,daysInDecimal,hours,days,hoursInDays;
        string daysInString,bHoursText;
        try{
            DateTime caseStartDate = currentInput[0].startDate;
            DateTime caseEndDate = currentInput[0].endDate;
            string caseBusinessUnit = currentInput[0].businessUnit;
            if(string.isEmpty(caseBusinessUnit) || caseBusinessUnit == null)
            {
                caseBusinessUnit = 'GEMS_NA';
            }
            BusinessHours defaultHours = new BusinessHours();
            if(caseBusinessUnit == 'GEMS_EU')
            {
                defaultHours = [select name, Id from BusinessHours where name='GEMS_EU' limit 1];
            }
            else
            {
            	defaultHours = [select name, Id from BusinessHours where name='GEMS_NA' limit 1];
            }
            timeForInitialContact = BusinessHours.diff(defaultHours.Id, caseStartDate,caseEndDate );
            timeForInitialContact = timeForInitialContact/3600000.0;
            system.debug('timeForInitialContact 1: '+timeForInitialContact);  
            timeForInitialContact = timeForInitialContact.setScale(2);
            system.debug('timeForInitialContact 2: '+timeForInitialContact);            
            totalHours = timeForInitialContact;
            if(totalHours < 1)
            {
                totalHours = timeForInitialContact;
            }
            daysInDecimal = totalHours/8.5;  
            if(string.valueOf(daysInDecimal).contains('.')){
                days =  daysInDecimal.round(System.RoundingMode.DOWN);
                hoursInDays = daysInDecimal - daysInDecimal.round(System.RoundingMode.DOWN);
            }
            else
                days = daysInDecimal;
            
            if( daysInDecimal > 1)
            	hours = hoursInDays * 8.5;
            else
                hours = totalHours;
            bHoursText = days.format()+' Days(s) '+ hours.format() +' Hours(s)';
            system.debug('Time : '+bHoursText);
            returnValues.caseBHours = timeForInitialContact;
            returnValues.caseBHoursText = bHoursText;
            returns.add(returnValues);
            return returns;
            }
        catch (Exception e) {
            returnValues.caseBHours = 0;
            returnValues.caseBHoursText = 'Error';
            returnValues.apexReturned=e.getMessage();
            returns.add(returnValues);
            return returns;
        }
    }
    
     public class flowInputs {                  
        @InvocableVariable public DateTime startDate; 
        @InvocableVariable public DateTime endDate;
        @InvocableVariable public string businessUnit;
      }
     public class flowOutputs{
    	@InvocableVariable public Decimal caseBHours;
        @InvocableVariable public string caseBHoursText;
        @InvocableVariable public string apexReturned; 
  	}
}