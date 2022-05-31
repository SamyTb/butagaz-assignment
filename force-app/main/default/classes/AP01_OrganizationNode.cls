public class AP01_OrganizationNode {
    //TODO: triggers for _delete_ 

    /* This triggers enforces that there is a single user that has no manager 
    Node in an Organization. 
    We will need to be able to bypass this validation rule, especially if we
    need to add an user at the top of the organization. */ 
    
    public static List<Organization_Node__c> mergeDBAndUpdatedNodes (
            List<Organization_Node__c> lDBNodes,
            List<Organization_Node__c> lUpdatedNodes
    ) {
            /* We pass this function a list of Nodes from the DB and a list of Updated Nodes,
               We get back a list of Nodes containing:
                + All nodes from the DB, with their updated version case they are being updated
                + The updated / new nodes
            */
            List<Organization_Node__c> outNodes = new List<Organization_Node__c>();
            map<Id, Organization_Node__c> updatedNodesMap = new map<Id, Organization_Node__c>();
            
            // First pass, we add the DB Nodes to the Map.
            for (Organization_Node__c oDBNode: lDBNodes) {
                   updatedNodesMap.put(oDBNode.Id, oDBNode);
            }

            // Second pass, we add the null IDS (new Nodes) to the list,
            // and the non-null IDS to the map. (! They will already be there if we did our job correctly).
            for (Organization_Node__c oUpdatedNode: lUpdatedNodes){
                if (oUpdatedNode.Id == null){
                    outNodes.add(oUpdatedNode);
                } else {
                    updatedNodesMap.put(oUpdatedNode.Id, oUpdatedNode);
                }
            }

            // Third pass, we add all the updated nodes to the new ones
            outNodes.addAll(updatedNodesMap.values());
             
            return outNodes;
    }
    
    public static void enforceSingleTopNode(List<Organization_Node__c> lOrganizationNodes) {
        //TODO What happens when we're currentyle updating the Top Node
        System.Debug('START method AP01_OrganizationNode.enforceSingleTopNode');
        
        System.debug('[AP01_OrganizationNode.enforceSingleTopNode] Fetching Organization Data');
        List<AggregateResult> lOrganizationHeadlessNodesCounts = [
            SELECT
                Organization__r.Id,
                COUNT(Id) nHeadless 
            FROM
                Organization_Node__c
            WHERE 
                Manager_Organization_Node__c = null
            AND 
                Id NOT IN :lOrganizationNodes //Not any of those being updated!
            GROUP BY
                Organization__r.Id
        ];
        
        System.debug('[AP01_OrganizationNode.enforceSingleTopNode] Reformating Organization Data');
        Map<String, Integer> mOrganizationHeadlessNodesCounts = new Map<String, Integer>(); 
        for (AggregateResult oOrganizationHeadlessNodesCount: lOrganizationHeadlessNodesCounts) {
            mOrganizationHeadlessNodesCounts.put(
                String.ValueOf(oOrganizationHeadlessNodesCount.get('Id')),
                Integer.valueOf(oOrganizationHeadlessNodesCount.get('nHeadless'))
            );
        }
        
        for (Organization_Node__c oOrganizationNode : lOrganizationNodes){
            System.debug('[AP01_OrganizationNode.enforceSingleTopNode] Processing Node: [' + String.valueOf(oOrganizationNode) + ']');
            Id orgId = oOrganizationNode.Organization__c;
            System.debug('[AP01_OrganizationNode.enforceSingleTopNode] OrgId: [' + String.valueOf(orgId) + ']');

            Integer otherHeadlessNodesCount = mOrganizationHeadlessNodesCounts.get(orgId);
            System.debug('[AP01_OrganizationNode.enforceSingleTopNode] nHeadlessNodes for this organization: [' + String.valueOf(otherHeadlessNodesCount) + ']');
            
            if (oOrganizationNode.Manager_Organization_Node__c == null) {
                if (otherHeadlessNodesCount == null) {
                    System.debug('[AP01_OrganizationNode.enforceSingleTopNode] No other headless node found [OK]');
                    mOrganizationHeadlessNodesCounts.put(orgId, 1); //We now have one!
                } else {
                    System.debug('[AP01_OrganizationNode.enforceSingleTopNode] Duplicate Headless Node [ERROR]');
                    oOrganizationNode.addError(System.Label.Error_MultipleHeadlessNodes);
                    mOrganizationHeadlessNodesCounts.put(orgId, otherHeadlessNodesCount + 1); //Not that useful, but let's do it so it's clear.
                }
                
            } else {
                System.debug('[AP01_OrganizationNode.enforceSingleTopNode] Node is not headless [OK]');
            }
        }
        System.Debug('END method AP01_OrganizationNode.enforceSingleTopNode');
    }
    
    
    public static void validateUniqueUser(List<Organization_Node__c> lUpdatedOrNewNodes){ // Updated or New...
        /* Validate that an user is only at one spot in an Hierarchy */
        System.Debug('START method AP01_OrganizationNode.validateUniqueUser');
        
        List<Id> lUserIds = new List<Id>();
        
        Map<Id, Organization_Node__c> mUpdatedNodes = new Map<Id, Organization_Node__c>(); // We can't rely on newMap, we might be before insert.
        
        System.debug('[AP01_OrganizationNode.validateUniqueUser] Remapping Updated Or New Nodes');
        for (Organization_Node__c oUpdatedOrNewNode : lUpdatedOrNewNodes) {
            lUserIds.add(oUpdatedOrNewNode.User__c);
        }
        
        // Let's get the relevant Nodes from the DB
        System.debug('[AP01_OrganizationNode.validateUniqueUser] Collecting relevant Nodes from the DB');
        List<Organization_Node__c> lStoredNodes = [
            SELECT Id, Organization__c, User__c // This is the ID of the user. 
            FROM Organization_Node__c
            WHERE User__c IN :lUserIds
        ];
        
        List<Organization_Node__c> lRelevantNodes = AP01_OrganizationNode.mergeDBAndUpdatedNodes(lStoredNodes, lUpdatedOrNewNodes);
        
        // Let's map the Users to the Nodes they're on.  (UserID -> NodesTheUserIsOn)
        System.debug('[AP01_OrganizationNode.validateUniqueUser] Mapping Users to the Nodes they are on');
        Map<Id, Set<Organization_Node__c>> mUserToNodes = new Map<Id, Set<Organization_Node__c>>(); // UserID -> NodesTheUserIsOn

        // Loop variables. 
        Set<Organization_Node__c> tempOrganizationNodes = null;
        Organization_Node__c oStoredNode = null;
        
        for (Organization_Node__c oRelevantNode : lRelevantNodes) {
            
            // Now, fill the map UserID -> NodesTheUserIsOn.
            if (mUserToNodes.containsKey(oRelevantNode.User__c)){
                mUserToNodes.get(oRelevantNode.User__c).add(oRelevantNode);
            } else {
                tempOrganizationNodes = new Set<Organization_Node__c>();
                tempOrganizationNodes.add(oRelevantNode);
                mUserToNodes.put(oRelevantNode.User__c, tempOrganizationNodes);
            }
        }
        
        tempOrganizationNodes = null; 
        Boolean canInsert = null; 
        
        System.debug('[AP01_OrganizationNode.validateUniqueUser] Validating New or Updated Nodes');
        for (Organization_Node__c oUpdatedOrNewNode : lUpdatedOrNewNodes){
            System.debug('[AP01_OrganizationNode.validateUniqueUser] Validating Node for User [' + String.valueOf(oUpdatedOrNewNode.User__c) +  ']');
            if (mUserToNodes.containsKey(oUpdatedOrNewNode.User__c)) { // The user exists on a Node!
                System.debug('[AP01_OrganizationNode.validateUniqueUser] User found on other Nodes');
                canInsert = true; // Maybe we can still insert/update (other org, same node)
                for (Organization_Node__c oOtherNodeForUser : mUserToNodes.get(oUpdatedOrNewNode.User__c)) {// All nodes the user is on
                    if (oOtherNodeForUser.Organization__c == oUpdatedOrNewNode.Organization__c) {// Yes => But is it the same Node?
                        if (oOtherNodeForUser.Id != oUpdatedOrNewNode.Id){// No => It's a duplicate, we can't insert!
                            // TODO Is this gonna crash if it's an insert?
                            System.debug('[AP01_OrganizationNode.validateUniqueUser] Duplicate User in Organization');
                            canInsert = false;
                        }
                    }
                }
                if (canInsert){
                    // No problem, go ahead inserting.
                } else {
                    oUpdatedOrNewNode.addError('This user is already in this Organization.'); //Don't let insert.
                }
            } else {
                // The key is not there, so we have no other node with this ID, it's OK, no error.
            }
            // Last, add the Node to the node being updated 
            // We might be bulk inserting, and we don't want the user to be inserted on two Nodes at the same time!
            System.debug('[AP01_OrganizationNode.validateUniqueUser] Adding Node to the Map for User');
            if (mUserToNodes.containsKey(oUpdatedOrNewNode.User__c)) {
                mUserToNodes.get(oUpdatedOrNewNode.User__c).add(oUpdatedOrNewNode);
            } else {
                tempOrganizationNodes = new Set<Organization_Node__c>();
                tempOrganizationNodes.add(oUpdatedOrNewNode);
                mUserToNodes.put(oUpdatedOrNewNode.User__c, tempOrganizationNodes);
            }
        }
        
        System.Debug('END method AP01_OrganizationNode.validateUniqueUser');
    }
    
   public static void validateChildren(List<Organization_Node__c> lUpdatedOrNewNodes) {
        /* Attempt to update Children Nodes to run validation rules */
        System.Debug('START method AP01_OrganizationNode.validateChildren');

        // These are ID's wer're interested in because they are managing Nodes we are updating.
        Set<Id> sManagerNodeIds = new Set<Id>(); 
        Set<Id> sBlockableIds = new Set<Id>();  // These are the IDs (+null) which *may* be addErrored.
        for (Organization_Node__c oNode : lUpdatedOrNewNodes){
            if (oNode.Manager_Organization_Node__c <> null){ sManagerNodeIds.add(oNode.Manager_Organization_Node__c); }
            sBlockableIds.add(oNode.Id); // May be null, but that's OK 'cause DB Nodes can't have a null ID.
        }
        
        List<Organization_Node__c> lDBOrganizationNodes = [
            SELECT 
                Approval_Level__c, Latitude_Level__c, Organization__c,
                Manager_Organization_Node__c
            FROM Organization_Node__c 
            WHERE (Manager_Organization_Node__c IN :lUpdatedOrNewNodes) OR (Id IN :sManagerNodeIds) 
        ]; //Is the WHERE clause THAT useful?
        
        // Let's merge them with the updated ones.
        List<Organization_Node__c> lRelevantNodes = AP01_OrganizationNode.mergeDBAndUpdatedNodes(lDBOrganizationNodes, lUpdatedOrNewNodes);

        // This handy map will allow us to get a Node from its ID.
        Map<Id, Organization_Node__c> mManagerNodes = new Map<Id, Organization_Node__c>();
        for (Organization_Node__c oNode: lRelevantNodes){
            if (oNode.Id <> null){ mManagerNodes.put(oNode.Id, oNode); }
        }

        System.debug('[AP01_OrganizationNode.validateChildren] Validating Nodes');
        Organization_Node__c oParentNode = null; // Loop variable
        
        for (Organization_Node__c oChildNode : lRelevantNodes){
            System.debug( '[AP01_OrganizationNode.validateChildren] Validating [' + oChildNode + ']');
            
            if(oChildNode.Manager_Organization_Node__c <> null) {
                
                oParentNode = mManagerNodes.get(oChildNode.Manager_Organization_Node__c);
                if (oParentNode <> null){
                    System.debug('[AP01_OrganizationNode.validateChildren] Parent exists => proceeding');

                    System.debug('[AP01_OrganizationNode.validateChildren] Validating Approval Level');
                    //We'll have to document somewhere that the same messages appear in TWO different places.
                    //(Here and in the validation rule)
                    System.debug('[AP01_OrganizationNode.validateChildren] Validating Latitude Level');
                    
                    if (oParentNode.Latitude_Level__c <= oChildNode.Latitude_Level__c  ) {
                        if (sBlockableIds.contains(oChildNode.Id)){
                            oChildNode.addError(System.Label.Error_InvalidLatitudeLevel);
                        }
                        if (sBlockableIds.contains(oParentNode.Id)){
                            oParentNode.addError(System.Label.Error_InvalidLatitudeLevel); 
                        }
                    }
                    
                    System.debug('[AP01_OrganizationNode.validateChildren] Validating Approval Level');
                    if (oParentNode.Approval_Level__c >= oChildNode.Approval_Level__c) {
                        if (sBlockableIds.contains(oChildNode.Id)){
                            oChildNode.addError(System.Label.Error_InvalidApprovalLevel); 
                        }
                        if (sBlockableIds.contains(oParentNode.Id)){
                            oParentNode.addError(System.Label.Error_InvalidApprovalLevel); 
                        }
                    }
                    
                    System.debug('[AP01_OrganizationNode.validateChildren] Validating Organization');
                    if (oParentNode.Organization__c <> oChildNode.Organization__c) {
                        if (sBlockableIds.contains(oChildNode.Id)){
                            oChildNode.addError(System.Label.Error_InvalidOrganization); 
                        }
                        if (sBlockableIds.contains(oParentNode.Id)){
                            oParentNode.addError(System.Label.Error_InvalidOrganization); 
                        }
                    }
                } else {
                    // We didn't find the Node in our list of Manager Nodes
                    // This just means this Node is actually a parent Node of the ones we're validating
                    // We're not interesting in validating this one, we'll just leave it be.
                }
            }
        }
        System.debug('END method AP01_OrganizationNode.validateChildren');
    }


    public static void enforceOrganizationMaxDepth(List<Organization_Node__c> lUpdatedOrNewNodes) {
        /* This trigger ensures that a hierarchy is not deeper than the MaxDepth*/
        // It is critical that this trigger runs AFTER ensuring that the Children and the Parents have the same
        // organizaiton! It relies on this assumption.

        // TODO: MaxDepth should come from some sort of setting, not from a constant defined here.
        Integer MAX_DEPTH = 5;
        System.debug('START method AP01_OrganizationNode.enforceOrganizationMaxDepth');

        // Let's get the Nodes on the same organization from the DB 
        Set<Id> sOrgIds = new Set<Id>();
        for (Organization_Node__c oNode : lUpdatedOrNewNodes){
                sOrgIds.add(oNode.Organization__c);
        }

        List<Organization_Node__c> lDBOrganizationNodes = [SELECT Id, Organization__c, Manager_Organization_Node__c FROM Organization_Node__c WHERE Organization__c IN :sOrgIds];
        // Let's merge them with the updated ones.
        List<Organization_Node__c> lRelevantNodes = AP01_OrganizationNode.mergeDBAndUpdatedNodes(lDBOrganizationNodes, lUpdatedOrNewNodes);

        // We need a map Org => Nodes so that we can lock all the updates to an Org when needed:
        // we have no way to know at which level the update that made it too deep happened, so we add an error to
        // all the Nodes
        Map<Id, Set<Organization_Node__c>> OrgIdToNodes = new Map<Id, Set<Organization_Node__c>>();
        // Loop var
        Set<Organization_Node__c> tmpSONodes = null;
        for (Organization_Node__c oNode : lUpdatedOrNewNodes){
            tmpSONodes = OrgIdToNodes.get(oNode.Organization__c);
            if (tmpSONodes == null){ 
                tmpSONodes= new Set<Organization_Node__c>();
                OrgIdToNodes.put(oNode.Organization__c, tmpSONodes);
            }
            tmpSONodes.add(oNode);
        }

        // We want to start at the leaf Nodes, let's just realize that a Leaf node is a Node that manages None.
        Map<Id, Organization_Node__c> mIdToNode = new Map<Id, Organization_Node__c>();
        Set<Id> sManagerNodeIds = new Set<Id>();
        List<Organization_Node__c> lLeafNodes = new List<Organization_Node__c>();

        for (Organization_Node__c oNode : lRelevantNodes){
            if ((oNode.Id <> null)){ mIdToNode.put(oNode.Id, oNode); }
            if ((oNode.Manager_Organization_Node__c <> null)){ 
                sManagerNodeIds.add(oNode.Manager_Organization_Node__c); 
            }
        }

        for (Organization_Node__c oNode : lRelevantNodes){
            // Newly inserted Node Or Managing one.
            if ((oNode.Id == null) || !(sManagerNodeIds.contains(oNode.Id))){ lLeafNodes.add(oNode); }
        }

        // Loop variables
        Integer currDepth = null;
        Organization_Node__c currentNode = null;

        System.debug('[AP01_OrganizationNode.enforceOrganizationMaxDepth] Leaf Nodes ' + lLeafNodes);
        for (Organization_Node__c oNode : lLeafNodes){
            System.debug('[AP01_OrganizationNode.enforceOrganizationMaxDepth] Processing Leaf Node ' + oNode.Id);
            currentNode = oNode;
            currDepth = 0;

            do {
                System.debug('[AP01_OrganizationNode.enforceOrganizationMaxDepth] Node: ' + currentNode.Id);
                currDepth++;
                if (currDepth > MAX_DEPTH){
                    System.debug('I BREAK THE LIMIT');
                    for (Organization_Node__c errNode : OrgIdToNodes.get(currentNode.Organization__c)){
                        errNode.addError(System.Label.Error_OrganizationMaxDepth);
                    }
                    break;
                }
                currentNode = mIdToNode.get(currentNode.Manager_Organization_Node__c);
                if (currentNode == null){
                    System.debug('[AP01_OrganizationNode.enforceOrganizationMaxDepth] Done!');
                }
            } while( currentNode <> null );
        }
        System.debug('END method AP01_OrganizationNode.enforceOrganizationMaxDepth');
    }
}