/**------------------------------------------------------------------------------------
* @File Name        :  AILeadScoringPullAPI
* @Description      :  AI LeadScoring Pull API
* @Author           :  Thirumoorthy Mani
* @Group            :  Class
* @Modification Log :  
* @Test class		: LeadTriggerTest
* 1.0                  2024-06-26                    
* -------------------------------------------------------------------------------------
**/
public class AILeadScoringPullAPI {
    @future(callout=true)    
    public static void pullLeadScoring(Id leadId, String service){
        Integer responseCode;
        system.debug(' leadId : '+leadId);
        system.debug(' service : '+service);
        String requestBody,responseBody,encodedAppDetails, jsonPayload;
        Lead currentLead = new Lead();
        Http http = new Http();
        Map<String, Object> payloadBody = new Map<String, Object>();
        
        Lead updateLead = new Lead();
        updateLead.Id = leadId;
        try{
            Constants_For_Apex__mdt leadScoreEndPoint = Constants_For_Apex__mdt.getInstance('AILeadScoreEndPoint');
            HttpRequest getLeadScoreRequest = createHttpRequest(leadScoreEndPoint.Value__c, service);
            currentLead = getLeadData(LeadId);
            system.debug('currentLead : '+currentLead);
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
            responseBody = leadScoreResponse.getBody();
            system.debug(' RESPONSE BODY: '+ responseBody);
            responseCode = leadScoreResponse.getStatusCode();
             
            if(responseCode == 200)
            {   
                If(service == 'profile')
                {
                    LeadScoringAPIProfileResponse apiResponse = (LeadScoringAPIProfileResponse) JSON.deserialize(responseBody, LeadScoringAPIProfileResponse.class);
                    
                    system.debug('apiResponse : '+apiResponse);
                    updateLead.Potential_Label__c = apiResponse.Potential_Label;
                    updateLead.Potential_Explanation__c = apiResponse.Potential_Explanation;
                    updateLead.Profile_Label__c = apiResponse.Profile_Label;
                    updateLead.Profile_Explanation__c = apiResponse.Profile_Explanation;
                }
                else 
                {
                    LeadScoringAPIPotentialResponse apiResponse = (LeadScoringAPIPotentialResponse) JSON.deserialize(responseBody, LeadScoringAPIPotentialResponse.class);
				  	updateLead.Potential_Label__c = apiResponse.Potential_Label;
                	updateLead.Potential_Explanation__c = apiResponse.Explanation;
                }
            }
            else
            {
                ErrorResponse apiErrorResponse = (ErrorResponse) JSON.deserialize(responseBody, ErrorResponse.class);
				updateLead.AI_API_Error__c = 'Status Code : '+responseCode + ' - ' + apiErrorResponse.error;
            }
            system.debug('responseBody : '+responseBody);    
        }
        catch(Exception ex)
        {
            updateLead.AI_API_Error__c = ex.getMessage();
            
             system.debug('EXCEPTION : '+ex.getMessage());
        }
        if(updateLead != null)
        	update updateLead;
    	
    }
   /**-------------------------------------------------------------------------------------
    * @Method Name	:  	createHttpRequest
    * @Description  :  	Method to create Http Request to make a callout
    * @Author       :	Thirumoorthy Mani
    * @Group        :  	Method
    * @Param		:	String
    * @Return		:	HttpRequest
    * -------------------------------------------------------------------------------------
    **/
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
     /*******************************
    * @Author Name - Thirumoorthy Mani
    * @Description -  To query the Lead Records based on leadID
    * @Created Date - 2024-06-26
    * 
    * ***************************/
    public static Lead getLeadData(ID leadID){
        Lead currentLead = new Lead();
        If(!Test.isRunningTest())
        {
        	currentLead = [SELECT id, Title, Company, Email, Sub_Market_Setra__c, Product_Of_Interest__c, Application_Detail__c, AI_API_Error__c  
                FROM Lead 
                WHERE Id =: leadID LIMIT 1]; 
        }
        else
        {
            currentLead = [SELECT id, Title, Company, Email, Sub_Market_Setra__c, Product_Of_Interest__c, Application_Detail__c, AI_API_Error__c  
                FROM Lead LIMIT 1]; 
        }
        return currentLead;
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