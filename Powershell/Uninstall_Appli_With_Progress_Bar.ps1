clear
#AUTEUR : WINTZ ENZO
#SCRIPT qui va supprimer java du poste + rejouer les stratégie SCCM pour enlencher la réinstallation de JAVA dans le centre logiciel
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
        
        <TextBlock x:Name="removeKey" HorizontalAlignment="Left" Height="23" Margin="10,120,0,0" VerticalAlignment="Top" Width="250" FontSize="12" FontWeight="Bold" >
            Suppression clé de registre
        </TextBlock>

        <TextBlock x:Name="Strategy" HorizontalAlignment="Left" Height="23" Margin="10,140,0,0" VerticalAlignment="Top" Width="250" FontSize="12" FontWeight="Bold" >
            Lancement des stratégies SCCM
        </TextBlock>
               
        <TextBlock x:Name="EndScript" HorizontalAlignment="Left" Height="23" Margin="10,160,0,0" TextWrapping="Wrap" Text="Fin du script" VerticalAlignment="Top" Width="111" FontSize="12" FontWeight="Bold"/>

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

$Global:ID = whoami    

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
   
    "<![LOG[$Message]LOG]!><time=$([char]34)$date+$($TimeZoneBias.bias)$([char]34) date=$([char]34)$date2$([char]34) component=$([char]34)$component$([char]34) context=$([char]34)$([char]34) type=$([char]34)$severity$([char]34) thread=$([char]34)$([char]34) file=$([char]34)$([char]34)>"| Out-File -FilePath "C:\windows\temp\$Global:ID-PurgeJava.Log" -Append -NoClobber -Encoding default            
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
$key = $(Get-ItemProperty -path registry::"HKEY_LOCAL_MACHINE\SOFTWARE\JRE" -ErrorAction SilentlyContinue).PSChildName 

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


if ($key)
    {
    write-log "Suppression de la cle de registre JAVA" -severity 2 -component "Registre"
    Remove-Item -Path registry::"HKEY_LOCAL_MACHINE\SOFTWARE\JRE" -Recurse

    Update-Window -Control removeKey -Property ForeGround -Value green                                                       
    start-sleep -Milliseconds 850
    update-window -Control ProgressBar -Property Value -Value 70
    }
else
    {
    Update-Window -Control removeKey -Property ForeGround -Value red                                                       
    start-sleep -Milliseconds 850
    update-window -Control ProgressBar -Property Value -Value 70
    write-log "Pas de clé de registre JAVA detecte" -severity 3 -component "Registre"
    }

write-log "Jeu des strategies SCCM`n" -severity 1 -component "MAJ POLICIES"

$machine = hostname
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
