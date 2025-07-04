@pin_code @msr @00x @61x @23x @31x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature:  Validate  pin block decryption is correct for master session pin when encryption is off
"""
 This feature file Feature Validates master session pin when encryption is off
 testlink testcase : https://testlink.evf.us/linkto.php?tprojectPrefix=ARC&item=testcase&id=ARC-1230

 """

  Scenario Outline: Validate master session pin when encryption is off

    Given I send a 00.x Offline message to the terminal with params:
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
      | p61_res_data_config_parameter | 0  |

    ##################select master session pin################"
    And I successfully changed configuration "0006" "0007" to "0"

    And I successfully changed configuration "0006" "0008" to "0"

    ################## swipe the card #########################"
    When I send a 13.x amount message to the terminal with:
      | p13_req_amount | 1000 |

    Then I should receive the 13.x amount response from terminal with params:
      | p13_res_status | 0 |

    When I send a 23.x Read Card message to the terminal with:
      | p23_req_prompt_index   | 3 |
      | p23_req_enable_devices | M |

    Then I Wait until Element "title" contains "Please slide card"

    And  I wait until Element "btn_cancel" visible

    When Axium swipe magnetic card:
      | track1 | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2 | <pan>=<exp_date><code><disc_data_t2>         |
      | track3 |                                              |

    Then I should receive the 23.x Card Read response from terminal with params:
      | p23_res_exit_type   | 0                                            |
      | p23_res_card_source | M                                            |
      | p23_res_track1      | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | p23_res_track2      | <pan>=<exp_date><code><disc_data_t2>         |
      | p23_res_track3      |                                              |
    #################### send 31.x message for pin entry #############################

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 000398 |
    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2          |
      | p29_res_variable_id   | 000398     |
      | p29_res_variable_data | @regexp:.* |

    When I send a 31.x PIN Entry message to the terminal with:
      | p31_req_prompt_index_number          | 1                                                |
      | p31_req_customer_acc_num             | @cache:upp:response:-1:['p29_res_variable_data'] |
      | p31_req_set_encryption_configuration | 0                                                |
      | p31_req_set_key_type                 | M                                                |
      | p31_req_form_name                    |                                                  |

      ############################### enter pin #############################
    And I enter pin "<pin_code>"

    Then I should receive the 31.x PIN Entry response from terminal with params:
      | p31_res_status   | 0          |
      | p31_res_pin_data | @regexp:.* |

    ################################# decrypt the enetered pin ###############################
    And I will decrypt pin block M/S from 'p31_res_pin_data' using the sequence of pan: '<pan>' and initial vector '<initial_vector>' and expect:
      | length   | <pin_length>                  |
      | pin_code | <pin_code>                    |
      | tail     | <tail>                        |
      | pinblock | 0<pin_length><pin_code><tail> |

    Examples:
      | card_type  | pan              | name               | exp_date | code | disc_data_t1                 | disc_data_t2   | initial_vector   | pin_code | pin_length | tail       |
      | Mastercard | 5413330089020011 | TEST/CARD          | 2412     | 221  | 000000140000000              | 0000014000001  | 0000000000000000 | 0000     | 4          | ffffffffff |
      | Amex       | 374245001731008  | XP CARD 07/VER 2.0 | 2103     | 201  | 150412345                    | 15041234500000 | 0000000000000000 | 1234     | 4          | ffffffffff |
      | VISA       | 4264510228395621 | JOHN/SMITH         | 1709     | 206  | 0000000000000000000704001000 | 0000070400100  | 0000000000000000 | 12345    | 5          | fffffffff  |
      | DISCOVER   | 6510000000000091 | CARD/IMAGE 09      | 1712     | 702  | 1000041300000                | 1000041300000  | 0000000000000000 | 4321     | 4          | ffffffffff |
      | Diners     | 36039667170472   | PETTITT/JO         | 0012     | 521  | 16010000000000000946         | 1000041300000  | 0000000000000000 | 5522     | 4          | ffffffffff |
      | VISA       | 4761739001010010 | Test Card 04       | 2212     | 201  | 16010000000000000946         | 1000041300000  | 0000000000000000 | 221100   | 6          | ffffffff   |
      | Mastercard | 5413330089099130 | Test Card 20       | 2512     | 201  | 16010000000000000946         | 1000041300000  | 0000000000000000 | 1133     | 4          | ffffffffff |
      | VISA       | 4761739001010010 | Test Card 04       | 2212     | 201  | 16010000000000000946         | 1000041300000  | 0000000000000000 | 22110055 | 8          | ffffff     |
