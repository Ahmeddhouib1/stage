@secbin @sde @msr @me @dme @emv @cless @00x @62x @61x @p2p @dx8000 @ex8000 @dx4000 @rx5000 @rx7000

Feature: Enable On-Guard SDE DUKPT AES Encryption Configuration

  @aes128
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

  @aes192
  Scenario: Enable OGSDE DUKPT with AES192 Encryption Configuration

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    When I have successfully sent "Files/p2p_encryptions/ArcOnGuard-SDE-AES192.apk" file using these params:
      | p62_req_file_name       | ArcOnGuard-SDE-AES192.apk |
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

  @aes256
  Scenario: Enable OGSDE DUKPT with AES256 Encryption Configuration

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    When I have successfully sent "Files/p2p_encryptions/ArcOnGuard-SDE-AES256.apk" file using these params:
      | p62_req_file_name       | ArcOnGuard-SDE-AES256.apk |
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