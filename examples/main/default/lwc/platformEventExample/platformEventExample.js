import { LightningElement } from "lwc";
import * as platformEventService from "c/platformEventService";
import { subscribe, unsubscribe, onError } from "lightning/empApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const TEST_EVENT = "Test_Event__e";
export default class PlatformEventExample extends LightningElement {
  channelName = `/event/${TEST_EVENT}`;
  isSubscribeDisabled = false;
  isUnsubscribeDisabled = !this.isSubscribeDisabled;

  subscription = {};
  message = "";
  receivedMessages = [];

  // Initializes the component
  connectedCallback() {
    // Register error listener
    this.registerErrorListener();
  }

  // Handles subscribe button click
  handleSubscribe() {
    // Callback invoked whenever a new event message is received
    const messageCallback = (response) => {
      console.log("New message received: ", JSON.stringify(response));
      this.receivedMessages = [...this.receivedMessages, response.data.payload.Message__c];
    };

    // Invoke subscribe method of empApi. Pass reference to messageCallback
    subscribe(this.channelName, -1, messageCallback).then((response) => {
      // Response contains the subscription information on subscribe call
      console.log("Subscription request sent to: ", JSON.stringify(response.channel));
      this.subscription = response;
      this.toggleSubscribeButton(true);
    });
  }

  // Handles unsubscribe button click
  handleUnsubscribe() {
    this.toggleSubscribeButton(false);

    // Invoke unsubscribe method of empApi
    unsubscribe(this.subscription, (response) => {
      console.log("unsubscribe() response: ", JSON.stringify(response));
      // Response is true for successful unsubscribe
    });
  }

  toggleSubscribeButton(enableSubscribe) {
    this.isSubscribeDisabled = enableSubscribe;
    this.isUnsubscribeDisabled = !enableSubscribe;
  }

  registerErrorListener() {
    // Invoke onError empApi method
    onError((error) => {
      console.log("Received error from server: ", JSON.stringify(error));
      // Error contains the server-side error
    });
  }

  handleMessageChange(event) {
    this.message = event.target.value;
  }

  handlePublish() {
    if (!this.message) {
      this.dispatchEvent(new ShowToastEvent({ variant: "error", message: "Please enter a message to be published" }));
    }
    const message = JSON.stringify({ Message__c: this.message });
    platformEventService.publish(TEST_EVENT, message);
  }
}
