public class AP_MappingOptions{

    public static Map<String,String> orderOriginMap = new Map<String, String>();
    public static Map<String, String> custCallMap = new Map<String,String>();
    public static Map<String, String> momentMap = new Map<String,String>();
    public static Map<String, String> medContactMap = new Map<String,String>();
    public static Map<String, String> reasonDelayMap = new Map<String,String>();

    static {
        orderOriginMap.put('FAX' , System.Label.fax_option);
        orderOriginMap.put('MUEN', System.Label.orally_option);
        orderOriginMap.put('SCHR', System.Label.written_option);
        orderOriginMap.put('TELC', System.Label.cust_call_option);
        orderOriginMap.put('TELE', System.Label.phone_call_option);
        orderOriginMap.put('TELM', System.Label.command_center_call_option);
        orderOriginMap.put('DFUE', System.Label.preplaning_option);

        custCallMap.put('0', System.Label.dont_need_call_option);
        custCallMap.put('1', System.Label.require_a_call_option);
        custCallMap.put('2', System.Label.contacted_option);
        
        momentMap.put('00', System.Label.none_label);
        momentMap.put('MATIN', System.Label.morning_option);
        momentMap.put('APRES-MIDI', System.Label.afternoon_option);
        
        medContactMap.put('00', System.Label.none_label_male);
        medContactMap.put('01', System.Label.phone1_option);
        medContactMap.put('02', System.Label.phone2_option);
        medContactMap.put('03', System.Label.phone3_option);
        medContactMap.put('04', System.Label.message_answering_option);
        medContactMap.put('05', 'SMS');
        medContactMap.put('06', 'Email');
        medContactMap.put('07',  System.Label.unreachable_client_option);
        medContactMap.put('08',  System.Label.not_contacted_client_option);
        
        reasonDelayMap.put('00', System.Label.none_label);
        reasonDelayMap.put('A', 'Mandataire');
        reasonDelayMap.put('B', System.Label.customer_option);
    }
    
    
}