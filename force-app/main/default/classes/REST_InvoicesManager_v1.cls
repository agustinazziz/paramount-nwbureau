// *************************************************
// Created by: 		Gonzalo Calderon
// Creation Date:	03/22/23
// Description:		Apex Web Service to handle the update of invoices from the SAP system.
// Methods:			* getInvoiceById: Not used on the original scope. Made only for testing purposes.
// 					* updateInvoiceFields: Updates invoices on Salesforce from the integration.
// 					Although the method is able to handle multiple invoices, was determined to send 
// 					only 1 invoice per call so CM (middleware) can handle the errors properly based 
// 					on the header response. Will create an error log if failed.
// History:         Created:    03/22/2023  -   Gonzalo Calderon.
//                  Updated:    03/19/2024  -   Agustín Azziz.
//                              - Added the StackTraceString to the SaveLog DML to have more info about errors.
// ************************************************

@RestResource(urlMapping = '/InvoicesManager/v1/*')
global with sharing class REST_InvoicesManager_v1 {
    
    // GC: Not needed for the integration. Built only if ever needed. Requires the Id on the URL.
	@HttpGet
    global static Contracts_and_Invoices__c getInvoiceById(){
		RestRequest request = RestContext.request;
		// GC: Grab the Invoice Id from the end of the URL
        String invoiceId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
		Contracts_and_Invoices__c result =  [SELECT Id, Name, Invoice_Amount__c, Invoice_Date__c, Status__c, 
                                             Invoice_Number__c, Invoice_Paid_Date__c, Payment_Type__c, 
                                             Credit_Amount__c, Payment_Amount__c, Collection_Reason_Code_Comments__c, 
                                             Collection_Reason_Code__c, Collection_Reason_Code_Date__c, Tax_Amount__c, 
                                             Total_Invoice_Amount__c 
                                             FROM Contracts_and_Invoices__c 
                                             WHERE Id = :invoiceId];
		return result;
    }
    
    // GC: PATCH/Update operation.
    @HttpPatch
    global static void updateInvoiceFields(){
        List<Contracts_and_Invoices__c> invoicesToUpdate = new List<Contracts_and_Invoices__c>();
        RestRequest request = RestContext.request;
        // GC: If doesn't encounter any errors later on, will send the success response with header 200 OK.
        RestContext.response.statusCode = 200;
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf('{ "message" : "success" }');
        // GC: Map the payload based on the helper class.
        REST_InvoicesManager_Helper obj = REST_InvoicesManager_Helper.parse(request.requestbody.tostring());
        
		for(REST_InvoicesManager_Helper.Invoices singleInvoice : obj.Invoices){
            // GC: Try mapping. If fails, call the error method, 
            // save the log and send back error 500.
            try {
            	Contracts_and_Invoices__c mappedInvoice = REST_InvoicesManager_Helper.objToInvoice(singleInvoice);
            	invoicesToUpdate.add(mappedInvoice);
        	} catch (Exception e) {
            	RestResponse response = RestContext.response;
                response = REST_InvoicesManager_Helper.saveLog(e.getTypeName(), e.getMessage(), e.getStackTraceString(), 
                                                               request.requestbody.tostring().deleteWhitespace(), response);
        	}
		}
        // GC: Try to update. If failed due to any issues with the request, 
        // call the error method and log it into the log object, sending error 500 back.
        try {
			update invoicesToUpdate;
        } catch (Exception e) {
            RestResponse response = RestContext.response;
            // GC: Save the error on the integration log custom object.
            response = REST_InvoicesManager_Helper.saveLog(e.getTypeName(), e.getMessage(), e.getStackTraceString(), 
                                                           request.requestbody.tostring().deleteWhitespace(), response);
        }
    }
}