public with sharing class CONA_B2B_MC_EasyOrderEmailService {

    public static final String CLASS_NAME = CONA_B2B_MC_EasyOrderEmailService.class.getName();

    public void processOrders(String bottlerId, List<Id> easyOrderIds) {

        CONA_B2BWebstoreSelector webstoreSelector = new CONA_B2BWebstoreSelector();
        List<WebStore> webstores = webstoreSelector.getWebStoreByBottlerIds(new List<String>{bottlerId});
        WebStore webstore = webstores.get(0);

        if(webstore != null){
            CONA_SObjectUnitOfWork uow = new CONA_SObjectUnitOfWork(
                    new List<Schema.SObjectType>{
                            Logger__c.SObjectType
                    });

            List<EasyOrder__c> easyOrdersWithItems = new CONA_B2BEasyOrderSelector().getEasyOrdersWithItemsByEasyOrderId(easyOrderIds);

            Set<Id> accountIds = new Set<Id>();
            for (EasyOrder__c easyOrder : easyOrdersWithItems) {
                accountIds.add(easyOrder.Account__c);
            }

            Map<Id, List<Contact>> contactsPerAccount = getContactsForAccounts(accountIds);

            List<CONA_B2B_MC_EasyOrderRequest> requests = populateRequest(easyOrdersWithItems, contactsPerAccount, 100);

            if(!requests.isEmpty()) {
                for(CONA_B2B_MC_EasyOrderRequest request : requests) {
                    //Build the request body
                    String requestBody = JSON.serialize(request);

                    try {
                        CONA_MC_HTTPCalloutService.invokeAsyncJourneyApi(bottlerId, requestBody);
                        uow.registerNew(CONA_LoggerService.generateCalloutLogger(request?.members[0]?.data?.easyOrderId, requestBody, CLASS_NAME, null));
                    } catch (Exception ex) {
                        uow.registerNew(CONA_LoggerService.generateCalloutLogger(request?.members[0]?.data?.easyOrderId, requestBody, CLASS_NAME, ex));
                    }
                }
            }

            //Overriding CRUD check for Logger object
            uow.overrideCRUDCheck(Logger__c.SObjectType, CONA_SObjectUnitOfWork.DmlOperation.DML_INSERT);
            uow.commitWork();
        }
    }

    private Map<Id, List<Contact>> getContactsForAccounts(Set<Id> accountIds) {
        Map<Id, List<Contact>> accountIdToContactsMap = new Map<Id, List<Contact>>();
        List<AccountContactRelation> acrs = new CONA_B2B_AccountContactSelector().getAccountContactRelationsByAccountIds(accountIds);
        for (AccountContactRelation acr : acrs) {
            List<Contact> contacts = accountIdToContactsMap.get(acr.AccountId);
            if (contacts == null) {
                contacts = new List<Contact>();
            }
            contacts.add(acr.Contact);
            accountIdToContactsMap.put(acr.AccountId, contacts);
        }
        return accountIdToContactsMap;
    }

    private List<CONA_B2B_MC_EasyOrderRequest> populateRequest(List<EasyOrder__c> easyOrders, Map<Id, List<Contact>> contactsPerAccount, Integer maxMembersPerRequest) {
        List<CONA_B2B_MC_EasyOrderRequest> requests = new List<CONA_B2B_MC_EasyOrderRequest>();
        String settingName = [SELECT IsSandbox FROM Organization].IsSandbox ? 'Sandbox' : 'Prod';
        ProductSetting__c prodSetting = ProductSetting__c.getInstance(settingName);

        CONA_B2B_MC_EasyOrderRequest request = new CONA_B2B_MC_EasyOrderRequest();
        request.eventDefinitionKey = 'Easy_Order_Reminder';

        integer i = 0;

        for (EasyOrder__c easyOrder : easyOrders) {

            List<Contact> contactsFromAccount = contactsPerAccount.get(easyOrder.Account__c);
            if (contactsFromAccount != null) {
                for (Contact contact : contactsFromAccount) {
                    if (request.members.size() > maxMembersPerRequest) {
                        requests.add(request);
                        request = new CONA_B2B_MC_EasyOrderRequest();
                        request.eventDefinitionKey = 'Easy_Order_Reminder';
                    }
                    CONA_B2B_MC_EasyOrderRequest.MemberData member = new CONA_B2B_MC_EasyOrderRequest.MemberData();
                    member.contactKey = contact.Id;
                    member.data = new CONA_B2B_MC_EasyOrderRequest.EasyOrderData(easyOrder, contact, prodSetting);
                    request.members.add(member);
                    i++;
                }

            }
        }
        System.debug('number of members' + i);
        requests.add(request);
        return requests;
    }


}