/*
###########################################################################
# File..................: <<Trigger - LeadForDistributors >>
# Version...............: <<1.0>>
# Created by............: <<Siddharth Jain>>
# Created Date..........: <<21-Oct-2010>>
# Last Modified by......: <<Siddharth Jain>>
# Last Modified Date....: <<21-Oct-2010>>
# Description...........: <<Trigger to assign Lead owner as Distibutor Owner, if "Lead Status = Disqualified"
#                           "Reason = Sent To Distibutor" and Selected Account is a Distibutor account >>
# Change Log............: << >>  
#                           
#
# Copyright (c) 2000-2010. Astadia, Inc. All Rights Reserved.
#
# Created by the Astadia, Inc. Modification must retain the above copyright notice.
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any commercial purpose, without fee, and without a written
# agreement from Astadia, Inc., is hereby forbidden. Any modification to source
# code, must include this paragraph and copyright.
#
# Permission is not granted to anyone to use this software for commercial uses.
#
# Contact address: 2839 Paces Ferry Road, Suite 350, Atlanta, GA 30339
# Company URL : http://www.astadia.com
###########################################################################
*/

trigger LeadForDistributors on Lead (after insert, after update) 
{
    List<ID> lstLeadIds = new List<ID>();
    List<Lead> lstLeads = new List<Lead>();
    
    //Build the list of converted leads
    for (Lead l : Trigger.new)
    {
        //if(l.Status == 'Disqualified' && l.Reason__c == 'Sent To Distributor' && l.Is_Distributor_Account__c == 'true' && l.Lead_Distributer_Owner_Synced__c == false)
        if(l.Status == 'Disqualified' && l.Reason__c == 'Sent To Distributor' && l.Is_Distributor_Account__c == 'true') 
        {
            lstLeadIds.add(l.Id);
        }
    }
       
    if (!lstLeadIds.isEmpty())
    {
        List<Lead> lstNewLeads = [Select id,OwnerId, Account__r.OwnerId, Account__r.Email_Address__c from Lead where Id in : lstLeadIds];
        if (!lstNewLeads.isEmpty())
        {
            for (Lead l : lstNewLeads)
            {
                if(l.OwnerId!=l.Account__r.OwnerId){
                Lead ld = new Lead(Id = l.Id);
                ld.OwnerId = l.Account__r.OwnerId;
                //ld.Lead_Distributer_Owner_Synced__c = true;
                ld.Distributor_Email__c = l.Account__r.Email_Address__c;
                lstLeads.add(ld);
                }
            }
            
            if (!lstLeads.isEmpty())
                update lstLeads;
        }
    }
}