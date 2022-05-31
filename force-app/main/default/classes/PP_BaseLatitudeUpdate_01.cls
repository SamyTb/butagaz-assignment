global virtual class PP_BaseLatitudeUpdate_01 implements Process.Plugin {
    protected String messageExtraInfo = '';

    protected virtual String getPluginDescription(){return '';}
    protected virtual String getPluginName(){return 'UpdateLatitudeMessage';}
    protected virtual Map<String, Object> getResultMap(Process.PluginRequest request){return new Map<String, Object>();}
    protected virtual List<Process.PluginDescribeResult.InputParameter> getInputParameters(){
        return new List<Process.PluginDescribeResult.InputParameter>();
    }
    protected virtual List<Process.PluginDescribeResult.OutputParameter> getOutputParameters(){
        return new List<Process.PluginDescribeResult.OutputParameter>();
    }

    private List<Process.PluginDescribeResult.InputParameter> getFinalInputParameters(){
        // The inheriting class will override getInputParameters, but we will use this method to 
        // add the CurrentMessage & NewMesagePart parameters.
        List<Process.PluginDescribeResult.InputParameter> finalParams = this.getInputParameters();
        finalParams.add(new Process.PluginDescribeResult.InputParameter('CurrentMessage', 'Your Current HL Message (as returned by this plugin) - Empty string if not provided', Process.PluginDescribeResult.ParameterType.STRING, false));
        finalParams.add(new Process.PluginDescribeResult.InputParameter('NewMessagePart', 'Why are you marking this Quote as HL?', Process.PluginDescribeResult.ParameterType.STRING, false));
        return finalParams;
    }

    private List<Process.PluginDescribeResult.OutputParameter> getFinalOutputParameters(){
        List<Process.PluginDescribeResult.OutputParameter> finalParams = this.getOutputParameters();
        finalParams.add(new Process.PluginDescribeResult.OutputParameter('NewMessage', 'New Latitude message (Old message + New message).', Process.PluginDescribeResult.ParameterType.STRING));
        return finalParams;
    }

    protected virtual String getMessageExtraInfo(){
        // Provide extra information in the message.
        return this.messageExtraInfo;
    }

    protected String getNewMessage(String currentMessage, String newMessagePart){
        String separator;
        if ((currentMessage <> '') && (newMessagePart <> '')){ separator = '\n'; }
        else { separator = ''; }
        return currentMessage + separator + newMessagePart + this.getMessageExtraInfo();
    }

    global Process.PluginResult invoke(Process.PluginRequest request){
        String  currentMessage;
        if (request.inputParameters.get('CurrentMessage') == null){ currentMessage = ''; } 
        else { currentMessage = String.valueOf(request.inputParameters.get('CurrentMessage')); }
            
        String  newMessagePart;
        if (request.inputParameters.get('NewMessagePart') == null){ newMessagePart = ''; }
        else { newMessagePart = String.valueOf(request.inputParameters.get('NewMessagePart')); }

        Map<String, Object> resultMap = this.getResultMap(request);

        String  newMessage = this.getNewMessage(currentMessage, newMessagePart);
        resultMap.put('NewMessage', newMessage);

        return new Process.PluginResult(resultMap);
    }

    global Process.PluginDescribeResult describe(){
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.Name = this.getPluginName();
        result.Description = this.getPluginDescription();
        result.Tag = 'latitude';
        result.inputParameters = this.getFinalInputParameters();
        result.outputParameters = this.getFinalOutputParameters();
        return result;
    }
}