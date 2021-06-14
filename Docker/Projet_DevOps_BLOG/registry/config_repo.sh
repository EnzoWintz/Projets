#!/bin/bash
#variables d'environnement pour se connecter au registry
REGISTRY_LOGIN=globalnet
REGISTRY_PWD=globalnet
REGISTRY_HOSTNAME=localhost:5000

IMG_DB1=mariadb_sdv_node1:latest
IMG_DB2=mariadb_sdv_node2:latest
IMG_DB3=mariadb_sdv_node3:latest

IMG_WEB1=apache-php_host1_sdv:latest
IMG_WEB2=apache-php_host2_sdv:latest
IMG_WEB3=apache-php_host3_sdv:latest

IMG_INFLUX=influxdb_sdv:latest

IMG_TAG_DB1=localhost:5000/mariadb_sdv_node1:1
IMG_TAG_DB2=localhost:5000/mariadb_sdv_node2:1
IMG_TAG_DB3=localhost:5000/mariadb_sdv_node3:1

IMG_TAG_WEB1=localhost:5000/apache-php_host1_sdv:1
IMG_TAG_WEB2=localhost:5000/apache-php_host2_sdv:1
IMG_TAG_WEB3=localhost:5000/apache-php_host3_sdv:1

IMG_TAG_INFLUX=localhost:5000/influxdb_sdv:1

IMG_PUSH_DB1=$IMG_TAG_DB1
IMG_PUSH_DB2=$IMG_TAG_DB2
IMG_PUSH_DB3=$IMG_TAG_DB3

IMG_PUSH_WEB1=$IMG_TAG_WEB1
IMG_PUSH_WEB2=$IMG_TAG_WEB2
IMG_PUSH_WEB3=$IMG_TAG_WEB3

IMG_PUSH_INFLUX=$IMG_TAG_INFLUX

#Connexion au registry docker afin de pouvoir push nos images
docker login $REGISTRY_HOSTNAME -u $REGISTRY_LOGIN -p $REGISTRY_PWD

#Boucle for qui va traiter les info
#$IMG_TELE
for i in "$IMG_DB1" "$IMG_DB2" "$IMG_DB3" "$IMG_WEB1" "$IMG_WEB2" "$IMG_WEB3" "$IMG_INFLUX"
do 
   if [ "$i" == "$IMG_DB1" ]
   then 
#On tag notre image   
       docker tag $IMG_DB1 $IMG_TAG_DB1
       
#On push notre image sur le registry
       docker push $IMG_PUSH_DB1

#On supprime notre image de notre environnement local
       docker rmi $IMG_DB1

#On pull notre image de notre registry pour la réutiliser en local
       docker pull $REGISTRY_HOSTNAME/$IMG_PUSH_DB1

   elif [ "$i" == "$IMG_DB2" ]
   then 
#On tag notre image   
       docker tag $IMG_DB2 $IMG_TAG_DB2

#On push notre image sur le registry
       docker push $IMG_PUSH_DB2

#On supprime notre image de notre environnement local
       docker rmi $IMG_DB2

#On pull notre image de notre registry pour la réutiliser en local
       docker pull $REGISTRY_HOSTNAME/$IMG_PUSH_DB2

   elif [ "$i" == "$IMG_DB3" ]
   then 
#On tag notre image   
       docker tag $IMG_DB3 $IMG_TAG_DB3

#On push notre image sur le registry
       docker push $IMG_PUSH_DB3

#On supprime notre image de notre environnement local
       docker rmi $IMG_DB3

#On pull notre image de notre registry pour la réutiliser en local
       docker pull $REGISTRY_HOSTNAME/$IMG_PUSH_DB3

   elif [ "$i" == "$IMG_WEB1" ]
   then   
       docker tag $IMG_WEB1 $IMG_TAG_WEB1
    
       docker push $IMG_PUSH_WEB1
 
       docker rmi $IMG_WEB1

       docker pull $REGISTRY_HOSTNAME/$IMG_PUSH_WEB1
   elif [ "$i" == "$IMG_WEB2" ]
   then   
       docker tag $IMG_WEB2 $IMG_TAG_WEB2
    
       docker push $IMG_PUSH_WEB2
 
       docker rmi $IMG_WEB2

       docker pull $REGISTRY_HOSTNAME/$IMG_PUSH_WEB2

   elif [ "$i" == "$IMG_WEB3" ]
   then   
       docker tag $IMG_WEB3 $IMG_TAG_WEB3
    
       docker push $IMG_PUSH_WEB3
 
       docker rmi $IMG_WEB3

       docker pull $REGISTRY_HOSTNAME/$IMG_PUSH_WEB3

   elif [ "$i" == "$IMG_INFLUX" ]
   then   
       docker tag $IMG_INFLUX $IMG_TAG_INFLUX
    
       docker push $IMG_PUSH_INFLUX
 
       docker rmi $IMG_INFLUX

       docker pull $REGISTRY_HOSTNAME/$IMG_PUSH_INFLUX

   else
      echo "Erreur, merci de vérifier le nom des images"
   fi
      
done

#Déconnexion du registry docker
#docker logout

