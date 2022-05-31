global class CallSOAPWebService implements Process.Plugin {
    
    //Calculate the quantity and amount correctly
    global String PLUGIN_DESCRIPTION = 'This plugin will make a soap call to SAP to get the right quantity and amount of the order`';


    /*private Integer resetQuotes(integer batchId){
        List<Quote> lTestQuotes = [SELECT Latitude__c FROM Quote WHERE Test__c = true AND T_TestBatch__c = :batchId];
        for (Quote oTestQuote : lTestQuotes){
            oTestQuote.Latitude__c = null;
        }
        update lTestQuotes;
        return lTestQuotes.size();
    }*/

    global Process.PluginResult invoke(Process.PluginRequest request){
        Double amount_simulation = Double.valueOf(request.inputParameters.get('Amount to simulate'));
        Double quantity_simulation = Double.valueOf(request.inputParameters.get('Quantity to simulate'));
        Boolean full_simulation = (Boolean) (request.inputParameters.get('Full Checked'));
        System.debug(request.inputParameters.get('Full Checked'));
        if (full_simulation){
            amount_simulation = 90000;
            quantity_simulation = 9000;
        }else if(amount_simulation == null){
            amount_simulation = quantity_simulation * 10; 
        }else{
            quantity_simulation = amount_simulation / 10;
        }
        Map<String,Object> result = new Map<String,Object>();
        result.put('Quantity simulated', quantity_simulation);
        result.put('Amount simulated', amount_simulation); 
        return new Process.PluginResult(result);
    }

    global Process.PluginDescribeResult describe(){
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'CalculateRightQuantityAmount';
        result.Tag = 'order-testing';
        result.Description = this.PLUGIN_DESCRIPTION;
        result.InputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('Amount to simulate', 'Amount to simulate', Process.PluginDescribeResult.ParameterType.DECIMAL, true),
            new Process.PluginDescribeResult.InputParameter('Quantity to simulate', 'Quantity to simulate', Process.PluginDescribeResult.ParameterType.DECIMAL, true),
            new Process.PluginDescribeResult.InputParameter('Full Checked', 'Full Checked', Process.PluginDescribeResult.ParameterType.BOOLEAN, false)

        };
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('Amount simulated', 'Amount simulated', Process.PluginDescribeResult.ParameterType.DECIMAL),
            new Process.PluginDescribeResult.OutputParameter('Quantity simulated', 'Quantity simulated', Process.PluginDescribeResult.ParameterType.DECIMAL)
        }; 

        return result;
    }

}