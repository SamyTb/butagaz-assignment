trigger OrganizationNodeBeforeUpdate on Organization_Node__c (before update) {
    if (Trigger.IsBefore && Trigger.IsUpdate) {
        System.Debug('##>>> OrganizationNode.BeforeUpdate : BEGIN <<< run by ' + UserInfo.getName());
        List<Organization_Node__c> lOrganizationNodes = Trigger.new;
        
        if (PAD.canTrigger('OrganizationNode.enforceSingleTopNode')) {
            AP01_OrganizationNode.enforceSingleTopNode(lOrganizationNodes);
        } else {
            System.Debug('##>>> OrganizationNode.BeforeUpdate : BYPASS enforceSingleTopNode <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('OrganizationNode.validateUniqueUser')) {
            AP01_OrganizationNode.validateUniqueUser(lOrganizationNodes);
        } else {
            System.Debug('##>>> OrganizationNode.BeforeUpdate : BYPASS validateUniqueUser <<< run by ' + UserInfo.getName());
        }

        if (PAD.canTrigger('OrganizationNode.validateChildren')) {
            AP01_OrganizationNode.validateChildren(lOrganizationNodes);
        } else {
            System.Debug('##>>> OrganizationNode.BeforeUpdate : BYPASS validateChildren <<< run by ' + UserInfo.getName());
        }

        if (PAD.canTrigger('OrganizationNode.forceOrganizatMaxDepth')) {
            AP01_OrganizationNode.enforceOrganizationMaxDepth(lOrganizationNodes);
        } else {
            System.Debug('##>>> OrganizationNode.BeforeInsert : BYPASS enforceOrganizationMaxDepth <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> OrganizationNode.BeforeUpdate : END <<<');
    } else {
        System.Debug('##>>> OrganizationNode.BeforeUpdate : FALSE TRIGGER <<<');
    }
}