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

  /****
   ** Executes a dynamic soql query with params. Supports upto 6 parameters, since this isn't a truly dynamic solution
   ** @param query The query to be executed with placeholders for params. The placeholder is for the format '{{i}}' where 'i' is the position of the corresponding parameter in the accompanying parameters list
   ** @param params The list of query parameters corresponding to placeholders in the accompanying query
   ** @return The list of sobject rows retrieved by the query
   **/
  @AuraEnabled
  public static SObject[] executeSoqlQueryWithParams(String query, List<Object> params) {
    // This is hacky, but in the absence of a truly dynamic way to set variables, we don't have a lot of options
    Object arg0, arg1, arg2, arg3, arg4, arg5;
    for (Integer i = 0; i < Math.min(6, params.size()); i++) {
      query = query.replace('{{' + i + '}}', ':arg' + i);
      switch on i {
        when 0 {
          arg0 = params[0];
        }
        when 1 {
          arg1 = params[1];
        }
        when 2 {
          arg1 = params[2];
        }
        when 3 {
          arg1 = params[3];
        }
        when 4 {
          arg1 = params[4];
        }
        when 5 {
          arg1 = params[5];
        }
        when else {
        }
      }
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
