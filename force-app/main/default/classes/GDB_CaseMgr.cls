public without sharing class GDB_CaseMgr {
    /**
     * getCaseReasons Returns the list of case reasons
     *
     * @retunrs {Map<String, String>}
     *
     **/
    public static Map<String, String> getCaseReasons() {
        return new Map<String,String> {
           'CDG01' => System.Label.GDB_ContactForm_Devis,
           'CDG02' => System.Label.GDB_ContactForm_Question,
           'CDG03' => System.Label.GDB_ContactForm_CommandShip,
           'CDG04' => System.Label.GDB_contactForm_retractation,
           'CDG05' => System.Label.GDB_contactForm_commande_groupee,
           'CDG06' => System.Label.GDB_contactForm_CDG06,
           'CDG07' => System.Label.GDB_contactForm_CDG07,
           'CDG08' => System.Label.GDB_contactForm_CDG08
        };
    }

    /**
     * submitCase Submit a new case based on the given contact form details
     *
     * @param {Map<String, String>} detailsForm
     *
     * @return {Map<String, String>}
     */
    public static Map<String, String> submitCase(Map<String, String> detailsForm) {
        Map<String, String> returnObject = new Map<String, String>();
        returnObject.put('success', 'false');

        if (detailsForm == null) {
            returnObject.put('message', System.Label.GDB_contactForm_cannotSubmitForm);
            return returnObject;
        }

        try {
            // Check required fields
            if (String.isBlank(detailsForm.get('salutation'))
            || String.isBlank(detailsForm.get('firstName'))
            || String.isBlank(detailsForm.get('lastName'))
            || String.isBlank(detailsForm.get('zipCode'))
            || String.isBlank(detailsForm.get('email'))
            || String.isBlank(detailsForm.get('phone'))
            || String.isBlank(detailsForm.get('reason'))
            || '#'.equals(detailsForm.get('reason'))
            || String.isBlank(detailsForm.get('message'))) 
            {
                returnObject.put('message', System.Label.GDB_contactForm_fillRequiredFields);
                return returnObject;
            } 
            else if (!Pattern.matches('^[0-9]{10}$', detailsForm.get('phone').trim())) 
            {
                returnObject.put('message', System.Label.GDB_contactForm_error_phoneFormat);
                return returnObject;
            }

            //Fetching the assignment rules on Case
            //Creating the DMLOptions to use the active assignment rule
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = true;
            
            String city = detailsForm.get('city');
            String zipCode = detailsForm.get('zipCode');

            Case c = new Case(
                Salutation__c = detailsForm.get('salutation'),
                W2C_CaseCategory__c = detailsForm.get('reason'),
                Description = detailsForm.get('message'),
                SuppliedEmail = detailsForm.get('email'),
                Phone__c = detailsForm.get('phone'),
                Firstname__c = detailsForm.get('firstName'),
                Lastname__c = detailsForm.get('lastName'),
                gdb_zipcode__c = zipCode,
                Origin = System.Label.GDB_contactForm_Origin,
                Front_Office__c = GDB_Constants.accountMandataireId,
                Mandataire__c = GDB_Constants.accountMandataireId
            );
            
            
            if(String.isNotBlank(city) && String.isNotBlank(zipCode))
            {
                c.Address__c = zipCode + ' - ' + city;
            }

           	if(!GDB_AccountMgr.isAuthenticated()) {
                c.Address__c = detailsForm.get('zipCode');
            }

            Map<String, String> reasonsValue = GDB_CaseMgr.getCaseReasons();

            // Add a Subject precision
            c.Subject = System.Label.GDB_CommandTypeButagaz + reasonsValue.get(c.W2C_CaseCategory__c) + System.Label.GDB_Contact_Origin + c.Origin;

            // Bind the account details
            Account a = GDB_AccountMgr.getCurrentCustomer();
            
            if (a != null) {
                c.AccountId = a.Id;
                c.Activity_Domain__c = a.Activity_Domain__c;
            } else {
                String email = detailsForm.get('email');
                
                Id externalContactRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name = 'External Contact' AND IsPersonType=True LIMIT 1][0].Id;
                
                Account[] externalAccounts = [SELECT Id FROM Account WHERE Email__c =:email AND RecordTypeId = :externalContactRecordTypeId ORDER BY CreatedDate DESC LIMIT 1];
                
                Account externalAccount = null;
                
                if(externalAccounts == null || externalAccounts.isEmpty())
                {
                    externalAccount = new Account
                    (
                    	Email__c = email,
                        PersonEmail = email,
                        Phone = detailsForm.get('phone'),
                        LastName = detailsForm.get('lastName'),
                        FirstName = detailsForm.get('firstName'),
                        Postal_Code__c = detailsForm.get('zipCode'),
                        RecordTypeId = externalContactRecordTypeId
                    );
                    
                    insert externalAccount;
                }
                else
                {
                    externalAccount = externalAccounts[0];
                }
                
                c.AccountId = externalAccount.Id;
                
                c.Activity_Domain__c = GDB_Constants.activityDomainId;
            }

            // Check the order
            Order__c o = GDB_OrderMgr.getOrderByOrderNo(detailsForm.get('orderNo'));
            if (o != null) {
                c.Order__c = o.Id;
            }
            
            c.setOptions(dmlOpts);
            
            insert c;

            returnObject.put('message', System.Label.GDB_contactForm_success);
            returnObject.put('success', 'true');
        } 
        catch(Exception e) {
            returnObject.put('message', System.Label.GDB_contactForm_cannotSubmitForm);
            return returnObject;
        }

        return returnObject;
    }

    /**
     * getCaseReasonsQuoteForm Returns the list of case reasons for quote form
     *
     * @retunrs {Map<String, String>}
     *
     **/
        public static Map<String, String> getCaseReasonsQuoteForm() {
        return new Map<String,String> {
           'CDG06' => System.Label.GDB_QuoteForm_Devis
        };
    }
}