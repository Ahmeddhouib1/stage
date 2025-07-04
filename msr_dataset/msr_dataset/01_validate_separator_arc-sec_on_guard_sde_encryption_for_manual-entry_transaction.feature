@sde @msr @00x @62x @61x @23x
Feature: Validate separator of On-Guard SDE Encryption for Manual Entry transaction
"""
 This feature file validates separator of On-Guard SDE Encryption for Manual Entry transaction
 based on ticket    https://ingenico-nar.atlassian.net/browse/ARC-1299
 Note : ArcSec.json used in current FF is the version from DefaultConfig of ARC Build "arc-app-23.09.03-0001"
 """
  @dx8000 @ex8000 @dx4000
  Scenario Outline: On-Guard SDE Encryption For MSR Transaction

    Given I successfully changed configuration "0007" "0029" to "1"

    ##################### Enable Onguard_SDE with specific separator #####################
    And a existing file "Files/p2p_encryptions/ArcSec_separator/ArcSec_separator_<ASCII>.apk"
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
      | p23_req_prompt_index   | 372 |
      | p23_req_enable_devices | M   |

    Then I Wait until Element "title" contains "Card"

    And  I wait until Element "btn_cancel" visible

    And  I wait until Element "btn_manual_entry" visible
    When I click Element "btn_manual_entry"

    ##################### Enter card details #####################
    And I click Element "ed_pan"
    And I send keys to Element "ed_pan" text "<pan>"

    And I press enter button

    And I click Element "ed_expiry_date"
    And I send keys to Element "ed_expiry_date" text "<exp_date>"

    And I press enter button

    And I click Element "ed_cvv"
    And I send keys to Element "ed_cvv" text "<code>"

    And I press enter button

    And I click Element "btn_manual_confirm"

    Then I should receive the 23.x Card Read response from terminal with params:
      | p23_res_exit_type   | 0                                                             |
      | p23_res_card_source | H                                                             |
      | p23_res_track1      | %M<masked_pan>^<name>^<expect_exp_date><masked_disc_data_t1>? |
      | p23_res_track2      | ;<masked_pan>=<expect_exp_date><masked_disc_data_t2>?         |
      | p23_res_track3      | @regexp:.{1,92}                                               |

    And decrypted field "p23_res_track3" with ON GUARD SDE algorithm should match the following data:
      | result | <pan><separator><expect_exp_date><separator><code><null_characters> |

    Examples:
      | card_type  | pan                 | name             | exp_date | expect_exp_date | code | masked_pan          | masked_disc_data_t1 | masked_disc_data_t2 | null_characters              | separator | ASCII |
      | Mastercard | 5413332389          | MANUALLY/ENTERED | 1224     | 2412            | 221  | 5413330009          | 000000000000000     | 000000000000        | \x00\x00\x00\x00\x00         | #         | 23    |
      | Amex       | 374245001748        | MANUALLY/ENTERED | 1225     | 2512            | 201  | 374245000748        | 000000000000000     | 000000000000        | \x00\x00\x00                 | ;         | 3B    |
      | VISA       | 42645122835621      | MANUALLY/ENTERED | 1227     | 2712            | 206  | 42645100005621      | 000000000000000     | 000000000000        | \x00                         | \|        | 7C    |
      | DISCOVER   | 6510000000352591    | MANUALLY/ENTERED | 1227     | 2712            | 702  | 6510000000002591    | 000000000000000     | 000000000000        | \x00\x00\x00\x00\x00\x00\x00 | %         | 25    |
      | Diners     | 36039667176631472   | MANUALLY/ENTERED | 1228     | 2812            | 521  | 36039600000001472   | 000000000000000     | 000000000000        | \x00\x00\x00\x00\x00\x00     | &         | 26    |
      | VISA       | 476173900101012010  | MANUALLY/ENTERED | 1229     | 2912            | 201  | 476173000000002010  | 000000000000000     | 000000000000        | \x00\x00\x00\x00\x00         | \x20      | 20    |
      | JCB        | 3569990010745082211 | MANUALLY/ENTERED | 1225     | 2512            | 601  | 3569990000000002211 | 000000000000000     | 000000000000        | \x00\x00\x00\x00             | ,         | 2C    |
      | Mastercard | 5413330089099130    | MANUALLY/ENTERED | 1226     | 2612            | 201  | 5413330000009130    | 000000000000000     | 000000000000        | \x00                         |           | empty |

  @rx5000 @rx7000
  Scenario Outline: On-Guard SDE Encryption For MSR Transaction

    Given I successfully changed configuration "0007" "0029" to "1"

    ##################### Enable Onguard_SDE with specific separator #####################
    And a existing file "Files/p2p_encryptions/ArcSec_separator/ArcSec_separator_<ASCII>.apk"
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
      | p23_req_prompt_index   | 372 |
      | p23_req_enable_devices | M   |

    Then I Wait until Element "title" contains "Card"

    And  I wait until Element "btn_cancel" visible

    And  I wait until Element "btn_manual_entry" visible
    When I click Element "btn_manual_entry"

    ##################### Enter card details #####################
    And I click Element "ed_pan"
    And I send keys to Element "ed_pan" text "<pan>"

    And I press enter button

    And I click Element "ed_expiry_date"
    And I send keys to Element "ed_expiry_date" text "<exp_date>"

    And I press enter button

    And I click Element "ed_cvv"

    And I send keys to Element "ed_cvv" text "<code>" and then ENTER

    Then I should receive the 23.x Card Read response from terminal with params:
      | p23_res_exit_type   | 0                                                             |
      | p23_res_card_source | H                                                             |
      | p23_res_track1      | %M<masked_pan>^<name>^<expect_exp_date><masked_disc_data_t1>? |
      | p23_res_track2      | ;<masked_pan>=<expect_exp_date><masked_disc_data_t2>?         |
      | p23_res_track3      | @regexp:.{1,92}                                               |

    And decrypted field "p23_res_track3" with ON GUARD SDE algorithm should match the following data:
      | result | <pan><separator><expect_exp_date><separator><code><null_characters> |

    Examples:
      | card_type  | pan                 | name             | exp_date | expect_exp_date | code | masked_pan          | masked_disc_data_t1 | masked_disc_data_t2 | null_characters              | separator | ASCII |
      | Mastercard | 5413332389          | MANUALLY/ENTERED | 1224     | 2412            | 221  | 5413330009          | 000000000000000     | 000000000000        | \x00\x00\x00\x00\x00         | #         | 23    |
      | Amex       | 374245001748        | MANUALLY/ENTERED | 1225     | 2512            | 201  | 374245000748        | 000000000000000     | 000000000000        | \x00\x00\x00                 | ;         | 3B    |
      | VISA       | 42645122835621      | MANUALLY/ENTERED | 1227     | 2712            | 206  | 42645100005621      | 000000000000000     | 000000000000        | \x00                         | \|        | 7C    |
      | DISCOVER   | 6510000000352591    | MANUALLY/ENTERED | 1227     | 2712            | 702  | 6510000000002591    | 000000000000000     | 000000000000        | \x00\x00\x00\x00\x00\x00\x00 | %         | 25    |
      | Diners     | 36039667176631472   | MANUALLY/ENTERED | 1228     | 2812            | 521  | 36039600000001472   | 000000000000000     | 000000000000        | \x00\x00\x00\x00\x00\x00     | &         | 26    |
      | VISA       | 476173900101012010  | MANUALLY/ENTERED | 1229     | 2912            | 201  | 476173000000002010  | 000000000000000     | 000000000000        | \x00\x00\x00\x00\x00         | \x20      | 20    |
      | JCB        | 3569990010745082211 | MANUALLY/ENTERED | 1225     | 2512            | 601  | 3569990000000002211 | 000000000000000     | 000000000000        | \x00\x00\x00\x00             | ,         | 2C    |
      | Mastercard | 5413330089099130    | MANUALLY/ENTERED | 1226     | 2612            | 201  | 5413330000009130    | 000000000000000     | 000000000000        | \x00                         |           | empty |

  @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
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