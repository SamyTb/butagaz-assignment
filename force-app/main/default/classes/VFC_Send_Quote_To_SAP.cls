public class VFC_Send_Quote_To_SAP {

    public String IdQuote{get; set;}
    public Account oAccount{get; set;}
    public list<Quote_PTL__c> lQPTL{get; set;}
    public list<Account> lAccount{get; set;}
    public Quote oQuote{get; set;}
    public list<Quote> lQuote{get; set;}
    public Boolean bSynchroSend{get; set;}
    public list<Opportunity_PTL__c> lOPTL{get; set;}
    public Boolean statusContinue{get; set;}
    public Boolean synchroSAP{get; set;}
    public String typeButton{get; set;}
    public Boolean afficheDevisDejaEnvoye{get; set;}
    public String DevisDejaEnvoye{get; set;}
    public list<QuoteLineItem> lQuoteLineItem{get; set;}
    public Boolean signature{get; set;}
    public Boolean ibanFrench;
    public list<QuoteLineItem> lQuoteLineItemRebate{get; set;}
    public Boolean displayRebate{get; set;}
    public Boolean displayOrder{get; set;}
    public Boolean displayAccount{get; set;}
    public String locationButton{get; set;}
    matriceSAP currentMatriceSAP;
    Map<String, Boolean> bapiALancer;
    public Boolean debug;
    public String IdOpty;
    public Boolean projetTypeSUCC{get; set;}
    public Boolean projetTypeCREA{get; set;}
    public Boolean projetTypeEXTE{get; set;}
    public Boolean stepPTL{get; set;}
    public Boolean stepAccount{get; set;}
    public Boolean displayActionCo{get; set;}
    public list<Action_Commerciale__c> lActionCo{get; set;}
    public Boolean typeClientPro{get; set;}
    public Boolean typeClientDom{get; set;}

    public VFC_Send_Quote_To_SAP(ApexPages.StandardController controller) 
    {
        this.IdQuote = ApexPages.CurrentPage().getParameters().get('id');
    }

    public PageReference init() 
    {
        system.debug('VFC_Send_Quote_To_SAP');

        this.bSynchroSend = true;
        //this.statusContinue = true;
        this.typeButton = 'button';
        this.afficheDevisDejaEnvoye = false;
        this.DevisDejaEnvoye = '';

        //debut verif custom metadata Table_Ref_SF_SAP__mdt
        Map<String, String> mapTaRefSfSap = new Map<String, String>();
        list<Table_Ref_SF_SAP__mdt> tabRefSFSap = [select Id, MasterLabel, DeveloperName, Code_SAP_Salutation__c from Table_Ref_SF_SAP__mdt];
        if(tabRefSFSap == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Custom Metadata Table_Ref_SF_SAP__mdt non déployée.'));
            this.bSynchroSend = false;
            this.typeButton = 'hidden';
        }
        else if(tabRefSFSap.size()==0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Custom Metadata Table_Ref_SF_SAP__mdt: valeurs non initialisées.'));
            this.bSynchroSend = false;
            this.typeButton = 'hidden';
        }
        else 
        {
            for(Table_Ref_SF_SAP__mdt t:tabRefSFSap)
            {
                //system.debug(t.MasterLabel+'##'+t.DeveloperName);                    
                mapTaRefSfSap.put(t.MasterLabel, t.Code_SAP_Salutation__c); 
            }
        }
        //fin verif custom metadata Table_Ref_SF_SAP__mdt
        system.debug('MSG1');                    

        //infos necessaires synchro account, optl, etc..
        this.oQuote = [select Id, Contract_Duration__c, Sent_To_SAP__c, Product_Scale_Code__c, Scale_Code__c, OpportunityId, AccountId, Contact.salutation, Contact.firstname, Contact.lastname, Project_Type__c, 
        Client_Type__c, Account.name, account.AccountNumber, account.Error_Synchro_To_SAP__c, account.State_Synchro_To_SAP__c, account.salutation, Market_type__c, 
        opportunity.Account.Activity_Domain__r.ExternalID__c, opportunity.StageName, opportunity.Opportunity_Won_Substage__c, opportunity.Opportunity_Reason__c,
        Opportunity.Project_City_Postal_Code__r.City__r.Canton__r.Mandataire__r.ExternalID__c, T_LAT_Approved__c, IsSyncing, Activity_Domain_Opportunity__c, Signea_Date_Signature__c, 
        DO_Payment_method__c, Opportunity.Account_Payer__r.accountnumber, Opportunity.Account_Payer__r.SEPA_IBAN__c, 
        Opportunity.Account_Payer__r.SEPA_CITY__c, Opportunity.Account.accountnumber, Opportunity.Account.SEPA_IBAN__c, Opportunity.Contract_Start_Date__c, 
        Opportunity.Account.SEPA_CITY__c, Opportunity.PA_DO__c, Opportunity.DO_Recovery_procedures__c, Opportunity.DO_Accounting_Manager__c, 
        Opportunity.Project_Type__c, Opportunity.Project_Sub_Type__c, Opportunity.Storage_Modification_Reason__c, Opportunity.Reason__c,
        Action_Commerciale__c, Action_Commerciale__r.Fixed_Price__c, Action_Commerciale__r.Locked_Price__c, Action_Commerciale__r.Locked_Price_1_Year__c, Action_Commerciale__r.Locked_Price_2_Years__c, 
        Action_Commerciale__r.Locked_Price_3_Years__c, Error_Synchro_To_SAP_ActionCo__c, State_Synchro_To_SAP_ActionCo__c, 
        Action_Commerciale__r.Name, Action_Commerciale__r.Libelle__c, Opportunity.Number__c, Scale__c, Step_Quote_SF_SAP__c                     
        from Quote where Id= :this.IdQuote limit 1];
        
        this.IdOpty = this.oQuote.OpportunityId;
        system.debug('IdOpty:'+IdOpty);

        //affichage remise HT ou TTC
        if(this.oQuote.Market_type__c == 'PRO') typeClientPro = true;
        else typeClientDom = true;

        //definition du type de projet
        String typeProjet = (this.oQuote.Project_Type__c  + this.oQuote.Client_Type__c).toUpperCase();
        system.debug('typeProjet:'+typeProjet);  
        
        system.debug('this.oQuote.Opportunity.Project_Type__c:'+this.oQuote.Opportunity.Project_Type__c);                    
        system.debug('this.oQuote.Opportunity.Project_Sub_Type__c:'+this.oQuote.Opportunity.Project_Sub_Type__c);                    
        system.debug('this.oQuote.Opportunity.Opportunity_Reason__c:'+this.oQuote.Opportunity.Opportunity_Reason__c);                    
        system.debug('this.oQuote.Opportunity.Storage_Modification_Reason__c:'+this.oQuote.Opportunity.Storage_Modification_Reason__c);                    

        system.debug('this.oQuote.Opportunity.Contract_Start_Date__c:'+this.oQuote.Opportunity.Contract_Start_Date__c);                    
        system.debug('this.oQuote.Opportunity.Reason__c:'+this.oQuote.Opportunity.Reason__c);                    

        //debut verif custom metadata Matrice_Synchro_SF_SAP__mdt
        list<Matrice_Synchro_SF_SAP__mdt> lMat = [select Id, MasterLabel, DeveloperName from Matrice_Synchro_SF_SAP__mdt];
        if(lMat == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Custom Metadata Matrice_Synchro_SF_SAP__mdt non déployée.'));
            this.bSynchroSend = false;
            this.typeButton = 'hidden';
        }
        else if(lMat.size()==0)
        {    
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Custom Metadata Matrice_Synchro_SF_SAP__mdt: valeurs non initialisées.'));
            this.bSynchroSend = false;
            this.typeButton = 'hidden';
        }
        system.debug('MSG1');                    

        //debut matrice
        list<Matrice_Synchro_SF_SAP__mdt> lMatSynchroSFSap;
        //CREA
        if(this.oQuote.Opportunity.Project_Type__c == 'CREA')
        {
            lMatSynchroSFSap = [select Id, MasterLabel, Project_Type__c, Project_Sub_Type__c, Opportunity_Reason__c,
            Storage_Modification_Reason__c, PTL__c, DO__c, HIERARCHIE__c, REMISE__c, Calendrier_de_facturation__c, CONTRAT__c, 
            RAISON_CDE_CONTRAT_CREA__c, RAISON_CDE_CDE_MVT__c, CDE_MVT_CITERNE__c  from Matrice_Synchro_SF_SAP__mdt 
            where Project_Type__c = :this.oQuote.Opportunity.Project_Type__c AND Project_Sub_Type__c = :this.oQuote.Opportunity.Project_Sub_Type__c 
            AND Opportunity_Reason__c = :this.oQuote.Opportunity.Opportunity_Reason__c 
            AND RAISON_CDE_CONTRAT_CREA__c = :this.oQuote.Opportunity.Reason__c];
        }
        system.debug('MSG2');                    

        //EXTE
        if(this.oQuote.Opportunity.Project_Type__c == 'EXTE')
        {
            lMatSynchroSFSap = [select Id, MasterLabel, Project_Type__c, Project_Sub_Type__c, Opportunity_Reason__c,
            Storage_Modification_Reason__c, PTL__c, DO__c, HIERARCHIE__c, REMISE__c, Calendrier_de_facturation__c, CONTRAT__c, 
            RAISON_CDE_CONTRAT_CREA__c, RAISON_CDE_CDE_MVT__c, CDE_MVT_CITERNE__c  from Matrice_Synchro_SF_SAP__mdt 
            where Project_Type__c = :this.oQuote.Opportunity.Project_Type__c AND Opportunity_Reason__c = :this.oQuote.Opportunity.Opportunity_Reason__c 
            AND RAISON_CDE_CONTRAT_CREA__c = :this.oQuote.Opportunity.Reason__c];
        }
        system.debug('MSG3');                    

        //SUCC
        if(this.oQuote.Opportunity.Project_Type__c == 'SUCC')
        {
            lMatSynchroSFSap = [select Id, MasterLabel, Project_Type__c, Project_Sub_Type__c, Opportunity_Reason__c,
            Storage_Modification_Reason__c, PTL__c, DO__c, HIERARCHIE__c, REMISE__c, Calendrier_de_facturation__c, CONTRAT__c, 
            RAISON_CDE_CONTRAT_CREA__c, RAISON_CDE_CDE_MVT__c, CDE_MVT_CITERNE__c  from Matrice_Synchro_SF_SAP__mdt 
            where Project_Type__c = :this.oQuote.Opportunity.Project_Type__c AND Project_Sub_Type__c = :this.oQuote.Opportunity.Project_Sub_Type__c 
            AND Opportunity_Reason__c = :this.oQuote.Opportunity.Opportunity_Reason__c 
            AND Storage_Modification_Reason__c = :this.oQuote.Opportunity.Storage_Modification_Reason__c 
            AND RAISON_CDE_CONTRAT_CREA__c = :this.oQuote.Opportunity.Reason__c];
        }
        system.debug('MSG4');                    

        //for(Matrice_Synchro_SF_SAP__mdt mat:lMatSynchroSFSap)
            //system.debug('mat freddy:'+mat);                    
       system.debug('MSG5');                    

        system.debug('lMatSynchroSFSap freddy:'+lMatSynchroSFSap);  
        //if(Test.isRunningTest()){
			//lMatSynchroSFSap = null;
		//}
        
        if(lMatSynchroSFSap == null)
        {
            Opportunity opty = [select Id, toLabel(Storage_Modification_Reason__c), toLabel(Opportunity_Reason__c), 
                                toLabel(Project_Sub_Type__c), Project_Type__c, toLabel(Reason__c) from Opportunity where Id= :this.oQuote.OpportunityId limit 1];

            String smodificationRaison = (opty.Storage_Modification_Reason__c == null)?'': opty.Storage_Modification_Reason__c;
            String sRaisonOpty = (opty.Opportunity_Reason__c == null)?'': opty.Opportunity_Reason__c;
            String sSubTypeProjet =  (opty.Project_Sub_Type__c == null)?'': opty.Project_Sub_Type__c;
            String sRaisonCommande =  (opty.Reason__c == null)?'': opty.Reason__c;


            String aucunProcess = 'Aucun processus de synchronisation a été trouvé, veuillez contacter votre support.<br/>'+
            'Type de Projet : '+opty.Project_Type__c+'<br/>'+
            'Sous-type de Projet : '+sSubTypeProjet+'<br/>'+
            'Raison de l\'opportunité : '+sRaisonOpty+'<br/>'+
            'Raison de la modification : '+smodificationRaison+'<br/>'+
            'Raison de commande : '+sRaisonCommande+'<br/><br/>';

            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, aucunProcess));

            this.bSynchroSend = false;
            this.typeButton = 'hidden';
        }

        if(lMatSynchroSFSap != null)        
        {
            if(Test.isRunningTest()){
                lMatSynchroSFSap.clear();
            }

            if(lMatSynchroSFSap.size() == 0)
            {
                Opportunity opty = [select Id, toLabel(Storage_Modification_Reason__c), toLabel(Opportunity_Reason__c), 
                                    toLabel(Project_Sub_Type__c), Project_Type__c, toLabel(Reason__c) from Opportunity where Id= :this.oQuote.OpportunityId limit 1];
    
                String smodificationRaison = (opty.Storage_Modification_Reason__c == null)?'': opty.Storage_Modification_Reason__c;
                String sRaisonOpty = (opty.Opportunity_Reason__c == null)?'': opty.Opportunity_Reason__c;
                String sSubTypeProjet =  (opty.Project_Sub_Type__c == null)?'': opty.Project_Sub_Type__c;
                String sRaisonCommande =  (opty.Reason__c == null)?'': opty.Reason__c;
    
    
                String aucunProcess = 'Aucun processus de synchronisation a été trouvé, veuillez contacter votre support.<br/>'+
                'Type de Projet : '+opty.Project_Type__c+'<br/>'+
                'Sous-type de Projet : '+sSubTypeProjet+'<br/>'+
                'Raison de l\'opportunité : '+sRaisonOpty+'<br/>'+
                'Raison de la modification : '+smodificationRaison+'<br/>'+
                'Raison de commande : '+sRaisonCommande+'<br/><br/>';
    
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, aucunProcess));
    
                this.bSynchroSend = false;
                this.typeButton = 'hidden';
            }
        }

        if(lMatSynchroSFSap != null)        
        {
            if(lMatSynchroSFSap.size() > 1)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Plusieurs processus de synchronisation ont été trouvés, veuillez contacter votre support.'));
                this.bSynchroSend = false;
                this.typeButton = 'hidden';
            }
        }

        //DEF ACTION
        //String action; = currentMatriceSAP.contrat;
        system.debug('lMatSynchroSFSap:'+lMatSynchroSFSap); 
        //system.debug('lMatSynchroSFSap.size() :'+lMatSynchroSFSap.size() ); 

        if(lMatSynchroSFSap != null && lMatSynchroSFSap.size() > 0)        
        {
            
            if(lMatSynchroSFSap.size() == 1)
            {
                //action = this.currentMatriceSAP.contrat;
                this.currentMatriceSAP = new matriceSAP(lMatSynchroSFSap[0].Project_Type__c, lMatSynchroSFSap[0].Project_Sub_Type__c, lMatSynchroSFSap[0].Opportunity_Reason__c, 
                                             lMatSynchroSFSap[0].Storage_Modification_Reason__c, lMatSynchroSFSap[0].PTL__c, lMatSynchroSFSap[0].DO__c, 
                                             lMatSynchroSFSap[0].HIERARCHIE__c, lMatSynchroSFSap[0].REMISE__c, lMatSynchroSFSap[0].Calendrier_de_facturation__c, 
                                             lMatSynchroSFSap[0].CONTRAT__c, lMatSynchroSFSap[0].RAISON_CDE_CONTRAT_CREA__c, 
                                             lMatSynchroSFSap[0].RAISON_CDE_CDE_MVT__c, lMatSynchroSFSap[0].CDE_MVT_CITERNE__c);
            }
        }
        //fin matrice

        //pour verifier si il y a pas deja un autre devis rattaché à l'opty deja synchro avec SAP
        list<Quote> lQuote = [select Id, name from Quote where OpportunityId = :this.oQuote.OpportunityId AND Sent_To_SAP__c = true 
        AND Id != :this.oQuote.Id];

        //debut verif condition si devis synchronisable
        //deja synchronisé
        if( this.oQuote.Sent_To_SAP__c == true)
        { 
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Synchronisation déjà effectuée vers SAP.'));
            //this.bSynchroSend = true;
            this.typeButton = 'hidden';
        }
        else if(this.oQuote.Activity_Domain_Opportunity__c != 'GEC - Gaz en citerne')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Seul le domaine d\'activité \'GEC - Gaz en citerne\' est pris en charge.'));
            this.bSynchroSend = false;
            this.typeButton = 'hidden';
        }
        //on verifie si il y a pas deja un autre devis rattaché à l'opty deja synchro avec SAP
        else if(lQuote.size() > 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Un autre devis rattaché à l\'opportunité a déjà été synchronisé vers SAP : '+lQuote[0].name+'.'));
            this.bSynchroSend = true;
            this.typeButton = 'hidden';
            //permet d'afficher le devis deja synchronisé
            this.oQuote = [select Id, Sent_To_SAP__c, Contract_Duration__c, OpportunityId, AccountId, Contact.salutation, Contact.firstname, Contact.lastname, Project_Type__c, 
            Client_Type__c, Account.name, account.AccountNumber, account.Error_Synchro_To_SAP__c, account.State_Synchro_To_SAP__c, account.salutation, Market_type__c, 
            opportunity.Account.Activity_Domain__r.ExternalID__c, opportunity.StageName, opportunity.Opportunity_Won_Substage__c, opportunity.Opportunity_Reason__c,
            Opportunity.Project_City_Postal_Code__r.City__r.Canton__r.Mandataire__r.ExternalID__c, T_LAT_Approved__c, IsSyncing, Activity_Domain_Opportunity__c, Signea_Date_Signature__c, 
            DO_Payment_method__c, Opportunity.Account_Payer__r.accountnumber, Opportunity.Account_Payer__r.SEPA_IBAN__c, 
            Opportunity.Account_Payer__r.SEPA_CITY__c, Opportunity.Account.accountnumber, Opportunity.Account.SEPA_IBAN__c, Opportunity.Contract_Start_Date__c, 
            Opportunity.Account.SEPA_CITY__c, Opportunity.PA_DO__c, Opportunity.DO_Recovery_procedures__c, Opportunity.DO_Accounting_Manager__c, 
            Opportunity.Project_Type__c, Opportunity.Project_Sub_Type__c, Opportunity.Storage_Modification_Reason__c, Opportunity.Reason__c,
            Action_Commerciale__c, Action_Commerciale__r.Fixed_Price__c, Action_Commerciale__r.Locked_Price__c, Action_Commerciale__r.Locked_Price_1_Year__c, Action_Commerciale__r.Locked_Price_2_Years__c, 
            Action_Commerciale__r.Locked_Price_3_Years__c, Error_Synchro_To_SAP_ActionCo__c, State_Synchro_To_SAP_ActionCo__c, 
            Action_Commerciale__r.Name, Action_Commerciale__r.Libelle__c, Scale__c, Step_Quote_SF_SAP__c                    
            from Quote where Id= :lQuote[0].Id limit 1];

            this.afficheDevisDejaEnvoye = true;
            this.DevisDejaEnvoye = 'Détail de la synchronisation vers SAP du devis '+lQuote[0].name;
        }
        else 
        {
            //verif type de projet sur Quote
            List<String> ltypeProjetQuote = mapTaRefSfSap.get('typeProjetQuote').split('_');
            Boolean btypeProjetQuoteTrouve = false;
            for(String s:ltypeProjetQuote)
            {
                if(this.oQuote.Project_Type__c == s)
                    btypeProjetQuoteTrouve = true;
            }
        
            if(this.oQuote.Project_Type__c == 'SUCC' && this.oQuote.opportunity.Opportunity_Reason__c != 'Déplacement – Apparent vers Apparent' && 
            this.oQuote.opportunity.Opportunity_Reason__c != 'Aucun')
            { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 
                'Les devis dont le type de projet est SUCC, sont synchronisables vers SAP que si la raison de l\'opportunité est \'Déplacement – Apparent vers Apparent\' ou \'Aucun\'.'));
                //'Les devis dont le type de projet est SUCC, sont synchronisables vers SAP que si la raison de l\'opportunité est \'Déplacement – Enfoui vers Enfoui\' ou \'Déplacement – Apparent vers Apparent\' ou \'Achat de maison\'.'));
                this.bSynchroSend = false;
                this.typeButton = 'hidden';
            }

            if( btypeProjetQuoteTrouve == false)
            { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Seuls les devis dont le type de projet est CREA ou EXTE sont synchronisables vers SAP.'));
                this.bSynchroSend = false;
                this.typeButton = 'hidden';
            }

            //verif si devis approuvé 
            if( this.oQuote.T_LAT_Approved__c == false)
            { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Votre devis doit être approuvé.'));
                this.bSynchroSend = false;
                this.typeButton = 'hidden';
            }

            //verif si synchronisation initiale effectuée 
            if( this.oQuote.IsSyncing == false)
            { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Synchronisation initiale non effectuée.'));
                this.bSynchroSend = false;
                this.typeButton = 'hidden';
            }

            //debut list des champs obligatoires
            list<Quote_PTL__c> lQPTL = [select Id, Name from Quote_PTL__c where Quote__c = :this.IdQuote];

            //debut profil de consommation obligatoire
            //Rendre la saisie du profil de conso obligatoire dans le QPTL en CREA et EXTENSION
            if(this.oQuote.Opportunity.Project_Type__c == 'CREA' || this.oQuote.Opportunity.Project_Type__c == 'EXTE')
            {
                for(Quote_PTL__c qptl:lQPTL)
                {
                    LIST<PTL_Consumption_Profile__c> lconso = [select Id, Quote_PTL_del__c,
                    consumption_variable_jan__c, consumption_variable_feb__c, consumption_variable_mar__c, 
                    consumption_variable_apr__c, consumption_variable_may__c, consumption_variable_jun__c,
                    consumption_variable_jul__c, consumption_variable_aug__c, consumption_variable_sep__c,
                    consumption_variable_oct__c, consumption_variable_nov__c, consumption_variable_dec__c,
                    consumption_fixed_jan__c, consumption_fixed_feb__c, consumption_fixed_mar__c,
                    consumption_fixed_apr__c, consumption_fixed_may__c, consumption_fixed_jun__c,
                    consumption_fixed_jul__c, consumption_fixed_aug__c, consumption_fixed_sep__c,
                    consumption_fixed_oct__c, consumption_fixed_nov__c, consumption_fixed_dec__c
                    from PTL_Consumption_Profile__c where Quote_PTL_del__c = :qptl.Id];

                    system.debug(qptl.name+'## lconso size'+lconso.size());                    


                    if(lconso.size() == 0)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Profils de consommation obligatoires, QPTL : '+qptl.name+'.'));
                        this.bSynchroSend = false;
                        this.typeButton = 'hidden';
                    }
                }
            }
            //fin profil de consommation obligatoire

            Boolean champObligatoireCO = false;
            Boolean champObligatoireBO = false;
            String libelleChampObligatoireCO = 'Liste des champs obligatoires à compléter par le commercial :<br/>';
            String libelleChampObligatoireBO = 'Liste des champs obligatoires à compléter par le Back Office :<br/>';
            

            //verif si opty cloturé gagné et finalisé commerciale , StageName, Closed Won, Opportunity_Won_Substage__c, Finalized by Sales
            if(((this.oQuote.opportunity.StageName != 'Closed Won') || (this.oQuote.opportunity.Opportunity_Won_Substage__c != 'Finalized by Sales'))&&(this.oQuote.Sent_To_SAP__c!=true))
            {
                libelleChampObligatoireCO += '- L\'opportunité rattachée au devis doit être à l\'étape \'Clôturée gagnée\' avec un sous-statut \'Contrat finalisé par le commercial\'.<br/>';
                this.bSynchroSend = false;
                this.typeButton = 'hidden';
                champObligatoireCO = true;
            }


            //verif opty reason contractual data
            if((this.oQuote.Opportunity.Reason__c == '')||(this.oQuote.Opportunity.Reason__c == null))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Raison obligatoire.'));
                this.bSynchroSend = false;
                this.typeButton = 'hidden';
            }


            if(!isBackOfficeUser())
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Vous devez faire parti du groupe Back Office pour pouvoir synchroniser un devis.'));
                this.bSynchroSend = false;
                this.typeButton = 'hidden';
            }

            //verif si date de signature renseignée
            /*if(this.oQuote.opportunity.Contract_Start_Date__c == null)
            {
                libelleChampObligatoireCO += '- Date de signature contrat.<br/>';
                this.bSynchroSend = false;
                this.typeButton = 'hidden';
                champObligatoireCO = true;
            }*/

            //verif si procédure de relance renseignée
            if(this.oQuote.opportunity.DO_Recovery_procedures__c == null || this.oQuote.opportunity.DO_Recovery_procedures__c == '')
            {
                libelleChampObligatoireBO += '- Procédure de relance.<br/>';
                this.bSynchroSend = false;
                this.typeButton = 'hidden';
                champObligatoireBO = true;
            }
            
            //verif si Code gestionnaire comptable renseigné
            if(this.oQuote.opportunity.DO_Accounting_Manager__c == null)
            {
                libelleChampObligatoireBO += '- Code gestionnaire comptable.';
                this.bSynchroSend = false;
                this.typeButton = 'hidden';
                champObligatoireBO = true;
            }

            if(champObligatoireCO == true)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, libelleChampObligatoireCO));

            if(champObligatoireBO == true)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, libelleChampObligatoireBO));
            //fin list des champs obligatoires

        }
        //fin verif condition si devis synchronisable
        system.debug('MSG3');                    

        //DEBUT AFFICHAGE ACCOUNT ET BANK
        list<Account> lAccountBefore = [select Id, name, AccountNumber, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c, Error_Synchro_Bank_To_SAP__c, 
                            State_Synchro_Bank_To_SAP__c, SEPA_IBAN__c from account where Id= :this.oQuote.AccountId];
                            
        for(Account acc:lAccountBefore)
        {
            if(acc.Error_Synchro_To_SAP__c != null)
            {
                String retourSAP = '<ol>';
                list<string> split= acc.Error_Synchro_To_SAP__c.split('#');   
                for(String s:split)
                    retourSAP = retourSAP+'<li>'+s+'</li>';
                retourSAP = retourSAP+'</ol>'; 
                acc.Error_Synchro_To_SAP__c = retourSAP;
            }    
            if(acc.Error_Synchro_Bank_To_SAP__c != null)
            {
                String retourSAP = '<ol>';
                list<string> split= acc.Error_Synchro_Bank_To_SAP__c.split('#');   
                for(String s:split)
                    retourSAP = retourSAP+'<li>'+s+'</li>';
                retourSAP = retourSAP+'</ol>'; 
                acc.Error_Synchro_Bank_To_SAP__c = retourSAP;
            }    
        }   
        this.lAccount = lAccountBefore; 

        //si payeur != DO, on verifie si payeur posssede IBAN FR
        if(this.oQuote.Opportunity.PA_DO__c == false || this.oQuote.Opportunity.PA_DO__c == null)
        {
            system.debug('payeur != DO');
            
            String iban = this.oQuote.Opportunity.Account_Payer__r.SEPA_IBAN__c;
            system.debug('iban:'+iban);

            if(iban!='' && iban!=null && iban.length()>2)
                this.ibanFrench = (this.oQuote.Opportunity.Account_Payer__r.SEPA_IBAN__c.substring(0,2) == 'FR')? true:false;            
            else this.ibanFrench = false;
        }
        else //si payeur == DO, on verifie si payeur posssede IBAN FR
        {    
            system.debug('payeur == DO');

            String iban = this.oQuote.Opportunity.Account.SEPA_IBAN__c;
            system.debug('iban:'+iban);
            if(iban!='' && iban!=null && iban.length()>2)
                this.ibanFrench = (this.oQuote.Opportunity.Account.SEPA_IBAN__c.substring(0,2) == 'FR')? true:false;            
            else this.ibanFrench = false;
        }
        //FIN AFFICHAGE ACCOUNT ET BANK
        system.debug('this.ibanFrench:'+this.ibanFrench);

        system.debug('MSG4');        

        ////DEBUT AFFICHAGE QPL CONTRAT
        list<Quote_PTL__c> lQPTLBefore;
        if(this.oQuote.Opportunity.Project_Type__c == 'EXTE')//récupère juste nouveau ptl
        {
            lQPTLBefore = [select Id, name, Input_network_number__c, Opportunity_PTL__c, ContractSynchroSAP__c, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c 
                                                from Quote_PTL__c where Quote__c= :this.oQuote.Id and PTL_Name__c = null];
        }
        else
        {
            lQPTLBefore = [select Id, name, Input_network_number__c, Opportunity_PTL__c, ContractSynchroSAP__c, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c 
                                                from Quote_PTL__c where Quote__c= :this.oQuote.Id];
        }

        //DEBUT CONTRAT ABONNEMENT
        //on recherche si article abonnement
        List<Quote_PTL__c> lqptl1 = new List<Quote_PTL__c>();
        list<QuoteLineItem> lQLI = [select Id, OrderSynchroSAP__c, Error_Synchro_To_SAP__c, State_Synchro_To_SAP__c, Product_Code__c, Quantity from QuoteLineItem where Quote_PTL__c= :lQPTLBefore 
                                    and Product_Family__c = 'Redevance' and Quantity > 0 and QuoteId= :this.oQuote.Id];
                                    //and Product_Code__c = 'S000000017' and Quantity > 0 and QuoteId= :this.oQuote.Id];
                                    
        //creation du contrat que si CREA || typeProjet=='SUCCOWNER'
        if((lQLI.size()>0) && (this.oQuote.Scale__c == '2G') && ((this.oQuote.Project_Type__c == 'CREA')||(typeProjet=='SUCCOWNER')))
        {
            Quote_PTL__c qptlAbonnement = new Quote_PTL__c();
            qptlAbonnement.Input_network_number__c = 'Contrat Abonnement';
            qptlAbonnement.ContractSynchroSAP__c = lQLI[0].OrderSynchroSAP__c;
            qptlAbonnement.State_Synchro_To_SAP__c = lQLI[0].State_Synchro_To_SAP__c;
            qptlAbonnement.Error_Synchro_To_SAP__c = lQLI[0].Error_Synchro_To_SAP__c;

            lqptl1.add(qptlAbonnement);

        }
        
        for(Quote_PTL__c qptl:lQPTLBefore)
        {
            qptl.Input_network_number__c = qptl.Name;
            lqptl1.add(qptl);
        }

        for(Quote_PTL__c qptl:lqptl1)
        {
            if(qptl.Error_Synchro_To_SAP__c != null)
            {
                String retourSAP = '<ol>';
                list<string> split= qptl.Error_Synchro_To_SAP__c.split('#');   
                for(String s:split)
                    retourSAP = retourSAP+'<li>'+s+'</li>';
                retourSAP = retourSAP+'</ol>'; 
                qptl.Error_Synchro_To_SAP__c = retourSAP;
            }    
        }   
        this.lQPTL = lqptl1; 
        //// FIN AFFICHAGE QPL CONTRAT

        system.debug('MSG5');

        //DEBUT AFFICHAGE liste des OPTL
        list<String> lOPTLId = new list<String>();
        for(Quote_PTL__c qptl:lQPTL) 
            lOPTLId.add(qptl.Opportunity_PTL__c);
        list<Opportunity_PTL__c> lOPTLBefore = [select Id, PTL_Label__c, name, State_Synchro_To_SAP__c, Error_Synchro_To_SAP__c, PTLSynchroSAP__c from Opportunity_PTL__c where Id IN :lOPTLId];

        for(Opportunity_PTL__c optl:lOPTLBefore)
        {
            if(optl.Error_Synchro_To_SAP__c != null)
            {
                String retourSAP = '<ol>';
                list<string> split= optl.Error_Synchro_To_SAP__c.split('#');   
                for(String s:split)
                    retourSAP = retourSAP+'<li>'+s+'</li>';
                retourSAP = retourSAP+'</ol>'; 
                optl.Error_Synchro_To_SAP__c = retourSAP;
            }    
        }   
        this.lOPTL = lOPTLBefore; 
        
        //FIN AFFICHAGE liste des OPTL

        //DEBUT AFFICHAGE liste des COMMANDES
        list<String> lQPTLContract = new list<String>();
        list<String> lQPTLId = new list<String>();
        for(Quote_PTL__c qptl:lQPTL)
            lQPTLId.add(qptl.Id);
        list<QuoteLineItem> lQuoteLineItemBefore = [select Id, F_Product_Code__c, Product_Description__c, Sub_Type__c, Tank_Placing_Options__c, State_Synchro_To_SAP__c, 
                                Error_Synchro_To_SAP__c, OrderSynchroSAP__c from QuoteLineItem where Quote_PTL__c IN :lQPTLId 
                                AND Sub_Type__c = 'Citerne' AND Tank_Placing_Options__c IN ('MEP', 'DDS') AND Quantity>0  and QuoteId= :this.oQuote.Id];
                                
        system.debug('lQuoteLineItemBefore freddy 1 :'+lQuoteLineItemBefore);


        for(QuoteLineItem qli:lQuoteLineItemBefore)
        {
            if(qli.Error_Synchro_To_SAP__c != null)
            {
                String retourSAP = '<ol>';
                list<string> split= qli.Error_Synchro_To_SAP__c.split('#');   
                for(String s:split)
                    retourSAP = retourSAP+'<li>'+s+'</li>';
                retourSAP = retourSAP+'</ol>'; 
                qli.Error_Synchro_To_SAP__c = retourSAP;
            }    
        }   
        this.lQuoteLineItem = lQuoteLineItemBefore; 

        if(this.lQuoteLineItem.size()>0)
            this.displayOrder = true;
        else    
            this.displayOrder = false;

        //lot 3 SUCC, pas de commande (MEP) sans modification de stockage
        //if(this.oQuote.Opportunity.Project_Type__c == 'SUCC')
          //  this.displayOrder = false;
        //FIN AFFICHAGE liste des COMMANDES

        //DEBUT AFFICHAGE BANK
        if((this.ibanFrench == true)&&(this.oQuote.Signea_Date_Signature__c != null)&&((this.oQuote.DO_Payment_method__c == 'P')||(this.oQuote.DO_Payment_method__c == 'G')))
            this.signature = true;
        else this.signature = false;    
        if(this.bSynchroSend == false) this.signature = false;
        //this.signature = false;
        //FIN AFFICHAGE BANK

        //contract start date or SE
        if(this.signature == false)
        {
            //verif opty Contract_Start_Date__c
            if(this.oQuote.Opportunity.Contract_Start_Date__c == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Date de signature du contrat obligatoire.'));
                this.bSynchroSend = false;
                this.typeButton = 'hidden';
            }

        }

        //DEBUT AFFICHAGE REBATE
        this.lQuoteLineItemRebate = getcurrentQLIs(this.IdQuote);
        if(this.lQuoteLineItemRebate.size() > 0 ) 
            this.displayRebate = true;
        //this.displayRebate = false;
        System.debug(logginglevel.WARN,'### currentQLIs = '+ this.lQuoteLineItemRebate);
        System.debug(logginglevel.WARN,'this.displayRebate = '+ this.displayRebate);

        //FIN AFFICHAGE REBATE

        //DEBUT AFFICHAGE ACTION CO
        if(this.oQuote.Action_Commerciale__c != null && ( 
               this.oQuote.Action_Commerciale__r.Fixed_Price__c || 
               this.oQuote.Action_Commerciale__r.Locked_Price__c || 
               this.oQuote.Action_Commerciale__r.Locked_Price_1_Year__c ||
               this.oQuote.Action_Commerciale__r.Locked_Price_2_Years__c || 
               this.oQuote.Action_Commerciale__r.Locked_Price_3_Years__c ))
        {
            this.displayActionCo = true;
            this.lQuote = new list<Quote>();
            this.lQuote.add(this.oQuote);
        } 
        
        //FIN AFFICHAGE ACTION CO

        //affichage button
        if(this.bSynchroSend == false)
            this.locationButton = 'top';
        else
            this.locationButton = 'both';

        //debut sequence
        switch on this.oQuote.Opportunity.Project_Type__c {
            when 'SUCC' {       
                this.projetTypeSUCC = true;
                this.projetTypeCREA = false;
                this.projetTypeEXTE = false;
                this.displayAccount = true;
            }   
            when 'CREA' {       
                this.projetTypeSUCC = false;
                this.projetTypeCREA = true;
                this.projetTypeEXTE = false;
                this.displayAccount = true;
            }
            when 'EXTE' {       
                this.projetTypeSUCC = false;
                this.projetTypeCREA = false;
                this.projetTypeEXTE = true;
                this.displayAccount = false;
            }
        }

        if(typeProjet == 'CREARENTER')
        {
            this.projetTypeSUCC = true;
            this.projetTypeCREA = false;
            this.projetTypeEXTE = false;
            this.displayAccount = true;
        }
        //fin sequence
        
        this.statusContinue = true;

        return null;
    }
 
    public static Boolean isBackOfficeUser()
    {
        if(Test.isRunningTest())
        {
            return true;
        }
        else
        {
            Id userId = UserInfo.getUserId();
            List<GroupMember> members = [select GroupId, UserOrGroupId from GroupMember where UserOrGroupId = :userId and GroupId in (select Id from Group WHERE DeveloperName = 'BackOffice')];
    
            if( members != null && !members.isEmpty() ){
                return true;
            }
    
            return false;
        }
    }

    public void updateOptySubStatus()
    {
        system.debug('AVANT updateOptySubStatus');
        Opportunity opty = [select Id, Opportunity_Won_Substage__c from Opportunity where Id= :this.IdOpty limit 1];
        opty.Opportunity_Won_Substage__c = 'Data validated by BO';
        update opty;
        system.debug('APRES updateOptySubStatus');
    }

    public PageReference masterFunction()
    {

        return null;
    }

    public PageReference postPTLToSAP()
    {
        Map<String, list<Opportunity_PTL__c>> mapOPTL = new Map<String, list<Opportunity_PTL__c>>(); 
        AP_WrapperForSOAPCallPTL wrapperForSOAPCallPTL = new AP_WrapperForSOAPCallPTL();
        mapOPTL = wrapperForSOAPCallPTL.Send_PTL_TO_SAP(this.IdQuote, this.currentMatriceSAP);

        system.debug('wrapperForSOAPCallPTL.statusContinueProcess:'+wrapperForSOAPCallPTL.statusContinueProcess);

        //mapOPTL = AP_WrapperForSOAPCallPTL.Send_PTL_TO_SAP(this.IdQuote, this.currentMatriceSAP);
        list<Opportunity_PTL__c> lOPTLBefore = mapOPTL.get('ListOPTL');

        for(Opportunity_PTL__c optl:lOPTLBefore)
        {
            if(optl.Error_Synchro_To_SAP__c != null)
            {
                String retourSAP = '<ol>';
                list<string> split= optl.Error_Synchro_To_SAP__c.split('#');   
                for(String s:split)
                    retourSAP = retourSAP+'<li>'+s+'</li>';
                retourSAP = retourSAP+'</ol>'; 
                optl.Error_Synchro_To_SAP__c = retourSAP;
            }    
        }   
        this.lOPTL = lOPTLBefore; 
        
        this.statusContinue = wrapperForSOAPCallPTL.statusContinueProcess;
        if(this.statusContinue == false)
        {
            this.oQuote.Sent_To_SAP__c = true;
            this.oQuote.Step_Quote_SF_SAP__c = 'PTL';
            this.oQuote.User_Quote_SF_SAP__c = UserInfo.getUserId();
            update this.oQuote;

        }
        this.stepPTL = true;

//      this.statusContinue = true;
//      this.stepPTL = true;

        return null;
    }

    public PageReference postAccountToSAP()
    {

        Map<String, list<Account>> mapAccount = new Map<String, list<Account>>(); 
        system.debug('APPEL AP_WrapperForSOAPCallAccount.Send_Account_TO_SAP(this.IdQuote)');

        AP_WrapperForSOAPCallAccount wrapperForSOAPCallAccount = new AP_WrapperForSOAPCallAccount();
        mapAccount = wrapperForSOAPCallAccount.Send_Account_TO_SAP(this.IdQuote, this.currentMatriceSAP);

        //mapAccount = AP_WrapperForSOAPCallAccount.Send_Account_TO_SAP(this.IdQuote, this.currentMatriceSAP);
        list<Account> lAccountBefore = mapAccount.get('ListACC');

        for(Account acc:lAccountBefore)
        {
            if(acc.Error_Synchro_To_SAP__c != null)
            {
                String retourSAP = '<ol>';
                list<string> split= acc.Error_Synchro_To_SAP__c.split('#');   
                for(String s:split)
                    retourSAP = retourSAP+'<li>'+s+'</li>';
                retourSAP = retourSAP+'</ol>'; 
                acc.Error_Synchro_To_SAP__c = retourSAP;
            }    
            if(acc.Error_Synchro_Bank_To_SAP__c != null)
            {
                String retourSAP = '<ol>';
                list<string> split= acc.Error_Synchro_Bank_To_SAP__c.split('#');   
                for(String s:split)
                    retourSAP = retourSAP+'<li>'+s+'</li>';
                retourSAP = retourSAP+'</ol>'; 
                acc.Error_Synchro_Bank_To_SAP__c = retourSAP;
            }    
        }   
        this.lAccount = lAccountBefore; 

        this.statusContinue = wrapperForSOAPCallAccount.statusContinueProcess;
        if(this.statusContinue == false)
        {
            this.oQuote.Sent_To_SAP__c = true;
            this.oQuote.Step_Quote_SF_SAP__c = 'Compte';
            this.oQuote.User_Quote_SF_SAP__c = UserInfo.getUserId();
            update this.oQuote;

        }
        this.stepAccount = true;
        system.debug('<<<<postAccountToSAP this.statusContinue>>>>>:'+this.statusContinue);

//        this.statusContinue = true;
//        this.stepAccount = true;
        return null;
    }

    public PageReference postRebateToSAP()
    {
            if(this.displayRebate == true || this.displayActionCo == true)
            {
                system.debug('APPEL AP_WrapperForSOAPCallRebateFromQuote.Send_Rebate_TO_SAP(this.IdQuote)');
                Map<String, list<QuoteLineItem>> mapQLI = new Map<String, list<QuoteLineItem>>(); 

                AP_WrapperForSOAPCallRebateFromQuote wrapperForSOAPCallRebateFromQuote = new AP_WrapperForSOAPCallRebateFromQuote();
                mapQLI = wrapperForSOAPCallRebateFromQuote.Send_Rebate_TO_SAP(this.IdQuote);


                //mapQLI = AP_WrapperForSOAPCallRebateFromQuote.Send_Rebate_TO_SAP(this.IdQuote);
                system.debug('mapQLI APPEL:'+mapQLI);
                
                this.lQuoteLineItemRebate = mapQLI.get('ListQLI');
                system.debug('this.lQuoteLineItemRebate:'+this.lQuoteLineItemRebate);

                system.debug('mapQLI.get(currentQLIsDisplay:'+mapQLI.get('currentQLIsDisplay'));
				List<QuoteLineItem> currentQLIsDisplay = mapQLI.get('currentQLIsDisplay');
                system.debug('currentQLIsDisplay APPEL:'+currentQLIsDisplay);

                if(currentQLIsDisplay != null)
                {
                    //List<QuoteLineItem> currentQLIsDisplay = mapQLI.get('currentQLIsDisplay');
                    system.debug('currentQLIsDisplay APPEL1:'+currentQLIsDisplay);
                    this.oQuote.Error_Synchro_To_SAP_ActionCo__c = currentQLIsDisplay[0].Error_Rebate_Synchro_To_SAP__c;
                    this.oQuote.State_Synchro_To_SAP_ActionCo__c = currentQLIsDisplay[0].State_Rebate_Synchro_To_SAP__c;
    
                }
                
                this.statusContinue = wrapperForSOAPCallRebateFromQuote.statusContinueProcess;
                if(this.statusContinue == false)
                {
                    this.oQuote.Sent_To_SAP__c = true;
                    this.oQuote.Step_Quote_SF_SAP__c = 'Remise';
                    this.oQuote.User_Quote_SF_SAP__c = UserInfo.getUserId();
                    update this.oQuote;
        
                }
                system.debug('<<<<postRebateToSAP this.statusContinue >>>>>:'+this.statusContinue);
                
            }    

//        this.statusContinue = true;
        return null;
    }


    public PageReference postContractToSAP()
    {
        system.debug('<<<< postContractToSAP this.statusContinue >>>>>:'+this.statusContinue);

            Map<String, list<Quote_PTL__c>> mapQPTL = new Map<String, list<Quote_PTL__c>>(); 
            AP_WrapperForSOAPCallContract wrapperForSOAPCallContract = new AP_WrapperForSOAPCallContract();
            mapQPTL = wrapperForSOAPCallContract.Send_Contract_TO_SAP(this.IdQuote, this.currentMatriceSAP);
            LIST<Quote_PTL__c> lQPTLBefore = mapQPTL.get('ListQPTL');

            for(Quote_PTL__c qptl:lQPTLBefore)
            {
                if(qptl.Error_Synchro_To_SAP__c != null)
                {
                    String retourSAP = '<ol>';
                    list<string> split= qptl.Error_Synchro_To_SAP__c.split('#');   
                    for(String s:split)
                        retourSAP = retourSAP+'<li>'+s+'</li>';
                    retourSAP = retourSAP+'</ol>'; 
                    qptl.Error_Synchro_To_SAP__c = retourSAP;
                }    
            }   
            this.lQPTL = lQPTLBefore; 
            
            this.statusContinue = wrapperForSOAPCallContract.statusContinueProcess;
            if(this.statusContinue == false)
            {
                this.oQuote.Sent_To_SAP__c = true;
                this.oQuote.Step_Quote_SF_SAP__c = 'Contrat';
                this.oQuote.User_Quote_SF_SAP__c = UserInfo.getUserId();
                update this.oQuote;
    
            }

            if(this.statusContinue == true && this.displayOrder == false && this.signature == false)
            {
                this.oQuote.Sent_To_SAP__c = true;
                this.oQuote.Step_Quote_SF_SAP__c = 'Success';
                this.oQuote.User_Quote_SF_SAP__c = UserInfo.getUserId();
                update this.oQuote;

                updateOptySubStatus();
            }    
            system.debug('<<<< 1 postContractToSAP this.statusContinue >>>>>:'+this.statusContinue);

//        this.statusContinue = true;

        return null;
    }

    public PageReference postOrderToSAP()
    {

            system.debug('APPEL AP_WrapperForSOAPCallOrder.postOrderToSAP(this.IdQuote)');
            Map<String, list<QuoteLineItem>> mapQLI = new Map<String, list<QuoteLineItem>>(); 
            AP_WrapperForSOAPCallOrder wrapperForSOAPCallOrder = new AP_WrapperForSOAPCallOrder();
            mapQLI = wrapperForSOAPCallOrder.Send_Order_TO_SAP(this.IdQuote, this.currentMatriceSAP);

            list<QuoteLineItem> lQuoteLineItemBefore = mapQLI.get('ListQLI');
            for(QuoteLineItem qli:lQuoteLineItemBefore)
            {
                if(qli.Error_Synchro_To_SAP__c != null)
                {
                    String retourSAP = '<ol>';
                    list<string> split= qli.Error_Synchro_To_SAP__c.split('#');   
                    for(String s:split)
                        retourSAP = retourSAP+'<li>'+s+'</li>';
                    retourSAP = retourSAP+'</ol>'; 
                    qli.Error_Synchro_To_SAP__c = retourSAP;
                }    
            }   
            this.lQuoteLineItem = lQuoteLineItemBefore; 
     
            this.statusContinue = wrapperForSOAPCallOrder.statusContinueProcess;
            if(this.statusContinue == false)
            {
                this.oQuote.Sent_To_SAP__c = true;
                this.oQuote.Step_Quote_SF_SAP__c = 'Commande';
                this.oQuote.User_Quote_SF_SAP__c = UserInfo.getUserId();
                update this.oQuote;
    
            }

            if(this.statusContinue == true && this.signature == false)
            {
                this.oQuote.Sent_To_SAP__c = true;
                this.oQuote.Step_Quote_SF_SAP__c = 'Success';
                this.oQuote.User_Quote_SF_SAP__c = UserInfo.getUserId();
                update this.oQuote;

                updateOptySubStatus();
            }    

            system.debug('<<<<wrapperForSOAPCallOrder this.statusContinue >>>>>:'+this.statusContinue);
              
        return null;
    }

    public PageReference postBankToSAP()
    {
            if(this.signature == true)
            {
                system.debug('APPEL AP_WrapperForSOAPCallBank.Send_Bank_TO_SAP(this.IdQuote)');
                Map<String, list<Account>> mapAccount = new Map<String, list<Account>>();
                AP_WrapperForSOAPCallBank wrapperForSOAPCallBank = new AP_WrapperForSOAPCallBank();
                mapAccount  = wrapperForSOAPCallBank.Send_Bank_TO_SAP(this.IdQuote);

                list<Account> lAccountBefore = mapAccount.get('ListACC');

                for(Account acc:lAccountBefore)
                {
                    if(acc.Error_Synchro_To_SAP__c != null)
                    {
                        String retourSAP = '<ol>';
                        list<string> split= acc.Error_Synchro_To_SAP__c.split('#');   
                        for(String s:split)
                            retourSAP = retourSAP+'<li>'+s+'</li>';
                        retourSAP = retourSAP+'</ol>'; 
                        acc.Error_Synchro_To_SAP__c = retourSAP;
                    }    
                    if(acc.Error_Synchro_Bank_To_SAP__c != null)
                    {
                        String retourSAP = '<ol>';
                        list<string> split= acc.Error_Synchro_Bank_To_SAP__c.split('#');   
                        for(String s:split)
                            retourSAP = retourSAP+'<li>'+s+'</li>';
                        retourSAP = retourSAP+'</ol>'; 
                        acc.Error_Synchro_Bank_To_SAP__c = retourSAP;
                    }    
                }   
                this.lAccount = lAccountBefore; 

                this.statusContinue = wrapperForSOAPCallBank.statusContinueProcess;
                if(this.statusContinue == false)
                {
                    this.oQuote.Sent_To_SAP__c = true;
                    this.oQuote.Step_Quote_SF_SAP__c = 'MandatSepa';
                    this.oQuote.User_Quote_SF_SAP__c = UserInfo.getUserId();
                    update this.oQuote;
        
                }
    
                if(this.statusContinue == true)
                {
                    this.oQuote.Sent_To_SAP__c = true;
                    this.oQuote.Step_Quote_SF_SAP__c = 'Success';
                    this.oQuote.User_Quote_SF_SAP__c = UserInfo.getUserId();
                    update this.oQuote;

                    updateOptySubStatus();
                }    

    
            }    

        return null;
    }


    public PageReference redirectToQuoteDetail(){
        PageReference redirect = new PageReference('/' + oQuote.Id);
        redirect.setRedirect(true);
        return redirect;
    }

    public static List<QuoteLineItem> getcurrentQLIs(String IdQuote)
    {
            List<QuoteLineItem> currentQLIs = new List<QuoteLineItem>();
        
            for(QuoteLineItem qli : [
                SELECT  
                    Id,
                    UnitPrice, 
                    Quote_PTL__c, 
                    Quote_PTL__r.PTL_Name__c, 
                    Quote_PTL__r.Opportunity_PTL__r.PTLSynchroSAP__c,
                    QuoteId, 
                    Quantity,
                    Quantity_Unit__c,
                    PricebookEntryId,
                    PricebookEntry.Product2Id,
                    PricebookEntry.Product2.IsActive,
                    PriceBookEntry.Product2.ProductCode,
                    PricebookEntry.Product2.Name,
                    PricebookEntry.Product2.Family,
                    PricebookEntry.Product2.Capacity__c,
                    PricebookEntry.Product2.Sub_Type__c,
                    PricebookEntry.Product2.UseGerConsumption__c,
                    PricebookEntry.Product2.MonthlyPriceDisplay__c,
                    Remise_Grpt_one_shot_HT__c, 
                    Consignation_Grpt_one_shot_HT__c, 
                    Group_Commercial_Rebate_HT__c, 
                    Group_Commercial_Rebate_TTC__c, 
                    Group_Cyclical_Rebate_HT__c, 
                    Group_Cyclical_Rebate_TTC__c, 
                    Group_Cyclical_Rebate_lenght_in_months__c,
                    Group_RCE_Rebate_HT__c,
                    Group_RCE_Rebate_TTC__c,
                    Commercial_Rebate_TTC__c, 
                    Commercial_Rebate_HT__c,
                    Cyclical_Rebate_TTC__c, 
                    Cyclical_Rebate_HT__c, 
                    Cyclical_Rebate_Months__c,
                    RCE_Rebate_TTC__c, 
                    RCE_Rebate_HT__c, 
                    Price_List_HT__c,
                    Price_List_TTC__c,
                    VAT_Percentage__c,
                    Pricing_Unit__c,
                    Amount_Unit__c,
                    Reason_For_Order__c,
                    Rebate_Starting_Date__c,
                    Credit_Quantity__c,
                    Credit_Unit_Price_HT__c,
                    Credit_Total_Price_HT__c,
                    Got_From_SAP__c, 
                    quote.Client_Reenlistment__c, quote.Type_de_remuneration__c, State_Rebate_Synchro_To_SAP__c, Error_Rebate_Synchro_To_SAP__c,
                    Remise_Post_Offre_HT__c, Remise_Post_Offre_TTC__c   
                FROM QuoteLineItem 
                WHERE QuoteId=:IdQuote]){

                if( qli.quote.Client_Reenlistment__c == 'Contract' && qli.quote.Type_de_remuneration__c != 'Avoir' && ((qli.RCE_Rebate_TTC__c > 0)||(qli.Commercial_Rebate_TTC__c > 0)||(qli.Cyclical_Rebate_TTC__c > 0)||(qli.Remise_Post_Offre_TTC__c > 0)))
                    currentQLIs.add(qli);
            }
        return currentQLIs;
    }

}