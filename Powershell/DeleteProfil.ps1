clear
############################
#                          #
#        Script            #
# Suppression profil local #
#                          #
############################

#On recherche l'ID de l'utilisateur actuellement en session sur le poste
$Global:x  = Get-CimInstance -ClassName win32_computerSystem -computerName . | select-object -Property *user*
$Global:ID = $Global:x.UserName -match '^(?!ID)'

#On demande l'utilisateur que l'on souhaite rechercher
$Search_User = read-host "Entrez ID"

#On initie HKLM_User_ID une valeur null au départ
$HKLM_User_ID = $null
$HKLM_User_ID = $(Get-WMIObject -class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq "$Search_User" }).SID
#$HKLM_User_ID.SID
#Chemin vers le profil utilisateur se situant à C:\Users\ID
$localpath = ‘c:\users\’ + $Search_User

#1ère condition
if (-not($Search_User -match $Global:ID))
    {
  
        if ($HKLM_User_ID)
           {
           write-host "Utilisateur $Search_User trouver`n" -ForegroundColor Yellow
           write-host "SID associé à $Search_User est $HKLM_User_ID" -ForegroundColor Yellow
   
           $Warn_Before_delete = read-host "Voulez-vous supprimer le profil $Search_User (y/n --> SENSIBLE A LA CASSE)"

           if ($Warn_Before_delete -ceq "y")
                {
                   Get-WmiObject -Class Win32_UserProfile | Where-Object {$_.LocalPath -eq $localpath} | Remove-WmiObject
                   write-host "Profil supprimer,`nMerci de redemarrer le poste" -ForegroundColor cyan
                }
           else 
                {
                write-host "Suppression du profil annuler" -ForegroundColor Yellow
                }
           }
        else 
            {
            write-host "Profil $Search_User introuvable" -ForegroundColor Yellow
            }
    }
else {Write-host "Vous ne pouvez pas supprimer $Search_User car vous le lancer depuis sa session" -ForegroundColor red}

Read-Host "`nMerci de d'appuyer sur entree pour quitter le script"   
