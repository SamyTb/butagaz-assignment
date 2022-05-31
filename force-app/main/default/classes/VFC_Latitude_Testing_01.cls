public class VFC_Latitude_Testing_01 {
    private List<String> lBatchIds;
    private String       requestedBatchIdCurrent; // Used by the CommandLink to fire the proper batch.
    private String       requestedBatchIdActive;  // Used by the CommandLink to fire the proper batch.
    
    public List<String> getLBatchIds(){
        if (this.lBatchIds == null){
            Set<String> tmpBatchIds = new Set<String>();
            this.lBatchIds = new List<String>();
            for (Quote oQuote : [SELECT T_LAT_Test_Batch__c FROM Quote WHERE T_LAT_IS_TEST__c = 1 ORDER BY T_LAT_Test_Batch__c]){
                tmpBatchIds.add(oQuote.T_LAT_Test_Batch__c); // No list contains... we use a  set : /
            }
            this.lBatchIds.addAll(tmpBatchIds);
            this.lBatchIds.sort();
        }
        return this.lBatchIds;
    }

    public List<DataObj> getFailureSuccessChartData() {
        // Pie Chart of the ratio Success vs Failure for Quotes
        List<AggregateResult> testStatus = [SELECT COUNT(Id) n, T_LAT_Test_Status__c FROM Quote WHERE T_LAT_IS_TEST__c = 1 GROUP BY T_LAT_Test_Status__c ORDER BY T_LAT_Test_Status__c];
        System.debug('[getFailureSuccessChartData] TestData: ' + testStatus);

        List<DataObj> testStatusChartData = new List<DataObj>();

        String status; // Loop variable.

        for (AggregateResult ar : testStatus){
            status = (String) ar.get('T_LAT_Test_Status__c');
            if (status == null){ status = 'Undefined'; }
            testStatusChartData.add(new DataObj(
                status,
                (Integer) ar.get('n')
            ));
        }
        System.debug('[getFailureSuccessChartData] ChartData: ' + testStatusChartData);

        return testStatusChartData;
    } 

    public List<DataObj> getCalculationTypeChartData() {
        // Pie Chart that shows the number of tests (ALL, Success OR Failure) by calculation type
        List<AggregateResult> testCalculationTypes = [SELECT COUNT(Id) n, T_LAT_Test_Calculation__c FROM Quote WHERE T_LAT_IS_TEST__c = 1 AND T_LAT_Test_Calculation__c != null AND T_LAT_Test_Status__c = 'Failed' GROUP BY T_LAT_Test_Calculation__c ];
        System.debug('[getCalculationTypeChartData] TestData: ' + testCalculationTypes);
        
        List<DataObj> testCalculationTypesChartData = new List<DataObj>();

        for (AggregateResult ar : testCalculationTypes){
            testCalculationTypesChartData.add(new DataObj(
                (String) ar.get('T_LAT_Test_Calculation__c'),
                (Integer) ar.get('n')
            ));
        }
        System.debug('[getCalculationTypeChartData] ChartData: ' + testCalculationTypesChartData);

        return testCalculationTypesChartData;
    } 

    public List<DataObj> getCalculationExpectedType() {
        // Histogram of the number of failed Quotes by Calculation Expected Type
        List<AggregateResult> testExpectedCalculationType = [SELECT COUNT(Id) n, T_LAT_Test_Calculation__c FROM Quote WHERE T_LAT_IS_TEST__c = 1 AND T_LAT_Test_Status__c = 'Failed' AND T_LAT_Test_Calculation__c != null GROUP BY T_LAT_Test_Calculation__c];
        System.debug('[getCalculationExpectedType] TestData: ' + testExpectedCalculationType);

        List<DataObj> testExpectedCalculationTypeChartData = new List<DataObj>();

        for (AggregateResult ar : testExpectedCalculationType){
            testExpectedCalculationTypeChartData.add(new DataObj(
                (String) ar.get('T_LAT_Test_Calculation__c'),
                (Integer) ar.get('n')
            ));
        }
        System.debug('[getCalculationExpectedType] ChartData: ' + testExpectedCalculationTypeChartData);

        return testExpectedCalculationTypeChartData;
    }

   public List<Quote> getFailedQuotes(){ 
        return [
            SELECT 
                T_LAT_IS_TEST__c,                        
                T_LAT_Test_ExpectedScore__c,
                T_LAT_Test_ExpectedLevel__c,      
                T_LAT_Test_LatitudeDifference__c,
                T_LAT_Test_Analyzed__c,
                T_LAT_Test_Batch__c,
                T_LAT_Test_ID__c,
                T_LAT_Test_Status__c,
                Latitude__c,
                Latitude_Level__c,
                Name
            FROM Quote
            WHERE T_LAT_IS_TEST__c = 1 AND T_LAT_Test_Status__c = 'Failed'
            ORDER BY T_LAT_Test_Batch__c
            LIMIT 1000
        ];
   }

   // Wrapper class
    
    public class DataObj {
        public String name { get; set; }
        public Integer data { get; set; }
        
        public DataObj(String name, Integer data) {
            this.name = name;
            this.data = data;
        }
    }


    public void     setRequestedBatchIdCurrent  (String i)  { this.requestedBatchIdCurrent = i; } 
    public String   getRequestedBatchIdCurrent  ()          { return this.requestedBatchIdCurrent; }
    
    public void     setRequestedBatchIdActive   (String i)  { this.requestedBatchIdActive = i; } 
    public String   getRequestedBatchIdActive   ()          { return this.requestedBatchIdActive; }
    
    public PageReference startLatest(){
        System.debug('[LatitudeTesting]  Latest Flow with BatchID: [' + this.getRequestedBatchIdCurrent()  + ']');
        //return new PageReference('/flow/LAT_Test?latestSub=true&batchName=' + this.getRequestedBatchIdCurrent());
        return new PageReference('/apex/VFP_Latitude_RunTest_01?batchId=' + this.getRequestedBatchIdCurrent());
    }
    public PageReference startActive(){
        System.debug('[LatitudeTesting] Active Flow with BatchID: [' + this.getRequestedBatchIdActive()  + ']');
        return new PageReference('/flow/LAT_Test?batchName=' + this.getRequestedBatchIdActive());
    }
}