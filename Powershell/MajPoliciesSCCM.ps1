cls

##################################
#                                #
#  Script Policies Client SCCM   #
#                                #
#        Client SCCM             #         
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


#On récupère le nom de la machine via les variables d'environnement
$machine=$env:computername

#Lancement du HeartBeat
$HearBeat = '{00000000-0000-0000-0000-000000000003}'|% {Invoke-WMIMethod -ComputerName $machine -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule $_} -ErrorAction SilentlyContinue


#On lance le Heartbeat, si c'est OK il fera les autres actions sinon il se stoppera
if ($HearBeat)
    {
    #Le log se trouve dans "C:\Windows\CCM\Logs\InventoryAgent.log"
    writestatus "Lancement du HeartBeat" $true
    
    sleep 2

    #Stratégie ordinateur + cycle d'évaluation
    #Les logs se trouvent dans "C:\Windows\CCM\Logs\PolicyAgent.log" et "C:\Windows\CCM\Logs\PolicyEvaluator.log"
    '{00000000-0000-0000-0000-000000000021}','{00000000-0000-0000-0000-000000000022}'|% {Invoke-WMIMethod -ComputerName $machine -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule $_} | Out-Null
    writestatus "Récupération de stratégie ordinateur et cycle d'évaluation" $true

    sleep 2
       
    #MAJ logiciels
    #Le log se trouve dans "C:\Windows\CCM\Logs\UpdatesDeployment.log"
    '{00000000-0000-0000-0000-000000000108}'|% {Invoke-WMIMethod -ComputerName $machine -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule $_} | Out-Null
    writestatus "Cycle d'évaluation des déploiements de mises à jours logiciels" $true

    sleep 2
    
    #Lancement policies Déploiement applications
    #Le log se trouve dans "C:\Windows\CCM\Logs\AppIntentEval.log"
    '{00000000-0000-0000-0000-000000000121}'|% {Invoke-WMIMethod -ComputerName $machine -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule $_} | Out-Null
    writestatus "Cycle d'évaluation du déploiement de l'application" $true
    
    sleep 2
    
    writestatus "Fin du script" $true

    }
else 
{
writestatus "Lancement du HeartBeat négatif" $false
Write-Host "Merci de vérifier le client SCCM" -foregroundcolor Yellow
}

