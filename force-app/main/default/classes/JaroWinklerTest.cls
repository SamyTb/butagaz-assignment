@isTest
public class JaroWinklerTest{   
    public static void roughlyEquals (decimal d1, double d2){
        JaroWinklerTest.roughlyEquals((double) d1, d2);
    }
    
    public static void roughlyEquals(double d1, double d2){
        System.assert(Math.abs(d1 - d2) < 0.001, 'too different: ' + d1 + ' != ' + d2);
    }
    
    public static testmethod void testJaroWinkler(){
        // Simple test cases
        
        JaroWinklerTest.roughlyEquals(1.0, JaroWinkler.similarity('', ''));
        JaroWinklerTest.roughlyEquals(1.0, JaroWinkler.similarity('abc', 'abc'));
        JaroWinklerTest.roughlyEquals(1.0, JaroWinkler.similarity('ab', 'ab'));
        JaroWinklerTest.roughlyEquals(1.0, JaroWinkler.similarity('a', 'a'));
        JaroWinklerTest.roughlyEquals(1.0, JaroWinkler.similarity('abcd', 'abcd'));
        JaroWinklerTest.roughlyEquals(0.0, JaroWinkler.similarity('abc', 'def'));
        
        // More complex test cases
        double score;
        
        score = (4/6.0 + 4/5.0 + (4-0)/4.0)/3.0; // Base
        score = score + ((1 * (1 - score)) / 10); // Prefix
        JaroWinklerTest.roughlyEquals(score, JaroWinkler.similarity('DwAyNE', 'DuANE'));
        
        score = (6/6.0 + 6/6.0 + (6-1)/6.0)/3.0;
        score = score + ((3 * (1 - score)) / 10); 
        JaroWinklerTest.roughlyEquals(score, JaroWinkler.similarity('MARTHA', 'MARHTA'));
        
        score = (3/5.0 + 3/5.0 + (3-0)/3.0)/3.0;
        JaroWinklerTest.roughlyEquals(score, JaroWinkler.similarity('CRATE', 'TRACE'));
        
        score = (4/5.0 + 4/8.0 + (4-0)/4.0)/3.0;
        score = score + ((2 * (1 - score)) / 10); // prefix
        JaroWinklerTest.roughlyEquals(score, JaroWinkler.similarity('DIXON', 'DICKSONX'));
        
        score = (5/6.0 + 5/8.0 + (5-1)/5.0)/3.0;
        JaroWinklerTest.roughlyEquals(score, JaroWinkler.similarity('anderson', 'barnes'));
        
        JaroWinklerTest.roughlyEquals(0.982, JaroWinkler.similarity('SHACKLEFORD', 'SHACKELFORD'));
        
        JaroWinklerTest.roughlyEquals(0.956, JaroWinkler.similarity('NICHLESON', 'NICHULSON'));
        
        JaroWinklerTest.roughlyEquals(0.832, JaroWinkler.similarity('JONES', 'JOHNSON'));
        
        
        JaroWinklerTest.roughlyEquals(0.933, JaroWinkler.similarity('MASSEY', 'MASSIE'));
        
        JaroWinklerTest.roughlyEquals(0.922, JaroWinkler.similarity('ABROMS', 'ABRAMS'));
        
        JaroWinklerTest.roughlyEquals(0.467, JaroWinkler.similarity('ITMAN', 'SMITH'));
        
        JaroWinklerTest.roughlyEquals(0.926, JaroWinkler.similarity('JERALDINE', 'GERALDINE'));
        
        JaroWinklerTest.roughlyEquals(0.921, JaroWinkler.similarity('MICHELLE', 'MICHAEL'));
        
        JaroWinklerTest.roughlyEquals(0.933, JaroWinkler.similarity('JULIES', 'JULIUS'));
        
        JaroWinklerTest.roughlyEquals(0.805, JaroWinkler.similarity('SEAN', 'SUSAN'));
        
        JaroWinklerTest.roughlyEquals(0.933, JaroWinkler.similarity('JON', 'JOHN'));
    }
}