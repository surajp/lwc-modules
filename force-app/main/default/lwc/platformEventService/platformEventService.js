import publishEvent from "@salesforce/apex/PlatformEventService.publishEvent";
const publish = (eventType, eventData) => {
  publishEvent({ eventType, eventData });
};

export { publish };
