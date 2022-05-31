@isTest
public class Schedule_Batch_Updating_PickLists_Test {
    public static testmethod void fieldAreChecked() {
        Batch_Updating_PickLists iBatch = new Batch_Updating_PickLists();
        
        Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
         insert mandataire1;
         
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        Canton__c Canton1 = new Canton__c(name = 'SBUP Canton', INSEE_Code__c = '-_-_', Mandataire__c = mandataire1.id);
        insert Canton1;
        
        City__c City1  = new City__c (Name = 'SBUP City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
        insert City1;
        City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - SBUPCity', 
            City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
        insert cityCP;
        
        // Account
        Account compte = new Account(name = 'Test Account', En_cours_d_immatriculation__c = true, No_E_mail__c = true,Country__c='FR', Phone='0202020202');
        insert compte;
        
        // New Contact
        Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
	        accountId = compte.Id,Street_Number__c = compte.Street_Number__c,Postal_Box__c = compte.Postal_Box__c,
	        Postal_Code__c = compte.Postal_Code__c,City__c = compte.City__c,Email = compte.Email__c,Email_2__c = compte.Email_2__c,
	        Fax = compte.Fax,Place_Called__c = compte.Place_Called__c,Country__c = compte.Country__c,Phone = compte.Phone);
        insert c;          
            
        
        // Opportunity
        Opportunity opty = new Opportunity(name = 'Test Opty', DO_Code_SIRET__c = null, Project_Type__c = 'CREA',
                AccountId = compte.Id, Assign__c = false, StageName = 'Needs analysis', CloseDate = Date.parse('01/02/2014'),
                Billed_No_E_mail__c = true, DO_No_E_mail__c = true, Payer_No_E_mail__c = true, DO_Phone__c = '0240456598', Project_City_Postal_Code__c=cityCP.id, T_Pack__c = '');
        insert opty;
        
        Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
		insert attCom50;  

        // Opportunity PTL
        Opportunity_PTL__c optl = new Opportunity_PTL__c(Opportunity__c = opty.Id, PTL_MEP_MouvementMemeAdresseButagaz__c = true,
                PTL_MEP_Cles_en_Main__c = true, PTL_MEP_Precheck_Tank_Connection__c = true, PTL_City_Postal_Code__c = cityCP.Id, 
                Code_AC_administrator_New__c = attCom50.Id, Code_marche__c =  'P100');
        insert optl;
        
        // Start test
        test.starttest();
        
        Database.executeBatch(iBatch);
        
        // Stop test        
        test.stoptest();
        
        Opportunity_PTL__c optlSoql = [SELECT PTL_MEP_MouvementMemeAdresseButagaz__c, PTL_MEP_Cles_en_Main__c, PTL_MEP_Precheck_Tank_Connection__c, 
                PTL_MEP_MouvementMemeAdresseButagaz_Y_N__c, PTL_MEP_Cles_en_Main_Y_N__c, PTL_MEP_Precheck_Tank_Connection_Y_N__c
                FROM Opportunity_PTL__c WHERE Opportunity__c = :opty.Id];
                
        System.assertEquals(optlSoql.PTL_MEP_MouvementMemeAdresseButagaz_Y_N__c, 'Oui');
        System.assertEquals(optlSoql.PTL_MEP_Cles_en_Main_Y_N__c, 'Oui');
        System.assertEquals(optlSoql.PTL_MEP_Precheck_Tank_Connection_Y_N__c, 'Oui');
    }
    
    public static testmethod void fieldAreNotChecked() {
        Batch_Updating_PickLists iBatch = new Batch_Updating_PickLists();
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
        insert mandataire1;
        
        Canton__c Canton1 = new Canton__c(name = 'SBUP Canton', INSEE_Code__c = '-_-_', Mandataire__c = mandataire1.id);
        insert Canton1;
        
        City__c City1  = new City__c (Name = 'SBUP City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
        insert City1;
        City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - SBUPCity', 
            City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
        insert cityCP;
        
        // Account
        Account compte = new Account(name = 'Test Account', En_cours_d_immatriculation__c = true, No_E_mail__c = true,Country__c='FR', Phone='0202020202');
        insert compte;
        
        // New Contact
        Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
	        accountId = compte.Id,Street_Number__c = compte.Street_Number__c,Postal_Box__c = compte.Postal_Box__c,
	        Postal_Code__c = compte.Postal_Code__c,City__c = compte.City__c,Email = compte.Email__c,Email_2__c = compte.Email_2__c,
	        Fax = compte.Fax,Place_Called__c = compte.Place_Called__c,Country__c = compte.Country__c,Phone = compte.Phone);
        insert c; 
        
        // Opportunity
        Opportunity opty = new Opportunity(name = 'Test Opty', DO_Code_SIRET__c = null, Project_Type__c = 'CREA',
                AccountId = compte.Id, Assign__c = false, StageName = 'Needs analysis', CloseDate = Date.parse('01/02/2014'),
                Billed_No_E_mail__c = true, DO_No_E_mail__c = true, Payer_No_E_mail__c = true, DO_Phone__c = '0240456598', Project_City_Postal_Code__c=cityCP.id, T_Pack__c = '');
        insert opty;
        
        Attache_Commercial__c attCom50 = new Attache_Commercial__c(Name='attCom50', Code_Groupe_Vendeur__c='500');
		insert attCom50;  

        // Opportunity PTL
        Opportunity_PTL__c optl = new Opportunity_PTL__c(Opportunity__c = opty.Id, PTL_MEP_MouvementMemeAdresseButagaz__c = false,
                PTL_MEP_Cles_en_Main__c = false, PTL_MEP_Precheck_Tank_Connection__c = false, PTL_City_Postal_Code__c = cityCP.Id, 
                Code_AC_administrator_New__c = attCom50.Id, Code_marche__c =  'P100');
        insert optl;
        
        // Start test
        test.starttest();
        
        Database.executeBatch(iBatch);
        
        Schedule_Batch_Updating_PickLists sb = new Schedule_Batch_Updating_PickLists();        
        String sch = '0 0 6 * * ?';        
        system.schedule('Batch Updating PickLists', sch, sb);
        
        // Stop test        
        test.stoptest();
        
        Opportunity_PTL__c optlSoql = [SELECT PTL_MEP_MouvementMemeAdresseButagaz__c, PTL_MEP_Cles_en_Main__c, PTL_MEP_Precheck_Tank_Connection__c, 
                PTL_MEP_MouvementMemeAdresseButagaz_Y_N__c, PTL_MEP_Cles_en_Main_Y_N__c, PTL_MEP_Precheck_Tank_Connection_Y_N__c
                FROM Opportunity_PTL__c WHERE Opportunity__c = :opty.Id];
        
        System.assertEquals(optlSoql.PTL_MEP_MouvementMemeAdresseButagaz_Y_N__c, 'Non');
        System.assertEquals(optlSoql.PTL_MEP_Cles_en_Main_Y_N__c, 'Non');
        System.assertEquals(optlSoql.PTL_MEP_Precheck_Tank_Connection_Y_N__c, 'Non');
    }
}