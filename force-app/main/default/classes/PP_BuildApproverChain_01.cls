global class PP_BuildApproverChain_01 implements Process.Plugin {
    // This process plugin builds the approver chain for a quote after Latitude has been calculated.
    // See PLUGIN_DESCRIPTION for functionnality highlights.
    
    global String PLUGIN_DESCRIPTION = 'Build the approver chain for the whose Id was passed in `Quote_Id`';


    global Process.PluginResult invoke(Process.PluginRequest request){
        String  quoteId = (String) request.inputParameters.get('Quote_Id');
        Integer status = 0;
        String  errorMsg = '';
        Quote oQuote = [
            SELECT Id, Opportunity.OwnerId, T_Organization__c, 
                   Latitude_Level__c, Latitude__c,
                   Approver0__c, Approver1__c, Approver2__c, Approver3__c, Approver4__c
            FROM Quote
            WHERE ID = :quoteId
        ];
        try { AP_ApprovalHierarchy_01.buildApproverChain(new List<Quote>{oQuote}); } 
        catch (AP_ApprovalHierarchy_01.RepNotInHiearchyException e){ status = 1; } 
        catch (AP_ApprovalHierarchy_01.NoApproverFoundException e){ status = 2; }
        if (status == 0){
            update oQuote;
        
            if ((Boolean) request.inputParameters.get('RequestApproval')){
                oQuote.T_LAT_LatitudeRequested__c = 1;
                update oQuote;
                
                try{
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    approvalRequest.setObjectId(quoteId);
                    Approval.ProcessResult result = Approval.process(approvalRequest);
                }
                catch (DmlException e){ status = 3;  
                system.debug( e );}

            }
           }
        return new Process.PluginResult('Status', status); // TODO
    }

    global Process.PluginDescribeResult describe(){
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'BuildApproverChainPlugin';
        result.Tag = 'latitude';
        result.Description = this.PLUGIN_DESCRIPTION;
        result.InputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('Quote_Id', 'The ID of the Quote to be approved', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('RequestApproval', 'Should an approval process be started?', Process.PluginDescribeResult.ParameterType.BOOLEAN, false)
        };
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('Status', 'Status of the Quote Approver build. (-1 indicates Error).', Process.PluginDescribeResult.ParameterType.INTEGER)
        }; 
        return result;
    }

}