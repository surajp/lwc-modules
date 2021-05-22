import getSObjectInfo from "@salesforce/apex/ObjectInfoController.getObjectInfo";
import getFieldInfo from "@salesforce/apex/ObjectInfoController.getFieldInfo";

const describeSObjectInfo = async (sobjectNames) => {
  let resp = await getSObjectInfo({ sobjectNames });
  return JSON.parse(resp);
};

const describeFieldInfo = async (fieldNames) => {
  let resp = await getFieldInfo({ fieldNames });
  return JSON.parse(resp);
};

export { describeSObjectInfo, describeFieldInfo };
