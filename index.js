var fs = require('fs');
var program = require('commander');
var exec = require('child_process').exec;

program
    .version('0.0.1')
    .option('-i, --install <ps-module-package>', 'npm install PowerShell module')
    .option('-r, --register <ps-module-path>', 'Existing PowerShell module location')
    .parse(process.argv);
    

if ((!program.install && !program.register) || (program.install && program.register)) {
    program.outputHelp();
    return
}

var errorFound = false;
if (program.install) {
    var execCmd = "npm install -g " + program.install;
    runCommand(execCmd);
    if (errorFound) {
        return;
    }
    
    execCmd = "PowerShell -c . '" + __dirname + "\\RegisterModule.ps1' -Package " + program.install;
    runCommand(execCmd);
    return;
}

if (program.register) {
    var execCmd = "PowerShell -c . '" + __dirname + "\\RegisterModule.ps1' -Path " + program.register;
    runCommand(execCmd);
    return;
}

function runCommand (cmd) {
    exec(cmd, function(err, stdout, stderr) {
        console.log(stdout);
        if (err) {
            errorFound = true;
            console.warn(stderr);
        }
    });
}
