@isTest
public class MockHttpResponseGenerator implements HttpCalloutMock {
	
	Protected Integer responseCode;
    Protected String status;
    Protected String bodyAsString;
    Protected Map<String,String> responseHeaders;
     
    public MockHttpResponseGenerator(Integer code, String status, String bodyAsString, Map<String,String> headers){
        this.responseCode = code;
        this.status = status;
        this.bodyAsString = bodyAsString;
        this.responseHeaders = headers;
    }
	
	
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint and method.
        //System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        /*HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;*/
        
        HttpResponse res = new HttpResponse();
        res.setStatusCode(this.responseCode);
        res.setStatus(this.status);
        res.setBody(this.bodyAsString);
        return res;
        
    }
}