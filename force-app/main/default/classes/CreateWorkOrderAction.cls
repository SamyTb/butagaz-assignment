public class CreateWorkOrderAction {
    /**
     * createWorkOrders creates a new workorder linked to the order
     *
     * @param {List<ID>} orderIds
     *
     * @return {void}
     */
    @InvocableMethod(label='Create Work Orders' description='Inserts work orders linked to the orders specified.')
    public static void createWorkOrders(List<ID> orderIds) {
    
        PraxedoSettings__c CREATEWORKORDERONORDER = PraxedoSettings__c.getValues('CreateWorkOrderOnOrder');
        PraxedoSettings__c PRAXEDOACCOUNTTOUSE = PraxedoSettings__c.getValues('PraxedoAccountToUse');
        PraxedoSettings__c QUALIFICATIONTYPE = PraxedoSettings__c.getValues('QualificationType');
        PraxedoSettings__c QUALIFICATIONEXPECTEDDURATION = PraxedoSettings__c.getValues('QualificationExpectedDuration');
        PraxedoSettings__c EXPIRATIONDATENBDAYS = PraxedoSettings__c.getValues('ExpirationDateNbDays');
        PraxedoSettings__c EARLIESTDATENBDAYS = PraxedoSettings__c.getValues('EarliestDateNbDays');
        PraxedoSettings__c STATUSONINSERT = PraxedoSettings__c.getValues('StatusOnInsert');
        
        
        Id PraxedoAccountId;
        String sQuantity = '';
        String sEquipmentNameAndQuantity = '';
        String sQTE_66_15_A_LIVRER = '';
        String sQTE_126_8_A_LIVRER = '';
        String sQTE_DEMIPAL_15_A_LIVRER = '';
        String sWarehouseReference = '';
        String sFlag = '';
        String sPhone = '';
        String sMobilePhone = '';
        
        List<WorkOrder> lWOToInsert = new List<WorkOrder>();
        Set<Id> woInsertedLinkedOrderSet = new Set<Id>();
        List<Order__c> lOrdersToUpdate = new List<Order__c>();
        
        
        if (orderIds.size() == 0 || CREATEWORKORDERONORDER.value__c.toLowerCase() != 'true') {
            return;
        }
        
        // Put the input list in a set to avoid duplicates
        Set<ID> orderIdsSet = new Set<ID>();
        orderIdsSet.addAll(orderIds);
        
        // Get the Id of the Praxedo account used
        PraxedoAccountId = [SELECT Id FROM PRAXEDO__MultiAccountsSettings__c WHERE PRAXEDO__Username__c =: PRAXEDOACCOUNTTOUSE.value__c LIMIT 1].Id;
        
        // Retrieve orders' data
        List<Order__c> lOrders= [
            SELECT
            Id,
            Account__r.Email__c,
            Account__r.FirstName,
            Account__r.LastName,
            Activity_Domain__c,
            Full_Address__c,
            gdb_isSample__c,
            gdb_billing_salutation__c,
            gdb_billing_firstname__c,
            gdb_billing_lastname__c,
            gdb_billing_address1__c,
            gdb_billing_address2__c,
            gdb_billing_address3__c,
            gdb_billing_city__c,
            gdb_billing_country__c,
            gdb_billing_phone__c,
            gdb_billing_zip__c,
            gdb_coupon_code__c,
            gdb_customer_firstname__c,
            gdb_customer_lastname__c,
            gdb_customer_title__c,
            gdb_Discount__r.Name,
            gdb_discount_price__c,
            gdb_email__c,
            gdb_multiple_payment__c,
            gdb_multiple_shipping__c,
            gdb_shipping_instructions__c,
            gdb_orderNo__c,
            gdb_payment_date__c,
            gdb_payment_method_name__c,
            gdb_Payment_Method__c,
            gdb_payment_status__c,
            gdb_shipping_salutation__c,
            gdb_shipping_firstname__c,
            gdb_shipping_lastname__c,
            gdb_shipping_address1__c,
            gdb_shipping_address2__c,
            gdb_shipping_address3__c,
            gdb_shipping_city__c,
            gdb_shipping_country__c,
            gdb_shipping_date__c,
            gdb_shipping_method_name__c,
            gdb_Shipping_Method__c,
            gdb_Shipping_Method__r.Name,
            gdb_shipping_phone__c,
            gdb_shipping_price__c,
            gdb_shipping_tax__c,
            gdb_shipping_status__c,
            gdb_shipping_zip__c,
            gdb_total_gross_price__c,
            gdb_total_net_price__c,
            gdb_total_tax__c,
            gdb_authorisation_id__c,
            gdb_transaction_id__c,
            gdb_validation_date__c,
            gdb_validation_token__c,
            gdb_warehouse_email__c,
            gdb_Warehouse__c,
            Name,
            Order_Date_and_Time__c,
            Order_Status__c,
            ExternalID__c,
            Account__c,
            Account__r.ExternalId__c,
            gdb_Warehouse__r.gdb_reference__c,
            gdb_Sent_To_Logistics__c,
            gdb_parent_order__c,
            (
                SELECT Article__c,
                gdb_description__c,
                gdb_name__c,
                gdb_sku__c,
                Article_Name__c,
                gdb_total_gross_price__c,
                gdb_total_net_price__c,
                gdb_total_tax__c,
                gdb_unit_gross_price__c,
                gdb_unit_net_price__c,
                gdb_unit_tax__c,
                Name,
                Quantity__c,
                Unit__c,
                gdb_Warehouse__r.gdb_reference__c,
                gdb_quantitywarehouse__c
                FROM Articles_dans_Commande__r
                WHERE gdb_warehouse__r.gdb_shipping_carrier__c = 'PRAXEDO'
            )
            FROM Order__c
            WHERE Id =: orderIdsSet
            AND Id NOT IN (SELECT Order__c FROM WorkOrder WHERE Order__c =: orderIdsSet)
        ];
        
        
        try {
            
            for(Order__c o:lOrders){
                
                //Order__c o = new Order__c();
                //o = GDB_OrderMgr.getOrderById(orderId);
                
                /*
                // Create the order
                Case c = new Case(
                    W2C_CaseCategory__c = 'CDG04',
                    Origin = System.Label.GDB_contactForm_Origin,
                    Front_Office__c = GDB_Constants.accountMandataireId,
                    Mandataire__c = GDB_Constants.accountMandataireId,
                    Order__c = o.Id,
                    Subject = System.Label.GDB_CommandTypeButagaz,
                    Description = o.gdb_orderNo__c,
                    Activity_Domain__c = o.Activity_Domain__c,
                    Salutation__c = o.gdb_shipping_salutation__c,
                    Firstname__c = o.gdb_shipping_firstname__c,
                    Lastname__c = o.gdb_shipping_lastname__c,
                    SuppliedEmail = o.gdb_email__c,
                    Phone__c = o.gdb_shipping_phone__c,
                    AccountId = o.Account__c  // Récupérer ce champ
                );
                insert c;
                */
                
                // Get Items in Order details
                sQuantity = '';
                sEquipmentNameAndQuantity = '';
                sQTE_66_15_A_LIVRER = '';
                sQTE_126_8_A_LIVRER = '';
                sQTE_DEMIPAL_15_A_LIVRER = '';
                sWarehouseReference = '';
                sFlag = '';
                for(Item_in_Order__c io : o.Articles_dans_Commande__r) {
                    sQuantity = (Integer.valueOf(io.gdb_quantitywarehouse__c) == null) ? String.valueOf(Integer.valueOf(io.Quantity__c)) : String.valueOf(Integer.valueOf(io.gdb_quantitywarehouse__c));
                    sEquipmentNameAndQuantity += sQuantity + ' ' + io.Article_Name__c + ', ';
                    //sEquipmentNameAndQuantity += String.valueOf(Integer.valueOf(io.Quantity__c)) + ' ' + io.Article_Name__c + ', ';
                    
                    /*if(io.Unit__c == 'GDB_P15_1'){
                        sQTE_66_15_A_LIVRER = String.valueOf(Integer.valueOf(io.Quantity__c));
                    }else if(io.Unit__c == 'GDB_P8_1'){
                        sQTE_126_8_A_LIVRER = String.valueOf(Integer.valueOf(io.Quantity__c));
                    }else if(io.Unit__c == 'GDB_P15_DE'){
                        sQTE_DEMIPAL_15_A_LIVRER = String.valueOf(Integer.valueOf(io.Quantity__c));
                    }*/
                    
                    if(io.gdb_sku__c == 'GB_P15_BRA'){
                        sQTE_66_15_A_LIVRER = String.valueOf(Integer.valueOf(io.Quantity__c));
                    }else if(io.gdb_sku__c == 'GB_P08_BRA'){
                        sQTE_126_8_A_LIVRER = String.valueOf(Integer.valueOf(io.Quantity__c));
                    }else if(io.gdb_sku__c == 'GB_P15_DEM'){
                        sQTE_DEMIPAL_15_A_LIVRER = String.valueOf(Integer.valueOf(io.Quantity__c));
                    }
                    
                    // The value of this variable will be replaced for each article because Praxedo only manages one Warehouse per WorkOrder. The value should be the same for all articles managed in Praxedo anyway
                    sWarehouseReference = io.gdb_Warehouse__r.gdb_reference__c;
                }
                sEquipmentNameAndQuantity = sEquipmentNameAndQuantity.removeEnd(', ');
                
                // Manage flags to send to Praxedo
                sFlag += o.gdb_parent_order__c == null ? '' : '8;';  // Child Order
                sFlag += o.gdb_Shipping_Method__c != null && o.gdb_Shipping_Method__r.Name == 'Livraison express' ? '4;' : '';  //  "Livraison express"
                sFlag += o.gdb_Shipping_Method__c != null && o.gdb_Shipping_Method__r.Name == 'Livraison économique' ? '64;' : '';  //  "Livraison économique"
                sFlag += o.gdb_Shipping_Method__c != null && o.gdb_Shipping_Method__r.Name == 'Livraison précise' ? '2048;' : '';  //  "Livraison précise"
                
                sPhone = '';
                sMobilePhone = '';
                if( !String.isBlank(o.gdb_shipping_phone__c) ){
                    if( o.gdb_shipping_phone__c.startsWith('06') || o.gdb_shipping_phone__c.startsWith('07') ){
                        sMobilePhone = o.gdb_shipping_phone__c;
                    }else{
                        sPhone = o.gdb_shipping_phone__c;
                    }
                }

                // Skip to next iteration if no article in this order will be handled by Praxedo. We don't want a WorkOrder to be created
                if(!String.isBlank(sEquipmentNameAndQuantity)){
                
                    // Create the workorder
                    WorkOrder wo = new WorkOrder(
                        AccountId = o.Account__c,
                        //CaseId = o.Id,
                        Order__c = o.Id,
                        PRAXEDO__OrganizationUnitId__c = sWarehouseReference,  // o.gdb_Warehouse__r.gdb_reference__c,
                        PRAXEDO__ExpirationDate__c = o.Order_Date_and_Time__c.addDays(integer.valueof(EXPIRATIONDATENBDAYS.value__c)),
                        PRAXEDO__EarliestDate__c = o.Order_Date_and_Time__c.addDays(integer.valueof(EARLIESTDATENBDAYS.value__c)),
                        Status = STATUSONINSERT.value__c,
                        PRAXEDO__CustomerName__c = o.Account__r.ExternalId__c,
                        PRAXEDO__LocationName__c = o.ExternalID__c,
                        PRAXEDO__EquipmentName__c = sEquipmentNameAndQuantity,
                        Street = (o.gdb_shipping_address1__c == null ? '' : o.gdb_shipping_address1__c) + ' ' + (o.gdb_shipping_address2__c == null ? '' : o.gdb_shipping_address2__c) + ' ' + (o.gdb_shipping_address3__c == null ? '' : o.gdb_shipping_address3__c),
                        PostalCode = o.gdb_shipping_zip__c,
                        City = o.gdb_shipping_city__c,
                        Country = o.gdb_shipping_country__c,
                        PRAXEDO__LocationContact__c = o.gdb_shipping_firstname__c + ' ' + o.gdb_shipping_lastname__c,
                        PRAXEDO__LocationDescription__c = o.gdb_shipping_instructions__c,
                        PRAXEDO__LocationPhone__c = sPhone,
                        PRAXEDO__LocationMobile__c = sMobilePhone,
                        PRAXEDO__LocationEmail1__c = o.gdb_email__c,
                        PRAXEDO__PraxedoAccount__c = PraxedoAccountId,
                        PRAXEDO__QualificationType__c = QUALIFICATIONTYPE.value__c,
                        PRAXEDO__QualificationExpectedDuration__c = integer.valueof(QUALIFICATIONEXPECTEDDURATION.value__c),
                        Quantite_a_livrer_66x15kg__c = sQTE_66_15_A_LIVRER,
                        Quantite_a_livrer_126x8kg__c = sQTE_126_8_A_LIVRER,
                        Quantite_a_livrer_DemiPal15kg__c = sQTE_DEMIPAL_15_A_LIVRER,
                        PRAXEDO__Flag__c = sFlag
                    );
                    lWOToInsert.add(wo);
                    
                }
            
            }
            
            if(lWOToInsert.size()>0){
                insert lWOToInsert;
            }
            
            // Get the work orders that have been inserted
            for(WorkOrder wo:lWOToInsert){
                if(wo.Id != null){
                    if(!woInsertedLinkedOrderSet.contains(wo.Order__c)){
                        woInsertedLinkedOrderSet.add(wo.Order__c);
                    }
                }
            }
            
            // Set gdb_Sent_To_Logistics__c flag to true on the orders linked to the inserted work orders
            for(Order__c o:lOrders){
                if(woInsertedLinkedOrderSet.contains(o.Id)){
                    o.gdb_Sent_To_Logistics__c = true;
                    lOrdersToUpdate.add(o);
                }               
            }
            
            if(lOrdersToUpdate.size()>0){
                update lOrdersToUpdate;
            }
            
            
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
        }

    }
}