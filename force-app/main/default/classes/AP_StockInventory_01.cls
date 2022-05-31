public class AP_StockInventory_01 {
    
    private static boolean alreadyUpdatedSI = false;

    public static void recoverLastSIDate(List<Stock_Inventory__c> lSI){
        String sKeySI = '';
        Set<String> setSI = new Set<String>();
        List<Id> listUniqueSIId = new list<Id>();
        List<PTL__c> lPTLToUpdate = new list<PTL__c>();
        
        map<id,date> mapPTLLastSIRackDate = new map<id,date>();
        map<id,date> mapPTLLastSIDABDate = new map<id,date>();
        
        System.debug('START method AP_StockInventory_01.recoverLastSIDate');        
        
        // Recover a list of unique PTL ids
        for(Stock_Inventory__c oSI:lSI){
            sKeySI = oSI.PTL__c;
            
            if(setSI.add(sKeySI))
                listUniqueSIId.add(oSI.PTL__c); 
        }

        // Query PTL fields that will be populated
        Map<ID, PTL__c> mapPTL = new Map<ID, PTL__c>([SELECT Id, Last_Stock_Inventory_Date_Rack__c, Last_Stock_Inventory_Date_DAB__c FROM PTL__c WHERE Id in :listUniqueSIId]);

        // Set fields to update to null to erase previous values
        for (ID idKey : mapPTL.keyset()) {
            mapPTL.get(idKey).Last_Stock_Inventory_Date_Rack__c = null;
            mapPTL.get(idKey).Last_Stock_Inventory_Date_DAB__c = null;
        }

        
        System.debug('[AP_StockInventory_01.recoverLastSIDate] listUniqueSIId Counts: ' + listUniqueSIId.size());
        
        if(listUniqueSIId.size() > 0){
            // Recover Last SI Date per PTL and per stock inventory type
            AggregateResult[] aggrSI = [Select MAX(Inventory_Date__c) Inventory_Date__c, PTL__c, Type__c from Stock_Inventory__c where PTL__c in :listUniqueSIId group by PTL__c, Type__c order by PTL__c];

            // Recover information to Update
            for (AggregateResult ar:aggrSI){
                
                if(mapPTL.containsKey((Id)ar.get('PTL__c'))) {

                    if( (String)ar.get('Type__c') == 'Rack' ){
                        mapPTL.get((Id)ar.get('PTL__c')).Last_Stock_Inventory_Date_Rack__c = (Date)ar.get('Inventory_Date__c');
                    }else if( (String)ar.get('Type__c') == 'DAB' ){
                        mapPTL.get((Id)ar.get('PTL__c')).Last_Stock_Inventory_Date_DAB__c = (Date)ar.get('Inventory_Date__c');
                    }
                }
            }
            
            System.debug('[AP_StockInventory_01.recoverLastSIDate] mapPTL Counts: ' + mapPTL.size());

            // Update database      
            if(mapPTL.size()>0){
                try{
                    update mapPTL.values();
                }
                catch(DmlException e){
                    //sendErrorMail(e.getMessage());
                }
            }
        }
        
        System.debug('END method AP_StockInventory_01.recoverLastSIDate');            
    }

    /*public static void sendErrorMail(String errorMessage){              
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'supportbfi@Butagaz.com'};
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('supportbfi@Butagaz.com');  
        mail.setSenderDisplayName('Apex error message');
        mail.setSubject('Error from Org : ' + UserInfo.getOrganizationName());
        mail.setPlainTextBody(errorMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }*/

    public static boolean hasAlreadyUpdatedSI() {
        return alreadyUpdatedSI;
    }
    	
    public static void setAlreadyUpdatedSI(boolean b) {
        alreadyUpdatedSI = b;
    }

}