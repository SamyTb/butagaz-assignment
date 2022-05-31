public class VFC_ControleDesStocks01{
 // ************
    // Attributes
    // ************ 
    public CDS__c oCDS {get;set;}
    ApexPages.StandardController oControl;  
    public string sMode {get;set;}// Page mode : New, Edit
    public Account oAccount {get;set;}// Link to the Account
    public PTL__c oPTL {get;set;}// Link to the PTL of the account
    public boolean bIssue {get;set;}// Manage issues
    public map<string, List<CDS_Article__c>> mCDSArticles {get;set;}//CDSArticles 
    public List<Item__c> lBouteilles {get;set;}//Articles of type Bouteille
    public List<Item__c> lCasiers {get;set;}//Articles of type Casier
    public List<CDS_Article__c> lCDSBouteilles {get;set;}//CDS Articles Bouteilles
    public List<CDS_Article__c> lCDSCasiers {get;set;}//CDS Articles Casiers
    public map<Id,Butagaz_Stock_Installed__c> mapButagazStockInstalled {get;set;}
    public transient Savepoint sp; //Database Savepoint
    public boolean bValidated {get;set;}// CDS Validated

    public static String isSE{get; set;} // Is the PEC being electronically signed ?
    public static String displayCGUSE{get; set;} // Display electronic signature CGU ?
    public static String withdrawalText{get; set;} // Display withdrawal text in electronic signature component ?
    public static String nbSig{get; set;} // Display withdrawal text in electronic signature component ?
    public Boolean displayPEC{get; set;}

    // ************
    // CONTROLLER
    // ************ 
    public VFC_ControleDesStocks01(ApexPages.StandardController oControl_in){
        this.oControl=oControl_in;        
        
        // Recover page mode
        oCDS=(CDS__c)oControl.getRecord();
        sMode=(oCDS.Id==null?'New':'Edit');                
        bIssue=false; 
 
        if( (sMode=='Edit') && (oCDS.Status__c != 'Attente de signature' && oCDS.Status__c !=null) ){
            bValidated = true;
            bIssue=true;

            //FLA 17/12/2021 
            if(oCDS.Status__c == 'Signé')
                displayPEC = true;
            ApexPages.AddMessage(new ApexPages.message(ApexPages.Severity.WARNING,System.Label.CDS_Validated));         
        }

        isSE = ApexPages.CurrentPage().getParameters().get('isSE');
        if(isSE == null){isSE = 'false';}  // non-electronic signature, constructor called by the VFP, not the button
        displayCGUSE = ApexPages.CurrentPage().getParameters().get('displayCGUSE');
        if(displayCGUSE == null){displayCGUSE = 'false';}  // non-electronic signature, constructor called by the VFP, not the button
        withdrawalText = ApexPages.CurrentPage().getParameters().get('withdrawalText');
        //if(withdrawalText == null){withdrawalText = 'false';}  // non-electronic signature, constructor called by the VFP, not the button
        nbSig = ApexPages.CurrentPage().getParameters().get('nbSig');
        if(nbSig == null){nbSig = '1';}  // non-electronic signature, constructor called by the VFP, not the button
        
        
        /* no more control, request number 370, FLA*/
        /* controle on back office group FLA*/     
        if(sMode=='Edit')
        {
            /*Id userId = UserInfo.getUserId();
            List<GroupMember> members = [select GroupId, UserOrGroupId from GroupMember where UserOrGroupId = :userId and GroupId in (select Id from Group WHERE DeveloperName = 'BackOffice')];

            if(members.isEmpty() || members == null)
            {
                bIssue=true;
                ApexPages.AddMessage(new ApexPages.message(ApexPages.Severity.FATAL,'Vous devez faire partie du groupe Back Office pour pouvoir modifier un CDS.'));

            }*/

            /*
            ID iCDSOwnerId =[Select CreatedById  from CDS__c where Id=:oCDS.Id].CreatedById;
            ID iCurrentUserId = UserInfo.getUserId();
            
            List<Id> lAllowedUserIDs = AP_PricingUtilities.getCustomSettingValue('UserIDsAllowedToModifyCDSStatus').split(';');
            set<Id> sAllowedUserIDs = new set<Id>();
            sAllowedUserIDs.addAll(lAllowedUserIDs);
            
            if(iCurrentUserId!=iCDSOwnerId && !sAllowedUserIDs.contains(iCurrentUserId)){
                bIssue=true;
                ApexPages.AddMessage(new ApexPages.message(ApexPages.Severity.WARNING,'Le CDS n\'est modifiable que par le créateur' ));
            }*/
        }
        

        // "New button" from the Prise En Charge tab
        if(oCDS.Account__c == null){
            bIssue=true;
            ApexPages.AddMessage(new ApexPages.message(ApexPages.Severity.INFO,System.Label.CDS_creation_issue));
        }
        else{ 

            //Recover Account information
            oAccount=[select id ,Name,General_Deletion_Flag__c,ADV_Deletion_Flag__c , Channel__c, ExternalId__c,AccountNumber  from Account where id=:oCDS.Account__c];
                
            // Recover PTL information
            oPTL=null;
            list<PTL__c> lPTLs=[select id ,Name, Code_Canal__c, Code_magasin__c,ExternalId__c from PTL__c where Account_DO__c=:oCDS.Account__c];
            if (lPTLs.size() > 0) {
                oPTL=lPTLs.get(0) ;               
            }       
                   
            // Case of a closed Account
            if((oAccount.General_Deletion_Flag__c == true) || (oAccount.ADV_Deletion_Flag__c==true)){
                bIssue=true;
                ApexPages.AddMessage(new ApexPages.message(ApexPages.Severity.INFO,'Ce Compte est fermé. Vous ne pouvez pas réaliser un CDS pour un Compte fermé.'));
            }
            else {
                              
                
                //Recover CDS Day
                if(sMode=='New') oCDS.CDS_Date__c = datetime.now();
                
                // Recover CDS Articles to Display
                lCDSBouteilles = new List<CDS_Article__c>();
                lCDSCasiers = new List<CDS_Article__c>();          
                getCDSArticles();           
            
            }

        }       
    }
    
    // Recover CDS Articles
    public void getCDSArticles(){
           
        if(sMode=='New') {
        
            // Recover "Butagaz Stock Installed" related to the PTL           
            mapButagazStockInstalled=new map<Id,Butagaz_Stock_Installed__c>(); 
            if (oPTL != null) {
                for(Butagaz_Stock_Installed__c oStockInstalled:[select id, Article__c, /*Stock_installe__c*/ Stock_pret_materiel__c from Butagaz_Stock_Installed__c where PTL__c=:oPTL.id]){
                    mapButagazStockInstalled.put(oStockInstalled.Article__c, oStockInstalled);
                }    
            }

            //Recover all the articles of type Bouteille and Casier 
            lBouteilles = [SELECT id, Name,Type__c, Code_Article__c ,Ordre_de_tri__c, ExternalID__c FROM Item__c WHERE Type__c='Bouteille' ORDER BY Ordre_de_tri__c];
            lCasiers = [SELECT id, Name,Type__c, Code_Article__c ,Ordre_de_tri__c, ExternalID__c FROM Item__c WHERE Type__c='Casier' ORDER BY Ordre_de_tri__c];         

            // Create CDS Articles for all the articles
            createCDSArticles(lBouteilles,lCDSBouteilles);
            createCDSArticles(lCasiers,lCDSCasiers);
            
        }
        else {
            // Recover all "CDS Articles" of the CDS        
            for(CDS_Article__c oCDSArticle:[select id, Article__c, Article__r.Name,Article__r.ExternalID__c,Article__r.Type__c,Article__r.Code_Article__c, Stock_PEC__c,Stock_effectif__c, Valeur_Consignation__c, Valeur_Deconsignation__c, Consignation__c, Deconsignation__c, Stock_Reel__c, Resultat_CDS__c, Compensation_Excedents__c, Non_Facture_Excedents__c, Compensation_Manquants__c, Consignation_Manquants__c from CDS_Article__c where CDS__c=:oCDS.id]){ 
                if (oCDSArticle.Article__r.Type__c == 'Bouteille'){
                    lCDSBouteilles.add(oCDSArticle);
                }
                else if (oCDSArticle.Article__r.Type__c == 'Casier'){
                    lCDSCasiers.add(oCDSArticle);
                }               
            }               
        }  
    }
    
    public void createCDSArticles(List<Item__c> lArticles, List<CDS_Article__c> lCDSArticle){
        for(Item__c oArticle:lArticles){
            CDS_Article__c oCDSArticle = new CDS_Article__c(CDS__c=oCDS.Id,Article__c=oArticle.Id, Article__r=oArticle);                
            if(mapButagazStockInstalled.containsKey(oArticle.Id)){
                oCDSArticle.Stock_PEC__c = mapButagazStockInstalled.get(oArticle.Id).Stock_pret_materiel__c;

            }   
            lCDSArticle.add(oCDSArticle);                   
        }
    }   

// ************
    // METHODS
    // ************     
    
    // ****************************  
    // Calculate Result of CDS
    // ****************************
    public pageReference calcResultBtn(){
    
        calcResult();               
        return null;
    }

    public void calcResult(){   
		//recherche l'Id des articles BD, G, CB, CP pour gérer la compensation, on stock Id article et plus tard le resultatCDS
        list<Item__c> lItem_BD_G = [Select Name, Id From Item__c where Name = 'BUTANE 13KG' OR Name = 'PROPANE 13KG'];
        Map<Id, String> mapResultatCDS_BD_G = new Map<Id, String>();
        Map<String, Decimal> mapCompensationCDS_BD_G = new Map<String, Decimal>();
        for(Item__c item:lItem_BD_G)
        {
            mapResultatCDS_BD_G.put(item.Id, item.Name);
            mapCompensationCDS_BD_G.put(item.Name, 0);
        }
        list<Item__c> lItem_CB_CP = [Select Name, Id From Item__c where Name = 'BUTANE CUBE 6KG' OR Name = 'PROPANE CUBE 5KG'];
        Map<Id, String> mapResultatCDS_CB_CP = new Map<Id, String>();
        Map<String, Decimal> mapCompensationCDS_CB_CP = new Map<String, Decimal>();
        for(Item__c item:lItem_CB_CP)
        {
            mapResultatCDS_CB_CP.put(item.Id, item.Name);
            mapCompensationCDS_CB_CP.put(item.Name, 0);
        }

        //réinit les valeurs à null
        for(CDS_Article__c oCDSArticle: lCDSBouteilles){
            oCDSArticle.Compensation_Excedents__c = null;
            oCDSArticle.Consignation_Manquants__c = null;
            oCDSArticle.Non_Facture_Excedents__c = null;
            oCDSArticle.Compensation_Manquants__c = null;
        }
        for(CDS_Article__c oCDSArticle: lCDSCasiers){
            oCDSArticle.Compensation_Excedents__c = null;
            oCDSArticle.Consignation_Manquants__c = null;
            oCDSArticle.Non_Facture_Excedents__c = null;
            oCDSArticle.Compensation_Manquants__c = null;
        }
        
        for(CDS_Article__c oCDSArticle: lCDSBouteilles){
            calcResultCDSArticle(oCDSArticle);
        }
        
        //on fait une passe pour récupérer cds compensation
        for(CDS_Article__c oCDSArticle: lCDSBouteilles){  
			//si article compensé, on sauvegarde resultatCDS dans map
            if(mapResultatCDS_BD_G.get(oCDSArticle.Article__c)!=null)
            	mapCompensationCDS_BD_G.put(oCDSArticle.Article__r.Name, oCDSArticle.Resultat_CDS__c);
            if(mapResultatCDS_CB_CP.get(oCDSArticle.Article__c)!=null)
            	mapCompensationCDS_CB_CP.put(oCDSArticle.Article__r.Name, oCDSArticle.Resultat_CDS__c);
        }

        system.debug('mapResultatCDS_BD_G:'+mapResultatCDS_BD_G);
        system.debug('mapResultatCDS_CB_CP:'+mapResultatCDS_CB_CP);
        system.debug('mapCompensationCDS_BD_G:'+mapCompensationCDS_BD_G);
        system.debug('mapCompensationCDS_CB_CP:'+mapCompensationCDS_CB_CP);

        for(CDS_Article__c oCDSArticle: lCDSBouteilles)
        {  
            if((mapResultatCDS_BD_G.get(oCDSArticle.Article__c)==null) && (mapResultatCDS_CB_CP.get(oCDSArticle.Article__c)==null))
	            calcResultExcedantManquant(oCDSArticle);
			
            //gestion compensation BD G
            if(mapResultatCDS_BD_G.get(oCDSArticle.Article__c)!=null)
            {
            	//gestion compensation BD G, il y a compensation que si l'un est >0 et l'autre <0 ou l'inverse
                if((mapCompensationCDS_BD_G.get('BUTANE 13KG')>0 && mapCompensationCDS_BD_G.get('PROPANE 13KG')<0))
                {
                    //si somme>0:excedant
                    if((mapCompensationCDS_BD_G.get('BUTANE 13KG')+mapCompensationCDS_BD_G.get('PROPANE 13KG'))>0)
                    {
                        if(oCDSArticle.Article__r.Name == 'BUTANE 13KG')
                        {
                            oCDSArticle.Non_Facture_Excedents__c = Math.abs(mapCompensationCDS_BD_G.get('BUTANE 13KG')+mapCompensationCDS_BD_G.get('PROPANE 13KG'));
							oCDSArticle.Compensation_Excedents__c = Math.abs(mapCompensationCDS_BD_G.get('PROPANE 13KG'));
                        }    
                        if(oCDSArticle.Article__r.Name == 'PROPANE 13KG')
							oCDSArticle.Compensation_Manquants__c = Math.abs(mapCompensationCDS_BD_G.get('PROPANE 13KG'));
                    }
                    //si somme<0:manquant
                    if((mapCompensationCDS_BD_G.get('BUTANE 13KG')+mapCompensationCDS_BD_G.get('PROPANE 13KG'))<0)
                    {
                        if(oCDSArticle.Article__r.Name == 'PROPANE 13KG')
                        {
                            oCDSArticle.Consignation_Manquants__c = Math.abs(mapCompensationCDS_BD_G.get('BUTANE 13KG')+mapCompensationCDS_BD_G.get('PROPANE 13KG'));
							oCDSArticle.Compensation_Manquants__c = Math.abs(mapCompensationCDS_BD_G.get('BUTANE 13KG'));
                        }    
                        if(oCDSArticle.Article__r.Name == 'BUTANE 13KG')
							oCDSArticle.Compensation_Excedents__c = Math.abs(mapCompensationCDS_BD_G.get('BUTANE 13KG'));
                    }
                    //si somme==0:manquant
                    if((mapCompensationCDS_BD_G.get('BUTANE 13KG')+mapCompensationCDS_BD_G.get('PROPANE 13KG'))==0)
                    {
                        if(oCDSArticle.Article__r.Name == 'PROPANE 13KG')
							oCDSArticle.Compensation_Manquants__c = Math.abs(mapCompensationCDS_BD_G.get('BUTANE 13KG'));
                        if(oCDSArticle.Article__r.Name == 'BUTANE 13KG')
							oCDSArticle.Compensation_Excedents__c = Math.abs(mapCompensationCDS_BD_G.get('BUTANE 13KG'));
                    }
                }
                else if((mapCompensationCDS_BD_G.get('BUTANE 13KG')<0 && mapCompensationCDS_BD_G.get('PROPANE 13KG')>0))
                {
                    //si somme>0:excedant
                    if((mapCompensationCDS_BD_G.get('BUTANE 13KG')+mapCompensationCDS_BD_G.get('PROPANE 13KG'))>0)
                    {
                        if(oCDSArticle.Article__r.Name == 'PROPANE 13KG')
                        {
                            oCDSArticle.Non_Facture_Excedents__c = Math.abs(mapCompensationCDS_BD_G.get('BUTANE 13KG')+mapCompensationCDS_BD_G.get('PROPANE 13KG'));
							oCDSArticle.Compensation_Excedents__c = Math.abs(mapCompensationCDS_BD_G.get('BUTANE 13KG'));
                        }    
                        if(oCDSArticle.Article__r.Name == 'BUTANE 13KG')
							oCDSArticle.Compensation_Manquants__c = Math.abs(mapCompensationCDS_BD_G.get('BUTANE 13KG'));
                    }
                    
                    //si somme<0:manquant
                    if((mapCompensationCDS_BD_G.get('BUTANE 13KG')+mapCompensationCDS_BD_G.get('PROPANE 13KG'))<0)
                    {
                        if(oCDSArticle.Article__r.Name == 'BUTANE 13KG')
                        {
                            oCDSArticle.Consignation_Manquants__c = Math.abs(mapCompensationCDS_BD_G.get('BUTANE 13KG')+mapCompensationCDS_BD_G.get('PROPANE 13KG'));
							oCDSArticle.Compensation_Manquants__c = Math.abs(mapCompensationCDS_BD_G.get('PROPANE 13KG'));
                        }    
                        if(oCDSArticle.Article__r.Name == 'PROPANE 13KG')
							oCDSArticle.Compensation_Excedents__c = Math.abs(mapCompensationCDS_BD_G.get('PROPANE 13KG'));
                    }
                    //si somme==0:manquant
                    if((mapCompensationCDS_BD_G.get('BUTANE 13KG')+mapCompensationCDS_BD_G.get('PROPANE 13KG'))==0)
                    {
                        if(oCDSArticle.Article__r.Name == 'PROPANE 13KG')
							oCDSArticle.Compensation_Excedents__c = Math.abs(mapCompensationCDS_BD_G.get('BUTANE 13KG'));
                        if(oCDSArticle.Article__r.Name == 'BUTANE 13KG')
							oCDSArticle.Compensation_Manquants__c = Math.abs(mapCompensationCDS_BD_G.get('BUTANE 13KG'));
                    }
                    
                }
                else //pas de compensation
                    calcResultExcedantManquant(oCDSArticle);
			}         
            //gestion compensation CB CP
            if(mapResultatCDS_CB_CP.get(oCDSArticle.Article__c)!=null)
            {
            	//gestion compensation BD G, il y a compensation que si l'un est >0 et l'autre <0 ou l'inverse
                if((mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG')>0 && mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG')<0))
                {
                    //si somme>0:excedant
                    if((mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG')+mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG'))>0)
                    {
                        if(oCDSArticle.Article__r.Name == 'BUTANE CUBE 6KG')
                        {
                            oCDSArticle.Non_Facture_Excedents__c = Math.abs(mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG')+mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG'));
							oCDSArticle.Compensation_Excedents__c = Math.abs(mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG'));
                        }    
                        if(oCDSArticle.Article__r.Name == 'PROPANE CUBE 5KG')
							oCDSArticle.Compensation_Manquants__c = Math.abs(mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG'));
                    }
                    //si somme<0:manquant
                    if((mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG')+mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG'))<0)
                    {
                        if(oCDSArticle.Article__r.Name == 'PROPANE CUBE 5KG')
                        {
                            oCDSArticle.Consignation_Manquants__c = Math.abs(mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG')+mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG'));
							oCDSArticle.Compensation_Manquants__c = Math.abs(mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG'));
                        }    
                        if(oCDSArticle.Article__r.Name == 'BUTANE CUBE 6KG')
							oCDSArticle.Compensation_Excedents__c = Math.abs(mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG'));
                    }
                    //si somme==0:manquant
                    if((mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG')+mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG'))==0)
                    {
                        if(oCDSArticle.Article__r.Name == 'PROPANE CUBE 5KG')
							oCDSArticle.Compensation_Manquants__c = Math.abs(mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG'));
                        if(oCDSArticle.Article__r.Name == 'BUTANE CUBE 6KG')
							oCDSArticle.Compensation_Excedents__c = Math.abs(mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG'));
                    }
                }
                else if((mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG')<0 && mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG')>0))
                {
                    //si somme>0:excedant
                    if((mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG')+mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG'))>0)
                    {
                        if(oCDSArticle.Article__r.Name == 'PROPANE CUBE 5KG')
                        {
                            oCDSArticle.Non_Facture_Excedents__c = Math.abs(mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG')+mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG'));
							oCDSArticle.Compensation_Excedents__c = Math.abs(mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG'));
                        }    
                        if(oCDSArticle.Article__r.Name == 'BUTANE CUBE 6KG')
							oCDSArticle.Compensation_Manquants__c = Math.abs(mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG'));
                    }
                    //FLA -2 1
                    //si somme<0:manquant
                    if((mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG')+mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG'))<0)
                    {
                        if(oCDSArticle.Article__r.Name == 'BUTANE CUBE 6KG')
                        {
                            oCDSArticle.Consignation_Manquants__c = Math.abs(mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG')+mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG'));
							oCDSArticle.Compensation_Manquants__c = Math.abs(mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG'));
                        }    
                        if(oCDSArticle.Article__r.Name == 'PROPANE CUBE 5KG')
							oCDSArticle.Compensation_Excedents__c = Math.abs(mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG'));
						
                    }
                    //si somme==0:manquant
                    if((mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG')+mapCompensationCDS_CB_CP.get('PROPANE CUBE 5KG'))==0)
                    {
                        if(oCDSArticle.Article__r.Name == 'PROPANE CUBE 5KG')
							oCDSArticle.Compensation_Excedents__c = Math.abs(mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG'));
                        if(oCDSArticle.Article__r.Name == 'BUTANE CUBE 6KG')
							oCDSArticle.Compensation_Manquants__c = Math.abs(mapCompensationCDS_CB_CP.get('BUTANE CUBE 6KG'));
                    }
                }
                else //pas de compensation
                    calcResultExcedantManquant(oCDSArticle);
			}         

        }
        
        for(CDS_Article__c oCDSArticle: lCDSCasiers){        
            calcResultCDSArticle(oCDSArticle);
            calcResultExcedantManquant(oCDSArticle);
        }

    }
    
    public void calcResultExcedantManquant(CDS_Article__c CDSArticle) {
        if(CDSArticle.Resultat_CDS__c > 0) 
        { 
            CDSArticle.Non_Facture_Excedents__c = CDSArticle.Resultat_CDS__c;
        	CDSArticle.Consignation_Manquants__c = null;
        }            
		if(CDSArticle.Resultat_CDS__c < 0) 
        {
            CDSArticle.Non_Facture_Excedents__c = null;
            CDSArticle.Consignation_Manquants__c = math.abs(CDSArticle.Resultat_CDS__c);
        }
		if(CDSArticle.Resultat_CDS__c == 0) 
        {
            CDSArticle.Non_Facture_Excedents__c = null;
            CDSArticle.Consignation_Manquants__c = null;
        }
    }

    public void calcResultCDSArticle(CDS_Article__c CDSArticle) {
    
        if( CDSArticle.Stock_effectif__c != null) {
            CDSArticle.Stock_Reel__c= CDSArticle.Stock_effectif__c;
            if( (CDSArticle.Consignation__c == TRUE) && (CDSArticle.Valeur_Consignation__c != null )) {
                CDSArticle.Stock_Reel__c +=CDSArticle.Valeur_Consignation__c;
            }
            if( (CDSArticle.Deconsignation__c == TRUE) && (CDSArticle.Valeur_Deconsignation__c != null )) {
                CDSArticle.Stock_Reel__c -= CDSArticle.Valeur_Deconsignation__c;
            }                   
            if( CDSArticle.Stock_PEC__c != null) {
                CDSArticle.Resultat_CDS__c=CDSArticle.Stock_Reel__c - CDSArticle.Stock_PEC__c;
            }
        } 
        else
        {
            CDSArticle.Stock_Reel__c= null;
        }   
    }
    
    // ****************  
    // Save information
    // ****************
    public pageReference saveBtn(){     
    
        list<CDS_Article__c> lCDSArticlessToUpsert = new list<CDS_Article__c>();//CDS Articles to be upserted
        calcResult();
        // Define a save point
        sp = Database.setSavepoint();
        CDS__c oNewCDS;
            
        try{
            //upsert New CDS;
            oNewCDS =oCDS.clone(true);
            upsert oNewCDS;
          
            // Upsert CDS Articles      
            for(CDS_Article__c CDSArticle : lCDSBouteilles){                           
                CDS_Article__c oNewCDSArticle = CDSArticle.clone(true);
                if(sMode=='New') {
                    oNewCDSArticle.CDS__c= oNewCDS.id;
                }
                    lCDSArticlessToUpsert.add(oNewCDSArticle);                           
            }       
            for(CDS_Article__c CDSArticle : lCDSCasiers){                           
                CDS_Article__c oNewCDSArticle = CDSArticle.clone(true);
                if(sMode=='New') {
                    oNewCDSArticle.CDS__c= oNewCDS.id;
                }
                    lCDSArticlessToUpsert.add(oNewCDSArticle);                           
            }       
                        
            
            if(lCDSArticlessToUpsert.size()>0){
                upsert lCDSArticlessToUpsert;
            }         
        } 
        catch(DmlException ex){
            
            Database.rollback(sp);
            ApexPages.addMessages(ex);            
            return null;
        }   
        return new PageReference('/' + oNewCDS.id); 
    }    

    
    //Display the articles of type "Bouteilles" if the list is not null
    Public boolean getRenderBouteilles(){
        return (lCDSBouteilles.size() > 0);
    } 
        
    //Display the articles of type "Casiers" if the list is not null
    Public boolean getRenderCasiers(){
        return (lCDSCasiers.size() > 0);
    } 
    
    
   
    //Get articles of type "Bouteilles" that are installed
    public List<CDS_Article__c>  getListBouteillesInstalles(){
        List<CDS_Article__c> ListBouteillesInstalles = new List<CDS_Article__c>();
        for (CDS_Article__c Bouteille:lCDSBouteilles) {
            if((Bouteille.Stock_PEC__c != null && Bouteille.Stock_PEC__c !=0) ||
                    (Bouteille.Stock_effectif__c != null &&  Bouteille.Stock_effectif__c !=0)) {            
                ListBouteillesInstalles.add(Bouteille);
            }
        }
        return ListBouteillesInstalles;
    }

    //Get articles of type "Casiers" that are installed
    public List<CDS_Article__c>  getListCasiersInstalles(){
        List<CDS_Article__c> ListCasiersInstalles = new List<CDS_Article__c>();
        for (CDS_Article__c Casier:lCDSCasiers) {
            if((Casier.Stock_PEC__c != null && Casier.Stock_PEC__c !=0) ||
                    (Casier.Stock_effectif__c != null && Casier.Stock_effectif__c !=0)) {            
                ListCasiersInstalles.add(Casier);
            }
        }
        return ListCasiersInstalles;
    }
        
    //Display the articles of type "Bouteilles" installés if the list is not null
    Public boolean getRenderBouteillesInstalles(){
        return (getListBouteillesInstalles().size()>0);
    }
    
    //Display the articles of type "Casiers" installés if the list is not null
    Public boolean getRenderCasiersInstalles(){
        return (getListCasiersInstalles().size()>0);
    }  
        
    public String getTodayDate() {

        return date.today().format();

    } 
}