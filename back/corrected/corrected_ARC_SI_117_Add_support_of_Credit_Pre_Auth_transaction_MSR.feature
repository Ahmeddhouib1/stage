""
@appium @dx @ex @credit @chase @smoke @msr
Feature: Add support of Credit Pre-Auth transaction (ASI-198)

  Scenario Outline: To Validate Credit Pre-Auth transaction is performed successfully
    Given I use upp-ws transaction endpoint
    When I send upp-ws request
    """
    "payment_type": "credit",
    "type": "preauth",
    "amount": {
      "total": 1000
    },
    "txn_status_events": true,
    "display_txn_result": true,
    "confirm_amount": false
    """
    Then I should receive upp-ws response
    """
    "status": "started"
    """
    And I Wait until Element "title" contains "Insert, Swipe or Tap Card"
    And I wait 2 seconds
    When Axium swipe magnetic card:
      | track1 | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2 | <pan>=<exp_date><code><disc_data_t2>        |
      | track3 | <additional_data><additional_data>          |
    Then I should receive upp-ws event within 50s
    """
    "card": {
      "account_name": "<name>",
      "brand": "<brand>",
      "exp": "<exp_date>",
      "mnemonic": "<mnemonic>",
      "pan": "<pan_in_response>",
      "service_code": "<code>"
    },
    "source": "msr",
    "status": "proceed",
    "type": "card_read"
    """
    When I send upp-ws event_ack with status "ok"
    Then I Wait until Element "title" contains "Processingâ¦ Please wait"
    And I should receive upp-ws event within 50s
    """
    "source": "msr",
    "status": "proceed",
    "type": "authorizing"
    """
    When I send upp-ws event_ack with status "ok"
    Then I should receive upp-ws event subset within 50s
    """
    "time": "@regexp:^$|.*",
    "date": "@regexp:^$|.*",
    "txn_type": "preauth",
    "payment_type": "credit",
    "client_txn_id": "@regexp:^$|.*",
    "amount": {
      "total": "1000"
    },
    "token": {
      "card_mnemonic": "<mnemonic>",
      "exp": "<exp_date>",
      "value": "@regexp:^$|.*"
    },
    "card": {
      "account_name": "<name>",
      "brand": "<brand>",
      "exp": "<exp_date>",
      "mnemonic": "<mnemonic>",
      "pan": "<pan_in_response>",
      "service_code": "<code>"
    },
    "host": {
      "approval_code": "@regexp:^$|.*",
      "response_text": "@regexp:\bAPPROVED\s\w+\b",
      "authorized_amount": "1000"
    },
    "type": "transaction_completed",
    "status": "completed",
    "source": "msr"
    """
    When I send upp-ws event_ack with status "ok"
    Then I Wait until Element "title" contains "APPROVED"
    And I wait 3 seconds
    Examples:
      | card_type           | pan              | name                   | exp_date | code | disc_data_t1             | disc_data_t2  | additional_data | mnemonic | brand         | pan_in_response  |
      | MasterCard          | 5132850000000008 | BU.SINESS/MC CORPORATE | 2812     | 101  | 5432112345678            | 5432112345678 |                 | MC       | MasterCard    | 5132850000000008 |
      | VISA                | 4895390000000013 | VISA TEST/GOOD         | 2812     | 101  | 00733000000              | 00000733      |                 | VI       | Visa          | 4895390000000013 |
      | CUP                 | 6282000123842342 | DISCOVER CUP/CPS TEST  | 2812     | 101  | 1000112312300            | 1000012312300 |                 | DS       | Discover      | 6282000000002342 |
      | AMEX                | 373953192351004  | AMEX TEST CARD ANSI    | 2812     | 090  | 131368                   | 131368        |                 | AE       | American Exp. | 373953000001004  |
      | Discover/Diners BIN | 3899990000000026 | TEST CARD/DINERS CLUB  | 2812     | 101  | 030912345678901239991231 | 0309123999123 |                 | DS       | Discover      | 3899990000000026 |
      | Discover            | 6011025500395802 | PAYMENTECH/ CHASE      | 2812     | 101  | 100000000000000000000000 | 0000          |                 | DS       | Discover      | 6011020000005802 |
      | JCB                 | 3566002020140006 | CHASE PAYMENTECH       | 2812     | 101  | 5432112345678            | 5432112345678 |                 | JC       | JCB           | 3566000000000006 |

  Scenario Outline: To Validate Credit Pre-Auth transaction is performed successfully for Maestro
    Given I use upp-ws transaction endpoint
    When I send upp-ws request
    """
    "payment_type": "credit",
    "type": "preauth",
    "amount": {
      "total": 1000
    },
    "txn_status_events": true,
    "display_txn_result": true,
    "confirm_amount": false
    """
    Then I should receive upp-ws response
    """
    "status": "started"
    """
    And I Wait until Element "title" contains "Insert, Swipe or Tap Card"
    And I wait 2 seconds
    When Axium swipe magnetic card:
      | track1 |                                  |
      | track2 | <pan>=<exp_date><code><disc_data_t2> |
      | track3 |                                  |
    Then I should receive upp-ws event within 50s
    """
    "card": {
      "account_name": "<name>",
      "brand": "<brand>",
      "exp": "<exp_date>",
      "mnemonic": "<mnemonic>",
      "pan": "<pan_in_response>",
      "service_code": "<code>"
    },
    "source": "msr",
    "status": "proceed",
    "type": "card_read"
    """
    When I send upp-ws event_ack with status "ok"
    Then I Wait until Element "title" contains "Processingâ¦ Please wait"
    And I should receive upp-ws event within 50s
    """
    "source": "msr",
    "status": "proceed",
    "type": "authorizing"
    """
    When I send upp-ws event_ack with status "ok"
    Then I should receive upp-ws event subset within 50s
    """
    "time": "@regexp:^$|.*",
    "date": "@regexp:^$|.*",
    "txn_type": "preauth",
    "payment_type": "credit",
    "client_txn_id": "@regexp:^$|.*",
    "amount": {
      "total": "1000"
    },
    "token": {
      "card_mnemonic": "<mnemonic>",
      "exp": "<exp_date>",
      "value": "@regexp:^$|.*"
    },
    "card": {
      "account_name": "<name>",
      "brand": "<brand>",
      "exp": "<exp_date>",
      "mnemonic": "<mnemonic>",
      "pan": "<pan_in_response>",
      "service_code": "<code>"
    },
    "host": {
      "approval_code": "@regexp:^$|.*",
      "response_text": "@regexp:\bAPPROVED\s\w+\b",
      "authorized_amount": "1000"
    },
    "type": "transaction_completed",
    "status": "completed",
    "source": "msr"
    """
    When I send upp-ws event_ack with status "ok"
    Then I Wait until Element "title" contains "APPROVED"
    And I wait 3 seconds
    Examples:
      | card_type | pan              | name | exp_date | code | disc_data_t1 | disc_data_t2  | additional_data | mnemonic | brand   | pan_in_response  |
      | Maestro   | 6701234567890123 |      | 2812     | 101  |              | 0000000000000 |                 | MC       | MAESTRO | 670123000000