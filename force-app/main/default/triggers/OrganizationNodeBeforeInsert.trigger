trigger OrganizationNodeBeforeInsert on Organization_Node__c (before insert) {
    if (Trigger.IsBefore && Trigger.IsInsert) {
        System.Debug('##>>> OrganizationNode.BeforeInsert : BEGIN <<< run by ' + UserInfo.getName());
        List<Organization_Node__c> lOrganizationNodes = Trigger.new;
        
        if (PAD.canTrigger('OrganizationNode.enforceSingleTopNode')) {
            AP01_OrganizationNode.enforceSingleTopNode(lOrganizationNodes);
        } else {
            System.Debug('##>>> OrganizationNode.BeforeInsert : BYPASS enforceSingleTopNode <<< run by ' + UserInfo.getName());
        }
        
        if (PAD.canTrigger('OrganizationNode.validateUniqueUser')) {
            AP01_OrganizationNode.validateUniqueUser(lOrganizationNodes);
        } else {
            System.Debug('##>>> OrganizationNode.BeforeInsert : BYPASS validateUniqueUser <<< run by ' + UserInfo.getName());
        }

        if (PAD.canTrigger('OrganizationNode.validateChildren')) {
            AP01_OrganizationNode.validateChildren(lOrganizationNodes);
        } else {
            System.Debug('##>>> OrganizationNode.BeforeInsert : BYPASS validateChildren <<< run by ' + UserInfo.getName());
        }

        if (PAD.canTrigger('OrganizationNode.forceOrganizatMaxDepth')) {
            AP01_OrganizationNode.enforceOrganizationMaxDepth(lOrganizationNodes);
        } else {
            System.Debug('##>>> OrganizationNode.BeforeInsert : BYPASS enforceOrganizationMaxDepth <<< run by ' + UserInfo.getName());
        }
        
        System.Debug('##>>> OrganizationNode.BeforeInsert : END <<<');
    } else {
        System.Debug('##>>> OrganizationNode.BeforeInsert : FALSE TRIGGER <<<');
    }
}