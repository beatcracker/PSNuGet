$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module -Name "$here\..\..\PSNuGet"

#region Helper methods
function IsAssemblyLoaded
{
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [string] $AssemblyName,
        [ValidateSet("3.0", "4.0", "4.5", "4.5.1")]
        [string] $Version
    )
    $loadedAssemblyNames = [AppDomain]::CurrentDomain.GetAssemblies().GetName()
    [bool] $result = $loadedAssemblyNames.Name.Contains($AssemblyName)

    if ($result -and ![String]::IsNullOrEmpty($Version)){
        #TODO:VersionCheck
    }

    return $result
}
#endregion

Describe "Install NuGet Package(.NET)" {
    It "Install RazorMachine"{
        Use-NuGetPackage -PackageId "RazorMachine"
        IsAssemblyLoaded ("Xipton.Razor") | Should Be $true
        IsAssemblyLoaded ("System.Web.Razor") | Should Be $true
    }
    
    It "Install ClosedXML"{
        Use-NuGetPackage -PackageId "ClosedXML"
        IsAssemblyLoaded ("DocumentFormat.OpenXml") | Should Be $true
        IsAssemblyLoaded ("ClosedXML") | Should Be $true
    }
    
    It "Install Windows7APICodePack-Shell"{
        Use-NuGetPackage -PackageId "Windows7APICodePack-Shell"
        IsAssemblyLoaded ("Microsoft.WindowsAPICodePack") | Should Be $true
        IsAssemblyLoaded ("Microsoft.WindowsAPICodePack.Shell") | Should Be $true
    }

    It "Install NuGet.Server"{
        Use-NuGetPackage -PackageId "NuGet.Server"
        IsAssemblyLoaded ("Microsoft.Web.XmlTransform") | Should Be $true
        IsAssemblyLoaded ("Elmah") | Should Be $true
        IsAssemblyLoaded ("Ninject") | Should Be $true
        IsAssemblyLoaded ("RouteMagic") | Should Be $true
        IsAssemblyLoaded ("Microsoft.Web.Infrastructure") | Should Be $true
        IsAssemblyLoaded ("WebActivatorEx") | Should Be $true
        IsAssemblyLoaded ("System.ServiceModel.Web") | Should Be $true
        IsAssemblyLoaded ("NuGet.Server") | Should Be $true
    }

    It "Install Tx.Windows"{
        Use-NuGetPackage -PackageId "Tx.Windows"
        IsAssemblyLoaded ("System.Reactive.Interfaces") | Should Be $true
        IsAssemblyLoaded ("System.Reactive.Core") | Should Be $true
        IsAssemblyLoaded ("System.Reactive.Linq") | Should Be $true
        IsAssemblyLoaded ("System.Reactive.PlatformServices") | Should Be $true
        IsAssemblyLoaded ("Tx.Core") | Should Be $true
        IsAssemblyLoaded ("Tx.Windows") | Should Be $true
    }

    It "Install LiveSDK"{
        Use-NuGetPackage -PackageId "LiveSDK"
        IsAssemblyLoaded ("System.Net") | Should Be $true
        IsAssemblyLoaded ("Microsoft.Threading.Tasks") | Should Be $true
        IsAssemblyLoaded ("Microsoft.Threading.Tasks.Extensions") | Should Be $true
        IsAssemblyLoaded ("Microsoft.Live") | Should Be $true
    }

    It "Install Microsoft.IdentityModel.Clients.ActiveDirectory"{
        Use-NuGetPackage -PackageId "Microsoft.IdentityModel.Clients.ActiveDirectory"
        IsAssemblyLoaded ("System.Net") | Should Be $true
        IsAssemblyLoaded ("Microsoft.IdentityModel.Clients.ActiveDirectory") | Should Be $true
        IsAssemblyLoaded ("Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms") | Should Be $true
    }

    It "Install StackExchange.Redis"{
        Use-NuGetPackage -PackageId "StackExchange.Redis"
        IsAssemblyLoaded ("StackExchange.Redis") | Should Be $true
    }
}
