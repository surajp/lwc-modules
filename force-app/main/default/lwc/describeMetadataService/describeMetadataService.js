import getSObjectInfo from "@salesforce/apex/ObjectInfoController.getObjectInfo";
import getFieldInfo from "@salesforce/apex/ObjectInfoController.getFieldInfo";

const describeSObjectInfo = async (sobjectTypes) => {
  let resp = await getSObjectInfo({ sobjectTypes });
  return JSON.parse(resp);
};

const describeFieldInfo = async (fieldNames) => {
  let resp = await getFieldInfo({ fieldNames });
  return JSON.parse(resp);
};

export { describeSObjectInfo, describeFieldInfo };
