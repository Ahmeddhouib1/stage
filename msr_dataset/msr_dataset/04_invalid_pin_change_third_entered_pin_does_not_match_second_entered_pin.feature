@msr @pin @28x @29x @31x @00x @23x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000 @crf13
Feature: validate an invalid PIN change where the cardholder will type a third entered PIN that does not match the second entered PIN
"""
   TestLink test case link : https://testlink.evf.us/linkto.php?tprojectPrefix=ARC&item=testcase&id=ARC-1387
   - The application validates the PIN according to the following rules:
In this testcase, we are testing an invalid PIN change where the cardholder will enter a strong PIN on the first and second attempts.
    - The application validates the PIN according to the following rules:
        - The first entered PIN does not match the second entered PIN.
        - The second entered PIN:
            - is not a weak PIN. The PIN is considered weak if:
                - All digits in the PIN are the same (e.g., 4444, 3333)
                - Each digit in the PIN is an increment of the previous digit (1234, 3456)
                - Each digit in the PIN is a decrement of the previous digit (4321, 9876)
                - The number of keys entered is more than four.
                - The number of keys entered does not exceed 12.
        - The third entered PIN matches the second entered PIN.
"""

  Scenario Outline: Perform MSR transaction and enter an invalid PIN where the cardholder enter a 3rd entered pin doesnt match the second enetered pin

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

 ################## enable pin change support ###########################

    When I send a 28.x Set Variable message to the terminal with:
      | p28_req_response_type | 1      |
      | p28_req_variable_id   | 000920 |
      | p28_req_variable_data | 1      |

    Then I should receive the 28.x Set Variable response from terminal with params:
      | p28_res_status      | 2      |
      | p28_res_variable_id | 000920 |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 00000920 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000920 |
      | p29_res_variable_data | true   |

    And I Wait until Element "title" contains "This Lane Closed"

 ################## swipe card ###########################

    When I send a 23.x Card Read message to the terminal with:
      | p23_req_prompt_index   | 311        |
      | p23_req_form_name      | read_cards |
      | p23_req_enable_devices | M          |

    And I Wait until Element "title" contains "Please swipe or insert card"

    And I wait until Element "btn_cancel" visible

    And Axium swipe magnetic card:
      | track1 | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2 | <pan>=<exp_date><code><disc_data_t2>         |
      | track3 | <additional_data><additional_data>           |

    Then I should receive the 23.x Card Read response from terminal with params:
      | p23_res_exit_type   | 0                                            |
      | p23_res_card_source | M                                            |
      | p23_res_track1      | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | p23_res_track2      | <pan>=<exp_date><code><disc_data_t2>         |
      | p23_res_track3      | <additional_data><additional_data>           |

    And I wait for 1 second

    When I send a 31.x PIN Entry message to the terminal with:
      | p31_req_prompt_index_number          | 14 |
      | p31_req_customer_acc_num             |    |
      | p31_req_set_encryption_configuration | 0  |
      | p31_req_set_key_type                 | D  |
      | p31_req_form_name                    |    |

    #################enter the weak pin################################
    And I enter pin "<weak_pin>"
    And I wait for 4 seconds
    #################enter strong pin################################

    And I enter pin "<strong_pin1>"
    ######################## enter another strong pin  #####################
    And I wait for 4 seconds
    And I enter pin "<strong_pin2>"
    ####### 31.x should return C because the 3rd pin entry is not same as the 2nd strong pin entered################### #######################

    Then I should receive the 31.x PIN Entry response from terminal with params:
      | p31_res_status   | C |
      | p31_res_pin_data |   |

    ############## variable keeps the value true since pin is not sucessfully changed ##########################
    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 00000920 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000920 |
      | p29_res_variable_data | true   |

    Examples:
      | card_type  | amount | pan              | name               | exp_date | code | disc_data_t1                 | disc_data_t2   | additional_data      | weak_pin | strong_pin1 | strong_pin2 |
      | Mastercard | 120    | 5413339000000119 | TEST/CARD          | 2412     | 221  | 000000140000000              | 0000014000001  | 01234567890123456789 | 1111     | 0258        | 1593        |
      | Amex       | 1234   | 374245001731008  | XP CARD 07/VER 2.0 | 2103     | 201  | 150412345                    | 15041234500000 |                      | 1234     | 3124        | 0101        |
      | VISA       | 56789  | 4264510228395621 | JOHN/SMITH         | 1709     | 206  | 0000000000000000000704001000 | 0000070400100  |                      | 4567     | 9988        | 3124        |
      | DISCOVER   | 987654 | 6510000000000091 | CARD/IMAGE 09      | 1712     | 702  | 1000041300000                | 1000041300000  |                      | 9876     | 0101        | 0258        |
      | Diners     | 87654  | 36039667170472   | PETTITT/JO         | 0012     | 521  | 16010000000000000946         | 1000041300000  | 01234567890123456789 | 7777     | 1593        | 9988        |
