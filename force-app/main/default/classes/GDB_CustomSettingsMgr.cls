public with sharing class GDB_CustomSettingsMgr {
    /**
     * The SINGLETON handle to the instance 
     */
    private static GDB_CustomSettingsMgr self;


    /**
     * Initialize the SINGLETON instance or return it if already exists
     *
     * @returns {SSCSiteCustomSettingHelper}
     */
    public static GDB_CustomSettingsMgr self() {
        if (self != null) {
            return self;
        }

        // To create org wide defaults in new org automatically. This will prevent NPE's in future.
        if (GDB_Configurations__c.getInstance() == null) {
            upsert new GDB_Configurations__c(SetupOwnerId = Userinfo.getOrganizationId());
        }

        self = new GDB_CustomSettingsMgr();
        return self;
    }

    private GDB_CustomSettingsMgr() {}

    public String getMercanetMerchantID() {
        return GDB_Configurations__c.getInstance().mercanetMerchantID__c;
    }

    public String getMercanetSecretKey() {
        return GDB_Configurations__c.getInstance().mercanetSecretKey__c;
    }

    public String getMercanetURL() {
        return GDB_Configurations__c.getInstance().mercanetURL__c;
    }

    // Cast field in integer because the number of payment should always be an integer value
    public Integer getMercanetPaymentTimes() {
        return Integer.valueOf(GDB_Configurations__c.getInstance().mercanetPaymentTimes__c);
    }

    // Cast field in integer because the time between payments should always be an integer value
    public Integer getMercanetTimeBetweenPayments() {
        return Integer.valueOf(GDB_Configurations__c.getInstance().mercanetTimeBetweenPayments__c);
    }

    public String getMercanetFraudData() {
        return GDB_Configurations__c.getInstance().mercanetFraudData__c;
    }

    public String getGuestType() {
        return GDB_Configurations__c.getInstance().guestType__c;
    }

    public String getStandardUserType() {
        return GDB_Configurations__c.getInstance().standardUserType__c;
    }

    public String getActivityDomainType() {
        return GDB_Configurations__c.getInstance().activityDomainType__c;
    }

    public String getArticleType() {
        return GDB_Configurations__c.getInstance().articleType__c;
    }

    public String getOrderType() {
        return GDB_Configurations__c.getInstance().orderType__c;
    }

    public String getOrderSplitType() {
        return GDB_Configurations__c.getInstance().orderSplitType__c;
    }

    public Integer getMaximumUseOfPromotionPerUser() {
        return Integer.valueOf(GDB_Configurations__c.getInstance().maximumUseOfPromotionPerUser__c);
    }

    public String getAccountMandataire() {
        return GDB_Configurations__c.getInstance().accountMandataireId__c;
    }

    public String getOrderOrigin() {
        return GDB_Configurations__c.getInstance().orderOrigin__c;
    }

    public String getOrderTypeOrigin() {
        return GDB_Configurations__c.getInstance().orderTypeOrigin__c;
    }

    public String getProductScale() {
        return GDB_Configurations__c.getInstance().productScale__c;
    }

    public String getPersonAccountType() {
        return GDB_Configurations__c.getInstance().personAccountTypeId__c;
    }
    
    public String getMercanetInterfaceVersion() {
        return GDB_Configurations__c.getInstance().mercanetInterfaceVersion__c;
    }

    public String getMercanetKeyVersion() {
        return GDB_Configurations__c.getInstance().mercanetKeyVersion__c;
    }

    public Boolean isErrorTracingActive() {
        return GDB_Configurations__c.getInstance().activateErrorTracing__c;
    }

    public Boolean isGoogleAnalyticsTrackingActive() {
        return GDB_Configurations__c.getInstance().activateGoogleAnalyticsTracking__c; 
    }
    
    public Integer getMultiplePaymentThreshold() {
        return Integer.valueOf(GDB_Configurations__c.getInstance().Multiple_payment_threshold__c);
    }
    
    public String getDocaPostEndpoint() {
        return String.valueOf(GDB_Configurations__c.getInstance().docapost_endpoint__c);
    }
    
    public String getDocaPostCertificateName() {
        return String.valueOf(GDB_Configurations__c.getInstance().docapost_certificate_name__c);
    }
    
    public Integer getNudgeNbOfMonthsToDisplay() {
        return Integer.valueOf(GDB_Product_Nudge__c.getInstance().gdb_display_nb_months__c);
    }
    
    public Integer getNudgeNbOfMonthsMaxToDisplay() {
        return Integer.valueOf(GDB_Product_Nudge__c.getInstance().gdb_display_nb_months_max__c);
    }
    
    public Integer getNudgeMinimumThreshold() {
        return Integer.valueOf(GDB_Product_Nudge__c.getInstance().gdb_min_threshold__c);
    }
    /**
     * getNudgeDefaultZipCode Return the default zipcode to use with nudge
     * @return {String}
     */
    public String getNudgeDefaultZipCode() {
        return GDB_Product_Nudge__c.getInstance().gdb_default_zipcode__c;
    }

    /** SPONSORSHIP */
    /**
     * getSponsorshipPrice
     * @return
     */
    public Integer getSponsorshipPrice() {
        return Integer.valueOf(GDB_Configurations__c.getInstance().gdb_parrainage_montant__c);
    }

    /**
     * getSponsorshipShippingMinimumPrice
     * @return
     */
    public Integer getSponsorshipShippingMinimumPrice() {
        return Integer.valueOf(GDB_Configurations__c.getInstance().gdb_parrainage_shipping_minimum_price__c);
    }

    /**
     * getSponsorshipMaxEndDate
     * @return
     */
    public Datetime getSponsorshipMaxEndDate() {
        return GDB_Configurations__c.getInstance().gdb_parrainage_max_end_date__c;
    }

    public Decimal getMercanetPaymentTimesPrice() {
        return GDB_Configurations__c.getInstance().mercanetPaymentTimesPrice__c;
    }
    
    public String getBulkDeliveredZipCodes() {
        return GDB_Configurations__c.getInstance().GDB_Bulk_Delivered_Zip_Codes__c;
    }
}