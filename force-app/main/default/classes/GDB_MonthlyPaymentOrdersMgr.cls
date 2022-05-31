public class GDB_MonthlyPaymentOrdersMgr {
    
    
    public static void updateMonthlyPaymentOrdersWithSAPData(List<Item_in_Order__c> liio) {
        
        // Manage GDB commandes mensualisees coming from SAP
        Set<Id>orderIdsSet = new Set<Id>();
        Id orderGDBEcomRT = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('GDB Ecom').getRecordTypeId();
        Id iioGDBEcomRT = Schema.SObjectType.Item_in_Order__c.getRecordTypeInfosByName().get('GDB Ecom').getRecordTypeId();
        
        for(Item_in_Order__c iio:liio){
            orderIdsSet.add(iio.Commande__c);
        }
        
        // Get related Orders
        List<Order__c> lOrders = [
            SELECT
            Id,
            Account__c,
            Account__r.FirstName,
            Account__r.LastName,
            Account__r.Email__c,
            Account__r.Phone,
            Account__r.gdb_billing_phone__c,
            Account__r.Street_Number__c,
            Account__r.City_Postal_Code__c,
            Account__r.City_Postal_Code__r.Postal_Code__c,
            Account__r.City_Postal_Code__r.City__r.Name,
            Account__r.Postal_Code__c,
            Account__r.City__c,
            Account__r.Payment_method__c,
            PTL__c,
            PTL__r.First_and_Last_Name__c,
            PTL__r.Address__c,
            PTL__r.Street_number__c,
            PTL__r.Street_type__c,
            PTL__r.Street_name__c,
            PTL__r.City_Postal_Code__c,
            PTL__r.City_Postal_Code__r.Postal_Code__c,
            PTL__r.City_Postal_Code__r.City__r.Name,
            PTL__r.City__c,
            PTL__r.Postal_code__c,
            PTL__r.Phone__c,
            PTL__r.Mobile_Phone_Number__c,
            Order_Type__c,
            gdb_Warehouse__c,
            gdb_Warehouse__r.gdb_reference__c,
            Dispatching_point__c,
            Earliest_Delivery_Date__c,
            gdb_wished_shipping_date__c
            FROM Order__c
            WHERE Id =: orderIdsSet
            AND Order_Type__c = 'ZG02'
        ];
        
        if(lOrders.size()>0){
            
            // Load warehouses in a map to be used later to get update the warehouse from the Order to the ItemInOrder
            Map<String,GDB_Warehouse__c> whMap = new Map<String,GDB_Warehouse__c>();
            
            for(GDB_Warehouse__c oWH : [select gdb_reference__c from GDB_Warehouse__c limit 1000]){
                whMap.put(oWH.gdb_reference__c, oWH);
            }
            
            
            // Update ItemInOrder
            List<Item_in_Order__c> lItemInOrderToUpdate = new List<Item_in_Order__c>();
            Map<Id,Order__c> orderMap = new Map<Id,Order__c>(lOrders);
            
            for(Item_in_Order__c iio:liio){
                if( orderMap.get(iio.Commande__c) != null && orderMap.get(iio.Commande__c).Order_Type__c == 'ZG02' ){
                    /*iio.RecordTypeId = iioGDBEcomRT;
                    System.debug('### iio.RecordTypeId : ' + iio.RecordTypeId);
                    //iio.Unit__c = ;
                    System.debug('### orderMap.get(iio.Commande__c).Dispatching_point__c : ' + orderMap.get(iio.Commande__c).Dispatching_point__c);
                    //GDB_Warehouse__c warehouseReference = new GDB_Warehouse__c(gdb_reference__c = orderMap.get(iio.Commande__c).Dispatching_point__c);
                    
                    //iio.gdb_Warehouse__r = warehouseReference;    //orderMap.get(iio.Commande__c).gdb_Warehouse__c;
                    System.debug('### iio.gdb_Warehouse__c : ' + iio.gdb_Warehouse__c);
                    
                    //iio.gdb_Warehouse__r = new GDB_Warehouse__c(gdb_reference__c = orderMap.get(iio.Commande__c).Dispatching_point__c);
                    System.debug('### orderMap.get(iio.Commande__c).Dispatching_point__c : ' + orderMap.get(iio.Commande__c).Dispatching_point__c);
                    String sWarehouse = orderMap.get(iio.Commande__c).Dispatching_point__c;
                    System.debug('### sWarehouse : ' + sWarehouse);
                    iio.gdb_Warehouse__c = whMap.get(sWarehouse).Id;
                    
                    lItemInOrderToUpdate.add(iio);*/
                    
                    String sWarehouse = orderMap.get(iio.Commande__c).Dispatching_point__c;
                    
                    lItemInOrderToUpdate.add(new Item_in_Order__c(
                        Id = iio.Id, 
                        RecordTypeId = iioGDBEcomRT,
                        gdb_Warehouse__c = whMap.get(sWarehouse).Id
                    ));
                    
                }
            }
            if( lItemInOrderToUpdate.size() > 0 ) update lItemInOrderToUpdate;
            
            
            // Update Order
            List<Order__c> lOrderToUpdate = new List<Order__c>();
            
            for(Order__c o:lOrders){
                
                lOrderToUpdate.add(new Order__c( 
                    Id = o.Id, 
                    Order_Status__c = '4', 
                    RecordTypeId = orderGDBEcomRT,
                    
                    gdb_payment_method_name__c = o.Account__r.Payment_method__c,
                    
                    gdb_billing_firstname__c = o.Account__r.FirstName != null ? o.Account__r.FirstName : '',
                    gdb_billing_lastname__c = o.Account__r.LastName != null ? o.Account__r.LastName : '',
                    gdb_billing_phone__c = o.Account__r.gdb_billing_phone__c != null ? o.Account__r.gdb_billing_phone__c : '',
                    gdb_billing_address1__c = o.Account__r.Street_Number__c != null ? o.Account__r.Street_Number__c : '',
                    gdb_billing_zip__c = o.Account__r.City_Postal_Code__c != null ? o.Account__r.City_Postal_Code__r.Postal_Code__c : o.Account__r.Postal_Code__c,
                    gdb_billing_city__c = o.Account__r.City_Postal_Code__c != null ? o.Account__r.City_Postal_Code__r.City__r.Name : o.Account__r.City__c,
                    gdb_billing_country__c = 'FR',
                    
                    gdb_shipping_firstname__c = '',
                    gdb_shipping_lastname__c = o.PTL__r.First_and_Last_Name__c != null ? o.PTL__r.First_and_Last_Name__c : '',
                    gdb_shipping_phone__c = o.PTL__r.Phone__c != null ? o.PTL__r.Phone__c : o.PTL__r.Mobile_Phone_Number__c,
                    gdb_shipping_address1__c = o.PTL__r.Address__c != null ? o.PTL__r.Address__c : '',  // o.PTL__r.Street_number__c + ' ' + o.PTL__r.Street_type__c + ' ' + o.PTL__r.Street_name__c,
                    gdb_shipping_zip__c = o.PTL__r.City_Postal_Code__c != null ? o.PTL__r.City_Postal_Code__r.Postal_Code__c : o.PTL__r.Postal_code__c,
                    gdb_shipping_city__c = o.PTL__r.City_Postal_Code__c != null ? o.PTL__r.City_Postal_Code__r.City__r.Name : o.PTL__r.City__c,
                    gdb_shipping_country__c = 'FR',
                    
                    gdb_email__c = o.Account__r.Email__c != null ? o.Account__r.Email__c : '',
                    
                    gdb_Warehouse__c = whMap.get(o.Dispatching_point__c).Id,
                    gdb_wished_shipping_date__c = o.Earliest_Delivery_Date__c,
                    /*gdb_Shipping_Method__c = ,*/
                    
                    gdb_Sent_To_SAP__c = True
                ));
            }
            if( lOrderToUpdate.size() > 0 ) update lOrderToUpdate;
        
        }
        
    }
    
}