@isTest
public class AP_StrDist_JaroWinkler_01_Test{   
    
    public static testmethod void testAP_StrDist_JaroWinkler_01(){
        // Simple test cases
        
        AP_StrDist_Interface_01_Test.roughlyEquals(1.0, AP_StrDist_JaroWinkler_01.similarity('', ''));
        AP_StrDist_Interface_01_Test.roughlyEquals(1.0, AP_StrDist_JaroWinkler_01.similarity('abc', 'abc'));
        AP_StrDist_Interface_01_Test.roughlyEquals(1.0, AP_StrDist_JaroWinkler_01.similarity('ab', 'ab'));
        AP_StrDist_Interface_01_Test.roughlyEquals(1.0, AP_StrDist_JaroWinkler_01.similarity('a', 'a'));
        AP_StrDist_Interface_01_Test.roughlyEquals(1.0, AP_StrDist_JaroWinkler_01.similarity('abcd', 'abcd'));
        AP_StrDist_Interface_01_Test.roughlyEquals(0.0, AP_StrDist_JaroWinkler_01.similarity('abc', 'def'));
        
        // More complex test cases
        double score;
        
        score = (4/6.0 + 4/5.0 + (4-0)/4.0)/3.0; // Base
        score = score + ((1 * (1 - score)) / 10); // Prefix
        AP_StrDist_Interface_01_Test.roughlyEquals(score, AP_StrDist_JaroWinkler_01.similarity('DwAyNE', 'DuANE'));
        
        score = (6/6.0 + 6/6.0 + (6-1)/6.0)/3.0;
        score = score + ((3 * (1 - score)) / 10); 
        AP_StrDist_Interface_01_Test.roughlyEquals(score, AP_StrDist_JaroWinkler_01.similarity('MARTHA', 'MARHTA'));
        
        score = (3/5.0 + 3/5.0 + (3-0)/3.0)/3.0;
        AP_StrDist_Interface_01_Test.roughlyEquals(score, AP_StrDist_JaroWinkler_01.similarity('CRATE', 'TRACE'));
        
        score = (4/5.0 + 4/8.0 + (4-0)/4.0)/3.0;
        score = score + ((2 * (1 - score)) / 10); // prefix
        AP_StrDist_Interface_01_Test.roughlyEquals(score, AP_StrDist_JaroWinkler_01.similarity('DIXON', 'DICKSONX'));
        
        score = (5/6.0 + 5/8.0 + (5-1)/5.0)/3.0;
        AP_StrDist_Interface_01_Test.roughlyEquals(score, AP_StrDist_JaroWinkler_01.similarity('anderson', 'barnes'));
        
        AP_StrDist_Interface_01_Test.roughlyEquals(0.982, AP_StrDist_JaroWinkler_01.similarity('SHACKLEFORD', 'SHACKELFORD'));
        
        AP_StrDist_Interface_01_Test.roughlyEquals(0.956, AP_StrDist_JaroWinkler_01.similarity('NICHLESON', 'NICHULSON'));
        
        AP_StrDist_Interface_01_Test.roughlyEquals(0.832, AP_StrDist_JaroWinkler_01.similarity('JONES', 'JOHNSON'));
        
        
        AP_StrDist_Interface_01_Test.roughlyEquals(0.933, AP_StrDist_JaroWinkler_01.similarity('MASSEY', 'MASSIE'));
        
        AP_StrDist_Interface_01_Test.roughlyEquals(0.922, AP_StrDist_JaroWinkler_01.similarity('ABROMS', 'ABRAMS'));
        
        AP_StrDist_Interface_01_Test.roughlyEquals(0.467, AP_StrDist_JaroWinkler_01.similarity('ITMAN', 'SMITH'));
        
        AP_StrDist_Interface_01_Test.roughlyEquals(0.926, AP_StrDist_JaroWinkler_01.similarity('JERALDINE', 'GERALDINE'));
        
        AP_StrDist_Interface_01_Test.roughlyEquals(0.921, AP_StrDist_JaroWinkler_01.similarity('MICHELLE', 'MICHAEL'));
        
        AP_StrDist_Interface_01_Test.roughlyEquals(0.933, AP_StrDist_JaroWinkler_01.similarity('JULIES', 'JULIUS'));
        
        AP_StrDist_Interface_01_Test.roughlyEquals(0.805, AP_StrDist_JaroWinkler_01.similarity('SEAN', 'SUSAN'));
        
        AP_StrDist_Interface_01_Test.roughlyEquals(0.933, AP_StrDist_JaroWinkler_01.similarity('JON', 'JOHN'));
    }
}