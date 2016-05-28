# PSModuleRegister
Version 0.0.5
Register a module in user's PS Module path
>Pass the module path to create a symbolic link in the PS Module path
>Install package from npm globally and register it in the PS Module path

Installation:
```
PS> npm install -g psmoduleregister
```

Example:
```
PS> psmoduleregister --register C:\MyPath\MyModule
```
Where the path provided contains a PowerShell module manifest (.psd1). For this example let's say MyModule.psd1
After its execution user should be able to work directly with the module i.e.:
```
PS> Import-Module MyModule
```

Example:
```
PS> psmoduleregister --install ps-modulepackage
```
Installs ps-modulepackage globally and register it in the module path
