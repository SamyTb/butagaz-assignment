@istest
public class BatchMiseAjourEventAnimationPres_Test {
        @testSetup
    public static void setup(){
        String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
        /*   User u = new User(FirstName='Test', LastName='APSQFO',Alias='APSQFO',
Email='APSQFO@shell.com',Username='APSQFO@shell.com',TimeZoneSidKey='Europe/Paris',
LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
LanguageLocaleKey='fr');

insert u;
*/
        User current =new    User(id =UserInfo.getUserId(),Bypass_Validation_Rules__c =true);
        update current;
        
        custom_Settings__c c0 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c1 = new Custom_Settings__c (name='FolderIdToStoreDocumentsForSignea', value__c = UserInfo.getUserId());
        //Custom_Settings__c c2 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c3 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c4 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c5 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c6 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        insert new List<Custom_Settings__c> { c0, c1, c3, c4, c5, c6 };
            
            //Activity Domain
            Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC - Gaz en citerne',ExternalID__c=42);
        insert AD_GEC;
        
        Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '591',Active__c = true,MatriculeEnCours__c=3);
        insert mandataire1;
        
        // RecordType
        RecordType recordTypeAccount = new RecordType(Name = 'Pro');
        
        //Canton
        Canton__c Canton1 = new Canton__c(name = 'APCT01 Canton', INSEE_Code__c = '-_-_',Mandataire__c=mandataire1.id);
        insert Canton1;
        
        //City
        City__c City1  = new City__c (Name = 'APCT01 City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
        insert City1;    
        
        City_Postal_Code__c cityCP1 = new City_Postal_Code__c(Name = '01001 - APCT01', 
                                                              City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
        insert cityCP1;      
        
        // Account
        List <Account> listAccount = new List<Account>();
        Account compteIsSiretOuEnCoursDImmat = new Account(name = 'accountIsSiretOuEnCoursDImmat', RecordType = recordTypeAccount,
                                                           Code_SIRET__c = '', En_cours_d_immatriculation__c = true, No_E_mail__c  = true, Email__c = null,Country__c='FR', Phone='0202020202');
        Account compteIsSiretOuEnCoursDImmat2 = new Account(name = 'accountIsSiretOuEnCoursDImmat2', RecordType = recordTypeAccount,
                                                            Code_SIRET__c = '', En_cours_d_immatriculation__c = true, No_E_mail__c  = true, Email__c = null,Country__c='FR', Phone='0202020202');
        
        listAccount.add(compteIsSiretOuEnCoursDImmat);
        listAccount.add(compteIsSiretOuEnCoursDImmat2);
        
        Account NewAccRefPresc = new Account(name='ComptePrescripteur', Activity_Domain__c=AD_GEC.Id, Predecessor__c=null, 
                                             CT_statutConversion__c='client', A_convertir__c=false, Street_Number__c='1', Market_Type__c = 'DOM',
                                             Postal_Box__c='11111', Postal_Code__c='22222', City__c='Ville', Email__c='titi.tata@gmail.com', 
                                             Email_2__c='toto.tutu@gmail.com', Fax='0101010101', Place_Called__c='LieuDit', Country__c='FR', Phone='0202020202',
                                             Prescriber__c=true,Prescriber_Activity__c='Artisant group',
                                             AccountNumber='PRESC00001');
        Account NewAccRefPresc2 = new Account(name='ComptePrescripteur2', Activity_Domain__c=AD_GEC.Id, Predecessor__c=null, 
                                              CT_statutConversion__c='client', A_convertir__c=false, Street_Number__c='1', Market_Type__c = 'PRO',
                                              Postal_Box__c='11111', Postal_Code__c='22222', City__c='Ville', Email__c='titi.tata@gmail.com', 
                                              Email_2__c='toto.tutu@gmail.com', Fax='0101010101', Place_Called__c='LieuDit', Country__c='FR', Phone='0202020202',
                                              Prescriber__c=true,Prescriber_Activity__c='Artisant group',
                                              AccountNumber='PRESC00002');
        
        listAccount.add(NewAccRefPresc);
        listAccount.add(NewAccRefPresc2);
        insert listAccount;
        
        
        // New Contact
        Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                                 accountId = compteIsSiretOuEnCoursDImmat.Id,Street_Number__c = compteIsSiretOuEnCoursDImmat.Street_Number__c,Postal_Box__c = compteIsSiretOuEnCoursDImmat.Postal_Box__c,
                                 Postal_Code__c = compteIsSiretOuEnCoursDImmat.Postal_Code__c,City__c = compteIsSiretOuEnCoursDImmat.City__c,Email = compteIsSiretOuEnCoursDImmat.Email__c,
                                 Email_2__c = compteIsSiretOuEnCoursDImmat.Email_2__c,
                                 Fax = compteIsSiretOuEnCoursDImmat.Fax,Place_Called__c = compteIsSiretOuEnCoursDImmat.Place_Called__c,
                                 Country__c = compteIsSiretOuEnCoursDImmat.Country__c,Phone = compteIsSiretOuEnCoursDImmat.Phone);
        insert c;
        
        NewAccRefPresc = [Select id,Name From Account  where name like 'ComptePrescripteur' ];
        NewAccRefPresc2 = [Select id,Name From Account  where name like 'ComptePrescripteur2' ];
        
        compteIsSiretOuEnCoursDImmat2 = [Select id,Name From Account  where name like 'accountIsSiretOuEnCoursDImmat2' ];
        cityCP1= [Select id,Name From City_Postal_Code__c where Name = '01001 - APCT01'];
        AD_GEC= [Select id,Name From Activity_Domain__c where Name = 'GEC - Gaz en citerne'];
        // Opportunity
        List<Opportunity> listOppty = new List<Opportunity>();
        date todayMinusAyear = date.newInstance(  (Date.today()).year()-1, (Date.today()).month(), (Date.today()).day());
        // date todayMinusADays = date.newInstance(  (Date.today()).year(), Math.abs((Date.today()).month()-1), (Date.today()).day());
        Opportunity optyUn = new Opportunity(
            name = 'optyUn', DO_Code_SIRET__c = '',Prescriber_Account__c =NewAccRefPresc2.id, project_market_type__c='DOM',
            Project_Type__c = 'CREA', AccountId = compteIsSiretOuEnCoursDImmat2.Id, Assign__c = false, StageName = 'Closed Won', Opportunity_Won_Substage__c='Data validated by BO',
            CloseDate = todayMinusAyear,  DO_En_cours_d_immatriculation__c = true, Project_City_Postal_Code__c=cityCP1.id,DO_Activity_Domain__c=AD_GEC.Id
        );
        listOppty.add(optyUn);
        
        Opportunity optydeux = new Opportunity(
            name = 'optydeux', DO_Code_SIRET__c = '',Prescriber_Account__c =NewAccRefPresc2.id, project_market_type__c='PRO',
            Project_Type__c = 'CREA', AccountId = compteIsSiretOuEnCoursDImmat2.Id, Assign__c = false, StageName = 'Closed Won', Opportunity_Won_Substage__c='Data validated by BO', 
            CloseDate = Date.today(),  DO_En_cours_d_immatriculation__c = true, Project_City_Postal_Code__c=cityCP1.id,DO_Activity_Domain__c=AD_GEC.Id
        ); 
        listOppty.add(optydeux);
        
        Opportunity optyTrois = new Opportunity(
            name = 'optyTrois', DO_Code_SIRET__c = '',Prescriber_Account__c =NewAccRefPresc2.id,  project_market_type__c='PRO',
            Project_Type__c = 'CREA', AccountId = compteIsSiretOuEnCoursDImmat2.Id, Assign__c = false, StageName = 'Prospecting', 
            CloseDate = Date.today(),  DO_En_cours_d_immatriculation__c = true, Project_City_Postal_Code__c=cityCP1.id,DO_Activity_Domain__c=AD_GEC.Id
        );
        listOppty.add(optyTrois);
        
        
        insert listOppty;
        
         RecordType rtGEB = [SELECT Id,Name FROM RecordType WHERE SobjectType='Event' AND Name ='Visite Prescripteur' LIMIT 1];
        datetime todayMinus4Month = date.newInstance(  (Date.today()).year(), (Date.today()).month(), (Date.today()).day());
         datetime todayMinus4MonthFin = todayMinus4Month.addMinutes(30);
         Event oEventFromAccount = new Event(whatid=NewAccRefPresc2.id,RecordTypeId=rtGEB.id,DurationInMinutes=30,EndDateTime=todayMinus4MonthFin, ActivityDateTime=todayMinus4Month,Type_d_evenement_GEC__c='PRESCRIPTION');
        system.debug('oEventFromAccount: ->'+oEventFromAccount);

        Event oEventFromAccount1 = new Event(whatid=NewAccRefPresc2.id,RecordTypeId=rtGEB.id,DurationInMinutes=30,EndDateTime=todayMinus4MonthFin, ActivityDateTime=todayMinus4Month,Segmentation_Scoring__c=null,Type_d_evenement_GEC__c='PRESCRIPTION');
        system.debug('oEventFromAccount1: ->'+oEventFromAccount1);
        
        Event oEventFromAccount2 = new Event(whatid=NewAccRefPresc2.id,RecordTypeId=rtGEB.id,DurationInMinutes=30,EndDateTime=todayMinus4MonthFin, ActivityDateTime=todayMinus4Month,Segmentation_Scoring__c=null,Type_d_evenement_GEC__c='PRESCRIPTION');
        system.debug('oEventFromAccount2: ->'+oEventFromAccount2);
        List<Event> listevent =new  List<Event>{oEventFromAccount,oEventFromAccount1,oEventFromAccount2};
        insert listevent;
    }
    @istest 
    public static void testBatch(){
         test.starttest();
         BatchMiseAjourEventAnimationPrescriteur uca = new BatchMiseAjourEventAnimationPrescriteur();
        Id batchId = Database.executeBatch(uca);
        test.stoptest();
        
    }
}