package com.example;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;

import com.google.gson.Gson;

import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.GetQueueUrlRequest;
import software.amazon.awssdk.services.sqs.model.SendMessageRequest;

public class NewOrderHandler implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {

    private final SqsClient sqsClient = SqsClient.create();

    private final Gson gson = new Gson();

    @Override
    public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent request, Context context) {

        Order order = gson.fromJson(request.getBody(), Order.class);

        // save order to DynamoDB (already exists in your service)

        // get queue URL
        GetQueueUrlRequest getQueueRequest = GetQueueUrlRequest.builder()
                .queueName("OrderCreatedQueue")
                .build();

        String queueUrl = sqsClient.getQueueUrl(getQueueRequest).queueUrl();

        // send message
        SendMessageRequest sendMessageRequest = SendMessageRequest.builder()
                .queueUrl(queueUrl)
                .messageBody(gson.toJson(order))
                .build();

        sqsClient.sendMessage(sendMessageRequest);

        return new APIGatewayProxyResponseEvent()
                .withStatusCode(201)
                .withBody("Order created");
    }
}
