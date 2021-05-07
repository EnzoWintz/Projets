cls
##################################
#                                #
#    Script Icônes Blanches      #
#                                #
#    Auteur : WINTZ ENZO         #
#                                #
##################################

#Fonction status
function writestatus([string] $element,[int] $status)
{
   $info = $wksname+" "+$element
   
	Write-Host ("{0,-80}" -f $info ) -nonewline 
	switch ($status)
	{
		1{
			Write-Host "[OK]" -foregroundcolor green
		}
		0{	
			Write-Host "[KO]" -foregroundcolor red
		}
		default{
			Write-Host "[WA]" -foregroundcolor Yellow
		}
	}
}

#On récupère le matricule de l'utilisateur actuellement connecté sur le poste
$x  = Get-CimInstance -ClassName win32_computerSystem -computerName . | select-object -Property *user*
$nameuser = $x.example


#Variable qui va vérifier la présence du dossier system tools, au quel cas, celui-ci n'existe pas, le script s'arrêtera
$SystemTools = Test-Path "C:\Users\$nameuser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\"
$Accessories = Test-Path "C:\Users\$nameuser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessories"
$Programmes = Test-Path "C:\Users\$nameuser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"



if ($Programmes)
    {
    writestatus "Check du profil" $true

        if ($SystemTools)
            {
             writestatus "Vérification existence du dossier System Tools" $true  

             Remove-Item -Path "C:\Users\$nameuser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\*"

             Copy-Item  -Path ".\Onglets\WINDOWS\shortcuts\SystemTools\*" -Destination "C:\Users\$nameuser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\"
     
             writestatus "Les raccourcis ont été copiés dans le dossier System Tools" $true      
     
            }

        else
            {
            writestatus "Vérification existence du dossier System Tools" $false
            [System.Windows.Forms.MessageBox]::Show("Le dossier System Tools n'existe pas ! `r`n`nVous pouvee vérifier l'existence de l'arborescence au chemin suivant : `r`n`nC:\Users\$nameuser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\" , "Script Icônes Blanches ",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
            }
        if ($Accessories)
            {
             writestatus "Vérification existence du dossier Accessoires Windows" $true  

             Remove-Item -Path "C:\Users\$nameuser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessories\*"

             Copy-Item  -Path ".\Onglets\WINDOWS\shortcuts\Accessories\*" -Destination "C:\Users\$nameuser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Accessories\"
     
             writestatus "Les raccourcis ont été copiés dans le dossier Accessoires Windows" $true  

            }
        else
            {
            writestatus "Vérification existence du dossier Accessoires Windows" $false
            [System.Windows.Forms.MessageBox]::Show("Le dossier Accessoires Windows n'existe pas !" , "Script Icônes Blanches ",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
            }



Get-ChildItem -Path "C:\Users\$nameuser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\*" -Recurse | Where-Object -FilterScript {$_.Name -match "Google Chrome"} | Remove-Item -ErrorAction SilentlyContinue

writestatus "Suppression du raccourci Chrome" $true

Copy-Item  -Path ".\Onglets\WINDOWS\shortcuts\Google Chrome.Ink" -Destination "C:\Users\$nameuser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\"

writestatus "Copie du raccourcis Chrome" $true

Get-ChildItem -Path "C:\Users\$nameuser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\*" -Recurse | Where-Object -FilterScript {$_.Name -match "OneDrive"} | Remove-Item -ErrorAction SilentlyContinue

writestatus "Suppression du raccourci OneDrive" $true

Copy-Item  -Path ".\Onglets\WINDOWS\shortcuts\OneDrive.Ink" -Destination "C:\Users\$nameuser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\"

writestatus "Copie du raccourci OneDrive" $true

[System.Windows.Forms.MessageBox]::Show("Fin du script ! `n`nVeuillez redémarrer le poste ! `n`nSupprimez les raccoucis avec icônes blanches et remettez les de nouveau une fois le redémarrage effectué" , "Script Icônes Blanches ",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)

          
    }
else 

    {
    writestatus "Check du profil" $false
    [System.Windows.Forms.MessageBox]::Show("Le profil semble avoir un soucis de configuration ! `r`n`nMerci de supprimer le profil afin d'en recharger un autre", "Script Icônes Blanches ",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::STOP)
    }

    #Accessories



 