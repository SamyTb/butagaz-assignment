public class VFC_Latitude_RunTest_01{
    // Run a specific Latitude Test Batch
    public String getBatchId(){
        return ApexPages.currentPage().getParameters().get('batchId');
    }
}