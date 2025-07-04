@rsa @msr @secbin @00x @62x @61x @23x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: Validate RSA Encryption for MSR transaction
"""
 This feature file validates RSA Encryption for MSR transaction
 https://testlink.evf.us/linkto.php?tprojectPrefix=ARC&item=testcase&id=ARC-1335
 """


  Scenario: Enable Whitelisting Configuration

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    When I have successfully sent "Files/whitelisting/apstitan_on.apk" file using these params:
      | p62_req_file_name       | apstitan_on.apk |
      | p62_req_encoding_format | B               |
      | p62_req_fast_download   | 1               |
      | p62_req_unpack_flag     | 0               |

    Then I should receive the 62.x Write File response from terminal with params:
      | p62_res_status      | 0           |
      | p62_res_file_length | @regexp:\d* |

  Scenario Outline: RSA Encryption For MSR Transaction

    #Step 5
    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    When I send a 61.x Read Configuration message to the terminal with:
      | p61_req_group_num | 91 |
      | p61_req_index_num | 1  |

    Then I should receive the 61.x Read Configuration response from terminal with params:
      | p61_res_status                | 2  |
      | p61_res_group_num             | 91 |
      | p61_res_index_num             | 1  |
      | p61_res_data_config_parameter | 9  |

    When I send a 23.x Card Read message to the terminal with:
      | p23_req_enable_devices | M |
      | p23_req_prompt_index   | 3 |

    Then I Wait until Element "title" contains "Please slide card"

    And  I wait until Element "btn_cancel" visible

    #this step is equivalent to the manual swipe of a card
    When Axium swipe magnetic card:
      | track1 | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2 | <pan>=<exp_date><code><disc_data_t2>         |
      | track3 | <additional_data><additional_data>           |


    Then I should receive the 23.x Card Read response from terminal with params:
      | p23_res_exit_type   | 0                                            |
      | p23_res_card_source | M                                            |
      | p23_res_track1      | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | p23_res_track2      | <pan>=<exp_date><code><disc_data_t2>         |
      | p23_res_track3      | @regexp:.*                                   |


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

    Examples:
      | card_type  | pan                 | name                   | exp_date | code | disc_data_t1         | disc_data_t2   | additional_data      |
      | Mastercard | 5413330089020011    | TEST/CARD              | 1225     | 221  | 000000140000000      | 0000014000001  | 01234567890123456789 |
      | Amex       | 374245002771003     | XP CARD 07/VER 2.0     | 1125     | 2222 | 150412345            | 15041234500000 |                      |
      | DISCOVER   | 651000000880000091  | CARD/IMAGE 09          | 0626     | 702  | 0074901              | 0897740001     |                      |
      | Diners     | 36039667170472      | PETTITT/JO             | 1200     | 521  | 1000041300000        | 1000041300000  |                      |
      | VISA       | 4264510228321       | JOHN/SMITH             | 0725     | 206  | 16010000000000000946 | 1000041300000  |                      |
      | DISCOVER   | 65100000111331191   | CARD/IMAGE 08          | 0626     | 702  | 16010000000000000946 | 1000041300000  | 01234567890123456789 |
      | Maestro    | 501833000060        | USA DEBIT/TEST CARD 16 | 1225     | 201  | 1000074900000        | 1000041300000  | 01234567890123456789 |
      | DISCOVER   | 6510000011122331191 | CARD/IMAGE 07          | 0626     | 702  | 0074901              | 0897740001     | 01234567890123456789 |


  Scenario: Teardown - Reset to Default State

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    When I have successfully sent "Files/whitelisting/apstitan_off.apk" file using these params:
      | p62_req_file_name       | apstitan_off.apk |
      | p62_req_encoding_format | B               |
      | p62_req_fast_download   | 1               |
      | p62_req_unpack_flag     | 0               |

    Then I should receive the 62.x Write File response from terminal with params:
      | p62_res_status      | 0           |
      | p62_res_file_length | @regexp:\d* |