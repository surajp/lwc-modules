public inherited sharing class ObjectInfoController {
  @AuraEnabled(cacheable=true)
  public static String getObjectInfo(List<String> sobjectTypes) {
    return JSON.serialize(Schema.describeSObjects(sobjectTypes));
  }

  @AuraEnabled(cacheable=true)
  public static String getFieldInfo(List<String> fieldNames) {
    List<String> objectNames = new List<String>();
    for (String fieldName : fieldNames) {
      while (fieldName.indexOf('.') > -1) {
        objectNames.add(fieldName.substringBefore('.').replace('__r', '__c'));
        fieldName = fieldName.substringAfter('.');
      }
    }
    List<DescribeSObjectResult> objectDescribes = Schema.describeSObjects(
      objectNames
    );
    Map<String, DescribeSObjectResult> objDescribeMap = new Map<String, DescribeSObjectResult>();
    for (Integer i = 0; i < objectDescribes.size(); i++) {
      objDescribeMap.put(objectNames[i], objectDescribes[i]);
    }
    Map<String, DescribeFieldResult> fieldDescribeMap = new Map<String, DescribeFieldResult>();
    for (String fieldName : fieldNames) {
      String immediateParent = fieldName.substringBeforeLast('.');
      if (immediateParent.indexOf('.') > -1) {
        immediateParent = immediateParent.substringAfterLast('.');
      }
      immediateParent = immediateParent.replace('__r', '__c');
      String lastChild = fieldName.substringAfterLast('.');
      fieldDescribeMap.put(
        fieldName,
        objDescribeMap.get(immediateParent)
          .fields.getMap()
          .get(lastChild)
          .getDescribe()
      );
    }
    return JSON.serialize(fieldDescribeMap);
  }
}
