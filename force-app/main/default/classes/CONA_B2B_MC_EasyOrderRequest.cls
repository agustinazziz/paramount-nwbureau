public with sharing class CONA_B2B_MC_EasyOrderRequest {

    public String eventDefinitionKey;	//APIEvent-ea03f4a9-4912-2c9d-69c8-cefe61c27047

    public List<MemberData> members = new List<MemberData>();

    public class MemberData {
        public String contactKey;	//JRQSYrPMGOYCZRX1

        public EasyOrderData data;

    }

    public class EasyOrderData {

        public EasyOrderData(EasyOrder__c easyOrder, Contact contact, ProductSetting__c productSetting){
            this.subscriberKey = contact.Id;
            this.emailAddress = contact.Email;
            this.mobile = contact.MobilePhone;
            this.language = contact.Language__c;
            this.easyOrderId = easyOrder.id;
            this.orderNumber = easyOrder.EasyOrderNumber__c;
            this.easyOrderType = easyOrder.Account__r.EasyOrderSetting__c;
            this.orderCutoffDate = easyOrder.CutOffTime__c.format('MM/dd/yyyy');
            this.cutoffTime = easyOrder.CutOffTime__c.format('hh:mm');
            this.cutoffTimezone = easyOrder.Account__r.TimeZone__c;
            this.deliveryDate = Datetime.newInstance(easyOrder.RequestedDeliveryDate__c, Time.newInstance(0,0,0,0)).format('MM/dd/yyyy');
            this.accountName = easyOrder.Account__r.Name;
            this.storeNumber = easyOrder.Account__r.LocationCode__c;
            this.accountNumber = easyOrder.Account__r.AccountNumber;
            this.address = easyOrder.Account__r.ShippingStreet;
            this.country = easyOrder.Account__r.ShippingCountry;
            this.state = easyOrder.Account__r.ShippingState;
            this.city = easyOrder.Account__r.ShippingCity;
            this.postalCode = easyOrder.Account__r.ShippingPostalCode;
            this.bottlerId = easyOrder.Account__r.BottlerId__c;


            this.totalLineItems = String.valueOf(easyOrder.Easy_Order_Items__r.size());
            this.orderLineItems = prepareItemsXlmPayload(easyOrder.Easy_Order_Items__r,productSetting, 5);
        }

        public String subscriberKey;	//JRQSYrPMGOYCZRX1 1
        public String bottlerId;	//111111 7

        //Contact Details
        public String emailAddress;	//daman88attwal@gmail.com 1
        public String mobile;	//1123123123 3
        public String language;	//EN 6

        //Order Details
        public String orderNumber;	//0000000001
        public String easyOrderType;	//0000000001
        public String orderCutoffDate;	//05/02/2023 11
        public String cutoffTime;
        public String cutoffTimezone;
        public String deliveryDate;	//05/22/2023 13

        //Account Details
        public String accountName;	//Company1
        public String storeNumber;	//1234
        public String accountNumber;	//534345346346  NA


        //Address Details
        public String address;	//Company Street
        public String city;	//NY
        public String state;	//NY
        public String postalCode;	//11103
        public String country;	//US 8

        //Other Details
		public String easyOrderId;
        
        //Order Line Item Details
        public String totalLineItems;   // 50
        public String orderLineItems;	//<orderLineDetails><ProductSequence>1</ProductSequence><ProductName>Coca Cola</ProductName><QuantityOrdered>5</QuantityOrdered><QuantityShipped>5</QuantityShipped><ProductPrice>32.32</ProductPrice><SKU>1111111</SKU><ProductImageUrl>https://www.google.com/image.png</ProductImageUrl></orderLineDetails><orderLineDetails><ProductSequence>2</ProductSequence><ProductName>Coca Cola</ProductName><QuantityOrdered>10</QuantityOrdered><QuantityShipped>5</QuantityShipped><ProductPrice>132.32</ProductPrice><SKU>1111112</SKU><ProductImageUrl>https://www.google.com/image1.png</ProductImageUrl></orderLineDetails>

		@TestVisible
        private String prepareItemsXlmPayload(List<EasyOrderItem__c> items, ProductSetting__c productSetting, Integer itemsLimit){
            List<String> lstXMLordrItems = new List<String>();
            Integer loopLimit = Math.min(itemsLimit,items.size());
            
            for(Integer i=0; i<loopLimit; i++){
                EasyOrderItem__c ordrItemRec = items[i];

                DOM.Document doc = new DOM.Document();
                dom.XmlNode orderLineItems = doc.createRootElement('orderLineDetails', null, null);
                orderLineItems.addChildElement('ProductSequence', null, null).addTextNode(String.valueof(i+1));
                orderLineItems.addChildElement('ProductName', null, null).addTextNode(ordrItemRec.Product__r?.Name);
                orderLineItems.addChildElement('QuantityOrdered', null, null).addTextNode(String.valueof(ordrItemRec.Quantity__c));
                orderLineItems.addChildElement('ProductImageUrl', null, null).addTextNode(getProductImageURL(String.valueOf(ordrItemRec.Product__r?.MaterialIdNumber__c),productSetting));
                orderLineItems.addChildElement('SKU', null, null).addTextNode(ordrItemRec.Product__r?.StockKeepingUnit);

                lstXMLordrItems.add(doc.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim());
            }
            return String.join(lstXMLordrItems,'');
        }
    }


    /**
     * @description           Method to generate product Image URL
     * @param materialNumber  passing the material number
     * @return                Returns Product image URL
     */
    @TestVisible
    private static String getProductImageURL(String materialNumber, ProductSetting__c productSetting){
        System.debug('materialNumber----> ' + materialNumber);
        System.debug('productSetting----> ' + productSetting);
        String imageBaseURL = productSetting.Public_Image_Base_URL__c;
        if(imageBaseURL.endsWith('/')){
            imageBaseURL = imageBaseURL.left(imageBaseURL.length() - 1);
        }

        return imageBaseURL + '/material/' + materialNumber + '?compression=' + productSetting.Image_Compression__c;
    }
}