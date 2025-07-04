@smoke @msr @00x @13x @23x @20x @29x @24x

Feature: MSR Credit Signature transaction with various card brands
"""
   TestLink test case link :https://testlink.evf.us/linkto.php?tprojectPrefix=ARC&item=testcase&id=ARC-917
 """


  @dx8000 @ex8000 @dx4000
  Scenario Outline: Perform MSR Credit Signature Transaction with Tracks_1&2&3 and Tracks_1&2  cards for various card brands

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    When I send a 13.x amount message to the terminal with:
      | p13_req_amount | <amount> |

    Then I should receive the 13.x amount response from terminal with params:
      | p13_res_status | 0 |

    When I send a 23.x Card Read message to the terminal with:
      | p23_req_prompt_index   | 311        |
      | p23_req_form_name      | read_cards |
      | p23_req_enable_devices | M          |

    Then I Wait until Element "title" contains "Please swipe or insert card"

    And I wait until Element "btn_cancel" visible

    When Axium swipe magnetic card:
      | track1 | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2 | <pan>=<exp_date><code><disc_data_t2>         |
      | track3 | <additional_data><additional_data>           |

    Then I should receive the 23.x Card Read response from terminal with params:
      | p23_res_exit_type   | 0                                            |
      | p23_res_card_source | M                                            |
      | p23_res_track1      | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | p23_res_track2      | <pan>=<exp_date><code><disc_data_t2>         |
      | p23_res_track3      | <additional_data><additional_data>           |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 000398 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000398 |
      | p29_res_variable_data | <pan>  |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 000399 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000399 |
      | p29_res_variable_data | <name> |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 000400 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2          |
      | p29_res_variable_id   | 000400     |
      | p29_res_variable_data | <exp_date> |

    And I wait for 1 second

    When I send a 24.x Form Entry message to the terminal with params:
      | p24_req_form_number     | confirmation_amount |
      | p24_req_type_of_element | T                   |
      | p24_req_prompt_idx      | 10                  |
      | p24_req_text_element_id | title               |

    Then I wait until Element "btn_enter" visible

    When I click Element "btn_enter"

    Then I should receive the 24.x Form Entry response from terminal with params:
      | p24_res_exit_type    | 0        |
      | p24_res_keyid        | \x1F     |
      | p24_res_buttonid     | b        |
      | p24_res_button_state | tn_enter |

    And I wait for 1 second

    When I send a 20.x Signature message to the terminal with params:
      | p20_req_prompt_index | 165  |
      | p20_req_form_name    | SIGN |

    Then I wait until Element "paint_view" visible

    When Draw line from 100x800 to 200x500

    And Draw line from 200x500 to 300x800

    And Draw line from 100x800 to 200x500

    And Draw line from 200x500 to 300x800

    And Draw line from 140x700 to 250x700

    And I click Element "btn_enter"

    Then I should receive the 20.x Signature request response from terminal with params:
      | p20_res_status | 0 |
      | p20_res_data   | 4 |

    When I send a 29.x Get Variable message to the terminal with params:
      | p29_req_variable_id | 000700 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2                |
      | p29_res_variable_id   | 000700           |
      | p29_res_variable_data | @skip_comparison |

    When I send a 29.x Get Variable message to the terminal with params:
      | p29_req_variable_id | 000701 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2                |
      | p29_res_variable_id   | 000701           |
      | p29_res_variable_data | @skip_comparison |

    And I wait for 1 second

    When I send a 24.x Form Entry message to the terminal with params:
      | p24_req_form_number     | status_title_only |
      | p24_req_type_of_element | T                 |
      | p24_req_prompt_idx      | 352               |
      | p24_req_text_element_id | title             |

    Then I Wait until Element "title" contains "Transaction complete"

    And I should receive the 24.x Form Entry response from terminal with params:
      | p24_res_exit_type | 0    |
      | p24_res_keyid     | \x1F |

    And I wait for 2 seconds

    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |




    Examples:
      | card_type  | amount | pan              | name               | exp_date | code | disc_data_t1                 | disc_data_t2   | additional_data      |
      | Mastercard | 120    | 5413339000000119 | TEST/CARD          | 2412     | 221  | 000000140000000              | 0000014000001  | 01234567890123456789 |
      | Amex       | 1234   | 374245001731008  | XP CARD 07/VER 2.0 | 2103     | 201  | 150412345                    | 15041234500000 |                      |
      | VISA       | 56789  | 4264510228395621 | JOHN/SMITH         | 1709     | 206  | 0000000000000000000704001000 | 0000070400100  |                      |
      | DISCOVER   | 987654 | 6510000000000091 | CARD/IMAGE 09      | 1712     | 702  | 1000041300000                | 1000041300000  |                      |
      | Diners     | 87654  | 36039667170472   | PETTITT/JO         | 0012     | 521  | 16010000000000000946         | 1000041300000  | 01234567890123456789 |




  @rx5000 @rx7000
  Scenario Outline: Perform MSR Credit Signature Transaction with Tracks_1&2&3 and Tracks_1&2  cards for various card brands

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    When I send a 13.x amount message to the terminal with:
      | p13_req_amount | <amount> |

    Then I should receive the 13.x amount response from terminal with params:
      | p13_res_status | 0 |

    When I send a 23.x Card Read message to the terminal with:
      | p23_req_prompt_index   | 311        |
      | p23_req_form_name      | read_cards |
      | p23_req_enable_devices | M          |

    Then I Wait until Element "title" contains "Please swipe or insert card"

    And I wait until Element "btn_cancel" visible

    When Axium swipe magnetic card:
      | track1 | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2 | <pan>=<exp_date><code><disc_data_t2>         |
      | track3 | <additional_data><additional_data>           |

    Then I should receive the 23.x Card Read response from terminal with params:
      | p23_res_exit_type   | 0                                            |
      | p23_res_card_source | M                                            |
      | p23_res_track1      | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | p23_res_track2      | <pan>=<exp_date><code><disc_data_t2>         |
      | p23_res_track3      | <additional_data><additional_data>           |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 000398 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000398 |
      | p29_res_variable_data | <pan>  |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 000399 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000399 |
      | p29_res_variable_data | <name> |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 000400 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2          |
      | p29_res_variable_id   | 000400     |
      | p29_res_variable_data | <exp_date> |

    And I wait for 1 second

    When I send a 24.x Form Entry message to the terminal with params:
      | p24_req_form_number     | confirmation_amount |
      | p24_req_type_of_element | T                   |
      | p24_req_prompt_idx      | 10                  |
      | p24_req_text_element_id | title               |

    Then I wait until Element "btn_enter" visible

    When I click Element "btn_enter"

    Then I should receive the 24.x Form Entry response from terminal with params:
      | p24_res_exit_type    | 0        |
      | p24_res_keyid        | \x1F     |
      | p24_res_buttonid     | b        |
      | p24_res_button_state | tn_enter |

    And I wait for 1 second

    When I send a 20.x Signature message to the terminal with params:
      | p20_req_prompt_index | 165  |
      | p20_req_form_name    | SIGN |

    Then I wait until Element "paint_view" visible

    When Draw line from 200x300 to 300x360

    And Draw line from 300x360 to 360x400

    And I click Element "btn_enter"

    Then I should receive the 20.x Signature request response from terminal with params:
      | p20_res_status | 0 |
      | p20_res_data   | 2 |

    When I send a 29.x Get Variable message to the terminal with params:
      | p29_req_variable_id | 000700 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2                |
      | p29_res_variable_id   | 000700           |
      | p29_res_variable_data | @skip_comparison |

    When I send a 29.x Get Variable message to the terminal with params:
      | p29_req_variable_id | 000701 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2                |
      | p29_res_variable_id   | 000701           |
      | p29_res_variable_data | @skip_comparison |

    And I wait for 1 second

    When I send a 24.x Form Entry message to the terminal with params:
      | p24_req_form_number     | status_title_only |
      | p24_req_type_of_element | T                 |
      | p24_req_prompt_idx      | 352               |
      | p24_req_text_element_id | title             |

    Then I Wait until Element "title" contains "Transaction complete"

    And I should receive the 24.x Form Entry response from terminal with params:
      | p24_res_exit_type | 0    |
      | p24_res_keyid     | \x1F |

    And I wait for 2 seconds



    Examples:
      | card_type  | amount | pan              | name               | exp_date | code | disc_data_t1                 | disc_data_t2   | additional_data      |
      | Mastercard | 120    | 5413339000000119 | TEST/CARD          | 2412     | 221  | 000000140000000              | 0000014000001  | 01234567890123456789 |
      | Amex       | 1234   | 374245001731008  | XP CARD 07/VER 2.0 | 2103     | 201  | 150412345                    | 15041234500000 |                      |
      | VISA       | 56789  | 4264510228395621 | JOHN/SMITH         | 1709     | 206  | 0000000000000000000704001000 | 0000070400100  |                      |
      | DISCOVER   | 987654 | 6510000000000091 | CARD/IMAGE 09      | 1712     | 702  | 1000041300000                | 1000041300000  |                      |
      | Diners     | 87654  | 36039667170472   | PETTITT/JO         | 0012     | 521  | 16010000000000000946         | 1000041300000  | 01234567890123456789 |