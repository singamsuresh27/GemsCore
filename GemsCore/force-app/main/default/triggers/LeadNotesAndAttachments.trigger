/*
###########################################################################
# File..................: <<Trigger - LeadNotesAndAttachments >>
# Version...............: <<1.0>>
# Created by............: <<Siddharth Jain>>
# Created Date..........: <<20-Oct-2010>>
# Last Modified by......: <<Siddharth Jain>>
# Last Modified Date....: <<20-Oct-2010>>
# Description...........: <<Trigger to assign Notes and Attachment to project only if a lead is converted
#                           and also populate the Lead Creator field on Opportunity. If the no new project    
#                           is created then keep the notes attached to Accounts only >>
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

trigger LeadNotesAndAttachments on Lead (after update) 
{
    List<Lead> lstConvertedLeads = new List<Lead>();
    
    //Build the list of converted leads
    for (Lead l : Trigger.new)
    {
        if(l.IsConverted)
        {
            lstConvertedLeads.add(l);       
        }
    }
    
    //Pass the control to Apex class that does the processing for Notes and Attachments
    if (!lstConvertedLeads.isEmpty())
    {
        LeadsNotesAndAttachments lna = new LeadsNotesAndAttachments();
        lna.LinkNotesAndAttachments(lstConvertedLeads);
    }
}