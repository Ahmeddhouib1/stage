@sde @msr @00x @60x @61x @23x
Feature:  Validate track encryption indicator values
"""
 This feature file validates track encryption indicator with its values for manual entry , encryption indicator=3
 based on ticket https://ingenico-nar.atlassian.net/browse/ARC-1800
 """

  @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
  Scenario: Enable On-Guard SDE Encryption Configuration

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

  @dx8000 @ex8000 @dx4000
  Scenario Outline: On-Guard SDE Encryption For Manual Entry Transaction with encryption indicator =3

    Given I successfully changed configuration "0007" "0029" to "1"

    And I successfully changed configuration "0019" "0001" to "0"

    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"
    And I wait until Element "imageOffline" visible

    When I send a 61.x Read Configuration message to the terminal with:
      | p61_req_group_num | 91 |
      | p61_req_index_num | 1  |

    Then I should receive the 61.x Read Configuration response from terminal with params:
      | p61_res_status                | 2  |
      | p61_res_group_num             | 91 |
      | p61_res_index_num             | 1  |
      | p61_res_data_config_parameter | 19 |

    When I send a 23.x Card Read message to the terminal with:
      | p23_req_prompt_index   | 312 |
      | p23_req_enable_devices | M   |

    Then I Wait until Element "title" contains "Insert, Swipe or Tap Card"

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
      | p23_res_track3      | @regexp:.+:3:.+                                                         |


    Examples:
      | card_type  | pan              | expect_exp_date | exp_date | code | masked_disc_data_t1 | masked_disc_data_t2 | masked_pan       | null_characters              |
      | Mastercard | 5413330089020011 | 2512            | 1225     | 221  | 000000000000000     | 000000000000        | 5413330000000011 | \x00\x00\x00\x00\x00\x00\x00 |
      | Amex       | 374245002771003  | 2511            | 1125     | 2222 | 0000000000000000    | 0000000000000       | 374245000001003  | \x00\x00\x00\x00\x00\x00\x00 |
      | VISA       | 4264510228395621 | 2507            | 0725     | 206  | 000000000000000     | 000000000000        | 4264510000005621 | \x00\x00\x00\x00\x00\x00\x00 |
      | DISCOVER   | 6510000000000091 | 2606            | 0626     | 702  | 000000000000000     | 000000000000        | 6510000000000091 | \x00\x00\x00\x00\x00\x00\x00 |


  @rx5000 @rx7000
  Scenario Outline: On-Guard SDE Encryption For Manual Entry Transaction with encryption indicator =3

    Given I successfully changed configuration "0007" "0029" to "1"

    And I successfully changed configuration "0019" "0001" to "0"

    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"
    And I wait until Element "imageOffline" visible

    When I send a 61.x Read Configuration message to the terminal with:
      | p61_req_group_num | 91 |
      | p61_req_index_num | 1  |

    Then I should receive the 61.x Read Configuration response from terminal with params:
      | p61_res_status                | 2  |
      | p61_res_group_num             | 91 |
      | p61_res_index_num             | 1  |
      | p61_res_data_config_parameter | 19 |

    When I send a 23.x Card Read message to the terminal with:
      | p23_req_prompt_index   | 312 |
      | p23_req_enable_devices | M   |

    Then I Wait until Element "title" contains "Insert, Swipe or Tap Card"

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
      | p23_res_track3      | @regexp:.+:3:.+                                                         |


    Examples:
      | card_type  | pan              | expect_exp_date | exp_date | code | masked_disc_data_t1 | masked_disc_data_t2 | masked_pan       | null_characters              |
      | Mastercard | 5413330089020011 | 2512            | 1225     | 221  | 000000000000000     | 000000000000        | 5413330000000011 | \x00\x00\x00\x00\x00\x00\x00 |
      | Amex       | 374245002771003  | 2511            | 1125     | 2222 | 0000000000000000    | 0000000000000       | 374245000001003  | \x00\x00\x00\x00\x00\x00\x00 |
      | VISA       | 4264510228395621 | 2507            | 0725     | 206  | 000000000000000     | 000000000000        | 4264510000005621 | \x00\x00\x00\x00\x00\x00\x00 |
      | DISCOVER   | 6510000000000091 | 2606            | 0626     | 702  | 000000000000000     | 000000000000        | 6510000000000091 | \x00\x00\x00\x00\x00\x00\x00 |

  @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
  Scenario: Teardown - Reset to Default State

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"
    And I wait until Element "imageOffline" visible

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