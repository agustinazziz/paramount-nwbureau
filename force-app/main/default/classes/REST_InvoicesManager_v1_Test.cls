// *************************************************
// Created by: 		Gonzalo Calderon
// Creation Date:	03/24/23
// Description:		Test class for REST_InvoicesManager_v1.
// Changes:			---
// ************************************************

@isTest
public class REST_InvoicesManager_v1_Test {

    // GC: Create an empty invoice
    @testSetup
    static void dataSetup(){
        //Create Invoice
        Contracts_and_Invoices__c singleInvoice = new Contracts_and_Invoices__c();
        	singleInvoice.Name = 'Test Invoice for Test Class';
        insert singleInvoice;
    }
    
    // GC: Test the GET method
    @isTest
    static void testSuccessGetMethod(){
        Id recordId = [SELECT Id FROM Contracts_and_Invoices__c LIMIT 1].Id;
		RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/InvoicesManager/v1/' + recordId;
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        Contracts_and_Invoices__c returnedInvoice = REST_InvoicesManager_v1.getInvoiceById();
        // Verify results
        System.assert(returnedInvoice != null);
        System.assertEquals('Test Invoice for Test Class', returnedInvoice.Name);
    }
    
    
    // GC: Test the PATCH method on Success
    @isTest
    static void testSuccessPatchMethod(){
		Id recordId = [SELECT Id FROM Contracts_and_Invoices__c LIMIT 1].Id;
		RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/services/apexrest/InvoicesManager/v1/';
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(requestCreator(recordId, '2023-03-22', 'Paid'));
        RestContext.request = request;
        RestContext.response = response;
        // Update the Invoice
        REST_InvoicesManager_v1.updateInvoiceFields();
        // Verify results
        System.assertEquals(200, response.statusCode);
    }
    
    // GC: Test the PATCH method on bad mapping
    @isTest
    static void testBadMappingPatchMethod(){
		Id recordId = [SELECT Id FROM Contracts_and_Invoices__c LIMIT 1].Id;
		RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/services/apexrest/InvoicesManager/v1/';
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(requestCreator(recordId,'03/22/2023', 'Paid'));
        RestContext.request = request;
        RestContext.response = response;
        // Update the Invoice
        REST_InvoicesManager_v1.updateInvoiceFields();
        // Verify results
        System.assertEquals(500, response.statusCode);
    }
    
	// GC: Test the PATCH method on bad update
    @isTest
    static void testBadUpdatePatchMethod(){
		Id recordId = [SELECT Id FROM Contracts_and_Invoices__c LIMIT 1].Id;
		RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/services/apexrest/InvoicesManager/v1/';
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        // GC: Bad value on restricted picklist.
        request.requestBody = Blob.valueOf(requestCreator(recordId,'2023-03-22', 'BADVALUEONRESTRICTEDPICKLIST'));
        RestContext.request = request;
        RestContext.response = response;
        // Update the Invoice
        REST_InvoicesManager_v1.updateInvoiceFields();
        // Verify results
        System.assertEquals(500, response.statusCode);
    }
    
    // GC: To dinamically create requests for good and bad inputs
    static String requestCreator(String recordId, String dateInput, String picklistValue){
		String json = '{'+
		'	\"invoices\": ['+
		'		{'+
		'			\"salesforceId\" : \"'+ recordId +'\",'+
		'			\"invoiceAmount\" : 54300.55,'+
		'			\"invoiceDate\" : \"'+ dateInput +'\",'+
		'			\"status\" : \"'+ picklistValue +'\",'+
		'			\"invoiceNumber\" : \"INV23094\",'+
		'			\"invoicePaidDate\" : \"2023-03-23\",'+
		'			\"paymentType\" : \"Cleared\",'+
		'			\"creditAmount\" : 1300.11,'+
		'			\"paymentAmount\" : 1500.33,'+
		'			\"collectionReasonCodeComments\" : \"Testing the PATCH\",'+
		'			\"collectionReasonCode\" : \"Code123\",'+
		'			\"collectionReasonCodeDate\" : \"2023-03-01\",'+
		'			\"taxAmount\" : 999.99,'+
		'			\"totalInvoiceAmount\" : 10101.11'+
		'		}'+
		'	]'+
		'}';
        return json;
    }
}