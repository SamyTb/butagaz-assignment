global class PP_AddLatitude_01 extends PP_BaseLatitudeUpdate_01 implements Process.Plugin {
    // This plugin is designed to update the Latitude Score field, as well as to provide a new message.

    protected override String getPluginName(){
        return 'AddLatitudePlugin';
    }

    protected override String getPluginDescription(){
        return 'This plugin gives you an updated value for the Latitude field. You provide the former Latitude Score, the increase, and an optional message (provide the current message too then). The Latitude Score will be increased, and you will get back the new Score and an updated message.';
    }

    private Decimal getNewScore(Decimal currentScore, Decimal extraScore){
        return currentScore + extraScore;
    }

    protected override Map<String, Object> getResultMap(Process.PluginRequest request){
        // Required param
        Decimal extraScore   = Decimal.valueOf(String.valueOf(request.inputParameters.get('ExtraScore')));

        // Non-required param - boilerplate to get the default values.
        Decimal currentScore;
        if (request.inputParameters.get('CurrentScore') == null){ 
            currentScore = 0; 
        } else { 
            currentScore = Decimal.valueOf(String.valueOf(request.inputParameters.get('CurrentScore'))); 
            If(String.valueOf(ExtraScore).left(1)=='-')
            {
            this.messageExtraInfo = ' (Score: ' + String.valueOf(ExtraScore) + ' pt)';
            }
            else
            {
            this.messageExtraInfo = ' (Score: +' + String.valueOf(ExtraScore) + ' pt)';
            }   
        }

        Decimal newScore     = this.getNewScore(currentScore, extraScore);
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('NewScore', newScore);

        return resultMap;
    }

    protected override List<Process.PluginDescribeResult.InputParameter> getInputParameters(){
        return new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('ExtraScore', 'How much you want to add to the score.', Process.PluginDescribeResult.ParameterType.DECIMAL, true),
            new Process.PluginDescribeResult.InputParameter('CurrentScore', 'The Current Latitude score - 0 if not provided.', Process.PluginDescribeResult.ParameterType.DECIMAL, false)
        };
    }

    protected override List<Process.PluginDescribeResult.OutputParameter> getOutputParameters(){
        return new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('NewScore', 'New (Integer) Latitude Score.', Process.PluginDescribeResult.ParameterType.DECIMAL)
        }; 
    }
}