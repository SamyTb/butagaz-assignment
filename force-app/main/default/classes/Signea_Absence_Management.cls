public with sharing class Signea_Absence_Management {
    
    public String userMandataires {get; set; }    
    public String selectedUserId { get; set; }  
    
    
    /*ApexPages.StandardController stdController*/
    public Signea_Absence_Management() {
        
        // get user mandataires
        userMandataires = getCurrentUserMandataires();
        
    }
    
    
    // Get current user mandataires 
    public String getCurrentUserMandataires(){
        
        selectedUserId = null;
        String currentUserMandataires = [SELECT Id, User_Mandataires__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].User_Mandataires__c;
        
        return currentUserMandataires;
    }
    
    // Creates list of users with Signea Package License belonging to the connected user's mandataire
    public List<SelectOption> getUserOptions() {
        
        String sMDT = '';
        
        List<SelectOption> userOptions = new List<SelectOption>();
        //userOptions.add(new SelectOption('None','Sélectionner un utilisateur'));
        userOptions.add(new SelectOption('All','Tous les utilisateurs'));
        
        
        if(userMandataires != 'BTZ') {
            sMDT = 'AND User_Mandataires__c = \'' + userMandataires + '\' ';
        }
        System.debug(logginglevel.WARN,'### sMDT = ' + sMDT);
        
        String userQuery = 'SELECT Id, Name ' +
                        'FROM User ' +
                        'WHERE Id IN ( ' +
                            'SELECT UserId ' +
                            'FROM UserPackageLicense ' +
                            'WHERE (PackageLicense.NamespacePrefix = \'Signea\') ' +
                        ') ' +
                        'AND Id IN ( ' +
                            'SELECT CreatedById ' +
                            'FROM Signea__Signer__c ' +
                            'WHERE Signea__Position__c = 2 ' + 
                            'AND Signea__Status__c = \'Ongoing\' ' +
                            'AND Signea__Circuit__r.Signea__Status__c = \'' + String.escapeSingleQuotes('Ongoing') + '\' ' +
                        ') ' +
                        sMDT +
                        'ORDER BY Name';
        
        System.debug(logginglevel.WARN,'### userQuery = ' + userQuery);
        for( User u : Database.query(userQuery) ) {
            userOptions.add(new SelectOption(u.Id, u.Name));
        }
        
        return userOptions;
    }
    
    // Creates list of ongoing circuits linked to the selected user 
    public List<Signea__Signer__c> getCircuitsList(){
        
        List<Signea__Signer__c> circuitsList = new List<Signea__Signer__c>();
        String sMDT = '';
        
        
        System.debug(logginglevel.WARN,'### selectedUserId = ' + selectedUserId);
        
        if(userMandataires != 'BTZ') {
            sMDT = 'AND CreatedBy.User_Mandataires__c = \'' + userMandataires + '\' ';
        }
        
        String circuitsQuery = 'SELECT Id, Signea__Circuit__r.Id, Signea__Circuit__r.Name, Signea__Circuit__r.CreatedDate, Signea__URL__c, ' +
                                'toLabel(Signea__Circuit__r.Signea__Status__c), Signea__User__c, Signea__Circuit__r.CreatedBy.Name, toLabel(Signea__Status__c),' +
                                'Signea__Circuit__r.Signea__Description__c, Signea__Circuit__r.Signea__Expiration_Date__c ' +
                                'FROM Signea__Signer__c ' +
                                'WHERE Signea__Position__c = 2 ' + 
                                'AND Signea__Status__c = \'' + String.escapeSingleQuotes('Ongoing') + '\' ' +
                                'AND Signea__Circuit__r.Signea__Status__c = \'' + String.escapeSingleQuotes('Ongoing') + '\' ';
                                
        
        if(selectedUserId != null && selectedUserId != 'All') {
            circuitsQuery += 'AND Signea__User__c = \'' + String.escapeSingleQuotes(selectedUserId) + '\' ';
        }else{
            circuitsQuery += sMDT;
        }
        
        circuitsQuery += 'ORDER BY Signea__Circuit__r.CreatedBy.Name, Signea__Circuit__r.CreatedDate DESC';
        
        System.debug(logginglevel.WARN,'### circuitsQuery = ' + circuitsQuery);
        circuitsList = Database.query(circuitsQuery);
        
        return circuitsList;
        
    }
    
}