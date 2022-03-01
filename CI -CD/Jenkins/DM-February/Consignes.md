# DM28-02
# Devoir Maison CICD Février 2022

## Devoir maison Cycle de vie, préparation à l'échec

### Modalités

Le rendu de cet exercice sera un dépôt **privé** git sur gitlab.com en tant que tel. Pour ça, vous m'ajouterez dans Gitlab en tant que "Mainteneur" de votre projet. Mon nom d'utilisateur est @tsaquet. Ainsi j'aurais accès à tous vos commits et à tout votre travail.

C'est à rendre en binôme.

La pertinence des commits et la clarté des messages sera prise en compte dans la notation. (Des commits qui concernent des éléments unitaires et qui sont bien commentés seront appréciés !)

Ajoutez un fichier NOMS dans le dépôt qui contient vos noms et prénoms (des deux binômes) afin que je puisse déterminer qui vous êtes (le pseudo gitlab n'aide pas toujours)

Le devoir est à rendre pour le lundi 28 février à 23h00 au plus tard !

### Objectif

L'objectif est de mettre à disposition plusieurs services :

- Un site web basé sur nginx (qui affiche une phrase simple, l'idée n'est pas de développer un site !)
Basé sur un Dockerfile depuis l'image ubuntu.
Il doit être disponible sur l'adresse nginx.local

- Un site web basé sur apache (même chose que pour nginx)
Basé directement sur une image qui va bien
Il doit être disponible sur l'adresse apache.local

- Un Whoami
Il doit être disponible sur l'adresse prenomdunbinome.nomdubinome.local

- Une instance de NodeRed un outil d'automatisation basé sur un système de noeuds en low code. (C'est à dire qu'en principe il n'y a pas besoin de coder pour utiliser cet outil, ça peut arriver pour certains cas précis / complexes. C'est un outil qui peut être utilisé pour faire de la domotique à la maison, ou encore pour automatiser les actions d'un live twitch, il est très polyvalent.)
Il doit être disponible sur l'adresse nodered.local

Pour réaliser ça dans de bonnes conditions, nous souhaitons placer ces différents services derrière un Reverse-Proxy. Pour cela, nous allons utiliser **Traefik** et **Docker Compose**.

L'instance de Traefik sera LA SEULE à avoir ses ports ouverts et publiés.

Tout ça doit être préparé et déployé automatiquement à l'aide d'un pipeline Gitlab et d'un pipeline Jenkins
Le pipeline Gitlab se déclenchera à chaque commit.
Le Job Jenkins basé sur le pipeline se déclenchera une fois par jour.

### Rendu

Le dépôt git devra contenir :

- Le ou les Dockerfile(s) nécessaires
- Le fichier docker-compose.yml qui permet de tout lancer
- Le fichier .gitlab-ci.yml pour Gitlab
- Le fichier Jenkinsfile pour Jenkins
- Les différents fichiers nécessaires pour que tout se fasse correctement
- L'export du job Jenkins pour que quelqu'un puisse le réimporter facilement (à vous de trouver le plugin qui permet de faire ça et de le documenter dans le README.md demandé à la ligne en dessous)
- Un README.md qui explique les éventuelles configurations à effectuer en plus pour que tout fonctionne.

### Etapes

#### Etape 1 : Traefik

_Objectif_ : Via docker-compose, mettre en place Traefik et afficher son Dashboard sur votre localhost, port 8080.
Vous pouvez trouver toutes les instructions nécessaires dans la documentation de Traefik.

ATTENTION : il existe plusieurs version de Traefik et les instructions à utiliser (par exemple dans le docker-compose) changent avec la V2. C'est cette V2 que vous devez utiliser. Attention aux ressources que vous allez trouver, il en existe encore beaucoup à propos de la V1.

#### Etape 2 : Whoami

_Objectif_ : Via le même fichier docker-compose, mettre en place l'outil "whoami" de Traefik. Il doit s'afficher lorsque vous entrez une adresse formatée comme ceci : votreprenom.votrenom.local
Vous pouvez trouver toutes les instructions nécessaires dans la documentation de Traefik.

#### Etape 3 : Node-Red

_Objectif_ : Faire démarrer un conteneur NodeRed avec les deux autres
Ici vous devez trouver comment placer Nodered derrière Traefik en vous inspirant de ce que vous aurez fait pour Whoami.

#### Etape 4 : Apache

_Objectif_ : Ajouter un site web déployé sur Apache derrière votre Traefik qui affiche une page HTML avec une phrase de votre choix.

#### Etape 4 : Nginx

_Objectif_ : Ajouter un site web déployé sur Nginx derrière votre Traefik, à partir d'une image Docker construite à partir de l'image Docker Ubuntu. Le site doit afficher une phrase de votre choix.

#### Etape 5 : Gitlab

_Objectif_ : Créer un projet git hébergé par gitlab.com. Ajouter un .gitlab-ci.yml qui permet de dérouler les étapes suivantes à chaque commit :
Build
- Création de l'image pour le serveur Nginx
Test Integration
- Test de la présence des fichiers nécessaires au déploiement
Deploy
- Déploiement du docker-compose sur la machine hôte
Test Fonctionnel
- Vérifier que le site Apache affiche la bonne phrase
_Aide_ : Pour cette étape, vous pouvez utiliser la Container Registry liée au projet sur gitlab.com. Vous devez créer des runners sur vos machines et les associer à votre projet sur gitlab.com via les menus d'administration, sinon vous ne pourrez pas faire tout ce qui est demandé.

#### Etape 6 : Jenkins
_Objectif_ : Utiliser une instance de Jenkins pour créer un Job Pipeline qui effectue les mêmes étapes que sur gitlab.com.
Le plugin Pipeline de Jenkins permet d'ajouter à Jenkins une fonctionnalité très proche de celle du pipeline vue sur Gitlab.
Le Pipeline se base sur un fichier Jenkinsfile qui peut avoir deux formats différents qui sont décrits ici :
https://www.jenkins.io/doc/book/pipeline/syntax/

La syntaxe "Declarative Pipeline" qui est la plus simple des deux.
La syntaxe "Scripted Pipeline", basée sur Groovy qui permet de faire plus de choses mais qui est plus complexe.

Vous pouvez choisir la syntaxe qui vous convient le mieux et/ou qui vous permet de répondre à la consigne.

_Aide_ : Le plugin Pipeline ajoute un nouveau type de Job dans Jenkins. Ce type de job a la particularité de permettre d'aller récupérer un fichier Jenkinsfile directement depuis un dépôt git et d'éxécuter le Job grâce à lui.
Pour ce devoir, comme mentionné au début de ce document, vous devez créer un dépôt **privé**. Il vous faudra alors permettre à Jenkins de s'authentifier sur votre dépôt gitlab.com, vous pouvez ajouter des "identités" dans l'administration de Jenkins.

### Notation

Le devoir sera noté de la façon suivante :
- Le/les Dockerfiles nécessaires : 2 pts
- Le fichier docker-compose.yml : 4 pts
- Le fichier .gitlab-ci.yml : 5 pts
- Le fichier Jenkinsfile : 5 pts
- Le job jenkins exporté : 2 pts
- La qualité et la rigueur du travail : 2 pts

### Aide supplémentaire

La plupart des éléments demandés ont beaucoup d'exemples et de documentation en ligne. En cherchant et lisant attentivement les éléments en ligne, vous devriez gagner beaucoup de temps. Par exemple, pour la partie Traefik / Whoami, vous devez trouver un fichier en ligne qui contient déjà tout ce qu'il faut faire.

### Durée de travail

La durée de travail totale estimée est entre 3 et 4h.