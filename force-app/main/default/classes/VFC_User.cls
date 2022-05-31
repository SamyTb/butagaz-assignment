public class VFC_User {

    // Method to remove license from users who go inactive
    public static void revokePackageLicenseFromUser(List<User> userList) {
        
        if(userList != null && userList.size() > 0){
            
            // Retrieve list of package licenses to revoke when a user goes inactive
            List<String> packageLicensesToRevokeList = AP_PricingUtilities.getCustomSettingValue('PackageLicensesToRevokeOnInactiveUsers').split(';');
            

            // Retrieve the PackageLicense list
            List<PackageLicense> pckgLicenseList = [SELECT Id, NamespacePrefix FROM PackageLicense WHERE NamespacePrefix IN :packageLicensesToRevokeList];

            System.debug(logginglevel.WARN, 'pckgLicenseList = ' + pckgLicenseList);

            if(pckgLicenseList != null && pckgLicenseList.size() > 0){
                // Retrieve the list of licenses for the list of users
                List<UserPackageLicense> userPckgLicenseList = new List<UserPackageLicense>([SELECT Id, PackageLicenseId, UserId 
                                                                                                FROM UserPackageLicense 
                                                                                                WHERE PackageLicenseId IN :pckgLicenseList 
                                                                                                AND UserId IN :userList]);

                List<UserPackageLicense> userPckgLicenseToRevokeList = new List<UserPackageLicense>();
                for(UserPackageLicense upl : userPckgLicenseList){
                    userPckgLicenseToRevokeList.add(upl);
                }
                System.debug(logginglevel.WARN, 'userPckgLicenseToRevokeList = ' + userPckgLicenseToRevokeList);

                if(!userPckgLicenseToRevokeList.isEmpty()){
                    try{
                        // Revoke package licenses from the users
                        delete userPckgLicenseToRevokeList;
                    }
                    catch(Exception e){
                        System.debug(logginglevel.WARN, 'Delete Exception = ' + e.getStackTraceString() + ' | Exception message = ' + e.getMessage());
                    }
                }
            }
        }

    }

    // Method returning true if user is allowed to run Signea process, otherwise false
    public static boolean isUserAuthorizedToRunSignea(Id userId) {

        boolean bIsAllowedPckgLicense = false;
        boolean bIsAllowedPermSet = false;
        integer nbPermSet;
        boolean isSandBox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if(isSandBox) return true;
        
        if(userId != null){
            // Checking if user has the Package License assigned
            // Retrieve the PackageLicense Id
            PackageLicense pckgLicense = [SELECT Id FROM PackageLicense WHERE NamespacePrefix = 'Signea' LIMIT 1];

            if(pckgLicense != null){
                // Retrieve Signea package license for the user
                List<UserPackageLicense> userPckgLicenseList = new List<UserPackageLicense>([SELECT Id, PackageLicenseId, UserId 
                                                                                                FROM UserPackageLicense 
                                                                                                WHERE PackageLicenseId = :pckgLicense.Id 
                                                                                                AND UserId = :userId]);

                bIsAllowedPckgLicense = userPckgLicenseList.isEmpty() ? false : true;

            }

            // Checking if user has one of the Permission Set assigned
            AggregateResult[] groupedResults = [SELECT count(Id) cptPermSet
                                                FROM PermissionSetAssignment 
                                                WHERE AssigneeId = :userId 
                                                AND PermissionSet.Name IN ('Signea_Admin_User', 'Signea_Advanced_User', 'Signea_User_Only')];

            for (AggregateResult ar : groupedResults) {
                nbPermSet = (Integer)ar.get('cptPermSet');
            }
            
            if(nbPermSet > 0){
                bIsAllowedPermSet = true;
            }
        }

        return bIsAllowedPckgLicense && bIsAllowedPermSet;

    }

}