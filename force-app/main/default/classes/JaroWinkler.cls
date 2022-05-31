public class JaroWinkler{
    // Implementation of the AP_StrDist_JaroWinkler_01 string similarity Algorithm
    // Translated from:
    // http://code.google.com/p/duke/source/browse/src/main/java/no/priv/garshol/duke/AP_StrDist_JaroWinkler_01.java?r=e32a5712dbd51f1d4c81e84cfa438468e217a65d
    
    public static String charAt(String s1, Integer position){
        return s1.substring(position, position + 1);
    }

    public static double similarity(String s1, String s2){
        if (s1 == s2){return 1.0;}  
        
        
        // (0) We want s1 to be shorter than s2
        
        if (s1.length() > s2.length()){
            return JaroWinkler.similarity(s2, s1);
        }
        
        
        // (1) Number of matching chracters / transpositions
        
        Integer maxDist     = s2.length() / 2;
        Integer commonCount = 0;
        Integer transpCount = 0;
        String  chr;                // chr we're working with.
        Integer chrPos1    = 0;     // Position of a chr in s1.
        Integer chrPos2 ;           // Position of the chr in s2.
        Integer previousPos = -1;
        
        
        do {
            chr = JaroWinkler.charAt(s1, chrPos1);
            
            chrPos2 = Math.max(0, chrPos1 - maxDist);
            
            do {
                if (chr == JaroWinkler.charAt(s2, chrPos2)){
                    commonCount ++;
                    if ((previousPos != -1) && (chrPos2 < previousPos)){
                        transpCount ++;
                    }
                    previousPos = chrPos2;
                    break;
                }
                chrPos2 ++;
            } while (chrPos2 < Math.min(s2.length(), chrPos1 + maxDist));
            
            chrPos1 ++;     
        } while (chrPos1 < s1.length());
        
        if (commonCount  == 0){return 0.0;}
            
        Double score = (
            (commonCount / (double) s1.length()) +
            (commonCount / (double) s2.length()) +
            ((commonCount - transpCount) / (double) commonCount)
        ) / 3.0;
            
        
        // (2) Common Prefix Modification
        
        Integer prefixLength = 0;
        Integer lastchr      = Math.min(4, s1.length()); //TODO: Why 4?
        while ((prefixLength < lastchr) && (JaroWinkler.charAt(s1, prefixLength) == JaroWinkler.charAt(s2, prefixLength))) {
            prefixLength ++; // We don't need to check the very last chr (because we would have s1 == s2);
        }
        score = score + ((prefixLength * (1 - score)) / 10);
        
        
        // (4) Done
        
        return score;
    }
}