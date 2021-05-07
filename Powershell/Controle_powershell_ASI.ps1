#PARTIE 1 :
#1
echo "Bonjour ! Bienvenue sur ma calculette Version 0.0"


#2
[int] $a= read-host "Rentrer un nombre afin qu'elle soit sauvegarder dans une variable"



#3
[int] $b= read-host "Rentrer un nombre afin qu'elle soit sauvegarder dans une deuxième variable"



#4
$c= $a + $b


#5
echo "$a + $b = $c"


#6
	if ($a -gt $b)
		{
		write-host "a est plus grand que b"
		}

	elseif ($a -lt $b)
		{
		write-host "a est inferieur a b"
		}


	elseif ($a -eq $b) 
		{	
		echo "a et b sont egaux"
		}

#7
$tab = $a,$b,$c


#8
@($tab) | sort -descending


#PARTIE 2 :
#9
get-process > Process_log.txt

#10
get-process | Sort-Object CPU -Descending | select -First 10 > cpu_log.txt


#11
$log=Get-ChildItem "*log.txt"


#12
If (-not (Test-Path "C:\temps")) 
{ New-Item -path "C:\" -Name "temps" -ItemType directory}
else
{echo "le dossier existe"}


$Source = ""
$Destination = "C:\temps"
foreach ($Fichier in $log) 
{
  Copy-Item "$($Fichier.Name)" -Destination "$($Destination )\$($Fichier.Name)"
}
