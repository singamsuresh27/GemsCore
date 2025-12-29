trigger PIM_AI_score on NBO_Forms__c (before insert, before update) {
     for (NBO_Forms__c nbo : Trigger.New)
    {
         Double dblPIMScore = 0;
         Double dblAFScore = 0;
         String sdrCardColor;
         //Department Cost
         if (nbo.PIM_Q1__c == 'Prototypes only')
             dblPIMScore = dblPIMScore + 1;
         else if (nbo.PIM_Q1__c == 'Prototypes with internal OR external testing, OR Agency Approval')
             dblPIMScore = dblPIMScore + 3;
         else if (nbo.PIM_Q1__c == 'Prototypes, reliabilty testing and Agency approvals, etc.'){
             dblPIMScore = dblPIMScore + 9; 
             //sdrCardColor = 'Red';   
             }     
         //Eng. Dev. Houes   
         if (nbo.PIM_Q2__c == '0 – 40 ($4000 NRE)')
             dblPIMScore = dblPIMScore + 1;
         else if (nbo.PIM_Q2__c == '40- 240 ($24,000 NRE)')
             dblPIMScore = dblPIMScore + 3;
         else if (nbo.PIM_Q2__c == '240+ ($50,000 NRE)'){
             dblPIMScore = dblPIMScore + 9;
             //sdrCardColor = 'Red'; 
             }         
        //Overall Complexity
        if (nbo.PIM_Q3__c == 'Component only & core competency')
            dblPIMScore = dblPIMScore + 1;
        else if (nbo.PIM_Q3__c == 'Special assy or simple system, General expertise in house')
            dblPIMScore = dblPIMScore + 3;
        else if (nbo.PIM_Q3__c == 'Complex system or assembly, requires dedicated development'){
            dblPIMScore = dblPIMScore + 9;
            sdrCardColor = 'Red';}
        //Skill sets available
        if (nbo.PIM_Q10__c == 'All')
            dblPIMScore = dblPIMScore + 1;
        else if (nbo.PIM_Q10__c == 'Need to lean new skill or apply new technology')
            dblPIMScore = dblPIMScore + 3;
        else if (nbo.PIM_Q10__c == 'Must contract or hire SME'){
            dblPIMScore = dblPIMScore + 9; 
            sdrCardColor = 'Red';}      
        //Floor Space Req.  
        if (nbo.PIM_Q4__c == 'Existing cell with addition of fixtures or jigs')
            dblPIMScore = dblPIMScore + 1;
        else if (nbo.PIM_Q4__c == 'Existing cell but modification within existing footprint')
            dblPIMScore = dblPIMScore + 3;
        else if (nbo.PIM_Q4__c == 'Expand existing cell or requires new cell'){
            dblPIMScore = dblPIMScore + 9;
            //sdrCardColor = 'Red';
            }
        //Start-Up Cost
        if (nbo.PIM_Q5__c == '$0 - $2500 Fixtures & Gauges Off the shelf or existing')
            dblPIMScore = dblPIMScore + 1;
        else if (nbo.PIM_Q5__c == '$5K - $20K i.e. Simple tooling (plastic mold) New Fixtures/Gages')
            dblPIMScore = dblPIMScore + 3;
        else if (nbo.PIM_Q5__c == '> $20K (Significant capital investment)'){
            dblPIMScore = dblPIMScore + 9;
            sdrCardColor = 'Red';}
        //Materials
        if (nbo.PIM_Q6__c == 'New or similar off the shelf part, readily available')
            dblPIMScore = dblPIMScore + 1;
        else if (nbo.PIM_Q6__c == 'New typical part or existing part where buying habits need to change due to required volume')
            dblPIMScore = dblPIMScore + 3;
        else if (nbo.PIM_Q6__c == 'Difficult part to procure at requested volume or lead time'){
            dblPIMScore = dblPIMScore + 9;
            //sdrCardColor = 'Red';
            }
        //Sourcing
        if (nbo.PIM_Q7__c == 'Existing supplier has expertise and can deliver in requested lead time')
            dblPIMScore = dblPIMScore + 1;
        else if (nbo.PIM_Q7__c == 'Existing supplier requires extended lead time to develop  new part')
            dblPIMScore = dblPIMScore + 3;
        else if (nbo.PIM_Q7__c == 'Qualify new or existing supplier on challenging new components, requires tooling and long lead time'){
            dblPIMScore = dblPIMScore + 9;
            sdrCardColor = 'Red';}
        //Quality
        if (nbo.PIM_Q8__c == 'Existing Quality System')
            dblPIMScore = dblPIMScore + 1;
        else if (nbo.PIM_Q8__c == 'DFMEA, PFMEA and Control Plan Req\'d')
            dblPIMScore = dblPIMScore + 3;
        else if (nbo.PIM_Q8__c == 'DFMEA, PFMEA, Control Plan and PPAP Req\'d or ISO13485 req\'ts'){
            dblPIMScore = dblPIMScore + 9; 
            //sdrCardColor = 'Red';
            }                      
        //Assembly complexity
        if (nbo.PIM_Q9__c == 'Current processes and people')
            dblPIMScore = dblPIMScore + 1;
        else if (nbo.PIM_Q9__c == 'New processes and current people')
            dblPIMScore = dblPIMScore + 3;
        else if (nbo.PIM_Q9__c == 'New processes and special training'){
            dblPIMScore = dblPIMScore + 9;
            //sdrCardColor = 'Red';
            }
        //set total PIM score
        //if ((dblPCMScore >= 10) && (dblPCMScore <= 14)) 
            //opp.PPG_Category__c = 'C';
        //else if ((dblPCMScore >= 15) && (dblPCMScore <= 48)) 
            //opp.PPG_Category__c = 'B';
        //else if ((dblPCMScore >= 49) && (dblPCMScore <= 59)) 
            //opp.PPG_Category__c = 'Consult To PPG';
        //else if ((dblPCMScore >= 60) && (dblPCMScore <= 99)) 
            //opp.PPG_Category__c = 'A';
        //else    
            //opp.PPG_Category__c = '';
        if ( (sdrCardColor <> 'Red') && (dblPIMScore >=10) && (dblPIMScore <= 15))
            sdrCardColor = 'Green';
        else if ( (sdrCardColor <> 'Red') && (dblPIMScore >=16) && (dblPIMScore <= 20))
            sdrCardColor = 'Yellow';
        else if ( (sdrCardColor == 'Red') || ( (dblPIMScore >= 21) && (dblPIMScore <= 90) ) )
        //else if ( (dblPIMScore >= 21) && (dblPIMScore <= 90) )
            sdrCardColor = 'Red';
        else    
            sdrCardColor = '';
        
        nbo.PIM_Score__c = dblPIMScore;  
        nbo.SDR_Color__c = sdrCardColor;
        
        //Attractiveness factor  
        //Probability of win
        if (nbo.AF_Q1__c == '0-50%')
            dblAFScore = dblAFScore + 1;
        else if (nbo.AF_Q1__c == '60 -80%')
            dblAFScore = dblAFScore + 2;
        else if (nbo.AF_Q1__c == '>80%')
            dblAFScore = dblAFScore + 3;        
        //Customer development cycle
        if (nbo.AF_Q2__c == '24+')
            dblAFScore = dblAFScore + 1;
        else if (nbo.AF_Q2__c == '8 – 24 weeks')
            dblAFScore = dblAFScore + 2;
        else if (nbo.AF_Q2__c == '0 – 8 weeks')
            dblAFScore = dblAFScore + 3;  
        // Customer Participation    
        if (nbo.AF_Q3__c == 'None')
            dblAFScore = dblAFScore + 1;
        else if (nbo.AF_Q3__c == 'Partial')
            dblAFScore = dblAFScore + 2;
        else if (nbo.AF_Q3__c == 'All')
            dblAFScore = dblAFScore + 3;
        //Competitive situation
        if (nbo.AF_Q4__c == 'Entrenched  Competitor')
            dblAFScore = dblAFScore + 1;
        else if (nbo.AF_Q4__c == 'Competitor at Parity')
            dblAFScore = dblAFScore + 2;
        else if (nbo.AF_Q4__c == 'Weak Competitor')
            dblAFScore = dblAFScore + 3;
        //Customer motivation
        if (nbo.AF_Q5__c == 'PPV')
            dblAFScore = dblAFScore + 1;
        else if (nbo.AF_Q5__c == 'New platform')
            dblAFScore = dblAFScore + 2;
        else if (nbo.AF_Q5__c == 'Problem with current supplier')
            dblAFScore = dblAFScore + 3;
        //Customer type
        if (nbo.AF_Q6__c == 'New')
            dblAFScore = dblAFScore + 1;
        else if (nbo.AF_Q6__c == 'Existing')
            dblAFScore = dblAFScore + 2;
        else if (nbo.AF_Q6__c == 'Top tier')
            dblAFScore = dblAFScore + 3;
        //total AF score
        nbo.AF_Score__c = dblAFScore/6;
    }
}