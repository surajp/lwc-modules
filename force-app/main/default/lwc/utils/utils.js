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

export { flatten };
