cls

#Déclaration des variables
$name_pc=hostname
#$fichier_sortie= test-path c:\caracteristique_$name_pc.txt
$fichier_sortie= test-path c:\caracteristique_$name_pc.csv
$Date=(Get-date).DateTime

#Si le fichier existe, il le supprime et joue ensuite la boucle normalement
if ($fichier_sortie)
{
#$fichier_sortie="c:\caracteristique_$name_pc.txt"

$fichier_sortie="c:\caracteristique_$name_pc.csv"
write-host "Fichier de sortie existant `n" -ForegroundColor Red

write-host "Suppression du fichier de sortie déjà existant" -ForegroundColor yellow
Remove-Item $fichier_sortie
}

else 
{
write-host "Fichier de sortie non existant" -ForegroundColor Green
}

#$fichier_sortie="c:\caracteristique_$name_pc.txt"
$fichier_sortie="c:\caracteristique_$name_pc.csv"

$Date >> $fichier_sortie

#Build de l'OS
$Build_OS = (Get-CimInstance -ClassName Win32_OperatingSystem).BuildNumber

#Version de l'OS basé sur le registre
$OS_Version = (Get-ItemProperty -path "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion

#Afficher l'espace de stockage disponible des différents périphériques
$Storage_FreeSpace = (Get-WmiObject -Class Win32_logicaldisk -Filter "DeviceID= 'C:'").FreeSpace
$Storage_FreeSpace = [math]::round($Storage_FreeSpace/1GB, 2)

#On affiche le nom du processeur
$Process_Info = (Get-CimInstance -Query 'Select * from Win32_Processor').Name

#Information de la RAM
 
#proc :
 
$Processeur=[string](Get-WmiObject -Class win32_processor).LoadPercentage + " % de processeur utilisé"
 
#ram = {
 
$Taille_RAM_MAX=[STRING]((Get-WmiObject -Class Win32_ComputerSystem ).TotalPhysicalMemory)
$Taille_RAM_MAX = [math]::round($Taille_RAM_MAX/1GB, 2)

$Taille_RAM_LIBRE=[String]((Get-WmiObject -Class Win32_OperatingSystem).FreePhysicalMemory)
$Taille_RAM_LIBRE = [math]::round($Taille_RAM_LIBRE/1MB, 2)

$Taille_RAM_UTILISE=[STRING]($Taille_RAM_MAX - $Taille_RAM_LIBRE) + " GB utilisée"
#}
#réseaux :
$Network =  $((Get-Counter).CounterSamples | Where-Object {$_.CookedValue -ne "0" -and $_.Path -like "*octets/s*"}) 
$Network_KB = [math]::round($Network.CookedValue/1KB,2)
$Network_MB = [math]::round($Network.CookedValue/1MB,6)
$Utilisation = $Network.InstanceName + "  utilise $Network_KB KB ($Network_MB MB) de bande  passante"

#On liste les mises à jours installées sur le poste
$KB = [string](Get-WmiObject -Class Win32_QuickFixEngineering -Filter "Description= 'Update'").HotFixID | Sort-Object -Property InstalledOn

Add-Content -Value @"

Version du build de l'OS : $Build_OS

Version de l'OS : $OS_Version

Nom du processeur : $Process_Info

Espace de stockage disponible restant sur le C: $Storage_FreeSpace GB
 
Processeur utilisé : $Processeur
 
Mémoire maximum de la machine : $Taille_RAM_MAX GB
 
Mémoire Libre : $Taille_RAM_LIBRE GB
 
Mémoire utilisée : $Taille_RAM_UTILISE

Liste des KB de mises à jour installées sur le poste : $KB
 
L'interface $Utilisation
 
"@ -path $fichier_sortie

