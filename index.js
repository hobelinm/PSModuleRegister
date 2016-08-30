#!/usr/bin/env node;

var fs = require('fs');
var program = require('commander');
var childProcess = require('child_process');

program
    .version('1.0.13')
    .option('-i, --install <ps-module-package>', 'npm install PowerShell module')
    .option('-r, --register <ps-module-path>', 'Existing PowerShell module location')
    .parse(process.argv);
    
if ((!program.install && !program.register) || (program.install && program.register)) {
    program.outputHelp();
    process.exit(0);
}

var errorFound = false;
if (program.install) {
    var execCmd = "npm install -g " + program.install;
    console.log("About to execute: " + execCmd);
    var npmInstall = childProcess.exec(execCmd, function(error, stdout, stderr) {
        if (error) {
            console.error(error.stack);
            console.warn('Error code: ' + error.code);
            console.warn('Signal Received: ' + error.signal);
            errorFound = true;
        }
        else {
            console.log(stdout);
            console.log(stderr);
        }
    });

    npmInstall.on('exit', function (code) {
        console.log('Command [' + execCmd + '] completed with code: ' + code);
        if (errorFound) {
            process.exit(1);
        }

        execCmd = "PowerShell -c . '" + __dirname + "\\RegisterModule.ps1' -Package " + program.install;
        var moduleInstall = childProcess.exec(execCmd, function(error, stdout, stderr) {
            if (error) {
                console.error(error.stack);
                console.warn('Error code: ' + error.code);
                console.warn('Signal Received: ' + error.signal);
                process.exit(1);
            }

            console.log(stdout);
            console.log(stderr);
            process.exit(0);
        });
    });
}

if (program.register) {
    var execCmd = "PowerShell -c . '" + __dirname + "\\RegisterModule.ps1' -Path '" + program.register + "'";
    var moduleInstall = childProcess.exec(execCmd, function (error, stdout, stderr) {
        if (error) {
            console.error(error.stack);
            console.warn('Error code: ' + error.code);
            console.warn('Signal Received: ' + error.signal);
            process.exit(1);
        }

        console.log(stdout);
        console.log(stderr);
        process.exit(0);
    });
}
