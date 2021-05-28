import executeSoql from "@salesforce/apex/DynamicSOQLDMLController.executeSoqlQuery";

export default async function soql(query) {
  let results = await executeSoql({ query });
  return results;
}
