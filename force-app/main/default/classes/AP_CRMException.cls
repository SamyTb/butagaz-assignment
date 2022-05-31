public class AP_CRMException extends Exception {
    
    List<String> listErrors;
    
    public AP_CRMException(List<String> listErrors){
        this.listErrors = listErrors;
    }
    
    public List<String> getMessages(){
        return this.listErrors;
    }
}