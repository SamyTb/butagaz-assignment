@isTest
public class AP_StrDist_Interface_01_Test{
    public static void roughlyEquals (decimal d1, double d2){
        AP_StrDist_Interface_01_Test.roughlyEquals((double) d1, d2);
    }
    
    public static void roughlyEquals(double d1, double d2){
        System.assert(Math.abs(d1 - d2) < 0.001, 'too different: ' + d1 + ' != ' + d2);
    }
}