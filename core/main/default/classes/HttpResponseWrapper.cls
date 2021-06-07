public with sharing class HttpResponseWrapper {
  @AuraEnabled
  public String body;
  @AuraEnabled
  public Integer statusCode;
  @AuraEnabled
  public Map<String, String> headers;

  public HttpResponseWrapper(String body, Integer statusCode, Map<String, String> headers) {
    this.body = body;
    this.statusCode = statusCode;
    this.headers = headers;
  }
}
