/*
###########################################################################
# File..................: <<Trigger - OpportunityPPGCategory >>
# Version...............: <<1.0>>
# Created by............: <<Siddharth Jain>>
# Created Date..........: <<22-Oct-2010>>
# Last Modified by......: <<Siddharth Jain>>
# Last Modified Date....: <<22-Oct-2010>>
# Description...........: <<Trigger to assign PPG Category on Opportunity based on PCM Score
#                           and this PCM score governed by total of picklist fields using formulas >>
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

trigger OpportunityPPGCategory on Opportunity (before insert, before update) 
{
    for (Opportunity opp : Trigger.New)
    {
        Double dblPCMScore = 0;
        
        //Department Cost
        if (opp.PCM_Q1__c == 'Prototypes Only')
            dblPCMScore = dblPCMScore + 1;
        else             if (opp.PCM_Q1__c == 'Prototypes & internal or external test or approval')
            dblPCMScore = dblPCMScore + 3;
        else           if (opp.PCM_Q1__c == 'Prototypes, reliabilty testing and agency approvals')
            dblPCMScore = dblPCMScore + 9;

        //Eng. Dev. Houes   
        if (opp.PCM_Q2__c == '0 – 40 ($4000 NRE)')
            dblPCMScore = dblPCMScore + 1;
        else             if (opp.PCM_Q2__c == '40- 240 ($24,000 NRE)')
            dblPCMScore = dblPCMScore + 3;
        else             if (opp.PCM_Q2__c == '240+ ($50,000 NRE)')
            dblPCMScore = dblPCMScore + 9;

        //Overall Complexity
        if (opp.PCM_Q3__c == 'Component only & core competency')
            dblPCMScore = dblPCMScore + 1;
        else             if (opp.PCM_Q3__c == 'Component or system; General expertise or technology in house')
            dblPCMScore = dblPCMScore + 3;
        else             if (opp.PCM_Q3__c == 'Full system; limited or no expertise or technology in house')
            dblPCMScore = dblPCMScore + 9;

        //Floor Space Req.  
        if (opp.PCM_Q4__c == 'Existing cell')
            dblPCMScore = dblPCMScore + 1;
        else             if (opp.PCM_Q4__c == 'New Cell / Cell expansion or modification')
            dblPCMScore = dblPCMScore + 3;
        else            if (opp.PCM_Q4__c == 'New Value stream to New building')
            dblPCMScore = dblPCMScore + 9;

        //Start-Up Cost
        if (opp.PCM_Q5__c == '$0 - $1000 Fixtures & Gauges Off the shelf or existing')
            dblPCMScore = dblPCMScore + 1;
        else            if (opp.PCM_Q5__c == '$0 - $20,000 Simple tooling (plastic mold) New Fixtures/Gages')
            dblPCMScore = dblPCMScore + 3;
        else             if (opp.PCM_Q5__c == '$20,000 + (Significant capital investment)')
            dblPCMScore = dblPCMScore + 9;

        //Materials
        if (opp.PCM_Q6__c == 'Current part, consistent usage')
            dblPCMScore = dblPCMScore + 1;
        else             if (opp.PCM_Q6__c == 'New part, must have consistent usage, medium volume')
            dblPCMScore = dblPCMScore + 3;
        else if (opp.PCM_Q6__c == 'New part, inconsistent usage, low volume')
            dblPCMScore = dblPCMScore + 9;

        //Sourcing
        if (opp.PCM_Q7__c == 'Current suppliers, standard lead-times')
            dblPCMScore = dblPCMScore + 1;
        else            if (opp.PCM_Q7__c == 'One new supplier, long lead-time, complex BOM')
            dblPCMScore = dblPCMScore + 3;
        else if (opp.PCM_Q7__c == 'Find and qualify new suppliers, new to Gems parts')
            dblPCMScore = dblPCMScore + 9;

        //Quality
        if (opp.PCM_Q8__c == 'Existing Quality System')
            dblPCMScore = dblPCMScore + 1;
        else             if (opp.PCM_Q8__c == 'DFMEA, PFMEA and Control Plan Req\'d')
            dblPCMScore = dblPCMScore + 3;
        else             if (opp.PCM_Q8__c == 'DFMEA, PFMEA, Control Plan and PPAP Req\'d or ISO13485 req\'ts')
            dblPCMScore = dblPCMScore + 9;

        //Functions Required
        if (opp.PCM_Q9__c == 'Sales, Eng, Purch')
            dblPCMScore = dblPCMScore + 1;
        else            if (opp.PCM_Q9__c == 'Sales, Eng, Mfg Eng, Purch, Supply Chain, Quality')
            dblPCMScore = dblPCMScore + 3;
        else            if (opp.PCM_Q9__c == 'Mktg., Sales, Eng, Mfg Eng, Purch, Supply Chain, Quality')
            dblPCMScore = dblPCMScore + 9;

        //Skill sets available  
        if (opp.PCM_Q10__c == 'All')
            dblPCMScore = dblPCMScore + 1;
        else             if (opp.PCM_Q10__c == 'Need to bring in one outside skill')
            dblPCMScore = dblPCMScore + 3;
        else             if (opp.PCM_Q10__c == 'Need to bring in two outside skills')
            dblPCMScore = dblPCMScore + 9;

        //Total Project Gestation   
        if (opp.PCM_Q11__c == '24+ weeks')
            dblPCMScore = dblPCMScore + 1;
        else            if (opp.PCM_Q11__c == '8 – 24 weeks')
            dblPCMScore = dblPCMScore + 3;
        else             if (opp.PCM_Q11__c == '0 – 8 weeks')
            dblPCMScore = dblPCMScore + 9;
        
        //Depending upon the PCM Score calculated set the PPG Category and PCM Score field  
        opp.PCM_Score__c = dblPCMScore;
        if ((dblPCMScore >= 10) && (dblPCMScore <= 14)) 
            opp.PPG_Category__c = 'C';
        else            if ((dblPCMScore >= 15) && (dblPCMScore <= 48)) 
            opp.PPG_Category__c = 'B';
        else            if ((dblPCMScore >= 49) && (dblPCMScore <= 59)) 
            opp.PPG_Category__c = 'Consult To PPG';
        else             if ((dblPCMScore >= 60) && (dblPCMScore <= 99)) 
            opp.PPG_Category__c = 'A';
        else   
            opp.PPG_Category__c = '';
    }
}