package powertop

import (
	"encoding/csv"
	"io"
	"log"
	"os"

	"github.com/influxdata/telegraf"
	"github.com/influxdata/telegraf/plugins/inputs"
)

type Powertop struct {
	Usage    string `csv:"Usage"`
	Events   string `csv:"Events"`
	Category string `csv:"Category"`
	Desc     string `csv:"Description"`
	PW       string `csv:"PW_Estimate"`
}

func (p *Powertop) Description() string {
	return "Gather Powertop infos"
}

func (p *Powertop) SampleConfig() string {
	return ""
}

func (p *Powertop) Gather(acc telegraf.Accumulator) error {

	csvFile, err := os.Open("/opt/telegraf/plugins/inputs/powertop/powertop.csv")
	if err != nil {
		log.Fatal(err)
	}

	reader := csv.NewReader(csvFile)
	defer csvFile.Close()

	for {
		itt, error := reader.Read()
		if error == io.EOF {
			break
		} else if error != nil {
			log.Fatal(error)
		}

		fields := map[string]interface{}{
			"Usage":    itt[0],
			"Events":   itt[1],
			"Category": itt[2],
			"Desc":     itt[3],
			"PW":       itt[4],
		}

		acc.AddFields("powertop", fields, nil)
	}

	return nil
}

func init() {
	inputs.Add("powertop", func() telegraf.Input {
		return &Powertop{}
	})
}
