@isTest
public class TestOrganization {
    public static testmethod void testHeadlessSingleCreate (){
        // Here, we want test the creation of Headless nodes in an organization.
        // We test one-by-one creation
        // We want to make sure a given organization only has one headless node.
        // We want to make sure different organizations can have their own headless nodes.
        TestUtilitiesOrganization.bypassUserRules();
        
        Activity_Domain__c newDomain = TestUtilitiesOrganization.createActivityDomain('NewDomain');
        insert newDomain;
        Organization__c newOrg1 = TestUtilitiesOrganization.createOrganization('newOrg', 'DOM', 'CREA', newDomain);
        Organization__c newOrg2 = TestUtilitiesOrganization.createOrganization('newOrg2', 'PRO', 'CREA', newDomain);
        
        insert newOrg1;
        insert newOrg2;
        
        Test.startTest();
        // Let's add an itial headless node => Should be OK
        System.debug('+++++++ Adding initial headless node');
        Organization_Node__c okNode1 = TestUtilitiesOrganization.createNode(0, 500, newOrg1);
        insert okNode1;
        System.debug('+++++++ Added headless node => OK');
        
        // Let's give him a child => Should be OK
        System.debug('+++++++ Adding child node');
        Organization_Node__c okNode11 = TestUtilitiesOrganization.createNode(1, 400, newOrg1, okNode1);
        insert okNode11;
        System.debug('+++++++ Added child node => OK');
        // Let's create an unrelated headless node => Should be OK
        System.debug('+++++++ Adding unrelated headless node');
        Organization_Node__c okNode2 = TestUtilitiesOrganization.createNode(0, 600, newOrg2);
        insert okNode2;
        System.debug('+++++++ Added unrelated headless node => OK');
        
        // Let's create another headless node => Should fail
        Boolean hasErrored = false;
        System.debug('+++++++ Adding duplicate headless node');
        try {
            Organization_Node__c failNode1 = TestUtilitiesOrganization.createNode(0, 200, newOrg1);
            insert failNode1;
        } catch (System.DmlException e) { // We'd like to be more precise..
            System.debug('+++++++ Adding headless node => Exception raised');
            System.assert( 
                e.getMessage().contains(System.Label.Error_MultipleHeadlessNodes), 
                e.getMessage() 
            );
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            System.debug('+++++++ Adding headless node => Exception is the expected one.');
            
        }
        
        System.debug('+++++++ Added headless node => OK');
        Test.stopTest();
        
    }
    
    
    public static testmethod void testHeadlessBulkCreate (){
        // Here, we want test the creation of Headless nodes in an organization.
        // We test bulk creation
        // We want to make sure that we can't create two headless nodes in an organization even if they're 
        // added at the same time
        TestUtilitiesOrganization.bypassUserRules();
        
        Activity_Domain__c newDomain = TestUtilitiesOrganization.createActivityDomain('NewDomain');
        insert newDomain;
        Organization__c newOrg = TestUtilitiesOrganization.createOrganization('newOrg', 'DOM', 'CREA', newDomain );
        insert newOrg;
    
        Organization_Node__c failNode1 = TestUtilitiesOrganization.createNode(0, 200, newOrg);
        Organization_Node__c failNode2 = TestUtilitiesOrganization.createNode(0, 200, newOrg);
        
        List<Organization_Node__c> failNodes = new List<Organization_Node__c>();
        failNodes.add(failNode1);
        failNodes.add(failNode2);
        
        Boolean hasErrored = false;
        
        Test.startTest();
        
        try {
            System.debug('+++++++ Bulk adding duplicate headless nodes');
            insert failNodes;
        } catch (System.DmlException e) { 
            System.debug('+++++++ Bulk adding duplicate headless nodes => Exception raised');
            System.assert( 
                e.getMessage().contains(System.Label.Error_MultipleHeadlessNodes), 
                e.getMessage() 
            );
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            System.debug('+++++++ Bulk adding headless nodes => Exception is the expected one.');
            
        }
        
        Test.stopTest();
    }
    
    
    public static testmethod void testInvertRel (){
        // Here we test the inversion of a parent and a child in a relationship.
        // We want the inversion to work if the usual conditions apply
        // We want it to fail if they don't. 
        TestUtilitiesOrganization.bypassUserRules();
        
        Activity_Domain__c newDomain = TestUtilitiesOrganization.createActivityDomain('NewDomain');
        insert newDomain;
        Organization__c newOrg = TestUtilitiesOrganization.createOrganization('newOrg', 'DOM', 'CREA', newDomain);
        insert newOrg;
    
        Organization_Node__c parentNode = TestUtilitiesOrganization.createNode(0, 200, newOrg);
        insert parentNode;
        Organization_Node__c childNode = TestUtilitiesOrganization.createNode(1, 100, newOrg, parentNode);
        insert childNode;
        
        Test.startTest();
        System.debug('+++++++ Exchanging relationship');
        childNode.Manager_Organization_Node__c = null;
        childNode.Approval_Level__c = 0;
        childNode.Latitude_Level__c = 200;
        parentNode.Manager_Organization_Node__c = childNode.Id;
        parentNode.Approval_Level__c = 1;
        parentNode.Latitude_Level__c = 100;
        List<Organization_Node__c> lNodes = new List<Organization_Node__c>();
        lNodes.add(childNode);
        lNodes.add(parentNode);
        System.debug('+++++++ Inserting Nodes');
        update lNodes;
        Test.stopTest();
    }
    
    public static testmethod void testReparent() {
        // Here we test what happens when we reparent a child
        // We want to be able to do so when the validation rules pass
        // We want it to fail when they don't
        TestUtilitiesOrganization.bypassUserRules();
        
        Activity_Domain__c newDomain = TestUtilitiesOrganization.createActivityDomain('NewDomain');
        insert newDomain;
        Organization__c newOrg = TestUtilitiesOrganization.createOrganization('newOrg', 'DOM', 'CREA', newDomain);
            
        insert newOrg;
        Organization__c otherOrg = TestUtilitiesOrganization.createOrganization('otherOrg', 'PRO', 'CREA', newDomain);
        insert otherOrg;
        Organization__c anotherOrg = TestUtilitiesOrganization.createOrganization('anotherOrg', 'PRO', 'FIDE', newDomain);
        insert anotherOrg;
        
        Organization_Node__c parentNode1 = TestUtilitiesOrganization.createNode(0, 200, newOrg);
        insert parentNode1;
        Organization_Node__c parentNode2 = TestUtilitiesOrganization.createNode(0, 50, otherOrg);
        insert parentNode2;
        Organization_Node__c parentNode3 = TestUtilitiesOrganization.createNode(0, 200, anotherOrg);
        insert parentNode3;
        
        Organization_Node__c childNode = TestUtilitiesOrganization.createNode(1, 100, newOrg, parentNode1);
        insert childNode;
        
        Boolean hasErrored1 = false;
        Boolean hasErrored2 = true;
        
        Test.startTest();
        
        try {
            childNode.Manager_Organization_Node__c = parentNode2.Id;
            update childNode;
        } catch (System.DmlException e) {
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            hasErrored1 = true;
        }
        System.assertEquals(true, hasErrored1);
        childNode.Manager_Organization_Node__c = parentNode1.Id;
        
        
        try {
            childNode.Manager_Organization_Node__c = parentNode3.Id;
            update childNode;
        } catch (System.DmlException e) { 
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            hasErrored2 = true;
        }
        System.assertEquals(true, hasErrored2);
        childNode.Manager_Organization_Node__c = parentNode1.Id;

        Test.stopTest();
        
    }
    
    public static testmethod void testValidateInsertChildren() {
        // Here we make sure the SFDC standard validation rules pass OK
        // We just make some checks. 
        TestUtilitiesOrganization.bypassUserRules();
        
        Activity_Domain__c newDomain = TestUtilitiesOrganization.createActivityDomain('NewDomain');
        insert newDomain;
        Organization__c newOrg = TestUtilitiesOrganization.createOrganization('newOrg', 'DOM', 'CREA', newDomain);
        insert newOrg;
        
        Organization__c otherOrg = TestUtilitiesOrganization.createOrganization('newOrg', 'DOM', 'CREA', newDomain);
        insert otherOrg;
    
        Organization_Node__c parentNode = TestUtilitiesOrganization.createNode(1, 200, newOrg);
        insert parentNode;
        
        // Should fail for Approval Level
        Organization_Node__c childNode1 = TestUtilitiesOrganization.createNode(0, 100, newOrg, parentNode); 
        
        // Should fail for Latitude Level
        Organization_Node__c childNode2 = TestUtilitiesOrganization.createNode(2, 300, newOrg, parentNode);
        
        // Should fail for Organization
        Organization_Node__c childNode3 = TestUtilitiesOrganization.createNode(2, 100, otherOrg, parentNode);
        
        // Should pass
        Organization_Node__c childNode4 = TestUtilitiesOrganization.createNode(2, 100, newOrg, parentNode);
        
        Boolean hasErrored1 = false;
        Boolean hasErrored2 = false;
        Boolean hasErrored3 = false;
        
        Test.startTest();
        
        // Updating the parent should not raise an error because he's the headless already!
        update parentNode;
        
        try {
            System.debug('+++++++ Adding node with Lower Approval Level');
            insert childNode1;
        } catch (System.DmlException e) { 
            System.debug('+++++++ Adding node with Lower Approval Level => Exception raised');
            System.assert( 
                e.getMessage().contains(System.Label.Error_InvalidApprovalLevel), 
                e.getMessage() 
            );
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            System.debug('+++++++ Adding node with Lower Approval Level => Exception is the expected one.');
            hasErrored1 = true;
        }
        
        try {
            System.debug('+++++++ Adding node with Higher Latitude Level');
            insert childNode2;
        } catch (System.DmlException e) { // We'd like to be more precise..
            System.debug('+++++++ Adding node with Higher Latitude Level => Exception raised');
            System.assert( 
                e.getMessage().contains(System.Label.Error_InvalidLatitudeLevel), 
                e.getMessage() 
            );
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            System.debug('+++++++ Adding node with Higher Latitude Level => Exception is the expected one.');
            hasErrored2 = true;
        }
        
        try {
            System.debug('+++++++ Adding node with Different Organization');
            insert childNode3;
        } catch (System.DmlException e) { // We'd like to be more precise..
            System.debug('+++++++ Adding node with Different Organization => Exception raised');
            System.assert( 
                e.getMessage().contains(System.Label.Error_InvalidOrganization), 
                e.getMessage() 
            );
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            System.debug('+++++++ Adding node with Different Organization => Exception is the expected one.');
            hasErrored3 = true;
        }
        
        System.assertEquals(true, hasErrored1);
        System.assertEquals(true, hasErrored2);
        System.assertEquals(true, hasErrored3);
        
        insert childNode4;
        
        Test.stopTest();
    }
    
    
    
    public static testmethod void testValidateUpdateParent (){
        // Here we want to make sure that the validation rules kick in when a parent is updated
        // We don't want to be able to update the parent when the children make it invalid.
        TestUtilitiesOrganization.bypassUserRules();
        
        Activity_Domain__c newDomain = TestUtilitiesOrganization.createActivityDomain('NewDomain');
        insert newDomain;
        Organization__c newOrg = TestUtilitiesOrganization.createOrganization('newOrg', 'DOM', 'CREA', newDomain);
        insert newOrg;
        
        Organization__c otherOrg = TestUtilitiesOrganization.createOrganization('otherOrg', 'PRO', 'CREA', newDomain);
        insert otherOrg;
    
        Organization_Node__c parentNode = TestUtilitiesOrganization.createNode(0, 200, newOrg);
        insert parentNode;
        
        Organization_Node__c childNode1 = TestUtilitiesOrganization.createNode(1, 100, newOrg, parentNode);
        insert childNode1;
        Organization_Node__c childNode2 = TestUtilitiesOrganization.createNode(1, 100, newOrg, parentNode);
        insert childNode2;
        
        Organization_Node__c grandChildNode1 = TestUtilitiesOrganization.createNode(2, 50, newOrg, childNode1);
        insert grandChildNode1;
        
        Test.startTest();
        
        Boolean hasErrored1 = false;
        Boolean hasErrored2 = false;
        Boolean hasErrored3 = false;
        
        try {
            System.debug('+++++++ Updating node to Higher Approval Level');
            parentNode.Approval_Level__c = 2;
            update parentNode;
        } catch (System.DmlException e) { // We'd like to be more precise..
            System.debug('+++++++ Updating node to Higher Approval Level => Exception raised');
            System.assert(
                e.getMessage().contains(System.Label.Error_InvalidApprovalLevel), 
                e.getMessage() 
            );
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            System.debug('+++++++ Updating node to Higher Approval Level => Exception is the expected one.');
            hasErrored1 = true;
        }
        
        System.assertEquals(true, hasErrored1);
        parentNode.Approval_Level__c = 0;
        
        try {
            System.debug('+++++++ Updating node to Lower Latitude Level');
            parentNode.Latitude_Level__c = 100;
            update parentNode;
        } catch (System.DmlException e) { // We'd like to be more precise..
            System.debug('+++++++ Updating node to Lower Latitude Level => Exception raised');
            System.assert(
                e.getMessage().contains(System.Label.Error_InvalidLatitudeLevel), 
                e.getMessage() 
            );
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            System.debug('+++++++ Updating node to Lower Latitude Level => Exception is the expected one.');
            hasErrored2 = true;
        }
        
        System.assertEquals(true, hasErrored2);
        parentNode.Latitude_Level__c = 200;
        
        try {
            System.debug('+++++++ Updating node to Different Organization');
            parentNode.Organization__c = otherOrg.Id;
            update parentNode;
        } catch (System.DmlException e) { // We'd like to be more precise..
            System.debug('+++++++ Updating node to Different Organization => Exception raised');
            System.assert(
                e.getMessage().contains(System.Label.Error_InvalidOrganization), 
                e.getMessage() 
            );
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            System.debug('+++++++ Updating node to Different Organization => Exception is the expected one.');
            hasErrored3 = true;
        }
        
        System.assertEquals(true, hasErrored3);
        parentNode.Organization__c = newOrg.Id;
        
        Test.stopTest();
    }
    
    
    /*
    // There's a design decision needed as to whether we need this or not.
    // At the moment, we can't, the parent record must exist first to be able to insert.
    // There exists a workaround: http://bobbuzzard.blogspot.fr/2012/03/create-parent-and-child-records-in-one.html
    // This relies on using an external ID as identifier and then inserting a generic list of sObjects. 
    // We need to see whether we want to implement that.
    
    public static testmethod void testSimultaneousInsert (){
        // Here we test what happens when we insert a parent and a child at the same time
        // We want it to pass when the validations rules pass
        // We want it to fail if they don't. 
        TestUtilitiesOrganization.bypassUserRules();
        
        Activity_Domain__c newDomain = TestUtilitiesOrganization.createActivityDomain('NewDomain');
        insert newDomain;

        Organization__c newOrg = TestUtilitiesOrganization.createOrganization('newOrg', 'DOM', 'CREA', newDomain);
        insert newOrg;
        Organization__c otherOrg = TestUtilitiesOrganization.createOrganization('otherOrg', 'PRO', 'CREA', newDomain);
        insert otherOrg;
    
        Organization_Node__c passParentNode = TestUtilitiesOrganization.createNode(0, 200, newOrg);
        Organization_Node__c passChildNode = TestUtilitiesOrganization.createNode(1, 100, newOrg, passParentNode); // Will pass
        List<Organization_Node__c> lPassNodes = new List<Organization_Node__c>();
        lPassNodes.add(passParentNode);
        lPassNodes.add(passChildNode);
        
        Organization_Node__c failParentNode = TestUtilitiesOrganization.createNode(0, 200, newOrg);
        Organization_Node__c failChildNode = TestUtilitiesOrganization.createNode(1, 300, newOrg, failParentNode); // Will fail.
        List<Organization_Node__c> lFailNodes = new List<Organization_Node__c>();
        lFailNodes.add(failParentNode);
        lFailNodes.add(failChildNode);
        
        Boolean hasErrored = false;
        
        Test.startTest();
        
        System.debug('[testSimultaneousInsert]: Inserting lPassNodes');
        insert lPassNodes; 
        System.debug('[testSimultaneousInsert]: Inserted lPassNodes');
        
        System.debug('[testSimultaneousInsert]: Inserting lFailNodes');
        try {
            insert lFailNodes;
        } catch (System.DmlException e) { // We'd like to be more precise..
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            hasErrored = true;
        }
        System.debug('[testSimultaneousInsert]: Inserted lFailNodes');
        System.assertEquals(true, hasErrored);
        
        Test.stopTest();
    }
    */
    
    public static testmethod void testInsertDuplicateUsers (){
        // Here we want to make sure that a single User can't be at two spots on an Organization
        // We also want to check that he can be on two spots on two different Organizations
        
        User user1 = TestUtilitiesOrganization.CreateTestUser('user1');
        User user2 = TestUtilitiesOrganization.CreateTestUser('user2');
        insert user1;
        insert user2;
        
        Activity_Domain__c newDomain = TestUtilitiesOrganization.createActivityDomain('NewDomain');
        insert newDomain;
        
        Organization__c org1 = TestUtilitiesOrganization.createOrganization('org1', 'DOM', 'CREA', newDomain);
        Organization__c org2 = TestUtilitiesOrganization.createOrganization('org2', 'PRO', 'CREA', newDomain);
        Organization__c org3 = TestUtilitiesOrganization.createOrganization('org2', 'PRO', 'FIDE', newDomain);
        insert org1;
        insert org2;
        insert org3;
        
        Organization_Node__c unrelatedNode = TestUtilitiesOrganization.createNode(0, 200, org1);
        insert unrelatedNode;
        
        Test.startTest();
        
        // Testing inserting two nodes (sequential)
        System.debug('[testInsertDuplicateUsers] Testing successive duplicate insert fails.');
        
        Boolean seqHasErrored = false;
        
        
        Organization_Node__c seqNode1 = TestUtilitiesOrganization.createNode(1, 100, org1, unrelatedNode, user1);
        Organization_Node__c seqNode2 = TestUtilitiesOrganization.createNode(1, 100, org1, unrelatedNode, user1);
        insert seqNode1; 
        try {
            insert seqNode2;
        } catch (System.DmlException e) { // We'd like to be more precise..
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            System.assert(
                e.getMessage().contains(System.Label.Error_DuplicateUserInOrg), 
                e.getMessage() 
            );
            seqHasErrored = true;
        }
        System.assertEquals(true, seqHasErrored);
        
        // Testing inserting two nodes (simulatenous)
        System.debug('[testInsertDuplicateUsers] Testing simulatenous duplicate insert fails.');
        Boolean simHasErrored = false;
         
        Organization_Node__c simNode1 = TestUtilitiesOrganization.createNode(1, 100, org1, unrelatedNode, user1);
        Organization_Node__c simNode2 = TestUtilitiesOrganization.createNode(1, 100, org1, unrelatedNode, user1);
        List<Organization_Node__c> simNodes = new List<Organization_Node__c>();
        simNodes.add(simNode1);
        simNodes.add(simNode2);
        
        try {
            insert simNodes;
        } catch (System.DmlException e) { // We'd like to be more precise..
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            System.assert(
                e.getMessage().contains(System.Label.Error_DuplicateUserInOrg), 
                e.getMessage() 
            );
            simHasErrored = true;
        }
        System.assertEquals(true, simHasErrored);
        /*
        Organization_Node__c node1 = TestUtilitiesOrganization.createNode(0, 200, newOrg);
        */
        Test.stopTest();
        
        // Testing that two orgs is OK with one user.
        System.debug('[testInsertDuplicateUsers] Testing unrelated inserts for one user works.');
        Organization_Node__c unrelNode1 = TestUtilitiesOrganization.createNode(1, 100, org2, user1);
        Organization_Node__c unrelNode2 = TestUtilitiesOrganization.createNode(1, 100, org3, user1);
        insert unrelNode1;
        insert unrelNode2;
    }
    
    public static testmethod void testUpdateDuplicateUsers (){
        // Here we want to ensure that updating two nodes into a single user fails
        // We also want to ensure that swapping users is OK.
        
        User user1 = TestUtilitiesOrganization.CreateTestUser('user1');
        User user2 = TestUtilitiesOrganization.CreateTestUser('user2');
        User user3 = TestUtilitiesOrganization.CreateTestUser('user3');
        insert user1; insert user2; insert user3;
        
        Activity_Domain__c newDomain = TestUtilitiesOrganization.createActivityDomain('NewDomain');
        insert newDomain;
        
        Organization__c org1 = TestUtilitiesOrganization.createOrganization('org1', 'DOM', 'CREA', newDomain);
        Organization__c org2 = TestUtilitiesOrganization.createOrganization('org2', 'PRO', 'CREA', newDomain);
        Organization__c org3 = TestUtilitiesOrganization.createOrganization('org2', 'PRO', 'FIDE', newDomain);
        insert org1; insert org2; insert org3;
        
        Organization_Node__c unrelatedNode = TestUtilitiesOrganization.createNode(0, 200, org1);
        insert unrelatedNode;
        
        Boolean hasErrored = null;
        Organization_Node__c node1 = null;
        Organization_Node__c node2 = null;
        
        List<Organization_Node__c> updateNodes = null;
        
        Test.startTest();
        
        // Here we have two distinct nodes, and update one into the same hierarchy as the first one. 
        System.debug('[testUpdateDuplicateUsers] Testing updating a Node when there\'s another one with the same user fails.');
        node1 = TestUtilitiesOrganization.createNode(1, 100, org2, user1);
        node2 = TestUtilitiesOrganization.createNode(2, 50, org3, user1);
        insert node1; insert node2;
        
        node2.Manager_Organization_Node__c = node1.Id;
        node2.Organization__c = org2.Id;
        hasErrored = false;
        try {
            update node2;
        } catch (System.DmlException e) { // We'd like to be more precise..
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            System.assert(
                e.getMessage().contains(System.Label.Error_DuplicateUserInOrg), 
                e.getMessage() 
            );
            hasErrored = true;
        }
        System.assertEquals(true, hasErrored);
        
        delete node1; delete node2; 
        
        // Here we have two Nodes that we both update into the same hierarchy.
        System.debug('[testUpdateDuplicateUsers] Testing updating two Nodes on the same Hierarchy into the same User fails.');
        node1 = TestUtilitiesOrganization.createNode(1, 100, org1, unrelatedNode, user1);
        node2 = TestUtilitiesOrganization.createNode(1, 100, org1, unrelatedNode, user2);
        insert node1; insert node2;
        updateNodes = new List<Organization_Node__c>(); updateNodes.add(node1);updateNodes.add(node2);
        
        node1.User__c = user3.Id;
        node2.User__c = user3.Id;
        
        hasErrored = false;
        try {
            update updateNodes;
        } catch (System.DmlException e) { // We'd like to be more precise..
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            System.assert(
                e.getMessage().contains(System.Label.Error_DuplicateUserInOrg), 
                e.getMessage() 
            );
            hasErrored = true;
        }
        System.assertEquals(true, hasErrored);
        delete node1; delete node2;
        
        // Here we test that updating a single Node works (IE. Validation ignores the current Node)
        System.debug('[testUpdateDuplicateUsers] Testing updating a single Node');
        node1 = TestUtilitiesOrganization.createNode(1, 100, org1, unrelatedNode, user1);
        insert node1;
        update node1;
        delete node1;
        
        // Here we have two Nodes that we both update so as to swap the users on them. 
        System.debug('[testUpdateDuplicateUsers] Testing swapping two Nodes works');
        node1 = TestUtilitiesOrganization.createNode(1, 100, org1, unrelatedNode, user1);
        node2 = TestUtilitiesOrganization.createNode(1, 100, org1, unrelatedNode, user2);
        insert node1; insert node2;
        updateNodes = new List<Organization_Node__c>(); updateNodes.add(node1);updateNodes.add(node2);
        
        node1.User__c = user2.Id;
        node2.User__c = user1.Id;
        
        update updateNodes;
        
        Test.stopTest();
    }

    public static testMethod void testOrganizationMaxDepthInsert(){
        TestUtilitiesOrganization.bypassUserRules();

        Activity_Domain__c newDomain = TestUtilitiesOrganization.createActivityDomain('NewDomain');
        insert newDomain;
        
        Organization__c org = TestUtilitiesOrganization.createOrganization('org', 'DOM', 'CREA', newDomain);
        insert org; 
        
        Boolean hasErrored = false;


        Organization_Node__c node1 = TestUtilitiesOrganization.createNode(0, 500, org);
        insert node1;
        Organization_Node__c node2 = TestUtilitiesOrganization.createNode(1, 450, org, node1);
        insert node2;
        Organization_Node__c node3 = TestUtilitiesOrganization.createNode(2, 400, org, node2);
        insert node3;
        Organization_Node__c node4 = TestUtilitiesOrganization.createNode(3, 350, org, node3);
        insert node4;
        Organization_Node__c node5 = TestUtilitiesOrganization.createNode(4, 300, org, node4);
        insert node5;
        Organization_Node__c node6 = TestUtilitiesOrganization.createNode(5, 250, org, node5);

        Test.startTest();

        hasErrored = false;
        try {
            insert node6;
        } catch (System.DmlException e) { // We'd like to be more precise..
            System.assert(
                e.getMessage().contains(System.Label.Error_OrganizationMaxDepth), 
                e.getMessage() 
            );
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            hasErrored = true;
        }
        System.assertEquals(true, hasErrored);

        Test.stopTest();
    }
    public static testMethod void testOrganizationMaxDepthUpdate(){
        System.debug('[TestOrganization.testOrganizationMaxDepthUpdate] Initializing.');
        TestUtilitiesOrganization.bypassUserRules();

        Activity_Domain__c newDomain = TestUtilitiesOrganization.createActivityDomain('NewDomain');
        insert newDomain;
        
        Organization__c org = TestUtilitiesOrganization.createOrganization('org', 'DOM', 'CREA', newDomain);
        insert org; 

        Organization_Node__c node1 = TestUtilitiesOrganization.createNode(0, 500, org);
        insert node1;
        Organization_Node__c node2 = TestUtilitiesOrganization.createNode(1, 450, org, node1);
        insert node2;
        Organization_Node__c node3 = TestUtilitiesOrganization.createNode(2, 400, org, node1);
        insert node3;
        Organization_Node__c node4 = TestUtilitiesOrganization.createNode(3, 350, org, node3);
        insert node4;
        Organization_Node__c node5 = TestUtilitiesOrganization.createNode(4, 300, org, node4);
        insert node5;
        Organization_Node__c node6 = TestUtilitiesOrganization.createNode(5, 250, org, node5);
        insert node6;

        Boolean hasErrored = null;
        
        System.debug('[TestOrganization.testOrganizationMaxDepthUpdate] Running.');
        Test.startTest();

        node3.Manager_Organization_Node__c = node2.Id;
        try {
            update node3;
        } catch (System.DmlException e) { // We'd like to be more precise..
            System.assert(
                e.getMessage().contains(System.Label.Error_OrganizationMaxDepth), 
                e.getMessage() 
            );
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION', e.getDmlStatusCode(0) );
            hasErrored = true;
        }
        System.assertEquals(true, hasErrored);


        Test.stopTest();
        System.debug('[TestOrganization.testOrganizationMaxDepthUpdate] Finished.');

    }
}