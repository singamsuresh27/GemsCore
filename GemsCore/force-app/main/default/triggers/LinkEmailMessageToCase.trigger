//test class - LinkEmailMessageToCaseTest
trigger LinkEmailMessageToCase on EmailMessage (before insert) {
    for (EmailMessage em : Trigger.new) {
        // Only process incoming emails
        if (em.Incoming && em.Subject != null) {
            // Initialize the debug record
          //  Email_Debug__c debugLog = new Email_Debug__c();
            
            // Capture the email subject
          //  debugLog.Email_Subject__c = em.Subject;
            
            // Case-insensitive regex to extract the ref number (customize regex as needed)
            Pattern pattern = Pattern.compile('(?i)Ref:\\s*([^\\s]+)');

            Matcher matcher = pattern.matcher(em.Subject);
            
            // Initialize extracted ref and set debug log field
            String ref = null;
            if (matcher.find()) {
                ref = matcher.group(1);  // Extracted ref like 'ABC123'
              //  debugLog.Extracted_Ref_c__c = ref; // Log the extracted ref (Fix)
            } else {
              //  debugLog.Extracted_Ref_c__c = 'No match found'; // Log failure if no match
            }

            // Query for the Case based on Email_Ref_No__c
            List<Case> cases = [
                SELECT Id, Email_Ref_No__c FROM Case WHERE Email_Ref_No__c = :ref LIMIT 1
            ];

            // Log whether a Case was found
            if (!cases.isEmpty()) {
                em.ParentId = cases[0].Id; // Link to Case
              /*  debugLog.Case_Ref__c = cases[0].Email_Ref_No__c; // Store Case reference
                debugLog.Case_Found_c__c = true; // Flag as true if case found
                debugLog.ParentId_c__c = cases[0].Id; // Store the Case ID
                debugLog.Status__c = 'Case Linked';  */
            } else {
              //  debugLog.Case_Found_c__c = false; // Flag as false if no case found
              //  debugLog.Status__c = 'No Case Found';
            }

            // Insert the debug log record
         //   insert debugLog; // Save the log for review
        }
    }
}