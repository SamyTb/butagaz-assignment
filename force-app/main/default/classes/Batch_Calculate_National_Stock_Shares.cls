global class Batch_Calculate_National_Stock_Shares implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    /**
    * Execute the schedulable batch
    * @param {SchedulableContext} context
    */
    public void execute(SchedulableContext context) 
    {
        Database.executeBatch(this);
    }
    
    /**
    * Start the current batch
    * @param {Database.BatchableContext} BC
    */
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        system.debug(LoggingLevel.WARN, 'Batch_Calculate_National_Stock_Shares START');

        /*return Database.getQueryLocator([SELECT Brand__c, Brand__r.Name__c, PTL_Stock_Share_10_13__c, PTL_Stock_Share_5_6__c, PTL_Stock_Share_35__c, PTL_Stock_Share_Total__c,
                                            Stock_Inventory__r.Type__c, Stock_Inventory__r.PTL__r.Enseigne__c, Stock_Inventory__r.PTL__r.Sous_canal__c
                                            FROM Stock_Inventory_Brand__c
                                            WHERE Stock_Inventory__r.T_IsPTLLastSIDate__c = True
                                            AND Stock_Inventory__r.PTL__r.Actif_Filtre__c = 1
                                            AND Presence__c = True
                                            AND (Stock_Inventory__r.PTL__r.Enseigne__c != null or Stock_Inventory__r.PTL__r.Sous_canal__c != null)
                                            ORDER BY Stock_Inventory__r.PTL__r.Enseigne__c, Stock_Inventory__r.PTL__r.Sous_canal__c, Brand__r.Name__c]);*/
        return Database.getQueryLocator([select Id, PTL_Stock_Share_10_13__c, PTL_Stock_Share_5_6__c, PTL_Stock_Share_35__c, PTL_Stock_Share_Total__c, 
                                            Stock_Inventory__r.Type__c, Stock_Inventory__r.PTL__r.Enseigne__c, Stock_Inventory__r.PTL__r.Sous_canal__c
                                            from Stock_Inventory_Brand__c
                                            where Stock_Inventory__r.T_IsPTLLastSIDate__c = True
                                            and Stock_Inventory__r.PTL__r.Actif_Filtre__c = 1
                                            and Presence__c = True
                                            and (Stock_Inventory__r.PTL__r.Enseigne__c != null or Stock_Inventory__r.PTL__r.Sous_canal__c != null)
                                            order by Stock_Inventory__r.PTL__r.Enseigne__c, Stock_Inventory__r.PTL__r.Sous_canal__c, Brand__r.Name__c]);
    }
    
    /**
    * execute the current batch
    * @param {Database.BatchableContext} BC
    * @param {List<Stock_Inventory_Brand__c>} sibList
    */
    global void execute(Database.BatchableContext BC, List<Stock_Inventory_Brand__c> sibList){

        List<Stock_Inventory_National_Share__c> sinsListToInsert = new List<Stock_Inventory_National_Share__c>();  // Final list to insert

        // Enseigne / Rack
        for(AggregateResult ar : [select Brand__c, Brand__r.Name__c, avg(PTL_Stock_Share_10_13__c) Stock_Share_10_13__c, avg(PTL_Stock_Share_5_6__c) Stock_Share_5_6__c, 
                                        avg(PTL_Stock_Share_35__c) Stock_Share_35__c, avg(PTL_Stock_Share_Total__c) Stock_Share_Total__c, 
                                        Stock_Inventory__r.Type__c InvType, Stock_Inventory__r.PTL__r.Enseigne__c Enseigne
                                        from Stock_Inventory_Brand__c
                                        where Presence__c = True
                                        and Stock_Inventory__r.Type__c = 'Rack'
                                        and Stock_Inventory__r.PTL__r.Enseigne__c != null
                                        and Id =: sibList
                                        group by Brand__c, Brand__r.Name__c, Stock_Inventory__r.Type__c, Stock_Inventory__r.PTL__r.Enseigne__c
                                        order by Brand__r.Name__c])
        {
            if( ar.get('Stock_Share_10_13__c') != null || ar.get('Stock_Share_5_6__c') != null || ar.get('Stock_Share_35__c') != null || ar.get('Stock_Share_Total__c') != null ){
                
                system.debug(LoggingLevel.WARN, 'Enseigne / Rack');

                Stock_Inventory_National_Share__c sins = new Stock_Inventory_National_Share__c();
                sins.Brand__c = (Id) ar.get('Brand__c');
                sins.Enseigne__c = (String) ar.get('Enseigne');
                //sins.Sous_canal__c = (String) ar.get('Subchannel');
                sins.Stock_Share_10_13__c = (Decimal) ar.get('Stock_Share_10_13__c');
                sins.Stock_Share_5_6__c = (Decimal) ar.get('Stock_Share_5_6__c');
                sins.Stock_Share_35__c = (Decimal) ar.get('Stock_Share_35__c');
                sins.Stock_Share_Total__c = (Decimal) ar.get('Stock_Share_Total__c');
                sins.Type__c = (String) ar.get('InvType');

                sinsListToInsert.add(sins);
                system.debug(LoggingLevel.WARN, 'Enseigne / Rack : ' + sinsListToInsert.size());
            }
        }
        
        // Enseigne / DAB
        for(AggregateResult ar : [select Brand__c, Brand__r.Name__c, avg(PTL_Stock_Share_10_13__c) Stock_Share_10_13__c, avg(PTL_Stock_Share_5_6__c) Stock_Share_5_6__c, 
                                        avg(PTL_Stock_Share_35__c) Stock_Share_35__c, avg(PTL_Stock_Share_Total__c) Stock_Share_Total__c, 
                                        Stock_Inventory__r.Type__c InvType, Stock_Inventory__r.PTL__r.Enseigne__c Enseigne
                                        from Stock_Inventory_Brand__c
                                        where Presence__c = True
                                        and Stock_Inventory__r.Type__c = 'DAB'
                                        and Stock_Inventory__r.PTL__r.Enseigne__c != null
                                        and Id =: sibList
                                        group by Brand__c, Brand__r.Name__c, Stock_Inventory__r.Type__c, Stock_Inventory__r.PTL__r.Enseigne__c
                                        order by Brand__r.Name__c])
        {
            if( ar.get('Stock_Share_10_13__c') != null || ar.get('Stock_Share_5_6__c') != null || ar.get('Stock_Share_35__c') != null || ar.get('Stock_Share_Total__c') != null ){
                
                system.debug(LoggingLevel.WARN, 'Enseigne / DAB');

                Stock_Inventory_National_Share__c sins = new Stock_Inventory_National_Share__c();
                sins.Brand__c = (Id) ar.get('Brand__c');
                sins.Enseigne__c = (String) ar.get('Enseigne');
                //sins.Sous_canal__c = (String) ar.get('Subchannel');
                sins.Stock_Share_10_13__c = (Decimal) ar.get('Stock_Share_10_13__c');
                sins.Stock_Share_5_6__c = (Decimal) ar.get('Stock_Share_5_6__c');
                sins.Stock_Share_35__c = (Decimal) ar.get('Stock_Share_35__c');
                sins.Stock_Share_Total__c = (Decimal) ar.get('Stock_Share_Total__c');
                sins.Type__c = (String) ar.get('InvType');

                sinsListToInsert.add(sins);
                system.debug(LoggingLevel.WARN, 'Enseigne / DAB : ' + sinsListToInsert.size());
            }
        }

        // Subchannel / Rack
        for(AggregateResult ar : [select Brand__c, Brand__r.Name__c, avg(PTL_Stock_Share_10_13__c) Stock_Share_10_13__c, avg(PTL_Stock_Share_5_6__c) Stock_Share_5_6__c, 
                                        avg(PTL_Stock_Share_35__c) Stock_Share_35__c, avg(PTL_Stock_Share_Total__c) Stock_Share_Total__c, 
                                        Stock_Inventory__r.Type__c InvType, Stock_Inventory__r.PTL__r.Sous_canal__c Subchannel
                                        from Stock_Inventory_Brand__c
                                        where Presence__c = True
                                        and Stock_Inventory__r.Type__c = 'Rack'
                                        and Stock_Inventory__r.PTL__r.Sous_canal__c != null
                                        and Id =: sibList
                                        group by Brand__c, Brand__r.Name__c, Stock_Inventory__r.Type__c, Stock_Inventory__r.PTL__r.Sous_canal__c
                                        order by Brand__r.Name__c])
        {
            if( ar.get('Stock_Share_10_13__c') != null || ar.get('Stock_Share_5_6__c') != null || ar.get('Stock_Share_35__c') != null || ar.get('Stock_Share_Total__c') != null ){
                
                system.debug(LoggingLevel.WARN, 'Subchannel / Rack');

                Stock_Inventory_National_Share__c sins = new Stock_Inventory_National_Share__c();
                sins.Brand__c = (Id) ar.get('Brand__c');
                //sins.Enseigne__c = (String) ar.get('Enseigne');
                sins.Sous_canal__c = (String) ar.get('Subchannel');
                sins.Stock_Share_10_13__c = (Decimal) ar.get('Stock_Share_10_13__c');
                sins.Stock_Share_5_6__c = (Decimal) ar.get('Stock_Share_5_6__c');
                sins.Stock_Share_35__c = (Decimal) ar.get('Stock_Share_35__c');
                sins.Stock_Share_Total__c = (Decimal) ar.get('Stock_Share_Total__c');
                sins.Type__c = (String) ar.get('InvType');

                sinsListToInsert.add(sins);
                system.debug(LoggingLevel.WARN, 'Subchannel / Rack : ' + sinsListToInsert.size());
            }
        }


        // Subchannel / DAB
        for(AggregateResult ar : [select Brand__c, Brand__r.Name__c, avg(PTL_Stock_Share_10_13__c) Stock_Share_10_13__c, avg(PTL_Stock_Share_5_6__c) Stock_Share_5_6__c, 
                                        avg(PTL_Stock_Share_35__c) Stock_Share_35__c, avg(PTL_Stock_Share_Total__c) Stock_Share_Total__c, 
                                        Stock_Inventory__r.Type__c InvType, Stock_Inventory__r.PTL__r.Sous_canal__c Subchannel
                                        from Stock_Inventory_Brand__c
                                        where Presence__c = True
                                        and Stock_Inventory__r.Type__c = 'DAB'
                                        and Stock_Inventory__r.PTL__r.Sous_canal__c != null
                                        and Id =: sibList
                                        group by Brand__c, Brand__r.Name__c, Stock_Inventory__r.Type__c, Stock_Inventory__r.PTL__r.Sous_canal__c
                                        order by Brand__r.Name__c])
        {
            if( ar.get('Stock_Share_10_13__c') != null || ar.get('Stock_Share_5_6__c') != null || ar.get('Stock_Share_35__c') != null || ar.get('Stock_Share_Total__c') != null ){
                
                system.debug(LoggingLevel.WARN, 'Subchannel / DAB');

                Stock_Inventory_National_Share__c sins = new Stock_Inventory_National_Share__c();
                sins.Brand__c = (Id) ar.get('Brand__c');
                //sins.Enseigne__c = (String) ar.get('Enseigne');
                sins.Sous_canal__c = (String) ar.get('Subchannel');
                sins.Stock_Share_10_13__c = (Decimal) ar.get('Stock_Share_10_13__c');
                sins.Stock_Share_5_6__c = (Decimal) ar.get('Stock_Share_5_6__c');
                sins.Stock_Share_35__c = (Decimal) ar.get('Stock_Share_35__c');
                sins.Stock_Share_Total__c = (Decimal) ar.get('Stock_Share_Total__c');
                sins.Type__c = (String) ar.get('InvType');

                sinsListToInsert.add(sins);
                system.debug(LoggingLevel.WARN, 'Subchannel / DAB : ' + sinsListToInsert.size());
            }
        }

        // Delete all records from Stock_Inventory_National_Share__c object
        delete [select id from Stock_Inventory_National_Share__c];
        
        // Insert new records from calculation
        system.debug(LoggingLevel.WARN, '### sinsListToInsert.size() : ' + sinsListToInsert.size());
        if(sinsListToInsert.size()>0) insert sinsListToInsert;
        
        system.debug(LoggingLevel.WARN, 'Batch_Calculate_National_Stock_Shares END');
    }
    
    /**
    * Finish the current batch
    * @param {Database.BatchableContext} BC
    */
    global void finish( Database.BatchableContext BC ){
        /*// Send an email after the batch completes
        string sInstanceName = '';
        List<String> lMailingList = new List<String>();
        lMailingList.addAll(AP_PricingUtilities.getCustomSettingValue('MailingList').split(';'));
        
        // Get SFDC instance name
        if(UserInfo.getUserName().substringAfterLast('.com') != null){
            sInstanceName = UserInfo.getUserName().substringAfterLast('.');
        }else{
            sInstanceName = 'PROD';
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(lMailingList);
        mail.setSubject('BobContact | ' + sInstanceName + ' | Batch_Counting_PTL_ActivityHistory');
        mail.setPlainTextBody('Le batch Apex est terminé. ' + string.valueof(this.iPTLToUpdateSize) + ' PTLs ont été mis à jour.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
    }
}