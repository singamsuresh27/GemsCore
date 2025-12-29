/**------------------------------------------------------------------------------------
* @File Name        :  AILeadScoringPullAPIQueueable
* @Author           :  Thirumoorthy Mani
* @Modification Log :  
* @Test class		: LeadTriggerTest
* 1.0                  2024-07-03                   
* -------------------------------------------------------------------------------------
**/
public class AILeadScoringPullAPIQueueable implements Queueable, Database.AllowsCallouts {
    private String service;
    private List<Id> allLeadIds;
    private Integer batchSize, batchIndex;
   
    public AILeadScoringPullAPIQueueable(List<Id> leadIds) {
      	this.allLeadIds = leadIds;
    }
	
    public void execute(QueueableContext context) {
        List<Id> currentBatchLeadIds = new List<Id>();
        Try
        {
            
            Constants_For_Apex__mdt leadScoreBatchSize = Constants_For_Apex__mdt.getInstance('AILeadScoreBathSize');
            batchSize = Integer.valueOf(leadScoreBatchSize.Value__c);
            if(batchSize <= 0)
            {
                batchSize = 10;
            }
            for (Integer i = 0; i < Math.min(allLeadIds.size(), batchSize); i++){
                currentBatchLeadIds.add(allLeadIds[i]);
            }
            if (currentBatchLeadIds.isEmpty()) {
                return;
            }
            List<Lead> newleadsList = [SELECT id, Title, Company, Email, Sub_Market_Setra__c, Product_Of_Interest__c, Application_Detail__c, AI_API_Error__c  
                FROM Lead 
                WHERE Id IN :currentBatchLeadIds];
            
            List<Lead> leadsToUpdate = new List<Lead>();
            for (Lead currentLead : newleadsList) {
                    try
                    {
                         if(string.isNotEmpty(currentLead.Title) && string.isNotEmpty(currentLead.Company)
                           && string.isNotEmpty(currentLead.Email)&& string.isNotEmpty(currentLead.Sub_Market_Setra__c)
                           && string.isNotEmpty(currentLead.Product_Of_Interest__c)&& string.isNotEmpty(currentLead.Application_Detail__c))                   
                        {
                            service = 'profile';
                        } 
                        else if(string.isNotEmpty(currentLead.Application_Detail__c))
                        {
                            service = 'potential';
                        }
                        HttpResponse leadScoreResponse = callLeadScoringAPI(currentLead, service);
                        String responseBody = leadScoreResponse.getBody();
                        Integer responseCode = leadScoreResponse.getStatusCode();
                        String responseStatus = leadScoreResponse.getStatus();
                        system.debug('responseBody : '+responseBody);
                        system.debug('responseStatus : '+responseStatus);
                        if(responseCode == 200)
                        {   
                            if(service == 'profile')
                            {
                                LeadScoringAPIProfileResponse apiResponse = (LeadScoringAPIProfileResponse) JSON.deserialize(responseBody, LeadScoringAPIProfileResponse.class);
                                
                                system.debug('apiResponse : '+apiResponse);
                                currentLead.Potential_Label__c = apiResponse.Potential_Label;
                                currentLead.Potential_Explanation__c = apiResponse.Potential_Explanation;
                                currentLead.Profile_Label__c = apiResponse.Profile_Label;
                                currentLead.Profile_Explanation__c = apiResponse.Profile_Explanation;
                            }
                            else 
                            {
                                LeadScoringAPIPotentialResponse apiResponse = (LeadScoringAPIPotentialResponse) JSON.deserialize(responseBody, LeadScoringAPIPotentialResponse.class);
                                currentLead.Potential_Label__c = apiResponse.Potential_Label;
                                currentLead.Potential_Explanation__c = apiResponse.Explanation;
                            }
                        }
                        else if(responseCode == 503)
                        {
                            //ErrorResponse apiErrorResponse = (ErrorResponse) JSON.deserialize(responseBody, ErrorResponse.class);
                            sendEmailNotification();
                            currentLead.AI_API_Error__c = 'Status Code : '+responseCode + ' - ' + responseStatus;
                        }
                        else
                        {
                            ErrorResponse apiErrorResponse = (ErrorResponse) JSON.deserialize(responseBody, ErrorResponse.class);
                            currentLead.AI_API_Error__c = 'Status Code : '+responseCode + ' - ' + apiErrorResponse.error;
                        }
                    }
                    catch(Exception ex)
                    {
                        system.debug('EXCEPTION : '+ ex.getMessage());
                        currentLead.AI_API_Error__c = 'Exception: ' + ex.getMessage();
                    }            
                    leadsToUpdate.add(currentLead);
            }
            if (!leadsToUpdate.isEmpty()) {
                Database.update(leadsToUpdate, false);
            }
            
            List<Id> remainingLeadIds = new List<Id>();
            for (Integer i = batchSize; i < allLeadIds.size(); i++) {
                remainingLeadIds.add(allLeadIds[i]);
            }
            if(remainingLeadIds.isEmpty()){
                return;
            }
            System.enqueueJob(new AILeadScoringPullAPIQueueable(remainingLeadIds));
            
        }
        Catch(Exception ex)
        {
            system.debug('Exception in AILeadScoringPullAPIQueueable : '+ ex.getMessage());
        }
      
    }
    private HttpResponse callLeadScoringAPI(Lead currentLead, String service) {
        Integer responseCode;
        String requestBody,responseBody,encodedAppDetails, jsonPayload;
        Http http = new Http();
        Map<String, Object> payloadBody = new Map<String, Object>();
               
        Constants_For_Apex__mdt leadScoreEndPoint = Constants_For_Apex__mdt.getInstance('AILeadScoreEndPoint');
        system.debug('currentLead : '+currentLead);
      
        HttpRequest getLeadScoreRequest = createHttpRequest(leadScoreEndPoint.Value__c, service);
        
        if(service == 'profile')
        {
            payloadBody = new Map<String, Object>{
                'job_title' => currentLead.Title,
            	'company_name' => currentLead.Company,
                'email' => currentLead.Email,
                'market_type' => currentLead.Sub_Market_Setra__c,
                'product_interest' => currentLead.Product_Of_Interest__c,
                'app_detail' => currentLead.Application_Detail__c
                };
        }
        else
        {
            payloadBody = new Map<String, Object>{
                'app_detail' => currentLead.Application_Detail__c
                };
        }
        jsonPayload = JSON.serialize(payloadBody);
        
        system.debug(' jsonPayload : '+jsonPayload);
        getLeadScoreRequest.setBody(jsonPayload);
        HttpResponse leadScoreResponse = http.send(getLeadScoreRequest);  
        system.debug(' RESPONSE : '+ leadScoreResponse);
        system.debug(' RESPONSE CODE: '+ leadScoreResponse.getStatusCode());
        
        return leadScoreResponse;
    } 
    public static void sendEmailNotification() {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress sender = [select Id,Address,DisplayName from OrgWideEmailAddress where DisplayName = 'Gems Sensors' LIMIT 1];
           	
        // Fetch email addresses from custom metadata
        Constants_For_Apex__mdt leadScoringApiUsers = Constants_For_Apex__mdt.getInstance('LeadScoringAPIErrorUsers');
        Constants_For_Apex__mdt leadScoringApiErrorMessage = Constants_For_Apex__mdt.getInstance('LeadScoringAPIErrorMessage');
        Set<String> userSet = new Set<String>();
        
        if(leadScoringApiUsers != null && leadScoringApiUsers.Value__c != null)
        {
        	userSet = new Set<String>(leadScoringApiUsers.Value__c.split(';'));
        }
        
        if(userSet.isEmpty())
        {
            return;
        }
        list<String> toAddresses=new list<string>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Lead Scoring API Server Unavailability');
        email.setHtmlBody(leadScoringApiErrorMessage.Value__c);
        if(sender != null)
        	email.setOrgWideEmailAddressId(sender.Id);
        emails.add(email);
        
        for (String userEmail : userSet) {
            toAddresses.add(userEmail);
        }
        email.setToAddresses(toAddresses);
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
   	public void finish(Database.BatchableContext bc) {
    }
   	public static HttpRequest createHttpRequest(String endPointUrl, String service)
    {
        system.debug(' createHttpRequest ');        
        HttpRequest request = new HttpRequest();
        request.setTimeout(120000);
        request.setMethod('POST');           
        request.setEndpoint(endPointUrl+'/'+service);
        request.setHeader('Content-Type','application/json');
        return request;
    }  
    public class LeadScoringAPIPotentialResponse{
    	public String App_detail;
    	public String Potential_Label;
        public String Explanation;
    }
    public class LeadScoringAPIProfileResponse{
    	public String Potential_Explanation;
    	public String Potential_Label;
        public String Profile_Explanation;
        public String Profile_Label;
    }
    public class ErrorResponse{
    	public String error;
    }	
}