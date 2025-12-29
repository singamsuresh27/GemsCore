public class CopyJDEAttachmentToCase {
       
@InvocableMethod        
    public static List<flowOutputs> parseCase(List<Id> MsgIds)
    {
        string msgSubject,soNumber;
        boolean returnSuccess=false;
        Case targetCase = new case();
        Case sourceJDECase = new case();  
        List<id> caseIds = new list<id>();
        List<string> caseWithSOList = new list<string>();
        List<Case> caseToUpdate = new list<Case>();
        List<FlowOutputs> results = new List<FlowOutputs>();
        flowOutputs returnValues = new flowOutputs();
        List<Attachment> insertAttList = new List<Attachment>();
        List<Attachment> attachmentsToDelete = new List<Attachment>();
       	List<Attachment> allAttachments = new List<Attachment>();
        Map<id,list<Attachment>> emailAttachmentsMap = new Map<id,list<Attachment>>();
        Map<string,Case> soWithCaseIDMap = new Map<string,Case>();
        Map<Id,Case> msgCaseMap = new Map<Id,Case>();
        try
        {
            List<EmailMessage> msgList =[select id,Subject,ParentId,ToAddress,FromAddress,Incoming,HasAttachment,HtmlBody,TextBody from EmailMessage where EmailMessage.id in :MsgIds];
	    	for (EmailMessage msg: msgList) 
            {
                caseIds.add(msg.ParentId);
                msgSubject = msg.Subject;
                if(msgSubject.indexOf(':') >= 0 || msgSubject.indexOf('"') >= 0)
                {
                    soNumber = (msgSubject.indexOf(':') >= 0) ? msgSubject.substring(0, msgSubject.indexOf(':')) : msgSubject.substring(0, msgSubject.indexOf('"'));
                }
                caseWithSOList.add(soNumber);
            }
            List<Case> caseList =[select id,subject,accountid,CreatedDate,CaseNumber,Status,OwnerId from case where case.id IN : caseIds];
           	for (EmailMessage emailMsg: msgList) 
            {
                 for (Case cas: caseList) 
            	{
                    if(emailMsg.ParentId == cas.id){
                        msgCaseMap.put(emailMsg.id,cas);
                        //system.debug(' emailMsg.id : '+emailMsg.id);
                        //system.debug(' Source case id : '+cas.id);
                    }
            	}  
            }
            
            for (Case caseWithSO: [select id,Gems_SO_Number__c from case where case.Gems_SO_Number__c IN :caseWithSOList]) 
            {
                soWithCaseIDMap.put(caseWithSO.Gems_SO_Number__c,caseWithSO);
            }
            for (Attachment a : [select id, name,parentId, body,OwnerId,ContentType from Attachment where ParentId IN :MsgIds])
            {
                if(emailAttachmentsMap.containsKey(a.ParentId)){
                    List<Attachment> tempLst = emailAttachmentsMap.get(a.ParentId);                    
                    tempLst.add(a);
                    emailAttachmentsMap.put(a.ParentId,tempLst);
                }else{
                    List<Attachment> initalLst = new List<Attachment>();
                    initalLst.add(a);
                    emailAttachmentsMap.put(a.ParentId,initalLst);
                }
            }
            for(EmailMessage msg : msgList)
            {                
                msgSubject = msg.Subject;
                Id sourceCaseId = msg.ParentId;
                if(msgSubject.indexOf(':') >= 0 || msgSubject.indexOf('"') >= 0)
                {
                    soNumber = (msgSubject.indexOf(':') >= 0) ? msgSubject.substring(0, msgSubject.indexOf(':')) : msgSubject.substring(0, msgSubject.indexOf('"'));
                    targetCase = soWithCaseIDMap.get(soNumber);
                }
                system.debug ('SO Number : '+soNumber);                
                if(targetCase != null && targetCase.Id != null)
                {                   
                    if(emailAttachmentsMap.get(msg.Id) != null)
               			allAttachments = emailAttachmentsMap.get(msg.Id);
                     for(Attachment att:allAttachments){
                         Attachment  b = att.clone();
                         b.parentid = targetCase.id;
                         b.ContentType= att.ContentType;
                         insertAttList.add(b); 
                         attachmentsToDelete.add(att);
                         system.debug('targetCase.id : ' +targetCase.id); 
                     }
                    if(insertAttList.size()>0)
                    {
                        insert insertAttList;
                        returnSuccess = true;
                    }
                    if(attachmentsToDelete.size()>0)
                    {
                        delete attachmentsToDelete;
                        returnSuccess = true;
                    }   
                    if(returnSuccess == true)
                    {
                        sourceJDECase =msgCaseMap.get(msg.Id);
                        if(sourceJDECase != null)
                        {
                            sourceJDECase.Status = 'Closed';
                            caseToUpdate.add(sourceJDECase);
                            returnValues.apexOutput='Success';            
                            results.add(returnValues);
                        }
                    }
                }
            }
            system.debug(' caseToUpdate Size:'+caseToUpdate.size());
            if(caseToUpdate.size() > 0)
            	update caseToUpdate;
        }
        catch (Exception e) {
            String errorMsg = 'CopyJDEAttachmentToCase : Exception thrown when JDE Attachment was copying to Case with matching SO ' + e;
            System.debug('CopyJDEAttachmentToCase : '+errorMsg);
            returnValues.apexOutput='Failed'; 
            returnValues.apexError=e.getMessage();
            results.add(returnValues);
            return results;
        }
        return results;
    }
    public class flowOutputs{
    @InvocableVariable public String apexOutput;
    @InvocableVariable public String apexError;
  
  }
}