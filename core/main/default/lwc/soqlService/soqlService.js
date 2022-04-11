import executeSoql from "@salesforce/apex/DynamicSOQLDMLController.executeSoqlQuery";
import executeSoqlWithParams from "@salesforce/apex/DynamicSOQLDMLController.executeSoqlQueryWithParams";

export default async function soql(query, params) {
  let results;
  if (params) {
    results = await executeSoqlWithParams({ query, params });
  } else {
    results = await executeSoql({ query });
  }
  return results;
}
