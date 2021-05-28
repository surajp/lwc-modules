const flatten = (obj, delimiter, newobj, prefix) => {
  if (!newobj) newobj = {};
  for (let prop in obj) {
    if (obj.hasOwnProperty(prop)) {
      if (!prefix) prefix = "";
      if (typeof obj[prop] === "object") flatten(obj[prop], delimiter, newobj, prefix + prop + delimiter);
      else newobj[prefix + prop] = obj[prop];
    }
  }
  return newobj;
};

//source: https://github.com/tsalb/lwc-utils/blob/master/utils-core/main/default/lwc/utils/utils.js
const reduceErrors = (errors) => {
  if (!Array.isArray(errors)) {
    errors = [errors];
  }

  return (
    errors
      // Remove null/undefined items
      .filter((error) => !!error)
      // Extract an error message
      .map((error) => {
        // UI API read errors
        if (Array.isArray(error.body)) {
          return error.body.map((e) => e.message);
        }
        // FIELD VALIDATION, FIELD, and trigger.addError
        else if (
          error.body &&
          error.body.enhancedErrorType &&
          error.body.enhancedErrorType.toLowerCase() === "recorderror" &&
          error.body.output
        ) {
          let firstError = "";
          if (
            error.body.output.errors.length &&
            error.body.output.errors[0].errorCode.includes("_") // one of the many salesforce errors with underscores
          ) {
            firstError = error.body.output.errors[0].message;
          }
          if (!error.body.output.errors.length && error.body.output.fieldErrors) {
            // It's in a really weird format...
            firstError = error.body.output.fieldErrors[Object.keys(error.body.output.fieldErrors)[0]][0].message;
          }
          return firstError;
        }
        // UI API DML, Apex and network errors
        else if (error.body && typeof error.body.message === "string") {
          let errorMessage = error.body.message;
          if (typeof error.body.stackTrace === "string") {
            errorMessage += `\n${error.body.stackTrace}`;
          }
          return errorMessage;
        }
        // PAGE ERRORS
        else if (error.body && error.body.pageErrors.length) {
          return error.body.pageErrors[0].message;
        }
        // JS errors
        else if (typeof error.message === "string") {
          return error.message;
        }
        // Unknown error shape so try HTTP status text
        return error.statusText;
      })
      // Flatten
      .reduce((prev, curr) => prev.concat(curr), [])
      // Remove empty strings
      .filter((message) => !!message)
  );
};

const processCompositeApiResponse = (resp) => {
  const errors = resp.compositeResponse
    .filter((r) => r.httpStatusCode !== 200)
    .map((r) => ({ errorCode: r.errorCode, message: `${r.body[0].message}::ReferenceId: ${r.referenceId}` }));
  const errorToDisplay = errors
    .filter((err) => err.errorCode !== "PROCESSING_HALTED")
    .map((err) => err.message)
    .join("^^^^");
  return { errors: errors.length, message: errorToDisplay };
};

export { flatten, reduceErrors, processCompositeApiResponse };
