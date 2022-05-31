@isTest
public class VFC_Send_Quote_To_SAP_Test {

    public static Quote AP_WrapperForSOAPCallAccount_Test1() 
    {
        System.Debug('### >>>>> testing class AP_WrapperForSOAPCallAccount_Test1 BEGIN <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCQLI01',Alias='VFCQLI01',
            Email='VFCQLI01@shell.com',Username='VFCQLI01@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;

        Quote q = new Quote();
        
        System.runAs(u) {
            
            Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = u.Id);
            insert new List<Custom_Settings__c> { c1 };

            Custom_Settings__c c2 = new Custom_Settings__c (name='Contact_Main_Role',value__c = 'Contact Principal');
            insert new List<Custom_Settings__c> { c2 };

            Custom_Settings__c c3 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 's4abEHNGXpOKCQkFmU6y');
            insert new List<Custom_Settings__c> { c3 };
                
            Custom_Settings__c c4 = new Custom_Settings__c (name='TrackBAPICalls',value__c = 'true');
            insert new List<Custom_Settings__c> { c4 };
                                
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
            
            //code naf
            Code_NAF__c codeNaf = new Code_NAF__c(name = 'codeNaf', ExternalID__c = '10000', Market_Type__c = 'PRO', Market_Sub_Type__c = 'Industrie');
            insert codeNaf;
            system.debug('codeNaf:'+codeNaf);
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne');
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'VFCQLI01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id, Department_Code__c='049');
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFCQLI01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFCQLI01City', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M', Postal_Code__c='49000');
            insert cityCP;
            
            Attache_Commercial__c attCom = new Attache_Commercial__c(Name='attCom', Code_Groupe_Vendeur__c='500');
            insert attCom;      

   
            Account a = new Account(AccountNumber='1122', Mandataire__c=mandataire1.Id, Compte_Superieur__c = 'OPTI2022', Name='Marketing cloud Contact ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Street_N__c='45', Email__c = 'VFCQLI01City@test.org',Country__c='FR', Phone='0202020202',
                City_Postal_Code__c=cityCP.Id, Optin_1__c=true, Optin_2__c=true, Adherent_Central_Number__c = 'Adherent_Central_Number__c',
                Invoicing_Frequency__c='Z1', Lieu_dit__c='fonction quality fonction quality fonction', SEPA_IBAN__c = 'FR', SEPA_CITY__c= 'paris',
                Error_Synchro_To_SAP__c='Error_Synchro_To_SAP__c', Error_Synchro_Bank_To_SAP__c='Error_Synchro_Bank_To_SAP__c');
            insert a;
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Marketing sales cloud',lastName = 'Marketing sales cloud Contact Marketing sales cloud',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;
         
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            update standardPricebook;

            Opportunity opty = new Opportunity();
            opty.Project_Type__c = 'EXTE';
            //opty.Project_Sub_Type__c = 'V34';
            //opty.Storage_Modification_Reason__c = 'Substitution';
            opty.Opportunity_Reason__c = 'Substitution';
            opty.Reason__c = 'V46';
            opty.Assign__c = false;
            opty.DO_Activity_Domain__c = AD_GEC.Id;
            opty.AccountId = a.Id;
            opty.Name = 'optyFreddy';
            opty.StageName = 'Prospecting';
            opty.CloseDate = Date.newInstance(2022, 01,01);
            opty.Project_market_type__c = 'DOM';
            //opty.Opportunity_Won_Substage__c = 'Finalized by Sales';
            //opty.SyncedQuoteId = q.Id;
            opty.T_Pack__c = 'IDEO';
            opty.PA_DO__c=false;
            opty.FA_DO__c=false;
            opty.Contract_Start_Date__c = Date.newInstance(2021, 01,01);
            //opty.Function_quality__c = 'fonction quality fonction quality fonction';
            opty.pricebook2Id = standardPricebook.Id;
            insert opty;
    
            system.debug('freddy class test opty:'+opty);
            
            Opportunity_PTL__c optl = new Opportunity_PTL__c();
            optl.Opportunity__c = opty.Id;
            optl.PTL_Code_NACE__c = codeNaf.Id;
            optl.Code_AC_administrator_New__c = attCom.Id;
            optl.PTL_City_Postal_Code__c = cityCP.Id;
            //String codePostal = optl.PTL_City_Postal_Code__r.Postal_Code__c;
            optl.PTL_Limitation_of_Vehicle__c='P';
            //optl.PTL_Limitation_of_Tonnage__c= true;
            optl.PTL_Street_number__c = '12';
            optl.PTL_Street_name__c = 'street name';
            optl.PTL_Postal_Box__c  = 'boite postal';
            optl.PTL_Shipping_Condition__c = '05';
            optl.Call_client_before_delivery__c = true;
            insert optl;

            system.debug('freddy class test optl:'+optl);
            
            Action_Commerciale__c ac = new Action_Commerciale__c();
            ac.name = 'AC00005';
            ac.Locked_Price_1_Year__c = true;
            ac.Start_Date__c = Date.newInstance(2021,08,01);
            insert ac;
            
            q.Action_Commerciale__c = ac.Id;
            q.DO_Payment_method__c = 'P';
            q.Payment_spread__c = 'Z000';
            //q.IsSyncing = true;
            q.T_LAT_Approved__c = true;
            q.Duree_offre_mois__c = 6;
            q.Date_debut_offre__c = Date.newInstance(2021, 01,01);
            q.Contract_Duration__c = '5';
            q.Name = 'freddy1';
            q.OpportunityId = opty.Id;
            q.ContactId = c.Id;
            q.Scale__c = 'V2GR';
            q.Client_Reenlistment__c = 'Contract';
            q.T_LAT_Approved__c = false;
            insert q;

            system.debug('freddy class test q:'+q);
            
            //Quote_PTL__c qptl = new Quote_PTL__c();  
            Quote_PTL__c qptl = [select Id, Quote__c, Opportunity_PTL__c, Estimated_Consumption__c, RPTL_Purposes__c from Quote_PTL__c where Quote__c= :q.Id limit 1];
            qptl.Estimated_Consumption__c = 1;
            qptl.RPTL_Purposes__c = 'Heating';
            update qptl;

            system.debug('freddy class test qptl:'+qptl);

            PTL_Consumption_Profile__c profilConso = new PTL_Consumption_Profile__c();
            profilConso.Quote_PTL_del__c = qptl.Id;
            profilConso.consumption_variable_jan__c = 0.044;
            profilConso.consumption_variable_feb__c = 0.040;
            profilConso.consumption_variable_mar__c = 0.032;
            profilConso.consumption_variable_apr__c = 0.025;
            profilConso.consumption_variable_may__c = 0;
            profilConso.consumption_variable_jun__c = 0;
            profilConso.consumption_variable_jul__c = 0;
            profilConso.consumption_variable_aug__c = 0;
            profilConso.consumption_variable_sep__c = 0;
            profilConso.consumption_variable_oct__c = 0.016;
            profilConso.consumption_variable_nov__c = 0.033;
            profilConso.consumption_variable_dec__c = 0.042;
            profilConso.consumption_fixed_jan__c = 0;
            profilConso.consumption_fixed_feb__c = 0;
            profilConso.consumption_fixed_mar__c = 0;
            profilConso.consumption_fixed_apr__c = 0;
            profilConso.consumption_fixed_may__c = 0;
            profilConso.consumption_fixed_jun__c = 0;
            profilConso.consumption_fixed_jul__c = 0;
            profilConso.consumption_fixed_aug__c = 0;
            profilConso.consumption_fixed_sep__c = 0;
            profilConso.consumption_fixed_oct__c = 0;
            profilConso.consumption_fixed_nov__c = 0;
            profilConso.consumption_fixed_dec__c = 0;
            insert profilConso;
            
            system.debug('freddy class test profilConso:'+profilConso);
            

            Product2 testProduct = new Product2(Activity_Domain__c=AD_GEC.Id, ProductCode='904P0001', Description='Description', Name='freddy',
                                      Family='Produit', Gaz_type__c='Propane', Sub_Type__c='Citerne');
            insert testProduct;
            Product2 testProduct1 = new Product2(Activity_Domain__c=AD_GEC.Id, ProductCode='904P0001', Description='Description', Name='freddy',
                                      Family='Redevance', Gaz_type__c='Propane', Sub_Type__c='Citerne');
            insert testProduct1;
            
            // Create the PricebookEntry
            PricebookEntry testPbe = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = testProduct.Id,
                UnitPrice = 100,
                IsActive = true
            );
            insert testPbe;           

            QuoteLineItem qli = new QuoteLineItem(Error_Synchro_To_SAP__c='Error_Synchro_To_SAP__c',UnitPrice=12, 
                                                  PricebookEntryId=testPbe.Id, QuoteId=q.Id, Quote_PTL__c=qptl.Id, Product2Id=testProduct.Id, 
                                                  Tank_Placing_Options__c = 'MEP', Quantity=1, RCE_Rebate_TTC__c=2);
            insert qli;
            
            QuoteLineItem qli1 = new QuoteLineItem(Error_Synchro_To_SAP__c='Error_Synchro_To_SAP__c',UnitPrice=12, PricebookEntryId=testPbe.Id, 
                                                   QuoteId=q.Id, Quote_PTL__c=qptl.Id, Product2Id=testProduct1.Id, 
                                                  Tank_Placing_Options__c = 'MEP', Quantity=1, RCE_Rebate_TTC__c=2);
            insert qli1;
            
        }   
        return q;
    }

    public static Quote AP_WrapperForSOAPCallAccount_Test() 
    {
        System.Debug('### >>>>> testing class AP_WrapperForSOAPCallAccount_Test BEGIN <<<<<');

        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCQLI01',Alias='VFCQLI01',
            Email='VFCQLI01@shell.com',Username='VFCQLI01@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;

        Quote q = new Quote();
        
        System.runAs(u) {

            Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = u.Id);
            
            Custom_Settings__c c2 = new Custom_Settings__c (name='Contact_Main_Role',value__c = 'Contact Principal');
            
            Custom_Settings__c c4 = new Custom_Settings__c (name='TrackBAPICalls',value__c = 'true');
            
            Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
            Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
            Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
            Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
            Custom_Settings__c c13 = new Custom_Settings__c (name='Rebate_EndPointURL',value__c = 'https://URLGEC.com/');
            Custom_Settings__c c14 = new Custom_Settings__c (name='Rebate_Username',value__c = 'freddy');
            Custom_Settings__c c15 = new Custom_Settings__c (name='Rebate_Password',value__c = 'pwdfreddy');
                 
            insert new List<Custom_Settings__c> { c1, c2, c4, c9, c10, c11, c12, c13, c14, c15 };

            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
            
            //code naf
            Code_NAF__c codeNaf = new Code_NAF__c(name = 'codeNaf', ExternalID__c = '10000', Market_Type__c = 'PRO', Market_Sub_Type__c = 'Industrie');
            insert codeNaf;
            system.debug('codeNaf:'+codeNaf);
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=2);
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'VFCQLI01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id, Department_Code__c='049');
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFCQLI01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFCQLI01City', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M', Postal_Code__c='49000');
            insert cityCP;
            
            Attache_Commercial__c attCom = new Attache_Commercial__c(Name='attCom', Code_Groupe_Vendeur__c='500');
            insert attCom;      
   
            Account a = new Account(AccountNumber='1122', Compte_Superieur__c = 'OPTI2022', Name='Contact Marketing sales cloud Contact ', 
                Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, SEPA_IBAN__c = 'FR', SEPA_CITY__c= 'paris',
                Street_N__c='45', Email__c = 'VFCQLI01City@test.org',Country__c='FR', Phone='0202020202',
                City_Postal_Code__c=cityCP.Id, Optin_1__c=true, Optin_2__c=true, Adherent_Central_Number__c = 'Adherent_Central_Number__c',
                Invoicing_Frequency__c='Z1', Mandataire__c=mandataire1.Id, 
                Error_Synchro_To_SAP__c='Error_Synchro_To_SAP__c', Error_Synchro_Bank_To_SAP__c='Error_Synchro_Bank_To_SAP__c');//Postal_Code__c = '123', City__c = 'VFCQLI01City', 
            insert a;
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing sales cloud',lastName = 'Contact Marketing sales cloud Contact Marketing sales cloud',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;

            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            update standardPricebook;
            
            Opportunity opty = new Opportunity();
            opty.Project_Type__c = 'CREA';
            opty.Project_Sub_Type__c = 'V34';
            //opty.Storage_Modification_Reason__c = 'Demande Client';
            opty.Opportunity_Reason__c = 'Substitution';
            opty.Reason__c = 'V34';
            opty.Assign__c = false;
            opty.DO_Activity_Domain__c = AD_GEC.Id;
            opty.AccountId = a.Id;
            opty.Name = 'optyFreddy';
            opty.StageName = 'Prospecting';
            opty.CloseDate = Date.newInstance(2021, 01,01);
            opty.Project_market_type__c = 'PRO';
            //opty.Opportunity_Won_Substage__c = 'Finalized by Sales';
            //opty.SyncedQuoteId = q.Id;
            opty.T_Pack__c = 'IDEO';
            opty.PA_DO__c=false;
            opty.FA_DO__c=false;
            opty.Contract_Start_Date__c = Date.newInstance(2021, 01,01);
            opty.pricebook2Id = standardPricebook.Id;
            insert opty;
    
            system.debug('freddy class test opty:'+opty);
            
            Opportunity_PTL__c optl = new Opportunity_PTL__c();
            optl.Opportunity__c = opty.Id;
            optl.PTL_Code_NACE__c = codeNaf.Id;
            optl.Code_AC_administrator_New__c = attCom.Id;
            optl.PTL_City_Postal_Code__c = cityCP.Id;
            //String codePostal = optl.PTL_City_Postal_Code__r.Postal_Code__c;
            optl.PTL_Limitation_of_Vehicle__c='P';
            //optl.PTL_Limitation_of_Tonnage__c= true;
            optl.PTL_Street_number__c = '12';
            optl.PTL_Street_name__c = 'street name';
            optl.PTL_Postal_Box__c  = 'boite postal';
            optl.PTL_Shipping_Condition__c = '05';
            optl.Call_client_before_delivery__c = true;
            insert optl;

            system.debug('freddy class test optl:'+optl);
            
            Action_Commerciale__c ac = new Action_Commerciale__c();
            ac.name = 'AC00005';
            ac.Locked_Price__c = true;
            ac.Start_Date__c = Date.newInstance(2021,08,01);
            insert ac;
            
            q.Action_Commerciale__c = ac.Id;
            q.DO_Payment_method__c = 'P';
            q.Payment_spread__c = 'Z000';
            //q.IsSyncing = true;
            q.T_LAT_Approved__c = true;
            q.Duree_offre_mois__c = 6;
            q.Date_debut_offre__c = Date.newInstance(2021, 01,01);
            q.Contract_Duration__c = '5';
            q.Name = 'freddy1';
            q.OpportunityId = opty.Id;
            q.ContactId = c.Id;
            q.Scale__c = '2G';
            q.Pricebook2Id = opty.Pricebook2Id;
            q.Client_Reenlistment__c = 'Contract'; 
            q.Sent_To_SAP__c = true;
            insert q;

            system.debug('freddy class test q:'+q);
            
            //Quote_PTL__c qptl = new Quote_PTL__c();  
            Quote_PTL__c qptl = [select Id, Quote__c, Opportunity_PTL__c, Estimated_Consumption__c, RPTL_Purposes__c from Quote_PTL__c where Quote__c= :q.Id limit 1];
            qptl.Estimated_Consumption__c = 1;
            qptl.RPTL_Purposes__c = 'Heating';
            update qptl;

            system.debug('freddy class test qptl:'+qptl);

            PTL_Consumption_Profile__c profilConso = new PTL_Consumption_Profile__c();
            profilConso.Quote_PTL_del__c = qptl.Id;
            profilConso.consumption_variable_jan__c = 0.044;
            profilConso.consumption_variable_feb__c = 0.040;
            profilConso.consumption_variable_mar__c = 0.032;
            profilConso.consumption_variable_apr__c = 0.025;
            profilConso.consumption_variable_may__c = 0;
            profilConso.consumption_variable_jun__c = 0;
            profilConso.consumption_variable_jul__c = 0;
            profilConso.consumption_variable_aug__c = 0;
            profilConso.consumption_variable_sep__c = 0;
            profilConso.consumption_variable_oct__c = 0.016;
            profilConso.consumption_variable_nov__c = 0.033;
            profilConso.consumption_variable_dec__c = 0.042;
            profilConso.consumption_fixed_jan__c = 0;
            profilConso.consumption_fixed_feb__c = 0;
            profilConso.consumption_fixed_mar__c = 0;
            profilConso.consumption_fixed_apr__c = 0;
            profilConso.consumption_fixed_may__c = 0;
            profilConso.consumption_fixed_jun__c = 0;
            profilConso.consumption_fixed_jul__c = 0;
            profilConso.consumption_fixed_aug__c = 0;
            profilConso.consumption_fixed_sep__c = 0;
            profilConso.consumption_fixed_oct__c = 0;
            profilConso.consumption_fixed_nov__c = 0;
            profilConso.consumption_fixed_dec__c = 0;
            insert profilConso;
            
            system.debug('freddy class test profilConso:'+profilConso);
            
            Product2 testProduct = new Product2(Activity_Domain__c=AD_GEC.Id, ProductCode='904P0001', Description='Description', Name='freddy',
                                      Family='Produit', Gaz_type__c='Propane', Sub_Type__c='Citerne');
            insert testProduct;
            Product2 testProduct1 = new Product2(Activity_Domain__c=AD_GEC.Id, ProductCode='904P0001', Description='Description', Name='freddy',
                                      Family='Redevance', Gaz_type__c='Propane', Sub_Type__c='Citerne');
            insert testProduct1;
            
            
            // Create the PricebookEntry
            PricebookEntry testPbe = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = testProduct.Id,
                UnitPrice = 100,
                IsActive = true
            );
            insert testPbe;           

            QuoteLineItem qli = new QuoteLineItem(Error_Synchro_To_SAP__c='Error_Synchro_To_SAP__c',UnitPrice=12, PricebookEntryId=testPbe.Id, QuoteId=q.Id, Quote_PTL__c=qptl.Id, Product2Id=testProduct.Id, 
                                                  Tank_Placing_Options__c = 'MEP', Quantity=1, RCE_Rebate_TTC__c=2);
            insert qli;
            QuoteLineItem qli1 = new QuoteLineItem(Error_Synchro_To_SAP__c='Error_Synchro_To_SAP__c',UnitPrice=12, PricebookEntryId=testPbe.Id, 
                                                   QuoteId=q.Id, Quote_PTL__c=qptl.Id, Product2Id=testProduct1.Id, 
                                                  Tank_Placing_Options__c = 'MEP', Quantity=1, RCE_Rebate_TTC__c=2);
            insert qli1;
            
            
            
        }   
        return q;
    }
    
    public static Quote AP_WrapperForSOAPCallAccount_Test2() 
    {
        System.Debug('### >>>>> testing class AP_WrapperForSOAPCallAccount_Test BEGIN <<<<<');

        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCQLI01',Alias='VFCQLI01',
            Email='VFCQLI01@shell.com',Username='VFCQLI01@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;

        Quote q = new Quote();
        
        System.runAs(u) {

            Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = u.Id);
            
            Custom_Settings__c c2 = new Custom_Settings__c (name='Contact_Main_Role',value__c = 'Contact Principal');
            
            Custom_Settings__c c4 = new Custom_Settings__c (name='TrackBAPICalls',value__c = 'true');
            
            Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
            Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
            Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
            Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
            Custom_Settings__c c13 = new Custom_Settings__c (name='Rebate_EndPointURL',value__c = 'https://URLGEC.com/');
            Custom_Settings__c c14 = new Custom_Settings__c (name='Rebate_Username',value__c = 'freddy');
            Custom_Settings__c c15 = new Custom_Settings__c (name='Rebate_Password',value__c = 'pwdfreddy');
                 
            insert new List<Custom_Settings__c> { c1, c2, c4, c9, c10, c11, c12, c13, c14, c15 };

            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
            
            //code naf
            Code_NAF__c codeNaf = new Code_NAF__c(name = 'codeNaf', ExternalID__c = '10000', Market_Type__c = 'PRO', Market_Sub_Type__c = 'Industrie');
            insert codeNaf;
            system.debug('codeNaf:'+codeNaf);
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne', ExternalID__c=2);
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'VFCQLI01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id, Department_Code__c='049');
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFCQLI01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFCQLI01City', 
                City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M', Postal_Code__c='49000');
            insert cityCP;
            
            Attache_Commercial__c attCom = new Attache_Commercial__c(Name='attCom', Code_Groupe_Vendeur__c='500');
            insert attCom;      
   
            Account predecesseur = new Account(AccountNumber='112211', Compte_Superieur__c = 'OPTI2022', Name='Contact eting sales cloud Contact ', 
                Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Street_N__c='45', Email__c = 'VFCQLI01City@test.org',Country__c='FR', Phone='0202020202',
                City_Postal_Code__c=cityCP.Id, Optin_1__c=true, Optin_2__c=true, Adherent_Central_Number__c = 'Adherent_Central_Number__c',
                Invoicing_Frequency__c='Z1', Mandataire__c=mandataire1.Id, Error_Synchro_To_SAP__c='Error_Synchro_To_SAP__c', Error_Synchro_Bank_To_SAP__c='Error_Synchro_Bank_To_SAP__c');//Postal_Code__c = '123', City__c = 'VFCQLI01City', 
            insert predecesseur;

            Account a = new Account(Predecessor__c=predecesseur.Id, AccountNumber='1122', Compte_Superieur__c = 'OPTI2022', Name='Contact Marketing sales cloud Contact ', 
                Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Street_N__c='45', Email__c = 'VFCQLI01City@test.org',Country__c='FR', Phone='0202020202',
                City_Postal_Code__c=cityCP.Id, Optin_1__c=true, Optin_2__c=true, Adherent_Central_Number__c = 'Adherent_Central_Number__c',
                Invoicing_Frequency__c='Z1', SEPA_IBAN__c = 'FR', SEPA_CITY__c= 'paris', Mandataire__c=mandataire1.Id, Error_Synchro_To_SAP__c='Error_Synchro_To_SAP__c', Error_Synchro_Bank_To_SAP__c='Error_Synchro_Bank_To_SAP__c');//Postal_Code__c = '123', City__c = 'VFCQLI01City', 
            insert a;
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing sales cloud',lastName = 'Contact Marketing sales cloud Contact Marketing sales cloud',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;

            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            update standardPricebook;
            
            Opportunity opty = new Opportunity();
            opty.Project_Type__c = 'SUCC';
            opty.Project_Sub_Type__c = 'V36';
            opty.Opportunity_Reason__c = 'Aucun';
            //opty.Storage_Modification_Reason__c = 'Demande Client';
            opty.Reason__c = 'V36';

            opty.Assign__c = false;
            opty.DO_Activity_Domain__c = AD_GEC.Id;
            opty.AccountId = a.Id;
            opty.Name = 'optyFreddy';
            opty.StageName = 'Prospecting';
            //opty.startdate = Date.newInstance(2022, 01,01);
            opty.CloseDate = Date.newInstance(2022, 01,01);
            opty.Project_market_type__c = 'PRO';
            //opty.Opportunity_Won_Substage__c = 'Finalized by Sales';
            //opty.SyncedQuoteId = q.Id;
            opty.T_Pack__c = 'IDEO';
            opty.PA_DO__c=false;
            opty.FA_DO__c=false;
            opty.Contract_Start_Date__c = Date.newInstance(2021, 01,01);
            opty.pricebook2Id = standardPricebook.Id;
            opty.Predecessor__c=predecesseur.Id;
            opty.pricebook2Id = standardPricebook.Id;
            insert opty;
    
            system.debug('freddy class test opty:'+opty);
            
            Opportunity_PTL__c optl = new Opportunity_PTL__c();
            optl.Opportunity__c = opty.Id;
            optl.PTL_Code_NACE__c = codeNaf.Id;
            optl.Code_AC_administrator_New__c = attCom.Id;
            optl.PTL_City_Postal_Code__c = cityCP.Id;
            //String codePostal = optl.PTL_City_Postal_Code__r.Postal_Code__c;
            optl.PTL_Limitation_of_Vehicle__c='P';
            //optl.PTL_Limitation_of_Tonnage__c= true;
            optl.PTL_Street_number__c = '12';
            optl.PTL_Street_name__c = 'street name';
            optl.PTL_Postal_Box__c  = 'boite postal';
            optl.PTL_Shipping_Condition__c = '05';
            optl.Call_client_before_delivery__c = true;
            optl.Error_Synchro_To_SAP__c = 'Error_Synchro_To_SAP__c';
            insert optl;

            system.debug('freddy class test optl:'+optl);
            
            Action_Commerciale__c ac = new Action_Commerciale__c();
            ac.name = 'AC00005';
			ac.Fixed_Price__c = true;
            ac.Locked_Price__c = true;
            ac.Start_Date__c = Date.newInstance(2021,08,01);
            insert ac;
            
            q.Action_Commerciale__c = ac.Id;
            q.DO_Payment_method__c = 'P';
            q.Payment_spread__c = 'Z000';
            //q.IsSyncing = true;
            q.T_LAT_Approved__c = true;
            q.Duree_offre_mois__c = 6;
            q.Date_debut_offre__c = Date.newInstance(2021, 01,01);
            q.Contract_Duration__c = '5';
            q.Name = 'freddy1';
            q.OpportunityId = opty.Id;
            q.ContactId = c.Id;
            q.Scale__c = '2G';
            q.Pricebook2Id = opty.Pricebook2Id;
            q.Client_Reenlistment__c = 'Contract'; 
            insert q;

            system.debug('freddy class test q:'+q);
            
            //Quote_PTL__c qptl = new Quote_PTL__c();  
            Quote_PTL__c qptl = [select Id, Quote__c, Opportunity_PTL__c, Estimated_Consumption__c, RPTL_Purposes__c from Quote_PTL__c where Quote__c= :q.Id limit 1];
            qptl.Estimated_Consumption__c = 1;
            qptl.RPTL_Purposes__c = 'Heating';
            qptl.Error_Synchro_To_SAP__c = 'Error_Synchro_To_SAP__c';
            update qptl;

            system.debug('freddy class test qptl:'+qptl);

            PTL_Consumption_Profile__c profilConso = new PTL_Consumption_Profile__c();
            profilConso.Quote_PTL_del__c = qptl.Id;
            profilConso.consumption_variable_jan__c = 0.044;
            profilConso.consumption_variable_feb__c = 0.040;
            profilConso.consumption_variable_mar__c = 0.032;
            profilConso.consumption_variable_apr__c = 0.025;
            profilConso.consumption_variable_may__c = 0;
            profilConso.consumption_variable_jun__c = 0;
            profilConso.consumption_variable_jul__c = 0;
            profilConso.consumption_variable_aug__c = 0;
            profilConso.consumption_variable_sep__c = 0;
            profilConso.consumption_variable_oct__c = 0.016;
            profilConso.consumption_variable_nov__c = 0.033;
            profilConso.consumption_variable_dec__c = 0.042;
            profilConso.consumption_fixed_jan__c = 0;
            profilConso.consumption_fixed_feb__c = 0;
            profilConso.consumption_fixed_mar__c = 0;
            profilConso.consumption_fixed_apr__c = 0;
            profilConso.consumption_fixed_may__c = 0;
            profilConso.consumption_fixed_jun__c = 0;
            profilConso.consumption_fixed_jul__c = 0;
            profilConso.consumption_fixed_aug__c = 0;
            profilConso.consumption_fixed_sep__c = 0;
            profilConso.consumption_fixed_oct__c = 0;
            profilConso.consumption_fixed_nov__c = 0;
            profilConso.consumption_fixed_dec__c = 0;
            insert profilConso;
            
            system.debug('freddy class test profilConso:'+profilConso);
            
            Product2 testProduct = new Product2(Activity_Domain__c=AD_GEC.Id, ProductCode='904P0001', Description='Description', Name='freddy',
                                      Family='Produit', Gaz_type__c='Propane', Sub_Type__c='Citerne');
            insert testProduct;
            Product2 testProduct1 = new Product2(Activity_Domain__c=AD_GEC.Id, ProductCode='904P0001', Description='Description', Name='freddy',
                                      Family='Redevance', Gaz_type__c='Propane', Sub_Type__c='Citerne');
            insert testProduct1;

            // Create the PricebookEntry
            PricebookEntry testPbe = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = testProduct.Id,
                UnitPrice = 100,
                IsActive = true
            );
            insert testPbe;           

            QuoteLineItem qli = new QuoteLineItem(UnitPrice=12, PricebookEntryId=testPbe.Id, QuoteId=q.Id, Quote_PTL__c=qptl.Id, Product2Id=testProduct.Id, 
                                                  Tank_Placing_Options__c = 'MEP', Quantity=1, RCE_Rebate_TTC__c=2);
            insert qli;
            QuoteLineItem qli1 = new QuoteLineItem(Error_Synchro_To_SAP__c='Error_Synchro_To_SAP__c',UnitPrice=12, PricebookEntryId=testPbe.Id, 
                                                   QuoteId=q.Id, Quote_PTL__c=qptl.Id, Product2Id=testProduct1.Id, 
                                                  Tank_Placing_Options__c = 'MEP', Quantity=1, RCE_Rebate_TTC__c=2);
            insert qli1;
            
            
        }   
        return q;
    }

    @isTest static void Test2() 
    {
        Quote q = AP_WrapperForSOAPCallAccount_Test2(); 
        ApexPages.StandardController controller;
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', q.Id);
        VFC_Send_Quote_To_SAP  testAccPlan = new VFC_Send_Quote_To_SAP(controller);
        testAccPlan.init();
        testAccPlan.init();
        testAccPlan.signature = true;
        testAccPlan.bSynchroSend = true;
        testAccPlan.ibanFrench = true;
		PageReference pageRef = testAccPlan.postPTLToSAP();
		PageReference pageRef1 = testAccPlan.postAccountToSAP();
		PageReference pageRef2 = testAccPlan.postRebateToSAP();
		//PageReference pageRef3 = testAccPlan.postContractToSAP();
		PageReference pageRef4 = testAccPlan.postOrderToSAP();
        PageReference pageRef5 = testAccPlan.postBankToSAP();
        PageReference pageRef6 = testAccPlan.redirectToQuoteDetail();
        testAccPlan.updateOptySubStatus();
        PageReference pageRef7 = testAccPlan.masterFunction();

        Test.stopTest();

    }

    @isTest static void Test1() 
    {
        Quote q = AP_WrapperForSOAPCallAccount_Test1(); 
        ApexPages.StandardController controller;
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', q.Id);
        VFC_Send_Quote_To_SAP  testAccPlan = new VFC_Send_Quote_To_SAP(controller);
        testAccPlan.init();
        testAccPlan.init();
        testAccPlan.signature = true;
        testAccPlan.bSynchroSend = true;
        testAccPlan.ibanFrench = true;
		PageReference pageRef = testAccPlan.postPTLToSAP();
		PageReference pageRef1 = testAccPlan.postAccountToSAP();
		PageReference pageRef2 = testAccPlan.postRebateToSAP();
		//PageReference pageRef3 = testAccPlan.postContractToSAP();
		PageReference pageRef4 = testAccPlan.postOrderToSAP();
        PageReference pageRef5 = testAccPlan.postBankToSAP();
        PageReference pageRef6 = testAccPlan.redirectToQuoteDetail();
        testAccPlan.updateOptySubStatus();
        PageReference pageRef7 = testAccPlan.masterFunction();

        Test.stopTest();

    }

    @isTest static void Test() 
    {
        Quote q = AP_WrapperForSOAPCallAccount_Test(); 
        ApexPages.StandardController controller;
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', q.Id);
        VFC_Send_Quote_To_SAP  testAccPlan = new VFC_Send_Quote_To_SAP(controller);
        testAccPlan.init();
        testAccPlan.signature = true;
        testAccPlan.bSynchroSend = true;
        testAccPlan.ibanFrench = true;
		PageReference pageRef = testAccPlan.postPTLToSAP();
		PageReference pageRef1 = testAccPlan.postAccountToSAP();
		PageReference pageRef2 = testAccPlan.postRebateToSAP();
		//PageReference pageRef3 = testAccPlan.postContractToSAP();
		PageReference pageRef4 = testAccPlan.postOrderToSAP();
        PageReference pageRef5 = testAccPlan.postBankToSAP();
        PageReference pageRef6 = testAccPlan.redirectToQuoteDetail();
        testAccPlan.updateOptySubStatus();
        PageReference pageRef7 = testAccPlan.masterFunction();
        
        Test.stopTest();

    }


}