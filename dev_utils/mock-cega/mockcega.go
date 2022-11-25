package main

import (
	"context"
	"encoding/json"
	"fmt"
	"math/rand"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	amqp "github.com/rabbitmq/amqp091-go"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/viper"
)

var (
	datasetGroups []string
	onemessage    []interface{}
	conf          config
)

type config struct {
	mockhost string
	messages int
	queues   string
	vhost    string
	user     string
	password string
	port     string
	dataset  string
}

func failOnError(err error, msg string) {
	if err != nil {
		log.Panicf("%s: %s", msg, err)
	}
}

// Function for creating the list of queues that will be checked for messages
func usedQueues() []string {
	var q []string
	// check if should send message for ingestion, accession ids or dataset ids
	if strings.Contains(conf.queues, "ingest") {
		q = append(q, "inbox")
	}

	if strings.Contains(conf.queues, "accessionid") {
		q = append(q, "verified")
	}

	if strings.Contains(conf.queues, "mapping") {
		if conf.dataset == "manual" {
			q = append(q, "stableIDs")
		} else {
			q = append(q, "completed")
		}
	}

	return q
}

// Function for returning the values of
// enviroment variables in config type
// TODO: Add errors for missing env vars
func envVal() {
	viper.AutomaticEnv()
	conf.messages = viper.GetInt("COMPLETED_MESSAGES")
	conf.mockhost = viper.GetString("MOCKHOST")
	conf.vhost = viper.GetString("MQ_VHOST")
	conf.user = viper.GetString("MQ_USER")
	conf.password = viper.GetString(("MQ_PASSWORD"))
	conf.port = viper.GetString("MQ_PORT")
	conf.queues = viper.GetString("CEGA_RESPONSE")
	conf.dataset = viper.GetString("DATASETID")
}

// Function for generating accession ids
func generateIds(queue string) string {
	egaInt := 12000000000 + rand.Intn(1000)
	strNumber := strconv.Itoa(egaInt)
	id := ""
	if queue == "verified" {
		id = "EGAF" + strNumber
	} else {
		id = "EGAD" + strNumber
	}
	return id
}

// Function for checking if a string exists in an array
func contains(list []string, str string) bool {
	for _, value := range list {
		if value == str {
			return true
		}
	}
	return false
}

// Function for getting all the messages from the "completed" queue
// and create one message with all of them included
func getAllMessages(msgs <-chan amqp.Delivery, channel *amqp.Channel) {
	// Consume messages from the queue and create one message
	for delivered := range msgs {
		var message map[string]interface{}

		err := json.Unmarshal(delivered.Body, &message)
		failOnError(err, "Failed to unmarshal the message")
		log.Printf("Received a message from completed queue: %s", delivered.Body)

		// Append the delivered message to the one big message
		onemessage = append(onemessage, message)

		// Check if the datasetType(user or filepath) exists in the datasetGroups list and if
		// it is not then add it
		var datasetType string
		if conf.dataset == "user" {
			datasetType = message[conf.dataset].(string)
		} else {
			// Get only the directory of the filepath
			datasetType = filepath.Dir(message[conf.dataset].(string))
		}
		exists := contains(datasetGroups, datasetType)
		if !exists {
			datasetGroups = append(datasetGroups, datasetType)
		}

		// When the number of messages received from the "completed" queue
		// is equal to the number we want then create the new messages for mapping
		if len(onemessage) == conf.messages {
			dataSetMsgs(onemessage, datasetGroups, channel, delivered.CorrelationId)
		}
	}
}

// Function for creating messages for mapping from the one big message.
// The number of the new messages is equal to the number of different
// datasetGroups (the same dataset id will be given to all files that this user uploaded)
func dataSetMsgs(unMarBody []interface{}, datasetGrps []string, channel *amqp.Channel, corrid string) {
	// Loop over the array of different datasetGrps
	for _, dG := range datasetGrps {
		message := make(map[string]interface{})
		var ids []string
		// Loop through all the messages and add in an array all the accessions ids
		// from the datasetGroup
		for _, dataset := range unMarBody {
			ds := dataset.(map[string]interface{})
			if conf.dataset == "user" && dG == ds["user"] {
				ids = append(ids, ds["accession_id"].(string))
			} else if conf.dataset == "filepath" {
				// Get only the directory of the filepath
				fpath := filepath.Dir(ds["filepath"].(string))
				if dG == fpath {
					ids = append(ids, ds["accession_id"].(string))
				}
			}
		}

		// Create a dataset id
		datasetID := generateIds("completed")

		// Add the necessary info to the new message
		message["type"] = "mapping"
		message["dataset_id"] = datasetID
		message["accession_ids"] = ids

		// Marshal the new body whith all the information
		createdBody, err := json.Marshal(message)
		failOnError(err, "Failed to marshal the new message for mapping")

		// Send the message to the files queue
		go sendMessage(createdBody, corrid, channel, "completed")
	}
}

// Fuction for consuming the messages in the queue
func consumeFromQueue(msgs <-chan amqp.Delivery, channel *amqp.Channel, queue string) {
	// For "completed" queue do not consume every incoming message
	// unless is desirable for every file to have different dataset id.
	// Wait until all the messages are in the queue
	if queue == "completed" && conf.dataset != "all" {
		getAllMessages(msgs, channel)
	}
	// Check the queue for messages
	for delivered := range msgs {
		//TODO: add json validation before calling the function
		log.Printf("Received a message from %v queue: %s", queue, delivered.Body)
		sendMessage(delivered.Body, delivered.CorrelationId, channel, queue)
	}
}

// Function for sending message to the file queue.
// Modify messages in a way that are not failing the validation in pipeline
func sendMessage(body []byte, corrid string, channel *amqp.Channel, queue string) {
	var newBody []byte
	if queue == "completed" && conf.dataset != "all" {
		newBody = body
	} else {
		var message map[string]interface{}

		// Unmarshal the message
		// TODO: remove the error if json validation is implemented
		err := json.Unmarshal(body, &message)
		failOnError(err, "Failed to unmarshal the message")

		// Add the type in the received message depending on the queue
		// and remove al the unwanted information
		if queue == "inbox" {
			delete(message, "filesize")
			delete(message, "operation")
			message["type"] = "ingest"
		} else if queue == "verified" {
			message["type"] = "accession"
			accessionid := generateIds(queue)
			message["accession_id"] = accessionid
		} else if queue == "stableIDs" || queue == "completed" {
			delete(message, "decrypted_checksums")
			delete(message, "filepath")
			delete(message, "user")
			message["type"] = "mapping"
			datasetid := generateIds(queue)
			message["dataset_id"] = datasetid
		}

		// Marshal the new body where the type is included
		newBody, err = json.Marshal(message)
		failOnError(err, "Failed to marshal the new message")
	}

	// Maybe move the context to the main
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Publish message to the files queue
	err := channel.PublishWithContext(ctx,
		"localega.v1", // exchange
		"files",       // routing key
		false,         // mandatory
		false,         // immediate
		amqp.Publishing{
			Headers:         amqp.Table{},
			ContentEncoding: "UTF-8",
			ContentType:     "application/json",
			DeliveryMode:    amqp.Persistent,
			CorrelationId:   corrid,
			Priority:        0, // 0-9
			Body:            []byte(newBody),
		})
	failOnError(err, "Failed to publish a message")
	log.Printf("Send a message from %v queue to files: %s", queue, []byte(newBody))
}

// This function is using a channel to get the messages from a given queue
// and returns the messages
func messages(queue string, channel *amqp.Channel) <-chan amqp.Delivery {
	queueFullname := ""
	if queue == "stableIDs" {
		queueFullname = "v1." + queue
	} else {
		queueFullname = "v1.files." + queue
	}
	log.Printf("Consuming messages from %v queue", queueFullname)
	// Receive messages from the files.inbox queue
	messages, err := channel.Consume(
		queueFullname, // queue
		"",            // consumer
		true,          // auto-ack
		false,         // exclusive
		false,         // no-local
		false,         // no-wait
		nil,           // args
	)
	failOnError(err, "Failed to register a consumer")

	return messages
}

func main() {
	// Get the values from the environment
	envVal()
	// Connect to the mock cega server
	cegaMQ := fmt.Sprintf("amqp://%s:%s@%s:%s/%s", conf.user, conf.password, conf.mockhost, conf.port, conf.vhost)
	conn, err := amqp.Dial(cegaMQ)
	failOnError(err, "Failed to connect to CEGA MQ")
	defer conn.Close()

	// Create a channel
	ch, err := conn.Channel()
	failOnError(err, "Failed to open a channel")
	defer ch.Close()

	// Queues that are checked for messages
	queues := usedQueues()

	var forever chan struct{}

	// Loop over the given queues
	for _, queue := range queues {
		// Get the message from the queue
		msgs := messages(queue, ch)

		// Consume messages from specific queue
		go consumeFromQueue(msgs, ch, queue)
	}
	log.Printf(" [*] Waiting for messages. To exit press CTRL+C")
	<-forever
}
