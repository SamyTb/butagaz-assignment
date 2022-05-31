@isTest
public class AP_WrapperForSOAPCallPTL_Test {

    @isTest
    static void AP_WrapperForSOAPCallPTL_Test() 
    {
        System.Debug('### >>>>> testing class AP_WrapperForSOAPCallPTL BEGIN <<<<<');

        matriceSAP currentMatriceSAP = new matriceSAP('CREA', 'V34', 'Construction neuve', '', 'CREA', 'CREA', 'CREA SI CLIENT OPTIMO', 'CREA', '', 'CREA', 'V34', 'V30', 'ZMEP');
		System.Debug('### >>>>> testing class AP_WrapperForSOAPCallCDS_Test <<<<<');
        
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(FirstName='Test', LastName='VFCQLI01',Alias='VFCQLI01',
            Email='VFCQLI01@shell.com',Username='VFCQLI01@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;

        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
            
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


		OrganizationSettings__c setting = new OrganizationSettings__c();
		setting.Account_Dom_RT_Id__c='FLA';
        setting.Account_Pro_RT_Id__c='FLA';
        setting.AES_Endpoint__c='FLA';
        setting.DashboardId_Evolution_CUsages__c='FLA';
        setting.DashboardId_TdB_du_PTL__c='FLA';
        setting.Demande_FieldId_CDS__c='FLA';
        setting.Demande_FieldId_PEC__c='FLA';
        setting.Lead_FieldAddress_AccountStreetType__c='FLA';
        setting.Lead_FieldAddress_ActivityDomain__c='FLA';
        setting.Lead_FieldAddress_MarketType__c='FLA';
        setting.Lead_FieldAddress_ProjectCityPostalCode__c='FLA';
        setting.Lead_FieldAddress_ProjectCountry__c='FLA';
        setting.Lead_FieldAddress_ProjectPlaceCalled__c='FLA';
        setting.Lead_FieldAddress_ProjectPostalBox__c='FLA';
        setting.Lead_FieldAddress_ProjectStreetName__c='FLA';
        setting.Lead_FieldAddress_ProjectStreetNumberExt__c='FLA';
        setting.Lead_FieldAddress_ProjectStreetNumber__c='FLA';
        setting.Lead_FieldAddress_ProjectStreetType__c='FLA';
        setting.Lead_FieldId_ExistingPTL__c='FLA';
        setting.Lead_FieldRecordTypeId__c='FLA';
        setting.Lead_ObjectId__c='FLA';
    	setting.Tons_To_KWH__c  = 13000;
        setting.OptyPTL_FieldPTL__c='FLA';
        setting.PTLConsumptionProfile_ObjectId__c='FLA';
        setting.PTLConsumptionProfile_OpportunityId__c='FLA';
        setting.PTLConsumptionProfile_QuotePTLId__c='FLA';
        setting.Quote_FieldId_Contract_Duration__c='FLA';
        setting.Quote_FieldId_Contract_Duration_old__c='FLA';
        setting.Quote_FieldId_DO_Payment_method_old__c='FLA';
        setting.Quote_FieldId_Facturation_calendar_old__c='FLA';
        setting.Quote_FieldId_Payment_spread_old__c='FLA';
        setting.Quote_FieldId_Product_Scale_old__c='FLA';
        setting.Quote_FieldId_Shipping_Condition_old__c='FLA';
        setting.Quote_FieldId_VAT_Code_old__c='FLA';
        setting.Quote_FieldId_scale_old__c='FLA';
        setting.Quote_ObjectId__c='FLA';
        setting.Lead_Field_ClientType__c='FLA';
        setting.Lead_Field_Predecessor__c='FLA';
        setting.Lead_Field_ProjectType__c='FLA';
        setting.OptyPTL_FieldId_RecordType__c='FLA';
        setting.OptyPTL_RecordTypeId_GEB__c='FLA';
        setting.Opty_FieldId_Billed__c='FLA';
        setting.Opty_FieldId_ClientType__c='FLA';
        setting.Opty_FieldId_Payer__c='FLA';
        setting.ReportId_GeC_GeR_Res_Com_compte_A_A_1__c='FLA';
        setting.RecordTypeId_GEB_Challenge__c='FLA';
        setting.ReportId_GeC_GeR_Res_com_Cpt_c_mois_A_1__c='FLA';
        setting.ReportId_GeC_GeR_Res_Com_Cpt_cum_ch_A_1__c='FLA';
		setting.Lead_FieldAddress_AccountCityPostalCode__c='FLA';
		setting.Lead_FieldAddress_AccountCountry__c='FLA';
		setting.Lead_FieldAddress_AccountPlaceCalled__c='FLA';
		setting.Lead_FieldAddress_AccountPostalBox__c='FLA';
		setting.Lead_FieldAddress_AccountStreetName__c='FLA';
		setting.Lead_FieldAddress_AccountStreetNumberExt__c='FLA';
		setting.Lead_FieldAddress_AccountStreetNumber__c='FLA';
        system.debug('setting:'+setting);
        insert setting;
        system.debug('setting1:'+setting);
        
        System.runAs(u) {
            
            //Mandataire
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;
            
            //code naf
            Code_NAF__c codeNaf = new Code_NAF__c(name = 'codeNaf', ExternalID__c = '10000', Market_Type__c = 'PRO', Market_Sub_Type__c = 'Industrie');
            insert codeNaf;
            system.debug('codeNaf:'+codeNaf);
            
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
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
            
            Account a = new Account(Name='Contact Marketing sales cloud Contact ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                Postal_Code__c = '123', City__c = 'VFCQLI01City', Email__c = 'VFCQLI01City@test.org',Country__c='FR', Phone='0202020202');
            insert a;
            
             // New Contact
            Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing sales cloud',lastName = 'Contact Marketing sales cloud Contact Marketing sales cloud',
            accountId = a.Id,Street_Number__c = a.Street_Number__c,Postal_Box__c = a.Postal_Box__c,
            Postal_Code__c = a.Postal_Code__c,City__c = a.City__c,Email = a.Email__c,Email_2__c = a.Email_2__c,
            Fax = a.Fax,Place_Called__c = a.Place_Called__c,Country__c = a.Country__c,Phone = a.Phone);
            insert c;

            Opportunity opty = new Opportunity();
            opty.Project_Type__c = 'CREA';
            opty.Project_Sub_Type__c = 'V34';
            //opty.Storage_Modification_Reason__c = 'Demande Client';
            opty.Opportunity_Reason__c = 'Construction neuve';
            opty.Assign__c = false;
            opty.DO_Activity_Domain__c = AD_GEC.Id;
        	opty.AccountId = a.Id;
            opty.Name = 'optyFreddy';
            opty.StageName = 'Prospecting';
            opty.CloseDate = Date.newInstance(2022, 01,01);
            opty.Project_market_type__c = 'PRO';
            //opty.Opportunity_Won_Substage__c = 'Finalized by Sales';
            //opty.SyncedQuoteId = q.Id;
            opty.T_Pack__c = 'IDEO';
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
            
            Quote q = new Quote();
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
            
            Map<String, list<Opportunity_PTL__c>> mapOPTL = new Map<String, list<Opportunity_PTL__c>>(); 
    
            Test.setMock(WebServiceMock.class, new AP_WrapperForSOAPCallPTLMock());
            Test.startTest();
            AP_WrapperForSOAPCallPTL WrapperForSOAPCallPTL = new AP_WrapperForSOAPCallPTL();
            mapOPTL = WrapperForSOAPCallPTL.Send_PTL_TO_SAP( q.Id, currentMatriceSAP);
            
            system.debug('mapOPTL:'+mapOPTL);
            Test.stopTest();
            System.Debug('### >>>>> testing class AP_WrapperForSOAPCallPTL END <<<<<');
        }
    }
    
}