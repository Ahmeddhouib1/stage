@p2p @secbin @voltage @tep7 @msr @me @dme @emv @cless @00x @62x @61x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: Enable Voltage TEP7 Encryption Configuration

  Scenario: Enable Voltage TEP7 Encryption Configuration

    Given I send a 00.x Offline message to the terminal with:
    | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
    | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    When I have successfully sent "Files/p2p_encryptions/voltage_32_default-signed.apk" file using these params:

      | p62_req_file_name       | voltage_32_default-signed.apk |
      | p62_req_encoding_format | B                             |
      | p62_req_fast_download   | 1                             |
      | p62_req_unpack_flag     | 0                             |


    And I should receive the 62.x File Write response from terminal with params:
    | p62_res_status      | 0            |
    | p62_res_file_length | @regexp:.\d* |

    When I send a 61.x Configuration Read message to the terminal with:
    | p61_req_group_num | 91 |
    | p61_req_index_num | 1  |

    Then I should receive the 61.x Configuration Read response from terminal with params:
    | p61_res_status                | 2  |
    | p61_res_group_num             | 91 |
    | p61_res_index_num             | 1  |
    | p61_res_data_config_parameter | 32 |

    When I send a 90.x MSR Encryption message to the terminal with:
      | p90_req_function | 0 |

    Then I should receive the 90.x MSR Encryption response from terminal with params:
      | p90_res_function | 0          |
      | p90_res_status   | 0          |
      | p90_res_etb      | @regexp:.* |