clear
#Verifie si le dossier log existe, s'il n'existe pas, on le cree
$loglocation = "C:\Taches_planifies\"

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
   
    "<![LOG[$Message]LOG]!><time=$([char]34)$date+$($TimeZoneBias.bias)$([char]34) date=$([char]34)$date2$([char]34) component=$([char]34)$component$([char]34) context=$([char]34)$([char]34) type=$([char]34)$severity$([char]34) thread=$([char]34)$([char]34) file=$([char]34)$([char]34)>"| Out-File -FilePath "$loglocation\Logs\Purge_CAM.Log" -Append -NoClobber -Encoding default            
    }

    Write-Log -Message "---------------------Debut de traitement---------------------"  -severity 1 

    $lecteurNAS = test-path Y:
    $lecteurDirectoryCam = test-path Y:\RECORD\FoscamCamera_00626EEF5DEB
    $startFolder = "Y:\RECORD\FoscamCamera_00626EEF5DEB"

    Write-Log -Message "Verification de la connexion au NAS"  -severity 1 

    if ($lecteurNAS)

        {
        Write-Log -Message "Le NAS est joignable"  -severity 1

        
        Write-Log -Message "Verification de l'existence du dossier des sauvegarde des fichiers de la camera"  -severity 1 

        if ($lecteurDirectoryCam)

            {

            #La boucle for va mesurer la volumétrie et l'inscrire dans le fichier de log
            Write-Log -Message "Verification de la volumetrie des dossier de la camera"  -severity 1

            $colItems = Get-ChildItem $startFolder | Where-Object {$_.PSIsContainer -eq $true} | Sort-Object

            $res = {

                foreach ($i in $colItems)
                {
                    $subFolderItems = Get-ChildItem $i.FullName -recurse -force | Where-Object {$_.PSIsContainer -eq $false} | Measure-Object -property Length -sum | Select-Object Sum
                    $i.FullName + " -- " + "{0:N2}" -f ($subFolderItems.sum / 1MB) + " MB"
                }
               }
            $res2 = Invoke-Command -ScriptBlock $res

            Write-Log -Message "La volumetrie du dossier de la camera est :"  -severity 1

            Write-Log -Message "$res2"  -severity 1

                #La boucle for va afficher les dossiers qui font plus de 500 Go en volumétrie et il entamera une purge afin de garder les fichiers des 7 derniers jours si c'est nécessaire, s'il dépasse pas les 500 Go, il les ignorera
                foreach ($i in $colItems)
                {
                    $subFolderItems2 = Get-ChildItem $i.FullName -recurse -force | Where-Object {$_.PSIsContainer -eq $false} | Measure-Object -property Length -sum | Select-Object Sum
                    $sum = $i.FullName + " -- " + "{0:N2}" -f ($subFolderItems2.sum / 1MB) + " MB"
                    #Il vérifie si le dossier dépasse les 500 Go, l'échelle se base sur les Mo
                    if (($subFolderItems2.sum / 1MB) -gt 500000)
                        {
                        Write-Log -Message "-----    ----------Purge de $i------------    ----"  -severity 1
                        Write-Log -Message "$i fait plus de 500 Go" -severity 1

                        #Commande de purge qui gardera les fichiers des 7 derniers jours uniquement
                        Get-ChildItem $i.FullName -recurse -force | Where CreationTime -lt  (Get-Date).AddDays(-7) | Remove-Item -Force -Recurse
                        
                        Write-Log -Message "-----    ------Fin de purge pour $i-------    ----"  -severity 1
                        }
                    else 
                        {
                        Write-Log -Message "$i n'a pas besoin de purge" -severity 1
                        }
                }

                Write-Log -Message "-----------------------Purge terminee----------------------"  -severity 1
                Write-Log -Message "---------------------Fin de traitement---------------------"  -severity 1

            }
        else {
            Write-Log -Message "Le dossier n'existe pas ou a ete renomme, merci de verifier cela"  -severity 1
            Write-Log -Message "---------------------Fin de traitement---------------------"  -severity 1
            exit
            }
        }

    else {
          Write-Log -Message "Echec de connexion au NAS, merci de verifier que le lecteur est mappe correctement"  -severity 1
          Write-Log -Message "---------------------Fin de traitement---------------------"  -severity 1
          exit
         }
