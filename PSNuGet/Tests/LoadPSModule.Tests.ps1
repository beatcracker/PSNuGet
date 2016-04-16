$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module -Name "$here\..\..\PSNuGet"

Describe "Install NuGet Package(Load PSModule under /tools)" {
    <#
    It "Install Pester"{
        Use-NuGetPackage -PackageId "Pester"
        Get-Module Pester | Should Not BeNullOrEmpty
    }

    It "Install PShould"{
        Use-NuGetPackage -PackageId "PShould"
        Get-Module PShould | Should Not BeNullOrEmpty
    }
    #>

    It "Install PSMock"{
        Use-NuGetPackage -PackageId "PSMock"
        Get-Module PSMock | Should Not BeNullOrEmpty
    }

    <#
    It "Install PSate"{
        Use-NuGetPackage -PackageId "PSate"
        Get-Module PSate | Should Not BeNullOrEmpty
    }
    #>

    It "Install PSake"{
        Use-NuGetPackage -PackageId "PSake"
        Get-Module PSake | Should Not BeNullOrEmpty
    }
}
