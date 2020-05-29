/**
 * Created by ryan.cox on 1/29/20.
 */

public with sharing class ReAuthController {

    @AuraEnabled
    public static ReAuthResponse checkCredentials(String recordId, String password) {

        ReAuthResponse reAuthResponse = new ReAuthResponse();
        String username = UserInfo.getUserName();

        System.debug('ReAuthController > checkCredentials - recordId: ' + recordId  + ', username: ' + username + ', password: ' + password);

        // connected app
        String clientID = '3MVG9_XwsqeYoueI0Iv.s6lDAnZR6EnwMPpFBK3Lk.VAPbDUXtQ5WIquYZmJzNusk9U35s8VHDsXbuaUFllot';
        String clientSecret = 'E37B1CC36480B6C5BC0B3F66F27A5CC533FC6A26BC433AA661961CFEF3305828';

        // user security token
        User currentUser = [SELECT securityToken__c FROM User WHERE Username = :username LIMIT 1];
        String securityToken = currentUser.securityToken__c;
        System.debug('ReAuthController > checkCredentials - securityToken: ' + securityToken);

        if (securityToken != null) {

            Http http = new Http();
            HttpRequest request = new HttpRequest();

            // Set the named credential as the endpoint
            String url = 'https://login.salesforce.com/services/oauth2/token?grant_type=password'
                    + '&client_id=' + clientID
                    + '&client_secret=' + clientSecret
                    + '&username=' + username
                    + '&password=' + password + securityToken;
            System.debug('ReAuthController - checkCredentials > url: ' + url);

            request.setEndpoint(url);

            // Make the callout
            request.setMethod('POST');

            String accessToken;
            try {
                HttpResponse response = http.send(request);
                String body = response.getBody();
                System.debug('ReAuthController > checkCredentials - response: ' + response + ', body: ' + body);

                // get access token

                JSONParser parser = JSON.createParser(body);
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                        String name = parser.getText();
                        parser.nextValue();
                        String value = parser.getText();
                        System.debug('ReAuthController > checkCredentials - response name: ' + name + ', value: ' + value);
                        if (name == 'access_token') {
                            accessToken = value;
                        }
                        parser.nextToken();
                    }
                }

                if (accessToken != null) {
                    reAuthResponse.authPassed = true;
                    reAuthResponse.errorMessage = null;

                    if (recordId != null) {
                        // create ESignature for the Case record
                        ESignature__c signature = new ESignature__c();
                        signature.Case__c = recordId;
                        insert signature;
                        System.debug('ReAuthController > checkCredentials - ESignature created: ' + signature);
                    }
                } else {
                    reAuthResponse.authPassed = false;
                    reAuthResponse.errorMessage = 'Incorrect Password or Security Token';
                }

            } catch (Exception e) {
                System.debug('ReAuthController > checkCredentials - exception: ' + e);
                reAuthResponse.authPassed = false;
                reAuthResponse.errorMessage = e.getMessage();
            }

        } else {
            reAuthResponse.authPassed = false;
            reAuthResponse.errorMessage = 'No User Security Token';
        }

        return reAuthResponse;

    } // end checkCredentials


    public class ReAuthResponse {

        @AuraEnabled
        public Boolean authPassed;

        @AuraEnabled
        public String errorMessage;

    } // end ReAuthResponse


} // end ReAuthController