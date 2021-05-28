@isTest
public with sharing class APICallControllerTest {
  @isTest
  public static void testAPICall() {
    Test.setMock(HttpCalloutMock.class, new APICallMock());
    HttpResponseWrapper resp = APICallController.makeApiCall(
      'https://api.example.com',
      'POST',
      '{"message":"sample_request"}',
      new Map<String, String>{ 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    );
    system.assertEquals('{"message": "sample response"}', resp.body, 'Unexpected Response');
    system.assertEquals(200, resp.statusCode, 'Incorrect value for status code');
    system.assertEquals(2, resp.headers.size(), 'Mismatch in the number of response headers expected');
    system.assertEquals('sample_value1', resp.headers.get('custom_header1'), 'Incorrect value for first header');
    system.assertEquals('sample_value2', resp.headers.get('custom_header2'), 'Incorrect value for second header');
  }

  class APICallMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse resp = new HttpResponse();
      if (
        req.getBody() == '{"message":"sample_request"}' &&
        req.getHeader('Accept') == 'application/json' &&
        req.getHeader('Content-Type') == 'application/json'
      ) {
        resp.setBody('{"message": "sample response"}');
        resp.setHeader('custom_header1', 'sample_value1');
        resp.setHeader('custom_header2', 'sample_value2');
        resp.setStatusCode(200);
      } else {
        resp.setStatusCode(400);
        resp.setBody('{"message":"Bad Request"}');
      }
      return resp;
    }
  }
}
