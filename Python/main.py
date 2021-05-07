import os
import cv2

def update(): #installation des mises_à_jours
    os.system("sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y")

def install_opencv(): #installation de opencv
    os.system("sudo apt install -y")
    os.system("pip install python-opencv")
    os.system("sudo apt install -f")


def watermark_photo(input_image, output_image, watermark_image, position): #traitement de l'image
    base_image = Image.open(input_image)
    watermark = Image.open(watermark_image)

    base_image.paste(watermark, position, mask=watermark)
    base_image.save(output_image)

update()
install_opencv()


import time
from PIL import Image

cam = cv2.VideoCapture(0)
cv2.namedWindow("Photomaton")

img_counter = 0

while True:
    ret, frame = cam.read()
    cv2.imshow("Capture", frame)
    if not ret:
        break
    k = cv2.waitKey(1)

    if k%256 == 27:     #Si Echap est appuye
        print("Fermeture...")
        break
    elif k%256 == 32:   #Si Espace est appuye
        print("3..")
        time.sleep(1)
        print("2..")
        time.sleep(1)
        print("1..")
        time.sleep(1)
        img_name = "Photo_n_{}.png".format(img_counter)
        cv2.imwrite(img_name, frame)
        print("Photo prise !".format(img_name))
        watermark_photo(img_name, 'output_{}.png'.format(img_counter), 'SDV.png', position=(15,15))
        #Convertissement de l'image en monochrome puis en binaire
        img = cv2.imread (img_name, 2)
        ret, bw_img = cv2.threshold(img,66,190,cv2.THRESH_BINARY)
        cv2.imwrite('img2.jpeg', bw_img)
        img_counter+=1

cam.release()
cv2.destroyAllWindows()
