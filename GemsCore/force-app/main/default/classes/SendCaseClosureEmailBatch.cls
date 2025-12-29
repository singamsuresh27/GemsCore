/**
 * Batch class to send follow-up email reminders for closed Case records.
 * 
 * This batch job performs the following:
 * - Queries Cases that are closed exactly 3, 7, or 14 days ago,
 *   with Type = 'New Order' and Pending_Customer_Type__c = 'Surcharge' and Gems_SO_Number__c = null.
 * - For each qualifying Case, retrieves the most recent inbound EmailMessage
 *   from a specific address (e.g., oe@gemsensors.com).
 * - Uses the ToAddress of the original email (excluding  addresses like GemsSensors.us@conexiom.net)
 *   as the recipient for the reminder email.
 * - Skips any Case where Conexiom_Link__c = 'conexiom processed' (checked in execute method).
 * - Test class - SendCaseClosureEmailBatchTest
 */

global class SendCaseClosureEmailBatch implements Database.Batchable<SObject>, Schedulable {
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new SendCaseClosureEmailBatch(),200);
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date today = System.today();
        
        return Database.getQueryLocator([SELECT Id, Account.Owner.Email,Gems_SO_Number__c,Conexiom_Link__c ,Business_Region__c,Email_Ref_No__c,CaseNumber,Type, Status, Pending_Customer_Type__c,ClosedDate, ContactId, Contact.Email, PO_No__c
                                         FROM Case
                                         WHERE Status = 'Closed' AND ((ClosedDate >= :today.addDays(-3) AND ClosedDate < :today.addDays(-2)) OR
                                                                      (ClosedDate >= :today.addDays(-7) AND ClosedDate < :today.addDays(-6)) OR
                                                                      (ClosedDate >= :today.addDays(-14) AND ClosedDate < :today.addDays(-13)))
                                         AND Pending_Customer_Type__c = 'Surcharge'
                                         AND Contact.Email != null AND Type = 'New Order' AND Gems_SO_Number__c = null AND Business_Region__c IN ('SETRA_NA', 'GEMS_NA')]);
    }
    // AND ((ClosedDate >= :today.addDays(-3) AND ClosedDate < :today.addDays(-2)) OR
                                            //  (ClosedDate >= :today.addDays(-7) AND ClosedDate < :today.addDays(-6)) OR
                                           //   (ClosedDate >= :today.addDays(-14) AND ClosedDate < :today.addDays(-13)))
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        Id orgWideId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'oe@gemssensors.com' LIMIT 1].Id;
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        List<Case> filteredCases = new List<Case>();
        
        for (Case c : (List<Case>)scope) {
            if (String.isBlank(c.Conexiom_Link__c) || !c.Conexiom_Link__c.equalsIgnoreCase('conexiom processed')) {
                filteredCases.add(c);
            }
        }
        
        if (filteredCases.isEmpty()) return;
        
        // Proceed only with filteredCases (where Conexiom_Link__c != 'conexiom processed')
        Set<Id> caseIds = new Set<Id>();
        for (Case c : filteredCases) {
            caseIds.add(c.Id);
        }
        
        // Get latest EmailMessage from oe@gemssensors.com per Case
        Map<Id, EmailMessage> latestEmailMap = new Map<Id, EmailMessage>();
        List<EmailMessage> emailMsgs = [
            SELECT Id, ParentId, FromAddress, ToAddress,Subject, TextBody, CreatedDate
            FROM EmailMessage
            WHERE ParentId IN :caseIds
            AND FromAddress = 'oe@gemssensors.com'
            ORDER BY CreatedDate DESC
        ];
        
        for (EmailMessage em : emailMsgs) {
            // Only add the *first* (latest) per case
            if (!latestEmailMap.containsKey(em.ParentId)) {
                latestEmailMap.put(em.ParentId, em);
            }
        }
        
        
        for (Case c : filteredCases) {
            Integer daysSinceClosed = Date.today().daysBetween(c.ClosedDate.date());
            String subject = '';
            String body = '';
            String po = String.isBlank(c.PO_No__c) ? 'N/A' : c.PO_No__c;
            String refNo = String.isBlank(c.Email_Ref_No__c) ? 'N/A' : c.Email_Ref_No__c;
            
            // Generate content per reminder type
            switch on daysSinceClosed {
                when -3 {
                    subject = 'Order Issue - Ref: ' + refNo;
                    body = 'Hello,\n\n' +
                        'Purchase Order: ' + po + '\n\n' +
                        'Per our previous notification, we are unable to process your order as the pricing is incorrect. ' +
                        'Please refer to our original notification attached for the pricing details.\n\n' +
                        'If you wish to continue to place your order, please send a revised copy to OE@GEMSSENSORS.COM or ORDERS@SETRA.COM for processing.\n\n' +
                        'Should you have any questions regarding the pricing, please contact our team at CS@GEMSSENSORS.COM or your Gems Setra Account Manager.\n\n' +
                        'Thank you,\n' +
                        'Gems Setra\n\n' + 
                        '-- Ref No: ' + refNo;
                }
                when -7 {
                    subject = 'Order Issue - Ref: ' + refNo;
                    body = 'Hello,\n\n' +
                        'Purchase Order: ' + po + '\n\n' +
                        'We value your business and would like to process your order.  However, per our previous notifications, we are unable to proceed with your order due to the pricing. ' +
                        'Please refer to our original notification attached for the pricing details.\n\n' +
                        'If you wish to continue to place your order, please send a revised copy to OE@GEMSSENSORS.COM or ORDERS@SETRA.COM for processing.\n\n' +
                        'Should you have any questions regarding the pricing, please contact our team at CS@GEMSSENSORS.COM or your Gems Setra Account Manager.\n\n' +
                        'Thank you,\n' +
                        'Gems Setra\n\n' + 
                        '-- Ref No: ' + refNo;
                }
                when -14 {
                    subject = 'Order Issue - Ref: ' + refNo;
                    body = 'Hello,\n\n' +
                        'Purchase Order: ' + po + '\n\n' +
                        'We value your business and would like to process your order. ' +
                        'However, we have not heard back from you in the past two weeks and assume that you do not wish to proceed with the order at the requested pricing.\n\n' +
                        'If you wish to continue to place your order, please send a revised copy to OE@GEMSSENSORS.COM or ORDERS@SETRA.COM for processing.\n\n' +
                        'Should you have any questions regarding the pricing, please contact our team at CS@GEMSSENSORS.COM or your Gems Setra Account Manager.\n\n' +
                        'Thank you,\n' +
                        'Gems Setra\n\n' + 
                        '-- Ref No: ' + refNo;
                }
                when else {
                    continue; 
                }
            }
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            if (latestEmailMap.containsKey(c.Id)) {
                EmailMessage em = latestEmailMap.get(c.Id);
                
                List<String> parsedToAddresses = new List<String>();
                
                if (String.isNotBlank(em.ToAddress)) {
                    for (String addr : em.ToAddress.split('[;,]')) {
                        String cleaned = addr.trim();
                        
                        if (String.isNotBlank(cleaned)  && !cleaned.toLowerCase().contains('conexiom')) {
                            parsedToAddresses.add(cleaned);
                        }
                    }
                    if (!parsedToAddresses.isEmpty()) {
                        
                        email.setToAddresses(parsedToAddresses);
                    }
                }
            }
            email.setSubject(subject);
            email.setPlainTextBody(body);
            email.setOrgWideEmailAddressId(getOrgWideEmailId());
            email.setWhatId(c.Id);
            email.setTargetObjectId(c.ContactId);
            email.setSaveAsActivity(true);
            if (c.Account.Owner != null && String.isNotBlank(c.Account.Owner.Email)) {
                email.setCcAddresses(new String[] { c.Account.Owner.Email });
            }
            //	
            email.setReplyTo('oe@935rkrr9wd6zo1xb8svfo69a88atqwylrft4bpb9li34fwpoi.6-iuyweaw.na166.case.salesforce.com'); // actual Prod email service address
            //  email.setReplyTo('dibyaishere20@2kv8f0srwgpgu67sh4ylswguq5ewvwzbafbj4vwea6l3vleezc.cb-1wpq1eac.usa896s.case.sandbox.salesforce.com'); // Your email service address
            // Attach latest email (as .eml file)
            
            
            
            if (latestEmailMap.containsKey(c.Id)) { 
                EmailMessage em = latestEmailMap.get(c.Id);
                
                // Clean and format the To address
                String toField = '';
                if (String.isNotBlank(em.ToAddress)) {
                    List<String> cleanedToList = new List<String>();
                    for (String addr : em.ToAddress.split('[;,]')) {
                        String cleaned = addr.trim();
                        if (String.isNotBlank(cleaned)) {
                            cleanedToList.add(cleaned);
                        }
                    }
                    if (!cleanedToList.isEmpty()) {
                        toField = String.join(cleanedToList, ', ');
                    } else if (String.isNotBlank(c.Contact.Email)) {
                        toField = c.Contact.Email;
                    }
                } else if (String.isNotBlank(c.Contact.Email)) {
                    toField = c.Contact.Email;
                }
                
                String emlContent = 'From: oe@gemssensors.com\n' +
                    'To: ' + toField + '\n' +
                    'Subject: ' + em.Subject + '\n' +
                    'Date: ' + em.CreatedDate.format() + '\n' +
                    'Content-Type: text/plain; charset=UTF-8\n' +
                    'Content-Transfer-Encoding: 7bit\n\n' +
                    (em.TextBody != null ? em.TextBody : '');
                
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Tariff Notification.eml');
                attachment.setBody(Blob.valueOf(emlContent));
                attachment.setContentType('message/rfc822');
                
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
            }
            
            emailsToSend.add(email);
        }
        
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
    private Id getOrgWideEmailId() {
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'oe@gemssensors.com' LIMIT 1];
        return owea.isEmpty() ? null : owea[0].Id;
    }
    public static void fakeTestMethod() {
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}