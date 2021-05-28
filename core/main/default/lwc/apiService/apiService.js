import getSessionId from "@salesforce/apex/GetSessionIdController.getSessionId";
import getRestAPIBaseUrl from "@salesforce/apex/GetSessionIdController.getRestAPIBaseUrl";

export default async function sfapi(
  endPoint,
  method = "GET",
  headers = { "Content-Type": "application/json" },
  body = null
) {
  if (endPoint.toLowerCase().indexOf("salesforce.com") === -1) {
    const baseUrl = await getRestAPIBaseUrl();
    endPoint = baseUrl + endPoint;
  }
  const sessionId = await getSessionId();
  headers = Object.assign(headers, {
    "Content-Type": "application/json",
    Accept: "application/json",
    Authorization: `Bearer ${sessionId}`
  });
  const result = await fetch(endPoint, {
    mode: "cors",
    method,
    body,
    headers
  });
  return result.json();
}
