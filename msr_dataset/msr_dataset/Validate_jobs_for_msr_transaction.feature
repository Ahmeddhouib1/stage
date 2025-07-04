@sde @msr @jobs @00x @62x @61x @23x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: Validate Jobs for MSR transaction
"""
    This feature file validate jobs for Msr Transactions config (0091, 0054)
    Jobs values allowed for msr:
         0 : Track 1
         2 : Track 2
         6 : PAN from Track1
         7 : PAN from Track2,
         10 Expiry date from Track1
         11 Expiry date from Track2
         14 Cardholder name from Track1
         18 :Track1 no sentinels
         19 :Track2 no sentinels
    TestLink test case link: https://testlink.evf.us/linkto.php?tprojectPrefix=ARC&item=testcase&id=ARC-1033
"""

  Scenario: Enable On-Guard SDE Encryption Configuration and Update jobs values(7 =PAN from Track2, 2 = Track-2 data, 10 Expiry date from Track1)

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    When I send a 61.x Read Configuration message to the terminal with:
      | p61_req_config_name | ArcSec/onGuardSde/jobsMsr |

    Then I should receive the 61.x Read Configuration response from terminal with params:
      | p61_res_status                | 2                         |
      | p61_res_config_name           | ArcSec/onGuardSde/jobsMsr |
      | p61_res_data_config_parameter | 18,19                     |

    When I have successfully sent "Files/Jobs_Msr/ArcSec.apk" file using these params:
      | p62_req_file_name       | ArcSec.apk |
      | p62_req_encoding_format | B          |
      | p62_req_fast_download   | 1          |
      | p62_req_unpack_flag     | 0          |

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

    When I send a 61.x Read Configuration message to the terminal with:
      | p61_req_config_name | ArcSec/onGuardSde/jobsMsr |

    Then I should receive the 61.x Read Configuration response from terminal with params:
      | p61_res_status                | 2                         |
      | p61_res_config_name           | ArcSec/onGuardSde/jobsMsr |
      | p61_res_data_config_parameter | 7,2,10                    |

  Scenario Outline: On-Guard SDE Encryption For MSR Transaction

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
      | p61_res_data_config_parameter | 19 |

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

    And decrypted field "p23_res_track3" with ON GUARD SDE algorithm should match the following data:
      | result | <pan>\|;<pan>=<exp_date><code><disc_data_t2>?<lrc_val>\|<exp_date><null_characters> |

    Examples:
      | card_type  | pan              | name               | exp_date | code | disc_data_t1                 | disc_data_t2   | additional_data      | masked_pan       | masked_disc_data_t1          | masked_disc_data_t2 | null_characters          | lrc_val |
      | Mastercard | 5413330089020011 | TEST/CARD          | 2412     | 221  | 000000140000000              | 0000014000001  | 01234567890123456789 | 5413330000000011 | 000000000000000              | 0000000000000       | \x00\x00                 | 9       |
      | Amex       | 374245001731008  | XP CARD 07/VER 2.0 | 2103     | 201  | 150412345                    | 15041234500000 |                      | 374245000001008  | 000000000                    | 00000000000000      | \x00\x00\x00             | 4       |
      | VISA       | 4264510228395621 | JOHN/SMITH         | 1709     | 206  | 0000000000000000000704001000 | 0000070400100  |                      | 4264510000005621 | 0000000000000000000000000000 | 0000000000000       | \x00\x00                 | 2       |
      | DISCOVER   | 6510000000000091 | CARD/IMAGE 09      | 1712     | 702  | 1000041300000                | 1000041300000  |                      | 6510000000000091 | 0000000000000                | 0000000000000       | \x00\x00                 | 4       |
      | Diners     | 36039667170472   | PETTITT/JO         | 0012     | 521  | 16010000000000000946         | 1000041300000  | 01234567890123456789 | 36039600000472   | 00000000000000000000         | 0000000000000       | \x00\x00\x00\x00\x00\x00 | 4       |
      | VISA       | 4761739001010010 | Test Card 04       | 2212     | 201  | 16010000000000000946         | 1000041300000  | 01234567890123456789 | 4761730000000010 | 00000000000000000000         | 0000000000000       | \x00\x00                 | 6       |
      | Mastercard | 5413330089099130 | Test Card 20       | 2512     | 201  | 16010000000000000946         | 1000041300000  | 01234567890123456789 | 5413330000009130 | 00000000000000000000         | 0000000000000       | \x00\x00                 | 9       |

