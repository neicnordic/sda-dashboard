package main

import (
	"context"
	"encoding/json"
	"time"

	amqp "github.com/rabbitmq/amqp091-go"
	log "github.com/sirupsen/logrus"
)

func failOnError(err error, msg string) {
	if err != nil {
		log.Panicf("%s: %s", msg, err)
	}
}

// Function for sending message to the file queue
func inboxpub(body []byte, corrid string, channel *amqp.Channel) {
	var message map[string]interface{}

	// Unmarshal the message
	// TODO: remove the error if json validation is implemented
	err := json.Unmarshal(body, &message)
	failOnError(err, "Failed to unmarshal the message")

	// Add the type in the received message
	message["type"] = "ingest"

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

	// Receive messages from the files.inbox queue
	messages, err := ch.Consume(
		"v1.files.inbox", // queue
		"",               // consumer
		true,             // auto-ack
		false,            // exclusive
		false,            // no-local
		false,            // no-wait
		nil,              // args
	)
	failOnError(err, "Failed to register a consumer")

	var forever chan struct{}

	go func() {
		// Check the queue for messages
		for delivered := range messages {
			//TODO: add json validation before calling the function
			log.Printf("Received a message: %s", delivered.Body)
			inboxpub(delivered.Body, delivered.CorrelationId, ch)
		}
	}()

	log.Printf(" [*] Waiting for messages. To exit press CTRL+C")
	<-forever
}
