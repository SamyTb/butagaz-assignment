global class PP01_ResetQuotes implements Process.Plugin {
    // This process plugin is designed to Reset quotes prior to the Test run.
    // See PLUGIN_DESCRIPTION for functionnality highlights.
    
    global String PLUGIN_DESCRIPTION = 'This plugin resets all the Quotes that have the Test Batch ID set to the one passed to this plugin as well as the T_LAT_IS_TEST__c flag. This plugin will set the `Latitude__c` field on these quotes to `null`';


    private Integer resetQuotes(String batchName){
        List<Quote> lTestQuotes = [
            SELECT Latitude__c, Latitude_Level__c 
            FROM Quote 
            WHERE T_LAT_IS_TEST__c  = 1 AND T_LAT_Test_Batch__c = :batchName
        ];
        for (Quote oTestQuote : lTestQuotes){
            oTestQuote.Latitude__c = null;
            oTestQuote.Latitude_Level__c = null;
        }
        update lTestQuotes;
        return lTestQuotes.size();
    }

    global Process.PluginResult invoke(Process.PluginRequest request){
        String batchName = String.valueOf(request.inputParameters.get('batchName'));
        return new Process.PluginResult('Reset', this.resetQuotes(batchName));
    }

    global Process.PluginDescribeResult describe(){
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'ResetTestQuotesPlugin';
        result.Tag = 'latitude-testing';
        result.Description = this.PLUGIN_DESCRIPTION;
        result.InputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('batchName', 'The ID of the test batch to be reset', Process.PluginDescribeResult.ParameterType.STRING, true)
        };
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('Reset', 'Number of reset Quotes', Process.PluginDescribeResult.ParameterType.INTEGER)
        }; 

        return result;
    }

}