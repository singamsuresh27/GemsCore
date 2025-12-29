global class ScheduledOpporJob  implements Schedulable{
      
	  global void execute(SchedulableContext sc) {
      Opportunityjob b = new Opportunityjob();
      database.executebatch(b);
   }

}