// *************************************************
// Created by: 		Gonzalo Calderon
// Creation Date:	03/22/23
// Description:		Helper class for the web service REST_InvoicesManager_v1. In charge of mapping
// 					the payload fields into the Salesforce object.
// History:         Created:    03/22/2023  -   Gonzalo Calderon.
//                  Updated:    03/19/2024  -   Agustín Azziz.
//								- The objToInvoice method was changed so that when receiving a payload 
//									with fewer fields, the service doesn't error out.
//								- Added putFieldsIfNotNull method that is used to fill the variables
//									if they are sent in the payload.
// ************************************************

public class REST_InvoicesManager_Helper {

	public List<Invoices> invoices;

	public class Invoices {
		public String salesforceId;
		public Double invoiceAmount;
		public String invoiceDate;
		public String status;
		public String invoiceNumber;
		public String invoicePaidDate;
		public String paymentType;
		public Double creditAmount;
		public Double paymentAmount;
		public String collectionReasonCodeComments;
		public String collectionReasonCode;
		public String collectionReasonCodeDate;
		public Double taxAmount;
		public Double totalInvoiceAmount;
	}

	
	public static REST_InvoicesManager_Helper parse(String json) {
		return (REST_InvoicesManager_Helper) System.JSON.deserialize(json, REST_InvoicesManager_Helper.class);
	}
    
    // GC: Map the payload to the Salesforce object. If by any reason,
    // any value is not properly formatted and fails, the main code
    // will then call the error method.
    public static Contracts_and_Invoices__c objToInvoice(Invoices inputInvoice){
        Contracts_and_Invoices__c singleInvoice = new Contracts_and_Invoices__c();
        	singleInvoice.Id = inputInvoice.salesforceId;
			putFieldsIfNotNull(singleInvoice, 'Invoice_Amount__c', inputInvoice.invoiceAmount);
			putFieldsIfNotNull(singleInvoice, 'Invoice_Date__c', inputInvoice.invoiceDate);
			putFieldsIfNotNull(singleInvoice, 'Status__c', inputInvoice.status);
			putFieldsIfNotNull(singleInvoice, 'Invoice_Number__c', inputInvoice.invoiceNumber);
			putFieldsIfNotNull(singleInvoice, 'Invoice_Paid_Date__c', inputInvoice.invoicePaidDate);
			putFieldsIfNotNull(singleInvoice, 'Payment_Type__c', inputInvoice.paymentType);
			putFieldsIfNotNull(singleInvoice, 'Credit_Amount__c', inputInvoice.creditAmount);
			putFieldsIfNotNull(singleInvoice, 'Payment_Amount__c', inputInvoice.paymentAmount);
			putFieldsIfNotNull(singleInvoice, 'Collection_Reason_Code_Comments__c', inputInvoice.collectionReasonCodeComments);
			putFieldsIfNotNull(singleInvoice, 'Collection_Reason_Code__c', inputInvoice.collectionReasonCode);
			putFieldsIfNotNull(singleInvoice, 'Collection_Reason_Code_Date__c', inputInvoice.collectionReasonCodeDate);
			putFieldsIfNotNull(singleInvoice, 'Tax_Amount__c', inputInvoice.taxAmount);
			putFieldsIfNotNull(singleInvoice, 'Total_Invoice_Amount__c', inputInvoice.totalInvoiceAmount);
			
        return singleInvoice;
    }

	private static void putFieldsIfNotNull(Contracts_and_Invoices__c singleInvoice, String fieldName, Object value) {
		List<String> stringFields = new List<String>{'Status__c', 'Invoice_Number__c', 'Payment_Type__c', 'Collection_Reason_Code_Comments__c', 'Collection_Reason_Code__c'};
		List<String> doubleFields = new List<String>{'Invoice_Amount__c', 'Credit_Amount__c', 'Payment_Amount__c', 'Tax_Amount__c', 'Total_Invoice_Amount__c'};

		if (value != null) {
			if (stringFields.contains(fieldName)) {
				singleInvoice.put(fieldName, (String)value);
			}else if(doubleFields.contains(fieldName)) {
				singleInvoice.put(fieldName, (Double)value);
			}else {
				singleInvoice.put(fieldName, Date.valueOf((String)value));
			}
		}
	}
    
    // GC: Save the error on the integration log custom object.
	// If the logic must be replicated, maintain the abbreviate 
    // methods so it never fails upon insert due to string sizes.
    public static RestResponse saveLog(String typeName, String getMessage, String stackTrace,  String requestBody, RestResponse response){
		// GC: If failed, send back status 500 ERROR, meaning 
        // Salesforce could not process the request due to internal errors.
		RestContext.response.statusCode = 500;
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf('[{ "errorCode" : "'+ typeName +'", "message" : "'+ getMessage +'" }]');
        Integration_Log__c integrationLog = new Integration_Log__c();
            integrationLog.Integration__c = 'InvoicesManager_v1'.abbreviate(18);
            integrationLog.Operation__c = 'PATCH'.abbreviate(8);
            integrationLog.Error_Type__c = typeName.abbreviate(80);
            integrationLog.Error_Description__c = (getMessage + ' ' + stackTrace).abbreviate(255);
			integrationLog.Request__c = requestBody.abbreviate(32768);
		insert integrationLog;
        return response;
    }
}