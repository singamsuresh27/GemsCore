@isTest
public class TestCalculateCaseInitialContactBH {
		static testMethod void calculateBusinessHours() {
            List<id> Ids= New List<Id>();
            Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        	insert cas;            
            Case newCas = [select Id,CreatedDate from Case where id =: cas.Id limit 1];
            Datetime stDate = newCas.CreatedDate;
            Datetime edDate = newCas.CreatedDate + 1;
            CalculateCaseInitialContactBusinessHours.flowInputs flwInputs= new CalculateCaseInitialContactBusinessHours.flowInputs();
            flwInputs.startDate = stDate;
            flwInputs.endDate = edDate;
            CalculateCaseInitialContactBusinessHours.CalculateBusinessHours(
            new List<CalculateCaseInitialContactBusinessHours.FlowInputs>{flwInputs}
        	);  
        }
    	static testMethod void calculateBusinessHours1() {
            List<id> Ids= New List<Id>();
            Case cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email'); 
        	insert cas;            
            Case newCas = [select Id,CreatedDate from Case where id =: cas.Id limit 1];
            Datetime stDate = newCas.CreatedDate;
            Datetime edDate;
            CalculateCaseInitialContactBusinessHours.flowInputs flwInputs= new CalculateCaseInitialContactBusinessHours.flowInputs();
            flwInputs.startDate = stDate;
            flwInputs.endDate = edDate;
            CalculateCaseInitialContactBusinessHours.CalculateBusinessHours(
            new List<CalculateCaseInitialContactBusinessHours.FlowInputs>{flwInputs}
        	);  
        }
}