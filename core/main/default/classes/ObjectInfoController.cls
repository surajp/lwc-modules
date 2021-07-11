/************************************************************

*** @author Suraj Pillai
*** @date 04/2021
*** @description Contains bulkified methods for returning object and field descriptions
*** 
**/
public inherited sharing class ObjectInfoController {
  private static Map<Schema.SObjectType, DescribeSObjectResult> objectDescribesMap = new Map<Schema.SObjectType, DescribeSObjectResult>();

  /****
   ** Returns JSON string of list of DescribSObjectResult for the given sobjects
   ** @param sobjectNames list of api names of sobjects
   ** @return JSON string of list of DescribSObjectResult for given sobjects
   **/
  @AuraEnabled(cacheable=true)
  public static String getObjectInfo(List<String> sobjectNames) {
    List<Schema.SObjectType> sobjectTypes = getSObjectTypesFromNames(sobjectNames);
    List<Schema.DescribeSObjectResult> retVal = getSObjectDescribes(sobjectTypes);
    return JSON.serialize(retVal);
  }

  private static List<DescribeSObjectResult> getSObjectDescribes(List<Schema.SObjectType> sobjectTypes) {
    List<Schema.SObjectType> uncachedSObjects = removeCachedSObjectsFromList(sobjectTypes);
    List<DescribeSObjectResult> retVal = new List<DescribeSObjectResult>();

    if (!uncachedSObjects.isEmpty()) {
      getAndCacheSObjectDescribes(uncachedSObjects);
    }
    for (Schema.SObjectType sobjectType : sobjectTypes) {
      if (sobjectType != null) {
        retVal.add(objectDescribesMap.get(sobjectType));
      }
    }
    return retVal;
  }

  private static List<Schema.SObjectType> removeCachedSObjectsFromList(List<Schema.SObjectType> sobjectTypes) {
    List<Schema.SObjectType> uncachedSObjects = new List<Schema.SObjectType>();
    for (Schema.SObjectType sobjectType : sobjectTypes) {
      if (sobjectType != null && !objectDescribesMap.containsKey(sobjectType)) {
        uncachedSObjects.add(sobjectType);
      }
    }
    return uncachedSObjects;
  }

  private static List<DescribeSObjectResult> getAndCacheSObjectDescribes(List<Schema.SObjectType> sObjectTypes) {
    List<Schema.DescribeSObjectResult> sobjectDescribes = new List<Schema.DescribeSObjectResult>();
    for (Schema.SObjectType sobjectType : sobjectTypes) {
      if (sobjectType != null) {
        sobjectDescribes.add(sobjectType.getDescribe());
      }
    }
    cacheSObjectDescribes(sobjectDescribes);
    return sobjectDescribes;
  }

  private static void cacheSObjectDescribes(List<DescribeSObjectResult> sobjectDescribes) {
    for (DescribeSObjectResult objDescribe : sobjectDescribes) {
      objectDescribesMap.put(objDescribe.getSObjectType(), objDescribe);
    }
  }

  private static List<Schema.SObjectType> getSObjectTypesFromNames(List<String> sobjectNames) {
    List<Schema.SObjectType> sobjectTypes = new List<Schema.SObjectType>();
    for (String sobjectName : sobjectNames) {
      SObjectType theType = getSObjectTypeFromName(sobjectName);
      if (theType != null) {
        sobjectTypes.add(theType);
      }
    }
    return sobjectTypes;
  }

  private static Schema.SObjectType getSObjectTypeFromName(String sobjectName) {
    Type theType = Type.forName(sobjectName);
    if (theType != null) {
      return ((SObject) theType.newInstance()).getSObjectType();
    }
    return null;
  }

  /****
   ** @description Returns field describe information for a list of qualified field names (eg: Contact.Account.Name) in the form of a JSON string
   ** @param fieldNames list of field names
   ** @return JSON string for list of field describe information for the specified fields
   **/
  @AuraEnabled(cacheable=true)
  public static String getFieldInfo(List<String> fieldNames) {
    List<String> objectNames = new List<String>();
    List<DescribeFieldResult> fieldDescribesList = new List<DescribeFieldResult>();

    for (String fieldName : fieldNames) {
      String originalFieldName = fieldName;
      String currObjName = fieldName.substringBefore('.');
      Schema.SObjectType currSObjectType = getSObjectTypeFromName(currObjName);
      fieldName = fieldName.substringAfter('.');

      while (fieldName.indexOf('.') > -1) {
        String currFieldName = fieldName.substringBefore('.').replace('__r', '__c');
        if (!currFieldName.endsWith('__c')) {
          currFieldName = currFieldName + 'Id';
        }
        currSObjectType = getSObjectDescribes(new List<Schema.SObjectType>{ currSObjectType })[0]
          .fields.getMap()
          .get(currFieldName)
          .getDescribe()
          .getReferenceTo()[0];
        fieldName = fieldName.substringAfter('.');
      }

      DescribeFieldResult fieldDescribe = getSObjectDescribes(new List<Schema.SObjectType>{ currSObjectType })[0]
        .fields.getMap()
        .get(fieldName)
        .getDescribe();
      fieldDescribesList.add(fieldDescribe);
    }
    return JSON.serialize(fieldDescribesList);
  }
}
