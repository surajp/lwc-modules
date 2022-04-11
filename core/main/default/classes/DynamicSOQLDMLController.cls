/************************************************************

*** @author Suraj Pillai
*** @date 05/2021
*** @description Contains methods for dynamic SOQL and DML
*** 
**/
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

  @AuraEnabled
  public static SObject[] executeSoqlQueryWithParams(String query, List<Object> params) {
    for (Integer i = 0; i < params.size(); i++) {
      query = query.replaceAll('{{' + i + '}}', ':params[' + i + ']');
    }
    System.debug('>>qury ' + query);
    return Database.query(query);
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
   * Execute a DML statement
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
