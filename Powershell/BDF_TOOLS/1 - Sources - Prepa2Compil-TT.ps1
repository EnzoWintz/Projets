clear
################################
#                              #
# Script préparation sources   #
#     Avant compilation        #
#                              #
#     AUTEUR : WINTZ ENZO      #
#                              #
################################


function Copy-compil {


$DirCompil = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, 'COMPIL2EXE'))


if (test-path $DirCompil)
    {
    write-host "Le dossier de compilation existe" -ForegroundColor Green
    Remove-Item -Path "$DirCompil\*" -Recurse
    sleep 2
    }
else {

    write-host "Le dossier de compilation n existe pas" -ForegroundColor Yellow
    write-host "$DirCompil" -ForegroundColor green
    New-Item -Path $DirCompil -ItemType "directory" | Out-Null
    }

$Global:fileps1 = "BDF_Tools_All_In_One.ps1"
$Global:filexaml = "BDF_Tools_All_In_One.xaml"
$GLobal:PS1_DIR = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "Onglets\"))
$GLobal:CMTRACE = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "Utilitaires\"))

$Global:filedest = @("assembly","logos","resources","$Global:fileps1","$Global:filexaml","$GLobal:CMTRACE","$Global:PS1_DIR")

write-host "Debut de la copie" -ForegroundColor Green


foreach ($x in $Global:filedest)
    {
    $Dirbase = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "$x"))

    switch ($x)
        {
            "$Global:fileps1" {
            Copy-Item -Path "$Dirbase" -Destination $DirCompil | Out-Null
            }

            "$Global:filexaml" {
            Copy-Item -Path "$Dirbase" -Destination $DirCompil | Out-Null
            }
            "$GLobal:PS1_DIR"{
            Get-ChildItem $Dirbase -recurse -filter *.ps1 | Copy-item -Destination $DirCompil
            return
            }
            "$GLobal:CMTRACE" {
            Copy-Item -Path "$Dirbase\cmtrace.exe" -Destination $DirCompil | Out-Null
            }

        }

        Copy-Item -Path "$Dirbase\*" -Destination $DirCompil -Recurse | Out-Null
        
        
    }
write-host "Fin de la copie" -ForegroundColor Green

}

function replace_text {
$DirCompilps1 = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "COMPIL2EXE\$Global:fileps1"))
$DirCompilXaml = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, "COMPIL2EXE\$Global:filexaml"))

if (test-path $DirCompilps1)
    {
    write-host "Fichier trouvé" -ForegroundColor green
    
    #Remplacement du texte 
    write-host "Changement de l assembly dans $DirCompilps1" -ForegroundColor Yellow
    $old = "assembly\"
    $new = ""
    (Get-Content "$DirCompilps1").replace($old,$new) | Set-Content -Path "$DirCompilps1"
    sleep -Milliseconds 500

    write-host "Changement de Config dans $DirCompilps1" -ForegroundColor Yellow
    $old = "Config\"
    $new = ""
    (Get-Content "$DirCompilps1").replace($old,$new) | Set-Content -Path "$DirCompilps1"
    sleep -Milliseconds 500

    write-host "Changement chemin Utilitaires dans $DirCompilps1" -ForegroundColor Yellow
    $old = "$Global:DP_PROD\Utilitaires"
    $new = "$Global:DP_PROD"
    (Get-Content -Path "$DirCompilps1").replace($old,$new) | Set-Content -Path "$DirCompilps1"
    sleep -Milliseconds 500

    write-host "Changement chemin Onglets\SCCM dans $DirCompilps1" -ForegroundColor Yellow
    $old = "$Global:DP_PROD\Onglets\SCCM"
    $new = "$Global:DP_PROD"
    (Get-Content -Path "$DirCompilps1").replace($old,$new) | Set-Content -Path "$DirCompilps1"
    sleep -Milliseconds 500

    write-host "Changement chemin Onglets\WINDOWS dans $DirCompilps1" -ForegroundColor Yellow
    $old = "$Global:DP_PROD\Onglets\WINDOWS"
    $new = "$Global:DP_PROD"
    (Get-Content -Path "$DirCompilps1").replace($old,$new) | Set-Content -Path "$DirCompilps1"
    sleep -Milliseconds 500

    write-host "Changement chemin Onglets\APPLICATIONS dans $DirCompilps1" -ForegroundColor Yellow
    $old = "$Global:DP_PROD\Onglets\APPLICATIONS"
    $new = "$Global:DP_PROD"
    (Get-Content -Path "$DirCompilps1").replace($old,$new) | Set-Content -Path "$DirCompilps1"
    sleep -Milliseconds 500

    write-host "`nChangement de ressources dans $DirCompilXaml" -ForegroundColor Yellow
    $old2 = "resources/"
    $new2 = ""
    (Get-Content -Path "$DirCompilXaml").replace($old2,$new2) | Set-Content -Path "$DirCompilXaml"
    sleep -Milliseconds 500

    write-host "`nChangement de logos dans $DirCompilXaml" -ForegroundColor Yellow
    $old3 = "logos\"
    $new3 = ""
    (Get-Content -Path "$DirCompilXaml").replace($old3,$new3) | Set-Content -Path "$DirCompilXaml"

    write-host "`nChangement de version dans $DirCompilXaml" -ForegroundColor Yellow
    $old4 = "BDF Tools $SED_version_search"
    $new4 = "BDF Tools $SED_version_replace"
    (Get-Content -Path "$DirCompilXaml").replace($old4,$new4) | Set-Content -Path "$DirCompilXaml"

    }

else {
    write-host "Fichier non trouve, merci de faire les modifications manuellement" -ForegroundColor Yellow

}

}

#On copie les sources dans le repertoire
Copy-compil 

#On change les valeurs pour qu'elles soient compatible avec la création de l'.exe par Iexpress
replace_text


read-host "`nAppuyer sur n importe quel touche pour terminer le script..."

