public class AP_VFMessage {
    // **********************
    // ATTRIBUTES 
    // **********************
    public String type; // 'E':Error, 'S':Success, 'W':Warning, 'I':Info, 'A':Error
    public String summary;
    public String details;
   
    
    // **********************
    // CONSTRUCTOR
    // **********************
    
    public AP_VFMessage(String type, String summary){
        this.type = type;
        this.summary = summary;
        this.details = '';
    }
    
    //FULL
    public AP_VFMessage(String type, String summary, String details){
        this.type = type;
        this.summary = summary;
        this.details = details;
    }
    
    public ApexPages.Severity getSeverityFromType(){
        if(this.type != null){
            if(this.type.equals('E')){
                return ApexPages.Severity.ERROR;
            }else if(this.type.equals('S')){
                return ApexPages.Severity.CONFIRM;
            }else if(this.type.equals('W')){
                return ApexPages.Severity.WARNING;
            }else if(this.type.equals('I')){
                return ApexPages.Severity.INFO;
            }else if(this.type.equals('A')){
                return ApexPages.Severity.ERROR;
            }        
        }
        return ApexPages.Severity.INFO;
    }
}