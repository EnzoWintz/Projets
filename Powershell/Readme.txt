Description de ce que fait chaque scripts dans ce dossier : 

- Archive_Data.ps1 : Le but va être de copier mes données depuis mon NAS et de les basculer sur mon disque dur et de créer une archive mensuelle,
                     j'ai spéicifié des dossiers d'exclusions car il n'était pas nécessaire de les ajouter à l'archive .zip qui sera créée.
                     Un fichier de log sera créer afin de faire du débugage.
                     
- Purge_CAM.ps1 : Ce script va purger le dossier ou sont les fichiers vidéos de la caméra et permettre une rétention de 7 jours mais il s'exécutera s'il voit que le dossier
                  en question a une volumétrie égal ou supérieur à 500 Go, un fichier de log sera généré.

- Sauvegarde_Data.ps1 : Ce script va sauvegarder les éléments contenu dans les dossiers "Bureau" ; "Documents"; "Images" et "Vidéos" sur mon NAS.
                        Un fichier de log sera généré également.
                        
A savoir que chaque scripts ont été incorporés au sein de tâches planifiés automatisant au maximum et limitant les opérations manuelles

- Lecture_log.ps1 : Le script Lecture_log.ps1 s'inscrivait dans une thématique de soucis de mise à niveau, certaines informations ont été volontairement anonymisées par respect                     de confidentialité,
                    Le but de ce script est de vérifier dans les logs SCCM certains mots clé à la suite de l'enclenchement d'une séquence de tâche dans le cadre de la mise à                         niveau vers la 1909 de Windows 10. En fonction du résultat de la recherche (affiné avec l'utilisation de Regex), des étapes seront retournées au prompt afin                     d'une meilleure prise en charge.
                    
- MajPoliciesSCCM.ps1 : Ce script va mettre à jour les stratégies du client SCCM sur le poste de l'utilisateur avec indication ou se trouvent le résultat de ces commandes dans
                        les logs du client SCCM.

- Icones_blanches.ps1 : Ce script traitait des soucis d'icônes blanche, il supprimait les icônes blanches en question et les copies par des icônes valide (des informations ont été anonymisées par respect de confidentialité).

- Controle_powershell_ASI.ps1 : Ce script a été réalisé dans le cadre d'un contrôle lors de mon année de bachelor

- DeleteProfil.ps1 : Ce script permettra la suppression d'un profil windows en local

- Uninstall_Appli_With_Progress_Bar.ps1 : Ce script prendra pour exemple la désinstallation de toute les versions de Java sur un poste incluant du Multithread couplé à une barre de progression en fonction des étapes auquelles le script se situ

- Purge_Profil_Multiple_Choix_Barre_De_Progression.ps1 : Ce script revisite la suppression de profil windows avec la fusion de 3 actions en un seul script : Le renommage, la suppression de profil sans renommage et la suppression du dossier renommer le tout avec une barre de progression.

- Dans le dossier WMI se trouver les scripts utilisant les requêtes WMI

- Dans le dossier BDF_TOOLS se trouve mon projet en Powershell qui correspond à la réalisation d'un outil permettant la résolution d'incidents dans le cadre de mon année d'alternance au sein de la Banque De France.

