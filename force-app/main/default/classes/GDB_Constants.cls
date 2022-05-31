public with sharing class GDB_Constants {
    /**
     * This map will store all session keys
     */
    public static Map<String, String> sessionKeys = new Map<String, String>{
        'customerId' => 'GDBCustomerId',
        'customerNo' => 'GDBCustomerNo',
        'basketId' => 'GDBBasketId',
        'orderId' => 'GDBOrderId',
        'orderNo' => 'GDBOrderNo',
        'currentCustomer' => 'GDBCurrentCustomer'
    };

    /**
     * This map will store display name for artcile
     */
    public static Map<Integer, String> articleNameDisplay = new Map<Integer, String>{
        1 => 'Menu',
        2 => 'Tuile'
    };

    /**
     * This map will store code article
     */
    public static Map<Integer, String> articleCode = new Map<Integer, String>{
        1 => 'GDB_PDT_2',
        2 => 'GDB_6BD_1'
    };

    /**
     * This map will store all checkout page URLs
     */
    public static Map<Integer, String> checkoutStepURLs = new Map<Integer, String>{
        1 => System.Label.GDB_link_basket,
        2 => System.Label.GDB_link_addresses,
        3 => System.Label.GDB_link_payment,
        4 => 'GDB_Checkout_ValidatePayment',
        5 => System.Label.GDB_link_confirmation,
        6 => SysteM.Label.GDB_link_login
    };

    /**
     * This map will store all checkout page URLs
     */
    public static Map<Integer, String> pagesURLs = new Map<Integer, String>{
        1 => System.Label.GDB_link_loginpage,
        2 => System.Label.GDB_link_productsandorders,
        3 => System.Label.GDB_link_mydetails,
        4 => System.Label.GDB_link_myorders,
        5 => System.Label.GDB_link_validateorder,
        6 => System.Label.GDB_link_contact,
        7 => System.Label.GDB_link_logout,
        8 => System.Label.GDB_link_advantage1,
        9 => System.Label.GDB_link_advantage2,
        10 => System.Label.GDB_link_product,
        11 => System.Label.GDB_link_myaddresses,
        12 => System.label.GDB_link_freeproduct,
        13 => System.Label.GDB_link_freeproductconfirm,
        14 => System.Label.GDB_link_faq,
        15 => System.Label.GDB_link_invoice,
        16 => System.Label.GDB_link_blog,
        17 => System.Label.GDB_link_quote,
        18 => System.Label.GDB_link_sponsorship,
        19 => System.Label.GDB_link_video_customer_reviews,
        20 => System.Label.GDB_link_customer_reviews,
        21 => System.Label.GDB_link_pack_serenissime,
        22 => System.Label.GDB_link_shipping
    };

    /**
     * Ecommerce article record type.
     */
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
    public static String communityPathPrefix = GDB_CustomMetadataMgr.self().getCommunityPathPrefix() == null ? '' : GDB_CustomMetadataMgr.self().getCommunityPathPrefix();

    /**
     * Domain name.
     */
    public static String domainName = GDB_CustomMetadataMgr.self().getDomainName();
    /**
     * Community name.
     */
    public static String communityName = GDB_CustomMetadataMgr.self().getCommunityName();

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
        9 => 'A Répartir - Fille',
        11 => 'Annulée'
    };

    /**
     * This map will store order payment status
     */
    public static Map<Integer, String> orderPaymentStatus = new Map<Integer, String>{
        1 => 'Failed',
        2 => 'Success',
        3 => 'Cancelled'
    };


    /**
     * This map will store order action
     */
    public static Map<Integer, String> orderAction = new Map<Integer, String>{
        0 => 'Refus',
        1 => 'Validation'
    };

    /**
     * This map will store all type for Article
     */
    public static Map<Integer, String> articleType = new Map<Integer, String>{
        1 => 'PRAXEDO',
        2 => 'STACI'
    };

    /**
     * This map will store all code error reponse for Mercanet
     */
    public static Map<String, String> codeErrorMercanet = new Map<String, String>{
        'ANNULATION' => '17',
        'PROBLEME_SERVEUR' => '99'
    };

    /**
    * This map will store all code error reponse for Mercanet
    */
    public static Map<Integer, String> warehouseName = new Map<Integer, String>{
        1 => 'PRAXEDO',
        2 => 'STACI'
    };

    /**
     * This map will store currency symbol
     */
    public static Map<String, String> currencySymbol =  new Map<String, String>{
        'USD' => '$',
        'CAD' => '$',
        'EUR' => '€',
        'GBP' => '£',
        'JPY' => '¥',
        'KRW' => '₩',
        'CNY' => '元'
    };

    /**
    * Return number of months to display for product nudge
    */
    public static Integer nudgeNbOfMonthsToDisplay = GDB_CustomSettingsMgr.self().getNudgeNbOfMonthsToDisplay();

    /**
    * Return the threshold below which we use max number of months
    */
    public static Integer nudgeMinimumThreshold = GDB_CustomSettingsMgr.self().getNudgeMinimumThreshold();

    /**
    * Return number of months to display for product nudge when minimum threshold is reached
    */
    public static Integer nudgeNbOfMonthsMaxToDisplay = GDB_CustomSettingsMgr.self().getNudgeNbOfMonthsMaxToDisplay();

    /**
    * The default zipcode to use if visitor doesn't have anyone
    */
    public static String nudgeDefaultZipCode = GDB_CustomSettingsMgr.self().getNudgeDefaultZipCode();

    /**
    * List of errors displays when guest basket is merged to customer
    */
    public static Map<Integer, String> mergeGuestBasketErrors = new Map<Integer, String>{
        10 => System.Label.GDB_merge_basket_no_more_stock,
        20 => System.Label.GDB_merge_basket_different_price,
        30 => System.Label.GDB_merge_basket_promo_already_used,
        40 => System.Label.GDB_merge_basket_purchase_limit_reached,
        50 => System.Label.GDB_merge_basket_shipping_method_not_available
    };

     /**
     * This map will store month in French
     */
    public static Map<Integer, String> monthFrench =  new Map<Integer, String>{
        1 => 'Janv.',
        2 => 'Févr.',
        3 => 'Mars',
        4 => 'Avr.',
        5 => 'Mai',
        6 => 'Juin',
        7 => 'Juill.',
        8 => 'Août',
        9 => 'Sept.',
        10 => 'Oct.',
        11 => 'Nov.',
        12 => 'Déc.'
    };

    /**
    * URL to call api DocaPost and get invoice
    */
    public static String docapostEndpoint = GDB_CustomSettingsMgr.self().getDocaPostEndpoint();

    /**
    * Certificate name for DocaPost API
    */
    public static String docapostCertificateName = GDB_CustomSettingsMgr.self().getDocaPostCertificateName();

    /**
    * BazaarVoice Deployment Zone
    */
    public static String bvDeploymentZone = GDB_CustomMetadataMgr.self().getBvDeploymentZone();

     /**
     * This map will store value picklist account type channel
     */
    public static Map<String, String> channelAccount =  new Map<String, String>{
        'PR' => 'PR',
        'RE' => 'RE',
        'All' => GDB_CustomMetadataMgr.self().getAccountTypeGoogleMap()
    };
}