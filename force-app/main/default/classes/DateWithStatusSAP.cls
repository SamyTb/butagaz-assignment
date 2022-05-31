public class DateWithStatusSAP {
        
    public Date datee {get; set;}
    public String colorCode {get; set;}
    
    public DateWithStatusSAP(Date d, String colorCode){
        this.datee = d;
        this.colorCode = colorCode;
    }
    
    public static String getColorCodeFromStatus(String status){
        if(status.equals('1')){
            return 'green';
        }else if(status.equals('2')){
            return 'orange';
        }else if(status.equals('3')){
            return 'red';
        }else{
            return 'black';
        }
    }

    public Boolean equals(Object obj){
        try {
            DateWithStatusSAP other = (DateWithStatusSAP) obj;
            if (other == null){ return false; } 
            else { return (this.datee == other.datee) && (this.colorCode == other.colorCode); }
        } catch (System.TypeException e){
            return false;
        }
    }
}