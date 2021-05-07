Description de ce que fait chaque scripts dans ce dossier : 

- Archive_Data.ps1 : Le but va être de copier mes données depuis mon NAS et de les basculer sur mon disque dur et de créer une archive mensuelle,
                     j'ai spéicifié des dossiers d'exclusions car il n'était pas nécessaire de les ajouter à l'archive .zip qui sera créée.
                     Un fichier de log sera créer afin de faire du débugage.
                     
- Purge_CAM.ps1 : Ce script va purger le dossier ou sont les fichiers vidéos de la caméra et permettre une rétention de 7 jours mais il s'exécutera s'il voit que le dossier
                  en question a une volumétrie égal ou supérieur à 500 Go, un fichier de log sera généré.

- Sauvegarde_Data.ps1 : Ce script va sauvegarder les éléments contenu dans les dossiers "Bureau" ; "Documents"; "Images" et "Vidéos" sur mon NAS.
                        Un fichier de log sera généré également.
                        
A savoir que chaque scripts ont été incorporés au sein de tâches planifiés automatisant au maximum et limitant les opérations manuelles
