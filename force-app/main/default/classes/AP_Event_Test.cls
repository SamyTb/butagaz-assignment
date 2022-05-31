@isTest
public class AP_Event_Test {
    
     public static void initCustomSettting(){
        // Custom settings
        Custom_Settings__c c1 = new Custom_Settings__c (name='FolderIdToStoreDocumentsForSignea', value__c = UserInfo.getUserId());
        Custom_Settings__c c8 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        Custom_Settings__c c9 = new Custom_Settings__c (name='Espace_Client_AES_Key',value__c = 'DhoFORSbCPYk/czijR/mNk+HIyRM/PG3z5goBhb00pw=');
        Custom_Settings__c c10 = new Custom_Settings__c (name='Espace_Client_AES_Iv',value__c = '7E892875A52C59A3B58830');
        Custom_Settings__c c11 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEB',value__c = 'https://URLGEB.com/');
        Custom_Settings__c c12 = new Custom_Settings__c (name='Espace_Client_Registration_URL_GEC',value__c = 'https://URLGEC.com/');
        Custom_Settings__c c13 = new Custom_Settings__c (name='Contact_Main_Role',value__c = 'Contact Principal');
        insert new List<Custom_Settings__c> { c1, c8, c9, c10, c11, c12,c13 };
            }
    
    
    public static testmethod void testEvent(){
        
        initCustomSettting();
      
           String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
         
         User u = new User(FirstName='Test', LastName='APOT2',Alias='APOT2',
                Email='APOT2@shell.com',Username='APOT2@shell.com',TimeZoneSidKey='Europe/Paris',
                LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
                LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
                
         insert u;
        
         // Start test
        test.starttest();
        
          
        Activity_Domain__c AD_GEB = new Activity_Domain__c(name = 'GEB', ExternalID__c=98);
        insert AD_GEB;
                   
            
                //Canton - City - CP
                            
                    Canton__c Canton1 = new Canton__c(name = 'VFC06PS Canton', INSEE_Code__c = '-_-_');
                    insert Canton1;
                            
                    City__c City1  = new City__c (Name = 'VFC06PS City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
                    insert City1;
                            
                    City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', 
                    City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
                    insert cityCP;
                           
        // Account
        Account oAccount = new Account(name='PECaccount', AccountNumber='C65',Segmentation__c='22',Country__c='FR', Phone='0202020202',Email__c='toto@titi.com',Mobile_Phone_Number__c='0601010101',Work_Phone_Number__c='0101010101',Email_2__c='toto@titi.com');
        insert oAccount;  
        
         //Contact
        Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
        accountId = oAccount.Id,Street_Number__c = oAccount.Street_Number__c,Postal_Box__c = oAccount.Postal_Box__c,
        Postal_Code__c = oAccount.Postal_Code__c,City__c = oAccount.City__c,Email = oAccount.Email__c,Email_2__c = oAccount.Email_2__c,
        Fax = oAccount.Fax,Place_Called__c = oAccount.Place_Called__c,Country__c = oAccount.Country__c,Phone = oAccount.Phone);
        insert c;
        
       
        

        // PTL
        PTL__c oPTL = new PTL__c(Name = 'IPPTL', Account_DO__c=oAccount.Id, City__c = 'City', Postal_Code__c = '12345', Propane_13__c=true, Client_ouvert_toute_l_annee__c=true);
        insert oPTL;    


        // Oppty
         Opportunity oOpty = new Opportunity(Name = 'TestOpty', Project_Type__c='CREA', DO_Activity_Domain__c= AD_GEB.Id,DO_AccountNumber__c='12345',StageName='Open', AccountId = oAccount.Id, CloseDate = Date.today(), 
         Project_City_Postal_Code__c = cityCP.Id, DO_City_Postal_Code__c = cityCP.Id, Assign__c=false, OwnerId = u.id,DO_Payment_method__c = 'V', Installation_date__c = Date.today() + 15,Client_Type__c = 'Owner');
         insert oOpty;
        
        //test of putSegmentationScoringInEvent 
        RecordType rtGEB = [SELECT Id,Name FROM RecordType WHERE SobjectType='Event' AND Name ='Visite GEB' LIMIT 1];
        

        
        Event oEventFromAccount = new Event(whatid=oAccount.id,RecordTypeId=rtGEB.id,DurationInMinutes=30,ActivityDateTime=datetime.now());
        system.debug('oEventFromAccount: ->'+oEventFromAccount);

        Event oEventFromPTL = new Event(whatid=oPTL.id,RecordTypeId=rtGEB.id,DurationInMinutes=30,ActivityDateTime=datetime.now(),Segmentation_Scoring__c=null);
        system.debug('oEventFromPTL: ->'+oEventFromPTL);
        
        Event oEventFromOpty = new Event(whatid=oPTL.id,RecordTypeId=rtGEB.id,DurationInMinutes=30,ActivityDateTime=datetime.now(),Segmentation_Scoring__c=null);
        system.debug('oEventFromPTL: ->'+oEventFromPTL);
                
        insert oEventFromAccount;                   
        insert oEventFromPTL;           
               
        // Stop test        
        test.stoptest();
    }
    
    
  /*MLC 20180312*/
  public static testmethod void putSObjectInfoInEvent() {
        
         String profileId = [SELECT Id FROM Profile WHERE Name LIKE '%Butagaz System Administrator%' LIMIT 1].Id;
         
         User u = new User(FirstName='Test', LastName='APOT2',Alias='APOT2',
                Email='APOT2@shell.com',Username='APOT2@shell.com',TimeZoneSidKey='Europe/Paris',
                LocaleSidKey='fr_FR_EURO',EmailEncodingKey='ISO-8859-1',ProfileId=profileId,
                LanguageLocaleKey='fr', Bypass_Validation_Rules__c = true);
                
         insert u;
            
         Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
         insert new List<Custom_Settings__c> { c1 };
            
          System.runAs(u) 
                {

              /*  //Mandataire
                    Mandataire__c mandataire1= new Mandataire__c(name = 'NewRefSAP Mandataire',ExternalID__c = '592',Active__c = true,MatriculeEnCours__c=3 );
                    insert mandataire1;*/
                            
                //Domaine acivite            
                    Activity_Domain__c AD_GEC = new Activity_Domain__c(name = 'GEC', ExternalID__c=99);
                    insert AD_GEC;
                   
                    
                    Activity_Domain__c AD_GEB = new Activity_Domain__c(name = 'GEB', ExternalID__c=98);
                    insert AD_GEB;
                   
                //Canton - City - CP
                            
                    Canton__c Canton1 = new Canton__c(name = 'VFC06PS Canton', INSEE_Code__c = '-_-_');
                    insert Canton1;
                            
                    City__c City1  = new City__c (Name = 'VFC06PS City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
                    insert City1;
                            
                    City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - VFC06PS', 
                    City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
                    insert cityCP;
                    
                     
            // PriceBook
            Id pb2StandardId = Test.getStandardPricebookId();
            Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook VFC06PS',Description='Test Pricebook VFC06PS', isActive=true);
            insert pbk1;
                    
                    
                    List<Event> Evt = new List<Event>();
            		List<Id> EvtId = new List<Id>();
                    
                    
                    test.startTest();             
                            
                            //Account            
                                        
                                Account oAccount  = new Account(Name='VFC06PS ', Market_Type__c = 'DOM', Activity_Domain__c = AD_GEC.Id, 
                                Postal_Code__c = '123', City__c = 'VFCQLI01City', Email__c = 'VFCQLI01City@test.org', channel__c='CD',
                                accountNumber='12345',Country__c='FR', Phone='0202020202',
                                Espace_Client_Registration_URL__c = 'https://test.com/XXXXX');
                                insert oAccount;
                                
                               
                                        
                               
                                        
                            // New Contact
                                Contact c  = new Contact( Contact_Marketing__c  = true,firstName = 'Contact Marketing',lastName = 'Contact Marketing',
                                accountId = oAccount.Id,Street_Number__c = oAccount.Street_Number__c,Postal_Box__c = oAccount.Postal_Box__c,
                                Postal_Code__c = oAccount.Postal_Code__c,City__c = oAccount.City__c,Email = oAccount.Email__c,Email_2__c = oAccount.Email_2__c,
                                Fax = oAccount.Fax,Place_Called__c = oAccount.Place_Called__c,Country__c = oAccount.Country__c,Phone = oAccount.Phone);
                                insert c;        
                                        
                            //PTL & Mandataire
                                
                                Mandataire__c  mand1 = new Mandataire__c( name = 'VFC06PS Mandataire',ExternalID__c = 'VPS01',Active__c = true);
                                insert mand1;
                                        
                                PTL__c oPTL = new PTL__c(Activity_Domain__c = AD_GEC.id,Mandataire__c = mand1.id,City__c = 'VFC06PS City 2',Postal_Code__c = '09876',
                                Mobile_Phone_Number__c=oAccount.Mobile_Phone_Number__c,Phone__c=oAccount.Phone);
                                insert oPTL;
                                        
                            // Add an Oppty
                                Opportunity oOpty = new Opportunity(Name = 'TestOpty', Project_Type__c='CREA', DO_Activity_Domain__c= AD_GEC.Id,DO_AccountNumber__c='12345',StageName='Open', AccountId = oAccount.Id, CloseDate = Date.today(), 
                                Project_City_Postal_Code__c = cityCP.Id, DO_City_Postal_Code__c = cityCP.Id, Assign__c=false, OwnerId = u.id,DO_Payment_method__c = 'V', Installation_date__c = Date.today() + 15,T_Pack__c = 'IDEO',Client_Type__c = 'Owner');
                                insert oOpty;
                           //Equipement  
                                  Equipement__c oEquipment = new Equipement__c(PTL__c = oPTL.Id,Activity_Domain__c = AD_GEC.Id,Mandataire__c = mand1.Id  );
                                  insert oEquipment;
                          
                            //case
                                Case oCase = new Case(Mandataire__c = mand1.Id,Equipement__c = oEquipment.Id,ContactId = c.Id  );
                                 insert oCase; 
                               
                            //Lead
                            Lead oLead = new Lead(lastName='LeadEvent', W2L_Postal_Code__c = '06230', W2L_Project_Postal_Code__c = '06230',W2L_City__c = 'Saint Jean Cap Ferrat', W2L_Activity_Domain__c = 99,W2L_Project_City__c = 'Saint Jean Cap Ferrat',
                                Phone='0202020202',MobilePhone='0601020201');  
                                insert oLead;
                                             
                                 
                //test of putSegmentationScoringInEvent 
                RecordType rtGEB = [SELECT Id,Name FROM RecordType WHERE SobjectType='Event' AND Name ='Visite GEB' LIMIT 1];
                            
                             
                //test of putSegmentationScoringInEvent 
                RecordType rtGEC = [SELECT Id,Name FROM RecordType WHERE SobjectType='Event' AND Name ='Visite GEC' LIMIT 1];
                
                
                   //test of putSegmentationScoringInEvent 
              //  RecordType rtPresc = [SELECT Id,Name FROM RecordType WHERE SobjectType='Event' AND Name ='Visite Prescripteur' LIMIT 1];
                            
                            
                Event oEventFromAccountGEB = new Event(whatid=oAccount.id,RecordTypeId=rtGEB.id,DurationInMinutes=30,ActivityDateTime=datetime.now());
                system.debug('oEventFromAccount: ->'+oEventFromAccountGEB );
                Evt.add(oEventFromAccountGEB);
                EvtId.add(oEventFromAccountGEB.Id);

                Event oEventFromPTLGEB = new Event(whatid=oPTL.id,RecordTypeId=rtGEB.id,DurationInMinutes=30,ActivityDateTime=datetime.now(),Segmentation_Scoring__c=null);
                system.debug('oEventFromPTL: ->'+oEventFromPTLGEB);
                Evt.add(oEventFromPTLGEB);  
                EvtId.add(oEventFromPTLGEB.Id);
                
               
//GEC

                Event oEventFromAccountGEC = new Event(whatid=oAccount.id,RecordTypeId=rtGEC.id,DurationInMinutes=30,ActivityDateTime=datetime.now());
                system.debug('oEventFromAccount: ->'+oEventFromAccountGEC );
                Evt.add(oEventFromAccountGEC);
                EvtId.add(oEventFromAccountGEC.Id);

                Event oEventFromPTLGEC = new Event(whatid=oPTL.id,RecordTypeId=rtGEC.id,DurationInMinutes=30,ActivityDateTime=datetime.now());
                system.debug('oEventFromPTL: ->'+oEventFromPTLGEC);               
                Evt.add(oEventFromPTLGEC);  
                EvtId.add(oEventFromPTLGEC.Id);
                
                Event oEventFromOptyGEC = new Event(whatid=oOpty.id,RecordTypeId=rtGEC.id,DurationInMinutes=30,ActivityDateTime=datetime.now());
                system.debug('oEventFromOpty: ->'+oEventFromOptyGEC);
                Evt.add(oEventFromOptyGEC);
                EvtId.add(oEventFromOptyGEC.Id);
                                
                Event oEventFromCaseGEC = new Event(whatid=oCase.id,RecordTypeId=rtGEC.id,DurationInMinutes=30,ActivityDateTime=datetime.now());
                system.debug('oEventFromCase: ->'+oEventFromCaseGEC);
                Evt.add(oEventFromCaseGEC);
                EvtId.add(oEventFromCaseGEC.Id);
                
                
                Event oEventFromEquipementGEC = new Event(whatid=oEquipment.id,RecordTypeId=rtGEC.id,DurationInMinutes=30,ActivityDateTime=datetime.now());
                system.debug('oEventFromEqupement: ->'+oEventFromEquipementGEC);
                Evt.add(oEventFromEquipementGEC);
                EvtId.add(oEventFromEquipementGEC.Id);
                
               Event oEventFromLeadGEC = new Event(WhoId=oLead.id,RecordTypeId=rtGEC.id,DurationInMinutes=30,ActivityDateTime=datetime.now());
                system.debug('oEventFromLead: ->'+oEventFromLeadGEC);
                Evt.add(oEventFromLeadGEC);
                EvtId.add(oEventFromLeadGEC.Id);
                
                
                
                
                
                  

                                
                insert Evt;                   


                AP_Event.putSObjectInfoInEvent(EvtId);         
                        
                        
                                        
                test.stopTest();
                
            }
    
    
    }
    
    
    
    
}