clear
#Vérifie si le dossier log existe, s'il n'existe pas, on le créé
$loglocation = "C:\Taches_planifies\"

#On récupère le nom de l'utilisateur connecté au poste grâce à la variable d'environnement associée session
$name = $env:UserName

 
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
   
    "<![LOG[$Message]LOG]!><time=$([char]34)$date+$($TimeZoneBias.bias)$([char]34) date=$([char]34)$date2$([char]34) component=$([char]34)$component$([char]34) context=$([char]34)$([char]34) type=$([char]34)$severity$([char]34) thread=$([char]34)$([char]34) file=$([char]34)$([char]34)>"| Out-File -FilePath "$loglocation\Logs\Sauvegarde_Data.$name.Log" -Append -NoClobber -Encoding default            
    } 


Write-Log -Message "---------------------Debut de traitement---------------------"  -severity 1 

#Création du dossier Sauvegarde.matricule.$D.$D2 dans le C:\Travail
#Ces variables seront utilisés dans le nommage des Logs et du fichier une fois le script joué, il pourra créer autant de fichier qu'il le souhaitera
                 
$D= Get-Date -Format "HH-mm"                     
$D2= Get-Date -Format "dd-MM-yyyy"
$lecteur = test-path Z:

if ($lecteur)

{    

New-Item -Path "Z:\Sauvegardes_Profil\$D2.$D" -ItemType "directory" | Out-Null 

Write-Log -Message "Creation du dossier $D2.$D sur le NAS"  -severity 2 


####Début de copie des datas user pour chaque dossiers renseignés dans $DataUser##### 
$DataUser= "Bureau","Documents","Images","Videos"


Write-Log -Message "---------------------Debut de copie des donnees---------------------"  -severity 1

    if ($DataUser -ne "Videos")
    {
        foreach ($Data in $DataUser -ne "Videos")
            {

            if ( (Get-ChildItem C:\Users\$name\OneDrive\$Data\ | Measure-Object).Count -eq 0)

            {

             Write-Log -Message "---------------------Fin de traitement---------------------"  -severity 1
   
             Write-Log -Message "****************Le dossier $Data est vide, Traitement suivant**************"  -severity 1
     
             return
            }

            if (-not (Test-path "Z:\Sauvegardes_Profil\$D2.$D\$Data")) 
            {
                New-Item -Path "Z:\Sauvegardes_Profil\$D2.$D\$Data" -ItemType "directory" | Out-Null

                Write-Log -Message "Creation du dossier $Data `n"  -severity 3
       
            }

            Copy-Item  -Path "C:\Users\$name\OneDrive\$Data\*" -Destination "Z:\Sauvegardes_Profil\$D2.$D\$Data" -Recurse 
    
            Write-Log -Message "---------------------Copie des donnees present dans $Data vers Z:\Sauvegardes_Profil\$D2.$D\$Data---------------------"  -severity 1
      
            Write-Log -Message "---------------------Fin de traitement---------------------"  -severity 1
    
    }
}

    if ($DataUser -eq "Videos")
    {
        if (-not (Test-path "Z:\Sauvegardes_Profil\$D2.$D\Videos")) 
            {
                New-Item -Path "Z:\Sauvegardes_Profil\$D2.$D\Videos" -ItemType "directory" | Out-Null

                Write-Log -Message "Creation du dossier Vidéos"  -severity 3
       
            }

            Copy-Item  -Path "C:\Users\$name\Videos\*" -Destination "Z:\Sauvegardes_Profil\$D2.$D\Videos" -Recurse 
    
            Write-Log -Message "---------------------Copie des donnees present dans Vidéos vers Z:\Sauvegardes_Profil\$D2.$D\Vidéos---------------------"  -severity 1
      
            Write-Log -Message "---------------------Fin de traitement---------------------"  -severity 1
    }

}
else 
{

Write-Log -Message "Serveur NAS injoignable"  -severity 1

Write-Log -Message "---------------------Fin de traitement---------------------"  -severity 1

exit
}