 cls

Write-host "#########################################"
Write-host "#                                       #"
Write-host "#  Script debug log de mise à niveau    #"
Write-host "#                                       #"
Write-host "#########################################"
Write-host "`n"

write-host "################DEBUT DE TRAITEMENT################" 
Write-host "`n"

####Début Script####
$Key1 = Get-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "ReleaseId" -ErrorAction SilentlyContinue
$Key2 = Get-ItemProperty -path "HKLM:\example\example\example" -Name "example" -ErrorAction SilentlyContinue
$reskey1 = $Key1.ReleaseId
$resKey2 = $Key2.example

if ($reskey1 -match "1909" -and $resKey2 -match "SUCCESS-1909") 
    {
    write-host "Mise à niveau en 1909 SUCCESS" -ForegroundColor Green
    }
else {


#Déclaration variables smsts.log
$smsts = test-path "C:\Windows\CCM\Logs\smsts*.log" 


if ($smsts)
    {
    #write-host "Fichier de log trouvé" 
    #Définition de la lecture du log avec le regex
    
    $logbackup = gci -path "C:\Windows\CCM\Logs\" -File | where-Object {$_.Name -match 'smsts(.{16})'} -ErrorAction SilentlyContinue
    $logbase = "smsts.log"
    if ($logbackup)
    {
    #Identification du dernier log d'archive
    #$archivelognmber = $logbackup.name
    $archivelognmber = $($logbackup.count)
    #Si deux logs d'archives sont détectés, il incrémente la variable $log afin que l'analyse se fasse sur les 3 fichiers de logs
    if ($archivelognmber -eq 2)
        {
        #write-host "Deux fichiers de logs d'archives détectés" -ForegroundColor Green
        #Identification du dernier log d'archive
        $archivelog1 = $logbackup.name[$($logbackup.count)-1]
        
        #identification de l'avant dernier log d'archive
        $archivelog2 = $logbackup.name[$($logbackup.count)-2]

        $log = "C:\Windows\CCM\Logs\$archivelog2","C:\Windows\CCM\Logs\$archivelog1","C:\Windows\CCM\Logs\$logbase"

        }
    else 
        {
        #write-host "Un fichier de log d'archive détecté" -ForegroundColor Green
        $log = "C:\Windows\CCM\Logs\$logbackup","C:\Windows\CCM\Logs\$logbase" 
        }
    }

    else {$log = "C:\Windows\CCM\Logs\$logbase"}
    $result=@()
        foreach ($logfile in $log)
        {

        $fs = new-object system.io.FileStream($logfile,[system.io.filemode]::open,[system.io.FileAccess]::Read,[system.io.FileShare]::ReadWrite)
        $file = new-object system.io.streamReader($fs)

        #Variable REGEX recherchant le mot clé du lo
        #$ErrorKnown = [regex] "Failed to run the action:(.+\.)"
        $ErrorKnown = [regex] "Failed to run the action: (.+). Error.*time=`"(.{8}).*date=`"(.{10})"
        $ErrorKnown2 = [regex] "External system shutdown request is received during execution of the action (.+).LOG.*time=`"(.{8}).*date=`"(.{10})"


        do 
            {
                $logline=$file.readline()

                if ($file.EndOfStream)
                   {
                   sleep -Milliseconds 100
                        $logline=$file.readline()
                   }
                switch -regex ($logline)
                    {
                    
                        $ErrorKnown
                        {                                    
                        $info1=$ErrorKnown.Match($logline).groups[1].Value
                        $info2=$ErrorKnown.Match($logline).groups[2].Value
                        $info3=$ErrorKnown.Match($logline).groups[3].Value
                        $result+="Date : $info3 Heure : $info2 Etape en échec : $info1"
                        }
                        $ErrorKnown2
                        {
                        $info1=$ErrorKnown2.Match($logline).groups[1].Value
                        $info2=$ErrorKnown2.Match($logline).groups[2].Value
                        $info3=$ErrorKnown2.Match($logline).groups[3].Value
                        $result+="Date : $info3 Heure : $info2 Etape en échec : $info1"
                        }
                        
                    }     
            }
         until($file.EndOfStream)
   


        }

    $result1=@()
    $result1+=$result | Where-Object {$_ -match "onedrive" -or $_ -match "example" -or $_ -match "example" -or $_ -match "mise a niveau" -or $_ -match "non conforme" -or $_ -match "example" -or $_ -match "example"}
     #$result
      
    if ($result1)
        {

        
    #$result[$($result.count)-1]
    #recherche des différents cas ou le souci est rencontré
    $OneDrive = $result1[$($result1.count)-1] | Where-object {$_ -match "onedrive"} 
    $example = $result1[$($result1.count)-1] | Where-object {$_ -match "Installation example"} 
    $example = $result1[$($result1.count)-1] | Where-object {$_ -match "Desinstallation example"} 
    $example = $result1[$($result1.count)-1] | Where-object {$_ -match "Installation example"} 
    $example = $result1[$($result1.count)-1] | Where-object {$_ -match "Desinstallation example"}
    $MiseANiveau = $result1[$($result1.count)-1] | Where-object {$_ -match "mise a niveau"} 
    $Prerequis = $result1[$($result1.count)-1] | Where-object {$_ -match "non conforme"} 
    $example = $result1[$($result1.count)-1] | Where-object {$_ -match "example"} 
    $example = $result1[$($result1.count)-1] | Where-object {$_ -match "example"} 

    #$Prerequis
    #$result1[$($result.count)-1] #| Where-object {$_ -match "non conforme"}
    #
  
    switch ($result1) 
          {

             $OneDrive
             {
             $OneDrive
              write-host "`n"
              write-host "Suppression de OneDrive en erreur, merci d'appliquer la procedure au point X.X.X.X `n `n" -ForegroundColor Yellow
              
             }

             $example 
             {
             $example 
              write-host "`n"
              write-host "Installation de example en erreur, merci d'appliquer la procedure au point X.X.X.X `n `n" -ForegroundColor Yellow
              
             }

             $example
             {
             $example
              write-host "`n"
              write-host "Desinstallation de example en erreur, merci d'appliquer la procedure au point X.X.X.X `n `n" -ForegroundColor Yellow
              
             }

             $example
             {
             $example
              write-host "`n"
              write-host "Installation d'example en erreur, merci d'appliquer la procedure au point X.X.X.X `n `n" -ForegroundColor Yellow
              
             }

             $example
             {
             $example
              write-host "`n"
              write-host "Désinstallation d'example en erreur, merci d'appliquer la procedure au point X.X.X.X `n `n" -ForegroundColor Yellow
             }
             $MiseANiveau 
             {
             $MiseANiveau
              write-host "`n"
              write-host "Echec de la mise a niveau, merci d'appliquer la procedure au point X.X.X.X `n `n" -ForegroundColor Yellow
             }
             $Prerequis
             {
             $Prerequis
              write-host "`n"
              write-host "Merci de verifier que lors du lancement de la mise à niveau, le poste a respecte tous les prerequis et relancez l'IPU `n `n" -ForegroundColor Yellow
              $PowerKey = Get-ItemProperty -path "HKLM:\example\example\example" -Name "example"
              $res = $PowerKey.example
              if ($res)
                {
                write-host "Cable d'alimentation debranche" -ForegroundColor Red
                }
                else {write-host "Autre prerequis KO, merci" -ForegroundColor Yellow} 
             }
             $example
             {
             $example
              write-host "`n"
              write-host "Merci de faire remasteriser le poste `n `n" -ForegroundColor Yellow
             }
             $example
             {
             $example
              write-host "`n"
              write-host "Echec d'application des example, merci de rejouer la procedure au point X.X.X.X`n `n" -ForegroundColor Yellow
             }


          }
        }
        else {write-host "Erreur non référencé, merci d'escalader l'incident" -ForegroundColor Red}
      }       
    
else 
    {
    write-host "Fichier de log non trouvé"
    }
    }



 write-host "`n"
 write-host "################FIN DE TRAITEMENT################"
 write-host "`n"
 read-host "Appuyer sur une touche pour quitter le script..." 
 
#Fin du script

