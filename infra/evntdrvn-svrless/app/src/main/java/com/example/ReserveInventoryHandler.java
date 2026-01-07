package com.example;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.SQSEvent;

import com.google.gson.Gson;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.PutItemRequest;

import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.GetQueueUrlRequest;
import software.amazon.awssdk.services.sqs.model.SendMessageRequest;

import java.util.HashMap;
import java.util.Map;

public class ReserveInventoryHandler implements RequestHandler<SQSEvent, Void> {

    private final DynamoDbClient ddb = DynamoDbClient.builder()
            .region(Region.EU_CENTRAL_1)
            .build();

    private final SqsClient sqsClient = SqsClient.builder()
            .region(Region.EU_CENTRAL_1)
            .build();

    private final Gson gson = new Gson();

    @Override
    public Void handleRequest(SQSEvent event, Context context) {

        for (SQSEvent.SQSMessage message : event.getRecords()) {

            Order order = gson.fromJson(message.getBody(), Order.class);

            // save inventory reservation
            Map<String, AttributeValue> item = new HashMap<>();
            item.put("orderId", AttributeValue.builder().s(order.getOrderId()).build());

            PutItemRequest request = PutItemRequest.builder()
                    .tableName("products-inventory")
                    .item(item)
                    .build();

            ddb.putItem(request);

            // send InventoryReserved event
            String queueUrl = sqsClient.getQueueUrl(
                    GetQueueUrlRequest.builder()
                            .queueName("InventoryReservedQueue")
                            .build()
            ).queueUrl();

            sqsClient.sendMessage(SendMessageRequest.builder()
                    .queueUrl(queueUrl)
                    .messageBody(message.getBody())
                    .build());
        }

        return null;
    }
}
