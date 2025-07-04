@pin_code @master_session @rsa @msr @00x @60x @61x @23x @31x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature:  Validate  pin block decryption is correct when RSA enabled
"""
 This feature file verify pin block decryption is correct when RSA enabled
 based on ticket https://ingenico-nar.atlassian.net/browse/ARC-1772
 """

  Scenario: Enable RSA Encryption Configuration

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    When I have successfully sent "Files/p2p_encryptions/ArcRSA-OAEP.apk" file using these params:
      | p62_req_file_name       | ArcRSA-OAEP.apk |
      | p62_req_encoding_format | B               |
      | p62_req_fast_download   | 1               |
      | p62_req_unpack_flag     | 0               |

    Then I should receive the 62.x Write File response from terminal with params:
      | p62_res_status      | 0           |
      | p62_res_file_length | @regexp:\d* |

    When I send a 61.x Configuration Read message to the terminal with:
      | p61_req_group_num | 91 |
      | p61_req_index_num | 1  |

    Then I should receive the 61.x Configuration Read response from terminal with params:
      | p61_res_status                | 2  |
      | p61_res_group_num             | 91 |
      | p61_res_index_num             | 1  |
      | p61_res_data_config_parameter | 9  |

  Scenario Outline: verify pin block decryption is correct with masked pan

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
      | p61_res_data_config_parameter | 9  |

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
      | p23_res_exit_type   | 0                                                            |
      | p23_res_card_source | M                                                            |
      | p23_res_track1      | %B<masked_pan>^<name>^<exp_date><code><masked_disc_data_t1>? |
      | p23_res_track2      | ;<masked_pan>=<exp_date><code><masked_disc_data_t2>?         |
      | p23_res_track3      | @regexp:.+                                                   |

    When I send a 31.x PIN Entry message to the terminal with:
      | p31_req_prompt_index_number          | 1            |
      | p31_req_customer_acc_num             | <masked_pan> |
      | p31_req_set_encryption_configuration | 0            |
      | p31_req_set_key_type                 | *            |
      | p31_req_form_name                    |              |

    And I enter pin "<pin_code>"

    Then I should receive the 31.x PIN Entry response from terminal with params:
      | p31_res_status         | 0          |
      | p31_res_pin_data       | @regexp:.* |
      | p31_res_pin_data_ksn   | @regexp:.* |
      | p31_res_pin_data_block | @regexp:.* |

    And I will decrypt pin block from 'p31_res_pin_data_block' using the sequence of pan: '<pan>' and parameters 'p31_res_pin_data_ksn' and expect:
      | length   | <pin_length>                  |
      | pin_code | <pin_code>                    |
      | tail     | <tail>                        |
      | pinblock | 0<pin_length><pin_code><tail> |

    Examples:
      | card_type  | pan              | name               | exp_date | code | disc_data_t1                 | disc_data_t2   | masked_pan       | masked_disc_data_t1          | masked_disc_data_t2 | pin_code | pin_length | tail       |
      | Mastercard | 5413330089020011 | TEST/CARD          | 2412     | 221  | 000000140000000              | 0000014000001  | 5413330000000011 | 000000000000000              | 0000000000000       | 0000     | 4          | ffffffffff |
      | Amex       | 374245001731008  | XP CARD 07/VER 2.0 | 2103     | 201  | 150412345                    | 15041234500000 | 374245000001008  | 000000000                    | 00000000000000      | 1234     | 4          | ffffffffff |
      | VISA       | 4264510228395621 | JOHN/SMITH         | 1709     | 206  | 0000000000000000000704001000 | 0000070400100  | 4264510000005621 | 0000000000000000000000000000 | 0000000000000       | 12345    | 5          | fffffffff  |
      | DISCOVER   | 6510000000000091 | CARD/IMAGE 09      | 1712     | 702  | 1000041300000                | 1000041300000  | 6510000000000091 | 0000000000000                | 0000000000000       | 4321     | 4          | ffffffffff |
      | Diners     | 36039667170472   | PETTITT/JO         | 0012     | 521  | 16010000000000000946         | 1000041300000  | 36039600000472   | 00000000000000000000         | 0000000000000       | 5522     | 4          | ffffffffff |
      | VISA       | 4761739001010010 | Test Card 04       | 2212     | 201  | 16010000000000000946         | 1000041300000  | 4761730000000010 | 00000000000000000000         | 0000000000000       | 221100   | 6          | ffffffff   |
      | Mastercard | 5413330089099130 | Test Card 20       | 2512     | 201  | 16010000000000000946         | 1000041300000  | 5413330000009130 | 00000000000000000000         | 0000000000000       | 1133     | 4          | ffffffffff |
      | VISA       | 4761739001010010 | Test Card 04       | 2212     | 201  | 16010000000000000946         | 1000041300000  | 4761730000000010 | 00000000000000000000         | 0000000000000       | 22110055 | 8          | ffffff     |


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
