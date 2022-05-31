/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AP_Query_01_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Pro' LIMIT 1];
        
        Custom_Settings__c c1 = new Custom_Settings__c (name='UserIDsAllowedToModifyClosedAccounts',value__c = UserInfo.getUserId());
        insert new List<Custom_Settings__c> { c1 };
        
        List<Account> lAccount=new List<Account>();
        for(Integer i=0;i<10;i++){
            lAccount.add(Utils.createAccountBA(i,rt.Id));
        }
        Account tempAccount=Utils.createAccountBA(1,rt.Id);
        tempAccount.Name='abcdefgh';
        lAccount.add(tempAccount);
        
        insert lAccount;
        
         List<String> queryFields = new List<String>{
            'Id',                   'Name',
            'Industry'
        };
        Test.startTest();
        List<AP_Query_01.QuerySetClause> queryFilters = new List<AP_Query_01.QuerySetClause>();
                        
        queryFilters.add(new AP_Query_01.QuerySetLikeClause('Name', 'test'));      
        AP_Query_01.QuerySet query = new AP_Query_01.QuerySet('Account', queryFields, queryFilters);
        Integer iNumberRows=query.getCount();
        List<Account> lresult=query.getRecords(11,5);
        System.assertEquals(10,iNumberRows);
        System.assertEquals(5,lresult.size());
        System.assertEquals('TestAccount5',lresult[0].Name);

        queryFilters = new List<AP_Query_01.QuerySetClause>();
        queryFilters.add(new AP_Query_01.QuerySetEqualsClause('Name', 'testAccount3'));
        query = new AP_Query_01.QuerySet('Account', queryFields, queryFilters);
        iNumberRows=query.getCount();
        lresult=query.getRecords(11,0);
        System.assertEquals(1,iNumberRows);
        System.assertEquals(1,lresult.size());
        System.assertEquals('TestAccount3',lresult[0].Name);
        Test.stopTest();
    }

    public static testmethod void testClausesAuthoring(){
        // This method compares the SOQL that is output by the Clauses and compares it to hand-written SOQL.

        // Test the "Equals" Clause.
        AP_Query_01.QuerySetEqualsClause eq1 = new AP_Query_01.QuerySetEqualsClause('param', 'value1');
        AP_Query_01.QuerySetEqualsClause eq2 = new AP_Query_01.QuerySetEqualsClause('param', 12.0);
        AP_Query_01.QuerySetEqualsClause eq3 = new AP_Query_01.QuerySetEqualsClause('param', Double.valueOf('1.25'));
        AP_Query_01.QuerySetEqualsClause eq4 = new AP_Query_01.QuerySetEqualsClause('param', 22);
        AP_Query_01.QuerySetEqualsClause eq5 = new AP_Query_01.QuerySetEqualsClause('param', true);
        AP_Query_01.QuerySetEqualsClause eq6 = new AP_Query_01.QuerySetEqualsClause('param', false);

        System.assertEquals('(param = \'value1\')', eq1.getClause());
        System.assertEquals('(param = 12.0)', eq2.getClause());
        System.assertEquals('(param = 1.25)', eq3.getClause());
        System.assertEquals('(param = 22)', eq4.getClause());
        System.assertEquals('(param = true)', eq5.getClause());
        System.assertEquals('(param = false)', eq6.getClause());

        // Test the "LIKE" Clause.
        AP_Query_01.QuerySetLikeClause lk1 = new AP_Query_01.QuerySetLikeClause('param', 'similar');
        AP_Query_01.QuerySetLikeClause lk2 = new AP_Query_01.QuerySetLikeClause('param', '22');
        System.assertEquals('(param LIKE \'%similar%\')', lk1.getClause());
        System.assertEquals('(param LIKE \'%22%\')', lk2.getClause());

        // Test the "OR" Clause.
        AP_Query_01.QuerySetOrClause or1 = new AP_Query_01.QuerySetOrClause(new List<AP_Query_01.QuerySetClause>{eq1, eq2});
        System.assertEquals('((param = \'value1\') OR (param = 12.0))', or1.getClause());

        // Test the "IN" Clause.
        AP_Query_01.QuerySetInClause in1 = new AP_Query_01.QuerySetInClause('param', new List<String>{'A', 'B', 'C'});
        AP_Query_01.QuerySetInClause in2 = new AP_Query_01.QuerySetInClause('param', new List<Id>{ '001C000000o4OoiIAE', '001C000000O4OOIIA3', '001C000000O4OOJIA3' });
        System.assertEquals('(param IN ( \'A\', \'B\', \'C\' ))', in1.getClause());
        System.assertEquals('(param IN ( \'001C000000o4OoiIAE\', \'001C000000O4OOIIA3\', \'001C000000O4OOJIA3\' ))', in2.getClause());

        // Test the "NOT" Clause.
        AP_Query_01.QuerySetNotClause not1 = new AP_Query_01.QuerySetNotClause(eq1);
        AP_Query_01.QuerySetNotClause not2 = new AP_Query_01.QuerySetNotClause(eq2);
        AP_Query_01.QuerySetNotClause not3 = new AP_Query_01.QuerySetNotClause(eq3);
        System.assertEquals('(NOT (param = \'value1\'))', not1.getClause());
        System.assertEquals('(NOT (param = 12.0))', not2.getClause());
        System.assertEquals('(NOT (param = 1.25))', not3.getClause());
    }

    public static testmethod void testQueryAuthoring(){
        // This method compares the SOQL that is output by a full Query to hand-written SOQL
        AP_Query_01.QuerySetEqualsClause eq1 = new AP_Query_01.QuerySetEqualsClause('param', 'value1');
        AP_Query_01.QuerySetEqualsClause eq2 = new AP_Query_01.QuerySetEqualsClause('param', 12.0);
        AP_Query_01.QuerySetOrClause or1 = new AP_Query_01.QuerySetOrClause(new List<AP_Query_01.QuerySetClause>{eq1, eq2});
        AP_Query_01.QuerySetLikeClause lk1 = new AP_Query_01.QuerySetLikeClause('param', 'similar');

        String sobjectName = 'Account';
        List<String> sobjectFields = new List<String>{'field1', 'field2'};
        List<AP_Query_01.QuerySetClause> clauses = new List<AP_Query_01.QuerySetClause>{lk1, or1};
        AP_Query_01.QuerySet qs = new AP_Query_01.QuerySet('Account', sobjectFields, clauses);
        System.assertEquals('SELECT field1, field2 FROM Account WHERE (param LIKE \'%similar%\') AND ((param = \'value1\') OR (param = 12.0))', String.join(qs.getBaseQueryClauses(), ' '));
    }

    public static testmethod void SOQLValidTest(){
        // This method ensures that the SOQL that is output is syntactically correct.
    }
}