import makeApiCall from "@salesforce/apex/APICallController.makeApiCall";

export default async function callout(
  endPoint,
  method = "GET",
  headers = { "Content-Type": "application/json" },
  body = null
) {
  return makeApiCall({
    endPoint,
    method,
    bodyStr: body ? JSON.stringify(body) : "",
    headers
  });
}
