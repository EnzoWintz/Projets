//Base du serveur
//appel du package main
package main

//on appelle les différentes librairies
import (
	"fmt"
	"io/ioutil"
	"net/http"
)

//On déclare notre slice faisant référence à notre struct Task le tout dans une variable
var tasks = make(map[string]Task)

func main() {

	//On définie nos 3 HandleFunc
	http.HandleFunc("/", list)
	http.HandleFunc("/done", done)
	http.HandleFunc("/add", add)

	//On appelle notre fonction ListenAndServe
	http.ListenAndServe(":8000", nil)

}

//On définie notre fonction list en référence au http.HandleFunc
func list(rw http.ResponseWriter, _ *http.Request) {
	//On va créer notre chaine de caractères
	tasks = map[string]Task{
		{"ID": 0}, "task": "Faire les courses",
		{"ID": 1}, "task": "Payer les factures",
	}

	//On met une condition qui affiche les tâches qui ne sont pas terminés
	if tasks == false {
		return
	}

	//On initialise notre réponse du header au client
	rw.WriteHeader(http.StatusOK)

	//On écrit notre réponse qui sera renvoyée
	reponse, err := rw.Write(tasks)

	if err != nil {

		return
	}
	//On effectue la conversion en byte
	reponseBytes := []byte(reponse)

}

//On fait notre fonction add qui n'acceptera que des requêtes POST
func add(rw http.ResponseWriter, r *http.Request) {

	//On vérifie que l'on fait bien appelle à la méthode POST
	//On créé une variable qui permettra et sera utilisée pour vérifier s'il s'agit d'une méthode POST ou non
	Verif := rw.WriteHeader(http.MethodePost)

	//boucle qui vérifie qu'il s'agit d'une méthode POST
	if Verif != rw.MethodePost {
		fmt.Println("Il ne s'agit pas d'une méthode POST")
		rw.WriteHeader(http.StatusBadRequest)
		return
	}

	//On effectue la lecture du corps de la requête
	body, err := ioutil.ReadAll(rw.Body)
	if err != nil {
		fmt.Printf("Error reading body: %v", err)
		http.Error(
			rw,
			"can't read body", http.StatusBadRequest,
		)
		return
	}

	//On affiche le résultat si tout s'est bien passé
	rw.WriteHeader(http.StatusOK)

	//tester le add de notre fonction et ainsi tester la requête
	Testadd, err := http.NewRequest("POST", "http://localhost:8080/add", nil)
	if err != nil {
		fmt.println("POST ne fonctionne pas")
	}
	fmt.println("POST fonctionne")

}

//On fait notre fonction done
func done(w http.ResponseWriter, r *http.Request) {
	//On initialise notre switch
	switch r.Method {
	case "GET":
		//On met une condition qui affiche les tâches qui terminées
		for u := range tasks {
			if tasks == true {
				return
			}
		}
	case "POST":
		//On lit le body
		body, err := ioutil.ReadAll(w.Body)
		if err != nil {
			fmt.Printf("Error reading body: %v", err)
			http.Error(
				w,
				"can't read body", http.StatusBadRequest,
			)
			return
		}
	default:
		//On définit notre message par défaut
		w.WriteHeader(http.StatusBadRequest)
	}
}

//On definie notre structure task

type Task struct {
	Description string
	Done        bool
}
