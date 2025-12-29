//public with sharing class OpptyChatter { 
public  class OpptyChatter {  
  public Id OpportunityId{get;set;}
  //public List<OpportunityFeed> LstOppFeed {get; set;}
  public List<FeedItem> LstFeed {get; set;}
  //string sortOptions {get; set;}
  String s = 'Post Date';
  public OpptyChatter(ApexPages.StandardController stdController){
    OpportunityId=ApexPages.currentPage().getParameters().get('RecordId'); 
    //OpportunityId=ApexPages.currentPage().getParameters().get('id');
    //ApexPages.currentPage().getParameters().get('id')]; 
  }

  public List<FeedItem> getOppFeed(){
    LstFeed=[Select f.Id, f.CreatedDate,  f.CreatedBy.FirstName, f.CreatedBy.LastName, f.CreatedBy.Name, f.CreatedById, f.Body, (Select Id, CreatedById, CreatedBy.FirstName, CreatedBy.LastName, CreatedDate, CommentBody From FeedComments ORDER BY CreatedDate) From FeedItem f WHERE f.Type='TextPost' And f.ParentID = : OpportunityId And CreatedDate <= TODAY  ORDER BY CreatedDate DESC LIMIT 100];
    return LstFeed;
  }
  
    public String getSortOptions() {
        return s;
    }
     public void setSortOptions(String s) {
        this.s = s;
    }
    
    public Pagereference back(){
		PageReference MainPage;
        MainPage= new PageReference('/'+OpportunityId);
		MainPage.setRedirect(true);
		return MainPage;
	}      
}