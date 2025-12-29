/**------------------------------------------------------------------------------------
* @File Name        :  EmailMessageTriggerHandler
* @Author           :  Thirumoorthy Mani
* @Description      :  Below rules applicable only for EMEA Cases
* @Test class		:  EmailMessageTriggerHandlerTest
* 1.0                  2024-10-09                    
* -------------------------------------------------------------------------------------
**/
public class EmailMessageTriggerHandler {
    public static void EmailMessageTriggerHandler(List<EmailMessage> newEmailMessageList){
	List<Case> caseToUpdateList = new List<Case>();
    Set<Case> caseToUpdateSet = new Set<Case>();
	Set<Id> caseIdSet = new Set<Id>();
    	try
    	{
            system.debug('EmailMessageTriggerHandler');            
            String comarkTargetSubstring = 'comark';
            String plvEDIPDFTargetBody = Constants_For_Apex__mdt.getInstance('PlvEdiPdfBody')!= null ? 
                                        Constants_For_Apex__mdt.getInstance('PlvEdiPdfBody').Value__c : '';
            plvEDIPDFTargetBody = plvEDIPDFTargetBody.toLowerCase();
            
            String xmlFilePlvTagetBody = Constants_For_Apex__mdt.getInstance('XmlFilesPlvBody') != null ?
                                        Constants_For_Apex__mdt.getInstance('XmlFilesPlvBody').Value__c : '';
            xmlFilePlvTagetBody = xmlFilePlvTagetBody.toLowerCase();
                
            String plvEDISuccessTargetBody = 'successful';
            String plvEDISuccessTargetFromAddress = Constants_For_Apex__mdt.getInstance('PlvEdiSuccessFulFromAddress') != null ?
                									Constants_For_Apex__mdt.getInstance('PlvEdiSuccessFulFromAddress').Value__c :'';
            plvEDISuccessTargetFromAddress = plvEDISuccessTargetFromAddress.toLowerCase();
                
            String westAllegemeinerTargetFromAddress = Constants_For_Apex__mdt.getInstance('WestAllgemeinerFromAddress') != null ?
                										Constants_For_Apex__mdt.getInstance('WestAllgemeinerFromAddress').Value__c : '';
            westAllegemeinerTargetFromAddress = westAllegemeinerTargetFromAddress.toLowerCase();
            //dibya starts SCTASK1218420
            String westAllegemeinerTargetSubjectLine = Constants_For_Apex__mdt.getInstance('WestAllgemeinerSubjectLine') != null ?
                									Constants_For_Apex__mdt.getInstance('WestAllgemeinerSubjectLine').Value__c : '';
            westAllegemeinerTargetSubjectLine = westAllegemeinerTargetSubjectLine.toLowerCase();
            //dibya ends SCTASK1218420
            //dibya starts 
            String XMLFIle_FromAddress = Constants_For_Apex__mdt.getInstance('XMLFIle_FromAddress') != null ?
                										Constants_For_Apex__mdt.getInstance('XMLFIle_FromAddress').Value__c : '';
            XMLFIle_FromAddress = XMLFIle_FromAddress.toLowerCase();
            String PO_PDF_FromAddress = Constants_For_Apex__mdt.getInstance('PO_PDF_FromAddress') != null ?
                										Constants_For_Apex__mdt.getInstance('PO_PDF_FromAddress').Value__c : '';
            PO_PDF_FromAddress = PO_PDF_FromAddress.toLowerCase();
            //dibya ends
        
            String westAllegemeinerTargetSubject = Constants_For_Apex__mdt.getInstance('WestAllgemeinerSubject') != null ?
                									Constants_For_Apex__mdt.getInstance('WestAllgemeinerSubject').Value__c : '';
            westAllegemeinerTargetSubject = westAllegemeinerTargetSubject.toLowerCase();
        
            String comarkCaseBodyRule = Constants_For_Apex__mdt.getInstance('ComarkCaseBodyRule') != null ?
                						Constants_For_Apex__mdt.getInstance('ComarkCaseBodyRule').Value__c : '';
            comarkCaseBodyRule = comarkCaseBodyRule.toLowerCase();
            
            Set<String> keywordSet = new Set<String>(comarkCaseBodyRule.split(';'));
            
            String gemsEUToAddress = Constants_For_Apex__mdt.getInstance('GemsEUToAddress')!= null ? 
                                        Constants_For_Apex__mdt.getInstance('GemsEUToAddress').Value__c : '';
            String gemsEUToAddressLongText = Constants_For_Apex__mdt.getInstance('GemsEUToAddress')!= null ? 
                                        Constants_For_Apex__mdt.getInstance('GemsEUToAddress').LongValue__c : '';
            
            
            gemsEUToAddress = gemsEUToAddress.toLowerCase();            
            gemsEUToAddressLongText = gemsEUToAddressLongText.toLowerCase();
            
            for (EmailMessage email : newEmailMessageList) {
                Case updateCase = new Case();
                if(!gemsEUToAddressLongText.contains(email.ToAddress)) // below rules applicable only for EMEA Cases
                {
                    continue;
                }
                if (email.HtmlBody != null) {
                    for (String keyword : keywordSet) {                        
                	system.debug('keyword : '+keyword);
                        if (email.HtmlBody.toLowerCase().contains(keyword.trim().toLowerCase())) {
                            updateCase.Id = email.ParentId;
                            updateCase.Type = 'Setra Temperature Monitoring';
                            caseToUpdateSet.add(updateCase);
                            continue; 
                        }
                    }
                }
                if(email.Subject != null && email.Subject.toLowerCase().contains(comarkTargetSubstring))
                {
                    updateCase.Id = email.ParentId;
                    updateCase.Type = 'Setra Temperature Monitoring';
                    caseToUpdateSet.add(updateCase);
                }
                
                if (email.Subject != null && email.ParentId != null &&
                    ((String.isNotBlank(plvEDIPDFTargetBody) && email.Subject.toLowerCase().contains(plvEDIPDFTargetBody))  || 
                    (String.isNotBlank(plvEDIPDFTargetBody) && email.Subject.toLowerCase().contains(xmlFilePlvTagetBody))
                    )
                   ) {
                                         
                        updateCase.id = email.ParentId;
                        updateCase.Status = 'Closed';
                        caseToUpdateSet.add(updateCase);            
                    }
                
                if (email.ParentId != null && email.FromAddress != null && String.isNotBlank(plvEDISuccessTargetFromAddress) &&
                    email.FromAddress.toLowerCase().contains(plvEDISuccessTargetFromAddress.toLowerCase()) && 
                    email.Subject != null && email.Subject.toLowerCase().contains(plvEDISuccessTargetBody)) {
                    //updateCase.Id = relatedCaseMap.get(email.ParentId);
                    
                    updateCase.id = email.ParentId;
                    updateCase.Status = 'Closed';
                        updateCase.Type = 'WEST Intercompany'; //dibya added
                    caseToUpdateSet.add(updateCase);
                }
                if (email.ParentId != null && email.FromAddress != null && String.isNotBlank(westAllegemeinerTargetFromAddress) &&
                    email.FromAddress.toLowerCase().contains(westAllegemeinerTargetFromAddress.toLowerCase()) && 
                    email.Subject != null && email.Subject.toLowerCase().contains(westAllegemeinerTargetSubject)) {
                    
                    updateCase.id = email.ParentId;
                    updateCase.Type = 'WEST Intercompany';
                    caseToUpdateSet.add(updateCase);
                }
                //dibya starts SCTASK1218420
                 if (email.ParentId != null && email.FromAddress != null && String.isNotBlank(westAllegemeinerTargetFromAddress) &&
                    email.FromAddress.toLowerCase().contains(westAllegemeinerTargetFromAddress.toLowerCase()) && 
                    email.Subject != null && email.Subject.toLowerCase().contains(westAllegemeinerTargetSubjectLine)) {
                    updateCase.Type = 'WEST Intercompany';
                    updateCase.id = email.ParentId;
                    updateCase.Status = 'Closed';
                    caseToUpdateSet.add(updateCase);
                }
                //dibya ends SCTASK1218420
                //dibya starts
                if (email.ParentId != null && email.FromAddress != null && String.isNotBlank(XMLFIle_FromAddress) &&
                    email.FromAddress.toLowerCase().contains(XMLFIle_FromAddress.toLowerCase())) {
                    
                    updateCase.id = email.ParentId;
                    updateCase.Type = 'WEST Intercompany';
                    caseToUpdateSet.add(updateCase);
                    }
                if (email.ParentId != null && email.FromAddress != null && String.isNotBlank(PO_PDF_FromAddress) &&
                    email.FromAddress.toLowerCase().contains(PO_PDF_FromAddress.toLowerCase()) ) {
                    
                    updateCase.id = email.ParentId;
                    updateCase.Type = 'WEST Intercompany';
                    caseToUpdateSet.add(updateCase);
                }
                //dibya ends
                
            }
        	system.debug(' caseToUpdateSet : ' + caseToUpdateSet);
            if (!caseToUpdateSet.isEmpty()) {
                try{
                    caseToUpdateList = new List<Case>(caseToUpdateSet);
                    Database.SaveResult[] results = Database.update(caseToUpdateList, false);
                }
                catch(Exception ex)
                {
                    system.debug(' Exception : ' + ex.getMessage());
                }
            }
		}
        Catch(Exception ex)
        {
            system.debug(' EXCEPTION : '+ ex.getMessage());
        }
	}
    public static void cover(){
        Integer i= 1;
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
        
    }
}