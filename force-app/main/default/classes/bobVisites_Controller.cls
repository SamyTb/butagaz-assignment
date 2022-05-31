public without sharing class bobVisites_Controller {
//public with sharing class bobVisites_Controller {
    
    Public Static Set<String> LargeItemList = new Set<String>{'BD','G','CB','CP','VB','P','GC'};
    Public Static Set<String> smallItemList = new Set<String>{'BD','G','P'};
    
    @AuraEnabled
    Public Static String getData(String eventId){
        System.debug(eventId);
        Event event = [SELECT id, RecordTypeId, StartDateTime,Objet_GEB__c,type,Description,Description_Actions__c,Description_Miscellaneous__c, WhatId, OwnerId, Validated_Steps__c, Validated__c, Number_Of_Covers_Replaced__c, Number_Of_Banners_Replaced__c, Number_Of_Displays_Replaced__c, Repair_Of_Locks_Or_Displays__c, Other_Actions_Performed__c, CN_Goal__c, Volume_Goal__c, PEC_and_SAP_Adequacy_Checked__c FROM Event WHERE id =: eventId];
        System.debug('EventType : '+ event.type);
        List<Event> futurEvent = [SELECT id, StartDateTime FROM Event Where WhatId = :event.WhatId AND id != :event.id AND StartDateTime > :event.StartDateTime ORDER BY StartDateTime LIMIT 1];
        PTL__c ptl = [SELECT id, Presence_pompiste__c,Service_de_Drive__c, Vente_caisse_centrale__c,Price_Panel__c,Enclos_sur__c,
                      Type_de_presentoir_1__c, Type_de_presentoir_2__c, Type_de_presentoir_3__c, Type_de_presentoir_4__c, Type_de_presentoir_5__c,
                      Nombre_type_de_presentoir_1__c, Nombre_type_de_presentoir_2__c, Nombre_type_de_presentoir_3__c, Nombre_type_de_presentoir_4__c, Nombre_type_de_presentoir_5__c,
                      /*Cover_On_Display_1__c, Cover_On_Display_2__c, Cover_On_Display_3__c, Cover_On_Display_4__c, Cover_On_Display_5__c, 
                      Cover_To_Replace_On_Display_1__c, Cover_To_Replace_On_Display_2__c, Cover_To_Replace_On_Display_3__c, Cover_To_Replace_On_Display_4__c, Cover_To_Replace_On_Display_5__c, */
                      Number_Of_Covers_On_Display_1__c, Number_Of_Covers_On_Display_2__c, Number_Of_Covers_On_Display_3__c, Number_Of_Covers_On_Display_4__c, Number_Of_Covers_On_Display_5__c, 
                      Number_Of_Covers_To_Replace_On_Display_1__c, Number_Of_Covers_To_Replace_On_Display_2__c, Number_Of_Covers_To_Replace_On_Display_3__c, Number_Of_Covers_To_Replace_On_Display_4__c, 
                      Number_Of_Covers_To_Replace_On_Display_5__c,
                      Nombre_de_bandeaux_courts__c, Nombre_de_bandeaux_longs__c, Marques_de_Gaz_vendues__c,
                      label__c, Distributeur_automatique_bouteilles__c, Marques_distributeurs_aut_bouteilles__c, 
                      City_Postal_Code__r.Name, Contact_Marketing__c, Centrale_Number__c, Marques_presentes__c,Vente_de_Gaz_dans_ce_Drive__c,Information_prix__c,
                      Stock_Is_Adapted__c, Location_Is_Optimal__c, /*Store_Relays_Green_Positioning__c,*/ Latest_Merchandising_Checklist_Date__c, Reimplantation_date__c,
                      Number_Of_Short_Banners_To_Replace__c, Number_Of_Short_Banners_To_Install__c, Number_Of_Long_Banners_To_Replace__c, Number_Of_Long_Banners_To_Install__c,
                      PLV_GEB_Vert__c, PLV_GEB_Vert_Check_Date__c, Enseigne__c, Sous_canal__c, Butagaz_Brand_Promotion__c
                      FROM PTL__c WHERE id =: event.WhatId LIMIT 1];
        PTL thisPtl = new PTL();
        thisPtl.ptl = ptl;
        if(ptl.Presence_pompiste__c == null){
            thisptl.PresencePompiste = '';
        }else{
            thisptl.PresencePompiste = ptl.Presence_pompiste__c;
        }
        if(ptl.Enclos_sur__c == null){
            thisPtl.EnclosSur = '';
        }else{
            thisPtl.EnclosSur = ptl.Enclos_sur__c;
        }
        if(ptl.Number_Of_Short_Banners_To_Replace__c == null){
            thisPtl.NbShortBannersToReplace = '';
        }else{
            thisPtl.NbShortBannersToReplace = ptl.Number_Of_Short_Banners_To_Replace__c;
        }
        if(ptl.Number_Of_Short_Banners_To_Install__c == null){
            thisPtl.NbShortBannersToInstall = '';
        }else{
            thisPtl.NbShortBannersToInstall = ptl.Number_Of_Short_Banners_To_Install__c;
        }
        if(ptl.Number_Of_Long_Banners_To_Replace__c == null){
            thisPtl.NbLongBannersToReplace = '';
        }else{
            thisPtl.NbLongBannersToReplace = ptl.Number_Of_Long_Banners_To_Replace__c;
        }
        if(ptl.Number_Of_Long_Banners_To_Install__c == null){
            thisPtl.NbLongBannersToInstall = '';
        }else{
            thisPtl.NbLongBannersToInstall = ptl.Number_Of_Long_Banners_To_Install__c;
        }
        
        system.debug('ptl : '+ptl);
        //Get Promotions
        Data data = new Data();
        data.event = event;
        data.eventId = event.id;
        data.eventType = event.type;
        If(futurEvent.size() > 0){
            nextEvent nextEvent = new nextEvent();
            nextEvent.eventId = futurEvent[0].Id;
            nextEvent.eventDateTime = futurEvent[0].startDateTime;
            data.nextEvent = nextEvent; 
        }
        else{
            nextEvent nextEvent = new nextEvent();
            data.nextEvent = nextEvent;
        }
        data.ptl = thisptl;
        data.presentoirs = getPresentoirs(ptl);
        data.presencePompisteValues = getPicklistValues('PTL__c','Presence_pompiste__c');
        data.challengeValues = getPicklistValues('Phase_PTL__c','Phase__c');
        data.conquestChallengeProductsValues = getPicklistValues('Phase_PTL__c','Conquest_Challenge_Products__c');
        data.enclosSurValues = getPicklistValues('PTL__c','Enclos_sur__c');
        data.presentoirTypeValues = getPicklistValues('PTL__c','Type_de_presentoir_1__c');
        data.presentoirNbCoversOnDisplayValues = getPicklistValues('PTL__c','Number_Of_Covers_On_Display_1__c');
        data.presentoirNbCoversToReplaceOnDisplayValues = getPicklistValues('PTL__c','Number_Of_Covers_To_Replace_On_Display_1__c');
        data.presentoirNbShortBannersToReplaceValues = getPicklistValues('PTL__c','Number_Of_Short_Banners_To_Replace__c');
        data.presentoirNbShortBannersToInstallValues = getPicklistValues('PTL__c','Number_Of_Short_Banners_To_Install__c');
        data.presentoirNbLongBannersToReplaceValues = getPicklistValues('PTL__c','Number_Of_Long_Banners_To_Replace__c');
        data.presentoirNbLongBannersToInstallValues = getPicklistValues('PTL__c','Number_Of_Long_Banners_To_Install__c');
        data.marquesDABValues = getPicklistValues('PTL__c','Marques_distributeurs_aut_bouteilles__c');
        data.marquesPresentes = getPicklistValues('PTL__c','Marques_de_Gaz_vendues__c');
        data.PanneauxPrix = getPicklistValues('PTL__c','Information_prix__c');

        //objMarquesPresentesPtl
        List<objCheckboxButtonGroup> objMarquesPresentesPtl= new List<objCheckboxButtonGroup>();
        Set<String> setMarques_presentes=new Set<String>();
        if(ptl.Marques_de_Gaz_vendues__c != null){
            List<String> listMarques_presentes = ptl.Marques_de_Gaz_vendues__c.split(';');
            setMarques_presentes = new Set<String>(listMarques_presentes);
        }
            
        for (String m :data.marquesPresentes)
        {
            objCheckboxButtonGroup mp = new objCheckboxButtonGroup();
            mp.name = m ;
            if (setMarques_presentes.contains(m))
            {
                mp.selected = true;
            }else{
                mp.selected = false;
            }
            objMarquesPresentesPtl.Add(mp);
        }
        
        data.objMarquesPresentesPtl = objMarquesPresentesPtl;
        
        //objPanneauxPrixPtl
        List<objCheckboxButtonGroup> objPanneauxPrixPtl= new List<objCheckboxButtonGroup>();
        Set<String> setPanneauxPrix=new Set<String>();
        if(ptl.Information_prix__c != null){
            
            List<String> listPanneauxPrix = ptl.Information_prix__c.split(';');
            setPanneauxPrix = new Set<String>(listPanneauxPrix);
        }
   
        for (String p :data.PanneauxPrix)
        {
            objCheckboxButtonGroup pp = new objCheckboxButtonGroup();
            pp.name = p ;
            if (setPanneauxPrix.contains(p))
            {
                pp.selected = true;
            }else{
                pp.selected = false;
            }
            objPanneauxPrixPtl.Add(pp);
        }
       
        data.objPanneauxPrixPtl = objPanneauxPrixPtl;
        
        
        //objMarquesDabPtl
        List<objCheckboxButtonGroup> objMarquesDabPtl= new List<objCheckboxButtonGroup>();
        Set<String> setMarques_dab=new Set<String>();
        if(ptl.Marques_distributeurs_aut_bouteilles__c != null){
            List<String> listMarques_dab = ptl.Marques_distributeurs_aut_bouteilles__c.split(';');
            setMarques_dab = new Set<String>(listMarques_dab);
        }
            
        for (String m :data.marquesDABValues)
        {
            objCheckboxButtonGroup mdab = new objCheckboxButtonGroup();
            mdab.name = m ;
            if (setMarques_dab.contains(m))
            {
                mdab.selected = true;
            }else{
                mdab.selected = false;
            }
            objMarquesDabPtl.Add(mdab);
        }
        
        data.objMarquesDabPtl = objMarquesDabPtl;

        /*
        //objConquestChallengeProducts
        List<objCheckboxButtonGroup> objConquestChallengeProducts= new List<objCheckboxButtonGroup>();
        Set<String> setConquestChallengeProducts=new Set<String>();
        if(challenge.Conquest_Challenge_Products__c != null){
            List<String> listConquestChallengeProducts = challenge.Conquest_Challenge_Products__c.split(';');
            setConquestChallengeProducts = new Set<String>(listConquestChallengeProducts);
        }
            
        for (String c :data.conquestChallengeProductsValues){
            objCheckboxButtonGroup ccp = new objCheckboxButtonGroup();
            ccp.name = c ;
            if (setConquestChallengeProducts.contains(c)){
                ccp.selected = true;
            }else{
                ccp.selected = false;
            }
            objConquestChallengeProducts.Add(ccp);
        }
        
        data.objConquestChallengeProducts = objConquestChallengeProducts;
        */

        data.challengeLabel = SObjectType.Phase_PTL__c.getLabel();
        data.operations = getOperations(ptl.Contact_Marketing__c);
        data.challenges = getChallenges(ptl.id);
        data.InventoryPricing = getInventoryPricing(eventId, ptl.Id, ptl.Centrale_Number__c, ptl.Price_Panel__c);
        data.stockInventory = getStockInventory(eventId, ptl.Id, ptl.Centrale_Number__c, 'Rack');
        data.stockInventoryDAB = getStockInventory(eventId, ptl.Id, ptl.Centrale_Number__c, 'DAB');
        system.debug('### data.stockInventory : ' + data.stockInventory);
        system.debug('### data.stockInventory.competitorsStock : ' + data.stockInventory.competitorsStock);
        system.debug('### data.stockInventoryDAB : ' + data.stockInventoryDAB);
        system.debug('### data.stockInventoryDAB.competitorsStock : ' + data.stockInventoryDAB.competitorsStock);
        system.debug('### data.objMarquesDabPtl : ' + data.objMarquesDabPtl);
        return JSON.serialize(data);
    }
    
    Public static List<Presentoir> getPresentoirs(PTL__c ptl){
        List<Presentoir> presentoirs = new List<Presentoir>();
        if(ptl.Nombre_type_de_presentoir_1__c != null && ptl.Nombre_type_de_presentoir_1__c > 0){
            Presentoir presentoir = new Presentoir();
            presentoir.preType = ptl.Type_de_presentoir_1__c;
            presentoir.preNumber = ptl.Nombre_type_de_presentoir_1__c;
            //presentoir.preCoverOnDisplay = ptl.Cover_On_Display_1__c;
            //presentoir.preCoverToReplaceOnDisplay = ptl.Cover_To_Replace_On_Display_1__c;
            presentoir.preNbCoversOnDisplay = ptl.Number_Of_Covers_On_Display_1__c;
            presentoir.preNbCoversToReplaceOnDisplay = ptl.Number_Of_Covers_To_Replace_On_Display_1__c;
            presentoirs.add(presentoir);
        }
        if(ptl.Nombre_type_de_presentoir_2__c != null && ptl.Nombre_type_de_presentoir_2__c > 0){
            Presentoir presentoir = new Presentoir();
            presentoir.preType = ptl.Type_de_presentoir_2__c;
            presentoir.preNumber = ptl.Nombre_type_de_presentoir_2__c;
            //presentoir.preCoverOnDisplay = ptl.Cover_On_Display_2__c;
            //presentoir.preCoverToReplaceOnDisplay = ptl.Cover_To_Replace_On_Display_2__c;
            presentoir.preNbCoversOnDisplay = ptl.Number_Of_Covers_On_Display_2__c;
            presentoir.preNbCoversToReplaceOnDisplay = ptl.Number_Of_Covers_To_Replace_On_Display_2__c;
            presentoirs.add(presentoir);
        }
        if(ptl.Nombre_type_de_presentoir_3__c != null && ptl.Nombre_type_de_presentoir_3__c > 0){
            Presentoir presentoir = new Presentoir();
            presentoir.preType = ptl.Type_de_presentoir_3__c;
            presentoir.preNumber = ptl.Nombre_type_de_presentoir_3__c;
            //presentoir.preCoverOnDisplay = ptl.Cover_On_Display_3__c;
            //presentoir.preCoverToReplaceOnDisplay = ptl.Cover_To_Replace_On_Display_3__c;
            presentoir.preNbCoversOnDisplay = ptl.Number_Of_Covers_On_Display_3__c;
            presentoir.preNbCoversToReplaceOnDisplay = ptl.Number_Of_Covers_To_Replace_On_Display_3__c;
            presentoirs.add(presentoir);
        }
        if(ptl.Nombre_type_de_presentoir_4__c != null && ptl.Nombre_type_de_presentoir_4__c > 0){
            Presentoir presentoir = new Presentoir();
            presentoir.preType = ptl.Type_de_presentoir_4__c;
            presentoir.preNumber = ptl.Nombre_type_de_presentoir_4__c;
            //presentoir.preCoverOnDisplay = ptl.Cover_On_Display_4__c;
            //presentoir.preCoverToReplaceOnDisplay = ptl.Cover_To_Replace_On_Display_4__c;
            presentoir.preNbCoversOnDisplay = ptl.Number_Of_Covers_On_Display_4__c;
            presentoir.preNbCoversToReplaceOnDisplay = ptl.Number_Of_Covers_To_Replace_On_Display_4__c;
            presentoirs.add(presentoir);
        }
        if(ptl.Nombre_type_de_presentoir_5__c != null && ptl.Nombre_type_de_presentoir_5__c > 0){
            Presentoir presentoir = new Presentoir();
            presentoir.preType = ptl.Type_de_presentoir_5__c;
            presentoir.preNumber = ptl.Nombre_type_de_presentoir_5__c;
            //presentoir.preCoverOnDisplay = ptl.Cover_On_Display_5__c;
            //presentoir.preCoverToReplaceOnDisplay = ptl.Cover_To_Replace_On_Display_5__c;
            presentoir.preNbCoversOnDisplay = ptl.Number_Of_Covers_On_Display_5__c;
            presentoir.preNbCoversToReplaceOnDisplay = ptl.Number_Of_Covers_To_Replace_On_Display_5__c;
            presentoirs.add(presentoir);
        }
        return presentoirs;     
    }
    
    //Get Operations
    Public static List<Operation> getOperations(Id ContactId){
        List<Operation> operations = new List<Operation>();
        List<CampaignMember> campMembers = [SELECT Campaign.Name, Campaign.Id, Status, Commentaires__c FROM campaignMember 
                             WHERE ContactId =: ContactId AND ContactId != null AND Campaign.isActive = True AND HasResponded = False];
        
        Set<id> campaignsId = new Set<id>();
        For(CampaignMember campMember : campMembers){
            campaignsId.add(campMember.Campaign.Id);    
        }
        List<CampaignMemberStatus> campStatusList = [SELECT Label, CampaignId FROM CampaignMemberStatus WHERE CampaignId in: campaignsId];
        
        For(CampaignMember campMember : campMembers){
            Operation ope = new Operation(campMember);
            List<String> statusList = new List<String>();
            For(CampaignMemberStatus campStatus : campStatusList){
                if(campStatus.campaignId == campMember.Campaign.Id) statusList.add(campStatus.Label);   
            }
            ope.selectStatus = statusList;
            ope.status = campMember.status;
            ope.comment = campMember.Commentaires__c;
            operations.add(ope);                       
        }
        return operations;
        
    }
    
    //Get Challenges Commercials (OPCDP)
    Public static List<Phase_PTL__c> getChallenges(Id PTLId){
        List<Phase_PTL__c> challenges = new List<Phase_PTL__c>();
        
        //Map<String,Phase_PTL__c> PhaseChallenge = new Map<String,Phase_PTL__c>();
         List<Phase_PTL__c> oldChallenges = [SELECT id, phase__c, montant_de_la_remise__c, date_debut__c, date_fin__c, Conquest_Challenge_Products__c, Gross_Consignment_Goal__c, Proof_Of_Dereferencing__c, Photo_Of_Gas_Department__c
                              FROM Phase_PTL__c WHERE PTL__c =: PTLId AND date_fin__c >: date.today() ];
        
        if(oldChallenges.size() > 0){
            challenges.addAll(oldChallenges);
        }else{
            Challenges.add(new Phase_PTL__c(Phase__c = '-Aucun-', montant_de_la_remise__c = 0, date_debut__c = date.today(), date_fin__c = date.today(),
                                            Conquest_Challenge_Products__c = '-Aucun-', Proof_Of_Dereferencing__c = false, Photo_Of_Gas_Department__c = false, PTL__c = PTLId));
        }
        
        return Challenges;
    }
    
    //Get inventory Pricing
    Public static InventoryPricing getInventoryPricing(Id EventId, Id ptlId, String centrale, Boolean pricePanel){
        Set<String> itemList = smallItemList;
        if(pricePanel == True) itemList = LargeItemList;
        
        InventoryPricing inventoryPricing = new InventoryPricing();
        
        //Select Competitors list
        List<Brand__c> competitors = new List<Brand__c>();
        Set<Id> competitorsId = new Set<Id>();
        For(Brand__c brand : [SELECT Id, Name__c FROM Brand__c WHERE Display_On_Inventory_Pricing__c = True AND ((Type__c = 'Nationale' and Name__c != 'Butagaz') 
                              OR (Type__c = 'Distributeur' and Centrale__c=: centrale)) ORDER BY Ordre_de_tri__c]){
            
            competitors.add(brand);
            competitorsId.add(brand.Id);
        }
        
        //Create Map ArticlesByCode
        Map<String, Id> articlesByCode = new Map<String, Id>();
        For(Item__c item : [SELECT Id, Code_Article__c FROM Item__c WHERE Code_Article__c in: itemList ]){
            articlesByCode.put(item.Code_Article__c, item.Id);    
        }
        
        //Create Map BrandsByName
        Map<String, Id> brandsByName = new Map<String, Id>();
        For(Brand__c brand : [SELECT Id, Name__c FROM Brand__c]){
            brandsByName.put(brand.Name__c, brand.Id);    
        }
        
        //Create Butagaz Inventory
        List<ArticlePricing> ButagazPricingArticles = new List<ArticlePricing>();
        For(String codeArticle : itemList){
            Inventory_Pricing_Article__c newPricingArticle = new Inventory_Pricing_Article__c();
            newPricingArticle.Article__c = articlesByCode.get(codeArticle);
            
            ArticlePricing article = new ArticlePricing(newPricingArticle);
            article.codeArticle = codeArticle;
            ButagazPricingArticles.add(article); 
        }
        inventoryPricing.butagazPricing = ButagazPricingArticles;
        
        //Create Competitor Inventory
        List<CompetitorPricing> competitorsPricing = new List<CompetitorPricing>();
        For(Brand__c competitor : competitors){
            CompetitorPricing compPricing = new CompetitorPricing(competitor.Name__c);
            Inventory_Pricing_Article__c BD = new Inventory_Pricing_Article__c();
            BD.Article__c = articlesByCode.get('BD');
            Inventory_Pricing_Article__c G = new Inventory_Pricing_Article__c();
            G.Article__c = articlesByCode.get('G');
            Inventory_Pricing_Article__c P = new Inventory_Pricing_Article__c();
            P.Article__c = articlesByCode.get('P');
          
            compPricing.BD = BD;
            compPricing.G = G;
            compPricing.P = P;
            
            if(pricePanel == True){
                Inventory_Pricing_Article__c CB = new Inventory_Pricing_Article__c();
                CB.Article__c = articlesByCode.get('CB');
                Inventory_Pricing_Article__c CP = new Inventory_Pricing_Article__c();
                CP.Article__c = articlesByCode.get('CP');
                Inventory_Pricing_Article__c VB = new Inventory_Pricing_Article__c();
                VB.Article__c = articlesByCode.get('VB');
                Inventory_Pricing_Article__c GC = new Inventory_Pricing_Article__c();
                GC.Article__c = articlesByCode.get('GC');
          
                compPricing.CB = CB;
                compPricing.CP = CP;
                compPricing.VB = VB;
                compPricing.GC = GC;
            }
            competitorsPricing.add(compPricing);
        }
        inventoryPricing.competitorsPricing = competitorsPricing;
        
        /*
         * Prepopulate Pricing & Stock
         */        
        /*//Select installed stock
        List<Butagaz_Stock_Installed__c> butagazStock = [Select id, Article__c, Stock_constate__c,Stock_installe__c from Butagaz_Stock_Installed__c Where PTL__c =: ptlId];

        For(ArticlePricing ButagazPricingArticle : ButagazPricingArticles){
            //set stock
            For(Butagaz_Stock_Installed__c stock : butagazStock){
                system.debug('butagazstock : '+ stock.Article__c + ' ' + stock.Stock_installe__c );
                if(stock.Article__c == ButagazPricingArticle.inventoryPricingArticle.Article__c){
                    if(stock.Stock_installe__c != null){
                        ButagazPricingArticle.inventoryPricingArticle.Bottle_Number__c = stock.Stock_installe__c;
                        ButagazPricingArticle.newStock = stock.Stock_installe__c;
                        ButagazPricingArticle.oldStock = stock.Stock_installe__c;
                        break;
                    }
                }
            }
        }*/
        //Select the more recent inventory pricing
        List<Inventory_Pricing__c> invPricing = [SELECT id FROM Inventory_Pricing__c WHERE PTL__c =: ptlId ORDER BY Inventory_Date__c DESC LIMIT 1];
        
        If(!invPricing.isEmpty()){
            //Loop on Inventory Brand
            //List<CompetitorPricing> competitorsPricing = new List<CompetitorPricing>();   
            For(Inventory_Pricing_Brand__c InvBrand : [SELECT id, Brand__r.Name__c, Presence__c, (SELECT id, Article__r.Code_Article__c, Charging_Price__c, Bottle_Number__c, Inventory_Pricing_Brand__c FROM Inventory_Pricing_Articles__r Where Article__c in: articlesByCode.values()) 
                                                       FROM Inventory_Pricing_Brand__c WHERE Inventory_pricing__c =: invPricing[0].Id
                                                       AND (Brand__c in: competitorsId OR Brand__c =: brandsByName.get('Butagaz'))]){
                
                //Prepolutate prices for Butagaz                                           
                If(InvBrand.Brand__r.Name__c == 'Butagaz'){
                    system.debug('Butagaz Pricing = True');
                    For(ArticlePricing ButagazPricingArticle : ButagazPricingArticles){
                        //set prices
                        For(Inventory_Pricing_Article__c oldArticle : InvBrand.Inventory_Pricing_Articles__r){
                            If(oldArticle.Article__c == ButagazPricingArticle.inventoryPricingArticle.Article__c){
                                ButagazPricingArticle.inventoryPricingArticle.Charging_Price__c = oldArticle.Charging_Price__c;
                                ButagazPricingArticle.price = oldArticle.Charging_Price__c;
                                /*ButagazPricingArticle.inventoryPricingArticle.Bottle_Number__c = 0;*/
                            }
                        }
                        //set stock
                        /*For(Butagaz_Stock_Installed__c stock : butagazStock){
                            system.debug('butagazstock : '+ stock.Article__c + ' ' + stock.Stock_installe__c );
                            if(stock.Article__c == ButagazPricingArticle.inventoryPricingArticle.Article__c){
                                if(stock.Stock_installe__c != null){
                                    ButagazPricingArticle.inventoryPricingArticle.Bottle_Number__c = stock.Stock_installe__c;
                                    ButagazPricingArticle.newStock = stock.Stock_installe__c;
                                    ButagazPricingArticle.oldStock = stock.Stock_installe__c;                                    
                                }    
                            }
                        }*/
                    }
                inventoryPricing.butagazPricing = ButagazPricingArticles;
                //End Propoluate prices for Butagaz     
                
                //Prepoluate prices & stock for Competitors
                }Else{
                    System.debug('Brand : ' + InvBrand.Brand__r.Name__c);
                    For(Inventory_Pricing_Article__c oldArticle : InvBrand.Inventory_Pricing_Articles__r){
                        
                        For(CompetitorPricing compPricing : competitorsPricing){
                            if(compPricing.brand == InvBrand.Brand__r.Name__c){
                                if(invBrand.Presence__c == True) compPricing.enabled = True;
                                //set B Pricing Article
                                if(oldArticle.Article__c == articlesByCode.get('BD')){
                                    compPricing.BD.Charging_Price__c = oldArticle.Charging_Price__c;
                                    compPricing.BD_price = oldArticle.Charging_Price__c;
                                    //compPricing.BD_stock = oldArticle.Bottle_Number__c;
                                }
                                //Set G Pricing Article
                                if(oldArticle.Article__c == articlesByCode.get('G')){
                                    compPricing.G.Charging_Price__c = oldArticle.Charging_Price__c;
                                    compPricing.G_price = oldArticle.Charging_Price__c;
                                    //compPricing.G_stock = oldArticle.Bottle_Number__c;
                                }
                                //Set P Pricing Article
                                if(oldArticle.Article__c == articlesByCode.get('P')){
                                    compPricing.P.Charging_Price__c = oldArticle.Charging_Price__c;
                                    compPricing.P_price = oldArticle.Charging_Price__c;
                                    //compPricing.P_stock = oldArticle.Bottle_Number__c;
                                }
                                
                                if(pricePanel == True){
                                    //set CB Pricing Article
                                    if(oldArticle.Article__c == articlesByCode.get('CB')){
                                        compPricing.CB.Charging_Price__c = oldArticle.Charging_Price__c;
                                        compPricing.CB_price = oldArticle.Charging_Price__c;
                                        //compPricing.CB_stock = oldArticle.Bottle_Number__c;
                                    }
                                    //Set CP Pricing Article
                                    if(oldArticle.Article__c == articlesByCode.get('CP')){
                                        compPricing.CP.Charging_Price__c = oldArticle.Charging_Price__c;
                                        compPricing.CP_price = oldArticle.Charging_Price__c;
                                        //compPricing.CP_stock = oldArticle.Bottle_Number__c;
                                    }
                                    //Set VB Pricing Article
                                    if(oldArticle.Article__c == articlesByCode.get('VB')){
                                        compPricing.VB.Charging_Price__c = oldArticle.Charging_Price__c;
                                        compPricing.VB_price = oldArticle.Charging_Price__c;
                                        //compPricing.VB_stock = oldArticle.Bottle_Number__c;
                                    }
                                    //Set GC Pricing Article
                                    if(oldArticle.Article__c == articlesByCode.get('GC')){
                                        compPricing.GC.Charging_Price__c = oldArticle.Charging_Price__c;
                                        compPricing.GC_price = oldArticle.Charging_Price__c;
                                        //compPricing.GC_stock = oldArticle.Bottle_Number__c;
                                    }   
                                }
                            }
                        }    
                            
                    }
                }//End Prepoluate prices for Competitors
                                                                    
            }//End Loop On Inventory Brand
            inventoryPricing.competitorsPricing = competitorsPricing;
        }
        return inventoryPricing;    
    }


    //Get Stock inventory
    Public static StockInventory getStockInventory(Id EventId, Id ptlId, String centrale, String stockinventoryType){
        Set<String> itemList = LargeItemList;
        
        StockInventory stockInventory = new StockInventory();
        //stockInventory.stockInvType = stockinventoryType;

        //Select Brands list
        List<Brand__c> competitors = new List<Brand__c>();
        Set<Id> competitorsId = new Set<Id>();
        For(Brand__c brand : [SELECT Id, Name__c FROM Brand__c WHERE Display_On_Stock_Inventory__c = True AND (Type__c = 'Nationale' 
                              OR (Type__c = 'Distributeur' and Centrale__c=: centrale)) ORDER BY Ordre_de_tri__c]){
            
            competitors.add(brand);
            competitorsId.add(brand.Id);
        }
        
        //Create Map ArticlesByCode
        Map<String, Id> articlesByCode = new Map<String, Id>();
        For(Item__c item : [SELECT Id, Code_Article__c, Capacity__c FROM Item__c WHERE Code_Article__c in: itemList ]){
            articlesByCode.put(item.Code_Article__c, item.Id);    
        }
        
        //Create Map BrandsByName
        Map<String, Id> brandsByName = new Map<String, Id>();
        For(Brand__c brand : [SELECT Id, Name__c FROM Brand__c]){
            brandsByName.put(brand.Name__c, brand.Id);    
        }

        // Recover Articles information
        list<string> lCdArticles = new list<string>(); // list of External IDs on CS
        list<Item__c> lArticles = new list<Item__c>(); // list of Item__c (will be used for Butagaz_stock_installed)
        
        // Recover items from Custom Settings
        for (GEB_Code_Articles_BTZ__c mapArticles : GEB_Code_Articles_BTZ__c.getAll().values()){
            if(mapArticles.Type__c.toUpperCase() == 'BOUTEILLE'){
                lCdArticles.add(mapArticles.External_ID__c);
            }
        }

        if(lCdArticles.size()>0){
            for(Item__c oArticle:[select id, Name, No_BTZ__c, Code_Article__c, ExternalID__c, Capacity__c from Item__c where ExternalID__c in :lCdArticles or No_BTZ__c=true order by No_BTZ__c limit 1000]){
                lArticles.add(oArticle);
            }
        }

        
        List<StockBrand> competitorsStock = new List<StockBrand>();
        boolean bHasButagazStockInstalled = false;

        if(lArticles.size() > 0){
            // Recover "Butagaz Stock Installed"
            map<Id,decimal> mapButagazStockInstalled = new map<Id,decimal>(); 
            decimal dButagazStockInstalled = null;
            decimal dButagazStockInstalled_10_13 = 0;
            decimal dButagazStockInstalled_5_6 = 0;
            decimal dButagazStockInstalled_35 = 0;
            boolean bButagazPresence = false;
            
            for(Butagaz_Stock_Installed__c oStockInstalled:[select id, Article__c, Article__r.Capacity__c, Stock_installe__c from Butagaz_Stock_Installed__c where PTL__c=:ptlId and Article__c in :lArticles ]){
                mapButagazStockInstalled.put(oStockInstalled.Article__c, oStockInstalled.Stock_installe__c);
            }                   
            
            for(Brand__c oBrand:competitors){
                //Stock_Inventory_Brand__c oSIBrand = new Stock_Inventory_Brand__c(Brand__c=oBrand.Id, Brand__r=oBrand);
                StockBrand compStockBrand = new StockBrand(oBrand.Name__c);

                // Using the list of Items
                for(Item__c oItem : lArticles){
                    // Butagaz Brand : Stock Installed
                    if(oBrand.Name__c.toUpperCase() == 'BUTAGAZ' && stockinventoryType != 'DAB'){
                        dButagazStockInstalled = null;
                        
                        if(mapButagazStockInstalled.containsKey(oItem.Id)){
                            dButagazStockInstalled = mapButagazStockInstalled.get(oItem.Id);
                            if(dButagazStockInstalled != 0){
                                bButagazPresence = true;
                                
                                // Group items by capacity (10-13, 5-6, 35)
                                switch on Integer.valueOf(oItem.Capacity__c) {
                                    when 10, 13 {
                                        dButagazStockInstalled_10_13 += dButagazStockInstalled;
                                    }
                                    when 5, 6 {
                                        dButagazStockInstalled_5_6 += dButagazStockInstalled;
                                    }
                                    when 35 {
                                        dButagazStockInstalled_35 += dButagazStockInstalled;
                                    }
                                    when else {
                                        // It means it's a capacity we don't manage
                                    }
                                }

                            }else{
                                dButagazStockInstalled = null;
                            }
                        }
                        
                        if(bButagazPresence){
                            compStockBrand.enabled = true;
                            bHasButagazStockInstalled = true;
                        }
                        if(oItem.No_BTZ__c==false){
                            compStockBrand.stock_10_13 = dButagazStockInstalled_10_13;
                            compStockBrand.stock_5_6 = dButagazStockInstalled_5_6;
                            compStockBrand.stock_35 = dButagazStockInstalled_35;
                        }                          
                    }else{
                        compStockBrand.enabled = false;
                        dButagazStockInstalled = null;
                    }

                }
                
                competitorsStock.add(compStockBrand);
            }
            stockInventory.competitorsStock = competitorsStock;
        }

        //Select the more recent stock inventory
        List<Stock_Inventory__c> invStock = [SELECT id FROM Stock_Inventory__c WHERE PTL__c =: ptlId AND Type__c =: stockinventoryType ORDER BY Inventory_Date__c DESC LIMIT 1];
        
        if(!invStock.isEmpty()){
            //Loop on Inventory Brand
            for(Stock_Inventory_Brand__c InvBrand : [SELECT id, Brand__r.Name__c, Presence__c, Number_of_Bottle_Slots_10_13__c, Number_of_Bottle_Slots_5_6__c, Number_of_Bottle_Slots_35__c 
                                                       FROM Stock_Inventory_Brand__c WHERE Stock_Inventory__c =: invStock[0].Id
                                                       AND (Brand__c in: competitorsId OR Brand__c =: brandsByName.get('Butagaz'))]){
                
                
                //Prepopulate stock for Competitors
                System.debug('Brand : ' + InvBrand.Brand__r.Name__c);
                for(StockBrand compStock : competitorsStock){
                    if(compStock.brand == InvBrand.Brand__r.Name__c){
                        compStock.enabled = InvBrand.Presence__c;

                        // In case of BUTAGAZ brand (when not DAB), we want the stock installed from SAP and not the stock from the last stock inventory
                        if(InvBrand.Brand__r.Name__c.toUpperCase() == 'BUTAGAZ' && stockinventoryType != 'DAB' && bHasButagazStockInstalled){
                            // Do nothing
                        }else{
                            compStock.stock_10_13 = InvBrand.Number_of_Bottle_Slots_10_13__c;
                            compStock.stock_5_6 = InvBrand.Number_of_Bottle_Slots_5_6__c;
                            compStock.stock_35 = InvBrand.Number_of_Bottle_Slots_35__c;
                        }
                    }
                }//End Prepopulate stocks for Competitors
                                                                    
            }//End Loop On Inventory Brand
            stockInventory.competitorsStock = competitorsStock;
        }
        return stockInventory;    
    }
    
    
    //Save All Data
    @AuraEnabled
    Public Static String saveData(String allData){
        List<String> results = new List<String>();
        system.debug(allData);
        SaveData dataToSave = (SaveData) JSON.deserialize(allData, SaveData.class);
        system.debug(dataToSave);
        system.debug('ptl : '+dataToSave.ptl);
        system.debug('Opérations : ' +dataToSave.operations);
        system.debug('Challenges : ' +dataToSave.challenges);
        system.debug('event : ' + dataToSave.event);
        system.debug('butagazPricing : '+dataToSave.butagazPricing);
        system.debug('competitorsPricing : '+dataToSave.competitorsPricing);
        //system.debug('butagazStocks : '+ dataToSave.butagazStocks);
        system.debug('competitorsStock : '+dataToSave.competitorsStocks);
        system.debug('competitorsStockDAB : '+dataToSave.competitorsStocksDAB);
        system.debug('listPresentoirs : '+dataToSave.presentoirs);
        
        // Erwan 20170703 : Bypass VR before saving
        Boolean originalBypassVRvalue;
        User currentUser = [SELECT Id, Bypass_Validation_Rules__c FROM User WHERE Id =: UserInfo.getUserId()];
        originalBypassVRvalue = currentUser.Bypass_Validation_Rules__c;
        currentUser.Bypass_Validation_Rules__c = True;
        update currentUser;
        
        string operationsResult = saveOperations(dataToSave.operations);
        results.add(operationsResult);
        string challengeResult = saveChallenges(dataToSave.challenges);
        results.add(challengeResult);
        //string invResult = saveInventoryPricing(dataToSave.ptl.ptl.Id, dataToSave.eventId, dataToSave.butagazPricing, dataToSave.competitorsPricing, dataToSave.butagazStocks, dataToSave.competitorsStocks, dataToSave.ptl.ptl.Price_Panel__c);
        string invResult = saveInventoryPricing(dataToSave.ptl.ptl.Id, dataToSave.eventId, dataToSave.butagazPricing, dataToSave.competitorsPricing, /*dataToSave.butagazStocks, dataToSave.competitorsStocks,*/ dataToSave.ptl.ptl.Price_Panel__c);
        results.add(invResult);
        string invStockResult = saveStockInventory(dataToSave.ptl.ptl.Id, dataToSave.ptl.ptl.Enseigne__c, dataToSave.ptl.ptl.Sous_canal__c, dataToSave.ptl.ptl.Distributeur_automatique_bouteilles__c, dataToSave.ptl.ptl.Marques_distributeurs_aut_bouteilles__c, dataToSave.eventId, /*dataToSave.butagazStocks,*/ dataToSave.competitorsStocks, dataToSave.ptl.ptl.Price_Panel__c, 'Rack');
        results.add(invStockResult);
        string invStockResultDAB = saveStockInventory(dataToSave.ptl.ptl.Id, dataToSave.ptl.ptl.Enseigne__c, dataToSave.ptl.ptl.Sous_canal__c, dataToSave.ptl.ptl.Distributeur_automatique_bouteilles__c, dataToSave.ptl.ptl.Marques_distributeurs_aut_bouteilles__c, dataToSave.eventId, /*dataToSave.butagazStocks,*/ dataToSave.competitorsStocksDAB, dataToSave.ptl.ptl.Price_Panel__c, 'DAB');
        results.add(invStockResultDAB);
        string eventResult = saveEvent(dataToSave.event, dataToSave.nextEvent, dataToSave.validate, dataToSave.validatedSteps);
        results.add(eventResult);
        string ptlResult = savePtl(dataToSave.ptl, dataToSave.presentoirs);       
        results.add(ptlResult);
        
        // Erwan 20170703 : Reset Bypass VR to its original value
        currentUser.Bypass_Validation_Rules__c = originalBypassVRvalue;
        update currentUser;
        
        return JSON.serialize(results);
    }
    
    Public static string saveEvent(Event event, nextEvent nextEvent, boolean validate, String validatedSteps){
        
        
        event.Validated__c = validate;
        event.validated_Steps__c = validatedSteps;
        try{
            update event;
            system.debug('nextEvent : ' +nextEvent);
     
            if(nextEvent.eventId != null){
                event eventToUpdate = new Event(Id = nextEvent.eventId);
                if(nextEvent.eventDateTime != null){
                    eventToUpdate.StartDateTime = nextEvent.eventDateTime;
                    eventToUpdate.EndDateTime = nextEvent.eventDateTime;
                }
                system.debug('update next event');
                update eventToUpdate;
            }else if(nextEvent.eventDateTime != null){     
                event newEvent = new event(recordTypeId = event.RecordTypeId, ownerId = event.OwnerId, whatId = event.WhatId,
                                            Objet_GEB__c = event.Objet_GEB__c, Type = event.type, StartDateTime = nextEvent.eventDateTime, EndDateTime = nextEvent.eventDateTime);
                system.debug('insert new next event');
                insert newEvent;
            }
            return 'save event : OK';
        }catch(DMLexception e){
            system.debug('Error saving event : ' + e.getMessage());
            return('save event : KO : Error saving event : ' + e.getMessage());
        }
    }
    
    Public static string savePtl(PTL ptl, List<Presentoir> presentoirs){
        //system.debug(ptl);
        Ptl__c thisPtl = ptl.ptl;
        
        if(presentoirs.size() > 0){
            thisPtl.Type_de_presentoir_1__c = presentoirs[0].preType;
            thisPtl.Nombre_type_de_presentoir_1__c = presentoirs[0].preNumber;
            //thisPtl.Cover_On_Display_1__c = presentoirs[0].preCoverOnDisplay;
            //thisPtl.Cover_To_Replace_On_Display_1__c = presentoirs[0].preCoverToReplaceOnDisplay;
            thisPtl.Number_Of_Covers_On_Display_1__c = presentoirs[0].preNbCoversOnDisplay;
            thisPtl.Number_Of_Covers_To_Replace_On_Display_1__c = presentoirs[0].preNbCoversToReplaceOnDisplay;
        }
        if(presentoirs.size() > 1){
            thisPtl.Type_de_presentoir_2__c = presentoirs[1].preType;
            thisPtl.Nombre_type_de_presentoir_2__c = presentoirs[1].preNumber;
            //thisPtl.Cover_On_Display_2__c = presentoirs[1].preCoverOnDisplay;
            //thisPtl.Cover_To_Replace_On_Display_2__c = presentoirs[1].preCoverToReplaceOnDisplay;
            thisPtl.Number_Of_Covers_On_Display_2__c = presentoirs[1].preNbCoversOnDisplay;
            thisPtl.Number_Of_Covers_To_Replace_On_Display_2__c = presentoirs[1].preNbCoversToReplaceOnDisplay;
        }
        if(presentoirs.size() > 2){
            thisPtl.Type_de_presentoir_3__c = presentoirs[2].preType;
            thisPtl.Nombre_type_de_presentoir_3__c = presentoirs[2].preNumber;
            //thisPtl.Cover_On_Display_3__c = presentoirs[2].preCoverOnDisplay;
            //thisPtl.Cover_To_Replace_On_Display_3__c = presentoirs[2].preCoverToReplaceOnDisplay;
            thisPtl.Number_Of_Covers_On_Display_3__c = presentoirs[2].preNbCoversOnDisplay;
            thisPtl.Number_Of_Covers_To_Replace_On_Display_3__c = presentoirs[2].preNbCoversToReplaceOnDisplay;
        }
        if(presentoirs.size() > 3){
            thisPtl.Type_de_presentoir_4__c = presentoirs[3].preType;
            thisPtl.Nombre_type_de_presentoir_4__c = presentoirs[3].preNumber;
            //thisPtl.Cover_On_Display_4__c = presentoirs[3].preCoverOnDisplay;
            //thisPtl.Cover_To_Replace_On_Display_4__c = presentoirs[3].preCoverToReplaceOnDisplay;
            thisPtl.Number_Of_Covers_On_Display_4__c = presentoirs[3].preNbCoversOnDisplay;
            thisPtl.Number_Of_Covers_To_Replace_On_Display_4__c = presentoirs[3].preNbCoversToReplaceOnDisplay;
        }
        if(presentoirs.size() > 4){
            thisPtl.Type_de_presentoir_5__c = presentoirs[4].preType;
            thisPtl.Nombre_type_de_presentoir_5__c = presentoirs[4].preNumber;
            //thisPtl.Cover_On_Display_5__c = presentoirs[4].preCoverOnDisplay;
            //thisPtl.Cover_To_Replace_On_Display_5__c = presentoirs[4].preCoverToReplaceOnDisplay;
            thisPtl.Number_Of_Covers_On_Display_5__c = presentoirs[4].preNbCoversOnDisplay;
            thisPtl.Number_Of_Covers_To_Replace_On_Display_5__c = presentoirs[4].preNbCoversToReplaceOnDisplay;
        }
        
        if(ptl.EnclosSur != null){
            thisPtl.presence_pompiste__c = ptl.PresencePompiste;
        }
        if(ptl.PresencePompiste != null){
            thisPtl.enclos_sur__c = ptl.enclosSur;
        }
        if(ptl.NbShortBannersToReplace != null){
            thisPtl.Number_Of_Short_Banners_To_Replace__c = ptl.NbShortBannersToReplace;
        }
        if(ptl.NbShortBannersToInstall != null){
            thisPtl.Number_Of_Short_Banners_To_Install__c = ptl.NbShortBannersToInstall;
        }
        if(ptl.NbLongBannersToReplace != null){
            thisPtl.Number_Of_Long_Banners_To_Replace__c = ptl.NbLongBannersToReplace;
        }
        if(ptl.NbLongBannersToInstall != null){
            thisPtl.Number_Of_Long_Banners_To_Install__c = ptl.NbLongBannersToInstall;
        }
        system.debug('### ptl.ptl.Marques_de_Gaz_vendues__c  : ' + ptl.ptl.Marques_de_Gaz_vendues__c);
        if(ptl.ptl.Marques_de_Gaz_vendues__c != null && ptl.ptl.Marques_de_Gaz_vendues__c != ''){
            thisPtl.Vente_de_Gaz_dans_ce_Drive__c = 'OUI';
        }else{
            thisPtl.Vente_de_Gaz_dans_ce_Drive__c = 'NON';
        }
        // if DAB unchecked then we'll empty DAB brands list
        if(ptl.ptl.Distributeur_automatique_bouteilles__c == false){
            thisPtl.Marques_distributeurs_aut_bouteilles__c = null;
        }
            
        try{
            update ptl.ptl;
            return 'save ptl : OK';
        }catch(DMLexception e){
            system.debug('Error saving ptl : ' + e.getMessage());
            return('save ptl : KO : Error saving ptl : ' + e.getMessage());
        }
    }
    
    Public static string saveOperations(List<operation> operations){
        
        List<CampaignMember> campaignsToUpdate = new List<CampaignMember>();
        For(Operation operation : operations){
            system.debug(operation);
            campaignMember campMember = new campaignMember(id = operation.ope.Id);
            campMember.status = operation.status;
            campMember.Commentaires__c = operation.comment;
            //if(operation.refus == True) campMember.status = 'Refus';
            
            campaignsToUpdate.add(campMember);
        }
        if(campaignsToUpdate.size() > 0){
            try{
                system.debug(campaignsToUpdate);
                Database.update(campaignsToUpdate, True);
                //update campaignsToUpdate;
                return 'save operations : OK';
            }catch(DMLexception e){
                return 'save operations : KO : Error update campaignMember : ' +e.getMessage();     
            }
        }else{
             return 'save operations : OK';    
        }
    }
    
    Public static String saveChallenges(list<Phase_PTL__c> challenges){
        System.debug(challenges);
        List<Phase_PTL__c> phasesToUpdate = new List<Phase_PTL__c>();
        For(Phase_PTL__c phase : challenges){
            if(phase.phase__c != '-Aucun-'){
                phasesToUpdate.add(phase);    
            }
        }
        
        if(phasesToUpdate.size() > 0){
            Try{
                System.debug('upsert challenges');
                upsert phasesToUpdate;
                return 'save challenge : OK';
            }Catch(DMLException e){
                system.debug('Error upsert challenges : '+ e.getMessage());
                return('save challenge : KO Error upsert challenges : '+ e.getMessage());
            }
        }
        return 'save challenge : OK';
    }
    
    /*Public static string saveInventoryPricing(Id ptlId, String eventId, List<ArticlePricing> butagazPricing, List<CompetitorPricing> competitorsPricing,
                                              List<ArticlePricing> butagazStock, List<CompetitorPricing> competitorsStock, Boolean pricePanel){*/
    Public static string saveInventoryPricing(Id ptlId, String eventId, List<ArticlePricing> butagazPricing, List<CompetitorPricing> competitorsPricing,
                                            Boolean pricePanel){

        String eventId15 = eventId.substring(0, 15);                                          
        List<Inventory_Pricing__c> oldInv = [SELECT id FROM Inventory_Pricing__c WHERE EventId__c =: eventId15];
        if(oldInv.size() > 0){
            delete oldInv;
        }
         
        //Create Map ArticlesByCode
        Map<String, Id> articlesByCode = new Map<String, Id>();
        For(Item__c item : [SELECT Id, Code_Article__c FROM Item__c WHERE Code_Article__c in: LargeItemList]){
            articlesByCode.put(item.Code_Article__c, item.Id);    
        }
        
        //Create Map BrandsByName
        Map<String, Id> brandsByName = new Map<String, Id>();
        For(Brand__c brand : [SELECT Id, Name__c FROM Brand__c]){
            brandsByName.put(brand.Name__c, brand.Id);    
        }
        
        /*//Manage realStock
        Map<String,Decimal> mapRealStockByArticle = new Map<String, Decimal>();
        For(ArticlePricing butStock : butagazStock){
            mapRealStockByArticle.put(articlesByCode.get(butStock.codeArticle), butStock.newStock);  
        }
        system.debug('mapRealStockByArticle : '+mapRealStockByArticle);                                          
        List<Butagaz_Stock_Installed__c> realStock = [Select id, Article__c, Stock_constate__c,Stock_installe__c from Butagaz_Stock_Installed__c Where PTL__c =: ptlId];
        For(Butagaz_Stock_Installed__c stockInstalled : realStock){
            if(mapRealStockByArticle.containsKey(stockInstalled.Article__c)){
                stockInstalled.Stock_constate__c = mapRealStockByArticle.get(stockInstalled.Article__c);  
            }    
        }*/
        
        //Manage InventoryPricing
        Inventory_Pricing__c newInvPric = new Inventory_Pricing__c();
        newInvPric.Inventory_Date__c = date.today();
        newInvPric.EventId__c = eventId.substring(0, 15);
        newInvPric.PTL__c = ptlId;
        
        //Insert InventoryPricing
        Try{
            system.debug('insert newInvPric');
            insert newInvPric;
            //system.debug('update stock installed');
            //system.debug(realStock);
            //update realStock;
            
            //Create Butagaz Inv Brand
            List<Inventory_Pricing_Brand__c> invBrandToInsert = new List<Inventory_Pricing_Brand__c>();
            Inventory_Pricing_Brand__c newButagazPricing = new Inventory_Pricing_Brand__c();
            newButagazPricing.Brand__c = brandsByName.get('Butagaz');
            newButagazPricing.Inventory_pricing__c = newInvPric.Id;
            invBrandToInsert.add(newButagazPricing);
            
            //Create Competitor Inv Brand
            Map<String,Inventory_Pricing_Brand__c> MapInvBrand = new Map<String,Inventory_Pricing_Brand__c>();
            For(CompetitorPricing compPric : competitorsPricing){
                if(compPric.enabled == True){
                    Inventory_Pricing_Brand__c newBrandPricing = new Inventory_Pricing_Brand__c();
                    newBrandPricing.Brand__c = brandsByName.get(compPric.brand);
                    newBrandPricing.Inventory_pricing__c = newInvPric.Id;
                    MapInvBrand.put(compPric.brand, newBrandPricing);
                    invBrandToInsert.add(newBrandPricing);
                }    
            }    
        
            try{
                
                system.debug('insert list newInvBrand');
                insert invBrandToInsert;
                                
                try{
                    //Create Butagaz Inv Pricing Article
                    List<Inventory_Pricing_Article__c> PricArtList = new List<Inventory_Pricing_Article__c>();
                    For(ArticlePricing artPric : butagazpricing){
                        Inventory_Pricing_Article__c newinvPricArt = artPric.inventoryPricingArticle;
                        newinvPricArt.Inventory_Pricing_Brand__c = newButagazPricing.Id;
                        newinvPricArt.article__c = articlesByCode.get(artPric.codeArticle);
                        newinvPricArt.Charging_Price__c = artPric.price;
                        /*//Set Bottle Number
                        for(ArticlePricing artStock : butagazstock){
                            if(artStock.codeArticle == artPric.codeArticle){
                                newinvPricArt.Bottle_Number__c = artStock.newStock;     
                            }
                        }*/
                        PricArtList.add(newinvPricArt);
                    }
                    
                    //Create Competitor Inv Pricing Article           
                    For(CompetitorPricing compPricing : competitorsPricing){
                        if(compPricing.enabled == true){
                            Id invBrandId = MapInvBrand.get(compPricing.brand).Id;
                            system.debug('invBrandId : '+invBrandId);
                            Inventory_Pricing_Article__c BD = compPricing.BD;
                            BD.Inventory_Pricing_Brand__c = invBrandId;
                            BD.Charging_price__c = compPricing.BD_price;
                            /*BD.Bottle_Number__c = compPricing.BD_stock;*/
                            PricArtList.add(BD);
                            Inventory_Pricing_Article__c G = compPricing.G;
                            G.Inventory_Pricing_Brand__c = invBrandId;
                            G.Charging_price__c = compPricing.G_price;
                            /*G.Bottle_Number__c = compPricing.G_stock;*/
                            PricArtList.add(G);
                            Inventory_Pricing_Article__c P = compPricing.P;
                            P.Inventory_Pricing_Brand__c = invBrandId;
                            P.Charging_price__c = compPricing.P_price;
                            /*P.Bottle_Number__c = compPricing.P_stock;*/
                            PricArtList.add(P);
                            if(pricePanel == true){
                                Inventory_Pricing_Article__c CB = compPricing.CB;
                                CB.Inventory_Pricing_Brand__c = invBrandId;
                                CB.Charging_price__c = compPricing.CB_price;
                                /*CB.Bottle_Number__c = compPricing.CB_stock;*/
                                PricArtList.add(CB);
                                Inventory_Pricing_Article__c CP = compPricing.CP;
                                CP.Inventory_Pricing_Brand__c = invBrandId;
                                CP.Charging_price__c = compPricing.CP_price;
                                /*CP.Bottle_Number__c = compPricing.CP_stock;*/
                                PricArtList.add(CP);
                                Inventory_Pricing_Article__c VB = compPricing.VB;
                                VB.Inventory_Pricing_Brand__c = invBrandId;
                                VB.Charging_price__c = compPricing.VB_price;
                                /*VB.Bottle_Number__c = compPricing.VB_stock;*/
                                PricArtList.add(VB);
                                Inventory_Pricing_Article__c GC = compPricing.GC;
                                GC.Inventory_Pricing_Brand__c = invBrandId;
                                GC.Charging_price__c = compPricing.GC_price;
                                /*GC.Bottle_Number__c = compPricing.GC_stock;*/
                                PricArtList.add(GC);
                            }      
                        }
                        /*
                        For(CompetitorPricing compStock : competitorsStock){
                            if(compStock.brand == compPricing.brand){
                                compPricing.BD.Bottle_Number__c = compStock.BD.Bottle_Number__c;
                                compPricing.G.Bottle_Number__c = compStock.G.Bottle_Number__c;
                                compPricing.P.Bottle_Number__c = compStock.P.Bottle_Number__c;
                                compPricing.CB.Bottle_Number__c = compStock.CB.Bottle_Number__c;
                                compPricing.CP.Bottle_Number__c = compStock.CP.Bottle_Number__c;
                                compPricing.VB.Bottle_Number__c = compStock.VB.Bottle_Number__c;
                                compPricing.GC.Bottle_Number__c = compStock.GC.Bottle_Number__c;
                            }    
                        }*/                        
                    }
                    
                    system.debug('insert newInvArticle');
                    system.debug(PricArtList);
                    insert PricArtList;
                    return  'save invPricing OK';
                }Catch(DMLException e){
                    system.debug('Error insert article pricing : '+e.getMessage()); 
                    return ('save invPricing : KO : Error insert article pricing : '+e.getMessage());
                }
            }Catch(DMLexception e){
                system.debug('Error insert brand pricing : '+e.getMessage());
                return ('save invPricing : KO : Error insert brand pricing : '+e.getMessage());
            }
                
        }Catch(DMLexception e){
            system.debug('Error insert inventory pricing : '+e.getMessage());
            return ('save invPricing : KO : Error insert brand pricing : '+e.getMessage());
        }
    }

    Public static string saveStockInventory(Id ptlId, String Enseigne, String Subchannel, Boolean hasDAB, String marquesDAB, String eventId, List<StockBrand> competitorsStock, Boolean pricePanel, String stockinventoryType){
        
        system.debug('### hasDAB : ' + hasDAB);
        system.debug('### marquesDAB : ' + marquesDAB);
        system.debug('### competitorsStock : ' + competitorsStock);
        
        if( stockinventoryType == 'DAB' && (hasDAB == false || marquesDAB == null) )
            return 'save stockInventory '+stockinventoryType+' : No Stock Inventory To Save';

        // In case of DAB stock inventory we want to create a stock inventory only if MDD brand is selected
        if(stockinventoryType == 'DAB'){
            system.debug('### marquesDAB : ' + marquesDAB);
            string[] tmpMarqueDAB = marquesDAB.split(';');
            boolean createStockInv = false;

            for(string s : tmpMarqueDAB){
                system.debug('### s : ' + s);
                if(s == 'Multimarques (MDD + marques nationales)'){
                    createStockInv = true;
                    break;
                }
            }
            if(!createStockInv)
                return 'save stockInventory '+stockinventoryType+' : No Stock Inventory To Save';
        }

        String eventId15 = eventId.substring(0, 15);                                          
        List<Stock_Inventory__c> oldInv = [SELECT id FROM Stock_Inventory__c WHERE Type__c =: stockinventoryType AND EventId__c =: eventId15];
        if(oldInv.size() > 0){
            delete oldInv;
        }
        
        //Create Map BrandsByName
        Map<String, Id> brandsByName = new Map<String, Id>();
        For(Brand__c brand : [SELECT Id, Name__c FROM Brand__c]){
            brandsByName.put(brand.Name__c, brand.Id);    
        }
        
        //Manage StockInventory
        Stock_Inventory__c newStockInv = new Stock_Inventory__c();
        newStockInv.Inventory_Date__c = date.today();
        newStockInv.EventId__c = eventId.substring(0, 15);
        newStockInv.Type__c = stockinventoryType;
        newStockInv.PTL__c = ptlId;
        
        system.debug('saveStockInventory competitorsStock : ' + competitorsStock);
        //Insert StockInventory
        try{
            system.debug('insert newStockInv');
            insert newStockInv;
            
            //Create Competitor Inv Brand
            List<Stock_Inventory_Brand__c> invBrandToInsert = new List<Stock_Inventory_Brand__c>();
            for(StockBrand compStock : competitorsStock){
                //if(compStock.enabled == True){
                    Stock_Inventory_Brand__c newStockBrand = new Stock_Inventory_Brand__c();
                    newStockBrand.Brand__c = brandsByName.get(compStock.brand);
                    newStockBrand.Stock_Inventory__c = newStockInv.Id;
                    newStockBrand.Number_of_Bottle_Slots_10_13__c = compStock.stock_10_13;
                    newStockBrand.Number_of_Bottle_Slots_5_6__c = compStock.stock_5_6;
                    newStockBrand.Number_of_Bottle_Slots_35__c = compStock.stock_35;
                    newStockBrand.Presence__c = compStock.enabled;

                    invBrandToInsert.add(newStockBrand);
                //}
            }
            
            // Calculate stock share
            calcStockShare(invBrandToInsert, stockinventoryType, Enseigne, Subchannel);

            try{
                system.debug('insert list newInvBrand '+stockinventoryType);
                insert invBrandToInsert;
                return 'save stockInventory '+stockinventoryType+' OK';
            }catch(DMLexception e){
                system.debug('Error insert stock brand '+stockinventoryType+' : '+e.getMessage());
                return ('save stockInventory : KO : Error insert stock brand : '+e.getMessage());
            }
                
        }catch(DMLexception e){
            system.debug('Error insert stock inventory '+stockinventoryType+' : '+e.getMessage());
            return ('save stockInventory : KO : Error insert stock brand : '+e.getMessage());
        }
    }
    
    //Custom Classes
    Public Class SaveData{
        Public String eventId;
        Public Event event;
        Public PTL ptl;
        Public nextEvent nextEvent;
        Public Boolean validate;
        Public String validatedSteps;
        //Public List<ArticlePricing> butagazStocks;
        //Public List<CompetitorPricing> competitorsStocks;
        Public List<StockBrand> competitorsStocks;
        Public List<StockBrand> competitorsStocksDAB;
        Public List<Operation> operations;  
        Public List<Phase_PTL__c> challenges;
        Public List<ArticlePricing> butagazPricing;
        Public List<CompetitorPricing> competitorsPricing;
        Public List<Presentoir> presentoirs; 
        //Public List<objCheckboxButtonGroup> objMarquesPresentesPtl;
        //Public List<objCheckboxButtonGroup> objPanneauxPrixPtl;
        //Public List<objCheckboxButtonGroup> objMarquesDabPtl;
    }
    
    Public Class Data{
        Public String eventId; 
        Public String eventType;
        Public Event event = new Event();
        Public nextEvent nextEvent;
        Public PTL ptl;
        Public String challengeLabel;
        Public List<String> challengeValues;
        Public List<String> conquestChallengeProductsValues;
        Public List<String> presentoirTypeValues;
        Public List<String> presentoirNbCoversOnDisplayValues;
        Public List<String> presentoirNbCoversToReplaceOnDisplayValues;
        Public List<String> presentoirNbShortBannersToReplaceValues;
        Public List<String> presentoirNbShortBannersToInstallValues;
        Public List<String> presentoirNbLongBannersToReplaceValues;
        Public List<String> presentoirNbLongBannersToInstallValues;
        Public List<Presentoir> presentoirs;
        Public List<String> presencePompisteValues;
        Public List<String> enclosSurValues;
        Public List<String> marquesDABValues;
        Public List<String> marquesPresentes;
        Public List<String> PanneauxPrix;
        Public List<objCheckboxButtonGroup> objMarquesPresentesPtl;
        Public List<objCheckboxButtonGroup> objPanneauxPrixPtl;
        Public List<objCheckboxButtonGroup> objMarquesDabPtl;
        Public List<Operation> operations;  
        Public List<Phase_PTL__c> challenges;
        Public InventoryPricing inventoryPricing;
        Public StockInventory stockInventory;
        Public StockInventory stockInventoryDAB;
    }
    
    Public Class nextEvent{
        Public String eventId;
        Public DateTime eventDateTime;
    }
    
    Public Class objCheckboxButtonGroup{
        Public String name;
        Public Boolean selected;
    }
    
    Public Class PTL{
        Public PTL__c ptl;
        Public String PresencePompiste;
        Public String EnclosSur;
        Public String NbShortBannersToReplace;
        Public String NbShortBannersToInstall;
        Public String NbLongBannersToReplace;
        Public String NbLongBannersToInstall;
    }
    
    Public Class Operation{
        Public CampaignMember ope;
        Public String status;
        Public List<String> selectStatus;
        Public String comment;
        
        Public Operation(campaignMember thisOpe){
            ope = thisOpe;
        }
    }
            
    Public Class Challenge{
        Public String name;
        Public Boolean active;
        Public Boolean enabled;
        Public Id phaseId;
        Public Decimal montant = 0;
        Public Date dateDebut = Date.today();
        Public Date dateFin = Date.today();
        Public String conquestChallengeProducts;
        
        Public Challenge(String thisName){
            name = thisName;
        }        
    }
    
    Public Class Presentoir{
        Public String preType;
        Public Decimal preNumber;
        //Public Boolean preCoverOnDisplay;
        //Public Boolean preCoverToReplaceOnDisplay;
        Public String preNbCoversOnDisplay;
        Public String preNbCoversToReplaceOnDisplay;
    }
    
    Public Class InventoryPricing{
        Public List<ArticlePricing> butagazPricing;
        Public List<CompetitorPricing> competitorsPricing;
    }
    
    Public Class CompetitorPricing{
        Public String brand;
        Public Boolean enabled;
        Public Inventory_Pricing_Article__c BD;
        Public decimal BD_Price;
        /*Public decimal BD_Stock;*/
        Public Inventory_Pricing_Article__c G;
        Public decimal G_Price;
        /*Public decimal G_Stock;*/
        Public Inventory_Pricing_Article__c P;
        Public decimal P_Price;
        /*Public decimal P_Stock;*/
        Public Inventory_Pricing_Article__c CB;
        Public decimal CB_Price;
        /*Public decimal CB_Stock;*/
        Public Inventory_Pricing_Article__c CP;
        Public decimal CP_Price;
        /*Public decimal CP_Stock;*/
        Public Inventory_Pricing_Article__c VB;
        Public decimal VB_Price;
        /*Public decimal VB_Stock;*/
        Public Inventory_Pricing_Article__c GC;
        Public decimal GC_Price;
        /*Public decimal GC_Stock;*/
        
        Public CompetitorPricing(String thisBrand){
            brand = thisBrand;
        }
    }
           
    Public Class ArticlePricing{
        Public Inventory_Pricing_Article__c inventoryPricingArticle;
        Public Decimal price = 0;
        Public String codeArticle;
        /*Public Decimal oldStock = 0;
        Public Decimal newStock = 0;*/
        
        Public ArticlePricing(Inventory_Pricing_Article__c pricingArticle){
            inventoryPricingArticle = pricingArticle;
        }
    }

    Public Class StockInventory{
        Public List<StockBrand> competitorsStock;
        //Public String stockInvType;
    }

    Public Class StockBrand{
        //Public Stock_Inventory_Brand__c stockInventoryBrand;
        Public String brand;
        Public Decimal stock_10_13 = 0;
        Public Decimal stock_5_6 = 0;
        Public Decimal stock_35 = 0;
        Public Boolean enabled = false;
        
        Public StockBrand(String stockBrand){
            brand = stockBrand;
        }
    }
    
    
    /*
     * UTILITIES
     */ 
    @AuraEnabled
    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){ 

        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }

        return lstPickvals;
    }    
    
    public static void calcStockShare(List<Stock_Inventory_Brand__c> lSIBrand, String stockinventoryType, String Enseigne, String Subchannel){
        system.debug('### BEGIN-calcStockShare');
        
        Decimal iStockPTL10_13 = 0;
        Decimal iStockPTL5_6 = 0;
        Decimal iStockPTL35 = 0;
        Decimal iStockPTLTotal; // Total stock for the PTL
        
        List<Stock_Inventory_National_Share__c> nationalShares = [select Id, Brand__c, Type__c, Enseigne__c, Sous_canal__c, Stock_Share_10_13__c, Stock_Share_5_6__c, Stock_Share_35__c, Stock_Share_Total__c
                                            from Stock_Inventory_National_Share__c
                                            where Type__c =: stockinventoryType
                                            and ( Enseigne__c =: Enseigne or Sous_canal__c =: Subchannel ) ];

        // Calculate PTL stock share
        if(lSIBrand.size()>0){

            // Reset values for rows with Presence__c == false
            for(Stock_Inventory_Brand__c oSIBrand:lSIBrand){
                if( !oSIBrand.Presence__c ){
                    oSIBrand.Number_of_Bottle_Slots_10_13__c = null;
                    oSIBrand.Number_of_Bottle_Slots_5_6__c = null;
                    oSIBrand.Number_of_Bottle_Slots_35__c = null;
                    oSIBrand.PTL_Stock_Share_10_13__c = null;
                    oSIBrand.PTL_Stock_Share_5_6__c = null;
                    oSIBrand.PTL_Stock_Share_35__c = null;
                    oSIBrand.PTL_Stock_Share_Total__c = null;
                    oSIBrand.Trademark_Stock_Share_10_13__c = null;
                    oSIBrand.Trademark_Stock_Share_5_6__c = null;
                    oSIBrand.Trademark_Stock_Share_35__c = null;
                    oSIBrand.Trademark_Stock_Share_Total__c = null;
                    oSIBrand.Subchannel_Stock_Share_10_13__c = null;
                    oSIBrand.Subchannel_Stock_Share_5_6__c = null;
                    oSIBrand.Subchannel_Stock_Share_35__c = null;
                    oSIBrand.Subchannel_Stock_Share_Total__c = null;
                }
            }

            // Get total per bottle slot
            for(Stock_Inventory_Brand__c oSIBrand:lSIBrand){
                
                if(oSIBrand.Number_of_Bottle_Slots_10_13__c != null) iStockPTL10_13 += oSIBrand.Number_of_Bottle_Slots_10_13__c;
                if(oSIBrand.Number_of_Bottle_Slots_5_6__c != null) iStockPTL5_6 += oSIBrand.Number_of_Bottle_Slots_5_6__c;
                if(oSIBrand.Number_of_Bottle_Slots_35__c != null) iStockPTL35 += oSIBrand.Number_of_Bottle_Slots_35__c;
                system.debug('### oSIBrand.Number_of_Bottle_Slots_10_13__c :' + oSIBrand.Number_of_Bottle_Slots_10_13__c);
                system.debug('### iStockPTL10_13 :' + iStockPTL10_13);
                system.debug('### oSIBrand.Number_of_Bottle_Slots_5_6__c :' + oSIBrand.Number_of_Bottle_Slots_5_6__c);
                system.debug('### iStockPTL5_6 :' + iStockPTL5_6);
            }
            iStockPTLTotal = iStockPTL10_13 + iStockPTL5_6 + iStockPTL35;
            system.debug('### iStockPTLTotal :' + iStockPTLTotal);

            // Calculate share per brand / bottle slot
            for(Stock_Inventory_Brand__c oSIBrand:lSIBrand){
                Decimal iStockTotal = 0;
                
                // Calculate share against 10/13 kg bottle slots
                if(oSIBrand.Number_of_Bottle_Slots_10_13__c != null && iStockPTL10_13 != null & iStockPTL10_13 != 0){
                    oSIBrand.PTL_Stock_Share_10_13__c = (oSIBrand.Number_of_Bottle_Slots_10_13__c / iStockPTL10_13) * 100;
                }
                // Calculate share against 5/6 kg bottle slots
                if(oSIBrand.Number_of_Bottle_Slots_5_6__c != null && iStockPTL5_6 != null & iStockPTL5_6 != 0){
                    oSIBrand.PTL_Stock_Share_5_6__c = (oSIBrand.Number_of_Bottle_Slots_5_6__c / iStockPTL5_6) * 100;
                }
                // Calculate share against 35 kg bottle slots
                if(oSIBrand.Number_of_Bottle_Slots_35__c != null && iStockPTL35 != null & iStockPTL35 != 0){
                    oSIBrand.PTL_Stock_Share_35__c = (oSIBrand.Number_of_Bottle_Slots_35__c / iStockPTL35) * 100;
                }
                // Calculate share against PTL total stock
                if(oSIBrand.Number_of_Bottle_Slots_10_13__c != null) iStockTotal += oSIBrand.Number_of_Bottle_Slots_10_13__c;
                if(oSIBrand.Number_of_Bottle_Slots_5_6__c != null) iStockTotal += oSIBrand.Number_of_Bottle_Slots_5_6__c;
                if(oSIBrand.Number_of_Bottle_Slots_35__c != null) iStockTotal += oSIBrand.Number_of_Bottle_Slots_35__c;
                if(iStockPTLTotal != null & iStockPTLTotal != 0){
                    oSIBrand.PTL_Stock_Share_Total__c = (iStockTotal / iStockPTLTotal) * 100;
                }

                // Put national shares in corresponding fields
                for(Stock_Inventory_National_Share__c oNS:nationalShares){
                    if( oNS.Brand__c == oSIBrand.Brand__c && oSIBrand.Presence__c ){
                        if(oNS.Enseigne__c == Enseigne){
                            oSIBrand.Trademark_Stock_Share_10_13__c = oNS.Stock_Share_10_13__c;
                            oSIBrand.Trademark_Stock_Share_5_6__c = oNS.Stock_Share_5_6__c;
                            oSIBrand.Trademark_Stock_Share_35__c = oNS.Stock_Share_35__c;
                            oSIBrand.Trademark_Stock_Share_Total__c = oNS.Stock_Share_Total__c;
                        }
                        if(oNS.Sous_canal__c == Subchannel){
                            oSIBrand.Subchannel_Stock_Share_10_13__c = oNS.Stock_Share_10_13__c;
                            oSIBrand.Subchannel_Stock_Share_5_6__c = oNS.Stock_Share_5_6__c;
                            oSIBrand.Subchannel_Stock_Share_35__c = oNS.Stock_Share_35__c;
                            oSIBrand.Subchannel_Stock_Share_Total__c = oNS.Stock_Share_Total__c;
                        }
                    }
                }
            }
        }
    }

}