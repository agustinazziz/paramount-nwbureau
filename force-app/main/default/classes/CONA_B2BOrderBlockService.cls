/**
 * @description Class to get details of Account Block and Collector Info
 * @author      Salesforce.com
 * @since       2023
 */

public with sharing class CONA_B2BOrderBlockService {

    private final CONA_B2BAccountSelector accountSelector = new CONA_B2BAccountSelector();

    /**
     * @description  Method called from LWC Utility component
     * @param accountIds Set<Id> set of accountIds to retrieve Order Block information for
     * @return Map<Id, OrderBlockWrapper> Map of Order Block data by Account Ids
     */
    public Map<Id, OrderBlockWrapper> isOrderBlock(Set<Id> accountIds) {
        Map<Id, OrderBlockWrapper> orderBlockByAccountId = new Map<Id, OrderBlockWrapper>();
        List<Account> accounts = accountSelector.getAccountByIds(accountIds).values();

        for (Account acc : accounts) {
            OrderBlockWrapper orderBlock = new OrderBlockWrapper(
                    acc.CreditBlock__c || acc.OrderBlock__r?.Name == CONA_B2BConstants.ORDER_BLOCK_STATUS || acc.PayerCreditBlock__c,
                    acc.CollectorName__r?.Name
            );
            orderBlock.blockType = String.isNotBlank(acc.OrderBlock__r?.Name) ? acc.OrderBlock__r.Name : ''; // ref: 3438665
            orderBlockByAccountId.put(acc.Id, orderBlock);
        }
        return orderBlockByAccountId;
    }

    /**
    * @description OrderBlockWrapper wrapper class for Oder Block and Collector data
    */
    public class OrderBlockWrapper {

        /**
        * @description isOrderBlock
        */

        public Boolean isOrderBlock;
        /**
        * @description collectorName
        */
        public String collectorName;
        /**
        * @description blockType
        */
        public String blockType;


        /**
        * @description constructor method
        * @param isOrderBlock Boolean
        * @param collectorName String
        */
        public OrderBlockWrapper(Boolean isOrderBlock, String collectorName) {
            this.isOrderBlock = isOrderBlock;
            this.collectorName = collectorName;
        }
    }
}