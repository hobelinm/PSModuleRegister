PSModuleRegister
================
Version 1.0.11 _Windows Only_

Register a module in user's PS Module path
>Pass the module path to create a symbolic link in the PS Module path
>Install package from npm globally and register it in the PS Module path
PSModuleRegister searches for the first module manifest present in the root of the 
provided path or the installed package and creates a symbolic link with such name
according to PowerShell module naming conventions to make it available directly in the 
user's console. Additionally this module perform the following checks/actions:
* Check for admin permissions (these are required for the symbolic link creation)
* Attempt to elevate to gain administrative permissions if current user doesn't have
* Enable symbolic link behavior to allow PowerShell to follow through the links
* Add user's Documents\WindowsPowerShell\Modules

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
Installs ps-modulepackage globally and register it in the module path. Use any existing npm PowerShell module instead of ps-modulepackage.
Supposing ps-modulepackage have a module manifest at its root (.psd1) user can import the module directly
```
PS> Import-Module MyModule
```
