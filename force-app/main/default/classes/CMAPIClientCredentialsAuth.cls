// *************************************************
// 
// Created by: 		Gonzalo Calderon
// Creation Date:	08/08/23
// Description:		Custom Auth. Provider for OAuth 2.0 Client Credentials Flow.
// 					Built for connection between Salesforce and CM/SAP.
// Changes:			---
// 
// ************************************************

global class CMAPIClientCredentialsAuth extends Auth.AuthProviderPluginClass{
	public static final String authProviderName = 'CMAPI_ClientCredentials';
	public static final String username = 'CMAPI Dummy User';
    public static final String metadataApiName = 'CMAPI__mdt';
    public IRefreshTokenGenerator generator = new DefaultRefreshTokenGenerator();
    private String callbackUrl;
    private string tokenEndpoint;
    private string clientId;
    private string clientSecret;
    private String tokenType;
    
    public CMAPIClientCredentialsAuth(){
    }
    
    public CMAPIClientCredentialsAuth(IRefreshTokenGenerator gen){
        this.generator = gen;
    }
    
    public  String getCustomMetadataType(){
        return metadataApiName;
    }

   //GC: This covers the Steps 1 to 5 of Authorization grant flow
    public PageReference initiate(Map<string, string> authProviderConfiguration, String stateToPropagate){
		final String callbackUrl = authProviderConfiguration.get('Callback_URL__c');
        final String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        final String url = baseUrl + callbackUrl + '?state=' + stateToPropagate;
        return new PageReference(url);
    }
 
    //GC: Get the token.
    public Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state){
        final String access_token = retrieveToken(authProviderConfiguration);
        final String refreshToken = generateRefreshToken();
		final String stateUrl = state.queryParameters.get('state');
        return new Auth.AuthProviderTokenResponse(authProviderName, access_token, refreshToken, stateUrl);
    }

	//GC: Custom refresh flow. Generate dummy refresh token and get new access token.
    public override Auth.OAuthRefreshResult refresh(Map<String,String> authProviderConfiguration, String refreshToken){
        final String newRefreshToken = generateRefreshToken();
        final String access_token = retrieveToken(authProviderConfiguration);
        return new Auth.OAuthRefreshResult(access_token, newRefreshToken);
    }
    
    private String retrieveToken(Map<String, String> authProviderConfiguration){
		clientId = getAndEncode(authProviderConfiguration, 'Client_Id__c');
        clientSecret  = getAndEncode(authProviderConfiguration, 'Client_Secret__c');
        tokenEndpoint = authProviderConfiguration.get('Token_Endpoint__c');
        String body = 
            'client_id='+ clientId +
            '&client_secret='+ clientSecret +
            '&grant_type=client_credentials';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(tokenEndpoint);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded;charset=UTF-8');
        request.setMethod('POST');
        request.setBody(body);
        HttpResponse response = http.send(request);
        ResponseWrapper responseWrapper = (ResponseWrapper) JSON.deserialize(response.getBody(), ResponseWrapper.class);
        return responseWrapper.access_token;
    }

    //Return fake user, client credentials auth flow is not for a user
    public Auth.UserData getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response){
		return new Auth.UserData(
			null,
            null,
            null,
            null,
            null,
            null,
            username,
            null,
            authProviderName,
            null,
            new Map<String, String>()
        );
    }
    
	private String getAndEncode(Map<String, String> config, String key){
        return EncodingUtil.urlEncode(config.get(key), 'UTF-8');
    }
    
    private String generateRefreshToken(){
        return this.generator.generate();
    }

	//GC: Interface to allow us to override refresh token generation when testing.
    public interface IRefreshTokenGenerator{
        String generate();
    }

    //GC: Default implementation for runtime.
	public class DefaultRefreshTokenGenerator implements IRefreshTokenGenerator{
        public String generate() {
            final String refreshToken = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
            return refreshToken;
        }
    }
    
    //GC: ResponseWrapper inner class
    public class ResponseWrapper{
        public String access_token;
        public String token_type;
        public String expires_in;
    }
}