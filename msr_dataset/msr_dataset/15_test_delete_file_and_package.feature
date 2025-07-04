@msr @fpe @00x @62x @61x @63x @23x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: Validate steps of deleting package and files from terminal
"""
this testcase is to validate the steps of deleting a file and a package from terminal
 """

  Scenario Outline: delete a file from terminal

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    When I have successfully sent file through 62.x Write File request with:
      | p62_req_file_name       | <path>     |
      | p62_req_encoding_format | 7          |
      | p62_req_fast_download   | 1          |
      | p62_req_unpack_flag     | 0          |
      | p62_req_record_type     | 0          |
      | p62_req_segment_nbr     | 01         |
      | p62_req_file_data       | @regexp:.* |

    Then I should receive the 62.x Write File response from terminal with params:
      | p62_res_status      | 0           |
      | p62_res_file_length | @regexp:\d* |

    When I send a 63.x Find File message to the terminal with:
      | p63_req_file_name | Test.txt |
    And I should receive the 63.x Find File response from terminal with params:
      | p63_res_result      | 0  |
      | p63_res_file_length | 40 |

    When I delete file "/sdcard/Android/data/com.ingenico.retail.arcapp/files/Test.txt" from terminal

    And I send a 63.x Find File message to the terminal with:
      | p63_req_file_name | Test.txt |
    Then I should receive the 63.x Find File response from terminal with params:
      | p63_res_result      | 1 |
      | p63_res_file_length | 0 |

    Examples:
      | path           |
      | Files/Test.txt |

  Scenario: Enable encryption and Whitelisting Configuration

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    When I have successfully sent "Files/p2p_encryptions/ArcOnGuardFPE.apk" file using these params:
      | p62_req_file_name       | ArcOnGuardFPE.apk |
      | p62_req_encoding_format | B                 |
      | p62_req_fast_download   | 1                 |
      | p62_req_unpack_flag     | 0                 |

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
      | p61_res_data_config_parameter | 2  |

    When I have successfully sent "Files/whitelisting/apstitan_on.apk" file using these params:
      | p62_req_file_name       | apstitan_on.apk |
      | p62_req_encoding_format | B               |
      | p62_req_fast_download   | 1               |
      | p62_req_unpack_flag     | 0               |

    Then I should receive the 62.x Write File response from terminal with params:
      | p62_res_status      | 0           |
      | p62_res_file_length | @regexp:\d* |

  Scenario Outline: Validate steps of deleting package from terminal

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    When I send a 61.x Configuration Read message to the terminal with:
      | p61_req_group_num | 91 |
      | p61_req_index_num | 1  |

    Then I should receive the 61.x Configuration Read response from terminal with params:
      | p61_res_status                | 2  |
      | p61_res_group_num             | 91 |
      | p61_res_index_num             | 1  |
      | p61_res_data_config_parameter | 2  |


    When I send a 13.x amount message to the terminal with:
      | p13_req_amount | 1000 |

    Then I should receive the 13.x amount response from terminal with params:
      | p13_res_status | 0 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    When I send a 23.x Card Read message to the terminal with:
      | p23_req_prompt_index   | 312 |
      | p23_req_enable_devices | M   |

    Then I Wait until Element "title" contains "Insert, Swipe or Tap Card"

    When I swipe card using this params:
      | track1_data | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2_data | <pan>=<exp_date><code><disc_data_t2>         |
      | track3_data | <additional_data><additional_data>           |

    Then I should receive the 23.x Read Card response from terminal with params:
      | p23_res_exit_type   | 0                                            |
      | p23_res_card_source | M                                            |
      | p23_res_track1      | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | p23_res_track2      | <pan>=<exp_date><code><disc_data_t2>         |
      | p23_res_track3      | @regexp:.+                                   |


    When I uninstall package "com.ingenico.retail.aps.secure.parameters" from terminal

    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    When I send a 61.x Configuration Read message to the terminal with:
      | p61_req_group_num | 91 |
      | p61_req_index_num | 1  |

    Then I should receive the 61.x Configuration Read response from terminal with params:
      | p61_res_status                | 2  |
      | p61_res_group_num             | 91 |
      | p61_res_index_num             | 1  |
      | p61_res_data_config_parameter | 2  |

    When I send a 23.x Card Read message to the terminal with:
      | p23_req_prompt_index   | 311        |
      | p23_req_form_name      | read_cards |
      | p23_req_enable_devices | M          |

    Then I Wait until Element "title" contains "Please swipe or insert card"

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

#    Then I should receive the 23.x Card Read response from terminal with params:
#      | p23_res_exit_type   | 0          |
#      | p23_res_card_source | M          |
#      | p23_res_track1      | @regexp:.+ |
#      | p23_res_track2      | @regexp:.+ |
#      | p23_res_track3      | @regexp:.+ |

    And decrypted field "p23_res_track3" with ON GUARD algorithm should match the following MSR data:
      | track2 | <pan>=<exp_date><code><disc_data_t2> |


    Examples:
      | card_type  | pan              | name      | exp_date | code | disc_data_t1    | disc_data_t2  | additional_data      | masked_pan       | masked_disc_data_t1 | masked_disc_data_t2 |
      | Mastercard | 5413330089020011 | TEST/CARD | 2412     | 221  | 000000140000000 | 0000014000001 | 01234567890123456789 | 5413330000000011 | 000000000000000     | 0000000000000       |

  Scenario: Teardown - Reset to Default State

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

