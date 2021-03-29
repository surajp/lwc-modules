/************************************************************

*** Copyright (c) Vertex Computer Systems Inc. All rights reserved.

*** @author Suraj Pillai
*** @group Controller
*** @date 01/2021
*** @description Get API-ready session id of the current users
*** 
**/
public with sharing class GetSessionIdController {
  /****
   ** @description Returns the current user's session id that may be used for calling Salesforce APIs
   ** @return the current user's api-ready session id
   **/
  @AuraEnabled(cacheable=true)
  public static String getSessionId() {
    String content = Page.GetSessionId.getContent().toString();
    return getSessionIdFromPage(content);
  }

  private static String getSessionIdFromPage(String content) {
    Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
      e = content.indexOf('End_Of_Session_Id');
    return content.substring(s, e);
  }

  @AuraEnabled(cacheable=true)
  public static String getRestAPIBaseUrl() {
    return URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v51.0';
  }
}
