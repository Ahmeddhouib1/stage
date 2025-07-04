@collis @msr @emv @cless @visa @amex @online_pin_cvm @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: 23.x Card Read Request
"""
    Using this feature file, we ensure that the reader should be disabled after start performing a transaction
    Test link test case link: https://testlink.evf.us/linkto.php?tprojectPrefix=ARC&item=testcase&id=ARC-1198
  """

  Scenario Outline: Send 23.x Card Read Request insert and remove chip card then swipe .

    Given I successfully changed configuration "0019" "0001" to "1"

    And I successfully changed configuration "0019" "0021" to "1"

    And  I initiating Collis Test Case with the following params:
      | brand     | American_Express |
      | interface | contact          |
      | test_plan | Quick_Chip_1__2  |
      | test_case | <test_case>      |

    And I wait 20 seconds

    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    When  I send a 13.x amount message to the terminal with:
      | p13_req_amount   | <amount> |
      | p13_req_cashback |          |

    Then I should receive the 13.x amount response from terminal with params:
      | p13_res_status | 0 |

    When I insert card

    And I wait 2 seconds

    When I send a 23.x Read Card message to the terminal with:
      | p23_req_prompt_index   | 100 |
      | p23_req_form_name      |     |
      | p23_req_enable_devices | S   |

    And I wait 2 seconds

    Then I should receive the 23.x Read Card response from terminal with params:

      | p23_res_exit_type   | 0 |
      | p23_res_card_source | Q |
      | p23_res_track1      |   |
      | p23_res_track2      |   |
      | p23_res_track3      |   |

    When I enter pin "00123"

    And I Wait until Element "title" contains "Please wait…\nDo not remove card"

    When I remove card

    Then I should receive the 33.05 Emv authorization confirmation response from terminal with params:
      | p33_05_res_status                  | 00         |
      | p33_05_res_emvh_current_packet_nbr | 0          |
      | p33_05_res_emvh_packet_type        | 0          |
      | p33_05_res_payload                 | @regexp:.* |

    When  I deserialize "p33_05_res_payload" value from the response object to the "authorization_confirmation_data" container

    Then  the reported "authorization_confirmation_data" container should have the following params:
      | tag    | name                                           | value                  |
      | 0x4F   | application_identifier                         | <adf>                  |
      | 0x84   | dedicated_file_df_name                         | <adf>                  |
      | 0x9C   | transaction_type                               | 00                     |
      | 0x1001 | ingenico_proprietary_pin_entry_required_flag   | U                      |
      | 0x1002 | ingenico_proprietary_signature_required_flag   | U                      |
      | 0x1005 | ingenico_proprietary_transaction_type          | 00                     |
      | 0x100F | ingenico_proprietary_pin_entry_successful_flag | U                      |
      | 0x1010 | ingenico_proprietary_error_response_code       | CRPRE                  |
      | 0x5F20 | cardholder_name                                | <cardholder_name>      |
      | 0x5F24 | application_expiration_date                    | <exp_date>31           |
      | 0x5F28 | issuer_country_code_kernel_2                   | 0840                   |
      | 0x9000 | ingenico_proprietary_card_payment_type         | B                      |
      | 0x9001 | ingenico_proprietary_card_entry_mode           | C                      |
      | 0x9F02 | amount_authorised_kernel_v2                    | 00000000<amount>       |
      | 0x9F03 | amount_other                                   | 000000000000           |
      | 0x9F0D | issuer_action_code_default                     | BC50ECA800             |
      | 0x9F0E | issuer_action_code_denial                      | 0000000000             |
      | 0x9F0F | issuer_action_code_online                      | BC78FCF800             |
      | 0x9F1A | terminal_country_code                          | 0840                   |
      | 0x9F1B | terminal_floor_limit                           | 00002710               |
      | 0x9F33 | terminal_capabilities                          | @regexp:[0-9A-Fa-f]{6} |
      | 0x9F35 | terminal_type                                  | @regexp:\d{2}          |
      | 0x9F39 | point_of_service_pos_entry_mode                | 05                     |
      | 0xDF03 | pin_try_limit_kernel_v2                        | C800000000             |
      | 0xDF04 | pin_try_counter                                | 0000000000             |
      | 0xDF05 | aip_for_visa_contactless                       | C800000000             |
      | 0xFF25 | Encryption/Whitelisting_mode                   | 00                     |

    And I should receive the 09.x Set Allowed Payment response from terminal with params:
      | p09_res_card_type        | 02 |
      | p09_res_msg_version      | 02 |
      | p09_res_transaction_type | 01 |
      | p09_res_card_status      | R  |

    And I Wait until Element "title" contains "Card removed\nTransaction canceled"

    When I swipe card using this params:
      | track1_data | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2_data | <pan>=<exp_date><code><disc_data_t2>         |
      | track3_data |                                              |

    And I should not receive in "2" seconds anything from terminal

    Then I Wait until Element "title" contains "Card removed\nTransaction canceled"

    And I successfully changed configuration "0019" "0001" to "0"

    And I successfully changed configuration "0019" "0021" to "0"

    Examples:
      | test_case                                | adf              | cardholder_name  | pan             | exp_date | amount |
      | AXP QC 032 - Online PIN - Successful PIN | A000000025010801 | AEIPS 22/VER 2.3 | 374245001751006 | 2512     | 3250   |

  Scenario Outline: Send 23.x Card Read Request Tap and Remove contacless card then swipe .

    Given I successfully changed configuration "0008" "0001" to "9"

    And I initiating Collis Test Case with the following params:
      | brand     | Visa                                 |
      | interface | contactless                          |
      | test_plan | 06_VisaL3Testing_series_01_build_019 |
      | test_case | <test_case>                          |

    And I wait 20 seconds

    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    When  I send a 13.x amount message to the terminal with:
      | p13_req_amount   | <amount> |
      | p13_req_cashback |          |

    Then I should receive the 13.x amount response from terminal with params:
      | p13_res_status | 0 |

    When I send a 23.x Read Card message to the terminal with:
      | p23_req_prompt_index   | 371        |
      | p23_req_form_name      | read_cards |
      | p23_req_enable_devices | MC         |

    And I Wait until Element "title" contains "Tap"

    And I tap contactless card

    Then I should receive the 23.x Read Card response from terminal with params:
      | p23_res_exit_type   | 0                          |
      | p23_res_card_source | E                          |
      | p23_res_track1      |                            |
      | p23_res_track2      | <pan>=<exp_date><add_data> |
      | p23_res_track3      | @regexp:.*                 |

    And I should receive the 33.02 Emv Transaction track2 response from terminal with params:
      | p33_02_res_status                  | 00         |
      | p33_02_res_emvh_current_packet_nbr | 0          |
      | p33_02_res_emvh_packet_type        | 0          |
      | p33_02_res_payload                 | @regexp:.+ |

    When  I deserialize "p33_02_res_payload" value from the response object to the "track2_equivalent_data" container
    Then  the reported "track2_equivalent_data" container should have the following params:
      | tag    | name                                         | value                      |
      | 0x4F   | application_identifier                       | <adf>                      |
      | 0x57   | track_2_equivalent_data                      | <pan>D<exp_date><add_data> |
      | 0x84   | dedicated_file_df_name                       | <adf>                      |
      | 0x1002 | ingenico_proprietary_signature_required_flag | 0                          |
      | 0x5F28 | issuer_country_code_kernel_2                 | 0840                       |
      | 0x5F20 | cardholder_name                              | <cardholder_name>          |
      | 0x5F24 | application_expiration_date                  | <exp_date>31               |
      | 0x9F1A | terminal_country_code                        | 0840                       |
      | 0x9F1B | terminal_floor_limit                         | 00002710                   |
      | 0xFF25 | Encryption/Whitelisting_mode                 | 00                         |

    When I enter pin "1234"

    Then I should receive the 33.03 Emv Transaction authorization_request response from terminal with params:
      | p33_03_req_status                  | 00         |
      | p33_03_req_emvh_current_packet_nbr | 0          |
      | p33_03_req_emvh_packet_type        | 0          |
      | p33_03_req_payload                 | @regexp:.+ |

    When I deserialize "p33_03_res_payload" value from the response object to the "authorization_request_data" container
    Then the reported "authorization_request_data" container should have the following params:
      | tag    | name                                           | value                      |
      | 0x4F   | application_identifier                         | <adf>                      |
      | 0x57   | track_2_equivalent_data                        | <pan>D<exp_date><add_data> |
      | 0x84   | dedicated_file_df_name                         | <adf>                      |
      | 0x95   | terminal_verification_results                  | 0000000000                 |
      | 0x9C   | transaction_type                               | 00                         |
      | 0x1002 | ingenico_proprietary_signature_required_flag   | 0                          |
      | 0x1005 | ingenico_proprietary_transaction_type          | 00                         |
      | 0x100F | ingenico_proprietary_pin_entry_successful_flag | 1                          |
      | 0x5F20 | cardholder_name                                | <cardholder_name>          |
      | 0x5F24 | application_expiration_date                    | <exp_date>31               |
      | 0x5F28 | issuer_country_code_kernel_2                   | 0840                       |
      | 0x9000 | ingenico_proprietary_card_payment_type         | B                          |
      | 0x9001 | ingenico_proprietary_card_entry_mode           | D                          |
      | 0x9F02 | amount_authorised_kernel_v2                    | 00000000<amount>           |
      | 0x9F03 | amount_other                                   | 000000000000               |
      | 0x9F1A | terminal_country_code                          | 0840                       |
      | 0x9F1B | terminal_floor_limit                           | 00002710                   |
      | 0x9F26 | application_cryptogram                         | @regexp:[0-9A-Fa-f]{16}    |
      | 0x9F27 | cryptogram_information_data                    | 80                         |
      | 0x9F33 | terminal_capabilities                          | @regexp:[0-9A-Fa-f]{6}     |
      | 0x9F34 | cardholder_verification_method_cvm_results     | @regexp:[048C]{1}20300     |
      | 0x9F35 | terminal_type                                  | @regexp:\d{2}              |
      | 0x9F39 | point_of_service_pos_entry_mode                | 07                         |
      | 0xFF25 | Encryption/Whitelisting_mode                   | 00                         |


    When I send a 33.04 Authorization Response message to the terminal with params:
      | p33_04_res_status                  | 00             |
      | p33_04_res_emvh_current_packet_nbr | 0              |
      | p33_04_res_emvh_packet_type        | 0              |
      | p33_04_res_payload                 | T008A:0002:a00 |

    Then I should receive the 33.05 Emv authorization confirmation response from terminal with params:
      | p33_05_res_status                  | 00         |
      | p33_05_res_emvh_current_packet_nbr | 0          |
      | p33_05_res_emvh_packet_type        | 0          |
      | p33_05_res_payload                 | @regexp:.* |

    When  I deserialize "p33_05_res_payload" value from the response object to the "authorization_confirmation_data" container
    Then  the reported "authorization_confirmation_data" container should have the following params:
      | tag    | name                                           | value                      |
      | 0x4F   | application_identifier                         | <adf>                      |
      | 0x57   | track_2_equivalent_data                        | <pan>D<exp_date><add_data> |
      | 0x84   | dedicated_file_df_name                         | <adf>                      |
      | 0x8A   | authorisation_response_code                    | 00                         |
      | 0x95   | terminal_verification_results                  | 0000000000                 |
      | 0x9C   | transaction_type                               | 00                         |
      | 0x1002 | ingenico_proprietary_signature_required_flag   | 0                          |
      | 0x1005 | ingenico_proprietary_transaction_type          | 00                         |
      | 0x100F | ingenico_proprietary_pin_entry_successful_flag | 1                          |
      | 0x5F20 | cardholder_name                                | <cardholder_name>          |
      | 0x5F24 | application_expiration_date                    | <exp_date>31               |
      | 0x5F28 | issuer_country_code_kernel_2                   | 0840                       |
      | 0x9000 | ingenico_proprietary_card_payment_type         | B                          |
      | 0x9001 | ingenico_proprietary_card_entry_mode           | D                          |
      | 0x9F02 | amount_authorised_kernel_v2                    | 00000000<amount>           |
      | 0x9F03 | amount_other                                   | 000000000000               |
      | 0x9F1A | terminal_country_code                          | 0840                       |
      | 0x9F1B | terminal_floor_limit                           | 00002710                   |
      | 0x9F26 | application_cryptogram                         | @regexp:[0-9A-Fa-f]{16}    |
      | 0x9F27 | cryptogram_information_data                    | 80                         |
      | 0x9F33 | terminal_capabilities                          | @regexp:[0-9A-Fa-f]{6}     |
      | 0x9F34 | cardholder_verification_method_cvm_results     | @regexp:[048C]{1}20300     |
      | 0x9F35 | terminal_type                                  | @regexp:\d{2}              |
      | 0x9F39 | point_of_service_pos_entry_mode                | 07                         |
      | 0xDF03 | pin_try_limit_kernel_v2                        | DC4000A800                 |
      | 0xDF04 | pin_try_counter                                | 0010000000                 |
      | 0xDF05 | aip_for_visa_contactless                       | DC4004F800                 |
      | 0xFF25 | Encryption/Whitelisting_mode                   | 00                         |

    And I Wait until Element "title" contains "Approved"

    When I swipe card using this params:
      | track1_data | B<pan>^<name>^<exp_date><add_data> |
      | track2_data | <pan>=<exp_date>201<disc_data_t2>  |
      | track3_data |                                    |

    And I should not receive in "2" seconds anything from terminal

    Then I Wait until Element "title" contains "Approved"

    And I successfully changed configuration "0008" "0001" to "0"

    Examples:
      | test_case     | adf            | cardholder_name | pan              | exp_date | add_data    | amount | disc_data_t2  |
      | VISA.TC.1002a | A0000000031010 | L3TEST/CARD1002 | 4761731000000027 | 3112     | 20119058101 | 1600   | 0000014000001 |


