export default class Util {
  
  test() {
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
  }

  toSQLArray(obj) {
    arr = [];
    cnt = 0;
    for (let prop in obj) {
        if (!obj.hasOwnProperty(prop)) continue;
        arr[cnt] = prop;
        cnt++;
    }
    arr = this.insertStrIntoArr(", ", arr);
}

insertStrIntoArr(str, arr) {
    cnt = 0
    for(item in arr) {
        arr.splice(item.index, 0, str);
    }
    return arr;
}


    /**
     * Checks if a server file exists, is not empty and has the specified extension
     * @param {string} path - path to the file
     * @param {string} ext - file extension 
     */
    FileOK(path, ext) {
      path += "?" + new Date().getTime() + Math.floor(Math.random() * 1000000);
      let file = new File(path);
      if (file.exists()) {
          let request = require("request");

          request({
              url: "https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/core.js",
              method: "HEAD"
          }, function (err, response, body) {
              console.log(response.headers);
              process.exit(0);
          });
      }
  }

  getExtension(path) {
      let basename = path.split(/[\\/]/).pop(),  // extract file name from full path ...
          // (supports `\\` and `/` separators)
          pos = basename.lastIndexOf(".");           // get last position of `.`
      if (basename === "" || pos < 1)            // if file name is empty or ...
          return "";                             //  `.` not found (-1) or comes first (0)
      return basename.slice(pos + 1);            // extract extension ignoring `.`
  }

  /**
   * Checks if a array is or any of its values are null or NaN
   * @param {*} arr - array to check
   * @param {*} from - lower limit to check - 0 if omitted
   * @param {*} to - upper limit to check - length of array if omitted
   */
  isNullOrUndefined(arr, from = 0, to) {
      if (!arr) return true;
      if (to === undefined) to = arr.length;
      for (let i = from; i <= to; i++) {
          if (!arr[i]) return true;
      }
      return false;
  }

  /**
   * Checks if a line is complete
   * @param {string} line - line to check
   * @returns bool - true if line is complete
   */
  isLineComplete(line) {
      splitted = line.split(',');
      if (splitted.length != 8) return false;
      if (splitted[0] = 1) {
          if (this.isNullOrUndefined(splitted, 1, 1) = false) return false;
          if (this.isNullOrUndefined(splitted, 3, 7) = false) return false;
          return true;
      }
  }

  /**
   * Adds a specific number of months to a date
   * @param {Date} date - date to add months to
   * @param {*} months - number of months to add
   * @returns date - date with months added
   */
  addMonths(date, months) {
      let d = date.getDate();
      date.setMonth(date.getMonth() + Number(months));
      if (date.getDate() != d)
          date.setDate(0);
      return date;
  }

}