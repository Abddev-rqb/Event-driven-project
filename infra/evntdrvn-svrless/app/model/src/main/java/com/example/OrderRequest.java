package com.example;

import java.util.List;

public class OrderRequest {

    private String customerId;
    private List<String> items;
    private String total;

    public String getCustomerId() {
        return customerId;
    }

    public List<String> getItems() {
        return items;
    }

    public String getTotal() {
        return total;
    }
}
