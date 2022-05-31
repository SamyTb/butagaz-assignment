public with sharing class VFC07_MarketingTarget {
	// **********************
    // ATTRIBUTES 
    // **********************

    /* The Campaign we're working with */
    public  Campaign      oCamp {get;set;} 

    /* Lists of Accounts */
	public list<SearchAccount>  lSearchAccount  {get;set;} //  Account returned by the search
   
    /* Search and display the objects */    
    private String  searchText; // The search test entered by the User
    private AP_Query_01.QuerySet       currentQuery;

    // **********************
    // CONSTRUCTOR
    // **********************
    public VFC07_MarketingTarget(ApexPages.standardcontroller stdController){

        System.debug('[VFC07_MarketingTarget.Constructor] Constructing.');

        // Initialize constants
		oCamp=(Campaign)stdController.getRecord();

        System.debug('[VFC07_MarketingTarget.Constructor] Done Constructing.');
    }
    
    /* ACTION METHODS */

    public void setSearchText(String searchText){
        this.searchText = String.escapeSingleQuotes(searchText);
    }

    public String getSearchText(){
        return this.searchText;
    }

    public PageReference saveForm(){
       return null;
    }

    public void search(){
        List<String> queryFields = new List<String>{
            'Id',                   'Name'
        };
        List<AP_Query_01.QuerySetClause> queryFilters = new List<AP_Query_01.QuerySetClause>();

        if (!(searchText == '' || searchText == null)){
            queryFilters.add(new AP_Query_01.QuerySetLikeClause('Name', searchText));
        }

        this.currentQuery = new AP_Query_01.QuerySet('Account', queryFields, queryFilters);
       
       	lSearchAccount=new List<SearchAccount>();
        for(SObject oSO: this.currentQuery.getRecords(1000,0)){
        	lSearchAccount.add(new SearchAccount((Account)oSo,this));
        } 
    }
    
    public class SearchAccount {
        public  Account          oAccount {get;set;}
        public  Boolean          selected {get;set;}
		public	VFC07_MarketingTarget parentObject {get;set;}
		
        public SearchAccount(Account oAccount, VFC07_MarketingTarget parentObject){
            // instantiate a SearchAccount 
            this.parentObject = parentObject;
            this.selected=false;
            this.oAccount=oAccount;
        }
    }   
    // Can't remove because of bug
    private class ProductQuerySet{}

}