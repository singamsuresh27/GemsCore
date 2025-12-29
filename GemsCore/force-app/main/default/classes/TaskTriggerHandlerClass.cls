public class TaskTriggerHandlerClass{
    public static boolean runME = true;

    List<String> stageList = new List<String>();
    
    public Opportunity updateOppStage(Opportunity opp){
        
        List<SelectOption> stageOptions = StageValue();
        for(SelectOption so : stageOptions){
            
            stageList.add(so.getValue());
        }
        
        System.debug('-------> '+opp.StageName);
        
        for(Integer i=0;i<stageList.size();i++){
            System.debug('-------> '+stageList.get(i));
            if(stageList.get(i) == opp.StageName){
                opp.StageName = stageList.get(i+1);
                
                break;
            }
        }  
        System.debug('-------> '+opp.StageName);
        
        return opp;   
    }
    
    public list<SelectOption> StageValue(){
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('Stage 1 - Qualified','Stage 1 - Qualified'));
        options.add(new SelectOption('Stage 2 - Needs Identified & Accepted','Stage 2 - Needs Identified & Accepted'));
        options.add(new SelectOption('Stage 3 - Solution Presented & Accepted','Stage 3 - Solution Presented & Accepted'));
        options.add(new SelectOption('Stage 4 - Specific Price / Budget','Stage 4 - Specific Price / Budget'));
        options.add(new SelectOption('Stage 5 - Order Placement','Stage 5 - Order Placement'));
        options.add(new SelectOption('Closed Won','Closed Won'));
        options.add(new SelectOption('Closed Lost','Closed Lost'));
        
        return options;
    }
    
    
}