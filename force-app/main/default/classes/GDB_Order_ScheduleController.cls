public with sharing class GDB_Order_ScheduleController {
    public GDB_Order_ScheduleController() {}

    private Map<String, Object[]> details;

    public Order__c order {
        get;
        set {
            if (value != null) {
                order = GDB_OrderMgr.getOrderById(value.Id);
                this.details = GDB_mercanet.getMultiplePaymentDetails(order.gdb_total_gross_price__c, order.gdb_orderNo__c, order.Order_Date_and_Time__c, false);
            }
        }
    }

    public List<Map<String, Object>> infos {
        get {
            List<Map<String, Object>> i = new List<Map<String, Object>>();

            if (this.details != null) {
                DateTime[] d = (DateTime[])details.get('dates');

                for(Integer j = 0; j < d.size(); ++j) {
                    i.add(new Map<String, Object> {
                        'date' => d[j],
                        'label' => 'GDB_emailOrderSchedulePayment_' + (j + 1)
                    });
                }
            }

            return i;
        }
    }
}