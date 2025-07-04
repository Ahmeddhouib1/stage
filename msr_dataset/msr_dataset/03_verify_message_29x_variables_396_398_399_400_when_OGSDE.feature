@00x @29x @60x @23x @87x @41x @sde
Feature: verify message 29.x of variables 396 398 399 400

"""
 This feature file validates 29.x message to verify message  variables 396 398 399 400 base on ticket ARC-1689
"""
  @dx4000 @dx8000 @ex8000 @rx5000 @rx7000
  Scenario: Enable On-Guard SDE Encryption Configuration
    ########## enable SDE encryption ###############
    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    When I have successfully sent "Files/p2p_encryptions/ArcOnGuardSDE.apk" file using these params:
      | p62_req_file_name       | ArcOnGuardSDE.apk |
      | p62_req_encoding_format | B                 |
      | p62_req_fast_download   | 1                 |
      | p62_req_unpack_flag     | 0                 |

    Then I should receive the 62.x Write File response from terminal with params:
      | p62_res_status      | 0            |
      | p62_res_file_length | @regexp:.\d* |

    When I send a 61.x Read Configuration message to the terminal with:
      | p61_req_group_num | 91 |
      | p61_req_index_num | 1  |

    Then I should receive the 61.x Read Configuration response from terminal with params:
      | p61_res_status                | 2  |
      | p61_res_group_num             | 91 |
      | p61_res_index_num             | 1  |
      | p61_res_data_config_parameter | 19 |

  @dx8000 @ex8000 @dx4000 @me
  Scenario Outline: Manual entry transaction with 23.x and 29.x message to verify variables 396 398 399 400 when SDE encryption enabled

    ########## start transaction ###############
    Given I successfully changed configuration "0007" "0029" to "1"
    And I send a 00.x Offline message to the terminal with params:
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

    When I click Element "btn_manual_entry"

    And I click Element "ed_pan"

    And I send keys to Element "ed_pan" text "<pan>"

    And I press enter button

    When I click Element "ed_cvv"

    And I send keys to Element "ed_cvv" text "<code>"

    And I press enter button

    When I click Element "ed_expiry_date"

    And I send keys to Element "ed_expiry_date" text "<exp_date>"

    And I press enter button

    When I click Element "btn_manual_confirm"

    Then I should receive the 23.x Read Card response from terminal with params:
      | p23_res_exit_type   | 0                                                                       |
      | p23_res_card_source | H                                                                       |
      | p23_res_track1      | %M<masked_pan>^MANUALLY/ENTERED^<expect_exp_date><masked_disc_data_t1>? |
      | p23_res_track2      | ;<masked_pan>=<expect_exp_date><masked_disc_data_t2>?                   |
      | p23_res_track3      | @regexp:.*                                                              |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 395 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000395 |
      | p29_res_variable_data | 19     |
    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 396 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000396 |
      | p29_res_variable_data | true   |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 398 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2            |
      | p29_res_variable_id   | 000398       |
      | p29_res_variable_data | <masked_pan> |

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
      | card_type  | pan              | expect_exp_date | exp_date | code | masked_disc_data_t1 | masked_disc_data_t2 | masked_pan       | cardholdername   |
      | Mastercard | 5413330089020011 | 2512            | 1225     | 221  | 000000000000000     | 000000000000        | 5413330000000011 | MANUALLY/ENTERED |


  @rx5000 @rx7000 @me
  Scenario Outline: Manual entry transaction with 23.x and 29.x message to verify variables 396 398 399 400 when SDE encryption enabled

    Given I successfully changed configuration "0007" "0029" to "1"
    And I send a 00.x Offline message to the terminal with params:
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

    When I click Element "btn_manual_entry"

    And I click Element "ed_pan"

    And I send keys to Element "ed_pan" text "<pan>"

    And I press enter button

    When I click Element "ed_cvv"

    And I send keys to Element "ed_cvv" text "<code>"

    And I press enter button

    When I click Element "ed_expiry_date"

    And I send keys to Element "ed_expiry_date" text "<exp_date>" and then ENTER

    Then I should receive the 23.x Read Card response from terminal with params:
      | p23_res_exit_type   | 0                                                                       |
      | p23_res_card_source | H                                                                       |
      | p23_res_track1      | %M<masked_pan>^MANUALLY/ENTERED^<expect_exp_date><masked_disc_data_t1>? |
      | p23_res_track2      | ;<masked_pan>=<expect_exp_date><masked_disc_data_t2>?                   |
      | p23_res_track3      | @regexp:.*                                                              |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 395 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000395 |
      | p29_res_variable_data | 19     |
    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 396 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000396 |
      | p29_res_variable_data | true   |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 398 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2            |
      | p29_res_variable_id   | 000398       |
      | p29_res_variable_data | <masked_pan> |

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
      | card_type  | pan              | expect_exp_date | exp_date | code | masked_disc_data_t1 | masked_disc_data_t2 | masked_pan       | cardholdername   |
      | Mastercard | 5413330089020011 | 2512            | 1225     | 221  | 000000000000000     | 000000000000        | 5413330000000011 | MANUALLY/ENTERED |

  @dx8000 @ex8000 @dx4000 @rx5000 @rx7000 @msr
  Scenario Outline: Manual entry transaction to verify 29.x variables 394 395 396 398 399 400 when SDE encryption enabled

    ########## start transaction ###############

    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"
    And I wait until Element "imageOffline" visible

    When I send a 23.x Read Card message to the terminal with:
      | p23_req_prompt_index   | 3 |
      | p23_req_enable_devices | M |

    Then I Wait until Element "title" contains "Please slide card"

    And  I wait until Element "btn_cancel" visible

    When Axium swipe magnetic card:
      | track1 | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2 | <pan>=<exp_date><code><disc_data_t2>         |
      | track3 | <additional_data><additional_data>           |

    Then I should receive the 23.x Card Read response from terminal with params:
      | p23_res_exit_type   | 0                                                            |
      | p23_res_card_source | M                                                            |
      | p23_res_track1      | %B<masked_pan>^<name>^<exp_date><code><masked_disc_data_t1>? |
      | p23_res_track2      | ;<masked_pan>=<exp_date><code><masked_disc_data_t2>?         |
      | p23_res_track3      | @regexp:.+                                                   |

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
      | p29_res_variable_data | 19     |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 396 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000396 |
      | p29_res_variable_data | true   |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 398 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2            |
      | p29_res_variable_id   | 000398       |
      | p29_res_variable_data | <masked_pan> |

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

    ########## remove encryption ###############

    Examples:
      | card_type  | pan              | name      | exp_date | code | disc_data_t1    | disc_data_t2  | additional_data      | masked_pan       | masked_disc_data_t1 | masked_disc_data_t2 | null_characters |
      | Mastercard | 5413330089020011 | TEST/CARD | 2412     | 221  | 000000140000000 | 0000014000001 | 01234567890123456789 | 5413330000000011 | 000000000000000     | 0000000000000       |                 |

  @dx4000 @dx8000 @ex8000 @rx5000 @rx7000
  Scenario: Teardown - Reset to Default State
    ########## remove encryption ###############
    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    When I have successfully sent "Files/p2p_encryptions/ArcNoEncryption.apk" file using these params:
      | p62_req_file_name       | ArcNoEncryption.apk |
      | p62_req_encoding_format | B                   |
      | p62_req_fast_download   | 1                   |
      | p62_req_unpack_flag     | 0                   |

    Then I should receive the 62.x Write File response from terminal with params:
      | p62_res_status      | 0          |
      | p62_res_file_length | @regexp:.* |

    When I send a 61.x Configuration Read message to the terminal with:
      | p61_req_group_num | 91 |
      | p61_req_index_num | 1  |

    Then I should receive the 61.x Configuration Read response from terminal with params:
      | p61_res_status                | 2  |
      | p61_res_group_num             | 91 |
      | p61_res_index_num             | 1  |
      | p61_res_data_config_parameter | 0  |