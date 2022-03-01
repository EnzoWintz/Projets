#commande pour exporter notre job : 
java -jar jenkins-cli.jar -s http://localhost:8080 -auth root:rootroot get-job DM-February > DM-February.xml

#cette commande a été exécuté en local sur notre instances EC2

#commande pour créer un job à partir de notre fichier de configuration
java -jar jenkins-cli.jar -s http://localhost:8080 -auth root:rootroot create-job DM-February_import < DM-February.xml

#Cette commande a été exécuter en local sur notre instance EC2
