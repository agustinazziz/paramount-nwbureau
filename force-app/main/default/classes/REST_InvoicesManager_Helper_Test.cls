// *************************************************
// Created by: 		Gonzalo Calderon
// Creation Date:	03/24/23
// Description:		Test class for REST_InvoicesManager_Helper.
// Changes:			---
// ************************************************

@IsTest
public class REST_InvoicesManager_Helper_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'	\"invoices\": ['+
		'		{'+
		'			\"salesforceId\" : \"a06g000000YHo1iAAD\",'+
		'			\"invoiceAmount\" : 54300.55,'+
		'			\"invoiceDate\" : \"2023-03-22\",'+
		'			\"status\" : \"Paid\",'+
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
		'		},'+
		'		{'+
		'			\"salesforceId\" : \"a06g000000YHo37AAD\",'+
		'			\"invoiceAmount\" : 54300.55,'+
		'			\"invoiceDate\" : \"2023-03-22\",'+
		'			\"status\" : \"Paid\",'+
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
		REST_InvoicesManager_Helper obj = REST_InvoicesManager_Helper.parse(json);
		System.assert(obj != null);
	}
}