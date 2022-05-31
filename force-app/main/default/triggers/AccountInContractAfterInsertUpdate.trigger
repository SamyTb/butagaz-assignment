trigger AccountInContractAfterInsertUpdate on Account_in_Contract__c (after insert, after update) {
	
	List<Account_in_Contract__c> accountInContracts = Trigger.new;
	
	AP_Account_in_Contract.updateBailleurOnOwnerAccount(accountInContracts);
}