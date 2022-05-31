@isTest
private class GDB_CurrencyController_TEST {
    @isTest
    static void testValues() {
        GDB_CurrencyController cc = new GDB_CurrencyController();
        cc.currencyISOCode = null;
        cc.currencyISOCode = '€';
        cc.amountValue = 10;

        System.assertEquals('€', cc.currencyISOCode, 'The currency code should not be null.');
        System.assertEquals(10, cc.amountValue, 'The amount value should not be null.');
        System.assertEquals('10,00', cc.formattedAmountValue, 'The formatted amount value should not be null.');

        GDB_CurrencyController cc1 = new GDB_CurrencyController();
        cc1.amountValue = 10.5;
        System.assertEquals('10,50', cc1.formattedAmountValue, 'The formatted amount value should not be null.');
    }
}