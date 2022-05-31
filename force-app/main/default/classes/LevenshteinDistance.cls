public class LevenshteinDistance{
        public static Integer minimum(Integer a, Integer b, Integer c){
            return LevenshteinDistance.minimum(LevenshteinDistance.minimum(a,b),c);
        }
        
        public static Integer minimum(Integer a, Integer b){
            if (a < b){return a;} 
            else {return b;}
        }

        
        public static Integer computeLevenshteinDistance(String str1, String str2) {
                Map<String, Integer> distance = new Map<String, Integer>(); // Oh so ineffective. 
                str1 = ' ' + str1;
                str2 = ' ' + str2;
 
                System.debug('Init');
                Integer i = 0;
                do {
                    distance.put(i + ',' + 0, i);
                    i = i + 1;
                } while (i < str1.length());
                
                Integer j = 0;
                do {
                    distance.put(0 + ',' + j, j);
                    j = j + 1;
                } while (j < str2.length());
                
                System.debug('Loop');
                
                j = 1;
                do {
                    i = 1;
                    do {
                        System.debug('j: ' + j);
                        System.debug('i: ' + i);
                        if (str1.substring(i, i+1) == str2.substring(j, j+1)){
                            distance.put(i + ',' + j, distance.get((i-1) + ',' + (j-1)));
                        } else {
                            distance.put(i + ',' + j, LevenshteinDistance.minimum(
                                distance.get((i-1) + ',' + j),
                                distance.get(i + ',' + (j-1)),
                                distance.get((i-1) + ',' + (j-1))
                            ) + 1);
                        }
                        i = i + 1;
                    } while (i < str1.length());
                    j = j + 1;
                } while (j < str2.length());

                return distance.get((str1.length() - 1) + ',' + (str2.length() - 1));
        }
}