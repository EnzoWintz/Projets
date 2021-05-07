cls
#import modules de compression
Import-Module Microsoft.Powershell.Archive

#dossier de logs
$loglocation = "C:\Taches_planifies\"
#Vérification d'accès au disque dur
$lecteurDD2ArchiveNAS = test-path "F:\ArchivesMensuel_NAS"
$lecteurDDArchiveNAS = "F:\ArchivesMensuel_NAS"
$lecteurNAS = test-path Z:
$letterNASMAP = 'Z:\'
#$NASExclude = "$letterNASMAP\Applis", "$letterNASMAP\Perso\Films","$letterNASMAP\VM","$letterNASMAP\Samsung SM-G975F Camera Backup"
$NASInclude = $letterNASMAP
$Date = Get-Date -Format "dd-MM-yyyy"


Function Write-Log{            
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
   
    "<![LOG[$Message]LOG]!><time=$([char]34)$date+$($TimeZoneBias.bias)$([char]34) date=$([char]34)$date2$([char]34) component=$([char]34)$component$([char]34) context=$([char]34)$([char]34) type=$([char]34)$severity$([char]34) thread=$([char]34)$([char]34) file=$([char]34)$([char]34)>"| Out-File -FilePath "$loglocation\Logs\Archive2DD.Log" -Append -NoClobber -Encoding default            
    }


function ZipFiles( $zipfilename, $sourcedir )
{
   Add-Type -Assembly System.IO.Compression.FileSystem
   $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
   [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcedir,
        $zipfilename, $compressionLevel, $false)
}
    
 Write-Log -Message "---------------------Debut de traitement---------------------"  -severity 1 -component "Debut du script"
    
if ($lecteurDD2ArchiveNAS)

    {
        Write-Log -Message "Le lecteur d'archive est joignable" -severity 2 -component "Connexion Disque dur"
        
        if ($lecteurNAS)
            {
            Write-Log -Message "Connexion au serveur NAS Reussi --> OK" -severity 2 -component "Connexion au NAS"
            
            #Boucle for faisant copier les datas vers le disque dur pour ensuite entamer la compression
            foreach ($CopyData in $NASInclude)
                {
                Write-Log -Message "Debut de copie des donnees avant compression" -severity 2 -component "CopyData_AvantCompression"
                    if ($CopyData)
                        {
                        #Création du dossier qui accueillera l'archive
                        Write-Log -Message "Creation dossier futur contenant l'archive" -severity 2 -component "CopyData_AvantCompression"
                        
                        New-Item -Path "$lecteurDDArchiveNAS\$Date" -ItemType "directory" | Out-Null 

                        Write-Log -Message "Dossier cree" -severity 1 -component "CopyData_AvantCompression"

                        #Copie des données vers la destination avec exclusion des différents répertoires
                        Write-Log -Message "Copie des fichiers du NAS" -severity 2 -component "CopyData_AvantCompression"
                        
                        robocopy $CopyData "$lecteurDDArchiveNAS\$Date\MENSUELLE" /S /XD "Perso" "VM" "Samsung SM-G975F Camera Backup" "EXCLUDE_MENSUELLE" "Rockstar Games"
                        
                        Write-Log -Message "Fin de copie des fichiers du NAS" -severity 1 -component "CopyData_AvantCompression"

                        #Compression des données
                        Write-Log -Message "Debut de la compression" -severity 2 -component "Compression"

                        #Compress-Archive -Path "$lecteurDDArchiveNAS\$Date\MENSUELLE\*" -DestinationPath "$lecteurDDArchiveNAS\$Date\ArchiveMensuelle.zip" 
                        ZipFiles -zipfilename "$lecteurDDArchiveNAS\$Date\ArchiveMensuelle.zip" -sourcedir "$lecteurDDArchiveNAS\$Date\MENSUELLE\"

                        Write-Log -Message "Fin de la compression" -severity 2 -component "Compression"

                        #Suppression du dossier temporaire une fois que la compression s'est terminé
                        write-log -Message "START - Suppression des fichiers temporaires" -severity 2 -component "Suppression après compression"

                        gci "$lecteurDDArchiveNAS\$Date\" -Recurse | Where-Object {$_.Name -Like "MENSUELLE"} | Remove-Item -Recurse -Force #| Out-Null
                        
                        write-log -Message "END - Suppression des fichiers temporaires" -severity 2 -component "Poste Suppression" 
                        }
                    else 
                        {
                        Write-log -Message "Erreur, impossible de poursuivre, arrêt du script" -severity 3 -component "Echec"
                        break
                        }
                }
            }
        else 
            {
            Write-Log -Message "Le serveur NAS n'est pas joignable, merci de verifier si le NAS est allume et branche au reseau" -severity 3 -component "Connexion au NAS"

            }

    
    
        write-Log -Message "-------------------Fin de traitement-----------------" -severity 1 -Component "Fin du script"     
    }
 else 
 
    {
    
        Write-Log -Message "Le lecteur d'archive n'est pas joignable, merci de verifier si le disque est branche" -severity 3 -component "Connexion Disque dur"
            
    }

write-Log -Message "-------------------Fin de traitement-----------------" -severity 1 -Component "Fin du script"  