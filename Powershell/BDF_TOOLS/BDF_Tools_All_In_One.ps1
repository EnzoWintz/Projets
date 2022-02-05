clear
################################
#                              #
#        Script BDF Tools      #
#                              #
#     AUTEUR : WINTZ ENZO      #
#                              #
################################
#PS : Les informations ont été anonymiser pour des raisons de sécurités.
#Auteur : WINTZ ENZO

Add-Type -AssemblyName System.Windows.Forms

# Get full path to the script:
$ScriptRoute = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, 'assembly\RadialMenu.dll'))
$XamlRoute = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, 'BDF_Tools_All_In_One.xaml'))

[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null
[System.Reflection.Assembly]::LoadFrom("$ScriptRoute") | out-null  

$wksname=$env:computername #Nom du poste

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

#Variable pour récupérer l'ID de l'utilisateur
$Global:x = @((Get-PSWho).user) 
$Global:ID = ($Global:x.Split("\",7))[1]

#On récupère la date
$Global:D= Get-Date -Format "HH:mm"                     
$Global:D2= Get-Date -Format "dd-MM-yyyy"
$Global:D_bis= Get-Date -Format "HHmm"

$Global:User_And_D = "$Global:ID-$Global:D_bis-$Global:D2"

#Fonction multithread qui permettra d'améliorer les performances de l'interface graphique
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

        "SCRIPT" {
            
            
            $syncHash = [hashtable]::Synchronized(@{})
            $syncHash.Add("script", $NewMultiThreadScriptAction)
            $newRunspace =[runspacefactory]::CreateRunspace()
            $newRunspace.ApartmentState = "STA"
            $newRunspace.ThreadOptions = "ReuseThread"         
            $newRunspace.Open()
            $newRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash)          
            $psCmd = [PowerShell]::Create().AddScript({
                foreach ($row in $syncHash.script)
                    {
                    & $row
                    sleep 20
                    }            
                })
            $psCmd.Runspace = $newRunspace
            $data = $psCmd.BeginInvoke()
        }
        
        default {"KO"}         
    }

}

#Exemple utilisation de la fonction de multithread
#Multithread_func -NewMultiThreadCondition "MSG_BOX"  -NewMultiThreadContent "ceci est une fenêtre test enzo" -NewMultiThreadTitle "Information" -NewMultiThreadStatus "OKCANCEL" -NewMultiThreadType "warning"
#Multithread_func -NewMultiThreadCondition "SCRIPT" -NewMultiThreadScriptAction ""

#On vérifie l'existence du dossier de Logs ou sera centralisé l'ensemble des actions liées à BDF_Tools
function create_repo_logs {
$Global:Dir_base = "C:\Temp\BDF_Tools"    
$Global:DIR_LOGS = "$Global:Dir_base"
$Global:DIR_LOGS2 = "$Global:Dir_base\LOGS"
$Global:WHO_LAUNCH = "$Global:DIR_LOGS2\WHO_LAUNCH"
$Global:ERRORS = "$Global:DIR_LOGS2\ERRORS"
$Global:REPO_PARTAGE = "$Global:DIR_LOGS\REPO_PARTAGE"
$Global:SCRIPTS = "$Global:DIR_LOGS2\SCRIPTS\"
#Catégorie Application
$Global:APPLICATIONS = "$Global:SCRIPTS\APPLICATIONS"
$Global:APPLICATIONS_JRE = "$Global:APPLICATIONS\JRE"
#Catégorie SCCM
$Global:SCCM = "$Global:SCRIPTS\SCCM"
$Global:SCCM_MAJ_POLICIES = "$Global:SCCM\MAJ_POLICIES"
$Global:SCCM_PURGE_CCMCACHE = "$Global:SCCM\PURGE_CCMCACHE"
#Catégorie Windows
$Global:WINDOWS = "$Global:SCRIPTS\WINDOWS"
$Global:WINDOWS_COPY_DONNEE_TO_C_TEMP_BDF_Tools = "$Global:WINDOWS\COPY_DONNEE_TO_C_TEMP_BDF_Tools"
$Global:WINDOWS_VERROUILLAGE = "$Global:WINDOWS\VERROUILLAGE"
$Global:WINDOWS_PURGE_PROFIL = "$Global:WINDOWS\PURGE_PROFIL"
$Global:WINDOWS_VERR_NUM = "$Global:WINDOWS\VERR_NUM"

$All_Dirs= @($Global:DIR_LOGS,$Global:DIR_LOGS2,$Global:WHO_LAUNCH,$Global:ERRORS,$Global:REPO_PARTAGE,$Global:SCRIPTS,$Global:APPLICATIONS,$Global:SCCM,$Global:WINDOWS,$Global:APPLICATIONS_JRE,$Global:SCCM_MAJ_POLICIES,$Global:SCCM_PURGE_CCMCACHE,$Global:WINDOWS_COPY_DONNEE_TO_C_TEMP_BDF_Tools,$Global:WINDOWS_VERROUILLAGE,$Global:WINDOWS_PURGE_PROFIL,$Global:WINDOWS_VERR_NUM)

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
   
    "<![LOG[$Message]LOG]!><time=$([char]34)$date+$($TimeZoneBias.bias)$([char]34) date=$([char]34)$date2$([char]34) component=$([char]34)$component$([char]34) context=$([char]34)$([char]34) type=$([char]34)$severity$([char]34) thread=$([char]34)$([char]34) file=$([char]34)$([char]34)>"| Out-File -FilePath "$Global:DIR_LOGS2\$env:COMPUTERNAME-$Global:ID-BDF_Tools.Log" -Append -NoClobber -Encoding default            
    } 

write-log -Message "-+-+-+-+-+-+-+-+Debut du script BDF_Tools+-+-+-+-+-+-+-+-+" -severity 1 -component "BDF_Tools"    

#On vérifie que l'utilisateur est en compte administrateur afin de pouvoir exécuter le script
function Test-Admin { 
	$identity = [Security.Principal.WindowsIdentity]::GetCurrent() 
	$principal = new-object Security.Principal.WindowsPrincipal $identity 
	$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)   
}
if( Test-Admin )
{
write-log -Message "BDF_Tools lancer en tant qu admin" -severity 2 -component "Droits Admin"
}
else
{
[System.Windows.Forms.MessageBox]::Show("Vous n'êtes pas Administrateur du poste `n`nVous devez disposer des droits Admin" , "Vérifications droits Admin",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::STOP)
write-log -Message "BDF_Tools n est pas lancer en tant qu admin"
	return -1
}


function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

#Fonction qui vérifie l'accès aux scripts via les onglets de base
function log_access_directory {
    param (
        # Parameter accepts the employee id to be searched.
        [Parameter(Mandatory)]
        $directory
    )
    switch ($directory) 
        {
            "Utilitaires"
            {
                $Global:Source_Utilitaire = test-path "$Global:DP_PROD\Utilitaires"

                #Si le dossier n'est pas joignable, un fichier txt sera incrémenté avec l'ID de l'utilisateur comprenant la date et l'heure ou le dossier n'a pas pu être joignable
                if (-not($Global:Source_Utilitaire))
                    {
                    echo "Dossier Utilitaires injoignable - $Global:User_And_D" >> "$Global:DP_LOG_ERROR_SOURCES_APPLIS\$Global:User_And_D.txt"
                    write-log -Message "Dossier Utilitaires injoignable" -severity 3 -component "Acces dossier UTILITAIRES"
                    Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Dossier Utilitaires injoignable" -NewMultiThreadTitle "Sources injoignables sur $Global:DP" -NewMultiThreadStatus "OK" -NewMultiThreadType "Asterisk"
                    }
                else 
                    {
                    $Global:Source_Utilitaire = "$Global:DP_PROD\Utilitaires"
                    write-log -Message "Acces au dossier Utilitaires OK" -severity 2 -component "Acces dossier UTILITAIRES"
                    }            
            }

            "SCCM"
            {
                $Global:SCCM_Onglet = test-path "$Global:DP_PROD\Onglets\SCCM"
                
                if (-not($Global:SCCM_Onglet))
                    {
                    echo "Dossier Onglet SCCM injoignable - $Global:User_And_D" >> "$Global:DP_LOG_ERROR_SOURCES_APPLIS\$Global:User_And_D.txt"
                    write-log -Message "Dossier Onglet SCCM injoignable" -severity 3 -component "Acces dossier SCCM"
                    Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Dossier SCCM injoignable" -NewMultiThreadTitle "Sources injoignables sur $Global:DP" -NewMultiThreadStatus "OK" -NewMultiThreadType "Asterisk"
                    }
                else 
                    {
                    $Global:SCCM_Onglet = "$Global:DP_PROD\Onglets\SCCM"
                    write-log -Message "Acces au dossier SCCM OK" -severity 2 -component "Acces dossier SCCM"
                    }
            }

            "WINDOWS"
            {
            $Global:PDT_Onglets = test-path "$Global:DP_PROD\Onglets\WINDOWS"

            if (-not($Global:PDT_Onglets))
                {
                echo "Dossier Onglet Windows injoignable - $Global:User_And_D" >> "$Global:DP_LOG_ERROR_SOURCES_APPLIS\$Global:User_And_D.txt"
                write-log -Message "Dossier Onglet WINDOWS injoignable" -severity 3 -component "Acces dossier WINDOWS"
                Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Dossier Windows injoignable" -NewMultiThreadTitle "Sources injoignables sur $Global:DP" -NewMultiThreadStatus "OK" -NewMultiThreadType "Asterisk"
                }
            else 
                {
                $Global:PDT_Onglets = "$Global:DP_PROD\Onglets\WINDOWS"
                write-log -Message "Acces au dossier WINDOWS OK" -severity 1 -component "Acces dossier WINDOWS"
                }
            }

            "APPLICATIONS"
            {
            $Global:APPLI_Onglets = test-path "$Global:DP_PROD\Onglets\APPLICATIONS"

            if (-not($Global:APPLI_Onglets))
                {
                echo "Dossier Onglet Applications injoignable - $Global:User_And_D" >> "$Global:DP_LOG_ERROR_SOURCES_APPLIS\$Global:User_And_D.txt"
                write-log -Message "Dossier APPLICATIONS injoignable" -severity 3 -component "Acces dossier APPLICATIONS"
                Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Dossier Windows injoignable" -NewMultiThreadTitle "Sources injoignables sur $Global:DP" -NewMultiThreadStatus "OK" -NewMultiThreadType "Asterisk"
                }
            else 
                {
                $Global:APPLI_Onglets = "$Global:DP_PROD\Onglets\APPLICATIONS"
                write-log -Message "Acces au dossier APPLICATIONS OK" -severity 1 -component "Acces dossier APPLICATIONS"
                }
            }

            default 
            {
            echo "Sources des scripts injoignables - $Global:User_And_D" >> "$Global:DP_LOG_ERROR_SOURCES_APPLIS\$Global:User_And_D.txt"
            write-log -Message "Sources des scripts injoignables" -severity 3 -component "Acces sources scripts"
            Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Sources des scripts injoignables" -NewMultiThreadTitle "Sources injoignables sur $Global:DP" -NewMultiThreadStatus "OK" -NewMultiThreadType "STOP"
            }
        }
}
#log_access_directory -directory "Utilitaires"

#Fonction de l'interface d'BDF_Tools
function BDF_Tools_interface {

$XamlMainWindow=LoadXml("$XamlRoute")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)

    #Variables qui fait reference a l arbo local ou les sources se trouvent et les autres variables
    #global dp prod fait référence à l'arbo de base du dossier BDF_Tools, cela évite de tout changer de nouveau
    $Global:DP_PROD = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, '.'))
    $Global:DP_WHO_LAUNCH = $Global:WHO_LAUNCH
    $Global:DP_LOG_ERROR_SOURCES_APPLIS = $Global:ERRORS

    echo "Le users $Global:ID a lance BDF_Tools le $Global:D2 à $Global:D sur $wksname" >> "$Global:DP_WHO_LAUNCH\$Global:D2.txt"

    $Form=[Windows.Markup.XamlReader]::Load($Reader)
    $Form.Background = '#D6F9EF'

    $Close = $form.FindName("Close")
    $MainMenu = $form.FindName("MainMenu")
    $Open_Menu = $form.FindName("Open_Menu")
    $Open_Menu.Visibility = "visible"
   
    ###ONGLET POUR DEPLACER L'APPLI####
    $Move_link = $form.FindName("Move_link")

#A décocher si on veut activer la possibilité de déplacer l'application sur la fenêtre Windows
<#
    $form.add_MouseLeftButtonDown({
       $_.handled=$true
       $this.DragMove()
    }) 
 
    $Move_link.add_PreviewMouseLeftButtonDown({
       $_.handled=$true
       $form.DragMove()   
    })
#>

    #####SCCM PART#####
#Recherche des éléments dans le fichier XML
    $SCCM_link = $form.FindName("SCCM_link")
    $SubMenu_Links_SCCM = $form.FindName("SubMenu_Links_SCCM")
    $Close_SubMenu_Links_SCCM = $form.FindName("Close_SubMenu_Links_SCCM")

    #Sous menu SCCM appel des différentes fonctions
    $Maj_policies_sccm = $form.FindName("Maj_policies_sccm")
    $CMTRACE = $form.FindName("CMTRACE")
    $Purge_cache_sccm = $form.FindName("Purge_cache_sccm")

    #On ouvre le sous menu SCCM
    $SCCM_link.Add_Click({
	    $MainMenu.IsOpen = $false
	    $Open_Menu.Visibility = "Collapsed"	
	    $SubMenu_Links_SCCM.IsOpen = $true	
    })

    #Fermer le sous menu SCCM
    $Close_SubMenu_Links_SCCM.Add_Click({
	    $SubMenu_Links_SCCM.IsOpen = $false
	    $MainMenu.IsOpen = $true
	    $Open_Menu.Visibility = "Collapsed"
    })

    #####WINDOWS PART#####
#Recherche des éléments dans le fichier XML
    $Windows_links = $form.FindName("Windows_links")
    $SubMenu_Links_Windows = $form.FindName("SubMenu_Links_Windows")
    $Close_SubMenu_Links_Windows = $form.FindName("Close_SubMenu_Links_Windows")

    #Sous menu Windows appel des différentes fonctions
    $Copy_Data = $form.FindName("Copy_Data")
    $Purge_profil = $form.FindName("purge_profil")
    $lock_session = $form.FindName("lock_session")
    $VerrNum = $form.FindName("VerrNum")

    #On ouvre le sous menu Windows
    $Windows_links.Add_Click({
	    $MainMenu.IsOpen = $false
	    $Open_Menu.Visibility = "Collapsed"	
	    $SubMenu_Links_Windows.IsOpen = $true	
    })

    #Fermer le sous menu Windows
    $Close_SubMenu_Links_Windows.Add_Click({
	    $SubMenu_Links_Windows.IsOpen = $false
	    $MainMenu.IsOpen = $true
	    $Open_Menu.Visibility = "Collapsed"
    })

    #####Applications PART#####
#Recherche des éléments dans le fichier XML
    $Applications_links = $form.FindName("Applications_links")
    $SubMenu_Links_Applications = $form.FindName("SubMenu_Links_Applications")
    $Close_SubMenu_Links_Applications = $form.FindName("Close_SubMenu_Links_Applications")

    #Sous menu Applications appel des différentes fonctions
    $java_repar = $form.FindName("java_repar")
    $about_aide2 = $form.FindName("about_aide2")

    #On ouvre le sous menu Windows
    $Applications_links.Add_Click({
	    $MainMenu.IsOpen = $false
	    $Open_Menu.Visibility = "Collapsed"	
	    $SubMenu_Links_Applications.IsOpen = $true	
    })

    #Fermer le sous menu Windows
    $Close_SubMenu_Links_Applications.Add_Click({
	    $SubMenu_Links_Applications.IsOpen = $false
	    $MainMenu.IsOpen = $true
	    $Open_Menu.Visibility = "Collapsed"
    })

    ####AIDE PART#####
#Recherche des éléments dans le fichier XML
    $Aide_link = $form.FindName("Aide_link")
    $SubMenu_Links_Aide = $form.FindName("SubMenu_Links_Aide")
    $Close_SubMenu_Links_Aide = $form.FindName("Close_SubMenu_Links_Aide")

    #Sous menu aide
    $about_aide = $form.FindName("about_aide")
    $wiki_scripts = $form.FindName("wiki_scripts")

    #On ouvre le sous menu Aide
    $Aide_link.Add_Click({
	    $MainMenu.IsOpen = $false
	    $Open_Menu.Visibility = "Collapsed"	
	    $SubMenu_Links_Aide.IsOpen = $true	
    })

    #Fermer le sous menu Aide
    $Close_SubMenu_Links_Aide.Add_Click({
	    $SubMenu_Links_Aide.IsOpen = $false
	    $MainMenu.IsOpen = $true
	    $Open_Menu.Visibility = "Collapsed"
    })

    ######INTERFACE PRINCIPAL#####
    ####DEBUT####
    #Fermer le menu
    $Close.Add_Click({
	    $MainMenu.IsOpen = $false
	    $Open_Menu.Visibility = "Visible"
    })

    #boutton d'ouverture du menu
    $Open_Menu.Add_Click({
	    $MainMenu.IsOpen = $true
	    $Open_Menu.Visibility = "Collapsed"
    })
    ####FIN####

    ######ACTIONS DES SOUS MENUS######
    #####SCCM - DEBUT#######

#Action de la mise à jour des stratégies du client SCCM
    $Maj_policies_sccm.Add_Click({
        log_access_directory -directory "SCCM"
        write-log -Message "Mise a jour des strategies SCCM" -severity 1 -component "ACTION - Maj strategies SCCM"
        Multithread_func -NewMultiThreadCondition "SCRIPT" -NewMultiThreadScriptAction "$Global:SCCM_Onglet\MajPoliciesSCCM.ps1"
    })

#Action de purge du cache SCCM
    $Purge_cache_sccm.Add_Click({
       log_access_directory -directory "SCCM"
       write-log -Message "Purge du cache SCCM" -severity 1 -component "ACTION - Purge cache SCCM"
       Multithread_func -NewMultiThreadCondition "SCRIPT" -NewMultiThreadScriptAction "$Global:SCCM_Onglet\PurgeCacheSCCM.ps1"
    })

#Lancement de CMTRACE
    $CMTRACE.Add_Click({
        log_access_directory -directory "Utilitaires"
        Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Vous venez de lancer l'utilitaire de lecture de logs" -NewMultiThreadTitle "CMTRACE" -NewMultiThreadStatus "OK" -NewMultiThreadType "INFORMATION"
        write-log -Message "Lancement CMTRACE" -severity 1 -component "ACTION - CMTRACE"
        Multithread_func -NewMultiThreadCondition "SCRIPT" -NewMultiThreadScriptAction "$Global:Source_Utilitaire\cmtrace.exe"
    })

    #####SCCM - FIN#######


    #####AIDE - DEBUT#######
#Onglet A propos 
        $about_aide.Add_Click({
            write-log -Message "Lancement a propos" -severity 1 -component "ACTION - A PROPOS"
            Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Personne à contacter en cas de question : Enzo Wintz`n`nBDF_Tools est un outil d'assistance qui englobe des actions pouvant agir sur le poste utilisateur `n`nUn grand pouvoir implique de grandes responsabilités `n`nFaites-en bon usage !" -NewMultiThreadTitle "A propos" -NewMultiThreadStatus "OK" -NewMultiThreadType "information"     
       })

#Action d'accès à la page Confluence de l'application
        $wiki_scripts.Add_Click({
        write-log -Message "Lancement Projets Gitub" -severity 1 -component "ACTION - WIKI_GITHUB"
	    $Browser=new-object -com internetexplorer.application
	    $Browser.navigate2("https://github.com/EnzoWintz/Projets")
	    $Browser.visible=$true	
    })
    #####AIDE - FIN#######

    #####WINDOWS - DEBUT#######
#Action de copie des données utilisateurs
    $Copy_Data.Add_Click({
        log_access_directory -directory "WINDOWS"
        write-log -Message "Sauvegarde donnees utilisateur" -severity 1 -component "ACTION - Sauvegarde"
        Multithread_func -NewMultiThreadCondition "SCRIPT" -NewMultiThreadScriptAction "$Global:PDT_Onglets\CopyDataToC_TEMP_BDF_TOOLS.ps1"        
    })
    
#Action de purge de profil 4ème version
    $Purge_profil.Add_Click({
        log_access_directory -directory "WINDOWS"
        write-log -Message "Lancement de la purge profil" -severity 1 -component "ACTIONS - Purge profil"
        Multithread_func -NewMultiThreadCondition "SCRIPT" -NewMultiThreadScriptAction "$Global:PDT_Onglets\PurgeProfilV4.ps1"
    })

#Action de réparation de la session verrouillée
    $lock_session.Add_Click({
        log_access_directory -directory "WINDOWS"
        write-log -Message "Verification compte verrouiller" -severity 1 -component "ACTION - SESSION LOCK"
        Multithread_func -NewMultiThreadCondition "SCRIPT" -NewMultiThreadScriptAction "$Global:PDT_Onglets\LOCK.ps1"
    })

#Action d'activation du pavé numérique au démarrage du poste
    $VerrNum.Add_Click({
        log_access_directory -directory "WINDOWS"
        write-log -Message "Pave numerique" -severity 1 -component "ACTION - PAVE NUMERIQUE"
        Multithread_func -NewMultiThreadCondition "SCRIPT" -NewMultiThreadScriptAction "$Global:PDT_Onglets\VerrNum_BarreDeProgression.ps1"
    })

    #####APPLICATIONS - DEBUT ######

#Action de aide
$about_aide2.Add_Click({
    write-log -Message "Lancement aide application" -severity 1 -component "ACTION - AIDE APPLICATION"
    Multithread_func -NewMultiThreadCondition "MSG_BOX" -NewMultiThreadContent "Cet onglet va permettre de regrouper des actions liés à des applications" -NewMultiThreadTitle "A propos" -NewMultiThreadStatus "OK" -NewMultiThreadType "information"     
})

#Action de réparation de Java - Désinstallation de Java
   $java_repar.Add_Click({
            log_access_directory -directory "APPLICATIONS"
            write-log -Message "Purge java" -severity 1 -component "ACTION - JAVA"
            Multithread_func -NewMultiThreadCondition "SCRIPT" -NewMultiThreadScriptAction "$Global:APPLI_Onglets\java_uninstallWithProgressBar.ps1"      
   })
   
#####WINDOWS - FIN#######

#On affiche notre interface
$Form.ShowDialog() | Out-Null
}

#L'interface d'BDF_Tools se chargera
BDF_Tools_Interface

write-log -Message "-+-+-+-+-+-+-+-+FIN du script BDF_Tools+-+-+-+-+-+-+-+-+" -severity 1 -component "BDF_Tools"

#Fonction qui va copier le log d'utilisation dans le partage dédié afin de centraliser les logs
function Back_To_Share_Place {
$REPO_PARTAGE = $Global:REPO_PARTAGE
$LOCAL_LOG = "$Global:DIR_LOGS2\$env:COMPUTERNAME-$Global:ID-BDF_Tools.Log"
if (-not(test-path $REPO_PARTAGE))
    {
    write-log -Message "Partage non joignable, impossible de copier le log sur le partage centraliser" -severity 1 -component "Copie fichier de log"    
    }
else {
     Copy-Item -Path $LOCAL_LOG -Destination $REPO_PARTAGE
     }
}
#On rappatrie le log sur notre partage commun afin de simplifier le monitoring d'BDF_Tools
Back_To_Share_Place