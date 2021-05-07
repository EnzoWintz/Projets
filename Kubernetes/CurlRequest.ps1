
$InterServ = curl 127.0.0.1:30000

#Boucle infinie qui se répète toute les 60 secondes grâce au sleep
while ($InterServ)
    {
    curl 127.0.0.1:30000
    sleep 60
    } 