@sde @msr @00x @62x @61x @41x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: Validate step of decryption for On-Guard SDE dukpt Encryption for MSR transaction

  Scenario: Enable OGSDE DUKPT with AES128 Encryption Configuration

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    When I have successfully sent "Files/p2p_encryptions/ArcOnGuard-SDE-AES128.apk" file using these params:
      | p62_req_file_name       | ArcOnGuard-SDE-AES128.apk |
      | p62_req_encoding_format | B                         |
      | p62_req_fast_download   | 1                         |
      | p62_req_unpack_flag     | 0                         |

    Then I should receive the 62.x Write File response from terminal with params:
      | p62_res_status      | 0            |
      | p62_res_file_length | @regexp:.\d* |

    When I send a 61.x Configuration Read message to the terminal with:
      | p61_req_group_num | 91 |
      | p61_req_index_num | 1  |

    Then I should receive the 61.x Configuration Read response from terminal with params:
      | p61_res_status                | 2  |
      | p61_res_group_num             | 91 |
      | p61_res_index_num             | 1  |
      | p61_res_data_config_parameter | 19 |

  Scenario Outline: On-Guard SDE DUKPT AES Encryption For MSR Transaction

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
      | p61_res_data_config_parameter | 19 |

    When I send a 41.x Card Read Message message to the terminal with params:
      | p41_req_parse_flag       | 1 |
      | p41_req_msr_flag         | 1 |
      | p41_req_contactless_flag | 0 |
      | p41_req_smc_flag         | 0 |

    And I wait for 2 seconds

    And Axium swipe magnetic card:
      | track1 | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2 | <pan>=<exp_date><code><disc_data_t2>         |
      | track3 | <additional_data><additional_data>           |
    And I wait 2 seconds

    Then I should receive the 41.x Card Read Message response from terminal with params:
      | p41_res_source          | M                                                            |
      | p41_res_encryption      | 19                                                           |
      | p41_res_track_1_status  | 0                                                            |
      | p41_res_track_2_status  | 0                                                            |
      | p41_res_track_3_status  | 0                                                            |
      | p41_res_track_1         | %B<masked_pan>^<name>^<exp_date><code><masked_disc_data_t1>? |
      | p41_res_track_2         | ;<masked_pan>=<exp_date><code><masked_disc_data_t2>?         |
      | p41_res_track_3         | @regexp:.+                                                   |
      | p41_res_pan             | <masked_pan>                                                 |
      | p41_res_masked_pan      | <masked_pan>                                                 |
      | p41_res_expiration_date | <exp_date>                                                   |
      | p41_res_account_name    | <name>                                                       |
      | p41_res_error_code      | 0                                                            |
    ######################### MSR transaction decryption for SDE AES DUKPT#############################

    And decrypted field 'p41_res_track_3' with AES DUKPT algorithm should match the following MSR data:
      | result | B<pan>^<name>^<exp_date><code><disc_data_t1>\x00<pan>=<exp_date><code><disc_data_t2><null_characters> |

    Examples:
      | card_type  | pan              | name               | exp_date | code | disc_data_t1                 | disc_data_t2   | additional_data      | masked_pan       | masked_disc_data_t1          | masked_disc_data_t2 | null_characters                          |
      | Mastercard | 5413330089020011 | TEST/CARD          | 2412     | 221  | 000000140000000              | 0000014000001  | 01234567890123456789 | 5413330000000011 | 000000000000000              | 0000000000000       | \x00\x00\x00\x00\x00\x00\x00\x00         |
      | Amex       | 374245001731008  | XP CARD 07/VER 2.0 | 2103     | 201  | 150412345                    | 15041234500000 |                      | 374245000001008  | 000000000                    | 00000000000000      | \x00\x00\x00\x00\x00\x00                 |
      | VISA       | 4264510228395621 | JOHN/SMITH         | 1709     | 206  | 0000000000000000000704001000 | 0000070400100  |                      | 4264510000005621 | 0000000000000000000000000000 | 0000000000000       | \x00\x00\x00\x00\x00\x00\x00\x00\x00\x00 |
      | DISCOVER   | 6510000000000091 | CARD/IMAGE 09      | 1712     | 702  | 1000041300000                | 1000041300000  |                      | 6510000000000091 | 0000000000000                | 0000000000000       | \x00\x00\x00\x00\x00\x00                 |
      | Diners     | 36039667170472   | PETTITT/JO         | 0012     | 521  | 16010000000000000946         | 1000041300000  | 01234567890123456789 | 36039600000472   | 00000000000000000000         | 0000000000000       | \x00\x00\x00\x00\x00\x00                 |

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