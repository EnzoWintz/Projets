# coding: utf-8
#Vérification des mises-à-jour avec installation des package cups et autre configuration
import os


from tkinter import * 
# Création d'une fenêtre
racine = Tk()

#Création de la frame
frame = Frame(racine, bg='#E0D2CF')
title = Frame(racine, bg='#C4F5E1', bd=10, relief=RIDGE)
title.pack(expand=YES)
frame.pack(expand=YES)

#titre de la fenêtre
racine.title("Impression de la photo")
racine.geometry("720x520") #taille de la fenêtre lors de l'exécution du script
racine.minsize(480, 360) #taille minimale de la fenêtre
racine.iconbitmap("Logo.ico") #insertion du logo
racine.config(background='#E0D2CF') #couleur arrière plan

#Ajout de texte, il s'agit du titre 
label_title = Label(title, text='Menu pour impression', background='#C4F5E1', font=("Courrier",40))
label_title.pack(expand=YES)

#ajout d'un second texte 
label_subtitle = Label(title, text='Différentes catégories :', background='#C4F5E1', font=("Courrier",25))
label_subtitle.pack(expand=YES, pady=20)
  
def level():
    #import main

    top = Toplevel() #cela va ouvrir une nouvelle page
    top.title("Prise de photo") #titre de la page
    top.iconbitmap("Logo.ico") #on insère le logo comme sur la page d'accueil
    top.geometry("520x420") #on détermine les dimensions de la page lors de l'ouveture de celle-ci

    msg = Message(top)
    msg.pack()

    title2 = Frame(top, bg='#C4F5E1', bd=5, relief=RIDGE)
    title2.pack(expand=YES)

    label_title2 = Label(title2, text='Voulez-vous prendre une photo ?', background='#C4F5E1', font=("Courrier",25))
    label_title2.pack(expand=YES) #cela permettra d'éviter certains problème lors de la diminution de la fenêtre

    Interro = Frame(top)
    Interro.pack(expand=YES)

    button2 = Button(Interro, text="OUI", relief=RAISED, borderwidth=3, width=10) #le bouton va fermer la page mais ne quittera pas le programme
    button2.pack(side=LEFT, pady=10)

    button = Button(Interro, text="NON", command=top.destroy, relief=RAISED, borderwidth=3, width=10) #le bouton va fermer la page mais ne quittera pas le programme
    button.pack(side=RIGHT, pady=10)

    button = Button(top, text="Fermer la page", command=top.destroy, relief=RAISED, borderwidth=3, width=16) #le bouton va fermer la page mais ne quittera pas le programme
    button.pack(side= BOTTOM, pady=15)

#2ème page 
def level2():
    #import main # A COMPLETER AVEC LE FICHIER D'impression

    top2 = Toplevel() #cela va ouvrir une nouvelle page
    top2.title("Impression de la photo") #titre de la page
    top2.iconbitmap("Logo.ico") #on insère le logo comme sur la page d'accueil
    top2.geometry("520x420") #on détermine les dimensions de la page lors de l'ouveture de celle-ci

    msg2 = Message(top2)
    msg2.pack()

    title3 = Frame(top2, bg='#C4F5E1', bd=5, relief=RIDGE)
    title3.pack(expand=YES)

    label_title3 = Label(title3, text='Voulez-vous imprimer la photo ?', background='#C4F5E1', font=("Courrier",25))
    label_title3.pack(expand=YES) #cela permettra d'éviter certains problème lors de la diminution de la fenêtre

    Interro2 = Frame(top2)
    Interro2.pack(expand=YES)

    #Impression de la photo
    button3 = Button(Interro2, text="OUI", command=os.system("lpr -o fit-to-page img2.jpeg"), relief=RAISED, borderwidth=3, width=10) #le bouton va fermer la page mais ne quittera pas le programme
    button3.pack(side=LEFT, pady=10) 

    button4 = Button(Interro2, text="NON", command=top2.destroy, relief=RAISED, borderwidth=3, width=10) #le bouton va fermer la page mais ne quittera pas le programme
    button4.pack(side=RIGHT, pady=10)

    button = Button(top2, text="Fermer la page", command=top2.destroy, relief=RAISED, borderwidth=3, width=16) #le bouton va fermer la page mais ne quittera pas le programme
    button.pack(side= BOTTOM, pady=15)


#Ajout du menu de boutons 
B1 = Button(frame, text ="1 - Prendre une photo", relief=RAISED, borderwidth=3, width=20).pack(pady=5)
B2 = Button(frame, text ="2 - Impression de la photo", relief=RAISED, borderwidth=3, width=20, command=level2).pack(pady=5)



# bouton de sortie
bouton=Button(frame , text="Fermer l'application", command=racine.quit, borderwidth=3, width=16)
bouton.pack(side= BOTTOM, pady=15)

# Affichage fenêtre
racine.mainloop()