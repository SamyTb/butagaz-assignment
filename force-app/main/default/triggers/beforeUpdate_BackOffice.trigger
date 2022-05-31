trigger beforeUpdate_BackOffice on CDS__c (before update) 
{

    if (trigger.isUpdate)
    {
        system.debug('beforeUpdate_BackOffice trigger.isUpdate');
        List<CDS__c> lcds = Trigger.new;

        system.debug('lcds:'+lcds);

        Id userId = UserInfo.getUserId();
        List<GroupMember> members = [select GroupId, UserOrGroupId from GroupMember where UserOrGroupId = :userId and GroupId in (select Id from Group WHERE DeveloperName = 'BackOffice')];

        system.debug('members:'+members);

        for(CDS__c cds : Trigger.new)
        {
	        system.debug('cds.Status__c:'+cds.Status__c);

            if(cds.Status__c == 'Validé par BO' && (members.isEmpty() || members == null))
            {
                cds.addError('Vous devez faire partie du groupe Back Office pour pouvoir modifier le statut du CDS en Validé par BO.');
            }

        }
        
    }

}