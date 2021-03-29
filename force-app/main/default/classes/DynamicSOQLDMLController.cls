public with sharing class DynamicSOQLDMLController {
  /**
   * Execute a Soql Query
   * @param query The soql query to execute
   *
   * @return SObject[]
   **/
  @AuraEnabled
  public static SObject[] executeSoqlQuery(String query) {
    return Database.query(query);
  }

  /**
   * Get JavaScript from a Custom Metadata with a given name
   * @param cmdtName The name of Custom Metadata record to fetch the script from
   *
   * @return String
   **/
  @AuraEnabled(cacheable=true)
  public static String getJSFromCmdt(String cmdtName) {
    JS_Button__mdt[] jsButton = [SELECT Script__c FROM JS_Button__mdt WHERE DeveloperName = :cmdtName LIMIT 1];
    if (jsButton.size() == 1)
      return jsButton[0].Script__c;
    else
      return '';
  }

  /**
   * Short Description
   * @param recordId Get the SObject Type given a record Id
   *
   * @return String
   **/
  @AuraEnabled(cacheable=true)
  public static String getSObjectTypeFromId(Id recordId) {
    return recordId.getSObjectType().getDescribe().getName();
  }

  private static List<ContentVersion> deserializeContentVersion(String strData) {
    List<Object> deserializedRecords = (List<Object>) JSON.deserializeUntyped(strData);
    List<ContentVersion> recordsList = new List<ContentVersion>();
    for (Object objRec : deserializedRecords) {
      Map<String, Object> record = (Map<String, Object>) objRec;
      ContentVersion cv = new ContentVersion();
      String vData = String.valueOf(record.remove('VersionData'));
      cv = (ContentVersion) JSON.deserialize(JSON.serialize(record), ContentVersion.class);
      cv.put('VersionData', EncodingUtil.base64Decode(vData));
      recordsList.add(cv);
    }
    return recordsList;
  }

  /**
   * @description Execute a DML statement
   * @param operation 'Insert','Update' or 'Upsert'
   * @param strData The records to update, stringified
   * @param sObjectType The SObject type to perform the DML on
   * @return Id[]
   **/
  @AuraEnabled
  public static List<Id> executeDml(String operation, String strData, String sObjectType) {
    List<SObject> records = null;

    if (sObjectType.equalsIgnoreCase('ContentVersion')) {
      records = deserializeContentVersion(strData);
    } else {
      records = (SObject[]) JSON.deserialize(strData, Type.forName('List<' + sObjectType + '>'));
    }

    if (operation == 'insert') {
      insert records;
    } else if (operation == 'update') {
      update records;
    } else if (operation == 'upsert') {
      upsert records;
    } else if (operation == 'delete') {
      delete records;
    } else {
      return null;
    }
    return new List<Id>(new Map<Id, SObject>(records).keySet());
  }
}
