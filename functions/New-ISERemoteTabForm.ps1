﻿#requires -version 4.0
#requires -module ISE

Function New-ISERemoteForm {

  [cmdletbinding()]
  [Alias("nrtf")]
  [outputtype("None")]
  Param()

  Add-Type -AssemblyName PresentationFramework
  Add-Type -AssemblyName PresentationCore
  Add-Type -AssemblyName WindowsBase

  #define the form XAML
  [xml]$xaml = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApplication3"
        Title="New Remote ISE Tab" Height="350" Width="525">
    <Grid HorizontalAlignment="Left" Height="316" VerticalAlignment="Top" Width="521" Margin="0,0,-2.333,0">
        <GroupBox x:Name="ComputerGroup" Header="Computer" HorizontalAlignment="left" Margin="15,12,0,0" VerticalAlignment="Top" Height="116" Width="490">
            <Grid HorizontalAlignment="Left" Height="90" Margin="3,7,0,0" VerticalAlignment="Top" Width="472">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="89*"/>
                    <ColumnDefinition Width="383*"/>
                </Grid.ColumnDefinitions>
                <Label x:Name="labelCN" Content="Computername" HorizontalAlignment="Left" Margin="12,0,0,0" VerticalAlignment="Top" Grid.ColumnSpan="2"/>
                <TextBox x:Name="textComputername" HorizontalAlignment="Left" Height="20" Margin="20,3,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="170" Grid.Column="1" ToolTip="Enter a computername or a comma separated list" TabIndex="1"/>
                <Label x:Name="label1" Content="Username" HorizontalAlignment="Left" Margin="14,61,0,0" VerticalAlignment="Top"/>
                <TextBox x:Name="textUserName" HorizontalAlignment="Left" Height="20" Margin="20,65,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="170" Grid.Column="1" ToolTip="Enter a username in the format domain\user or machine\user" TabIndex="3"/>
                <Label x:Name="label2" Content="Password" HorizontalAlignment="Left" Margin="190,61,0,0" VerticalAlignment="Top" RenderTransformOrigin="3.926,-1.387" Grid.Column="1"/>
                <PasswordBox x:Name="textPassword" HorizontalAlignment="Left" Margin="250,65,0,0" VerticalAlignment="Top" Width="116" Height="20" Grid.Column="1" TabIndex="4"/>
                <Label x:Name="label7" Content="Configuration" HorizontalAlignment="Left" Margin="15,32,0,0" VerticalAlignment="Top" Grid.ColumnSpan="2" Width="90"/>
                <TextBox x:Name="textConfiguration" Grid.Column="1" HorizontalAlignment="Left" Height="20" Margin="20,35,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="170" ToolTip="Enter an alternate configuration name" TabIndex="2"/>
                <CheckBox x:Name="checkVM" Content="Use VMName" Grid.Column="1" HorizontalAlignment="Left" Margin="248,5,0,0" VerticalAlignment="Top" ToolTip = "Use VMName instead of computername" TabIndex="0"/>
                <CheckBox x:Name="checkPromptCredential" Content="Prompt Credential" Grid.Column="1" HorizontalAlignment="Left" Margin="248,20,0,0" VerticalAlignment="Top" ToolTip="Prompt for a credential for each connection" TabIndex="1"/>
                </Grid>
        </GroupBox>
         <Label x:Name="version" Content="version"  HorizontalAlignment="Left" VerticalAlignment="Top" Margin="15,283,0,0"/>
        <Button x:Name="btnConnect" Content="_Connect" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="428,283,0,0" TabIndex="12"/>
        <GroupBox x:Name="OptionsGroup" Header="Options" HorizontalAlignment="Left" Height="135" Margin="15,137,0,0" VerticalAlignment="Top" Width="490  ">
            <Grid HorizontalAlignment="Left" Height="124" Margin="-1,3,-2,-41" VerticalAlignment="Top" Width="481">
                <CheckBox x:Name="checkSSL" Content="Use SSL" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="6,1,0,0" TabIndex="5"/>
                <Label x:Name="label3" Content="Use Port" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="3,30,0,0"/>
                <TextBox x:Name="textPort" HorizontalAlignment="Left" Height="20" Margin="60,34,0,0" TextWrapping="Wrap" Text="5985 " VerticalAlignment="Top" Width="120" ToolTip="What port do you want to connect to?" TabIndex="7"/>
                <Label x:Name="label4" Content="Authentication" HorizontalAlignment="Left" Margin="223,30,0,0" VerticalAlignment="Top" />
                <Label x:Name="label5" Content="Certificate Thumbprint" HorizontalAlignment="Left" Margin="71,-4,0,0" VerticalAlignment="Top" />
                <TextBox x:Name="textCertThumb" HorizontalAlignment="Left" Height="20" Margin="201,1,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="275" ToolTip="Enter the certificate thumbprint for SSL connections" TabIndex="6"/>
                <Label x:Name="label6" Content="Profile Script" HorizontalAlignment="Left" Margin="3,65,0,0" VerticalAlignment="Top" />
                <TextBox x:Name="textScript" HorizontalAlignment="Left" Height="20" Margin="86,65,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="310" ToolTip="Enter the path to a PowerShell script to be invoked remotely" TabIndex="9"/>
                <Button x:Name="btnBrowse" Content="Browse" HorizontalAlignment = "Left" Margin="405,65,0,0" VerticalAlignment="Top" Width="75" TabIndex="10"/>
                <CheckBox x:Name="checkScript" Content="Save script setting" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="5,95,0,0" TabIndex="11" ToolTip="Save the current script setting to `$ISERemoteProfile"/>
            </Grid>
        </GroupBox>
        <ComboBox x:Name="comboAuthentication" HorizontalAlignment="Left" Margin="336,190,0,0" VerticalAlignment="Top" Width="120" TabIndex="8">
            <ComboBoxItem Content="Default" IsSelected="True"/>
            <ComboBoxItem Content="Basic"/>
            <ComboBoxItem Content="Kerberos"/>
            <ComboBoxItem Content="CredSSP"/>
            <ComboBoxItem Content="Negotiate"/>
            <ComboBoxItem Content="NegotiatewithImpliedCredential"/>
            <ComboBoxItem Content="Digest"/>
        </ComboBox>
      </Grid>
</Window>
"@

  #create something to read the XAML
  $reader = New-Object system.xml.xmlnodereader $xaml

  #load the form XAML into the reader
  $form = [windows.markup.xamlreader]::Load($reader)

  #get elements

  #go through a list of form elements and create a variable using the name to
  #btnBrowse can be referenced as $btnBrowse
  'textComputername', 'textUserName', 'textConfiguration', 'textPort', 'textCertThumb',
  'textScript', 'textPassword', 'checkPromptCredential', 'checkSSL', 'comboAuthentication',
  'btnBrowse', 'checkScript', 'version', 'btnConnect', 'checkVM', 'labelCN' | ForEach-Object {
    Set-Variable -Name $_ -Value ($form.FindName($_))
  }

  #set the version label
  $version.content = "v$((Get-Module ISERemoteTab).Version.ToString())"
  #set remote script from variable if found
  if ($ISERemoteProfile -AND (Test-Path -Path $ISERemoteProfile)) {
    $textScript.Text = $ISERemoteProfile
  }

  $checkVM.Add_Checked( {
      $textPort.isEnabled = $false
      $checkSSL.IsEnabled = $false
      $comboAuthentication.IsEnabled = $false
      $textCertThumb.isEnabled = $False
      $labelCN.Content = "VMName"
      $textComputername.ToolTip = "Enter a single VM name."
    })

  $checkVM.Add_UnChecked( {
      $textPort.isEnabled = $True
      $checkSSL.IsEnabled = $True
      $comboAuthentication.IsEnabled = $True
      $textCertThumb.isEnabled = $True
      $labelCN.Content = "Computername"
      $textComputername.ToolTip = "Enter a computername or a comma separated list"
    })

  $checkPromptCredential.Add_Checked( {
      $textUserName.Clear()
      $textPassword.Clear()
      $textUserName.IsEnabled = $False
      $textPassword.IsEnabled = $False
    })

  $checkPromptCredential.Add_Unchecked( {
      $textUserName.IsEnabled = $True
      $textPassword.IsEnabled = $True
    })

  $btnBrowse.add_Click( {
      $dlg = New-Object Microsoft.Win32.OpenFileDialog
      $dlg.DefaultExt = ".ps1"
      $dlg.Filter = "PowerShell Scripts (*.ps1)|*.ps1"
      If ($dlg.ShowDialog()) {
        $textScript.text = $dlg.FileName
      }
    })

  $btnconnect.Add_Click( {

      #Throw an error if no computername
      if (-Not $textComputername.Text) {
        Write-Warning "You must enter a computername"
        #bail out
        Return
      }

      #uncomment for troubleshooting
      #Write-Host "Connecting to $($textComputername.Text)" -ForegroundColor Cyan

      if ($checkVM.IsChecked) {
        $nrtParams = @{
          VMName = $($textComputername.Text).Trim()
        }
      }
      else {
        $nrtParams = @{
          Computername = $($textComputername.Text).Trim() -split ","
          Port         = $textPort.Text.trim()
        }

        $nrtParams.Add("Authentication", $comboAuthentication.Text)

        if ($checkSSL.IsChecked) {
          $nrtParams.Add("UseSSL", $True)
        }

        if ($textCertThumb.Text) {
          $nrtParams.Add("CertificateThumbprint", $textCertThumb.Text.trim())
        }

      }

      if ($textConfiguration.text) {
        $nrtParams.Add("ConfigurationName", $textConfiguration.Text.trim())
      }

      If ($checkPromptCredential.IsChecked) {
        $nrtParams.Add("PromptForCredential", $True)
      }
      elseif ($textUsername.Text -AND $textPassword.Password) {
        #create a credential object
        $cred = New-Object System.Management.Automation.PSCredential $textUsername.Text, $textPassword.SecurePassword
        $nrtParams.Add("Credential", $cred)
      }

      if ($textScript.Text) {
        $nrtParams.Add("ProfileScript", $textScript.text)
      }

      #uncomment for troubleshooting
      #write-host ($nrtparams | out-string) -foregroundcolor yellow

      #invoke the new remote tab function
      New-ISERemoteTab @nrtParams

    }) #click

  #display the form
  [void]$checkVM.focus()

  [void]$form.showDialog()

  #save last script used to a global variable
  if ($checkScript.IsChecked) {
    $global:ISERemoteProfile = $textScript.text
  }

} #close function
