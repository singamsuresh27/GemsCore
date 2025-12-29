@isTest
public class TestContractExpirationReminder {

static testMethod void sendContractReminder() {
        
        // Create the heirarchy of objects
        // starting with Account
        List<id> Ids= New List<Id>();
     	User userToCreate = [Select id from user where profile.name='System Administrator' Limit 1];
        Account act = new Account(
            Name = 'Test Account', BillingCity = 'Hartland', BillingState = 'Wisconsin', BillingCountry = 'United States', 
            BillingPostalCode = '55009', BillingStreet = '1234 First St.',ownerId=userToCreate.id,CEMS_Renewal_Price__c=20,CEMS_Length_of_Contract__c='1 Year',CEMS_Primary_Email__c='test@non.com');
        insert act;
        
    system.debug(' ownerid : '+ act.OwnerId);
        // Then the contact
        Contact con = new Contact(
            FirstName = 'Unit', LastName = 'Test', Email = 'noN@non.com', AccountId = act.Id,Role__c='CEMS Primary');
        insert con;
    
    	// Then the contract
        Contract ctract = new Contract(
            AccountId = act.id, Status = 'Draft', StartDate = Date.today(),ContractTerm=1);
        insert ctract;
       	//Ids.add(con.id);
       
    	ContractExpirationReminder.flowInputs inpt = new ContractExpirationReminder.flowInputs();
    	inpt.currentRecordId = ctract.Id;
    	inpt.myCustomString='30';
    	ContractExpirationReminder.parseContract(new List<ContractExpirationReminder.flowInputs>{inpt});
    
    	inpt = new ContractExpirationReminder.flowInputs();
    	inpt.currentRecordId = ctract.Id;
    	inpt.myCustomString='60';
    	ContractExpirationReminder.parseContract(new List<ContractExpirationReminder.flowInputs>{inpt});
    
    	inpt = new ContractExpirationReminder.flowInputs();
    	inpt.currentRecordId = ctract.Id;
    	inpt.myCustomString='90';
    	ContractExpirationReminder.parseContract(new List<ContractExpirationReminder.flowInputs>{inpt});
        
    }
}