trigger UpdateCompteDansContrat on Contract (after insert, after update) {
    
    List<Contract> contracts = Trigger.new;
    
    AP_Contract.updateLastDateFIDEOnRelatedAccountInContract(contracts);
    
    AP_Contract.updatetypeRelationInAccount(contracts);
    
}