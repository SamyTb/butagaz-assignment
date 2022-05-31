@isTest(seeAllData=true)
public class VFC01_OrderTaking_TestUtilities{
    
    public static String PTL_CODE_DIV = 'TEST_CD';
    public static String USER_PROFILE = 'Butagaz Standard User';

    public static PageReference getVFPSimulateFromQS(String queryString){
        String PageURL = '/apex/VFP01_OrderTaking_Simulation_Step1?' + queryString;
        return new PageReference(PageURL);
    }

    public static PageReference getVFPDeletionFromQS(String queryString){
        String PageURL = '/apex/VFP01_OrderTaking_Deletion?' + queryString;
        return new PageReference(PageURL);
    }
    
    public static PageReference getVFPSimulationFromOrder(String orderId){
        String queryString = '';
        queryString += 'id=';
        queryString += orderId;
        return VFC01_OrderTaking_TestUtilities.getVFPSimulateFromQS(queryString);
    }
    
    public static PageReference getVFPDeletionFromOrder(String orderId){
        String queryString = '';
        queryString += 'delID=';
        queryString += orderId;
        return VFC01_OrderTaking_TestUtilities.getVFPDeletionFromQS(queryString);
    }
    
    public static PageReference getVFPSimulationFromOrder(Id orderId){
        return VFC01_OrderTaking_TestUtilities.getVFPSimulationFromOrder(String.valueOf(orderId));
    }

    public static PageReference getVFPSimulationFromContract(String contractId){
        String queryString = '';
        queryString += 'CF' + Custom_Settings__c.getInstance('OrderTaking_Order_FieldId_Contract').value__c + '_lkid=';
        queryString += contractId;
        return VFC01_OrderTaking_TestUtilities.getVFPSimulateFromQS(queryString);
    }
    
    public static PageReference getVFPSimulationFromContract(Id contractId){
        return VFC01_OrderTaking_TestUtilities.getVFPSimulationFromContract(String.valueOf(contractId));
    }

    public static VFC01_OrderTaking_Simulation getSimulationControllerForPage(PageReference page){
        // Create the controller for the page. This is equivalent to the user visiting the page.
        ApexPages.StandardController std = new ApexPages.StandardController(new Order__c());
        return new VFC01_OrderTaking_Simulation(std);
    }

    public static VFC01_OrderTaking_Deletion getDeletionControllerForPage(PageReference page){
        // Create the controller for the page. This is equivalent to the user visiting the page.
        ApexPages.StandardController std = new ApexPages.StandardController(new Order__c());
        return new VFC01_OrderTaking_Deletion(std);
    }
    
    public static Contract getContract(){
        Contract ct;
        RecordType proAccountRT = [SELECT Id FROM RecordType WHERE sObjectType='Account' AND DeveloperName = 'Pro'];
        Account acct = new Account(Name = 'TestAcct', RecordTypeId = proAccountRT.Id, Postal_Code__c = '1234', City__c = 'SomeCity',Country__c='FR', Phone='0202020202', Email__c='test.mail@mail.com'); 
        insert acct;
        ct = new Contract(AccountId = acct.Id); insert ct;
        return ct;
    }

    public static Item__c getItem(){
        Item__c oItem = new Item__c(Name = 'TestItem'); insert oItem;
        return oItem;
    }

    public static PTL__c getPTL(){
        PTL__c oPTL = new PTL__c(Name = 'TestPTL', Code_Division__c = VFC01_OrderTaking_TestUtilities.PTL_CODE_DIV, City__c = 'YYYY', Postal_Code__c = '12345');
        oPTL.Propane_13__c = true;
        oPTL.Client_ouvert_toute_l_annee__c = true;
        insert oPTL;
        return oPTL;
    }

    public static void makePermissions(){
        /*User currentUser = [SELECT Mandataire__c FROM User WHERE Id = :UserInfo.getUserId()];
        String userMandataire = currentUser.Mandataire__c;
        Order_Taking_Permissions__c oPermissions = new Order_Taking_Permissions__c(Delivery_Code__c = VFC01_OrderTaking_TestUtilities.PTL_CODE_DIV, User_mandataire__c = userMandataire);
        insert oPermissions;*/
        // Gestion multi-plaques
        list<Order_Taking_Permissions__c> lPermissions = new list<Order_Taking_Permissions__c>();
        Order_Taking_Permissions__c oPermissions = null;
        User currentUser = [SELECT User_Mandataires__c FROM User WHERE Id = :UserInfo.getUserId()];
        String userMandataire = currentUser.User_Mandataires__c;
        
        if(userMandataire != null){
            String[] userMandataires = userMandataire.split(';',0);
            
            for(integer i=0;i<userMandataires.size();i++){
                oPermissions = new Order_Taking_Permissions__c(Delivery_Code__c = VFC01_OrderTaking_TestUtilities.PTL_CODE_DIV, User_mandataire__c = userMandataires[i]);
                lPermissions.add(oPermissions);
            }
            if(lPermissions.size()>0) insert lPermissions;
        }
    }

    public static User getUser(){
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = :VFC01_OrderTaking_TestUtilities.USER_PROFILE];
        String uname = 'OrderTaking-'  + String.valueOf(Crypto.getRandomInteger()) + '@test.fr'; // Get Random name
        User user = new User();
        user.username  = uname;
        user.email     = uname;
        user.firstName = 'F';
        user.lastName  = 'L';
        user.alias     = 'LF';
        user.IsActive  = true;
        user.communityNickname = 'LF';
        user.timeZoneSidKey = 'Europe/Paris';
        user.localeSidKey = 'fr_FR_EURO';
        user.languageLocaleKey = 'fr';
        user.emailEncodingKey = 'ISO-8859-1';
        user.profileId = p.Id;
        //user.mandataire__c = 'ABC';
        // Gestion multi-plaques
        user.User_Mandataires__c = 'ABC;CDE';

        System.runAs(new User(Id = UserInfo.getUserId())){ insert user; } // Avoid mixed DML.

        return user;
    }

     public  static Activity_Domain__c getActivityDomain(){  
        Integer activityDomainExternalId = 1; 
        Activity_Domain__c oActivityDomain = new Activity_Domain__c();
        oActivityDomain.name = 'GEC';
        oActivityDomain.ExternalID__c = activityDomainExternalId++;
        insert oActivityDomain;
        return oActivityDomain;
    }
    
     public static  Mandataire__c getMandataire(){
        Mandataire__c oMandataire = new Mandataire__c();        
        oMandataire.name = 'Logigaz';
        oMandataire.ExternalID__c = 'LGZ';
        oMandataire.Active__c = true;
        insert oMandataire;
        
        return oMandataire;
    }    
    
    public static Account getAccount(){
        Account oAccount = new Account();
        oAccount.Name = 'Test Account';
        oAccount.Postal_Code__c= '75001';
        oAccount.City__c = 'Paris';
        oAccount.Activity_Domain__c = getActivityDomain().Id;
        oAccount.Mandataire__c = getMandataire().Id;
        oAccount.Country__c= 'FR';
        oAccount.Email__c='test.mail@mail.com';
        oAccount.Phone='0202020202';
        insert oAccount;  
        
        return oAccount;
    }    
    
}