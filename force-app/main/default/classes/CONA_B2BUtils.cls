@SuppressWarnings('PMD')
/**
 * @description Generic utility methods would be present here
 */
public without sharing class CONA_B2BUtils {
    public static final String COMMERCE_USER_PROFILE_NAME = 'B2B Standard Profile';

    /**
     * @description creates AuraHandledException based on a given Exception object
     * @param  exceptionInstance Exception to be converted
     * @return AuraHandledException
     */
    public static AuraHandledException createAuraException(Exception exceptionInstance) {
        return createAuraException(exceptionInstance.getMessage());
    }

    /**
     * @description creates AuraHandledException based on a given error message
     * @param  errorMessage String error message to build exception with
     * @return AuraHandledException
     */
    public static AuraHandledException createAuraException(String errorMessage) {
        AuraHandledException auraEx = new AuraHandledException(errorMessage);
        auraEx.setMessage(errorMessage);
        return auraEx;
    }

    /**
     * @description Queries and returns the bottlerID for user
     * @param accId - ID of account to get the details for
     * @return Current Account Record
     */
    @AuraEnabled
    public static Account getAccountDetails(String accId) {
        String finalAccId = accId;
        Account retAccount ;
        //Check 1: If there is no session storage accountID : Example: AccountSwitcher not loaded yet
        if (isAcountIDNotFound(finalAccId)) {
            finalAccId = [SELECT AccountId FROM USER WHERE ID = :UserInfo.getUserId()][0].AccountId;
        }
        //Check 2: If there is no accountID on user: Example: Bottler Admin
        if (isAcountIDNotFound(finalAccId)) {
            finalAccId = getAccountDetailsHelper();
        }
        //Last check: Return null if there are no contacts also assosciated to that admin
        if (isAcountIDNotFound(finalAccId)) {
            retAccount = null ;
        }
        retAccount =  [
            SELECT
                Id,
                Name,
                AccountNumber,
                Phone,
                BottlerId__c,
                BillingStreet,
                BillingCity,
                BillingState,
                BillingPostalCode,
                BillingCountry,
                ShippingStreet,
                ShippingCity,
                ShippingState,
                ShippingPostalCode,
                ShippingCountry
            FROM Account
            WHERE Id = :finalAccId
        ];
        return retAccount;
    }

    /**
     * @description helper method for getAccountDetails
     * @return String
     */
    public static String getAccountDetailsHelper() {
        String finalAccId = '';
        for (Contact c : [SELECT AccountId FROM Contact WHERE Email = :UserInfo.getUserEmail()]) {
            if (c.AccountId != null) {
                finalAccId = c.AccountId;
            }
        }
        return finalAccId;
    }

    /**
     * @description Check if account ID is not obtained yet
     * @param finalAccId - Parent Account ID
     * @return boolean true if account ID is null or blank
     */
    private static Boolean isAcountIDNotFound(String finalAccId) {
        return finalAccId == null || String.isBlank(finalAccId);
    }

    /**
     * @description Queries and returns the delegated accounts
     * @param userId - ID of user to get the delegated accounts for
     * @return List of queried records
     */
    @AuraEnabled(cacheable=true)
    public static List<DelegatedAccount> getDelegatedAccounts(String userId) {
        String idOfUser = userId == null ? UserInfo.getUserId() : userId;
        List<DelegatedAccount> returnExtAccs = [
            SELECT
                Id,
                Name,
                ManagedBy.Name,
                ManagedById,
                AccessBuyFor,
                TargetId,
                Target.ParentId,
                Target.Name,
                Target.Parent.Name,
                Target.FirstName,
                Target.Parent.FirstName,
                Target.ShippingStreet,
                Target.Parent.ShippingStreet,
                Target.ShippingCity,
                Target.Parent.ShippingCity,
                Target.ShippingState,
                Target.Parent.ShippingState,
                Target.ShippingPostalCode,
                Target.Parent.ShippingPostalCode,
                Target.ShippingCountry,
                Target.Parent.ShippingCountry,
                Target.Phone,
                Target.Parent.Phone,
                Target.AccountNumber,
                Target.Parent.AccountNumber,
                Target.BottlerId__c,
                Target.Parent.BottlerId__c,
                AccessManageUsers,
                ParentId,
                Parent.Name
            FROM DelegatedAccount
            WHERE ParentId IN (SELECT AccountId FROM User WHERE Id = :idOfUser) AND ManagedById = :UserInfo.getUserId()
        ];
        return returnExtAccs;
    }

    /**
     * @description Check if current effective id has enabled access for buying products
     * @param effectiveAccountId - String account id
     * @return Boolean - true if has access, false if not
     */
    @AuraEnabled(cacheable=true)
    public static Boolean hasBuyerAccessForCurrentEffectiveAccount(String effectiveAccountId) {
        if(String.isNotBlank(effectiveAccountId)) {
            String primaryAccountId = getLoggedInUserPrimaryAccount();

            if(effectiveAccountId.equalsIgnoreCase(primaryAccountId)) {
                return true;
            }

            List<DelegatedAccount> delegatedAccounts = [
                    SELECT AccessBuyFor
                    FROM DelegatedAccount
                    WHERE TargetId = :effectiveAccountId
                    AND ManagedById = :UserInfo.getUserId()
                    AND ParentId = :primaryAccountId
            ];

            if(!delegatedAccounts.isEmpty()) {
                DelegatedAccount currentDelegatedAccount = delegatedAccounts.get(0);

                return currentDelegatedAccount.AccessBuyFor;
            }
        }

        return false;
    }

    /**
     * @description Checks and inserts/ updates records accordingly
     * @param fields - String object payload from LWC
     * @return Success/ failure message
     */
    @AuraEnabled
    public static string upsertUserRecord(String fields) {
        Map<String, Id> permissionSetNameIDMap = new Map<String, Id>();
        //List of permissions to check
        Map<String, String> permissionsToCheck = new Map<String, String>();
        for (CONA_B2BUser_Enable_Permissions__mdt permission : [
            SELECT Id, Permissions_Name__c, Display_Name__c, Description__c, MasterLabel
            FROM CONA_B2BUser_Enable_Permissions__mdt
            WHERE CONA_B2BActive__c = TRUE
        ]) {
            permissionsToCheck.put(permission.Permissions_Name__c, permission.Display_Name__c);
        }

        for (PermissionSetGroup pSet : [SELECT ID, DeveloperName FROM PermissionSetGroup WHERE DeveloperName IN :permissionsToCheck.keySet()]) {
            permissionSetNameIDMap.put(pSet.DeveloperName, pSet.Id);
        }

        //Deserialize everything from LWC into wrapper and crete new user object with details
        CONA_B2BSubUtils.UserUpsertWrapper userDetails = (CONA_B2BSubUtils.UserUpsertWrapper) JSON.deserialize(
            fields,
            CONA_B2BSubUtils.UserUpsertWrapper.class
        );
        User newUser = new User(FirstName = userDetails.firstName, LastName = userDetails.lastName, Email = userDetails.email, Phone = userDetails.phoneNumber);

        return userDetails.id == null
            ? insertUserRecordHelper(userDetails, newUser, permissionSetNameIDMap)
            : updateUserRecordHelper(userDetails, newUser, permissionSetNameIDMap);
    }

    /**
     * @description helper method for user insert
     * @param userDetails - wrapper class for user
     * @param newUser - user to be inserted
     * @param permissionSetNameIDMap - map of permisisonsset and ID
     * @return Success/ failure message
     */
    private static String insertUserRecordHelper(CONA_B2BSubUtils.UserUpsertWrapper userDetails, User newUser, Map<String, Id> permissionSetNameIDMap) {
        // In case if the User with the same Email exists in ICEP,  we'll return the error.
        if ([SELECT COUNT() FROM user WHERE Email = :userDetails.email] > 0) {
            return System.Label.CONA_B2BUserInsertValidationErr;
        }

        //1. Add details to Create User and Create site user with details sent
        newUser.ProfileId = [SELECT ID FROM Profile WHERE Name = :COMMERCE_USER_PROFILE_NAME][0].Id; //Put in constants class
        newUser.BottlerId__c = ((Account) ([SELECT BottlerId__c FROM Account WHERE Id = :userDetails.accounts[0].value LIMIT 1])).BottlerId__c;

        String outcomeOfUserDML = createSiteUser(newUser, userDetails.accounts[0].value, true);
        userDetails.accounts.remove(0);

        if (!outcomeOfUserDML.contains('Error')) {
            String outCome = CONA_B2BSubUtils.insertUserLogic(newUser, userDetails, permissionSetNameIDMap);
            return outCome;
        } else {
            return System.Label.CONA_B2BUserInsertionFailed + outcomeOfUserDML;
        }
    }

    /**
     * @description helper method for user updated
     * @param userDetails - wrapper class for user
     * @param newUser - user to be updated
     * @param permissionSetNameIDMap - map of permisisonsset and ID
     * @return Success/ failure message
     */
    private static String updateUserRecordHelper(CONA_B2BSubUtils.UserUpsertWrapper userDetails, User newUser, Map<String, Id> permissionSetNameIDMap) {
        //1. Update the existing user with new name, email fields
        newUser.Id = userDetails.id;
        if (userDetails.accountId != userDetails.accounts[0].value) {
            Database.update(
                new Contact(
                    Id = userDetails.contactId,
                    FirstName = userDetails.firstName,
                    LastName = userDetails.lastName,
                    Phone = userDetails.phoneNumber,
                    Email = userDetails.email,
                    AccountId = userDetails.accounts[0].value
                )
            );
        } else {
            Database.update(
                new Contact(
                    Id = userDetails.contactId,
                    FirstName = userDetails.firstName,
                    LastName = userDetails.lastName,
                    Phone = userDetails.phoneNumber,
                    Email = userDetails.email
                )
            );
        }
        Database.Saveresult outcomeOfUserDML = Database.update(newUser);
        //On success assign accounts and permission sets
        if (outcomeOfUserDML.isSuccess()) {
            userDetails.accounts.remove(0);
            String outCome = CONA_B2BSubUtils.updateUserLogic(newUser, userDetails, permissionSetNameIDMap);
            return outCome;
        } else {
            return System.Label.CONA_B2BUserInsertionFailed + JSON.serialize(outcomeOfUserDML.getErrors());
        }
    }

    /**
     * @description Checks and inserts/ updates permission set assignments accordingly
     * @param delIds - String list with Ids to delete
     * @param psaFields - String list payload to insert permissions
     */
    @future
    public static void dmlPermissionSetAssigments(List<String> delIds, List<String> psaFields) {
        //This will take care of duplicate deletes or inserts and does not throw exceptionas per use case
        List<PermissionSetAssignment> delPSA = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> insertPSA = new List<PermissionSetAssignment>();
        for (String deletePSAId : delIds) {
            delPSA.add(new PermissionSetAssignment(Id = deletePSAId));
        }
        for (String psatoInsert : psaFields) {
            String[] tmpArray = psatoInsert.split(':');
            insertPSA.add(new PermissionSetAssignment(AssigneeId = tmpArray[0], PermissionSetGroupId = tmpArray[1]));
        }
        Database.insert(insertPSA, false);
        Database.delete(delPSA, false);
    }

    /**
     * @description Create a site user
     * @param newUserToInsert - User object to insert
     * @param accountId - Parent Account ID
     * @param createContact description
     * @return userId if successful, error message if not
     */
    public static string createSiteUser(User newUserToInsert, String accountId, Boolean createContact) {
        //String randomiser = string.valueOf(math.random()).substring(0,6);
        newUserToInsert.UserName = newUserToInsert.Email;
        String aliasName = newUserToInsert.FirstName.substring(0, 1);
        String aliasLastName = newUserToInsert.LastName.length() >= 7 ? newUserToInsert.LastName.substring(0, 6) : newUserToInsert.LastName;
        newUserToInsert.Alias = aliasName + aliasLastName;
        newUserToInsert.CommunityNickName = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
        newUserToInsert.TimeZoneSidKey = 'America/New_York';
        newUserToInsert.LocaleSidKey = 'en_US';
        newUserToInsert.EmailEncodingKey = 'UTF-8';
        newUserToInsert.LanguageLocaleKey = 'en_US';
        try {
            Contact contactToInsert = new Contact();
            //passing contact id in second parameter from unable my coke User
            if (createContact) {
                contactToInsert = createContactHelper(accountId, newUserToInsert, createContact);
            }
            newUserToInsert.ContactId = createContact == true ? contactToInsert.Id : accountId;
            insert newUserToInsert;
            return newUserToInsert.Id;
        } catch (Exception ex) {
            return 'Error: ' + ex.getMessage();
        }
    }

    /**
     * @description Create a site user
     * @param accountId - Parent Account ID
     * @param newUserToInsert - User object to insert
     * @param createContact boolean
     * @return Contact contact ID if successful, error message if not
     */

    private static Contact createContactHelper(String accountId, User newUserToInsert, Boolean createContact) {
        Account currentAccount  = new Account();
        CONA_B2BAccountSelector accSelector = new CONA_B2BAccountSelector();
        currentAccount = accSelector.getAccountById(accountId);
        Contact contactToInsert = new Contact(
            AccountId = accountId,
            FirstName = newUserToInsert.FirstName,
            LastName = newUserToInsert.LastName,
            Email = newUserToInsert.Email,
            Phone = newUserToInsert.Phone,
            CONA_B2BCreation_Source__c = 'Super User',
            BottlerId__c = currentAccount.BottlerId__c
        );
        if (createContact) {
            insert contactToInsert;
        }
        return contactToInsert;
    }

    /**
     * @description get details of logged in user
     * @return AccountID of user
     */
    @AuraEnabled
    public static string getLoggedInUserPrimaryAccount() {
        return [SELECT AccountID FROM User WHERE ID = :UserInfo.getUserId()][0].AccountId;
    }

    /**
     * @description get details of logged in user
     * @param userId Id of user to get contactID for
     * @return contactID of user
     */
    @AuraEnabled
    public static string getLoggedInUserPrimaryContact(String userId) {
        try {
            return [SELECT ContactID FROM User WHERE ID = :userId][0].ContactID;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description get details of logged in user
     * @param payload Id of user to get contactID for
     * @return success or error from operation
     */
    @AuraEnabled
    public static string enableDisableUser(String payload) {
        try {
            Database.SaveResult userDMLresult = Database.update((User) JSON.deserialize(payload, User.class));
            if (userDMLresult.isSuccess()) {
                List<String> permissionSetAssignmentLst = new List<String>();
                CONA_B2BUnablecokeUserWrapper.updateContact(userDMLresult.getId(), payload, permissionSetAssignmentLst);
                return 'success';
            } else {
                string errString = '';
                for (Database.Error s : userDMLresult.getErrors()) {
                    errString += s.getMessage();
                }
                return errString;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description get not-null value for given decimal
     * @param value value to be pruned
     * @return 0 or value provided if not null
     */
    public static Decimal prune(Decimal value) {
        if (value == null) {
            return 0;
        }
        return value;
    }

    /**
     * @description Wrapper class to send response back to LWC
     */
    public class UserListWrapper {
        @AuraEnabled
        public User user;
        @AuraEnabled
        public List<Account> accounts;
        @AuraEnabled
        public List<String> permissions;
        /**
         * @description get details of logged in user
         * @param user Id of user to get contactID for
         * @param accounts Id of user to get contactID for
         * @param permissions Id of user to get contactID for
         */
        public UserListWrapper(User user, List<Account> accounts, List<String> permissions) {
            this.user = user;
            this.accounts = accounts;
            this.permissions = permissions;
        }
    }

    /**
     * @description Inner Wrapper class to get user values to upsert
     */
    public class AccountWrapper {
        public String label;
        public String value;
    }
}