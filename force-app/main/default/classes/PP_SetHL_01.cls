global class PP_SetHL_01 extends PP_BaseLatitudeUpdate_01 implements Process.Plugin {
    // This process plugin is designed to give you the value for the HL field, and also update the error message.
    // See getPluginDescription for functionnality highlights.

    global class InvalidLatitudeLevelException extends Exception {}

    protected override String getPluginName(){
        return 'SetHLPlugin';
    }

    protected override String getPluginDescription(){
        return 'This plugin gives you an updated (internal: Integer) value for the HL field when you provide a correct input (possible values are: BTZ (0), DirCom (1), RespNat (2), GdCompte (3), CDV (4), CE (5)): you will get the integer value, and the current level is taken into account. You can also pass a reason and the current reason string, it will be updated with the reason.';
    }

    public static Integer LatLevel_CE       = 5;
    public static Integer LatLevel_CDV      = 4;
    public static Integer LatLevel_GdCompte = 3;
    public static Integer LatLevel_RespNat  = 2;
    public static Integer LatLevel_DirCom   = 1;
    public static Integer LatLevel_BTZ      = 0;
    
    private static Map<String, Integer> latitudeLevels = new Map<String, Integer>{
        'CE'       => LatLevel_CE,
        'CDV'      => LatLevel_CDV,
        'GdCompte' => LatLevel_GdCompte,
        'RespNat'  => LatLevel_RespNat,
        'DirCom'   => LatLevel_DirCom,
        'BTZ'      => LatLevel_BTZ
    };

    private Integer getNewLevel(Integer currentLevel, String newLevelString){
        Integer newLevel = PP_SetHL_01.latitudeLevels.get(newLevelString);
        if (newLevel == null){
            if (newLevelString.isNumeric()){
                newLevel = Integer.valueOf(newLevelString);
            } else {
                throw new PP_SetHL_01.InvalidLatitudeLevelException('Invalid Latitude Level: ' + newLevelString);
            }
        } 
        return Math.min(currentLevel, newLevel); // Lowest level
    }

    protected override Map<String, Object> getResultMap(Process.PluginRequest request){
        // Required param
        String  newLevelString  = String.valueOf(request.inputParameters.get('NewLevel'));

        // Non-required param - boilerplate to get the default values.
        Integer currentLevel;
        if (request.inputParameters.get('CurrentLevel') == null){ 
            currentLevel = LatLevel_CE; 
            this.messageExtraInfo = 'CE';
        } else { 
            currentLevel = Integer.valueOf(request.inputParameters.get('CurrentLevel')); 
            this.messageExtraInfo = ' (Niveau: ' + newLevelString + ')';
        }

        Integer newLevel   = this.getNewLevel(currentLevel, newLevelString);

        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('NewLevel', newLevel);

        return resultMap;
    }

    protected override List<Process.PluginDescribeResult.InputParameter> getInputParameters(){
        return new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('NewLevel', 'The New Latitude level (as text)', Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('CurrentLevel', 'The Current Latitude level (as returned by this plugin) - CE value if not provided.', Process.PluginDescribeResult.ParameterType.INTEGER, false)
        };
    }

    protected override List<Process.PluginDescribeResult.OutputParameter> getOutputParameters(){
        return new List<Process.PluginDescribeResult.OutputParameter>{
            new Process.PluginDescribeResult.OutputParameter('NewLevel', 'New (Integer) Latitude Level.', Process.PluginDescribeResult.ParameterType.INTEGER)
        }; 
    }
}