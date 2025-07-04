@87x @msr @00x @24x @21x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: Validate On-Demand Messages using 87.x EFT message
"""
  This feature file Validates on-demand messages using 87.x EFT message
  TestLink test case link:https://testlink.evf.us/linkto.php?tprojectPrefix=ARC&item=testcase&id=ARC-1158.
  """

  Scenario Outline: On-Demand Messages using 87.x EFT message

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    When I send a 24.x Form Entry message to the terminal with params:
      | p24_req_form_number | activity_main |

    Then I should receive the 24.x Form Entry response from terminal with params:
      | p24_res_exit_type | 0    |
      | p24_res_keyid     | \x1F |

    And I Wait until Element "title" contains "This Lane Closed"

    When I send a 21.x Numeric Input message to the terminal with:
      | p21_req_display_char        | 0              |
      | p21_req_min_input_length    | <min_input>    |
      | p21_req_max_input_length    | <max_input>    |
      | p21_req_prompt_index        | <prompt_index> |
      | p21_req_form_specific_index | input_numeric  |

    And I Wait until Element "fixed_title" contains "<title>"

    #And I wait until Element "btn_cancel" visible

    And I wait until Element "line_display" visible

    When I click Element "input_box"

    And  I send keys to Element "input_box" text "<input_data>" and then ENTER

    Then I should receive the 21.x Numeric Input response from terminal with params:
      | p21_res_exit_type  | 0            |
      | p21_res_input_data | <input_data> |

    When I send a 87.x On-Guard and KME Card Read message to the terminal with:
      | p87_req_prompt_index    | 3          |
      | p87_req_form_name       | read_cards |
      | p87_req_enabled_devices | M          |

    And I Wait until Element "title" contains "Please slide card"

    And I wait until Element "btn_cancel" visible

    And I wait until Element "line_display" visible

    And I wait until Element "image_card" visible

    When I send a 24.x Form Entry message to the terminal with params:
      | p24_req_form_number | activity_main |

    And I should receive the 24.x Form Entry response from terminal with params:
      | p24_res_exit_type | 0    |
      | p24_res_keyid     | \x1F |

    And I Wait until Element "title" contains "Welcome"

    When I send a 27.x Alpha Input message to the terminal with params:
      | p27_req_display_char     | 0           |
      | p27_req_min_input_length | 00          |
      | p27_req_max_input_length | 40          |
      | p27_req_prompt_index     | 016         |
      | p27_req_form_specificid  | input_alpha |

    And I Wait until Element "fixed_title" contains "Please enter Cashback:"

    #And I wait until Element "btn_cancel" visible

    And I wait until Element "line_display" visible

    And I click Element "input_box"

    And I send keys to Element "input_box" text "ISAT-v-1.9.66" and then ENTER

    Then I should receive the 27.x Alpha Input response from terminal with params:
      | p27_res_exit_type  | 0             |
      | p27_res_data_input | ISAT-v-1.9.66 |

    When I send a 87.x On-Guard and KME Card Read message to the terminal with:
      | p87_req_prompt_index    | 3          |
      | p87_req_form_name       | read_cards |
      | p87_req_enabled_devices | M          |

    And I Wait until Element "title" contains "Please slide card"

    And I wait until Element "btn_cancel" visible

    And I wait until Element "line_display" visible

    When I swipe card using this params:
      | track1_data | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2_data | <pan>=<exp_date><code><disc_data_t2>         |
      | track3_data | <additional_data><additional_data>           |

    Then I should receive the 87.x Card Read response from terminal with params:
      | p87_res_exit_type   | 0                                            |
      | p87_res_card_source | M                                            |
      | p87_res_card_data   | @regexp:^B<pan>\^<name>\^<exp_date><code>.*$ |

    When I send a 31.x Pin Entry message to the terminal with params:
      | p31_req_set_key_type                 | D     |
      | p31_req_set_encryption_configuration | 0     |
      | p31_req_prompt_index_number          | 1     |
      | p31_req_customer_acc_num             | <pan> |
      | p31_req_form_name                    |       |

    And I enter pin "1234"

    Then I should receive in '30' seconds the 31.x Pin Entry response from terminal with params:
      | p31_res_status         | 0          |
      | p31_res_pin_data       | @regexp:.* |
      | p31_res_pin_data_block | @regexp:.* |
      | p31_res_pin_data_ksn   | @regexp:.* |

    When I send a 24.x Form Entry message to the terminal with params:
      | p24_req_form_number | activity_main |

    Then I should receive the 24.x Form Entry response from terminal with params:
      | p24_res_exit_type | 0    |
      | p24_res_keyid     | \x1F |

    And I Wait until Element "title" contains "Welcome!"

    When I send a 21.x Numeric Input message to the terminal with:
      | p21_req_display_char        | 0              |
      | p21_req_min_input_length    | <min_input>    |
      | p21_req_max_input_length    | <max_input>    |
      | p21_req_prompt_index        | <prompt_index> |
      | p21_req_form_specific_index | input_numeric  |

    When I send a 87.x On-Guard and KME Card Read message to the terminal with:
      | p87_req_prompt_index    | 3          |
      | p87_req_form_name       | read_cards |
      | p87_req_enabled_devices | M          |
      | po87_req_options        |            |

    And I Wait until Element "title" contains "Please slide card"

    And I wait until Element "line_display" visible

    And I wait until Element "btn_cancel" visible

    Then I should receive the 21.x Numeric Input response from terminal with params:
      | p21_res_exit_type  | a |
      | p21_res_input_data |   |

    When I send a 24.x Form Entry message to the terminal with params:
      | p24_req_form_number | activity_main |

    Then I should receive the 24.x Form Entry response from terminal with params:
      | p24_res_exit_type | 0    |
      | p24_res_keyid     | \x1F |

    And I Wait until Element "title" contains "Welcome!"

    When I send a 27.x Alpha Input message to the terminal with params:
      | p27_req_display_char     | 0           |
      | p27_req_min_input_length | 00          |
      | p27_req_max_input_length | 40          |
      | p27_req_prompt_index     | 206         |
      | p27_req_form_specificid  | input_alpha |

    #And I wait until Element "btn_cancel" visible

    When I send a 87.x On-Guard and KME Card Read message to the terminal with:
      | p87_req_prompt_index    | 3          |
      | p87_req_form_name       | read_cards |
      | p87_req_enabled_devices | M          |

    And I Wait until Element "title" contains "Please slide card"

    And I wait until Element "line_display" visible

    And I wait until Element "btn_cancel" visible

    Then I should receive the 27.x Alpha Input response from terminal with params:
      | p27_res_exit_type  | a |
      | p27_res_data_input |   |

    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    Then I should receive the 87.x On-Guard and KME Card Read Data response from terminal with params:
      | p87_res_exit_type   | a        |
      | p87_res_card_source | ?        |
      | p87_res_card_data   | \x1C\x1C |

    And I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    Examples:
      | card_type  | amount | pan              | name               | exp_date | code | disc_data_t1                                                                                             | disc_data_t2   | additional_data      | min_input | max_input | prompt_index | input_data | title                   |
      | Mastercard | 120    | 5413339000000119 | TEST/CARD          | 2412     | 221  | 000000140000000\u001c5413339000000119=24122210000014000001\u001c0123456789012345678901234567890123456789 | 0000014000001  | 01234567890123456789 | 01        | 10        | 001          | 6724240113 | Enter home phone number |
      | Amex       | 1234   | 374245001731008  | XP CARD 07/VER 2.0 | 2103     | 201  | 150412345                                                                                                | 15041234500000 |                      | 01        | 20        | 001          | 77457777   | Enter home phone number |
      | VISA       | 56789  | 4264510228395621 | JOHN/SMITH         | 1709     | 206  | 0000000000000000000704001000                                                                             | 0000070400100  |                      | 01        | 40        | 001          | 558555     | Enter home phone number |
      | DISCOVER   | 987654 | 6510000000000091 | CARD/IMAGE 09      | 1712     | 702  | 1000041300000                                                                                            | 1000041300000  |                      | 01        | 40        | 001          | 88855588   | Enter home phone number |
      | Diners     | 87654  | 36039667170472   | PETTITT/JO         | 0012     | 521  | 16010000000000000946                                                                                     | 1000041300000  | 01234567890123456789 | 01        | 40        | 001          | 74158552   | Enter home phone number |
