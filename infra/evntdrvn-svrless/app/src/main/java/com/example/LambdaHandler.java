package com.example;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayV2HTTPResponse;
import com.google.gson.Gson;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.*;

import java.text.SimpleDateFormat;
import java.util.*;

public class LambdaHandler implements RequestHandler<APIGatewayV2HTTPEvent, APIGatewayV2HTTPResponse> {

    private static final Gson gson = new Gson();
    private static final SimpleDateFormat sdf =
            new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    private static final String TABLE_NAME =
            System.getenv("ORDERS_TABLE");

    private final DynamoDbClient ddb = DynamoDbClient.builder()
            .region(Region.of(System.getenv("AWS_REGION")))
            .build();

    @Override
    public APIGatewayV2HTTPResponse handleRequest(
            APIGatewayV2HTTPEvent event, Context context) {

        context.getLogger().log("Received order request");

        Order order = toOrder(event);

        Map<String, AttributeValue> item = new HashMap<>();
        item.put("orderId", AttributeValue.builder().s(order.getOrderId()).build());
        item.put("customerId", AttributeValue.builder().s(order.getCustomerId()).build());
        item.put("orderDate", AttributeValue.builder().s(sdf.format(order.getOrderDate())).build());
        item.put("status", AttributeValue.builder().s(order.getStatus().name()).build());
        item.put("items", AttributeValue.builder().ss(order.getItems()).build());
        item.put("total", AttributeValue.builder().n(order.getTotal()).build());

        PutItemRequest request = PutItemRequest.builder()
                .tableName(TABLE_NAME)
                .item(item)
                .build();

        ddb.putItem(request);

        return APIGatewayV2HTTPResponse.builder()
                .withStatusCode(201)
                .withHeaders(Map.of("Content-Type", "application/json"))
                .withBody(order.getOrderId())
                .build();
    }

    private Order toOrder(APIGatewayV2HTTPEvent event) {
        OrderRequest req = gson.fromJson(event.getBody(), OrderRequest.class);

        Order order = new Order();
        order.setOrderId(UUID.randomUUID().toString());
        order.setCustomerId(req.getCustomerId());
        order.setOrderDate(new Date());
        order.setStatus(OrderStatus.PLACED);
        order.setItems(req.getItems());
        order.setTotal(req.getTotal());
        return order;
    }
}
