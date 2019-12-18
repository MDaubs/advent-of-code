"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var fs = require("fs");
var readline = require("readline");
function accumulateInputs(filename, callback) {
    var reader = readline.createInterface({
        input: fs.createReadStream(filename),
        output: process.stdout
    });
    var accumulatedValue = 0;
    reader.on('line', function (line) {
        accumulatedValue += callback(parseInt(line));
        console.log(accumulatedValue);
    });
    reader.on('close', function () { console.log(accumulatedValue); });
}
accumulateInputs('day1.input', function (mass) { Math.floor(mass / 3) - 2; });
//# sourceMappingURL=day1.js.map