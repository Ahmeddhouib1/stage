@sde @msr @00x @62x @61x @23x
@dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: Validate separator of On-Guard SDE Encryption for MSR transaction
"""
 This feature file validates separator of On-Guard SDE Encryption for MSR transaction
 based on ticket    https://ingenico-nar.atlassian.net/browse/ARC-1299
 Note : ArcSec.json used in current FF is the version from DefaultConfig of ARC Build "arc-app-23.09.02-0006"
 """

  Scenario Outline: On-Guard SDE Encryption For MSR Transaction

    ##################### Enable Onguard_SDE with specific separator #####################
    Given a existing file "Files/p2p_encryptions/ArcSec_separator/ArcSec_separator_<ASCII>.apk"
    When I have successfully sent "Files/p2p_encryptions/ArcSec_separator/ArcSec_separator_<ASCII>.apk" file using these params:
      | p62_req_file_name       | ArcSec_separator_<ASCII>.apk |
      | p62_req_encoding_format | B                            |
      | p62_req_fast_download   | 1                            |
      | p62_req_unpack_flag     | 0                            |
    Then I should receive the 62.x Write File response from terminal with params:
      | p62_res_status      | 0            |
      | p62_res_file_length | @regexp:.\d* |
    ##################### ########################################## #####################

    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |
    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |
    And I Wait until Element "title" contains "This Lane Closed"
    And I wait until Element "imageOffline" visible

    ##################### Verify Onguard_SDE enabled #####################
    When I send a 61.x Read Configuration message to the terminal with:
      | p61_req_group_num | 91 |
      | p61_req_index_num | 1  |
    Then I should receive the 61.x Read Configuration response from terminal with params:
      | p61_res_status                | 2  |
      | p61_res_group_num             | 91 |
      | p61_res_index_num             | 1  |
      | p61_res_data_config_parameter | 19 |
    ##################### ##################### #####################

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
      | p23_res_track3      | @regexp:.{1,252}                                             |

    And decrypted field "p23_res_track3" with ON GUARD SDE algorithm should match the following data:
      | result | B<pan>^<name>^<exp_date><code><disc_data_t1><separator><pan>=<exp_date><code><disc_data_t2><null_characters> |

    Examples:
      | card_type  | pan              | name               | exp_date | code | disc_data_t1                 | disc_data_t2  | additional_data      | masked_pan       | masked_disc_data_t1          | masked_disc_data_t2 | null_characters          | separator | ASCII |
      | Mastercard | 5413330089020011 | TEST/CARD          | 2412     | 221  | 000000140000000              | 0000014000001 | 01234567890123456789 | 5413330000000011 | 000000000000000              | 0000000000000       |                          | #         | 23    |
      | Amex       | 374245001731008  | XP CARD 07/VER 2.0 | 2512     | 201  | 150412345                    | 1504123450    |                      | 374245000001008  | 000000000                    | 0000000000          | \x00\x00                 | ;         | 3B    |
      | VISA       | 4264510228395621 | JOHN/SMITH         | 2712     | 206  | 0000000000000000000704001000 | 0000070400100 | 123456789            | 4264510000005621 | 0000000000000000000000000000 | 0000000000000       | \x00\x00                 | \|        | 7C    |
      | DISCOVER   | 6510000000000091 | CARD/IMAGE 09      | 2712     | 702  | 1000041300000                | 1000041300999 |                      | 6510000000000091 | 0000000000000                | 0000000000000       | \x00\x00\x00\x00\x00\x00 | %         | 25    |
      | Diners     | 36039667170472   | PETTITT/JO         | 2812     | 521  | 160100000000000007778946     | 1000051300000 | 0123456789           | 36039600000472   | 000000000000000000000000     | 0000000000000       | \x00\x00                 | &         | 26    |
      | VISA       | 4761739001010010 | VISA Credit        | 2912     | 201  | 16010000000000000946         | 10000413      | 01234567890123456789 | 4761730000000010 | 00000000000000000000         | 00000000            | \x00\x00\x00\x00\x00\x00 | \x20      | 20    |
      | Mastercard | 5413330089099130 | Test Card 20       | 2512     | 601  | 16010000000000946            | 1000041300000 | 01234567890123456789 | 5413330000009130 | 00000000000000000            | 0000000000000       | \x00\x00\x00\x00         |           | empty |
      | JCB        | 3569990010082211 | JCB/TEST           | 2612     | 201  | 1234567891234                | 987654321098  | 01234567890123456789 | 3569990000002211 | 0000000000000                | 000000000000        | \x00\x00\x00\x00         | ,         | 2C    |

   Scenario: Teardown - Reset to Default State

    Given a existing file "Files/p2p_encryptions/ArcNoEncryption.apk"
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

    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |
    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |
    And I Wait until Element "title" contains "This Lane Closed"
    And I wait until Element "imageOffline" visible