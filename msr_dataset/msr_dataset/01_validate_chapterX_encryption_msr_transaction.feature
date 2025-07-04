@p2p @chapter_x @msr @00x @62x @61x @23x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: validate chapter X Decryption
"""
 This feature file validates chapterX Encryption for MSR transaction
 https://testlink.evf.us/linkto.php?tprojectPrefix=ARC&item=testcase&id=ARC-1348
 """

  Scenario Outline: chapter X Encryption For MSR Transaction

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
      | p61_res_data_config_parameter | 30 |

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

    And decrypted field 'p23_res_track3' with Chapter X algorithm should match the following data:
      | ret                 | 00                                                         |
      | ez_track2_decrypted | <pan>D<exp_date><code><disc_data_t2><null_characters>      |
      | ey_track1_decrypted | @regexp:^B<pan>\^<name>\^<exp_date><code><disc_data_t1>.+$ |


    Examples:
      | card_type  | pan              | name               | exp_date | code | disc_data_t1                 | disc_data_t2   | additional_data      | masked_pan       | masked_disc_data_t1          | masked_disc_data_t2 | null_characters |
      | Mastercard | 5413330089020011 | TEST/CARD          | 2612     | 221  | 361010000000000933000000     | 0000014000001  | 01234567890123456789 | 5413330000000011 | 000000000000000000000000     | 0000000000000       | FFFFFFFFFFF     |
      | Amex       | 374245001731008  | XP CARD 07/VER 2.0 | 2103     | 201  | 150412345                    | 15041234500000 |                      | 374245000001008  | 000000000                    | 00000000000000      | FFFFFFFFFFF     |
      | VISA       | 4264510228395621 | JOHN/SMITH         | 1709     | 206  | 0000000000000000000704001000 | 0000070400100  |                      | 4264510000005621 | 0000000000000000000000000000 | 0000000000000       | FFFFFFFFFFF     |
      | DISCOVER   | 6510000000000091 | CARD/IMAGE 09      | 1712     | 702  | 1000041300000                | 1000041300000  |                      | 6510000000000091 | 0000000000000                | 0000000000000       | FFFFFFFFFFF     |
      | Diners     | 36039667170472   | PETTITT/JO         | 0012     | 521  | 16010000000000000946         | 1000041300000  | 01234567890123456789 | 36039600000472   | 00000000000000000000         | 0000000000000       | FFFFFFFFFFFFF   |
      | VISA       | 4761739001010010 | Test Card 04       | 2212     | 201  | 16010000000000000946         | 1000041300000  | 01234567890123456789 | 4761730000000010 | 00000000000000000000         | 0000000000000       | FFFFFFFFFFF     |
      | Mastercard | 541389099130     | Test Card 20       | 2512     | 201  | 16010000000000000946         | 1000041300000  | 01234567890123456789 | 541389000130     | 00000000000000000000         | 0000000000000       | FFFFFFFFFFFFFFF |
