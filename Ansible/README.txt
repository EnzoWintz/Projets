docker build -t ubuntu1804_web .

docker build -t ubuntu1804_db .

docker run --name=host_web -tid ubuntu1804_web bash

docker run --name=host_db -tid ubuntu1804_db bash

docker inspect host_web ==> 172.17.0.6

docker inspect host_db ==> 172.17.0.7

vi /etc/hosts et on ajoute nos IP d'hosts :

172.17.0.6 host_web
172.17.0.7 host_db

On copie notre clé ssh sur chaque host:
ssh-copy-id -i ~/.ssh/id_rsa.pub root@172.17.0.6
ssh-copy-id -i ~/.ssh/id_rsa.pub root@172.17.0.7

Ajout de : 

[host_web]
172.17.0.6

[host_db]
172.17.0.7

res_apache
apache2.conf.j2

become_user: apache


Dans le fichier /etc/ansible/hosts pour la communication (un fichier host sera créé par la suite propre au playbook)
verifier la bonne connexion entre ansible et nos hosts :
ansible  host_web -m ping -u root
ansible  host_db -m ping -u root

on crée l'aborescence Ansible avec divers mkdir

On va créer un fichier secret.yml pour sauvegarder nos variables sécurisées :
mot de passe vault : toto

Pour Editer le vault : 
ansible-vault edit playbooks/vars/secret.yml 

On joue le playbook : 
ansible-playbook -i lamp_hosts --ask-vault-pass playbooks/main.yml -v --diff


ARBORESCENCE :


.
├── Connexion_check.txt
├── Dockerfile
├── README.txt
├── ansible.cfg
├── lamp_hosts
├── playbooks
│   ├── main.yml
│   └── vars
│       └── secret.yml
└── roles
    ├── Apache
    │   ├── handlers
    │   │   └── main.yml
    │   ├── tasks
    │   │   ├── apache.yml
    │   │   └── main.yml
    │   └── templates
    │       └── apache2.conf.j2
    ├── Mysql
    │   └── tasks
    ├── Php
    │   ├── tasks
    │   │   ├── main.yml
    │   │   └── php.yml
    │   └── templates
    │       └── index.php.j2
    └── comptes_service
        └── tasks
            └── main.yml


