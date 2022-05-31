public with sharing class GDB_Checkout_TotalsController {
    /**
    * get the current basket totals prices
    * @param {String} step
    * @param {Map<String, Object>} guest
    * @return {Map<String, Decimal>}
    */
    @AuraEnabled
    public static Map<String, Decimal> getTotals(String step, Map<String, Object> guest) {
        GDB_AccountMgr.setCurrentGuest(guest);
        Decimal s = Decimal.valueOf(step);
        return GDB_CheckoutUtils.getTotals((s > 0 && s < 4));
    }
}