public with sharing class GDB_Constants_B2B {
    
    /**
     * This map will store all page URLs for B2B
     */
    public static Map<Integer, String> pagesURLsB2B = new Map<Integer, String>{
        1 => System.Label.GDB_B2B_link_loginpage,
        2 => System.Label.GDB_B2B_link_myaccount,
        3 => System.Label.GDB_B2B_link_myorder,
        4 => System.Label.GDB_link_logout
    };

    /** 
     * This map will store all checkout page URLs
     */
    public static Map<Integer, String> checkoutStepURLsB2B = new Map<Integer, String>{         
        1 => System.Label.GDB_link_addresses,
        5 => System.Label.GDB_link_confirmation
    };

    /**
     * Ecommerce article record type.
     */
    public static Id accountRecordTypeId = GDB_CustomMetadataMgr.self().getB2BAccountType();    
    public static Id B2BUserTypeId = GDB_CustomMetadataMgr.self().getB2BUserType();
    public static Id articleTypeId = GDB_CustomSettingsMgr.self().getArticleType();
    public static Id activityDomainId = GDB_CustomSettingsMgr.self().getActivityDomainType();
    public static Id orderTypeId = GDB_CustomSettingsMgr.self().getOrderType();
    public static Id orderSplitTypeId = GDB_CustomSettingsMgr.self().getOrderSplitType();
    public static String orderOrigin = GDB_CustomSettingsMgr.self().getOrderOrigin();
    public static String orderType = GDB_CustomSettingsMgr.self().getOrderTypeOrigin();
    public static Id accountMandataireId = GDB_CustomSettingsMgr.self().getAccountMandataire();
    public static String productScale = GDB_CustomSettingsMgr.self().getProductScale();
    public static Id personAccountId = GDB_CustomSettingsMgr.self().getPersonAccountType();
    public static Boolean isErrorTracingActive = GDB_CustomSettingsMgr.self().isErrorTracingActive();
    public static Boolean isGoogleAnalyticsTrackingActive = GDB_CustomSettingsMgr.self().isGoogleAnalyticsTrackingActive();

    /**
     * Guest user type.
     */
    public static String guestUserType = GDB_CustomSettingsMgr.self().getGuestType();

    /**
     * Standard user type.
     */
    public static String standardUserType = GDB_CustomSettingsMgr.self().getStandardUserType();

    /**
     * Community path prefix.
     */
    public static String communityPathPrefix = GDB_CustomMetadataMgr.self().getCommunityPathPrefixB2B() == null ? '' : GDB_CustomMetadataMgr.self().getCommunityPathPrefixB2B();

    /**
     * Domain name.
     */
    public static String domainName = GDB_CustomMetadataMgr.self().getDomainNameB2B();
    /**
     * Community name.
     */
    public static String communityName = GDB_CustomMetadataMgr.self().getCommunityNameB2B();
    
    /**
     * This map will store order status
     */
    public static Map<Integer, String> orderStatus = new Map<Integer, String>{
        3 => 'Créée',
        4 => 'Enregistrée',
        5 => 'Echouée',
        6 => 'Expédiée',
        7 => 'Livrée',
        8 => 'A Répartir',
        9 => 'A Répartir - Fille'
    };
    
    /**
     * This map will store Account Role
     */
    public static Map<Integer, String> accountRole = new Map<Integer, String>{ 
        1 => 'RE'
    };
}