@isTest
private class GDB_Constants_TEST {
    @isTest
    static void testConstants() {
        GDB_TestDataFactory.createCustomSettings();

        System.assertNotEquals(null, GDB_Constants.sessionKeys, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.checkoutStepURLs, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.pagesURLs, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.articleTypeId, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.activityDomainId, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.orderTypeId, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.orderSplitTypeId, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.guestUserType, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.communityName, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.domainName, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.communityPathPrefix, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.orderStatus, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.orderPaymentStatus, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.orderAction, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.currencySymbol, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.bvDeploymentZone, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.nudgeNbOfMonthsToDisplay, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.nudgeMinimumThreshold, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.nudgeNbOfMonthsMaxToDisplay, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants.nudgeDefaultZipCode, 'The constant should not be null.');
        System.assertEquals(2, GDB_Constants.articleCode.size(), 'The constant should not be null.');
    }
}