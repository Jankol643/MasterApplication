  function test() {
    //TODO: read from JSON file
    //let fs  = require('fs');
    let obj = {
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
  }

  function createStructure(folder, o) {
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

export {test, createStructure};