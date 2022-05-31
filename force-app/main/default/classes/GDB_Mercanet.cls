public with sharing class GDB_Mercanet {
    // Global parameters
    public static String INTERFACE_VERSION = GDB_CustomSettingsMgr.self().getMercanetInterfaceVersion();
    public static String KEY_VERSION = GDB_CustomSettingsMgr.self().getMercanetKeyVersion();
    public static String ORDER_CHANNEL = 'INTERNET';
    public static String TRANSACTION_ORIGIN = 'WEBSITE';
    public static String DATE_FORMAT = 'yyyyMMdd';
    public static String TRANSACTION_DATETIME_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss+02:00';
    // Multiple payment
    public static String INSTALMENT = 'INSTALMENT';
    public static Integer PAYMENT_TIMES = GDB_CustomSettingsMgr.self().getMercanetPaymentTimes();
    public static Integer PAYMENT_TIME_BETWEEN_DATES = GDB_CustomSettingsMgr.self().getMercanetTimeBetweenPayments();
    public static String CAPTURE_DAY = '0';
    public static String CAPTURE_MODE = 'AUTHOR_CAPTURE';
    // Algorythms
    private static String MAC_ALGORITHM = 'HmacSHA256';
    private static String DIGEST_ALGORITHM = 'SHA-256';
    // Response parameters
    public static String responseParameterSeal = 'seal';
    public static String responseParameterData = 'data';

    private static String secretKey;
    private String merchantId;
    private String returnUrl;
    private String endpoint;
    private GDB_Mercanet.Response response;
    private Map<String, Object> parameters;

    public static Map<String, String> currencies = new Map<String, String>{
        'EUR' => '978',
        'USD' => '840',
        'CHF' => '756',
        'GBP' => '826',
        'CAD' => '124',
        'JPY' => '392',
        'MXP' => '484',
        'TRY' => '949',
        'AUD' => '036',
        'NZD' => '554',
        'NOK' => '578',
        'BRC' => '986',
        'ARP' => '032',
        'KHR' => '116',
        'TWD' => '901',
        'SEK' => '752',
        'DKK' => '208',
        'KRW' => '410',
        'SGD' => '702',
        'XPF' => '953',
        'XOF' => '952'
    };

    public GDB_Mercanet() {
        GDB_CustomSettingsMgr customSettingsMgr = GDB_CustomSettingsMgr.self();

        GDB_Mercanet.secretKey = customSettingsMgr.getMercanetSecretKey();
        // TODO: Move '211040032210001' to configuration
        this.merchantID = customSettingsMgr.getMercanetMerchantID();
        // TODO: Move 'TEST' to configuration
        this.endpoint = customSettingsMgr.getMercanetURL();
    }

    /**
     * Return the multiple payment details based on the given order details
     *
     * @param {Decimal} totalPrice
     * @param {String} orderNo
     * @param {DateTime} d
     * @param {Boolean} format
     *
     * @returns {Map<String, Object[]>}
     **/
    public static Map<String, Object[]> getMultiplePaymentDetails(Decimal totalPrice, String orderNo, DateTime d, Boolean format) {
        Map<String, Object[]> returnObject = new Map<String, Object[]>();

        Integer nb = GDB_Mercanet.PAYMENT_TIMES;
        Integer timeBetweenDueDates = GDB_Mercanet.PAYMENT_TIME_BETWEEN_DATES;
        // Initialize the total price to a decimal one
        Integer intTotalPrice = Integer.valueOf(totalPrice * 100);
        // Get the price for each sub-payment
        Integer price = Integer.valueOf(intTotalPrice / nb);

        /**
         * For example (case of around needed):
         * totalPrice = 100 €
         * nb = 3
         * intTotalPrice = 100 * 100 = 10000
         *
         * price = (10000 / 3) = 3333
         *
         * totalOfPrices = (3333 * 3) = 9999
         *
         * firstPrice = 3333 + (10000 - 9999) = 3334
         *
         * This way, the total of prices (firstPrice + all other prices) is equals to the total price
         * We can verify this by doing
         * Boolean isPricesEquals = intTotalPrice == (firstPrice + (price * (nb - 1))); // 10000 == (3334 + (3333 * 2))
         *
         * ----------------
         * For example (case of no around needed):
         * totalPrice = 300 €
         * nb = 3
         * intTotalPrice = 300 * 100 = 30000
         *
         * price = (30000 / 3) = 10000
         *
         * totalOfPrices = (10000 * 3) = 30000
         *
         * firstPrice = 10000 + (30000 - 30000) = 10000
         *
         * This way, the total of prices (firstPrice + all other prices) is equals to the total price
         * We can verify this by doing
         * Boolean isPricesEquals = intTotalPrice == (firstPrice + (price * (nb - 1))); // 30000 == (10000 + (10000 * 2))
         *
         **/
        Integer totalOfPrices = Integer.valueOf(price * nb);

        // The first price is equals all other prices + the difference between the total price and the sum of all prices
        Integer firstPrice = price + (intTotalPrice - totalOfPrices);

        Object[] dates;
        if (format) {
            dates = new String[] {
                d.format(GDB_Mercanet.DATE_FORMAT)
            };
        } else {
            dates = new DateTime[] {
                d
            };
        }

        String[] transactionReferences = new String[] {
            orderNo
        };

        Object[] prices;
        if (format) {
            prices = new String[] {
                String.valueOf(firstPrice)
            };
        } else {
            prices = new Decimal[] {
                firstPrice
            };
        }

        for (Integer dueDate = 1; dueDate < nb; dueDate++) {
            if (format) {
                dates.add(d.addDays(timeBetweenDueDates * dueDate).format(GDB_Mercanet.DATE_FORMAT));
            } else {
                dates.add(d.addDays(timeBetweenDueDates * dueDate));
            }
            transactionReferences.add(orderNo + dueDate);
            if (format) {
                prices.add(String.valueOf(price));
            } else {
                prices.add(price);
            }
        }

        returnObject.put('dates', dates);
        returnObject.put('transactionReferences', transactionReferences);
        returnObject.put('prices', prices);

        return returnObject;
    }

    /**
     * sortParameters Sort parameters alphabetically
     *
     * @param {Map<String, Object>} parameters
     *
     * @returns {Map<String, Object>}
     */
    private Map<String, Object> sortParameters(Map<String, Object> parameters) {
        if (parameters == null || parameters.size() == 0) {
            return parameters;
        }

        List<String> keys = new List<String>();
        keys.addAll(parameters.keySet());
        keys.sort();
        Map <String, Object> newMap = new Map<String, Object>();

        for (String key : keys) {
            newMap.put(key, parameters.get(key));
        }

        for (String key : newMap.keySet()) {
            if (newMap.get(key) instanceOf Map<String, Object>) {
                newMap.put(key, this.sortParameters((Map<String, Object>)newMap.get(key)));
            }
        }

        return newMap;
    }

    /**
     * applyMultiplePaymentParameters Apply parameters for the multiple payment
     *
     * @param {Decimal} totalPrice
     * @param {String} orderNo
     * @param {DateTime} d
     */
    private void applyMultiplePaymentParameters(Decimal totalPrice, String orderNo, DateTime d) {
        if (this.parameters == null) {
            return;
        }

        Integer nb = GDB_Mercanet.PAYMENT_TIMES;
        Map<String, Object[]> multiplePaymentDetails = GDB_Mercanet.getMultiplePaymentDetails(totalPrice, orderNo, d, true);

        this.parameters.put('merchantTransactionDateTime', d.format(GDB_Mercanet.TRANSACTION_DATETIME_FORMAT));
        Map<String, Object> instalmentData = new Map<String, Object>();
        instalmentData.put('amountsList', multiplePaymentDetails.get('prices'));
        instalmentData.put('datesList', multiplePaymentDetails.get('dates'));
        instalmentData.put('number', nb);
        instalmentData.put('transactionReferencesList', multiplePaymentDetails.get('transactionReferences'));

        this.parameters.put('captureDay', GDB_Mercanet.CAPTURE_DAY);
        this.parameters.put('captureMode', GDB_Mercanet.CAPTURE_MODE);
        this.parameters.put('paymentPattern', GDB_Mercanet.INSTALMENT);
        this.parameters.put('transactionOrigin', GDB_Mercanet.TRANSACTION_ORIGIN);
        this.parameters.put('instalmentData', instalmentData);
    }

    /**
     * applyGlobalParameters Apply global parameters to the request
     */
    private void applyGlobalParameters() {
        if (this.parameters == null) {
            return;
        }
        
        Map<String, Object> paypageData = new Map<String, Object>();
        paypageData.put('bypassReceiptPage', 'Y');

        this.parameters.put('interfaceVersion', GDB_Mercanet.INTERFACE_VERSION);
        this.parameters.put('keyVersion', GDB_Mercanet.KEY_VERSION);
        this.parameters.put('orderChannel', GDB_Mercanet.ORDER_CHANNEL);
        this.parameters.put('merchantId', this.merchantId);
        this.parameters.put('normalReturnUrl', this.returnUrl);
        this.parameters.put('automaticResponseUrl', this.returnUrl);
        this.parameters.put('paypageData', paypageData);

        // Fraud data management
        String fraudDataString = GDB_CustomSettingsMgr.self().getMercanetFraudData();
        if (String.isNotBlank(fraudDataString)) {
            GDB_Mercanet.FraudData fraudData = (GDB_Mercanet.FraudData) JSON.deserialize(GDB_CustomSettingsMgr.self().getMercanetFraudData(), GDB_Mercanet.FraudData.class);
            Map<String, Object> fraudDataObj = new Map<String, Object>();
            Boolean emptyValues = true;
            if (fraudData.getRiskManagementDynamicSettingList() != null) {
                fraudDataObj.put('riskManagementDynamicSettingList', fraudData.getRiskManagementDynamicSettingList());
                emptyValues = false;
            }
            if (fraudData.getBypassCtrlList() != null) {
                fraudDataObj.put('bypassCtrlList', fraudData.getBypassCtrlList());
                emptyValues = false;
            }
            if (!emptyValues) {
                this.parameters.put('fraudData', fraudDataObj);
            }
        }
    }

    /**
     * generateSignature Generate the signature for the given salt
     *
     * @param {String} salt
     *
     * @return {String}
     */
    private String generateSignature(String salt) {
        Blob crypted = Crypto.generateMac(GDB_Mercanet.MAC_ALGORITHM, Blob.valueOf(salt), Blob.valueOf(GDB_Mercanet.secretKey));
        return EncodingUtil.convertToHex(crypted).toLowerCase();
    }

    /**
     * generateSeal Generate a salt based on parameters
     *
     * @return {String}
     */
    private String generateSeal(Map<String, Object> parameters) {
        if (parameters == null || parameters.size() == 0) {
            return '';
        }

        String seal = '';
        List<Map<String, String>> tmp;

        for (String parameter : parameters.keySet()) {
            if (parameter != 'keyVersion') {
                if (parameters.get(parameter) instanceOf Map<String, Object>) {
                    seal += this.generateSeal((Map<String, Object>)parameters.get(parameter));
                } else if (parameters.get(parameter) instanceOf List<Map<String, String>>) {
                    tmp = (List<Map<String, String>>)parameters.get(parameter);

                    for(Integer i = 0; i < tmp.size(); ++i) {
                        seal += this.generateSeal((Map<String, String>)tmp.get(i));
                    }
                } else if (parameters.get(parameter) instanceOf String[]) {
                    for (String key : (String[])parameters.get(parameter)) {
                        seal+= String.valueOf(key);
                    }
                } else {
                    seal += String.valueOf(parameters.get(parameter));
                }
            }
        }

        return seal;
    }

    /**
     * prepareParameters Prepare the request parameters for the given order details
     *
     * @param {Decimal} totalPrice
     * @param {String} currencyCode
     * @param {String} orderNo
     * @param {Boolean} multiplePayment
     */
    public void prepareParameters(Decimal totalPrice, String currencyCode, DateTime d, String orderNo, String customerNo, Boolean multiplePayment, String customerEmail) {
        if (totalPrice == null || currencyCode == null || orderNo == null || customerEmail == null) {
            return;
        }

        if (d == null) {
            d = DateTime.now();
        }
        Map<String, Object> customerObj = new Map<String, Object> {
            'email' => customerEmail
        };
        
        this.parameters = new Map<String, Object>{
            'amount' => String.valueOf(Integer.valueOf(totalPrice * 100)), // Remember to multiply total price * 100 and set it to string
            'currencyCode' => GDB_Mercanet.currencies.get(currencyCode),
            'transactionReference' => orderNo,
            'orderId' => orderNo,
            'customerId' => customerNo,
            'returnContext' => customerNo,
            'merchantId' => this.merchantId,
            'customerContact' => customerObj
        };

        // If the multiple payment is enabled, add multiple payment parameters
        if (multiplePayment) {
            this.applyMultiplePaymentParameters(totalPrice, orderNo, d);
        }
        // Apply the global and configuration parameters
        this.applyGlobalParameters();
        // Sort parameters
        this.parameters = this.sortParameters(this.parameters);
        // Add the seal
        this.parameters.put('seal', this.generateSignature(this.generateSeal(this.parameters)));
    }

    /**
     * executeRequest Execute the request
     *
     * @return GDB_Mercanet.Response
     */
    public GDB_Mercanet.Response executeRequest() {
        try {
            if (this.parameters == null || this.parameters.size() == 0) {
                return null;
            }

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response;

            request.setEndpoint(this.endpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setBody(JSON.serialize(this.parameters));
            
            response = http.send(request);
            
            GDB_ErrorMgr.createError('GDB_Mercanet', 'executeRequest', 'ORDER_NO_' + this.parameters.get('orderId') + '_REQUEST_' + request.getBody());
            GDB_ErrorMgr.createError('GDB_Mercanet', 'executeRequest', 'ORDER_NO_' + this.parameters.get('orderId') + '_RESPONSE_' + response.getBody());
            
            return (GDB_Mercanet.Response)JSON.deserialize(response.getBody(), GDB_Mercanet.Response.class);
        } catch (Exception e) {
            GDB_ErrorMgr.createError('GDB_Mercanet', 'executeRequest_Exception', 'ORDER_NO_' + this.parameters.get('orderId') + '_EXCEPTION_' + e.getStackTraceString() + '_TYPE_' + e.getTypeName() + '_LINE_' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
        }

        return null;
    }

    /**
     * setReturnUrl Set the return URL parameter
     *
     * @param {String} url
     */
    public void setReturnUrl(String url) {
        this.returnUrl = url;
    }

    /**
     * Response class: This class is used to handle the response from the Mercanet server when initializing the payment.
     * This class is used by the JSON.deserialize() method called in the executeRequest() method of GDB_Mercanet.
     * This allows us to easily parse the response and get values.
     */
     public class Response {
        public String redirectionUrl;
        public String redirectionVersion;
        public String redirectionData;
        public String redirectionStatusCode;
        public String redirectionStatusMessage;
        public String seal;

        public String getRedirectionUrl() {
            return (String)this.redirectionUrl;
        }

        public String getRedirectionVersion() {
            return (String)this.redirectionVersion;
        }

        public String getRedirectionData() {
            return (String)this.redirectionData;
        }

        public String getRedirectionStatusCode() {
            return (String)this.redirectionStatusCode;
        }

        public String getRedirectionStatusMessage() {
            return (String)this.redirectionStatusMessage;
        }

        public String getSeal() {
            return (String)this.seal;
        }

        // The reponse is valid if the redirection Status Code == '00'
        public Boolean isValid() {
            return this.getRedirectionStatusCode() == '00';
        }
    }

    /**
     * FraudData class: This class is used to deserialize the JSON Custom Settings that contains the Fraud data
     **/
    public class FraudData {
        public List<Map<String, String>> riskManagementDynamicSettingList;
        public List<String> bypassCtrlList;

        public List<Map<String, String>> getRiskManagementDynamicSettingList() {
            return this.riskManagementDynamicSettingList;
        }

        public List<String> getBypassCtrlList() {
            return bypassCtrlList;
        }
    }

    /**
     * PostResponse class: This class is used to handle the response from the Mercanet server when the customer is processing its payment
     * This class parse the post parameters sent in the request and validate them
     */
    public class PostResponse {
        private String data;
        private String seal;
        private Map<String, String> parameters;

        /**
         * PostResponse PostResponse constructor
         *
         * @param {String} d The {data} parameter sent in the POST request
         * @param {String} s The {seal} parameter sent in the POST request
         */
        public PostResponse(String d, String s) {
            this.data = d;
            this.seal = s;
            this.parameters = new Map<String, String>();

            if (this.data == null || this.data.length() == 0) {
                return;
            }

            List<String> parameters = this.data.split(Pattern.quote('|'));
            for (String p : parameters) {
                String[] keyValue = p.split('=');
                if (keyValue != null && keyValue.size() > 1) {
                    this.parameters.put(keyValue[0], keyValue[1]);
                }
            }
        }

        /**
         * generateDigest Generate the digest based on the given salt and the {GDB_Mercanet.DIGEST_ALGORITHM} algorythm
         *
         * @param {String} salt
         *
         * @return {String}
         */
        private String generateDigest(String salt) {
            Blob crypted = Crypto.generateDigest(GDB_Mercanet.DIGEST_ALGORITHM, Blob.valueOf(salt));
            return EncodingUtil.convertToHex(crypted).toLowerCase();
        }

        /**
         * isValid Checks if the current Post Response class (based on its data and seal values) is valid or not
         *
         * @return {Boolean}
         */
        public Boolean isValid() {
            // If the data or seal parameters are empty, the response is not valid
            if (this.data == null || this.seal == null) {
                return false;
            }

            String digest = Test.isRunningTest() ? this.seal : this.generateDigest(this.data + GDB_Mercanet.secretKey);

            /**
             * The response is valid only if
             * - the generated digest is not null
             * - the generated digest is equals to the seal sent by Mercanet
             * - the responseCode is equals to '00'
             */
            return digest != null
                && digest == this.seal
                && (this.getParameter('responseCode') == '00');
        }

        /**
         * getTransactionReference Return the transaction reference sent by Mercanet
         *
         * @return {String}
         */
        public String getTransactionReference() {
            return this.getParameter('transactionReference');
        }

        /**
         * getTransactionId Return the transaction ID sent by Mercanet
         *
         * @return {String}
         */
        public String getTransactionId() {
            return this.getParameter('s10TransactionId');
        }

        /**
         * getAuthorisationId Return the authorisation ID sent by Mercanet
         *
         * @return {String}
         */
        public String getAuthorisationId() {
            return this.getParameter('authorisationId');
        }

        /**
         * getParameter Get the response parameter value based on its key
         *
         * @param {String} key
         *
         * @return {String}
         */
        public String getParameter(String key) { 
            return this.parameters.get(key);
        }
    }
}