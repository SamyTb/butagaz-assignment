@isTest
private class GDB_CustomSettingsMgr_TEST {

    @isTest
    static void testCustomSettings(){
        GDB_TestDataFactory.createCustomSettings();

        GDB_CustomSettingsMgr customSettings = GDB_CustomSettingsMgr.self();

        String mercanetMerchantID = customSettings.getMercanetMerchantID();
        String mercanetSecretKey = customSettings.getMercanetSecretKey();
        String mercanetUrl = customSettings.getMercanetURL();
        Integer mercanetPaymentTime = customSettings.getMercanetPaymentTimes();
        Integer mercanetTimeBetweenPayments = customSettings.getMercanetTimeBetweenPayments();
        String fraudData = customSettings.getMercanetFraudData();
        String guestType = customSettings.getGuestType();
        String standardUserType = customSettings.getStandardUserType();
        String activityDomainType = customSettings.getActivityDomainType();
        String articleType = customSettings.getArticleType();
        String orderType = customSettings.getOrderType();
        String orderSplitType = customSettings.getOrderSplitType();
        Integer maximumUseOfPromotionPerUser = customSettings.getMaximumUseOfPromotionPerUser();
        String personAccountType = customSettings.getPersonAccountType();
        String accountMandataire = customSettings.getAccountMandataire();
        String orderOrigin = customSettings.getOrderOrigin();
        String orderTypeOrigin = customSettings.getOrderTypeOrigin();
        String productSale = customSettings.getProductScale();
        String mercanetInterfaceVersion = customSettings.getMercanetInterfaceVersion();
        String mercanetKeyVersion = customSettings.getMercanetKeyVersion();
        Boolean activeErrorTracing = customSettings.isErrorTracingActive();
        Boolean iactiveGoogleAnalyticsTracking = customSettings.isGoogleAnalyticsTrackingActive();
        Integer multiplePaymentThreshold = customSettings.getMultiplePaymentThreshold();
        Integer nudgeNbOfMonthsToDisplay = customSettings.getNudgeNbOfMonthsToDisplay();
        Integer nudgeNbOfMonthsMaxToDisplay = customSettings.getNudgeNbOfMonthsMaxToDisplay();
        Integer nudgeMinimumThreshold = customSettings.getNudgeMinimumThreshold();
        String nudgeDefaultZipCode = customSettings.getNudgeDefaultZipCode();
        String docapostEndpoint = customSettings.getDocaPostEndpoint();
        String docapostCertificate = customSettings.getDocaPostCertificateName();
        Integer sponsorshipPrice = customSettings.getSponsorshipPrice();
        Integer sponsorshipShippingMinimumPrice = customSettings.getSponsorshipShippingMinimumPrice();
        Datetime sponsorshipMaxEndDate = customSettings.getSponsorshipMaxEndDate();
        Decimal mercanetPaymentTimesPrice = customSettings.getMercanetPaymentTimesPrice();
        String bulkDeliveredZipCodes = customSettings.getBulkDeliveredZipCodes(); 
    }

    @isTest
    static void testCustomSettingsCallTwoTimes(){
        GDB_CustomSettingsMgr customSettings = GDB_CustomSettingsMgr.self();
        GDB_CustomSettingsMgr customSettings2 = GDB_CustomSettingsMgr.self();
    }

}