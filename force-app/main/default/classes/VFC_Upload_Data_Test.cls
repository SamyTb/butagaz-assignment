@isTest
public class VFC_Upload_Data_Test {

    public static String[] csvFileLines;
    public static Blob csvFileBody;
    public static String csvAsString;
    
    public VFC_Upload_Data_Test() {

    }
	
    @isTest 
    static void uploadTestNotCSV() {

        Test.startTest();   
		VFC_Upload_Data controller = new VFC_Upload_Data();
        pageReference pr = controller.upload();
        Test.stopTest();
        
        system.assertEquals(pr, null);
        
    }

    @isTest 
    static void uploadTestCSV() {
        
        
        String str = 'numéro du compte;mandataire;secteur d\'activité;propriétaire demande;point livré;catégorie demande;equipement;commande;Origin;Subject;Status;Priority;Description\r\n'+
        		'2V933092292;2GAZARMOR SAS Secteur Ouest;GEB - Gaz en bouteille;2Elisabeth LEONLEMOULEC;2L999999999;2CDM:09 | Métal - Opération(s) réglementaire(s);2equi1;2GDB1675355;2Remonté du Conseiller Technique CTS;2Client à risque identifié par CTS;New;High;FLA11';	 
		
        Test.startTest();       
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n');         

        VFC_Upload_Data controller = new VFC_Upload_Data();
        controller.contenttype = 'application/vnd.ms-excel';
        controller.csvFileBody = csvFileBody;
		pageReference pr = controller.upload();
        Test.stopTest();
        
        system.assertEquals(pr, null);
        
    }


    @isTest 
    static void uploadTestCSVOK() 
    {
        // Custom settings
        // FolderId lookup on Document = polymorphic field (can lookup to a folder or a user). Docs will be added to the My Personal Documents folder
        Custom_Settings__c c1 = new Custom_Settings__c (name='FolderIdToStoreDocumentsForSignea', value__c = UserInfo.getUserId());
        Custom_Settings__c c2 = new Custom_Settings__c (name='Pricing_EndPointURL',value__c = 'http://www.google.fr'); 
        Custom_Settings__c c3 = new Custom_Settings__c (name='Pricing_Username',value__c = 'username'); 
        Custom_Settings__c c4 = new Custom_Settings__c (name='Pricing_Password',value__c = 'password');
        Custom_Settings__c c8 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c13 = new Custom_Settings__c (name='Opportunity_RecordTypeId_GEC_DOM_IDEO',value__c = '012D00000003Epc');
        Custom_Settings__c c14 = new Custom_Settings__c (name='Opportunity_RecordTypeId_GEC_GrosVrac',value__c = '012D0000000374b');
        Custom_Settings__c c15 = new Custom_Settings__c (name='TrackBAPICalls', value__c = 'true');
        Custom_Settings__c c16 = new Custom_Settings__c (name='Rebate_EndPointURL', value__c = 'http://www.google.fr');
        Custom_Settings__c c17 = new Custom_Settings__c (name='Rebate_Username',value__c = 'username'); 
        Custom_Settings__c c18 = new Custom_Settings__c (name='Rebate_Password',value__c = 'password');
        insert new List<Custom_Settings__c> { c1, c2, c3, c4, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18 };
            
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        User u = new User(LastName='LANGLAIS', Alias='VFCQLI07',
            Email='VFCQLI01@shelldd.com',Username='ddVFCQLI01@shell.com',TimeZoneSidKey='Europe/Paris',
            LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
            LanguageLocaleKey='fr');
            
        insert u;
        
        System.runAs(u) {
            Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
            insert mandataire1;

            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC');
            insert AD_GEC;
            Canton__c Canton1 = new Canton__c(name = 'VFCQLI01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
            insert Canton1;
            City__c City1  = new City__c (Name = 'VFCQLI01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
            insert City1;
            City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFCQLI01City', 
            City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
            insert cityCP;
    
            Account acc = new Account(AccountNumber = 'WRARCSCZK', Name='VFCQLI01 ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                                      Postal_Code__c = '123', City__c = 'VFCQLI01City', Email__c = 'VFCQLI01City@test.org',Country__c='FR', Phone='0202020202');
            insert acc;
            
            String str = 'numéro du compte;mandataire;secteur d\'activité;propriétaire demande;point livré;catégorie demande;equipement;commande;Origin;Subject;Status;Priority;Description\r\n'+
                    acc.AccountNumber+';'+mandataire1.Name+';'+AD_GEC.Name+';'+u.lastName+';;;;;;New;High;FLA11';	 
            
            Test.startTest();       
            csvFileBody = Blob.valueOf(str);
            String csvAsString = csvFileBody.toString();
            csvFileLines = csvAsString.split('\n');         
    
            VFC_Upload_Data controller = new VFC_Upload_Data();
            controller.contenttype = 'application/vnd.ms-excel';
            controller.csvFileBody = csvFileBody;
            pageReference pr = controller.upload();
            Test.stopTest();
            
            system.assertEquals(pr, null);
    	}        
    }


}