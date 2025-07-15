Feature: MSR Debit sale transaction using MASTERCARD Card (TC1)

  Scenario Outline: Verify user can perform successful debit sale transaction with MSR
    Given Axium pinpad auto enter enable
    When I use upp-ws transaction endpoint
    And I setup prompt on display: Executing scenario related to debit Sale transaction MSR using mastercard brand (TC_Number1)
    And I send upp-ws request
    """
           "type": "sale",
           "payment_type": "debit",
           "amount": {
             "total": <amount>
           },
           "txn_status_events": false,
           "display_txn_result": true,
           "confirm_amount": false,
           "token_request": true,
           "manual_entry": true
    """
    Then I should receive upp-ws response
    """
    "status" : "started"
    """
    And I Wait until Element "title" contains "Insert, Swipe or Tap Card"
    When I wait 2 seconds
    And Axium swipe magnetic card:
      | track1 |                                              |
      | track2 | <pan>=<exp_date><service_code><disc_data_t2> |
      | track3 |                                              |
    Then I Wait until Element "title" contains "Cashback ?"
    When I enter pin "1234"
    And I click Element "btn_clear"
    Then I Wait until Element "fixed_title" contains "Please enter your PIN:"
    And I Wait until Element "title" contains "Processingâ¦ Please wait"
    And I should receive upp-ws event subset within 50s
    """
        "time":"@regexp:^$|.*",
        "date":"@regexp:^$|.*",
        "txn_type":"sale",
        "payment_type":"debit",
        "client_txn_id":"@regexp:^$|.*",
        "amount":{
        "total":"<amount>"
        },
        "card": {
          "brand": "<brand>",
          "exp": "<exp_date>",
          "mnemonic": "<mnemonic>",
          "pan": "<pan_in_response>",
          "service_code": "<service_code>"
        },
        "host": {
          "approval_code": "@regexp:^$|.*",
          "response_text": "<Response>",
          "customer_text":"<Response>",
          "response_code":"<response_code>",
          "authorized_amount":"<amount>",
          "auth_network_id":"0001",
          "txn_id":"@regexp:^$|.*",
          "reference_number":"@regexp:^$|.*"
        },
        "type":"transaction_completed",
        "status":"proceed",
        "source":"msr"
    """
    When I send upp-ws event_ack with status "ok"
    Then I should receive upp-ws event within 50s
    """
    "status":"completed",
    "type":"post_txn_reset"
    """
    When I send upp-ws event_ack with status "ok"
    Then I Wait until Element "title" contains "<Response>"
    And I wait 1 second
    Examples:
      | name                    | amount | response_code | Response | pan              | pan_in_response  | exp_date | service_code | mnemonic | brand | exp  | disc_data_t1          | disc_data_t2 |
      | FDCSTESTCARD/MASTERCARD | 2500   | 00            | APPROVAL | 4017779999999011 | 4017770000009011 | 2512     | 120          | DB       | Debit | 2512 | 10001111A123456789012 | 0000000001   |"
}
```