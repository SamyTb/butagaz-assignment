public class AP_ApprovalHierarchy_01 {
    public abstract class ApprovalHiearchyException extends Exception {} 
    public class RepNotInHiearchyException extends ApprovalHiearchyException {}  // Raised when the rep is not in the H.
    public class HierarchyTooDeepException extends ApprovalHiearchyException {}  // Raised when the H. depth > 5 (?) 
    public class NoApproverFoundException  extends ApprovalHiearchyException {}  // Raised when the toplevel is not sufficient
    public class OrganizationNotFoundException extends ApprovalHiearchyException {}  // Raised when we didn't find the H.

    public static void buildApproverChain(List<Quote> lQuotes){

        // This map allows us to find the Nodes from the User for each Hierarchy (they're unique)
        Map<Id, Map<Id, Organization_Node__c>> mOrgToUserToNode = new Map<Id, Map<Id, Organization_Node__c>>();
        // This map allows us to find a Node from its ID
        Map<Id, Organization_Node__c> mNodes = new Map<Id, Organization_Node__c>();


        // Get the Organization IDs that we're interested in.
        for (Quote oQuote : lQuotes){
            if (!(mOrgToUserToNode.containsKey(oQuote.T_Organization__c))){
                mOrgToUserToNode.put(oQuote.T_Organization__c, new Map<Id, Organization_Node__c>());
            }
        }

        System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] Organization IDs: ' + mOrgToUserToNode.keySet());

        // Retrieve the Nodes and the Hiearchy.
        for (Organization_Node__c oNode : [SELECT Id, Approval_Level__c, Latitude_Level__c, Manager_Organization_Node__c, Organization__c, User__c FROM Organization_Node__c WHERE Organization__c IN :mOrgToUserToNode.keySet()]){
            mNodes.put(oNode.Id, oNode);
            mOrgToUserToNode.get(oNode.Organization__c).put(oNode.User__c, oNode);
        }
        System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] Organizations: ' + mOrgToUserToNode);

        // Loop variables
        List<Id> lApprovers = null; // The quote's approvers
        Boolean done = null; // Whether we still need to search
        Map<Id, Organization_Node__c> mOrganization = null; // The appropriate organization for this quote
        Organization_Node__c currentNode  = null; // The node we're currently working on.
        Organization_Node__c startingNode = null; // The first node in the hierarchy.

        // Treat the Quotes
        for (Quote oQuote : lQuotes){
            // Initialize variables
            System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] Processing Quote with ID [' + oQuote.Id  + ']');
            lApprovers = new List<Id>();
            done = false;

            // Select the matching organization
            mOrganization = mOrgToUserToNode.get(oQuote.T_Organization__c);
            System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] Organization is: ' + mOrganization);
            if (mOrganization == null){ 
                System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] No Organization found.');//TODO: Loglevel.
                throw new OrganizationNotFoundException(); 
            }

            if (mOrganization.containsKey(oQuote.Opportunity.OwnerId)){
                // Is the user in the Organization?
                currentNode = mOrganization.get(oQuote.Opportunity.OwnerId);
                startingNode = currentNode;
                while (!done){
                    if (currentNode != startingNode) { // We don't want to add the rep himself!
                        lApprovers.add(currentNode.User__c);
                        System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] Adding User [' + currentNode.User__c + '] to approver chain');
                    }
                    if (
                           (currentNode.Approval_Level__c <= oQuote.Latitude_Level__c) 
                        && (currentNode.Latitude_Level__c >= oQuote.Latitude__c) // TODO: serious renaming needed here!
                    ){
                        System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] Approver chain done.');
                        done = true;
                    } else {
                        currentNode = mNodes.get(currentNode.Manager_Organization_Node__c);
                        if (currentNode == null){
                            System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] No approver found.');
                            throw new NoApproverFoundException();
                        }
                        System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] Next node is [' + currentNode.Id + ']');
                    }
                }
            } else {
                    System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] User not found in hierarchy: [' + oQuote.Opportunity.OwnerId + ']');
                throw new RepNotInHiearchyException();
            }

            System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] Validating Hierarchy depth.');
            if (lApprovers.size() > 5){ // TODO: move this to a C.S. TODO: Remove magic number
                System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] Hierarchy too deep.');
                throw new HierarchyTooDeepException();
            }


            try {
                // We're gonna do work, so we should clean the approver chain first!
                oQuote.approver0__c = null; oQuote.approver1__c = null; oQuote.approver2__c = null;
                oQuote.approver3__c = null; oQuote.approver4__c = null;

                oQuote.Approver0__c = lApprovers.get(0);
                System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] Added approver 0');
                oQuote.Approver1__c = lApprovers.get(1);
                System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] Added approver 1');
                oQuote.Approver2__c = lApprovers.get(2);
                System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] Added approver 2');
                oQuote.Approver3__c = lApprovers.get(3);
                System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] Added approver 3');
                oQuote.Approver4__c = lApprovers.get(4);
                System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] Added approver 4');
            } catch (System.ListException e){
                System.debug('[AP_ApprovalHierarchy_01.buildApproverChain] Reached end of chain');
                // We don't do anything, we just reached the end of the list : ).
            }
        }
    }
}