public class AP_StrDist_Levenshtein_01 implements AP_StrDist_Interface_01{
        public static Double similarity(String str1, String str2){
            Integer distance = AP_StrDist_Levenshtein_01.compute(str1, str2);
            if (distance == 0){
                return 1;
            } else {
                return 1 / Double.valueOf(distance);
            }
        }

        public static Integer compute(String str1, String str2) {
            Map<Integer,Map<Integer, Integer>> NewDistance = new Map<Integer, Map<Integer, Integer>>();
            
            str1 = ' ' + str1;
            str2 = ' ' + str2;

            for (Integer i = 0; i < str1.length(); i++){
                newDistance.put(i, new Map<Integer, Integer>{ 0 => i});
            }

            //Map<Integer, Integer> newDistance0 = newDistance.get(0)
            for (Integer j = 0; j < str2.length(); j++){
                newDistance.get(0).put(j,j); // Internalize newDistance.get(0) for performance?
            }

            for (Integer j = 1; j < str2.length(); j++){
                for (Integer i = 1; i < str1.length(); i++){
                  if (str1.substring(i, i+1) == str2.substring(j, j+1)){
                      newDistance.get(i).put(j, newDistance.get(i-1).get(j-1));
                  } else {
                      newDistance.get(i).put(
                        j,
                        Math.Min(
                            Math.Min(
                                newDistance.get(i-1).get(j),
                                newDistance.get(i).get(j-1)
                            ),
                            newDistance.get(i-1).get(j-1)
                        ) + 1
                      );
                  }
                }
            }

            return newDistance.get(str1.length() - 1).get(str2.length() - 1);
        }
}