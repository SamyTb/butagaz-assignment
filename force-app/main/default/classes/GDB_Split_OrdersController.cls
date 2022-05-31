public with sharing class GDB_Split_OrdersController {

    Order__c currentOrder;
    ApexPages.StandardController stdController;
    public List < Order__c > parentOrderAndChilds {get; set;}
    public Boolean isOrderToValidate {get; set;}

    /**
     * GDB_Split_OrdersController description
     * @param  controller controller description
     * @return            return description
     */
    public GDB_Split_OrdersController(ApexPages.StandardController controller) {
        this.stdController = controller;
        this.currentOrder = GDB_OrderMgr.getOrderById(((Order__c) this.stdController.getRecord()).Id);

        this.isOrderToValidate = '8'.equals(this.currentOrder.Order_status__c) && 'SUCCESS'.equalsIgnoreCase(this.currentOrder.gdb_payment_status__c);

        if (!isOrderToValidate) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.GDB_splitOrder_bad_order));
        }

        this.parentOrderAndChilds = new List<Order__c>();
        //Add parent order first
        this.parentOrderAndChilds.add(this.currentOrder);
        //Add child orders
        this.parentOrderAndChilds.addAll(this.getChildOrders());
    }

    /**
     * getChildOrders description
     * @return   return description
     */
    private List < Order__c > getChildOrders() {
        return GDB_OrderMgr.getChildOrders(this.currentOrder.Id);
    }


    /**
     * validate Validate the divide order
     * @return   {PageReference}
     */
    public PageReference validate() {
        this.isOrderToValidate = true;
        Map < String, Decimal > initialQties = new Map<String, Decimal>();
        Map < String, Decimal > initialQtiesWarehouseCoef = new Map<String, Decimal>();
        Decimal quantity = 0;
        Boolean isParentOrderBecomeEmpty = false;
        Order__c parentOrder = this.parentOrderAndChilds.get(0);

        // Store parent order quantity in Map
        for (Item_In_Order__c parentItems: parentOrder.Articles_dans_Commande__r) {
            initialQties.put(parentItems.gdb_sku__c, parentItems.Quantity__c);
            
            // Get coef warehouse for Items
            if(parentItems.gdb_quantitywarehouse__c != null && parentItems.gdb_quantitywarehouse__c != 0){
                decimal coef = parentItems.gdb_quantitywarehouse__c / parentItems.Quantity__c;             
                initialQtiesWarehouseCoef.put(parentItems.gdb_sku__c, coef);
            }
            else{
                initialQtiesWarehouseCoef.put(parentItems.gdb_sku__c, 1);
            }
        }


        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();

            // Update items in order of child orders
            for (Integer i = 1; i < parentOrderAndChilds.size(); i++) {
                Order__c childOrder = parentOrderAndChilds.get(i);
                for (Item_in_order__c childItem: childOrder.Articles_dans_Commande__r) {
                    quantity = initialQties.get(childItem.gdb_sku__c) - childItem.Quantity__c;
                    initialQties.put(childItem.gdb_sku__c, quantity);
                    
                    // Update Qte warehouse with coef
                    Decimal coef = initialQtiesWarehouseCoef.get(childItem.gdb_sku__c);
                    if(coef != null && coef != 0){                        
	                    childItem.gdb_quantitywarehouse__c = childItem.Quantity__c * coef;                    
                    }
                    else{
                        childItem.gdb_quantitywarehouse__c = childItem.Quantity__c; 
                    }                    
                }
                GDB_OrderMgr.recalculateOrder(childOrder, false);
                GDB_OrderMgr.updateOrderStatus(childOrder, '4');
                GDB_OrderMgr.updatePaymentStatus(childOrder, parentOrder.gdb_payment_status__c); 
            }

            // Check if parent order is empty
            List < Decimal > parentOrderQty = initialQties.values();
            Decimal remainingQty = 0;
            for (Decimal qty: parentOrderQty) {
                remainingQty += qty;
            }

            if (remainingQty.intValue() == 0) {
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.GDB_splitOrder_parent_have_one_line));
                return null;
            }

            // Update items in order of parent order
            for (Item_In_Order__c parentItems: parentOrder.Articles_dans_Commande__r) {                
                Decimal Qte = initialQties.get(parentItems.gdb_sku__c);
                Decimal coef = initialQtiesWarehouseCoef.get(parentItems.gdb_sku__c);
                
                parentItems.Quantity__c = Qte;
                
                // Update Qte warehouse with coef
                if(coef != null && coef != 0){
	                parentItems.gdb_quantitywarehouse__c = Qte * coef;                    
                }
                else{
                    parentItems.gdb_quantitywarehouse__c = Qte;
                }                               
                update parentItems;
            }

            // Recalculate total price in parent order
            GDB_OrderMgr.recalculateOrder(parentOrder, true);
            GDB_OrderMgr.updateOrderStatus(parentOrder, '4');

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.GDB_splitOrder_success));

            this.isOrderToValidate = false;
        } catch (Exception ex) {
            Database.rollback(sp);
            System.debug(System.LoggingLevel.ERROR, 'An error occured during the split order "' + this.currentOrder
                .gdb_orderNo__c + '": ' + ex.getMessage());
        }
        return null;
    }

    /**
     * backToOrder Returns to the parent order page
     * @return   {PageReference}
     */
    public PageReference backToOrder() {
        PageReference nextPage = new PageReference('/' + this.currentOrder.Id);
        return nextPage;
    }
}