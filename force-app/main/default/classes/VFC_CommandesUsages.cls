public class VFC_CommandesUsages{
    // ************
    // Attributes
    // ************ 
    public CUSAGE__c oCUSAGE {get;set;}
    ApexPages.StandardController oControl;  
    public string sMode {get;set;}// Page mode : New, Edit
    public Account oAccount {get;set;}// Link to the Account
    public boolean bIssue {get;set;}// Manage issues
    public List<Item__c> lUsages {get;set;}//Articles of type Usages    
    public List<CUSAGE_Article__c> lCUSAGEArticles {get;set;}//CUSAGE Articles 
    public transient Savepoint sp; //Database Savepoint

    
    // ************
    // CONTROLLER
    // ************ 
    public VFC_CommandesUsages(ApexPages.StandardController oControl_in){
        this.oControl=oControl_in;        
        
        // Recover page mode
        oCUSAGE=(CUSAGE__c)oControl.getRecord();
        sMode=(oCUSAGE.Id==null?'New':'Edit');                
        
       
        // "New button" from the Commandes Usages tab
        if(oCUSAGE.Account__c == null){
            bIssue=true;
            ApexPages.AddMessage(new ApexPages.message(ApexPages.Severity.INFO,System.Label.CUsages_creation_issue));
        }
        else{   
            bIssue=false;                   
                
            //Recover Account information
            oAccount=[select id ,Name,blockade_Status__c, Channel__c, ExternalId__c,AccountNumber from Account where id=:oCUSAGE.Account__c];
                                     
            //Recover CUSAGE Day
            if(sMode=='New') oCUSAGE.Date_de_Commande__c = date.today();
            
            // Recover CUSAGE Articles
            lCUSAGEArticles = new List<CUSAGE_Article__c>();            
            getCUSAGEArticles();
        }       
    }     
    
    // Recover CUSAGE Articles
    public void getCUSAGEArticles(){

        if(sMode=='New') {      
            //Recover all the articles of type  
            lUsages = [SELECT id, Name,Type__c ,Gencode__c,Recommended_Price__c, Ordre_de_tri__c, ExternalID__c FROM Item__c WHERE Type__c='Usages' or Type__c='Services Usages' ORDER BY Ordre_de_tri__c];
            
            // Create CUSAGE Articles for all the articles       
            for(Item__c oArticle:lUsages){  
                lCUSAGEArticles.add(new CUSAGE_Article__c(CUSAGES__c=oCUSAGE.Id,Article__c=oArticle.Id, Article__r=oArticle,Prix_unitaire__c=oArticle.Recommended_Price__c));
            }
        }
        else {
            // Recover all "CUSAGE Articles" of the CUSAGE        
            for(CUSAGE_Article__c oCUSAGEArticle:[select id, Article__c, Article__r.Name,Article__r.Type__c,Gencode__c, Article__r.Gencode__c, Article__r.Recommended_Price__c, Article__r.Ordre_de_tri__c, Article__r.ExternalID__c,Quantite__c, Prix_unitaire__c, Total_Article__c from CUSAGE_Article__c where CUSAGES__c=:oCUSAGE.id ORDER By Article__r.Ordre_de_tri__c]){
                lCUSAGEArticles.add(oCUSAGEArticle);               
            }
        }  
    }

    public void calcCost(){
        
        oCUSAGE.Total_Quantite__c = 0;
        oCUSAGE.Total_Prix__c = 0;       
                
        for(CUSAGE_Article__c oCUSAGEArticle: lCUSAGEArticles){             
            //Total 
            if( (oCUSAGEArticle.Quantite__c != null) && (oCUSAGEArticle.Prix_unitaire__c != null) ) {
                oCUSAGEArticle.Total_Article__c= oCUSAGEArticle.Quantite__c * oCUSAGEArticle.Prix_unitaire__c;
                oCUSAGE.Total_Quantite__c += oCUSAGEArticle.Quantite__c;
                oCUSAGE.Total_Prix__c += oCUSAGEArticle.Total_Article__c;
            } 
            if( (oCUSAGEArticle.Prix_unitaire__c != null) && (oCUSAGEArticle.Article__r.Type__c == 'Services Usages')) {
                oCUSAGEArticle.Total_Article__c = oCUSAGEArticle.Prix_unitaire__c;
                oCUSAGE.Total_Prix__c += oCUSAGEArticle.Total_Article__c;
            }
        }
    }   
    
    
    // ****************  
    // Save information
    // ****************
    public pageReference saveBtn(){     
    
        list<CUSAGE_Article__c> lCUSAGEArticlessToUpsert = new list<CUSAGE_Article__c>();//CUSAGE Articles to be upserted           
        calcCost();
        // Define a save point
        sp = Database.setSavepoint();
        CUSAGE__c oNewCUSAGE;
        
        try{
               
            //upsert New CUSAGE;
            oNewCUSAGE =oCUSAGE.clone(true);
            upsert oNewCUSAGE;       
                
            // Upsert CUSAGE Articles       
            for(CUSAGE_Article__c oCUSAGEArticle: lCUSAGEArticles){  
                CUSAGE_Article__c oNewCUSAGEArticle = oCUSAGEArticle.clone(true);
                if(sMode=='New') {
                    oNewCUSAGEArticle.CUSAGES__c= oNewCUSAGE.id;
                }
                lCUSAGEArticlessToUpsert.add(oNewCUSAGEArticle);
            }       
            if(lCUSAGEArticlessToUpsert.size()>0){
                upsert lCUSAGEArticlessToUpsert;
            } 
        } 
        catch(DmlException ex){
            
            Database.rollback(sp);
            ApexPages.addMessages(ex);            
            return null;
        }   
        return new PageReference('/' + oNewCUSAGE.id); 
    }       
    
    
    public String getTodayDate() {

        return date.today().format();

    } 

    //Get articles of type "Casiers" that are installed
    public List<CUSAGE_Article__c>  getListUsagesInstalles(){
        List<CUSAGE_Article__c> listUsagesInstalles = new List<CUSAGE_Article__c>();
        for (CUSAGE_Article__c Usage:lCUSAGEArticles) {
            if((Usage.Quantite__c != null && Usage.Quantite__c !=0)) {            
                listUsagesInstalles.add(Usage);
            }
            if(Usage.Article__r.Type__c=='Services Usages') {
                listUsagesInstalles.add(Usage);
            }
        }
        return listUsagesInstalles;
    }      
}