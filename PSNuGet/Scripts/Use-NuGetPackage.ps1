﻿function Use-NuGetPackage
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $PackageId,
        [string] $Version = $null,
        [switch] $IncludePreRelease = $true,
        [switch] $Force = $false
    )
    $ErrorActionPreference = "Stop"
    Set-StrictMode -Version Latest

    #Add NuGet package Id to script variable
    $Script:LoadedPackageNames.Add($PackageId)

    #Initialize packagemanager if not explicitly called
    if ($script:PackageManager -eq $null){
        Initialize-NuGetPackageManager -Verbose
    }

    [NuGet.PackageManager] $manager = $script:PackageManager

    #Search installed package
    [NuGet.IPackage] $package = Find-LocalNuGetPackage -PackageId $PackageId -Version $Version

    if ($Force -and ($package -ne $null))
    {
        Write-Verbose ($messages.UninstallPackage -f $package.ToString())
        $manager.UninstallPackage($package, $true)
        $package = $null
    }

    #If package is already installed, do nothing, If local package is not found. install it.
    if ($package -ne $null)
    {
        Write-Verbose ($messages.UsePackage -f $package)
    }
    else
    {
        #Validate PackageId exists
        if (!($PackageManager.SourceRepository.Exists($PackageId, $Version))){
            Write-Error ($messages.PackageNotFound -f $PackageId, $Version)
        }
        
        Write-Progress -Activity ($messages.InstallPackageProgress -f $PackageId)
        $manager.InstallPackage($PackageId, $Version, $true, $IncludePreRelease) #Ignore dependency(manually resolve it)
        Write-Progress -Activity ($messages.InstallPackageProgress -f $PackageId) -Complete
        
        #Write package install log to verbose stream(Loaded package name can't determined before installation)
        $package = Find-LocalNuGetPackage -PackageId $PackageId -Version $Version
        Write-Verbose ($messages.PackageInstalled -f $package.ToString())
    }

    # Trying to detect FrameworkVersion using CLRVersion
    # https://github.com/altrive/PSNuGet/issues/2
    # http://stackoverflow.com/questions/12971881/how-to-reliably-detect-the-actual-net-4-5-version-installed

    [Runtime.Versioning.FrameworkName] $frameworkName = $null
    switch ($PSVersionTable.CLRVersion){
        {$_.Major -eq 4 -and $_.Build -eq 30319} {
            if ($_.Revision -lt 17626) {
                $frameworkName = ".NETFramework,Version=v4.0"
            } else {
                $frameworkName = ".NETFramework,Version=v4.5"
            }
        }
        default{ $frameworkName = [NuGet.VersionUtility]::DefaultTargetFramework }
    }


    #Load dependent NuGet packages first
    foreach ($dependency in [NuGet.PackageExtensions]::GetCompatiblePackageDependencies($package, $frameworkName))
    {
        #Resolve dependency to compatible stable version.(Need additional query to repository)
        #$package = [NuGet.PackageRepositoryExtensions]::ResolveDependency($manager.SourceRepository, $dependency, $false, $true)
        #Use-NuGetPackage -PackageId $package.Id -Version $package.Version -Force:$Force
       
        #TODO: How to resolve best version? 
        if (!$Script:LoadedPackageNames.Contains($dependency.Id)){
            Use-NuGetPackage -PackageId $dependency.Id -Version $dependency.VersionSpec.MaxVersion -Force:$Force
        }
    }

    #Load framework assemblies 
    $items = $null
    if ([NuGet.VersionUtility]::TryGetCompatibleItems($frameworkName, $package.FrameworkAssemblies, [ref] $items))
    {
        foreach ($item in $items)
        {
            $item = [NuGet.FrameworkAssemblyReference] $item
            if ($item.AssemblyName -notin $Script:LoadedAssemblyNames)
            {
                Write-Verbose ($messages.LoadFrameworkAssembly -f $item.AssemblyName)
                Add-Type -AssemblyName $item.AssemblyName
                $Script:LoadedAssemblyNames.Add($item.AssemblyName)
            }
        }
    }

    #Load referenced assemblies 
    $items = $null
    if ([NuGet.VersionUtility]::TryGetCompatibleItems($frameworkName, $package.AssemblyReferences, [ref] $items))
    {
        foreach ($item in $items)
        {
            #Skip if Name is PackageEmptyFileName
            if ($item.Name -eq "_._")
            {
                continue
            }

            $assemblyName = [IO.Path]::GetFileNameWithoutExtension($item.Name)
            if ($assemblyName -notin $Script:LoadedAssemblyNames)
            {
                Write-Verbose ($messages.LoadAssembly -f $item.Name, $item.TargetFramework)
                #Note: Add-Type Cmdlet can't handle dependent assembly, when difference (compatible) version assembly is already loaded in AppDomain.
                #Add-Type -Path $item.SourcePath
                [Reflection.Assembly]::LoadFile($item.SourcePath) > $null
                $Script:LoadedAssemblyNames.Add($assemblyName)
            }
        }
    }

    #Load PowerShell Module(.psm1) from "tools" directory
    $toolFiles = [NuGet.PackageExtensions]::GetToolFiles($package)
    [NuGet.IPackageFile[]] $psModuleFiles = $toolFiles | where { $_.Path.EndsWith(".psm1")}
    if ($psModuleFiles -ne $null)
    {
        foreach ($file in $psModuleFiles)
        {
            Write-Verbose ($messages.PSModuleImport -f $file.SourcePath)
            Import-Module $file.SourcePath -Verbose:$false -Global #Import module to global scope
        }
    }

    #Import PowerShell Module(.psm1) from "content" directory
    $contentFiles = [NuGet.PackageExtensions]::GetContentFiles($package)
    [NuGet.IPackageFile[]] $psModuleFiles = $contentFiles | where { $_.Path.EndsWith(".psm1")}
    if ($psModuleFiles -ne $null)
    {
        foreach ($file in $psModuleFiles)
        {
            Write-Verbose ($messages.PSModuleImport -f $file.SourcePath)
            Import-Module $file.SourcePath -Verbose:$false -Global #Import module to global scope
        }
    }
}
