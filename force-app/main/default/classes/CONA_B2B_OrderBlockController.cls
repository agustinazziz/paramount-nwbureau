/**
 * @description Class to get details of Account Block and Collector Info
 * @author      Salesforce.com
 * @since       2023
 */

public without sharing class CONA_B2B_OrderBlockController {

    /**
    * @description  Method called from LWC Utility component 
    * @param accId account ID
    * @return Map<String,String> Map of block and collector details if they exist
    */ 
    
    @AuraEnabled (cacheable=true)
    public static Map<String,String> isOrderBlock(String accId){
        Map<String,String> returnedMap = new Map<String,String>();
        try {
            CONA_B2BOrderBlockService orderBlockService = new CONA_B2BOrderBlockService();

            CONA_B2BOrderBlockService.OrderBlockWrapper orderBlock = orderBlockService.isOrderBlock(new Set<Id>{accId}).get(accId);

            if(orderBlock.isOrderBlock){
                returnedMap.put('isOrderBlocked','true');
            }
            if(orderBlock.collectorName != null){
                returnedMap.put('collectorName',orderBlock.collectorName);
            }
            if(String.isNotBlank(orderBlock.blockType)){
                returnedMap.put('blockType', orderBlock.blockType);
            }
            return returnedMap;
        } catch (Exception ex ) {
            throw new AuraHandledException(ex.getMessage());    
            
        } 

    }


}