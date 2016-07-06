#!/usr/bin/env node

var fs = require('fs');
var program = require('commander');
var exec = require('exec-npm');

function runCommand (cmd) {
    console.log("About to execute: " + cmd);
    exec(cmd, function(err) {
        if (err) {
            errorFound = true;
            console.warn(err.message);
        }
    });
}

program
    .version('1.0.0')
    .option('-i, --install <ps-module-package>', 'npm install PowerShell module')
    .option('-r, --register <ps-module-path>', 'Existing PowerShell module location')
    .parse(process.argv);
    

if ((!program.install && !program.register) || (program.install && program.register)) {
    program.outputHelp();
    process.exit(0);
}

var errorFound = false;
if (program.install) {
    var execCmd = ["npm", "install", "-g", program.install];
    runCommand(execCmd);
    if (errorFound) {
        process.exit(1);
    }
    
    execCmd = ["PowerShell", "-c . '" + __dirname + "\\RegisterModule.ps1' -Package " + program.install];
    runCommand(execCmd);
    process.exit(0);
}

if (program.register) {
    var execCmd = ["PowerShell", "-c . '" + __dirname + "\\RegisterModule.ps1' -Path '" + program.register + "'"];
    runCommand(execCmd);
    if (errorFound) {
        process.exit(1);
    }
    
    process.exit(0);
}
