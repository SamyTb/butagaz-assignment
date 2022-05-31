@isTest
private class GDB_Constants_B2B_TEST {
    @isTest
    static void testConstants() {
        initializeObjects();
        
        System.assertNotEquals(null, GDB_Constants_B2B.checkoutStepURLsB2B, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants_B2B.pagesURLsB2B, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants_B2B.articleTypeId, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants_B2B.activityDomainId, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants_B2B.orderTypeId, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants_B2B.orderSplitTypeId, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants_B2B.guestUserType, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants_B2B.communityName, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants_B2B.domainName, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants_B2B.communityPathPrefix, 'The constant should not be null.');
        System.assertNotEquals(null, GDB_Constants_B2B.orderStatus, 'The constant should not be null.');     
        System.assertNotEquals(null, GDB_Constants_B2B.accountRecordTypeId, 'The constant should not be null.');                        
    }

    @isTest
    static void initializeObjects() {
        Schema.DescribeSObjectResult d = Schema.SObjectType.Activity_Domain__c;
        Map<Id,Schema.RecordTypeInfo> recordTypeMapById = d.getRecordTypeInfosById();
        Id recordId;
        for(Id i : recordTypeMapById.keySet()) {
            recordId = i;
            break;
        }

        GDB_Configurations__c setting = new GDB_Configurations__c();
        setting.mercanetMerchantID__c = 'test';
        setting.mercanetSecretKey__c = 'test';
        setting.mercanetURL__c = 'test';
        setting.mercanetPaymentTimes__c = 1;
        setting.mercanetTimeBetweenPayments__c = 1;
        setting.maximumUseOfPromotionPerUser__c = 1;
        setting.guestType__c = 'Guest';
        setting.activityDomainType__c = recordId;
        setting.articleType__c = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Item__c' AND DeveloperName = 'ECommerce_Article' LIMIT 1 ].Id;
        setting.orderType__c = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Order__c' AND DeveloperName = 'GDB_Ecom' LIMIT 1 ].Id;
        setting.orderSplitType__c = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Order__c' AND DeveloperName = 'GDB_Split_Orders' LIMIT 1 ].Id;
        insert setting;
    }
}