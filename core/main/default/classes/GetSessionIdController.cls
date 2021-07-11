/************************************************************

*** Copyright (c) Vertex Computer Systems Inc. All rights reserved.

*** @author Suraj Pillai
*** @group Controller
*** @date 01/2021
*** @description Get API-ready session id of the current users
*** 
**/
public with sharing class GetSessionIdController {
  @TestVisible
  private static String maxApiVersion = null;
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

  class Attribute {
    String type;
    String url;
  }

  class Resp {
    Attribute attributes;
  }

  /****
   ** @description Get the latest api version this org is on. It uses the fact that queried sobjects when serialized includes the REST API url to access the record. We extract the api version from this url
   ** @return Api version in the form 'v51.0'
   **/
  private static String getCurrentMaxApiVersion() {
    if (String.isEmpty(maxApiVersion)) {
      Pattern p = Pattern.compile('v[0-9.]{4}'); // Match api version in the format v51.0
      Resp r = (Resp) JSON.deserialize(JSON.serialize([SELECT Id FROM User LIMIT 1][0]), Resp.class);
      Matcher m = p.matcher(r.attributes.url);
      m.find();
      maxApiVersion = m.group(0);
    }
    return maxApiVersion;
  }

  /****
   ** Get Base Url for REST API for the current org
   ** @return Base Url for REST API for the current org
   **/
  @AuraEnabled(cacheable=true)
  public static String getRestAPIBaseUrl() {
    String currentMaxApiVersion = getCurrentMaxApiVersion();
    return URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/' + currentMaxApiVersion;
  }
}
