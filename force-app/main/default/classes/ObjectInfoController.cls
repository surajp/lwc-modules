public inherited sharing class ObjectInfoController {
  private static Map<Schema.SObjectType, DescribeSObjectResult> objectDescribesMap = new Map<Schema.SObjectType, DescribeSObjectResult>();

  @AuraEnabled(cacheable=true)
  public static String getObjectInfo(List<String> sobjectNames) {
    List<Schema.SObjectType> sobjectTypes = getSObjectTypesFromNames(sobjectNames);
    List<Schema.DescribeSObjectResult> retVal = getSObjectDescribes(sobjectTypes);
    return JSON.serialize(retVal);
  }

  private static List<DescribeSObjectResult> getSObjectDescribes(List<Schema.SObjectType> sobjectTypes) {
    List<Schema.SObjectType> uncachedSObjects = getUncachedSObjectsFromList(sobjectTypes);
    List<DescribeSObjectResult> retVal = new List<DescribeSObjectResult>();

    if (!uncachedSObjects.isEmpty()) {
      getAndCacheSObjectDescribes(uncachedSObjects);
    }
    for (Schema.SObjectType sobjectType : sobjectTypes) {
      retVal.add(objectDescribesMap.get(sobjectType));
    }
    return retVal;
  }

  private static List<Schema.SObjectType> getUncachedSObjectsFromList(List<Schema.SObjectType> sobjectTypes) {
    List<Schema.SObjectType> uncachedSObjects = new List<Schema.SObjectType>();
    for (Schema.SObjectType sobjectType : sobjectTypes) {
      if (!objectDescribesMap.containsKey(sobjectType)) {
        uncachedSObjects.add(sobjectType);
      }
    }
    return uncachedSObjects;
  }

  private static List<DescribeSObjectResult> getAndCacheSObjectDescribes(List<Schema.SObjectType> sObjectTypes) {
    List<Schema.DescribeSObjectResult> sobjectDescribes = new List<Schema.DescribeSObjectResult>();
    for (Schema.SObjectType sobjectType : sobjectTypes) {
      sobjectDescribes.add(sobjectType.getDescribe());
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
      sobjectTypes.add(getSObjectTypeFromName(sobjectName));
    }
    return sobjectTypes;
  }

  private static Schema.SObjectType getSObjectTypeFromName(String sobjectName) {
    return ((SObject) (Type.forName(sobjectName).newInstance())).getSObjectType();
  }

  @AuraEnabled(cacheable=true)
  public static String getFieldInfo(List<String> fieldNames) {
    List<String> objectNames = new List<String>();
    Map<String, DescribeFieldResult> fieldDescribesMap = new Map<String, DescribeFieldResult>();

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
      fieldDescribesMap.put(originalFieldName, fieldDescribe);
    }
    return JSON.serialize(fieldDescribesMap);
  }
}
