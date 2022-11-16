package main

import (
	"context"
	"encoding/json"
	"math/rand"
	"strconv"
	"time"

	amqp "github.com/rabbitmq/amqp091-go"
	log "github.com/sirupsen/logrus"
)

func failOnError(err error, msg string) {
	if err != nil {
		log.Panicf("%s: %s", msg, err)
	}
}

// Function for generating accession ids
func generateIds(queue string) string {
	egaInt := 12000000000 + rand.Intn(1000)
	strNumber := strconv.Itoa(egaInt)
	id := ""
	if queue == "verified" {
		id = "EGAF" + strNumber
		//EGAD00123456780
	} else {
		id = "EGAD" + strNumber
	}
	return id
}

// Fuction for consuming the messages in the queue
func consumeFromQueue(msgs <-chan amqp.Delivery, channel *amqp.Channel, queue string) {
	// Check the queue for messages
	for delivered := range msgs {
		//TODO: add json validation before calling the function
		log.Printf("Received a message from %v queue: %s", queue, delivered.Body)
		sendMessage(delivered.Body, delivered.CorrelationId, channel, queue)
	}
}

// Function for sending message to the file queue
// Message from inbox queue: adds the type only
// Message from verified queue: adds type and accession id
// Message from stableIDs queue: adds type and dataset id
func sendMessage(body []byte, corrid string, channel *amqp.Channel, queue string) {
	var message map[string]interface{}

	// Unmarshal the message
	// TODO: remove the error if json validation is implemented
	err := json.Unmarshal(body, &message)
	failOnError(err, "Failed to unmarshal the message")

	// Add the type in the received message depending on the queue
	if queue == "inbox" {
		message["type"] = "ingest"
	} else if queue == "verified" {
		message["type"] = "accession"
		accessionid := generateIds(queue)
		message["accession_id"] = accessionid
	} else {
		message["type"] = "mapping"
		datasetid := generateIds(queue)
		message["dataset_id"] = datasetid
	}

	// Marshal the new body where the type is included
	newbody, err := json.Marshal(message)
	failOnError(err, "Failed to marshal the new message")

	// Maybe move the context to the main
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// Publish message to the files queue
	err = channel.PublishWithContext(ctx,
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
			Body:            []byte(newbody),
		})
	failOnError(err, "Failed to publish a message")
	log.Printf("Send a message from %v queue to files: %s", queue, []byte(newbody))
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
	// Connect to the mock cega server
	conn, err := amqp.Dial("amqp://test:test@cegamq:5672/lega")
	failOnError(err, "Failed to connect to CEGA MQ")
	defer conn.Close()

	// Create a channel
	ch, err := conn.Channel()
	failOnError(err, "Failed to open a channel")
	defer ch.Close()

	// Queues that are checked for messages
	queues := []string{"inbox", "verified", "stableIDs"}

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
