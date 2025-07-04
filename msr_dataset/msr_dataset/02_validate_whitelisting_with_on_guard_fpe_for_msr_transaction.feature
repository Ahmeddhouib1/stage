@msr @fpe @secbin @00x @61x @23x @62x @13x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: Validate Whitelisting With On Guard FPE Encryption for MSR Transaction
"""
  This feature file validates whitelisting for MSR Transaction
  TestLink test case link : https://testlink.evf.us/linkto.php?tprojectPrefix=ARC&item=testcase&id=ARC-977.
  """

  Scenario: Enable Whitelisting Configuration

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    When I have successfully sent "Files/whitelisting/apstitan_on.apk" file using these params:
      | p62_req_file_name       | apstitan_on.apk |
      | p62_req_encoding_format | B               |
      | p62_req_fast_download   | 1               |
      | p62_req_unpack_flag     | 0               |

    Then I should receive the 62.x Write File response from terminal with params:
      | p62_res_status      | 0           |
      | p62_res_file_length | @regexp:\d* |


  Scenario Outline: Whitelisting with on guard FPE for MSR Transaction

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


    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    When I send a 13.x amount message to the terminal with:
      | p13_req_amount | <amount> |

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
      | track3_data |                                              |


    Then I should receive the 23.x Read Card response from terminal with params:
      | p23_res_exit_type   | 0                                            |
      | p23_res_card_source | M                                            |
      | p23_res_track1      | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | p23_res_track2      | <pan>=<exp_date><code><disc_data_t2>         |
      | p23_res_track3      | <additional_data><additional_data>           |


    Examples:
      | card_type  | amount | pan              | name               | exp_date | code | disc_data_t1                 | disc_data_t2   | additional_data |
      | Mastercard | 120    | 5413339000000119 | TEST/CARD          | 2412     | 221  | 000000140000000              | 0000014000001  |                 |
      | Amex       | 1234   | 374245001731008  | XP CARD 07/VER 2.0 | 2103     | 201  | 150412345                    | 15041234500000 |                 |
      | VISA       | 56789  | 4264510228395621 | JOHN/SMITH         | 1709     | 206  | 0000000000000000000704001000 | 0000070400100  |                 |
      | DISCOVER   | 987654 | 6510000000000091 | CARD/IMAGE 09      | 1712     | 702  | 1000041300000                | 1000041300000  |                 |
      | Diners     | 87654  | 36039667170472   | PETTITT/JO         | 0012     | 521  | 16010000000000000946         | 1000041300000  |                 |


  Scenario: Teardown - Reset to Default State

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    When I have successfully sent "Files/whitelisting/apstitan_off.apk" file using these params:
      | p62_req_file_name       | apstitan_off.apk |
      | p62_req_encoding_format | B               |
      | p62_req_fast_download   | 1               |
      | p62_req_unpack_flag     | 0               |

    Then I should receive the 62.x Write File response from terminal with params:
      | p62_res_status      | 0           |
      | p62_res_file_length | @regexp:\d* |
