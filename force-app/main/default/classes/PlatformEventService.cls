/************************************************************

*** @author Suraj Pillai
*** @date 05/2021
*** @description Contains Platform Event related methods
*** 
**/
public with sharing class PlatformEventService {
  /****
   ** @description Publishes a single platform event of a given type with the given data
   ** @param eventName The Platform Event type
   ** @param eventData JSON String with the platform event data
   **/
  @AuraEnabled
  public static void publishEvent(String eventType, String eventData) {
    SObject pEvent = (SObject) JSON.deserialize(eventData, Type.forName(eventType));
    Eventbus.publish(pEvent);
  }
}
