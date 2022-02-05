################################
#                              #
#       Script pour BDF_TOOLS  #
#                              #
#     AUTEUR : WINTZ ENZO      #
#                              #
################################
clear

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
        Title="Copie des données utilisateurs vers C:\BDF_Tools" Height="350" Width="525">
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

        <TextBlock x:Name="createdir" HorizontalAlignment="Left" Height="23" Margin="10,100,0,0" VerticalAlignment="Top" Width="250" FontSize="12" FontWeight="Bold" >
            Création du dossier de sauvegarde
        </TextBlock>
        
        <TextBlock x:Name="startcopy" HorizontalAlignment="Left" Height="23" Margin="10,120,0,0" VerticalAlignment="Top" Width="280" FontSize="12" FontWeight="Bold" >
            Initialisation de la copie des données utilisateurs
        </TextBlock>
                
        <TextBlock x:Name="endcopy" HorizontalAlignment="Left" Height="23" Margin="10,140,0,0" VerticalAlignment="Top" Width="280" FontSize="12" FontWeight="Bold" >
            Fin de la copie des données utilisateurs
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
#On récupère le ID de l'utilisateur qui exécute le script
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
   
    "<![LOG[$Message]LOG]!><time=$([char]34)$date+$($TimeZoneBias.bias)$([char]34) date=$([char]34)$date2$([char]34) component=$([char]34)$component$([char]34) context=$([char]34)$([char]34) type=$([char]34)$severity$([char]34) thread=$([char]34)$([char]34) file=$([char]34)$([char]34)>"| Out-File -FilePath "$Global:DIR_LOGS2\$env:COMPUTERNAME-$Global:ID-BDF_TOOLS-Copie_Data_2_C_BDF_Tools.Log" -Append -NoClobber -Encoding default            
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


write-log -Message "-+-+-+-+-+-+-+-+Debut du script Copie2CTempBDF_Tools+-+-+-+-+-+-+-+-+" -severity 1 -component "Sauvegarde donnees"

#Création du dossier Sauvegarde.ID.$D.$D2 dans le C:\Temp\BDF_Tools
#Ces variables seront utilisés dans le nommage des Logs et du fichier une fois le script joué, il pourra créer autant de fichier qu'il le souhaitera
                 
$D= Get-Date -Format "HHmm"                     
$D2= Get-Date -Format "ddMMyyyy"
$Name_directory_save = "Sauvegarde.$Global:ID-$D2_$D"
$Dest_directory_save = "C:\Temp\BDF_Tools\$Name_directory_save"

#Multithread_func -NewMultiThreadCondition "MSG_BOX"  -NewMultiThreadContent "Création du dossier $Name_directory_save dans `nC:\BDF_Tools" -NewMultiThreadTitle "Information" -NewMultiThreadStatus "OK" -NewMultiThreadType "Asterisk"

Update-Window -Control createdir -Property ForeGround -Value green                                                       
start-sleep -Milliseconds 850
update-window -Control ProgressBar -Property Value -Value 10

#write-host "Creation du dossier Sauvegarde.$Global:ID.$D2.$D dans C:\BDF_Tools `n " -foregroundcolor yellow

New-Item -Path $Dest_directory_save -ItemType "directory" | Out-Null 

Write-Log -Message "Creation du dossier $Name_directory_save"  -severity 2 

####Début de copie des datas user pour chaque dossiers renseignés dans $DataUser##### 
$DataUser= @("Desktop","Documents","Pictures", "Privé")

Update-Window -Control startcopy -Property ForeGround -Value green                                                       
start-sleep -Milliseconds 850
update-window -Control ProgressBar -Property Value -Value 40

foreach ($Data in $DataUser)
{

    if ( (Get-ChildItem C:\Users\$Global:ID\$Data\ | Measure-Object).Count -eq 0)

    {

#Multithread_func -NewMultiThreadCondition "MSG_BOX"  -NewMultiThreadContent "Le dossier $Data est vide, il ne sera pas copie dans $Dest_directory_save" -NewMultiThreadTitle "Information" -NewMultiThreadStatus "OK" -NewMultiThreadType "Asterisk"
   
     Write-Log -Message "****************Le dossier $Data est vide, Traitement suivant**************"  -severity 1
     
     break
    }

    if (-not (Test-path "$Dest_directory_save\$Data")) 
    {
        New-Item -Path "$Dest_directory_save\$Data" -ItemType "directory" | Out-Null

        Write-Log -Message "Creation du dossier $Data `n"  -severity 3
       
    }

#[System.Windows.Forms.MessageBox]::Show("Copie de $Data du $Global:ID $x ?" , "INFORMATION",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Asterisk)

    #write-host "Copie de $Data du $Global:ID `n" -foregroundcolor yellow

    Copy-Item  -Path "C:\Users\$Global:ID\$Data\*" -Destination "$Dest_directory_save\$Data" -Recurse 
    
    Write-Log -Message "---------------------Copie des donnees present dans $Data vers $Dest_directory_save\$Data---------------------"  -severity 1
    
}

Update-Window -Control endcopy -Property ForeGround -Value green                                                       
start-sleep -Milliseconds 850
update-window -Control ProgressBar -Property Value -Value 80

Update-Window -Control EndScript -Property ForeGround -Value green                                                       
start-sleep -Milliseconds 200
update-window -Control ProgressBar -Property Value -Value 100

#Multithread_func -NewMultiThreadCondition "MSG_BOX"  -NewMultiThreadContent "Fin du script" -NewMultiThreadTitle "Information" -NewMultiThreadStatus "OK" -NewMultiThreadType "Asterisk"

write-log -Message "-+-+-+-+-+-+-+-+Fin du script Copie2CTempBDF_Tools+-+-+-+-+-+-+-+-+" -severity 1 -component "Sauvegarde donnees"

#Fonction qui va copier le log d'utilisation dans le partage dédié afin de centraliser les logs
function Back_To_Share_Place {
$REPO_PARTAGE = "C:\temp\BDF_Tools\LOGS\SCRIPTS\WINDOWS\COPY_DONNEE_TO_C_TEMP_BDF_Tools"
$LOCAL_LOG = "$Global:DIR_LOGS2\$env:COMPUTERNAME-$Global:ID-BDF_TOOLS-Copie_Data_2_C_BDF_Tools.Log"
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

