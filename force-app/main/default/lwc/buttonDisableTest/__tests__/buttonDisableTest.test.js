import { createElement } from "lwc";
import ButtonDisableTest from "c/buttonDisableTest";
import executeSoql from "@salesforce/apex/DynamicSOQLDMLController.executeSoqlQuery";

const NAV_TYPE = "standard__recordPage";
const NAV_OBJECT_API_NAME = "Account";
const NAV_ACTION_NAME = "view";

jest.mock("@salesforce/apex/DynamicSOQLDMLController.executeSoqlQuery", () => ({ default: jest.fn() }), {
  virtual: true
});

function setupTest() {
  const element = createElement("c-button-disable-test", {
    is: ButtonDisableTest
  });
  document.body.appendChild(element);

  return { element };
}

function flushPromises() {
  return new Promise((r) => setTimeout(r, 0));
}

describe("c-button-disable-test", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("disables navigation if there is no id", () => {
    executeSoql.mockResolvedValue(null);
    const { element } = setupTest();
    return Promise.resolve().then(() => {
      const button = element.shadowRoot.querySelector('[data-id="viewObjectButton"]');
      expect(button.disabled).toBeFalsy();
    });
  });

  it("enables navigation if there is an id", () => {
    executeSoql.mockResolvedValue([{ Id: "test123", Name: "Acme Inc" }]);
    const { element } = setupTest();
    return Promise.resolve().then(() => {
      const button = element.shadowRoot.querySelector('[data-id="viewObjectButton"]');
      Promise.resolve().then(() => expect(button.disabled).toBeTruthy());
    });
  });

  it("should enable button", () => {
    executeSoql.mockResolvedValue([{ Id: "test123", Name: "Acme Inc" }]);
    const { element } = setupTest();
    return Promise.resolve().then(() => {
      const button = element.shadowRoot.querySelector('[data-id="viewObjectButton"]');
      flushPromises().then(() => {
        button.click();
        const pageReference = element.navRef;

        expect(pageReference.type).toBe(NAV_TYPE);
        expect(pageReference.attributes.objectApiName).toBe(NAV_OBJECT_API_NAME);
        expect(pageReference.attributes.actionName).toBe(NAV_ACTION_NAME);
        expect(pageReference.attributes.recordId).toBe("test123");
      });
    });
  });
});
