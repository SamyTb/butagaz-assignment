public class VFC_PriseEnCharge01{
    // ************
    // Attributes
    // ************ 
    public PEC__c oPEC {get;set;}
    public PEC__c oLastPEC {get;set;}   
    ApexPages.StandardController oControl;  
    public string sMode {get;set;}// Page mode : New, Edit
    public Account oAccount {get;set;}// Link to the Account
    string sAccountID {get;set;} // Account ID
    string sContactID {get;set;} // Contact ID
    public PTL__c oPTL {get;set;}// Link to the PTL of the account
    public boolean bIssue {get;set;}// Manage issues
    public List<Item__c> lBouteilles {get;set;}//Articles of type Bouteille
    public List<Item__c> lCasiers {get;set;}//Articles of type Casier
    public List<Item__c> lAutresMateriels {get;set;}//Articles of type Autre Materiel
    public List<PEC_Article__c> lPECBouteilles {get;set;}//PEC Articles Bouteilles
    public List<PEC_Article__c> lPECCasiers {get;set;}//PEC Articles Casiers
    public List<PEC_Article__c> lPECAutresMateriels {get;set;}//PEC Articles Autre Materiel 
    public map<Id,Butagaz_Stock_Installed__c> mapButagazStock {get;set;}
    public map<id,PEC_Article__c> mapLastPECStock {get;set;}
    public transient Savepoint sp; //Database Savepoint
    public boolean bValidated {get;set;}// PEC Validated

    public static String isSE{get; set;} // Is the PEC being electronically signed ?
    public static String displayCGUSE{get; set;} // Display electronic signature CGU ?
    public static String withdrawalText{get; set;} // Display withdrawal text in electronic signature component ?
    public static String nbSig{get; set;} // Display withdrawal text in electronic signature component ?
    
    // ************
    // CONTROLLER
    // ************ 
    public VFC_PriseEnCharge01(ApexPages.StandardController oControl_in){
        this.oControl=oControl_in;
        // Recover page mode
        oPEC=(PEC__c)oControl.getRecord();
        sMode=(oPEC.Id==null?'New':'Edit');
        string sFrom =ApexPages.currentPage().getParameters().get('From');
        sAccountID =ApexPages.currentPage().getParameters().get('AccountID');
        sContactID =ApexPages.currentPage().getParameters().get('ContactID');
        bIssue = false;
		bValidated = false;
        isSE = ApexPages.CurrentPage().getParameters().get('isSE');
        if(isSE == null){isSE = 'false';}  // non-electronic signature, constructor called by the VFP, not the button
        displayCGUSE = ApexPages.CurrentPage().getParameters().get('displayCGUSE');
        if(displayCGUSE == null){displayCGUSE = 'false';}  // non-electronic signature, constructor called by the VFP, not the button
        withdrawalText = ApexPages.CurrentPage().getParameters().get('withdrawalText');
        //if(withdrawalText == null){withdrawalText = 'false';}  // non-electronic signature, constructor called by the VFP, not the button
        nbSig = ApexPages.CurrentPage().getParameters().get('nbSig');
        if(nbSig == null){nbSig = '1';}  // non-electronic signature, constructor called by the VFP, not the button
		
		if( (sMode=='Edit') && (oPEC.Status__c != 'Attente de signature' && oPEC.Status__c !=null) ){
			bValidated = true;
			bIssue=true;
            ApexPages.AddMessage(new ApexPages.message(ApexPages.Severity.WARNING,System.Label.PEC_Validated));
		}
   		
        // "New button" from the Quote
        if (sFrom=='Devis')  {
        	if (sAccountID!=null && sAccountID!='') {
        		oPEC.Account__c = sAccountID;
        	}
        	else
        	{
        		bIssue=true;
            	ApexPages.AddMessage(new ApexPages.message(ApexPages.Severity.ERROR,System.Label.PEC_from_Quote_Error));
        	}
        	if (sContactID!=null && sContactID!='') {
        		oPEC.Contact__c = sContactID;
        	}
        	        	
        }       
        
        // "New button" from the Prise En Charge tab
        if(oPEC.Account__c == null){
            bIssue=true;
            ApexPages.AddMessage(new ApexPages.message(ApexPages.Severity.INFO,System.Label.PEC_creation_issue));
        }
        else{                                    
            //Recover Account information
            oAccount=[select id ,Name,blockade_Status__c, Channel__c, ExternalId__c,AccountNumber from Account where id=:oPEC.Account__c];
                
            // Recover PTL information
            oPTL=null;
            list<PTL__c> lPTLs=[select id ,Name, Code_Canal__c, Code_magasin__c,ExternalId__c from PTL__c where Account_DO__c=:oPEC.Account__c];
            if (lPTLs.size() > 0) {
                oPTL=lPTLs.get(0) ;               
            }
            
            // Recover Last PEC and Last PEC Date 
            if(sMode=='New') {
                list<PEC__c> PrevPECS= [SELECT Id,PEC_Date__c FROM PEC__c WHERE Account__c = :oAccount.Id ORDER BY PEC_Date__c DESC LIMIT 1];
                if (PrevPECS.size() > 0) {
                    oPEC.Last_PEC__c=PrevPECS.get(0).id ;
                    oPEC.Last_PEC_Date__c = date.parse(PrevPECS.get(0).PEC_Date__c.date().format());                   
               }
            }          
            else {           	
                list<PEC__c> PrevPECS= [SELECT PEC_Date__c FROM PEC__c WHERE  id= :oPEC.Last_PEC__c];
                if (PrevPECS.size() > 0) {
                    oPEC.Last_PEC_Date__c = date.parse(PrevPECS.get(0).PEC_Date__c.date().format());                
                }
                else {
                    PrevPECS= [SELECT Id,PEC_Date__c FROM PEC__c WHERE Account__c = :oAccount.Id AND PEC_Date__c <: oPEC.PEC_Date__c  ORDER BY PEC_Date__c DESC LIMIT 1];
                    if (PrevPECS.size() > 0) {
                        oPEC.Last_PEC__c=PrevPECS.get(0).id ;
                        oPEC.Last_PEC_Date__c = date.parse(PrevPECS.get(0).PEC_Date__c.date().format());                   
                   }                                
                }
            }
            
            //Recover PEC Day
            if(sMode=='New') oPEC.PEC_Date__c = datetime.now();
            
            // Recover PEC Articles
            lPECBouteilles = new List<PEC_Article__c>();
            lPECCasiers = new List<PEC_Article__c>();
            lPECAutresMateriels = new List<PEC_Article__c>();
            getPECArticles();
        }       
    }    
    
    // Recover PEC Articles
    public void getPECArticles(){
           
        if(sMode=='New') {            
            // Recover "Butagaz Stock Installed" related to the PTL           
            mapButagazStock = new map<Id,Butagaz_Stock_Installed__c>();
            if (oPTL != null) {
                for(Butagaz_Stock_Installed__c oStockInstalled:[select id, Article__c, Stock_pret_materiel__c, Stock_consigne__c, Stock_installe__c from Butagaz_Stock_Installed__c where PTL__c=:oPTL.id]){
                    mapButagazStock.put(oStockInstalled.Article__c, oStockInstalled);
                }    
            }
                        
            // Recover Stock of Last PEC 
            mapLastPECStock = new map<id,PEC_Article__c> ();        
            for(PEC_Article__c LastPECArticle:[select id, Article__c,Stock_PEC_pret__c , Stock_PEC_consigne__c from PEC_Article__c where Prise_en_Charge__c=:oPEC.Last_PEC__c]){
                    mapLastPECStock.put(LastPECArticle.Article__c,LastPECArticle);
            }                          
            
            //Recover all the articles of type Bouteille and Casier 
            lBouteilles = [SELECT id, Name,Type__c, Code_Article__c ,Ordre_de_tri__c, Recommended_Price__c, ExternalID__c FROM Item__c WHERE Type__c='Bouteille' ORDER BY Ordre_de_tri__c];
            lCasiers = [SELECT id, Name,Type__c, Code_Article__c ,Ordre_de_tri__c, Recommended_Price__c, ExternalID__c FROM Item__c WHERE Type__c='Casier' ORDER BY Ordre_de_tri__c];
            lAutresMateriels = [SELECT id, Name,Type__c, Code_Article__c ,Ordre_de_tri__c, Recommended_Price__c, ExternalID__c FROM Item__c WHERE Type__c='Autre Matériel' ORDER BY Ordre_de_tri__c];
            
            // Create PEC Articles
            createPECArticles(lBouteilles,lPECBouteilles);
            createPECArticles(lCasiers,lPECCasiers); 
            createPECArticles(lAutresMateriels,lPECAutresMateriels);
        }
        else {
            // Recover all "PEC Articles" of the PEC        
            for(PEC_Article__c oPECArticle:[select id, Article__c, Article__r.Name,Article__r.ExternalID__c,Article__r.Type__c,Article__r.Code_Article__c,Article__r.Recommended_Price__c,Article__r.Ordre_de_tri__c, Stock_SAP_pret__c, Stock_SAP_consigne__c, 
            Stock_SAP_installe__c, Stock_PEC_pret__c, Stock_PEC_consigne__c, Unit_Cost__c,Total_CostP__c, Total_CostC__c,Stock_pret_Last_PEC__c, Stock_cons_Last_PEC__c from PEC_Article__c where Prise_en_Charge__c=:oPEC.id ORDER BY Article__r.Ordre_de_tri__c]){
                if(oPECArticle.Article__r.Type__c == 'Bouteille'){
                    lPECBouteilles.add(oPECArticle);
                }
                else if (oPECArticle.Article__r.Type__c == 'Casier'){
                    lPECCasiers.add(oPECArticle);
                }
                else if (oPECArticle.Article__r.Type__c == 'Autre Matériel'){
                    lPECAutresMateriels.add(oPECArticle);
                }               
            }
        }  
    }
    
    public void createPECArticles(List<Item__c> lArticles,List<PEC_Article__c> lPECArticle){
        for(Item__c oArticle:lArticles){
            PEC_Article__c oPECArticle = new PEC_Article__c(Prise_en_Charge__c=oPEC.Id,Article__c=oArticle.Id, Article__r=oArticle);                
            if(mapButagazStock.containsKey(oArticle.Id)){
                oPECArticle.Stock_SAP_pret__c = mapButagazStock.get(oArticle.Id).Stock_pret_materiel__c;
                oPECArticle.Stock_SAP_consigne__c = mapButagazStock.get(oArticle.Id).Stock_consigne__c; 
                oPECArticle.Stock_SAP_installe__c = mapButagazStock.get(oArticle.Id).Stock_installe__c;
            } 
            if(mapLastPECStock.containsKey(oArticle.Id)){
                oPECArticle.Stock_pret_Last_PEC__c = mapLastPECStock.get(oArticle.Id).Stock_PEC_pret__c;
                oPECArticle.Stock_cons_Last_PEC__c = mapLastPECStock.get(oArticle.Id).Stock_PEC_consigne__c;        
            }
            oPECArticle.Unit_Cost__c = oArticle.Recommended_Price__c;   
            lPECArticle.add(oPECArticle);                   
        }
    }

    public void calcCost(){
        oPEC.Total_pret_B__c = 0;
        oPEC.Total_cost_pretB__c = 0;
        oPEC.Total_cons_B__c  = 0;
        oPEC.Total_cost_ConsB__c = 0;
        oPEC.Total_pret_C__c = 0;
        oPEC.Total_cost_pretC__c = 0;
        oPEC.Total_cons_C__c  = 0;
        oPEC.Total_cost_ConsC__c = 0; 
        oPEC.Total_pret_AM__c = 0;
        oPEC.Total_cost_pretAM__c = 0;
        oPEC.Total_cons_AM__c = 0;
        oPEC.Total_cost_consAM__c = 0;
        
        for(PEC_Article__c PECArticle: lPECBouteilles){        
            CalcTotal(PECArticle);
        }
        
        for(PEC_Article__c PECArticle: lPECCasiers){        
            CalcTotal(PECArticle);
        }  
        
        for(PEC_Article__c PECArticle: lPECAutresMateriels){        
            CalcTotal(PECArticle);
        }  
        
    }   
    
    public void CalcTotal(PEC_Article__c PECArticle) {
        if (oAccount.Channel__c == 'CS') {
            //Total  pret
            if( (PECArticle.Unit_Cost__c != null) && (PECArticle.Stock_PEC_pret__c != null) ) {
                PECArticle.Total_CostP__c= PECArticle.Unit_Cost__c * PECArticle.Stock_PEC_pret__c ;
                
                if(PECArticle.Article__r.Type__c == 'Bouteille'){
                    oPEC.Total_pret_B__c += PECArticle.Stock_PEC_pret__c;
                    oPEC.Total_cost_pretB__c += PECArticle.Total_CostP__c;
                }
                else if (PECArticle.Article__r.Type__c == 'Casier'){
                    oPEC.Total_pret_C__c += PECArticle.Stock_PEC_pret__c;
                    oPEC.Total_cost_pretC__c += PECArticle.Total_CostP__c;
                }
                else if (PECArticle.Article__r.Type__c == 'Autre Matériel'){
                    oPEC.Total_pret_AM__c += PECArticle.Stock_PEC_pret__c;
                    oPEC.Total_cost_pretAM__c += PECArticle.Total_CostP__c;
                }   
            } 
            else
            {
                PECArticle.Total_CostP__c= null;
            }
            //Total  consigné
            if( (PECArticle.Unit_Cost__c != null) && (PECArticle.Stock_PEC_consigne__c != null) ) {
                PECArticle.Total_CostC__c= PECArticle.Unit_Cost__c * PECArticle.Stock_PEC_consigne__c ;
                
                if(PECArticle.Article__r.Type__c == 'Bouteille'){
                    oPEC.Total_cons_B__c += PECArticle.Stock_PEC_consigne__c;
                    oPEC.Total_cost_ConsB__c += PECArticle.Total_CostC__c;
                }
                else if (PECArticle.Article__r.Type__c == 'Casier'){
                    oPEC.Total_cons_C__c += PECArticle.Stock_PEC_consigne__c;
                    oPEC.Total_cost_ConsC__c += PECArticle.Total_CostC__c;
                }
                else if (PECArticle.Article__r.Type__c == 'Autre Matériel'){
                    oPEC.Total_cons_AM__c += PECArticle.Stock_PEC_consigne__c;
                    oPEC.Total_cost_consAM__c += PECArticle.Total_CostC__c;
                }                   
               
            } 
            else
            {
                PECArticle.Total_CostC__c= null;
            }  
        }
        else {
            //Total  pret
            if(PECArticle.Stock_PEC_pret__c != null) {              

                if(PECArticle.Article__r.Type__c == 'Bouteille'){
                    oPEC.Total_pret_B__c += PECArticle.Stock_PEC_pret__c;
                }
                else if (PECArticle.Article__r.Type__c == 'Casier'){
                    oPEC.Total_pret_C__c += PECArticle.Stock_PEC_pret__c;
                }
                else if (PECArticle.Article__r.Type__c == 'Autre Matériel'){
                    oPEC.Total_pret_AM__c += PECArticle.Stock_PEC_pret__c;
                }                           
            } 
            //Total  consigné
            if(PECArticle.Stock_PEC_consigne__c != null)  {
            
                if(PECArticle.Article__r.Type__c == 'Bouteille'){
                    oPEC.Total_cons_B__c += PECArticle.Stock_PEC_consigne__c; 
                }
                else if (PECArticle.Article__r.Type__c == 'Casier'){
                    oPEC.Total_cons_C__c += PECArticle.Stock_PEC_consigne__c;
                }
                else if (PECArticle.Article__r.Type__c == 'Autre Matériel'){
                    oPEC.Total_cons_AM__c += PECArticle.Stock_PEC_consigne__c;
                }
                
            }                           
        } 
    }       
    
    // ****************  
    // Save information
    // ****************
    public pageReference saveBtn(){     
    
        list<PEC_Article__c> lPECArticlessToUpsert = new list<PEC_Article__c>();//PEC Articles to be upserted           
        calcCost();
        // Define a save point
        sp = Database.setSavepoint();
        PEC__c oNewPEC;
        
        try{
               
            //upsert New PEC;
            oNewPEC =oPEC.clone(true);
            upsert oNewPEC;       
                
            // Upsert PEC Articles       
            for(PEC_Article__c PECArticle : lPECBouteilles){
                PEC_Article__c oNewPECArticle = PECArticle.clone(true);
                if(sMode=='New') {
                    oNewPECArticle.Prise_en_Charge__c= oNewPEC.id;
                }
                lPECArticlessToUpsert.add(oNewPECArticle);
            }
            for(PEC_Article__c PECArticle : lPECCasiers){
                PEC_Article__c oNewPECArticle = PECArticle.clone(true);
                if(sMode=='New') {
                    oNewPECArticle.Prise_en_Charge__c= oNewPEC.id;
                }
                lPECArticlessToUpsert.add(oNewPECArticle);
            }

            for(PEC_Article__c PECArticle : lPECAutresMateriels){
                PEC_Article__c oNewPECArticle = PECArticle.clone(true);
                if(sMode=='New') {
                    oNewPECArticle.Prise_en_Charge__c= oNewPEC.id;
                }
                lPECArticlessToUpsert.add(oNewPECArticle);
            }           
            
            
            if(lPECArticlessToUpsert.size()>0){
                upsert lPECArticlessToUpsert;
            } 
        } 
        catch(DmlException ex){
            
            Database.rollback(sp);
            ApexPages.addMessages(ex);            
            return null;
        }   
        return new PageReference('/' + oNewPEC.id); 
    }       

    //Get articles of type "Bouteilles" that are installed   
    public List<PEC_Article__c> getListBouteillesInstalles(){
        List<PEC_Article__c> ListBouteillesInstalles = new List<PEC_Article__c>();
        for (PEC_Article__c Bouteille:lPECBouteilles) {
            if((Bouteille.Stock_PEC_pret__c != null && Bouteille.Stock_PEC_pret__c !=0) ||
              (Bouteille.Stock_PEC_consigne__c != null && Bouteille.Stock_PEC_consigne__c !=0 )) {            
                ListBouteillesInstalles.add(Bouteille);
            }
        }
        return ListBouteillesInstalles;
    }    
    
    //Get articles of type "Casiers" that are installed   
    public List<PEC_Article__c> getListCasiersInstalles(){
        List<PEC_Article__c> ListCasiersInstalles = new List<PEC_Article__c>();
        for (PEC_Article__c Casier:lPECCasiers) {
            if((Casier.Stock_PEC_pret__c != null && Casier.Stock_PEC_pret__c !=0) ||           
             (Casier.Stock_PEC_consigne__c != null && Casier.Stock_PEC_consigne__c !=0)) {            
                ListCasiersInstalles.add(Casier);
            }
        }
        return ListCasiersInstalles;
    }
    
    //Get articles of type "Autre Matériel" that are installed   
    public List<PEC_Article__c> getListAMInstalles(){
        List<PEC_Article__c> ListAMInstalles = new List<PEC_Article__c>();
        for (PEC_Article__c AMateriel:lPECAutresMateriels) {
            if((AMateriel.Stock_PEC_pret__c != null && AMateriel.Stock_PEC_pret__c !=0) ||
               (AMateriel.Stock_PEC_consigne__c != null && AMateriel.Stock_PEC_consigne__c !=0)) {            
                ListAMInstalles.add(AMateriel);
            }
        }
        return ListAMInstalles;
    } 
 
    //Display the articles of type "Bouteilles" if the list is not null
    Public boolean getRenderBouteilles(){
        return (lPECBouteilles.size()>0);
    } 
        
    //Display the articles of type "Casiers" if the list is not null
    Public boolean getRenderCasiers(){
        return (lPECCasiers.size()>0);
    }

    //Display the articles of type "Autre Matériel" if the list is not null
    Public boolean getRenderAutreMateriel(){
        return (lPECAutresMateriels.size()>0);
    }

    //Display the articles of type "Casiers" installés if the list is not null
    Public boolean getRenderBouteillesInstalles(){
        return (getListBouteillesInstalles().size()>0);
    } 
    
    //Display the articles of type "Casiers" installés if the list is not null
    Public boolean getRenderCasiersInstalles(){
        return (getListCasiersInstalles().size()>0);
    } 
        

    //Display the articles of type "Autre Matériel" installés if the list is not null
    Public boolean getRenderAMInstalles(){
        return (getListAMInstalles().size()>0);
    } 
    
    public String getTodayDate() {

        return date.today().format();

    } 
    
    public String getLastPecDate() {

        return oPEC.Last_PEC_Date__c.format();

    }  
}