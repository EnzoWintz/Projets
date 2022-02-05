#Auteur : WINTZ ENZO
#Suppression ou renommage d'un profil
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
        Title="Script de purge profil" Height="425" Width="525" WindowStartupLocation = "CenterScreen">
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

        <ProgressBar x:Name = "ProgressBar" Height = "20" Width = "400" HorizontalAlignment="Left" VerticalAlignment="top" Margin = "36,350,0,0"/>

        <TextBlock x:Name="recense_user_dir" HorizontalAlignment="Left" Height="23" Margin="10,70,0,0" VerticalAlignment="Top" Width="250" FontSize="12" FontWeight="Bold" >
            Vérification des dossiers utilisateurs
        </TextBlock>
        
        <TextBlock x:Name="verif_logon" HorizontalAlignment="Left" Height="23" Margin="10,90,0,0" VerticalAlignment="Top" Width="250" FontSize="12" FontWeight="Bold" >
            Profil sélectionné n'est pas l'actuel user
        </TextBlock>

        <TextBlock x:Name="Verif_symbolique" HorizontalAlignment="Left" Height="23" Margin="10,110,0,0" VerticalAlignment="Top" Width="250" FontSize="12" FontWeight="Bold" >
            Vérification lien symbolique
        </TextBlock>

        <TextBlock x:Name="Title1" HorizontalAlignment="Left" Height="23" Margin="10,130,0,0" VerticalAlignment="Top" Width="300" FontSize="12" FontWeight="Bold" >
            - - - - - - ACTION 1 - - - - - - 
        </TextBlock>

        
        <TextBlock x:Name="rename_old_yes" HorizontalAlignment="Left" Height="23" Margin="10,150,0,0" VerticalAlignment="Top" Width="250" FontSize="12" FontWeight="Bold" >
            Renommage du profil en .old
        </TextBlock>
        
        <TextBlock x:Name="delete_symbolic_link" HorizontalAlignment="Left" Height="23" Margin="10,170,0,0" VerticalAlignment="Top" Width="300" FontSize="12" FontWeight="Bold" >
            Suppression de la clé ProfileList
        </TextBlock>
        
        <TextBlock x:Name="delete_symbolic_link2" HorizontalAlignment="Left" Height="23" Margin="10,190,0,0" VerticalAlignment="Top" Width="300" FontSize="12" FontWeight="Bold" >
            Suppression de la clé ProfilGuid
        </TextBlock>

        <TextBlock x:Name="Title2" HorizontalAlignment="Left" Height="23" Margin="10,210,0,0" VerticalAlignment="Top" Width="300" FontSize="12" FontWeight="Bold" >
            - - - - - - ACTION 2 - - - - - - 
        </TextBlock>
        
        <TextBlock x:Name="Delete_profil" HorizontalAlignment="Left" Height="23" Margin="10,230,0,0" VerticalAlignment="Top" Width="300" FontSize="12" FontWeight="Bold" >
            Suppression du profil
        </TextBlock>

        <TextBlock x:Name="Title3" HorizontalAlignment="Left" Height="23" Margin="10,250,0,0" VerticalAlignment="Top" Width="300" FontSize="12" FontWeight="Bold" >
            - - - - - - ACTION 3 - - - - - - 
        </TextBlock>
        
        <TextBlock x:Name="delete_dir_profil" HorizontalAlignment="Left" Height="23" Margin="10,270,0,0" VerticalAlignment="Top" Width="300" FontSize="12" FontWeight="Bold" >
            Suppression du dossier de profil sélectionné
        </TextBlock>

        <TextBlock x:Name="Title4" HorizontalAlignment="Left" Height="23" Margin="10,290,0,0" VerticalAlignment="Top" Width="300" FontSize="12" FontWeight="Bold" >
            - - - - - - - - - - - - - 
        </TextBlock>
                
        <TextBlock x:Name="restart" HorizontalAlignment="Left" Height="23" Margin="10,310,0,0" VerticalAlignment="Top" Width="300" FontSize="12" FontWeight="Bold" >
            Redémarrage du poste
        </TextBlock>
        
               
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

#Fonction qui va copier le log d'utilisation dans le partage dédié afin de centraliser les logs
function Back_To_Share_Place {
$REPO_PARTAGE = "C:\temp\BDF_Tools\LOGS\SCRIPTS\WINDOWS\PURGE_PROFIL"
$LOCAL_LOG = "$Global:DIR_LOGS2\$env:COMPUTERNAME-$Global:ID-BDF_TOOLS-PurgeProfil.Log"
if (-not(test-path $REPO_PARTAGE))
    {
    write-log -Message "Partage non joignable, impossible de copier le log sur le partage centraliser" -severity 1 -component "Copie fichier de log"    
    }
else {
     Copy-Item -Path $LOCAL_LOG -Destination $REPO_PARTAGE
     }
}
#On rappatrie le log sur notre partage commun afin de simplifier le monitoring d'BDF_TOOLS
#Back_To_Share_Place

$Global:Date= Get-Date -Format "HH_mm"
#$PSEXEC = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, 'PsExec.exe'))
#$PSEXEC\PsExec.exe /accepteula -s cmd
#& "rd /S /Q C:\Users\TEST""

#FONCTIONS
Function write-log {            
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
   
    "<![LOG[$Message]LOG]!><time=$([char]34)$date+$($TimeZoneBias.bias)$([char]34) date=$([char]34)$date2$([char]34) component=$([char]34)$component$([char]34) context=$([char]34)$([char]34) type=$([char]34)$severity$([char]34) thread=$([char]34)$([char]34) file=$([char]34)$([char]34)>"| Out-File -FilePath "$Global:DIR_LOGS2\$env:COMPUTERNAME-$Global:ID-BDF_TOOLS-PurgeProfil.Log" -Append -NoClobber -Encoding default            
    } 

function Multithread_func {
   param (
   [Parameter(Mandatory=$true)]
    $NewMultiThreadCondition,
    $NewMultiThreadContent,
    $NewMultiThreadTitle,
    $NewMultiThreadStatus,
    $NewMultiThreadType,
    $NewMultiThreadScriptAction   
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

function Input_box {
   param (
   [Parameter(Mandatory=$true)]
    $Input_Box_Option,
    $InputBox_Content
   )
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


switch ($Input_Box_Option)
    {

        "OUINON" {
                    $form = New-Object System.Windows.Forms.Form
                    #$form.Text = $InputBox_Title
                    $form.Size = New-Object System.Drawing.Size(200,125)
                    $form.FormBorderStyle = "FixedSingle"
                    $form.MaximizeBox = $false
                    $form.MinimizeBox = $false;
                    $form.StartPosition = 'CenterScreen'

                    $okButton = New-Object System.Windows.Forms.Button
                    $okButton.Location = New-Object System.Drawing.Point(40,60)
                    $okButton.Size = New-Object System.Drawing.Size(45,23)
                    $okButton.Text = 'Oui'
                    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
                    $form.AcceptButton = $okButton
                    $form.Controls.Add($okButton)

                    $cancelButton = New-Object System.Windows.Forms.Button
                    $cancelButton.Location = New-Object System.Drawing.Point(110,60)
                    $cancelButton.Size = New-Object System.Drawing.Size(45,23)
                    $cancelButton.Text = 'Non'
                    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
                    $form.CancelButton = $cancelButton
                    $form.Controls.Add($cancelButton)

                    $label = New-Object System.Windows.Forms.Label
                    $label.Location = New-Object System.Drawing.Point(10,20)
                    $label.Size = New-Object System.Drawing.Size(180,100)
                    $label.Text = $InputBox_Content
                    $form.Controls.Add($label)

                    $form.Topmost = $true
                    

                    $Global:result_OUINON = $form.ShowDialog()

                        if ($Global:result_OUINON -eq [System.Windows.Forms.DialogResult]::OK)
                            {
                                $Global:OUINON = "OUI"
                                $Global:OUINON
                            }
                        else {

                        $Global:OUINON = "NON"
                        $Global:OUINON 
                        }

                }

}
}

function rename_folder {
Update-Window -Control Delete_profil -Property ForeGround -Value white
Update-Window -Control delete_dir_profil -Property ForeGround -Value white  
Update-Window -Control verif_logon -Property ForeGround -Value yellow                                                       
start-sleep -Milliseconds 850

if (-not(actual_logon))
    {
    Update-Window -Control verif_logon -Property ForeGround -Value green                                                       
    start-sleep -Milliseconds 850
    update-window -Control ProgressBar -Property Value -Value 20
    
    Update-Window -Control Verif_symbolique -Property ForeGround -Value yellow                                                       
    start-sleep -Milliseconds 850
    update-window -Control ProgressBar -Property Value -Value 25

        if ($Global:HKLM_User_ID)
            {
            Update-Window -Control Verif_symbolique -Property ForeGround -Value green                                                       
            start-sleep -Milliseconds 850
            update-window -Control ProgressBar -Property Value -Value 30
                

                Update-Window -Control rename_old_yes -Property ForeGround -Value yellow                                                       
                start-sleep -Milliseconds 850
                update-window -Control ProgressBar -Property Value -Value 32

                $Warn_Before_rename = [System.Windows.Forms.MessageBox]::Show("Voulez-vous renommer le profil $Global:Select_ID ?", "INFORMATION" , "YESNO", "ASTERISK")

                #Input_box -Input_Box_Option "OUINON" -InputBox_Content "Voulez-vous renommer le profil $Global:Select_ID ?" 

                       if ($Warn_Before_rename -eq "YES")
                            {
                               Update-Window -Control rename_old_yes -Property ForeGround -Value yellow                                                       
                               start-sleep -Milliseconds 850
                               update-window -Control ProgressBar -Property Value -Value 38
                               
                               #On renomme le dossier en .old
                               Rename-Item -Path "$localpath" -Newname "$localpath.old-$Global:Date" -Force

                               Update-Window -Control rename_old_yes -Property ForeGround -Value green                                                       
                               start-sleep -Milliseconds 850
                               update-window -Control ProgressBar -Property Value -Value 50

                               write-log "`nLe dossier $Global:localpath a ete renommer en $localpath.old-$Global:Date" -severity 2 -component "Renommage dossier profil utilisateur"
                               "`n"
                               $HKLM_ProfilList = $(Get-ItemProperty -path registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$Global:KEY_USER_ID_C_Lecteur").PSChildName
                                   
                               Update-Window -Control delete_symbolic_link -Property ForeGround -Value yellow                                                       
                               start-sleep -Milliseconds 850
                               update-window -Control ProgressBar -Property Value -Value 52
                   
                               if ($HKLM_ProfilList -match $Global:HKLM_User_ID)
                                    {
                                    write-log "`nMatch entre le SID du registre et celui attacher au dossier $localpath" -severity 1 -component "Match SID registre et SID dossier utilisateur"
                                    sleep -Milliseconds 500
                                    Remove-Item -Path registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$HKLM_ProfilList" -Recurse

                                    Update-Window -Control delete_symbolic_link -Property ForeGround -Value green                                                       
                                    start-sleep -Milliseconds 850
                                    update-window -Control ProgressBar -Property Value -Value 60

                                    write-log "`nSuppression de la cle ProfilList" -severity 2 -component "Suppression cle ProfilList"
                       
                                    #$HKLM_ProfilGuid = @()
                                    $HKLM_ProfilGuid_path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileGuid\" #| get-itemproperty | where-object {$_.SidString -match $HKLM_ProfilList}.SidString
                        
                                    $HKLM_ProfilGuid_item = @(get-childitem -path $HKLM_ProfilGuid_path | get-itemproperty) #| where-object {$_.SidString -match $HKLM_ProfilList}) 
                                    #$HKLM_ProfilGuid_item

                                    Update-Window -Control delete_symbolic_link2 -Property ForeGround -Value yellow                                                       
                                    start-sleep -Milliseconds 850
                                    update-window -Control ProgressBar -Property Value -Value 62

                                    foreach ($x in $HKLM_ProfilGuid_item)
                                        {
                                        #$($x | where-object {$_.SidString -cmatch $HKLM_ProfilList}).SidString
                                        if ($($x | where-object {$_.SidString -cmatch $HKLM_ProfilList}).SidString)
                                            {

                                            $Keys2Delete = $($x | where-object {$_.SidString -cmatch $HKLM_ProfilList}).PSChildName
                                            Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileGuid\$Keys2Delete" -Recurse

                                            write-log "`nSuppression de la cle ProfilGuid" -severity 2 -component "Suppression cle ProfilGuid"
                                            #$($x | where-object {$_.SidString -cmatch $HKLM_ProfilList}).SidString
                                            }                     

                                        }
                                    Update-Window -Control delete_symbolic_link2 -Property ForeGround -Value green                                                       
                                    start-sleep -Milliseconds 850
                                    update-window -Control ProgressBar -Property Value -Value 70

                                    }                
                  
                               write-log "`nProfil renommer,`nMerci de redemarrer le poste" -severity 2 -component "Redemarrage du poste"
                            restart_computer

                            }
                    else 
                        {
                        Update-Window -Control rename_old_yes -Property ForeGround -Value red                                                       
                        start-sleep -Milliseconds 850
                        Update-Window -Control delete_symbolic_link -Property ForeGround -Value red                                                       
                        Update-Window -Control delete_symbolic_link2 -Property ForeGround -Value red 
                        Update-Window -Control restart -Property ForeGround -Value red 
                        start-sleep -Milliseconds 850                                                     
                        update-window -Control ProgressBar -Property Value -Value 100
                        Back_To_Share_Place
                        }
            }
        else
            {
            Update-Window -Control Verif_symbolique -Property ForeGround -Value red
            Update-Window -Control rename_old_yes -Property ForeGround -Value red
            Update-Window -Control delete_symbolic_link -Property ForeGround -Value red
            Update-Window -Control delete_symbolic_link2 -Property ForeGround -Value red                                                         
            Update-Window -Control restart -Property ForeGround -Value red                                                        
            start-sleep -Milliseconds 850
            update-window -Control ProgressBar -Property Value -Value 100
            
            write-log -Message "Vous ne pouvez pas renommer le dossier, merci de faire l'action Nettoyage dossier résiduel si vous voulez le supprimer" -severity 2 -component "ren du dossier $Global:Select_ID"
            Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Vous ne pouvez pas supprimer le dossier, merci de faire l'action :`n`n- Nettoyage dossier résiduel" -NewMultiThreadTitle "Script de purge profil" -NewMultiThreadStatus "OK" -NewMultiThreadType "STOP"
            Back_To_Share_Place
            } 
    }
}

function delete_folder {
Update-Window -Control rename_old_yes -Property ForeGround -Value white
Update-Window -Control delete_symbolic_link -Property ForeGround -Value white
Update-Window -Control delete_symbolic_link2 -Property ForeGround -Value white
Update-Window -Control delete_dir_profil -Property ForeGround -Value white
 
Update-Window -Control verif_logon -Property ForeGround -Value yellow 
start-sleep -Milliseconds 850 
if (-not(actual_logon))
    {
    Update-Window -Control verif_logon -Property ForeGround -Value green                                                       
    start-sleep -Milliseconds 850
    update-window -Control ProgressBar -Property Value -Value 20

    Update-Window -Control Verif_symbolique -Property ForeGround -Value yellow                                                       
    start-sleep -Milliseconds 850
    update-window -Control ProgressBar -Property Value -Value 25
                                                              
    
        if ($Global:HKLM_User_ID)
            {
            Update-Window -Control Verif_symbolique -Property ForeGround -Value green                                                       
            start-sleep -Milliseconds 850
            update-window -Control ProgressBar -Property Value -Value 30

            Update-Window -Control Delete_profil -Property ForeGround -Value yellow                                                       
            start-sleep -Milliseconds 850
            update-window -Control ProgressBar -Property Value -Value 30

                $Warn_Before_delete = [System.Windows.Forms.MessageBox]::Show("Voulez-vous vraiment supprimer le profil $Global:Select_ID ?`n`nIl s'agit d'une action irrémédiable !`n`nAucune restaurations ne sera possible", "ATTENTION" , "YESNO", "WARNING")
                
                #Input_box -Input_Box_Option "OUINON" -InputBox_Content "Voulez-vous supprimer le profil $Global:Select_ID ?" 

                       if ($Warn_Before_delete -eq "YES")
                            {
                                Get-WmiObject -Class Win32_UserProfile | Where-Object {$_.LocalPath -eq $Global:localpath} | Remove-WmiObject             
                                write-log "`nProfil supprime,`nMerci de redemarrer le poste" -severity 2 -component "Redemarrage du poste"
                                
                                Update-Window -Control Delete_profil -Property ForeGround -Value green                                                       
                                start-sleep -Milliseconds 850
                                update-window -Control ProgressBar -Property Value -Value 80

                                restart_computer
                            }
                       else 
                            {
                                Update-Window -Control Delete_profil -Property ForeGround -Value red                                                       
                                start-sleep -Milliseconds 850
                                update-window -Control ProgressBar -Property Value -Value 80
                                Update-Window -Control restart -Property ForeGround -Value red 
                                start-sleep -Milliseconds 850
                                update-window -Control ProgressBar -Property Value -Value 100
                                Back_To_Share_Place
                            }
            }
        else
            {
            Update-Window -Control Verif_symbolique -Property ForeGround -Value red
            Update-Window -Control Delete_profil -Property ForeGround -Value red 
            Update-Window -Control restart -Property ForeGround -Value red                                                        
            start-sleep -Milliseconds 850
            update-window -Control ProgressBar -Property Value -Value 100

            write-log -Message "Vous ne pouvez pas supprimer le dossier, merci de faire l'action Nettoyage dossier résiduel" -severity 2 -component "Suppression du dossier $Global:Select_ID"
            Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Vous ne pouvez pas supprimer le dossier, merci de faire l'action :`n`n- Nettoyage dossier résiduel" -NewMultiThreadTitle "Script de purge profil" -NewMultiThreadStatus "OK" -NewMultiThreadType "STOP"
            Back_To_Share_Place
            } 
    }
}

function delete_dir {
Update-Window -Control rename_old_yes -Property ForeGround -Value white
Update-Window -Control delete_symbolic_link -Property ForeGround -Value white 
Update-Window -Control delete_symbolic_link2 -Property ForeGround -Value white
Update-Window -Control Delete_profil -Property ForeGround -Value white 

Update-Window -Control verif_logon -Property ForeGround -Value yellow
start-sleep -Milliseconds 850  
if (-not(actual_logon))
    {
    Update-Window -Control verif_logon -Property ForeGround -Value green                                                       
    start-sleep -Milliseconds 850
    update-window -Control ProgressBar -Property Value -Value 20

    Update-Window -Control Verif_symbolique -Property ForeGround -Value yellow                                                       
    start-sleep -Milliseconds 850
    update-window -Control ProgressBar -Property Value -Value 25

        if (-not($Global:HKLM_User_ID))
            {
            Update-Window -Control Verif_symbolique -Property ForeGround -Value green                                                       
            start-sleep -Milliseconds 850
            update-window -Control ProgressBar -Property Value -Value 30

            Update-Window -Control delete_dir_profil -Property ForeGround -Value yellow                                                       
            start-sleep -Milliseconds 850
            update-window -Control ProgressBar -Property Value -Value 40

                if (test-path $Global:localpath)
                    {
                    $Warn_Before_delete_dir = [System.Windows.Forms.MessageBox]::Show("Voulez-vous supprimer le dossier de profil $Global:Select_ID ?`n`nIl s'agit d'une action irrémédiable !`n`nAucune restaurations ne sera possible", "ATTENTION" , "YESNO", "WARNING")

                    #Input_box -Input_Box_Option "OUINON" -InputBox_Content "Voulez-vous supprimer le dossier de profil $Global:Select_ID ?" 

                           if ($Warn_Before_delete_dir -eq "YES")
                                {
                                Update-Window -Control delete_dir_profil -Property ForeGround -Value green                                                       
                                start-sleep -Milliseconds 850
                                update-window -Control ProgressBar -Property Value -Value 60

                                write-log -Message "Suppression du dossier $Global:Select_ID" -severity 2 -component "Suppression du dossier $Global:Select_ID"
                                cmd /c ""rd /S /Q $Global:localpath""
                                restart_computer
                                }
                           else 
                                {
                                Update-Window -Control delete_dir_profil -Property ForeGround -Value red 
                                Update-Window -Control restart -Property ForeGround -Value red
                                start-sleep -Milliseconds 850
                                update-window -Control ProgressBar -Property Value -Value 100
                                Back_To_Share_Place
                                }
                    }
                else 
                    {
                    write-log -Message "Le dossier n existe pas, il a peut-etre deja ete supprime" -severity 2 -component "Suppression du dossier $Global:Select_ID"
                    Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Le dossier n'existe pas, il a peut-être déjà été supprimé" -NewMultiThreadTitle "Script de purge profil" -NewMultiThreadStatus "OK" -NewMultiThreadType "STOP"
                    Back_To_Share_Place
                    }
            }
        else
            {
            Update-Window -Control Verif_symbolique -Property ForeGround -Value red
            Update-Window -Control delete_dir_profil -Property ForeGround -Value red
            Update-Window -Control restart -Property ForeGround -Value red 
            start-sleep -Milliseconds 850
            update-window -Control ProgressBar -Property Value -Value 100

            write-log -Message "Vous ne pouvez pas supprimer le dossier, merci de faire l'action Renommage ou Suppression" -severity 2 -component "Suppression du dossier $Global:Select_ID"
            Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Vous ne pouvez pas supprimer le dossier, merci de faire l'action :`n`n- Renommage`n`nou`n`n- Suppression" -NewMultiThreadTitle "Script de purge profil" -NewMultiThreadStatus "OK" -NewMultiThreadType "STOP"
            Back_To_Share_Place
            } 
    }
}

function restart_computer {
Update-Window -Control restart -Property ForeGround -Value yellow                                                       
start-sleep -Milliseconds 850
update-window -Control ProgressBar -Property Value -Value 75

$restart = Input_box -Input_Box_Option "OUINON" -InputBox_Content "Voulez-vous redemarrer le poste ?" 
if ($restart -ceq "OUI")
    {
    Update-Window -Control restart -Property ForeGround -Value green                                                       
    start-sleep -Milliseconds 850
    update-window -Control ProgressBar -Property Value -Value 100

    write-log "`nInitalisation du redemarrage du poste" -severity 2 -component "Initialisation du redemarrage"
    write-log -Message "-+-+-+-+-+-+-+-+Fin du script PurgeProfil+-+-+-+-+-+-+-+-+" -severity 1 -component "Purge Profil"
    Back_To_Share_Place
    Restart-Computer -Force
    }
else {
     Update-Window -Control restart -Property ForeGround -Value red                                                       
     start-sleep -Milliseconds 850
     update-window -Control ProgressBar -Property Value -Value 100
     write-log "Le redemarrage du poste a ete annuler" -severity 1 -component "Abandon du redemarrage"
     Back_To_Share_Place
     }
}

function actual_logon {

   if ($Global:Select_ID -eq $Global:ID)
        {
        Update-Window -Control verif_logon -Property ForeGround -Value red
        Update-Window -Control Verif_symbolique -Property ForeGround -Value red 
        Update-Window -Control restart -Property ForeGround -Value red                                                        
        start-sleep -Milliseconds 850
        update-window -Control ProgressBar -Property Value -Value 100
        write-log "Vous tentez de renommer un dossier ou l'utilisateur est actuellement connecte sur la machine" -severity 3 -component "User actuellement connecte"
        Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Vous tentez de renommer un dossier ou l'utilisateur est actuellement connecte sur la machine`n`nMerci de vous déconnecter de la session et de recommencer" -NewMultiThreadTitle "Script de purge profil" -NewMultiThreadStatus "OK" -NewMultiThreadType "STOP"
        Back_To_Share_Place
        return $true       
        }
}

#region XAML window definition
# Right-click XAML and choose WPF/Edit... to edit WPF Design
# in your favorite WPF editing tool
$xaml = @'
<Window
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
   xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
   MinWidth="200"
   Width ="460"
   SizeToContent="Height"
   Title="Script de suppression profil"
   Topmost="True">
   <Grid Margin="10,40,10,10">
      <Grid.ColumnDefinitions>
         <ColumnDefinition Width="Auto"/>
         <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>
      <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
      </Grid.RowDefinitions>
        <TextBlock Grid.Column="1" Margin="10">Profil(s) présents sur le poste :</TextBlock>
 
      <TextBlock Grid.Column="0" Grid.Row="1" Margin="5">ID :</TextBlock>
      <ComboBox Name="ComboService" Grid.Column="1" Grid.Row="1" Margin="5"></ComboBox>
       
      <StackPanel Orientation="Horizontal" HorizontalAlignment="center" VerticalAlignment="Bottom" Margin="0,10,0,0" Grid.Row="2" Grid.ColumnSpan="2">
        <Button Name="ButRename" MinWidth="80" Height="22" Margin="5">Renommage</Button>
        <Button Name="ButDelete" MinWidth="80" Height="22" Margin="5">Suppression</Button>
        <Button Name="ButDeleteDir" MinWidth="80" Height="22" Margin="5">Nettoyage dossier résiduel</Button>
        <Button Name="ButCancel" MinWidth="80" Height="22" Margin="5">Fermer</Button>
      </StackPanel>
   </Grid>
</Window>
'@

function Convert-XAMLtoWindow
{
   param
   (
    [Parameter(Mandatory)]
    [string]
    $XAML,

    [string[]]
    $NamedElement=$null,

    [switch]
    $PassThru
   )

   Add-Type -AssemblyName PresentationFramework

   $reader = [XML.XMLReader]::Create([System.IO.StringReader]$XAML)
   $result = [Windows.Markup.XAMLReader]::Load($reader)
   foreach($Name in $NamedElement)
   {
    $result | Add-Member NoteProperty -Name $Name -Value $result.FindName($Name) -Force
   }

   if ($PassThru)
   {
    $result
   }
   else
   {
    $null = $window.Dispatcher.InvokeAsync{
      $result = $window.ShowDialog()
      Set-Variable -Name result -Value $result -Scope 1
    }.Wait()
    $result
   }
}


function Show-WPFWindow
{
   param
   (
    [Parameter(Mandatory)]
    [Windows.Window]
    $Window
   )

   $result = $null
   $null = $window.Dispatcher.InvokeAsync{
    $result = $window.ShowDialog()
    Set-Variable -Name result -Value $result -Scope 1
   }.Wait()
   $result
}

#VARIABLES
$window = Convert-XAMLtoWindow -XAML $xaml -NamedElement 'ComboService','ButRename','ButDelete','ButDeleteDir','ButCancel' -PassThru
function Variable_universelles {
$Global:Select_ID = $null
$Global:Select_ID = $($window.ComboService.SelectedItem)
$Global:HKLM_User_ID = $(Get-WMIObject -class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq "$Global:Select_ID" }).SID
$Global:KEY_USER_ID_C_Lecteur = $null
$Global:localpath = ‘c:\users\’ + $Global:Select_ID
$Global:KEY_USER_ID_C_Lecteur = $(Get-WmiObject -Class Win32_UserProfile | Where-Object {$_.LocalPath -eq $localpath}).SID
}

# add click handlers
$window.ButRename.add_Click{
Variable_universelles
   if ($Global:Select_ID)
    { 
    #Fonction qui vérifie si l'utilisateur qu'on renomme n'est pas l'utilisateur connecté
    rename_folder
    }
   else 
    {
    Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Merci de choisir un profil à Renommer" -NewMultiThreadTitle "ACTION - Renommage" -NewMultiThreadStatus "OK" -NewMultiThreadType "STOP" 
    }

}


$window.ButDelete.add_Click{
Variable_universelles
#Action de réinstallation en fonction de la version disponible

   if ($Global:Select_ID)
    { 
    delete_folder       
    }
   else 
    {
    Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Merci de choisir un profil à supprimer" -NewMultiThreadTitle "ACTION - Suppression" -NewMultiThreadStatus "OK" -NewMultiThreadType "STOP" 
    }
}

$window.ButDeleteDir.add_Click{
Variable_universelles
#Action de réinstallation en fonction de la version disponible

   if ($Global:Select_ID)
    { 
    delete_dir
     #cmd /c "rd /S /Q $Global:Select_ID"      
    }
   else 
    {
    Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Merci de choisir un profil à supprimer" -NewMultiThreadTitle "ACTION - Suppression dossier" -NewMultiThreadStatus "OK" -NewMultiThreadType "STOP" 
    }
}


$window.ButCancel.add_Click{
   # close window
   $window.DialogResult = $false
}
    write-log -Message "-+-+-+-+-+-+-+-+Debut du script PurgeProfil+-+-+-+-+-+-+-+-+" -severity 1 -component "Purge Profil"

Update-Window -Control recense_user_dir -Property ForeGround -Value green                                                       
start-sleep -Milliseconds 850
update-window -Control ProgressBar -Property Value -Value 10

# fill the combobox with some powershell objects
#On initie HKLM_User_ID une valeur null au départ
$Show_Users = $null
$Show_Users_conforme = $null
$Show_Users_conforme = @()
$Show_Users = $(gci "C:\Users").Name

foreach ($username_conforme in $Show_Users)
    {
        if ($username_conforme -notlike "*default*" -and $username_conforme -notlike "*Public*")
            {
                $Show_Users_conforme += $username_conforme
            }      
    }

$window.ComboService.ItemsSource = @($Show_Users_conforme) 

    write-log -Message "-+-+-+-+-+-+-+-+Fin du script PurgeProfil+-+-+-+-+-+-+-+-+" -severity 1 -component "Purge Profil"

#Cette option affiche une version au départ qui s'affiche dans la liste box
#$window.ComboService.SelectedIndex = 1

Show-WPFWindow -Window $window
#endregion
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

