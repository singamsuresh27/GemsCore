public class lineItemController{
    public string caseDetailId{get; set;}
    public Case_Detail__c LineItem{
        get{
            Case_Detail__c li = new Case_Detail__c(); 
            if(caseDetailId != null){
                li = [Select Id, Name, Date_Evaluation_Started__c, Order_Shipment__r.PONumber__c,
                          Case__r.Account.Name, Case__r.Contact.FirstName, Case__r.Contact.LastName, Case__r.Customer_Internal_Case_RA_No__c, Quantity__c,
                          Order_Shipment__r.Productid__r.ProductCode, Date_Code_Serial_No__c, Case__r.Customer_Part_Number__c, 
                          Order_Shipment__r.Productid__r.Description, Case__r.Description, Receivers_Comment__c, Warranty_Type__c,
                          Recommendations__c, Date_Evaluation_Completed__c 
                      From Case_Detail__c where id = :caseDetailId];
            }
             return li;
        }
    }
    public lineItemController(){
      
    }
}