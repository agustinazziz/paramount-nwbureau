// *************************************************
// 
// Created by: 		Gonzalo Calderon
// Creation Date:	08/08/23
// Description:		Test class for CMAPIClientCredentialsAuth.
// Changes:			Franco Ansaldi - updated class
// 
// ************************************************

@isTest
public class CMAPIClientCredentialsAuth_Test {
	
    public static testMethod void testGetCustomMetadataType() {
		CMAPIClientCredentialsAuth instance = new CMAPIClientCredentialsAuth();
        System.assertEquals(CMAPIClientCredentialsAuth.metadataApiName, instance.getCustomMetadataType());
    }
    
    public static testMethod void testInitiate() {
        CMAPIClientCredentialsAuth instance = new CMAPIClientCredentialsAuth();
        Map<String, String> authProviderConfiguration = new Map<String, String>();
        authProviderConfiguration.put('Callback_URL__c', 'test');
        final String state = 'testState';

        PageReference ref = instance.initiate(authProviderConfiguration, state);
        System.assertEquals(URL.getSalesforceBaseUrl().toExternalForm() + 'test?state=testState', ref.getUrl());
    }
    
    public static testMethod void testHandleCallback_Success() {
        Map<String, String> authProviderConfiguration = new Map<String, String>();
        authProviderConfiguration.put('Tenant_ID__c', 'tenantId');
        authProviderConfiguration.put('Client_Id__c', 'clientId');
        authProviderConfiguration.put('Client_Secret__c', 'clientSecret');
        authProviderConfiguration.put('Token_Endpoint__c', 'https://login.microsoftonline.com/tenantId/oauth2/v2.0/token');

        final String mockResponse = '{"access_token": "fake_access_token"}';
        
        final TokenEndpointHttpCalloutMockImpl httpMock = new TokenEndpointHttpCalloutMockImpl(mockResponse);
        Test.setMock(HttpCalloutMock.class, httpMock);
        
        CMAPIClientCredentialsAuth instance = new CMAPIClientCredentialsAuth(new StaticRefreshTokenGenerator());
        final Map<String, String> queryArgs = new Map<String, String>();
        queryArgs.put('state', 'randomState');
        Auth.AuthProviderCallbackState callbackState = new Auth.AuthProviderCallbackState(new Map<String, String>(),
            '',
            queryArgs);
        
        system.debug('authProviderConfiguration: ' + authProviderConfiguration);
        system.debug('instance: ' + instance);
        system.debug('callbackState: ' + callbackState);
        system.debug('queryArgs: ' + queryArgs);
        
        // call
        
        Auth.AuthProviderTokenResponse response = instance.handleCallback(authProviderConfiguration, callbackState);
        system.debug('test2: ' + response); 
        // assert
        httpMock.assertUrl('https://login.microsoftonline.com/tenantId/oauth2/v2.0/token');
        httpMock.assertContentType('application/x-www-form-urlencoded;charset=UTF-8');
        httpMock.assertMethod('POST');
        httpMock.assertBody(
            'client_id=clientId&client_secret=clientSecret&grant_type=client_credentials'
        );
        System.assertEquals(CMAPIClientCredentialsAuth.authProviderName, response.provider);
        System.assertEquals('fake_access_token', response.oauthToken);
        System.assertEquals('fake_refresh_token', response.oauthSecretOrRefreshToken);
        System.assertEquals('randomState', response.state); 
    }
    
    public static testMethod void testGetUserInfo() {
        CMAPIClientCredentialsAuth instance = new CMAPIClientCredentialsAuth();
        Auth.UserData r = instance.getUserInfo(null, null);
        System.assertEquals(CMAPIClientCredentialsAuth.USERNAME, r.username);
        System.assertEquals(CMAPIClientCredentialsAuth.authProviderName, r.provider);
    }

    public static testMethod void testRefresh() {
        Map<String, String> authProviderConfiguration = new Map<String, String>();
        authProviderConfiguration.put('Tenant_ID__c', 'tenantId');
        authProviderConfiguration.put('Client_Id__c', 'clientId');
        authProviderConfiguration.put('Client_Secret__c', 'clientSecret');
        authProviderConfiguration.put('Token_Endpoint__c', 'https://login.microsoftonline.com/tenantId/oauth2/v2.0/token');

        final String mockResponse = '{"access_token": "fake_access_token"}';

        final TokenEndpointHttpCalloutMockImpl httpMock = new TokenEndpointHttpCalloutMockImpl(mockResponse);
        Test.setMock(HttpCalloutMock.class, httpMock);

        system.debug('authProviderConfiguration: ' + authProviderConfiguration);
        
        // call
        CMAPIClientCredentialsAuth instance = new CMAPIClientCredentialsAuth(new StaticRefreshTokenGenerator());
        
        system.debug('instance:' + instance);
        Auth.OAuthRefreshResult response = instance.refresh(authProviderConfiguration, null);	

        // assert
        httpMock.assertUrl('https://login.microsoftonline.com/tenantId/oauth2/v2.0/token');
        httpMock.assertContentType('application/x-www-form-urlencoded;charset=UTF-8');
        httpMock.assertMethod('POST');
        System.assertEquals('fake_access_token', response.accessToken);
        System.assertEquals('fake_refresh_token', response.refreshToken);
        System.assert(null == response.error);
    }
    
    private class TokenEndpointHttpCalloutMockImpl implements HttpCalloutMock {
        private String callUrl;
        private String callMethod;
        private String callBody;
        private Map<String, String> callHeaders = new Map<String, String>();
        private String responseBody;
        private String responseContentType = 'application/json';
        private Integer responseStatus = 200;
        
        public TokenEndpointHttpCalloutMockImpl(String response) {
            this.responseBody = response;
        }
        
        public TokenEndpointHttpCalloutMockImpl(String response, String contentType) {
            this(response);
            this.responseContentType = contentType;
        }
        
        public TokenEndpointHttpCalloutMockImpl setResponseStatus(Integer status) {
            this.responseStatus = status;
            return this;
        }
        
        public void assertMethod(String method) {
            if (String.isEmpty(this.callMethod))
                System.assert(false, 'Method never set');
            System.assertEquals(method, this.callMethod);
        }
        
        public void assertUrl(String url) {
            if (String.isEmpty(this.callUrl))
                System.assert(false, 'URL never called');
            	System.assertEquals(url, this.callUrl);
        }
        
        public void assertBody(String body) {
            if (String.isEmpty(this.callBody))
                System.assert(false, 'URL never called');
            System.assertEquals(body, this.callBody);
        }
        
        public void assertContentType(String value) {
            this.assertHeader('Content-Type', value);
        }
        
        public void assertHeader(String key, String value) {
            if (this.callHeaders.size() == 0)
                System.assert(false, 'No headers');
            if (String.isEmpty(key))
                System.assert(false, 'Must supply header name');
            String v = this.callHeaders.get(key.toLowerCase());
            if (String.isEmpty(v))
                System.assert(false, 'Header not set');
            System.assertEquals(value, v);
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            this.callUrl = req.getEndpoint();
            this.callMethod = req.getMethod();
            this.callBody = req.getBody();
            this.callHeaders.put('content-type', req.getHeader('Content-Type'));
            this.callHeaders.put('accept', req.getHeader('Accept'));
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', this.responseContentType);
            res.setBody(this.responseBody);
            res.setStatusCode(this.responseStatus);
            return res;
        }
    }
    
    private class StaticRefreshTokenGenerator implements CMAPIClientCredentialsAuth.IRefreshTokenGenerator{
        public String generate() {
            return 'fake_refresh_token';
        }
    }
}