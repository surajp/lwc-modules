public inherited sharing class ObjectInfoController {
  @AuraEnabled(cacheable=true)
  public List<DescribeSObjectResult> getObjectInfo(List<String> sobjectTypes) {
    return Schema.DescribeSObjects(sobjectTypes);
  }

  @AuraEnabled(cacheable=true)
  public Map<String, Schema.DescribeFieldResult> getFieldInfo(
    List<String> fieldNames
  ) {
    for (String fieldName : fieldNames) {
      while (fieldName.indexOf('.') > -1) {
        objectNames.add(fieldName.substringBefore('.').replace('__r', '__c'));
        fieldName = fieldName.substringAfter('.');
      }
    }
    List<DescribeSObjectResult> objectDescribes = ObjectInfoController.getObjectInfo(
      objectNames
    );
    for (Integer i = 0; i < objectDescribes.size(); i++) {
      objDescribeMap.put(objName, objectDescribes[i]);
    }
    for (String fieldName : fieldNames) {
      String immediateParent = fieldName.substringBeforeLast('.')
        .substringAfterLast('.')
        .replace('__r', '__c');
      String lastChild = fieldName.substringAfterLast('.');
      fieldDescribeMap.put(
        fieldName,
        objDescribeMap.get(immediateParent)
          .fields.getMap()
          .get(lastChild)
          .getDescribe()
      );
    }
  }
}
