import executeDml from "@salesforce/apex/DynamicSOQLDMLController.executeDml";
import getSObjectType from "@salesforce/apex/DynamicSOQLDMLController.getSObjectTypeFromId";

async function dml(dmlType, records, sObjectType) {
  if (records && !Array.isArray(records)) {
    records = [records];
  }

  /* If sobjecType is not specified, we try to deduce it from the record id */
  if (!sObjectType)
    sObjectType = await getSObjectType({ recordId: records[0].Id });

  records = records.map((rec) => ({
    ...rec,
    attributes: { type: sObjectType }
  }));

  let results = await executeDml({
    operation: dmlType,
    strData: sObjectType
      ? JSON.stringify(records, (k, v) => {
          return typeof v === "number" ? "" + v : v;
        })
      : null,
    sObjectType
  });
  return results;
  return null;
}

const insert = dml.bind(null, "insert");
const update = dml.bind(null, "update");
const upsert = dml.bind(null, "upsert");
const del = dml.bind(null, "delete");

export { insert, update, upsert, del };
