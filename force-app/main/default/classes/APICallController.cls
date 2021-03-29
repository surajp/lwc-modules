/************************************************************

*** @author Suraj Pillai
*** @group Controller
*** @description Controller for making API calls and sending the response back
*** 
**/
public with sharing class APICallController {
  /**
   * @description Given an endpoint, request params and headers, callout the api and return the response
   * @param endPoint The endpoint to callout to
   * @param method The http method to use
   * @param bodyStr The request body string.
   * @param headers Map of string key and value for request headers
   * @return The response for the http request
   *
   */
  @AuraEnabled
  public static HttpResponseWrapper makeApiCall(
    String endPoint,
    String method,
    String bodyStr,
    Map<String, String> headers
  ) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(endPoint);
    req.setMethod(method);
    if (method != 'GET') {
      req.setBody(bodyStr);
    }
    if (headers != null) {
      for (String key : headers.keySet()) {
        req.setHeader(key, headers.get(key));
      }
    }
    HttpResponse resp = new Http().send(req);
    Map<String, String> respHeaders = new Map<String, String>();
    for (String key : resp.getHeaderKeys()) {
      respHeaders.put(key, String.valueOf(resp.getHeader(key)));
    }
    return new HttpResponseWrapper(resp.getBody(), resp.getStatusCode(), respHeaders);
  }
}
