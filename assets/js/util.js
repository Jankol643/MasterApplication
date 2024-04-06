const Singleton = (function () {
  let instance;

  createDirStructure() {
    //TODO: read from JSON file
    //var fs  = require('fs');
    var obj = {
      "europe": {
        "poland": {},
        "france": {},
        "spain": {},
        "greece": {},
        "UK": {},
        "germany": "txt"
      },
      "Asia": {
        "india": "xml"
      },
      "Africa": null
    };

  createStructure(folder, o) {
      for (let key in o) {
        if (typeof o[key] === 'object' && o[key] !== null) {
          console.log('folder created : ' + (folder + key))
          //fs.mkdir(folder + key, function() {
          if (Object.keys(o[key]).length) {
            create(folder + key + '/', o[key]);
          }
          //});
        } else {
          console.log('file created : ' + (folder + key + (o[key] === null ? '' : '.' + o[key])))
          //fs.writeFile(folder + key + (o[key] === null ? '' : '.' + o[key]));
        }
      }
  };

  function createInstance() {
      const object = new Object({ name: "Singleton Object" });
      return object;
  }

  return {
      getInstance: function () {
          if (!instance) {
              instance = createInstance();
          }
          return instance;
      },
  };
});

const singleton1 = Singleton.getInstance();
export default singleton1;