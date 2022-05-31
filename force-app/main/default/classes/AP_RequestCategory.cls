public class AP_RequestCategory
{
    private static void updateCalculatedFields(List<Request_Category__c> requestCategories)
    {
        System.Debug('Start method AP_RequestCategory.updateCalculatedFields');
        
        // Get parent categories
        List<String> parentCategoryIds = new List<String>();
        
        for (Request_Category__c rc : requestCategories) {
            if (rc.Parent_Category__c != null) {
                parentCategoryIds.add(rc.Parent_Category__c);
            }
        }
        
        Map<Id, Request_Category__c> parentCategories = new Map<Id, Request_Category__c>([select Name__c, Name_Path__c, Code_Path__c, SLA__c from Request_Category__c where Id in :parentCategoryIds]);

        // Process triggered objects
        for (Request_Category__c rc : requestCategories) {
            rc.Name_Path__c = '';
            rc.Code_Path__c = '';
            rc.Name = '';
            
            if (rc.Parent_Category__c != null) {
                Request_Category__c parentCategory = parentCategories.get(rc.Parent_Category__c);
                
                rc.Name_Path__c = parentCategory.Name_Path__c + ' - ';
                rc.Code_Path__c = parentCategory.Code_Path__c + ':';
                rc.Report_Category_Name__c = parentCategory.Name__c;
                rc.Report_Subcategory_Name__c = rc.Name__c;
                
                if (rc.SLA__c == null) {
                    rc.SLA__c = parentCategory.SLA__c;
                }
            } else {
                rc.Report_Category_Name__c = rc.Name__c;
                rc.Report_Subcategory_Name__c = null;
            }
            
            rc.Name_Path__c += rc.Name__c;
            rc.Code_Path__c += rc.Code__c;
            String name = rc.Code_Path__c + ' | ' + rc.Name_Path__c;
            rc.Name += name.substring(0, Math.min(name.length(), 80));
        }
        
        System.Debug('End method AP_RequestCategory.updateCalculatedFields');
    }
    
    public static void beforeInsert(List<Request_Category__c> requestCategories)
    {
        System.Debug('Start method AP_RequestCategory.beforeInsert');
        
        AP_RequestCategory.updateCalculatedFields(requestCategories);
        
        System.Debug('End method AP_RequestCategory.beforeInsert');
    }
    
    public static void beforeUpdate(List<Request_Category__c> requestCategories)
    {
        System.Debug('Start method AP_RequestCategory.beforeUpdate');
        
        AP_RequestCategory.updateCalculatedFields(requestCategories);
        
        System.Debug('End method AP_RequestCategory.beforeUpdate');
    }
    
    public static void afterUpdate(List<Request_Category__c> requestCategories)
    {
        System.Debug('Start method AP_RequestCategory.afterUpdate');
        
        List<Request_Category__c> children = new List<Request_Category__c>();
        
        for (Request_Category__c child : [select Name from Request_Category__c where Parent_Category__c in :requestCategories]) {
            child.Name = 'to update';
            children.add(child);
        }
        
        update children;
        
        System.Debug('End method AP_RequestCategory.afterUpdate');
    }
}