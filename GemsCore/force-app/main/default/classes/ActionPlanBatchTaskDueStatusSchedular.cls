/*
###########################################################################
# File..................: <<Trigger - autoFollowOpportunity >>
# Version...............: <<2.0>>
# Created by............: <<Gazi Ahmed>>
# Created Date..........: <<22-Oct-2013>>
# Last Modified by......: <<Gazi Ahmed>>
# Last Modified Date....: <<02-Jan-2014>>
# Description...........: <<This job will check the box if a action plan task is due in a week
#                           >>
# Change Log............: << 
#                             >>                        
#
# Copyright (c) 2000-2010. Danaher, All Rights Reserved.
#
# Created by the Danaher. Modification must retain the above copyright notice.
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any commercial purpose, without fee, and without a written
# agreement from Gems Sensors and Control, is hereby forbidden. Any modification to source
# code, must include this paragraph and copyright.
#
# Permission is not granted to anyone to use this software for commercial uses.
#
# Contact address: Gems Sensors and Controls, 1 Cowles Rd., Plainville, CT USA 06062
# Company URL : http://www.gemssensors.com
###########################################################################
*/ 
global with sharing class ActionPlanBatchTaskDueStatusSchedular implements Schedulable{	
	
	//global void execute(SchedulableContext sc) {       
        //ID BatchId = Database.executeBatch(new ActionPlanBatchTaskDueStatusUpdate(), 200);
	//}
    //Public static void SchedulerMethod() {
  		//string timeinterval = '0 20 * * * ?';
  		//System.schedule('BatActionPlan-Every10mins',timeinterval, new ActionPlanBatchTaskDueStatusSchedular());
  	//}
  	
	global void execute(SchedulableContext c)
    {   
        ActionPlanBatchTaskDueStatusUpdate uab = new ActionPlanBatchTaskDueStatusUpdate();
        Database.executeBatch(uab);                 
    }	
}