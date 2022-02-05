clear
#AUTEUR : WINTZ ENZO
#SCRIPT qui va supprimer java du poste + rejouer les stratégie SCCM pour enlencher la réinstallation de JAVA

$Global:syncHash = [hashtable]::Synchronized(@{})
$newRunspace =[runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash)

# Load WPF assembly if necessary
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

$psCmd = [PowerShell]::Create().AddScript({
    [xml]$xaml = @"
   <Window
            xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
            xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="Purge Java" Height="350" Width="525">
    <Grid Background="#68BFDD">
        <TextBlock x:Name="textBlock" HorizontalAlignment="center" Height="62" Margin="30" TextWrapping="Wrap" Text="Barre de progression" FontWeight="Bold" UseLayoutRounding="True" VerticalAlignment="Top" Width="200" Foreground="White" FontSize="18.667"/>
        <Button x:Name="button" Content="Exécuter" FontWeight="Bold" HorizontalAlignment="Left" Height="50" Margin="322,-60,0,0"  Width="114">
		    <Button.Effect>
				<DropShadowEffect BlurRadius="15" ShadowDepth="0"/>
			</Button.Effect>
			<Button.Resources>
				<Style TargetType="{x:Type Border}">
					<Setter Property="CornerRadius" Value="5"/>
					<Setter Property="Padding" Value="10,2,10,3"/>
					<Setter Property="Background" Value="White"/>
				</Style>
			</Button.Resources>			 
		</Button> 
        <Button x:Name="button2" Content="Fermer" FontWeight="Bold" HorizontalAlignment="Left" Height="50" Margin="322,100,0,0"  Width="114"  Style="{DynamicResource RoundCorner}" IsCancel="True"  Command="{Binding CloseWindowCommand, Mode=OneWay}" CommandParameter="{Binding ElementName=TestWindow}">
		    <Button.Effect>
				<DropShadowEffect BlurRadius="15" ShadowDepth="0"/>
			</Button.Effect>
			<Button.Resources>
				<Style TargetType="{x:Type Border}">
					<Setter Property="CornerRadius" Value="5"/>
					<Setter Property="Padding" Value="10,2,10,3"/>
					<Setter Property="Background" Value="White"/>
				</Style>
			</Button.Resources>			 
		</Button> 

        <ProgressBar x:Name = "ProgressBar" Height = "20" Width = "400" HorizontalAlignment="Left" VerticalAlignment="Top" Margin = "36,270,0,0"/>

        <TextBlock x:Name="verif_java_exist" HorizontalAlignment="Left" Height="23" Margin="10,80,0,0" VerticalAlignment="Top" Width="250" FontSize="12" FontWeight="Bold" >
            Vérification  présence de Java
        </TextBlock>
        
        <TextBlock x:Name="uninstall_java" HorizontalAlignment="Left" Height="23" Margin="10,100,0,0" VerticalAlignment="Top" Width="250" FontSize="12" FontWeight="Bold" >
            Désinstallation de Java
        </TextBlock>
        
        <TextBlock x:Name="Strategy" HorizontalAlignment="Left" Height="23" Margin="10,120,0,0" VerticalAlignment="Top" Width="250" FontSize="12" FontWeight="Bold" >
            Lancement des stratégies SCCM
        </TextBlock>
               
        <TextBlock x:Name="EndScript" HorizontalAlignment="Left" Height="23" Margin="10,140,0,0" TextWrapping="Wrap" Text="Fin du script" VerticalAlignment="Top" Width="111" FontSize="12" FontWeight="Bold"/>

    </Grid>
</Window>
"@

    # Remove XML attributes that break a couple things.
    #   Without this, you must manually remove the attributes
    #   after pasting from Visual Studio. If more attributes
    #   need to be removed automatically, add them below.
    $AttributesToRemove = @(
        'x:Class',
        'mc:Ignorable'
    )

    foreach ($Attrib in $AttributesToRemove) {
        if ( $xaml.Window.GetAttribute($Attrib) ) {
             $xaml.Window.RemoveAttribute($Attrib)
        }
    }
    
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    
    $syncHash.Window=[Windows.Markup.XamlReader]::Load( $reader )

    [xml]$XAML = $xaml
        $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | %{
        #Find all of the form types and add them as members to the synchash
        $syncHash.Add($_.Name,$syncHash.Window.FindName($_.Name) )

    }

    $Script:JobCleanup = [hashtable]::Synchronized(@{})
    $Script:Jobs = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList))

    #region Background runspace to clean up jobs
    $jobCleanup.Flag = $True
    $newRunspace =[runspacefactory]::CreateRunspace()
    $newRunspace.ApartmentState = "STA"
    $newRunspace.ThreadOptions = "ReuseThread"          
    $newRunspace.Open()        
    $newRunspace.SessionStateProxy.SetVariable("jobCleanup",$jobCleanup)     
    $newRunspace.SessionStateProxy.SetVariable("jobs",$jobs) 
    $jobCleanup.PowerShell = [PowerShell]::Create().AddScript({
        #Routine to handle completed runspaces
        Do {    
            Foreach($runspace in $jobs) {            
                If ($runspace.Runspace.isCompleted) {
                    [void]$runspace.powershell.EndInvoke($runspace.Runspace)
                    $runspace.powershell.dispose()
                    $runspace.Runspace = $null
                    $runspace.powershell = $null               
                } 
            }
            #Clean out unused runspace jobs
            $temphash = $jobs.clone()
            $temphash | Where {
                $_.runspace -eq $Null
            } | ForEach {
                $jobs.remove($_)
            }        
            Start-Sleep -Seconds 1     
        } while ($jobCleanup.Flag)
    })
    $jobCleanup.PowerShell.Runspace = $newRunspace
    $jobCleanup.Thread = $jobCleanup.PowerShell.BeginInvoke()  
    #endregion Background runspace to clean up jobs

    $syncHash.button.Add_Click({
        #Start-Job -Name Sleeping -ScriptBlock {start-sleep 5}
        #while ((Get-Job Sleeping).State -eq 'Running'){
            $x+= "."
        #region Boe's Additions
        $newRunspace =[runspacefactory]::CreateRunspace()
        $newRunspace.ApartmentState = "STA"
        $newRunspace.ThreadOptions = "ReuseThread"          
        $newRunspace.Open()
        $newRunspace.SessionStateProxy.SetVariable("SyncHash",$SyncHash) 
        $PowerShell = [PowerShell]::Create().AddScript({
Function Update-Window {
        Param (
            $Control,
            $Property,
            $Value,
            [switch]$AppendContent
        )

        # This is kind of a hack, there may be a better way to do this
        If ($Property -eq "Close") {
            $syncHash.Window.Dispatcher.invoke([action]{$syncHash.Window.Close()},"Normal")
            Return
        }

        # This updates the control based on the parameters passed to the function
        $syncHash.$Control.Dispatcher.Invoke([action]{
            # This bit is only really meaningful for the TextBox control, which might be useful for logging progress steps
            If ($PSBoundParameters['AppendContent']) {
                $syncHash.$Control.AppendText($Value)
            } Else {
                $syncHash.$Control.$Property = $Value
            }
        }, "Normal")
    }

Function Get-PSWho {
  <#
  .SYNOPSIS
  Get PowerShell user summary information
  
  .DESCRIPTION
  This command will provide a summary of relevant information for the current 
  user in a PowerShell session. You might use this to troubleshoot an end-user
  problem running a script or command. The default behavior is to write an 
  object to the pipeline, but you can use the -AsString parameter to force the
  command to write a string. This makes it easier to use in your scripts with
  Write-Verbose.
  
  .PARAMETER AsString
  Write the summary object as a string.
  
  .EXAMPLE
  PS C:\> Get-PSWho

  User            : BOVINE320\Jeff
  Elevated        : True
  Computername    : BOVINE320
  OperatingSystem : Microsoft Windows 10 Pro [64-bit]
  OSVersion       : 10.0.16299
  PSVersion       : 5.1.16299.64
  Edition         : Desktop
  PSHost          : ConsoleHost
  WSMan           : 3.0
  ExecutionPolicy : RemoteSigned
  Culture         : en-US

  .EXAMPLE
  PS /mnt/c/scripts> get-pswho


  User            : jhicks
  Elevated        : NA
  Computername    : Bovine320
  OperatingSystem : Linux 4.4.0-43-Microsoft #1-Microsoft Wed Dec 31 14:42:53 PST 2014
  OSVersion       : Ubuntu 16.04.3 LTS
  PSVersion       : 6.0.0-rc
  Edition         : Core
  PSHost          : ConsoleHost
  WSMan           : 3.0
  ExecutionPolicy : Unrestricted
  Culture         : en-US

  .EXAMPLE
  PS C:\Program Files\PowerShell\6.0.0-rc> get-pswho


  User            : BOVINE320\Jeff
  Elevated        : True
  Computername    : BOVINE320
  OperatingSystem : Microsoft Windows 10 Pro [64-bit]
  OSVersion       : 10.0.16299
  PSVersion       : 6.0.0-rc
  Edition         : Core
  PSHost          : ConsoleHost
  WSMan           : 3.0
  ExecutionPolicy : RemoteSigned
  Culture         : en-US

  .EXAMPLE
  PS C:\> Get-PSWho -asString | Set-Content c:\test\who.txt

  .NOTES
  Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

   .INPUTS
   none

   .OUTPUTS
   [pscustomboject]
   [string]
  
   .LINK
  Get-CimInstance
  .LINK
  Get-ExecutionPolicy
  .LINK
  $PSVersionTable
  .LINK
  $Host
  #>
    [CmdletBinding()]
    Param(
      [switch]$AsString
    )

if ($PSVersionTable.PSEdition -eq "desktop" -OR $PSVersionTable.OS -match "Windows") {
      
        #get some basic information about the operating system
        $cimos = Get-CimInstance win32_operatingsystem -Property Caption, Version,OSArchitecture
        $os = "$($cimos.Caption) [$($cimos.OSArchitecture)]"
        $osver = $cimos.Version

        #determine the current user so we can test if the user is running in an elevated session
        $current = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal]$current
        $Elevated = $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
        $user = $current.Name
        $computer = $env:COMPUTERNAME
    }
    else {
     #non-Windows values
      $os = $PSVersionTable.OS
      $lsb = lsb_release -d
      $osver =   ($lsb -split ":")[1].Trim()
      $elevated = "NA"
      $user = $env:USER
      $computer = $env:NAME
    }


    #object properties will be displayed in the order they are listed here
    $who = [pscustomObject]@{ 
        User            = $user
        Elevated        = $elevated
        Computername    = $computer
        OperatingSystem = $os
        OSVersion       = $osver
        PSVersion       = $PSVersionTable.PSVersion.ToString()
        Edition         = $PSVersionTable.PSEdition
        PSHost          = $host.Name
        WSMan           = $PSVersionTable.WSManStackVersion.ToString()
        ExecutionPolicy = (Get-ExecutionPolicy)
        Culture         = $host.CurrentCulture
    }

    if ($AsString) {
      $who | Out-String
    }
    else {
      $who
    }
}

$Global:x = @((Get-PSWho).user) 
$Global:ID = ($Global:x.Split("\",7))[1]

function create_repo_logs {
$Global:DIR_LOGS = "$Global:Dir_base"
$Global:DIR_LOGS2 = "$Global:Dir_base\LOGS"
$All_Dirs= @($Global:DIR_LOGS,$Global:DIR_LOGS2)

foreach ($Directorys in $All_Dirs)
    {
    if (-not(test-path $Directorys))
        {
        New-Item -Path $Directorys -ItemType Directory 
        }
    }
}

#On vérifie que notre dossier de logs existe
create_repo_logs

Function write-log{            
##----------------------------------------------------------------------------------------------------            
##  Function: Write-Log            
##  Purpose: This function writes trace32 log fromat file to user desktop      
##  Function by: Kaido JÃƒÂ¤rvemets Configuration Manager MVP (http://www.cm12sdk.net)
##----------------------------------------------------------------------------------------------------                            
PARAM(                     
    [String]$Message,                                  
    [int]$severity,                     
    [string]$component                     
    )                                          
    $TimeZoneBias = Get-WmiObject -Query "Select Bias from Win32_TimeZone"                     
    $Date= Get-Date -Format "HH:mm:ss.fff"                     
    $Date2= Get-Date -Format "MM-dd-yyyy"                     
    $type=1                         
   
    "<![LOG[$Message]LOG]!><time=$([char]34)$date+$($TimeZoneBias.bias)$([char]34) date=$([char]34)$date2$([char]34) component=$([char]34)$component$([char]34) context=$([char]34)$([char]34) type=$([char]34)$severity$([char]34) thread=$([char]34)$([char]34) file=$([char]34)$([char]34)>"| Out-File -FilePath "$Global:DIR_LOGS2\$env:COMPUTERNAME-$Global:ID-BDF_TOOLS-PurgeJava.Log" -Append -NoClobber -Encoding default            
    } 

#Fonction multithread qui permettra d'améliorer les performances de traitements
function Multithread_func {
   param (
   [Parameter(Mandatory=$true)]
    $NewMultiThreadCondition,
    $NewMultiThreadContent,
    $NewMultiThreadTitle,
    $NewMultiThreadStatus,
    $NewMultiThreadType  
   )

switch ($NewMultiThreadCondition)
    {
        "MSG_BOX" {
            $syncHash = [hashtable]::Synchronized(@{})
            $syncHash.Add("Content", $NewMultiThreadContent)
            $syncHash.Add("Title", $NewMultiThreadTitle)
            $syncHash.Add("Status", $NewMultiThreadStatus)
            $syncHash.Add("Type", $NewMultiThreadType)
            $newRunspace =[runspacefactory]::CreateRunspace()
            $newRunspace.ApartmentState = "STA"
            $newRunspace.ThreadOptions = "ReuseThread"         
            $newRunspace.Open()
            $newRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash)          
            $psCmd = [PowerShell]::Create().AddScript({[System.Windows.Forms.MessageBox]::Show($syncHash.Content,$syncHash.Title,$syncHash.Status,$syncHash.Type)})
            $psCmd.Runspace = $newRunspace
            $data = $psCmd.BeginInvoke()
        }

       
        default {"KO"}         
    }

}

write-log -Message "-+-+-+-+-+-+-+-+Debut du script PurgeJava+-+-+-+-+-+-+-+-+" -severity 1 -component "Purge JAVA"

$AllJava = $null
$AllJava = @() 
$AllJava = Get-Package | Where-Object {$_.Name -like "*Java*"} -ErrorAction SilentlyContinue

if ($AllJava)
{
Update-Window -Control verif_java_exist -Property ForeGround -Value green                                                       
start-sleep -Milliseconds 850
update-window -Control ProgressBar -Property Value -Value 10

Update-Window -Control uninstall_java -Property ForeGround -Value yellow                                                       
start-sleep -Milliseconds 850
update-window -Control ProgressBar -Property Value -Value 30

write-log "$($AllJava.Count) versions de Java ont ete detectes" -severity 2 -component "Purge JAVA"
foreach ($x in $AllJava)
    {

    write-log "Version de java détecter : $($x.Name)" -severity 2 -component "Purge JAVA"

    $uninstall32 = gci "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "$($x.Name)" } | select UninstallString
    $uninstall64 = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "$($x.Name)" } | select UninstallString

    if ($uninstall64) {
    $uninstall64 = $uninstall64.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
    $uninstall64 = $uninstall64.Trim()

    write-log "Desinstallation version 64 bits..." -severity 2 -component "Purge JAVA"

    start-process "msiexec.exe" -arg "/X $uninstall64 /qb" -Wait
    }

    if ($uninstall32) {
    $uninstall32 = $uninstall32.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
    $uninstall32 = $uninstall32.Trim()

    write-log "Desinstallation version 32 bits..." -severity 2 -component "Purge JAVA"

    start-process "msiexec.exe" -arg "/X $uninstall32 /qb" -Wait
    }

    }

Update-Window -Control uninstall_java -Property ForeGround -Value green                                                       
start-sleep -Milliseconds 850
update-window -Control ProgressBar -Property Value -Value 60

}

else 
    {
    Update-Window -Control verif_java_exist -Property ForeGround -Value red                                                       
    start-sleep -Milliseconds 850
    update-window -Control ProgressBar -Property Value -Value 10

    Update-Window -Control uninstall_java -Property ForeGround -Value red                                                       
    start-sleep -Milliseconds 850
    update-window -Control ProgressBar -Property Value -Value 60
    write-log "Pas de version de Java détecté" -severity 3 -component "Purge JAVA"

    }


write-log "Jeu des strategies SCCM`n" -severity 1 -component "MAJ POLICIES"

$machine = $env:COMPUTERNAME
#Lancement du HeartBeat
$HearBeat = '{00000000-0000-0000-0000-000000000003}'|% {Invoke-WMIMethod -ComputerName $machine -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule $_} -ErrorAction SilentlyContinue

#On lance le Heartbeat, si c'est OK il fera les autres actions sinon il se stoppera
if ($HearBeat)
    {
    Update-Window -Control Strategy -Property ForeGround -Value yellow                                                       
    start-sleep -Milliseconds 850
    update-window -Control ProgressBar -Property Value -Value 70
                                                    
    start-sleep -Milliseconds 850
    
    #Le log se trouve dans "C:\Windows\CCM\Logs\InventoryAgent.log"
    write-log "Hearbeat OK" -severity 2 -component "MAJ POLICIES"

    #Stratégie ordinateur + cycle d'évaluation
    sleep -Milliseconds 500
    #Les logs se trouvent dans "C:\Windows\CCM\Logs\PolicyAgent.log" et "C:\Windows\CCM\Logs\PolicyEvaluator.log"
    '{00000000-0000-0000-0000-000000000021}','{00000000-0000-0000-0000-000000000022}'|% {Invoke-WMIMethod -ComputerName $machine -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule $_} | Out-Null
    write-log "Recuperation de strategie ordinateur et cycle d'evaluation" -severity 2 -component "MAJ POLICIES"
       
    #MAJ logiciels
    sleep -Milliseconds 500
    #Le log se trouve dans "C:\Windows\CCM\Logs\UpdatesDeployment.log"
    '{00000000-0000-0000-0000-000000000108}'|% {Invoke-WMIMethod -ComputerName $machine -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule $_} | Out-Null
    write-log "Cycle d'evaluation des deploiements de mises a jours logiciels" -severity 2 -component "MAJ POLICIES"
        
    #Lancement policies Déploiement applications
    sleep -Milliseconds 500
    #Le log se trouve dans "C:\Windows\CCM\Logs\AppIntentEval.log"
    '{00000000-0000-0000-0000-000000000121}'|% {Invoke-WMIMethod -ComputerName $machine -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule $_} | Out-Null
    write-log "Cycle d'evaluation du deploiement de l'application" -severity 2 -component "MAJ POLICIES"

    Update-Window -Control Strategy -Property ForeGround -Value green                                                       
    start-sleep -Milliseconds 850
    update-window -Control ProgressBar -Property Value -Value 95
    
    }
else 
{
Update-Window -Control Strategy -Property ForeGround -Value red                                                       
start-sleep -Milliseconds 850
update-window -Control ProgressBar -Property Value -Value 95

write-log "Heartbeat négatif" -severity 3 -component "Purge JAVA"
write-log "Merci de reinstaller le client SCCM" -severity 3 -component "Purge JAVA"
}
                          
Update-Window -Control EndScript -Property ForeGround -Value green                                                       
start-sleep -Milliseconds 200
update-window -Control ProgressBar -Property Value -Value 100

Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Merci d'attendre quelques minutes et de redémarrer le centre logiciel pour pouvoir réinstaller Java" -NewMultiThreadTitle "Script Purge Java" -NewMultiThreadStatus "OK" -NewMultiThreadType "Asterisk"

write-log -Message "-+-+-+-+-+-+-+-+Fin du script PurgeJava+-+-+-+-+-+-+-+-+" -severity 1 -component "Purge JAVA"

#Fonction qui va copier le log d'utilisation dans le partage dédié afin de centraliser les logs
function Back_To_Share_Place {
$REPO_PARTAGE = "C:\temp\BDF_Tools\LOGS\SCRIPTS\APPLICATIONS\JRE"
$LOCAL_LOG = "$Global:DIR_LOGS2\$env:COMPUTERNAME-$Global:ID-BDF_TOOLS-PurgeJava.Log"
if (-not(test-path $REPO_PARTAGE))
    {
    write-log -Message "Partage non joignable, impossible de copier le log sur le partage centraliser" -severity 1 -component "Copie fichier de log"    
    }
else {
     Copy-Item -Path $LOCAL_LOG -Destination $REPO_PARTAGE
     }
}
#On rappatrie le log sur notre partage commun afin de simplifier le monitoring d'BDF_TOOLS
Back_To_Share_Place

        })
        $PowerShell.Runspace = $newRunspace
        [void]$Jobs.Add((
            [pscustomobject]@{
                PowerShell = $PowerShell
                Runspace = $PowerShell.BeginInvoke()
            }
        ))
    })

    #region Window Close 
    $syncHash.Window.Add_Closed({
        Write-Verbose 'Halt runspace cleanup job processing'
        $jobCleanup.Flag = $False

        #Stop all runspaces
        $jobCleanup.PowerShell.Dispose()      
    })
    #endregion Window Close 
    #endregion Boe's Additions

    #$x.Host.Runspace.Events.GenerateEvent( "TestClicked", $x.test, $null, "test event")

    #$syncHash.Window.Activate()
    $syncHash.Window.ShowDialog() | Out-Null
    $syncHash.Error = $Error
})
$psCmd.Runspace = $newRunspace
$data = $psCmd.BeginInvoke()
