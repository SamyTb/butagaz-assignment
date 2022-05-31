/** Classe de test du batch «  Batch_Counting_PTL_ActivityHistory » **/
@isTest
private class Batch_Counting_PTL_ActivityHistory_Test {
    
    static List<Contact_Per_Medal__c> CPMList;
    static List<Account> accountList;
    static List<PTL__c> PTLList;
    static List<Event> eventList;
    static Date todayDate;
    static DateTime todayDateTime;
    
    
    static void init(){
        
        todayDate = Date.today();
        todayDateTime = system.now();
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        /** Contact_Per_Medal__c **/
        CPMList = new List<Contact_Per_Medal__c>();
        CPMList.add(new Contact_Per_Medal__c(
            Year__c = string.valueof(System.Today().Year()), Contact_Type__c = 'Visite de suivi',
            Segmentation_medailles__c = '1. Or', Contact_Count__c = 8
        ));
        CPMList.add(new Contact_Per_Medal__c(
            Year__c = string.valueof(System.Today().Year()), Contact_Type__c = 'Visite de suivi',
            Segmentation_medailles__c = '2. Argent', Contact_Count__c = 4
        ));
        CPMList.add(new Contact_Per_Medal__c(
            Year__c = string.valueof(System.Today().Year()), Contact_Type__c = 'Phone conference',
            Segmentation_medailles__c = '1. Or', Contact_Count__c = 4
        ));
        CPMList.add(new Contact_Per_Medal__c(
            Year__c = string.valueof(System.Today().Year()-1), Contact_Type__c = 'Phone conference',
            Segmentation_medailles__c = '2. Argent', Contact_Count__c = 2
        ));
        CPMList.add(new Contact_Per_Medal__c(
            Year__c = string.valueof(System.Today().Year()-1), Contact_Type__c = 'Visite de suivi',
            Segmentation_medailles__c = '1. Or', Contact_Count__c = 8
        ));
        CPMList.add(new Contact_Per_Medal__c(
            Year__c = string.valueof(System.Today().Year()-1), Contact_Type__c = 'Visite de suivi',
            Segmentation_medailles__c = '2. Argent', Contact_Count__c = 4
        ));
        CPMList.add(new Contact_Per_Medal__c(
            Year__c = string.valueof(System.Today().Year()-1), Contact_Type__c = 'Phone conference',
            Segmentation_medailles__c = '1. Or', Contact_Count__c = 4
        ));
        CPMList.add(new Contact_Per_Medal__c(
            Year__c = string.valueof(System.Today().Year()), Contact_Type__c = 'Phone conference',
            Segmentation_medailles__c = '2. Argent', Contact_Count__c = 2
        ));
        insert CPMList;
        
                
        Activity_Domain__c AD_GEB = new Activity_Domain__c(name = 'GEB', ExternalID__c=41);
        insert AD_GEB;
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
        Canton__c Canton1 = new Canton__c(name = 'BCPA Canton', INSEE_Code__c = '-_-_');
        insert Canton1;
        City__c City1  = new City__c (Name = 'BCPA City',  Canton__c = Canton1.Id, INSEE_Code__c = '____-');
        insert City1;
        City_Postal_Code__c cityCP = new City_Postal_Code__c(Name = '01001 - BCPA', 
            City__c = City1.Id, HEXAPOSTE_Code__c = '01001', Code_Type__c = 'M');
        insert cityCP;
            
        
        /** Account **/
        accountList = new List<Account>();
        accountList.add(new Account(
            Name='BCPA1', Market_Type__c = 'PRO', Activity_Domain__c = AD_GEB.Id, Postal_Code__c = '123', 
            City__c = 'BCPACity', Email__c = 'BCPA@test.org', channel__c='RE', accountNumber='12345', Segmentation_medailles__c = '1. Or',Country__c='FR', Phone='0202020202',
            Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
        ));
        accountList.add(new Account(
            Name='BCPA2', Market_Type__c = 'PRO', Activity_Domain__c = AD_GEB.Id, Postal_Code__c = '123', 
            City__c = 'BCPACity', Email__c = 'BCPA@test.org', channel__c='RE', accountNumber='12346', Segmentation_medailles__c = '2. Argent',Country__c='FR', Phone='0202020202',
            Espace_Client_Registration_URL__c = 'https://test.com/XXXXX'
        ));
        
        insert accountList;
        
        /** PTL & Mandataire **/
        Mandataire__c mand1 = new Mandataire__c(
            name = 'BCPA MDT',
            ExternalID__c = 'BCP01',
            Active__c = true
        );
        insert mand1;
        
        PTLList = new List<PTL__c>();
        PTLList.add(new PTL__c(
            Account_DO__c = accountList[0].id,
            Activity_Domain__c = AD_GEB.id,
            Mandataire__c = mand1.id,
            City__c = 'BCPA City 2',
            Postal_Code__c = '09876',
            Code_Canal__c = 'RE',
            Name = 'PTL1'
        ));
        PTLList.add(new PTL__c(
            Account_DO__c = accountList[1].id,
            Activity_Domain__c = AD_GEB.id,
            Mandataire__c = mand1.id,
            City__c = 'BCPA City 2',
            Postal_Code__c = '09876',
            Code_Canal__c = 'RE',
            Name = 'PTL2'
        ));
        
        insert PTLList;
            
        
        /** Event **/
        RecordType rtEventGEB = [SELECT Id, Name FROM RecordType WHERE SobjectType='Event' AND DeveloperName='Visite_GEB' LIMIT 1];
        eventList = new List<Event>();
        
        // A
        eventList.add(new Event(
            WhatId=PTLList[0].Id, ActivityDate = todayDate, Description = 'XXXXXXXXXX', Type = 'Visite de suivi', 
            Subject = 'MySubject', DurationInMinutes = 60, ActivityDateTime = todayDateTime.addHours(-2), StartDateTime = todayDateTime.addHours(-2),
            EndDateTime = todayDateTime.addHours(-1), RecordTypeId = rtEventGEB.Id, Objet_GEB__c = 'Intervention technique Standard'
        ));
        eventList.add(new Event(
            WhatId=PTLList[0].Id, ActivityDate = todayDate, Description = 'XXXXXXXXXX', Type = 'Visite de suivi', 
            Subject = 'MySubject', DurationInMinutes = 60, ActivityDateTime = todayDateTime.addHours(-3), StartDateTime = todayDateTime.addHours(-3),
            EndDateTime = todayDateTime.addHours(-2), RecordTypeId = rtEventGEB.Id, Objet_GEB__c = 'Intervention technique Standard'
        ));
        eventList.add(new Event(
            WhatId=PTLList[1].Id, ActivityDate = todayDate, Description = 'XXXXXXXXXX', Type = 'Phone conference', 
            Subject = 'MySubject', DurationInMinutes = 60, ActivityDateTime = todayDateTime.addHours(-2), StartDateTime = todayDateTime.addHours(-2),
            EndDateTime = todayDateTime.addHours(-1), RecordTypeId = rtEventGEB.Id, Objet_GEB__c = 'Intervention technique Standard'
        ));
        
        // A-1
        eventList.add(new Event(
            WhatId=PTLList[0].Id, ActivityDate = todayDate.addYears(-1), Description = 'XXXXXXXXXX', Type = 'Visite de suivi', 
            Subject = 'MySubject', DurationInMinutes = 60, ActivityDateTime = todayDateTime.addYears(-1).addHours(-2), StartDateTime = todayDateTime.addYears(-1).addHours(-2),
            EndDateTime = todayDateTime.addYears(-1).addHours(-1), RecordTypeId = rtEventGEB.Id, Objet_GEB__c = 'Intervention technique Standard'
        ));
        eventList.add(new Event(
            WhatId=PTLList[0].Id, ActivityDate = todayDate.addYears(-1), Description = 'XXXXXXXXXX', Type = 'Visite de suivi', 
            Subject = 'MySubject', DurationInMinutes = 60, ActivityDateTime = todayDateTime.addYears(-1).addHours(-3), StartDateTime = todayDateTime.addYears(-1).addHours(-3),
            EndDateTime = todayDateTime.addYears(-1).addHours(-2), RecordTypeId = rtEventGEB.Id, Objet_GEB__c = 'Intervention technique Standard'
        ));
        eventList.add(new Event(
            WhatId=PTLList[0].Id, ActivityDate = todayDate.addYears(-1), Description = 'XXXXXXXXXX', Type = 'Visite de suivi', 
            Subject = 'MySubject', DurationInMinutes = 60, ActivityDateTime = todayDateTime.addYears(-1).addHours(-4), StartDateTime = todayDateTime.addYears(-1).addHours(-4),
            EndDateTime = todayDateTime.addYears(-1).addHours(-3), RecordTypeId = rtEventGEB.Id, Objet_GEB__c = 'Intervention technique Standard'
        ));
        
        insert eventList;
        
    }
    
    static testMethod void myUnitTest() {
        
        init();
        
        Test.startTest();
        
        Batch_Counting_PTL_ActivityHistory iBatch=new Batch_Counting_PTL_ActivityHistory('select id, Nombre_de_visites__c, Nombre_de_contacts_telephoniques__c, Nombre_de_visites_Percent__c, Nombre_de_contacts_telephoniques_Percent__c from PTL__c');
        //Database.executeBatch(new Batch_Counting_PTL_ActivityHistory(iBatch, 200));
        ID JobId = Database.executeBatch(iBatch, 200);
        
        Test.stopTest();
        
        
        // Récupération des PTLs dans Salesforce
        List<PTL__c> newPTLList = [
          SELECT Id, Name, Nombre_de_visites__c, Nombre_de_contacts_telephoniques__c, Segmentation_medailles__c,
          Nombre_de_visites_Amoins1__c, Nombre_de_contacts_telephoniques_Amoins1__c
          FROM PTL__c
          WHERE Id IN :PTLList
        ];
        
        
        // Verification des points
        System.assertEquals(2, newPTLList[0].Nombre_de_visites__c);
        System.assertEquals(0, newPTLList[0].Nombre_de_contacts_telephoniques__c);
        System.assertEquals(0, newPTLList[1].Nombre_de_visites__c);
        System.assertEquals(1, newPTLList[1].Nombre_de_contacts_telephoniques__c);
        System.assertEquals(3, newPTLList[0].Nombre_de_visites_Amoins1__c);
        System.assertEquals(0, newPTLList[0].Nombre_de_contacts_telephoniques_Amoins1__c);
        
    }
}