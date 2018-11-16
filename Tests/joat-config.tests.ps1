[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText","")]
param()

Import-Module (Join-Path $PSScriptRoot ..\joat-config.psm1) -Force

Describe "StringTests" {
    $path = [System.IO.Path]::GetTempFileName()
	It "SetsGetsString" {
        Set-ConfigData -Path $path -Name "String1" -Value "abc"
        (Get-ConfigData -Path $path -Name "String1") | Should be "abc"
	}
	It "SetsGetsEncryptedString" {
        Set-ConfigData -Path $path -Name "String2" -Value "abc" -Encrypt
        (Get-ConfigData -Path $path -Name "String2" -Decrypt) | Should be "abc"
	}
    It "RemovesString" {
        Remove-ConfigData -Path $path -Name "String2" | should be $true
        Remove-ConfigData -Path $path -Name "String2" | should be $false
        Get-ConfigData -Path $path -Name "String2" -WarningAction "SilentlyContinue" | should be $null
    }
    It "TestsNumbers" {
        Set-ConfigData -Path $path -Name "Num1" -Value 123
        (Get-ConfigData -Path $path -Name "Num1") | Should be 123
    }
    Remove-Item $path
}


Describe "Wildcard tests" {
    $path = [System.IO.Path]::GetTempFileName()
	It "Gets two values" {
        Set-ConfigData -Path $path -Name "String1" -Value "abc"
        Set-ConfigData -Path $path -Name "String2" -Value "abc2"
        Set-ConfigData -Path $path -Name "Number" -Value 1
        $data = Get-ConfigData -Path $path -Name "String*"
        $data.Count| Should be 2
        $data[0] | Should be "abc"
        $data[1] | Should be "abc2"
	}
	It "Gets two values with names" {
        Set-ConfigData -Path $path -Name "String1" -Value "abc"
        Set-ConfigData -Path $path -Name "String2" -Value "abc2"
        Set-ConfigData -Path $path -Name "Number" -Value 1
        $data = Get-ConfigData -Path $path -Name "String*" -WithName
        $data.Count| Should be 2
        $data[0].Name | Should be "String1"
        $data[1].Name | Should be "String2"
        $data.Value[0] | Should be "abc"
        $data.Value[1] | Should be "abc2"
	}
    Remove-Item $path
}

Describe "ObjectTest" {
    $path = [System.IO.Path]::GetTempFileName()
    Write-Verbose "Cfg path is $path"
    $o = @{ a = @{ b = "testing"} }

    It "SetGetsObject" {
        Set-ConfigData -Path $path -Name "String1" -Value $o
        $ret = (Get-ConfigData -Path $path -Name "String1")
        $ret.a.b | Should be "testing"
    }
    It "SetGetsEncryptedObject" {
        Set-ConfigData -Path $path -Name "String2" -Value $o -Encrypt
        $ret = (Get-ConfigData -Path $path -Name "String2" -Decrypt)
        $ret.a.b | Should be "testing"
    }

    Remove-Item $path
}

Describe "MoreComplexObjectTest" {
    $path = [System.IO.Path]::GetTempFileName()
    Write-Verbose "Cfg path is $path"
    $o = @{ a = @{ user = "testing"
                   password = "pw"
                   clientId = 123
                   tenantId = 345
} }

    It "SetGetsObject" {
        Set-ConfigData -Path $path -Name "String1" -Value $o
        $ret = (Get-ConfigData -Path $path -Name "String1")
        $ret.a.user | Should be "testing"
        $ret.a.tenantId | Should be 345
    }
    It "SetGetsEncryptedObject" {
        Set-ConfigData -Path $path -Name "String2" -Value $o -Encrypt
        $ret = (Get-ConfigData -Path $path -Name "String2" -Decrypt)
        $ret.a.user | Should be "testing"
        $ret.a.tenantId | Should be 345
    }

    Remove-Item $path
}

Describe "SecureStringTest" {
    $path = [System.IO.Path]::GetTempFileName()
    Write-Verbose "Cfg path is $path"
    $ss = ConvertTo-SecureString -String "monkey123" -AsPlainText -Force

    It "SetGetsSecureString" {
        Set-ConfigData -Path $path -Name "SString" -Value $ss
        $ret = (Get-ConfigData -Path $path -Name "SString" -AsSecureString)
        $ret | Should beoftype 'SecureString'
    }

    It "SetGetSecureStringDecrypts" {
        Set-ConfigData -Path $path -Name "SString" -Value $ss
        $ret = (Get-ConfigData -Path $path -Name "SString" -Decrypt)
        $ret | Should be 'monkey123'
    }

    It "SetStringGetAsSecureString" {
        Set-ConfigData -Path $path -Name "SecString" -Value "monkey123" -Encrypt
        $ss = (Get-ConfigData -Path $path -Name "SecString")
        $ss | Should be 'System.Security.SecureString'
        $decryptedtString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ss))
        $decryptedtString | Should be 'monkey123'
    }

    It "SetStringGetAsSecureNumber" {
        Set-ConfigData -Path $path -Name "SecString" -Value 123 -Encrypt
        $ss = (Get-ConfigData -Path $path -Name "SecString")
        $ss | Should be 'System.Security.SecureString'
        $decryptedtString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ss))
        $decryptedtString | Should be 123
    }

    Remove-Item $path
}
