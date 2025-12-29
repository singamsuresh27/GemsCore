/**
* @File Name        :   ConexiomEmailMessageTrigger
* @Description      :   Trigger on email message object to update case status if it's sent to conexiom or Eskar
* @TestClass        :   TestEmailConexiom
* -------------------------------------------------------------------------------------
**/

trigger ConexiomEmailMessageTrigger on EmailMessage (after insert) {
    try
    {
        for(EmailMessage emailMsg:Trigger.new){
            if(emailMsg.Incoming == false && emailMsg.ToAddress != null && (emailMsg.ToAddress.contains('conexiom.net') ||emailMsg.ToAddress.contains('process.esker.net')))
                CaseHandlerClass.updateConexiomCaseStatus(Trigger.new);
        }
    }
    catch(Exception ex)
    {
        system.debug(' ConexiomEmailMessageTrigger Exception : '+ ex.getMessage());
    }
}