@msr @collis @emv @unionpay @signature_cvm @credit @00x @13x @23x @33x @04x @09x @dx8000 @ex8000 @rx5000 @rx7000
Feature: Validate UnionPay collis testcase TAIS_POS_005
"""
 - Requirement: Mandatory
 - Test purpose and description : To validate POS is able to complete the quasi credit transaction correctly
                                  when the application Label(Tag:50) and Application Preferred Name(Tag:9F12) contain Chinese Characters
 - Card No: FT05
 - Amount: 500
 - Testing Steps:
	  1.Please swipe a card first and the terminal shall prompt to use a chip card.
      2.Please insert a card and select purchase function.
      3. Choose 'UICC Quasi Credit'.
      4. Enter "500.00" as transaction amount.
      5. Enter a correct online PIN as '111111' if required.
      6. Processing completion
 - Expected result/note
      1. The terminal goes online to complete the transaction;
      2. The transaction is approved.

 Collis reports :resources\Collis\Reports\contact\UnionPay\Functional_V202205\POS\TAIS_POS_005.zip

 Note :
      - Cucumber does not support Chinese words
      - The Application Label from the image card is : D2 F8 C1 AA 36 32 B1 EA D7 BC BF A8 40 B2 E2 CA D4 D7 A8 D3 C3 43 61 72 64 73
      - encoded using Character encoding GB 18030 (Chinese) :  银联62标准卡@测试专用Cards (in English : UnionPay 62 Standard Card@Test Cards)
      - The Application Label only detects the readable characters (0x5F20 = '    62      @        Cards')

 """

  Scenario Outline: Instructions to cover testcase TAIS_POS_005

     ####################### Enable EMV Contact reader #######################
    Given I successfully changed configuration "0019" "0001" to "1"

    And I successfully changed configuration "0008" "0001" to "0"

    ####################### Initiating Collis #######################
    When  I initiating Collis Test Case with the following params:
      | brand     | UnionPay           |
      | interface | contact            |
      | test_plan | Functional_V202205 |
      | test_case | <test_case>        |

    And I wait 20 seconds

    And I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    ####################### Start Transaction #######################

    When I send a 13.x amount message to the terminal with:
      | p13_req_amount | <amount> |

    Then I should receive the 13.x amount response from terminal with params:
      | p13_res_status | 0 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    ####################### Swipe card step #######################

    When I send a 23.x Card Read message to the terminal with:
      | p23_req_prompt_index   | 312 |
      | p23_req_enable_devices | M   |

    Then I Wait until Element "title" contains "Insert, Swipe or Tap Card"

    When I swipe card using this params:
      | track1_data | B<PAN>^<app_label>^<exp_date><code><add_data> |
      | track2_data | <PAN>=<exp_date><code><add_data>              |
      | track3_data |                                               |

    Then I should receive the 23.x Read Card response from terminal with params:
      | p23_res_exit_type   | 0                                             |
      | p23_res_card_source | M                                             |
      | p23_res_track1      | B<PAN>^<app_label>^<exp_date><code><add_data> |
      | p23_res_track2      | <PAN>=<exp_date><code><add_data>              |
      | p23_res_track3      |                                               |
     ####################### EMV Transaction flow #######################

    When I insert card

    And I send a 23.x Read Card message to the terminal with:
      | p23_req_prompt_index   | 100        |
      | p23_req_form_name      | read_cards |
      | p23_req_enable_devices | S          |

    Then I should receive the 23.x Card Read response from terminal with params:
      | p23_res_exit_type   | 0 |
      | p23_res_card_source | S |
      | p23_res_track1      |   |
      | p23_res_track2      |   |
      | p23_res_track3      |   |

    And I Wait until Element "title" contains "Please wait…\nDo not remove card"

    When I send a 33.00 EMV Transaction Initiation message to the terminal with:
      | p33_00_req_status                  | 00 |
      | p33_00_req_emvh_current_packet_nbr | 0  |
      | p33_00_req_emvh_packet_type        | 0  |

    Then I Wait until Element "title" contains "Please wait…\nDo not remove card"

    And  I should receive the 33.00 Emv Transaction Initiation response from terminal with params:
      | p33_00_res_status                  | 00 |
      | p33_00_res_emvh_current_packet_nbr | 0  |
      | p33_00_res_emvh_packet_type        | 0  |

    And I should receive the 33.02 Emv Transaction track2 response from terminal with params:
      | p33_02_res_status                  | 00         |
      | p33_02_res_emvh_current_packet_nbr | 0          |
      | p33_02_res_emvh_packet_type        | 0          |
      | p33_02_res_payload                 | @regexp:.+ |

      ####################### 33.02 payload verification #######################
    When  I deserialize "p33_02_res_payload" value from the response object to the "track2_equivalent_data" container
    Then  the reported "track2_equivalent_data" container should have the following params:
      | tag    | name                         | value                                                 |
      | 0x4F   | application_identifier       | <AID>03                                               |
      | 0x50   | application_label            | @regexp:[\s]{4}62[\s]{4}IC[\s]{2}                     |
      | 0x57   | track_2_equivalent_data      | <PAN>D<exp_date><code><add_data>F                     |
      | 0x5A   | Primary_Account_Number_(PAN) | <PAN>                                                 |
      | 0x84   | dedicated_file_df_name       | <AID>03                                               |
      | 0x5F20 | cardholder_name              | UICC<test_card>                                       |
      | 0x5F24 | application_expiration_date  | <exp_date>31                                          |
      | 0x5F28 | Issuer_Country_Code          | 0156                                                  |
      | 0x5F2D | preferred_languages          | zh                                                    |
      | 0x9F07 | Application_Usage_Control    | FF00                                                  |
      | 0x9F09 | Application_Version_Number   | @regexp:\d{4}                                         |
      | 0x9F1A | Terminal_Country_Code        | 0840                                                  |
      | 0x9F1B | Terminal_Floor_Limit         | 00000000                                              |
      | 0x9F1F | Track1_Discretionary_Data    | <PAN>^UICC<test_card>^<exp_date><code>^20130821105304 |
      | 0xFF25 | Encryption_Whitelisting_Mode | 00                                                    |
      | 0x100E | User_Language                | EN                                                    |
       #####################################################################

    When I send a 04.x Set Payment Type message to the terminal with params:
      | p04_req_force_payment_type | 1   |
      | p04_req_payment_type       | B   |
      | p04_req_amount             | 000 |

    Then I should receive the 04.x Set Payment Type response from terminal with params:
      | p04_res_force_payment_type | 0   |
      | p04_res_payment_type       | B   |
      | p04_res_amount             | 000 |

    When I send a 13.x amount message to the terminal with:
      | p13_req_amount | <amount> |

    Then I should receive the 13.x amount response from terminal with params:
      | p13_res_status | 0 |

    And I wait until Element "btn_enter" visible

    When I click Element "btn_enter"

    Then I should receive the 33.03 Emv Transaction authorization_request response from terminal with params:
      | p33_03_req_status                  | 00         |
      | p33_03_req_emvh_current_packet_nbr | 0          |
      | p33_03_req_emvh_packet_type        | 0          |
      | p33_03_req_payload                 | @regexp:.+ |

    ####################### 33.03 payload verification #######################
    When I deserialize "p33_03_res_payload" value from the response object to the "authorization_request_data" container
    Then the reported "authorization_request_data" container should have the following params:
      | tag    | name                                       | value                                                 |
      | 0x4F   | application_identifier                     | <AID>03                                               |
      | 0x50   | Application_Label                          | @regexp:[\s]{4}62[\s]{4}IC[\s]{2}                     |
      | 0x57   | track_2_equivalent_data                    | <PAN>D<exp_date><code><add_data>F                     |
      | 0x82   | application_interchange_profile            | @regexp:[0-9A-Fa-f]{4}                                |
      | 0x84   | dedicated_file_df_name                     | <AID>03                                               |
      | 0x95   | terminal_verification_results              | 000800E000                                            |
      | 0x9A   | transaction_date                           | @regexp:\d{6}                                         |
      | 0x9B   | Transaction_Status_Information             | @regexp:[0-9A-Fa-f]{4}                                |
      | 0x9C   | transaction_type (Purchase)                | 00                                                    |
      | 0x5F20 | cardholder_name                            | UICC<test_card>                                       |
      | 0x5F24 | application_expiration_date                | <exp_date>31                                          |
      | 0x5F2A | Transaction_Currency_Code                  | 0840                                                  |
      | 0x9F02 | amount_authorised_kernel_v2                | 000000<amount>                                        |
      | 0x9F06 | Application_Identifier_(AID)_Terminal      | <AID>03                                               |
      | 0x9F07 | Application_Usage_Control                  | FF00                                                  |
      | 0x9F08 | Application_Version_Number_ICC             | @regexp:\d{4}                                         |
      | 0x9F09 | Application_Version_Number_Terminal        | @regexp:\d{4}                                         |
      | 0x9F0D | issuer_action_code_default                 | FC6004A800                                            |
      | 0x9F0E | issuer_action_code_denial                  | 0010000000                                            |
      | 0x9F0F | issuer_action_code_online                  | FC6804F800                                            |
      | 0x9F10 | Issuer_Application_Data_(IAD)              | @regexp:[0-9A-Fa-f]{16}                               |
      | 0x9F1A | terminal_country_code                      | 0840                                                  |
      | 0x9F1B | terminal_floor_limit                       | 00000000                                              |
      | 0x9F1F | Track1_Discretionary_Data                  | <PAN>^UICC<test_card>^<exp_date><code>^20130821105304 |
      | 0x9F21 | Transaction_Time                           | @regexp:\d{6}                                         |
      | 0x9F26 | application_cryptogram                     | @regexp:[0-9A-Fa-f]{16}                               |
      | 0x9F27 | cryptogram_information_data                | 80                                                    |
      | 0x9F33 | terminal_capabilities                      | E0F8C8                                                |
      | 0x9F34 | cardholder_verification_method_cvm_results | @regexp:[15]{1}E0300                                  |
      | 0x9F35 | terminal_type                              | 22                                                    |
      | 0x9F36 | Application_Transaction_Counter            | @regexp:[0-9A-Fa-f]{4}                                |
      | 0x9F39 | point_of_service_pos_entry_mode            | 05                                                    |
      | 0x9F40 | Additional_Terminal_Capabilities           | F800F0A3FF                                            |
      | 0xFF25 | Encryption_Whitelisting_Mode               | 00                                                    |
        #Ingenico property
      | 0x1001 | pin_entry_required_flag                    | 0                                                     |
      | 0x1002 | signature_required_flag                    | 1                                                     |
      | 0x1005 | transaction_type                           | 00                                                    |
      | 0x100E | User_Language                              | EN                                                    |
      | 0x100F | pin_entry_successful_flag                  | 0                                                     |
      | 0x9000 | card_payment_type                          | B                                                     |
      | 0x9001 | card_entry_mode                            | C                                                     |

      #####################################################################

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

      ####################### 33.05 payload verification #######################
    When  I deserialize "p33_05_res_payload" value from the response object to the "authorization_confirmation_data" container
    Then  the reported "authorization_confirmation_data" container should have the following params:
      | tag    | name                                       | value                                                 |
      | 0x4F   | application_identifier                     | <AID>03                                               |
      | 0x50   | Application_Label                          | @regexp:[\s]{4}62[\s]{4}IC[\s]{2}                     |
      | 0x57   | track_2_equivalent_data                    | <PAN>D<exp_date><code><add_data>F                     |
      | 0x82   | application_interchange_profile            | @regexp:[0-9A-Fa-f]{4}                                |
      | 0x84   | dedicated_file_df_name                     | <AID>03                                               |
      | 0x89   | Authorization_Code                         | 3030                                                  |
      | 0x8A   | authorisation_response_code                | 00                                                    |
      | 0x8E   | cardholder_verification_method_cvm_list    | 00000000000000005E0342031F00                          |
      | 0x95   | terminal_verification_results              | 000800E000                                            |
      | 0x9A   | transaction_date                           | @regexp:\d{6}                                         |
      | 0x9B   | Transaction_Status_Information             | @regexp:[0-9A-Fa-f]{4}                                |
      | 0x9C   | transaction_type (Purchase)                | 00                                                    |
      | 0x5F20 | cardholder_name                            | UICC<test_card>                                       |
      | 0x5F24 | application_expiration_date                | <exp_date>31                                          |
      | 0x5F28 | Issuer_Country_Code                        | 0156                                                  |
      | 0x5F2A | Transaction_Currency_Code                  | 0840                                                  |
      | 0x5F2D | Preferred_Languages                        | zh                                                    |
      | 0x9F02 | amount_authorised_kernel_v2                | 000000<amount>                                        |
      | 0x9F06 | Application_Identifier_(AID)_Terminal      | <AID>03                                               |
      | 0x9F07 | Application_Usage_Control                  | FF00                                                  |
      | 0x9F08 | Application_Version_Number_ICC             | @regexp:\d{4}                                         |
      | 0x9F09 | Application_Version_Number_Terminal        | @regexp:\d{4}                                         |
      | 0x9F0D | issuer_action_code_default                 | FC6004A800                                            |
      | 0x9F0E | issuer_action_code_denial                  | 0010000000                                            |
      | 0x9F0F | issuer_action_code_online                  | FC6804F800                                            |
      | 0x9F10 | Issuer_Application_Data_(IAD)              | @regexp:[0-9A-Fa-f]{16}                               |
      | 0x9F1A | terminal_country_code                      | 0840                                                  |
      | 0x9F1B | terminal_floor_limit                       | 00000000                                              |
      | 0x9F1F | Track1_Discretionary_Data                  | <PAN>^UICC<test_card>^<exp_date><code>^20130821105304 |
      | 0x9F21 | Transaction_Time                           | @regexp:\d{6}                                         |
      | 0x9F26 | application_cryptogram                     | @regexp:[0-9A-Fa-f]{16}                               |
      | 0x9F27 | cryptogram_information_data                | 40                                                    |
      | 0x9F33 | terminal_capabilities                      | E0F8C8                                                |
      | 0x9F34 | cardholder_verification_method_cvm_results | @regexp:[15]{1}E0300                                  |
      | 0x9F35 | terminal_type                              | 22                                                    |
      | 0x9F36 | Application_Transaction_Counter            | @regexp:[0-9A-Fa-f]{4}                                |
      | 0x9F39 | point_of_service_pos_entry_mode            | 05                                                    |
      | 0x9F40 | Additional_Terminal_Capabilities           | F800F0A3FF                                            |
      | 0xDF03 | Terminal_Action_Code_(TAC)_Default         | D84000A800                                            |
      | 0xDF04 | Terminal_Action_Code_Denial                | 0010000000                                            |
      | 0xDF05 | Terminal_Action_Code_Online                | D84004F800                                            |
      | 0xFF25 | Encryption_Whitelisting_Mode               | 00                                                    |
        #Ingenico property
      | 0x1001 | pin_entry_required_flag                    | 0                                                     |
      | 0x1002 | signature_required_flag                    | 1                                                     |
      | 0x1003 | Confirmation_Response_Code                 | A                                                     |
      | 0x1005 | transaction_type                           | 00                                                    |
      | 0x100E | User_Language                              | EN                                                    |
      | 0x100F | pin_entry_successful_flag                  | 0                                                     |
      | 0x9000 | card_payment_type                          | B                                                     |
      | 0x9001 | card_entry_mode                            | C                                                     |

        #####################################################################

    And I Wait until Element "title" contains "Approved\nPlease remove card"
    When  I remove card
    And I wait 4 seconds

    Then I should receive the 09.x Set Allowed Payments response from terminal with params:
      | p09_res_card_type        | 02 |
      | p09_res_msg_version      | 02 |
      | p09_res_transaction_type | 01 |
      | p09_res_card_status      | R  |

    And I Wait until Element "title" contains "Approved"

    ####################### Terminal Offline #######################
    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    ####################### Manual Validations #######################
    #No manual validation

    ####################### Finalize collis #######################
    When I finalizing Collis Test Case as "approved"
    Then I expect Collis Test Case to be "passed"

    Examples:
      | test_case    | AID            | app_label        | PAN              | test_card | exp_date | code | add_data      | amount |
      | TAIS_POS_005 | A0000003330101 | UICC Credit Card | 6210948000000052 | FT05      | 3010     | 220  | 0000000000000 | 500000 |
