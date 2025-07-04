@00x @29x @60x @23x @87x @41x
Feature: verify message 29.x of variables 396 398 399 400
"""
 This feature file validates 29.x message to verify message  variables 396 398 399 400 base on ticket ARC-1689
"""

  @dx8000 @ex8000 @dx4000 @me
  Scenario Outline: Manual entry transaction with 23.x and 29.x message to verify variables 396 398 399 400

    Given I successfully changed configuration "0007" "0029" to "1"

    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"
    And I wait until Element "imageOffline" visible

    When I send a 23.x Card Read message to the terminal with:
      | p23_req_prompt_index   | 312 |
      | p23_req_enable_devices | M   |

    Then I Wait until Element "title" contains "Insert, Swipe or Tap Card"
    And I wait until Element "btn_cancel" visible
    And I wait until Element "line_display" visible
    And I wait until Element "btn_manual_entry" visible

    And I click Element "btn_manual_entry"

    When I click Element "ed_pan"

    Then I send keys to Element "ed_pan" text "<pan>"

    And I press enter button

    When I click Element "ed_cvv"

    Then I send keys to Element "ed_cvv" text "<code>"

    And I press enter button

    When I click Element "ed_expiry_date"

    Then I send keys to Element "ed_expiry_date" text "<exp_date>"

    And I press enter button

    When I click Element "btn_manual_confirm"

    Then I should receive the 23.x Read Card response from terminal with params:
      | p23_res_exit_type   | 0                                                                     |
      | p23_res_card_source | H                                                                     |
      | p23_res_track1      | M<pan>^<cardholdername>^<expect_exp_date><add_data1><code><add_data1> |
      | p23_res_track2      | <pan>=<expect_exp_date><add_data1><code><add_data2>                   |
      | p23_res_track3      |                                                                       |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 395 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000395 |
      | p29_res_variable_data | 0      |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 396 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000396 |
      | p29_res_variable_data | true   |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 398 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000398 |
      | p29_res_variable_data | <pan>  |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 399 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2                |
      | p29_res_variable_id   | 000399           |
      | p29_res_variable_data | <cardholdername> |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 400 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2                 |
      | p29_res_variable_id   | 000400            |
      | p29_res_variable_data | <expect_exp_date> |

    Examples:
      | card_type  | pan              | expect_exp_date | exp_date | code | add_data1 | add_data2 | cardholdername   |
      | Mastercard | 5413330089020011 | 2512            | 1225     | 221  | 000000    | 000       | MANUALLY/ENTERED |


  @rx5000 @rx7000 @me
  Scenario Outline: Manual entry transaction with 23.x and 29.x message to verify variables 396 398 399 400

    Given I successfully changed configuration "0007" "0029" to "1"

    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"
    And I wait until Element "imageOffline" visible

    When I send a 23.x Card Read message to the terminal with:
      | p23_req_prompt_index   | 312 |
      | p23_req_enable_devices | M   |

    Then I Wait until Element "title" contains "Insert, Swipe or Tap Card"
    And I wait until Element "btn_cancel" visible
    And I wait until Element "line_display" visible
    And I wait until Element "btn_manual_entry" visible

    And I click Element "btn_manual_entry"

    When I click Element "ed_pan"

    Then I send keys to Element "ed_pan" text "<pan>"

    And I press enter button

    When I click Element "ed_cvv"

    Then I send keys to Element "ed_cvv" text "<code>"

    And I press enter button

    When I click Element "ed_expiry_date"

    And I send keys to Element "ed_expiry_date" text "<exp_date>" and then ENTER

    Then I should receive the 23.x Read Card response from terminal with params:
      | p23_res_exit_type   | 0                                                                     |
      | p23_res_card_source | H                                                                     |
      | p23_res_track1      | M<pan>^<cardholdername>^<expect_exp_date><add_data1><code><add_data1> |
      | p23_res_track2      | <pan>=<expect_exp_date><add_data1><code><add_data2>                   |
      | p23_res_track3      |                                                                       |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 395 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000395 |
      | p29_res_variable_data | 0      |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 396 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000396 |
      | p29_res_variable_data | true   |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 398 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000398 |
      | p29_res_variable_data | <pan>  |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 399 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2                |
      | p29_res_variable_id   | 000399           |
      | p29_res_variable_data | <cardholdername> |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 400 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2                 |
      | p29_res_variable_id   | 000400            |
      | p29_res_variable_data | <expect_exp_date> |

    Examples:
      | card_type  | pan              | expect_exp_date | exp_date | code | add_data1 | add_data2 | cardholdername   |
      | Mastercard | 5413330089020011 | 2512            | 1225     | 221  | 000000    | 000       | MANUALLY/ENTERED |


  @dx8000 @ex8000 @dx4000 @me
  Scenario Outline: Manual entry transaction with 87.x and 29.x message to verify variables 396 398 399 400

    Given I successfully changed configuration "0007" "0029" to "1"

    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"
    And I wait until Element "imageOffline" visible

    When I send a 87.x On-Guard and KME Card Read message to the terminal with:
      | p87_req_prompt_index    | 1          |
      | p87_req_form_name       | read_cards |
      | p87_req_enabled_devices | M          |

    And I wait until Element "btn_cancel" visible
    And I wait until Element "line_display" visible
    And I wait until Element "btn_manual_entry" visible

    And I click Element "btn_manual_entry"

    When I click Element "ed_pan"

    Then I send keys to Element "ed_pan" text "<pan>"

    And I press enter button

    When I click Element "ed_cvv"

    Then I send keys to Element "ed_cvv" text "<code>"

    And I press enter button

    When I click Element "ed_expiry_date"

    Then I send keys to Element "ed_expiry_date" text "<exp_date>"

    And I press enter button

    When I click Element "btn_manual_confirm"

    Then I should receive the 87.x On-Guard and KME Card Read Data response from terminal with params:
      | p87_res_exit_type   | 0                                                                        |
      | p87_res_card_source | H                                                                        |
      | p87_res_card_data   | @regexp:^M<pan>\^<cardholdername>\^<expect_exp_date><add_data1><code>.*$ |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 395 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000395 |
      | p29_res_variable_data | 0      |
    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 396 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000396 |
      | p29_res_variable_data | true   |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 398 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000398 |
      | p29_res_variable_data | <pan>  |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 399 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2                |
      | p29_res_variable_id   | 000399           |
      | p29_res_variable_data | <cardholdername> |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 400 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2                 |
      | p29_res_variable_id   | 000400            |
      | p29_res_variable_data | <expect_exp_date> |


    Examples:
      | card_type  | pan              | expect_exp_date | exp_date | code | add_data1 | cardholdername   |
      | Mastercard | 5413330089020011 | 2512            | 1225     | 221  | 000000    | MANUALLY/ENTERED |


  @rx5000 @rx7000 @me
  Scenario Outline: Manual entry transaction with 87.x and 29.x message to verify variables 396 398 399 400

    Given I successfully changed configuration "0007" "0029" to "1"

    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"
    And I wait until Element "imageOffline" visible

    When I send a 87.x On-Guard and KME Card Read message to the terminal with:
      | p87_req_prompt_index    | 1          |
      | p87_req_form_name       | read_cards |
      | p87_req_enabled_devices | M          |

    And I wait until Element "btn_cancel" visible
    And I wait until Element "line_display" visible
    And I wait until Element "btn_manual_entry" visible

    When I click Element "btn_manual_entry"

    And I click Element "ed_pan"

    And I send keys to Element "ed_pan" text "<pan>"

    And I press enter button

    When I click Element "ed_cvv"

    And I send keys to Element "ed_cvv" text "<code>"

    And I press enter button

    When I click Element "ed_expiry_date"

    And I send keys to Element "ed_expiry_date" text "<exp_date>" and then ENTER

    Then I should receive the 87.x On-Guard and KME Card Read Data response from terminal with params:
      | p87_res_exit_type   | 0                                                                        |
      | p87_res_card_source | H                                                                        |
      | p87_res_card_data   | @regexp:^M<pan>\^<cardholdername>\^<expect_exp_date><add_data1><code>.*$ |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 395 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000395 |
      | p29_res_variable_data | 0      |
    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 396 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000396 |
      | p29_res_variable_data | true   |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 398 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000398 |
      | p29_res_variable_data | <pan>  |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 399 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2                |
      | p29_res_variable_id   | 000399           |
      | p29_res_variable_data | <cardholdername> |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 400 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2                 |
      | p29_res_variable_id   | 000400            |
      | p29_res_variable_data | <expect_exp_date> |

    Examples:
      | card_type  | pan              | expect_exp_date | exp_date | code | add_data1 | cardholdername   |
      | Mastercard | 5413330089020011 | 2512            | 1225     | 221  | 000000    | MANUALLY/ENTERED |


  @dx8000 @ex8000 @dx4000 @rx5000 @rx7000 @msr
  Scenario Outline: MSR transaction with 23.x and 29.x message to verify variables 394 395 396 398 399 400

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"
    And I wait until Element "imageOffline" visible

    When I send a 23.x Card Read message to the terminal with:
      | p23_req_prompt_index   | 311        |
      | p23_req_form_name      | read_cards |
      | p23_req_enable_devices | M          |

    Then I Wait until Element "title" contains "Please swipe or insert card"

    And  I wait until Element "btn_cancel" visible

    When I swipe card using this params:
      | track1_data | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2_data | <pan>=<exp_date><code><disc_data_t2>         |
      | track3_data |                                              |

    Then I should receive the 23.x Read Card response from terminal with params:
      | p23_res_exit_type   | 0                                            |
      | p23_res_card_source | M                                            |
      | p23_res_track1      | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | p23_res_track2      | <pan>=<exp_date><code><disc_data_t2>         |
      | p23_res_track3      |                                              |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 394 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000394 |
      | p29_res_variable_data | <code> |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 395 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000395 |
      | p29_res_variable_data | 0      |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 396 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000396 |
      | p29_res_variable_data | true   |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 398 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000398 |
      | p29_res_variable_data | <pan>  |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 399 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000399 |
      | p29_res_variable_data | <name> |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 400 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2          |
      | p29_res_variable_id   | 000400     |
      | p29_res_variable_data | <exp_date> |

    Examples:
      | card_type  | amount | pan              | name      | exp_date | code | disc_data_t1    | disc_data_t2  |
      | Mastercard | 120    | 5413339000000119 | TEST/CARD | 2412     | 221  | 000000140000000 | 0000014000001 |

  @dx8000 @ex8000 @dx4000 @rx5000 @rx7000 @msr
  Scenario Outline: MSR transaction with 41.x and 29.x message to verify variables 394 395 396 398 399 400

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"
    And I wait until Element "imageOffline" visible

    When I send a 41.x Card Read Message message to the terminal with params:
      | p41_req_parse_flag       | 1 |
      | p41_req_msr_flag         | 1 |
      | p41_req_contactless_flag | 0 |
      | p41_req_smc_flag         | 0 |

    Then I wait for 23 seconds

    When I swipe card using this params:
      | track1_data | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2_data | <pan>=<exp_date><code><disc_data_t2>         |
      | track3_data |                                              |

    And I wait for 2 seconds

    Then I should receive the 41.x Card Read Message response from terminal with params:
      | p41_res_source          | M                                            |
      | p41_res_encryption      | 00                                           |
      | p41_res_track_1_status  | 0                                            |
      | p41_res_track_2_status  | 0                                            |
      | p41_res_track_3_status  | 1                                            |
      | p41_res_track_1         | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | p41_res_track_2         | <pan>=<exp_date><code><disc_data_t2>         |
      | p41_res_track_3         |                                              |
      | p41_res_pan             | <pan>                                        |
      | p41_res_masked_pan      | <pan>                                        |
      | p41_res_expiration_date | <exp_date>                                   |
      | p41_res_account_name    | <name>                                       |
      | p41_res_error_code      | 0                                            |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 394 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000394 |
      | p29_res_variable_data | <code> |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 395 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000395 |
      | p29_res_variable_data | 0      |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 396 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000396 |
      | p29_res_variable_data | true   |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 398 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000398 |
      | p29_res_variable_data | <pan>  |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 399 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000399 |
      | p29_res_variable_data | <name> |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 400 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2          |
      | p29_res_variable_id   | 000400     |
      | p29_res_variable_data | <exp_date> |

    Examples:
      | card_type | pan              | name          | exp_date | code | disc_data_t1  | disc_data_t2  |
      | DISCOVER  | 6510000000000091 | CARD/IMAGE 09 | 1712     | 702  | 1000041300000 | 1000041300000 |

  @dx8000 @ex8000 @dx4000 @rx5000 @rx7000 @msr
  Scenario Outline: MSR transaction with 87.x and 29.x message to verify variables 394 395 396 398 399 400

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"
    And I wait until Element "imageOffline" visible

    When I send a 87.x On-Guard and KME Card Read message to the terminal with:
      | p87_req_prompt_index    | 3          |
      | p87_req_form_name       | read_cards |
      | p87_req_enabled_devices | M          |

    Then I Wait until Element "title" contains "Please slide card"

    And I wait until Element "btn_cancel" visible

    And I wait for 1 second

    When I swipe card using this params:
      | track1_data | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2_data | <pan>=<exp_date><code><disc_data_t2>         |
      | track3_data |                                              |

    Then I should receive the 87.x On-Guard and KME Card Read Data response from terminal with params:
      | p87_res_exit_type   | 0                                                                                                    |
      | p87_res_card_source | M                                                                                                    |
      | p87_res_card_data   | @regexp:^B<pan>\^<name>\^<exp_date><code><disc_data_t1>\x1C<pan>=<exp_date><code><disc_data_t2>\x1C$ |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 394 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000394 |
      | p29_res_variable_data | <code> |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 395 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000395 |
      | p29_res_variable_data | 0      |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 396 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000396 |
      | p29_res_variable_data | true   |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 398 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000398 |
      | p29_res_variable_data | <pan>  |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 399 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000399 |
      | p29_res_variable_data | <name> |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 400 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2          |
      | p29_res_variable_id   | 000400     |
      | p29_res_variable_data | <exp_date> |

    Examples:
      | card_type | pan            | name                      | exp_date | code | disc_data_t1    | disc_data_t2 |
      | VISA      | 34798979016630 | XNHKBPMOENSGWLH/VVKLBTTVC | 2011     | 885  | 131026887693372 | 887693372    |

