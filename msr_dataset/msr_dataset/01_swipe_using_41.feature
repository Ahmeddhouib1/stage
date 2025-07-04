@41x @msr @00x @29x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature:Swipe Transaction with 41.x Card Read with parse fields
"""
  This feature file Validates MSR transaction using 41.x Card Read Request
  TestLink test case link:https://testlink.evf.us/linkto.php?tprojectPrefix=ARC&item=testcase&id=ARC-1160.
  """


  Scenario Outline:  Check MSR flow using 41.x (track1 ,track2)

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    When I send a 41.x Card Read Message message to the terminal with params:
      | p41_req_parse_flag       | 1 |
      | p41_req_msr_flag         | 1 |
      | p41_req_contactless_flag | 0 |
      | p41_req_smc_flag         | 0 |

    Then I wait for 23 seconds

    When I swipe card using this params:
      | track1_data | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2_data | <pan>=<exp_date><code><disc_data_t2>         |
      | track3_data |                                              |

    And I wait for 2 seconds

    Then I should receive the 41.x Card Read Message response from terminal with params:
      | p41_res_source          | M                                            |
      | p41_res_encryption      | 00                                           |
      | p41_res_track_1_status  | 0                                            |
      | p41_res_track_2_status  | 0                                            |
      | p41_res_track_3_status  | 1                                            |
      | p41_res_track_1         | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | p41_res_track_2         | <pan>=<exp_date><code><disc_data_t2>         |
      | p41_res_track_3         |                                              |
      | p41_res_pan             | <pan>                                        |
      | p41_res_masked_pan      | <pan>                                        |
      | p41_res_expiration_date | <exp_date>                                   |
      | p41_res_account_name    | <name>                                       |
      | p41_res_error_code      | 0                                            |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 398 |

	Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000398 |
      | p29_res_variable_data | <pan>  |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 399 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000399 |
      | p29_res_variable_data |<name>  |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 400 |

	Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2          |
      | p29_res_variable_id   | 000400     |
      | p29_res_variable_data | <exp_date> |

	When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    Examples:
      | card_type  | pan                 | name                      | exp_date | code | disc_data_t1         | disc_data_t2  |
      | MasterCard | 6799998900000201011 | EKRLOFKPUUTQURT/ALMPWTZUL | 2007     | 707  | 122560965000469      | 965000469     |
      | VISA       | 34798979016630      | XNHKBPMOENSGWLH/VVKLBTTVC | 2011     | 885  | 131026887693372      | 887693372     |
      | AMEX 1     | 3715841319          | YYBROXFQJRXJW/EVXOV       | 2001     | 442  | 57431313685          | 13685         |
      | DISCOVER   | 6510000000000091    | CARD/IMAGE 09             | 1712     | 702  | 1000041300000        | 1000041300000 |
      | Diners     | 36039667170472      | PETTITT/JO                | 0012     | 521  | 16010000000000000946 | 1000041300000 |

  Scenario Outline:  Check MSR flow using 41.x (track1 only)

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    When I send a 41.x Card Read Message message to the terminal with params:
      | p41_req_parse_flag       | 1 |
      | p41_req_msr_flag         | 1 |
      | p41_req_contactless_flag | 0 |
      | p41_req_smc_flag         | 0 |

    Then I wait for 3 seconds

    When I swipe card using this params:
      | track1_data | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2_data |                                              |
      | track3_data |                                              |

    And I wait for 2 seconds

    Then I should receive the 41.x Card Read Message response from terminal with params:
      | p41_res_source          | M                                            |
      | p41_res_encryption      | 00                                           |
      | p41_res_track_1_status  | 0                                            |
      | p41_res_track_2_status  | 1                                            |
      | p41_res_track_3_status  | 1                                            |
      | p41_res_track_1         | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | p41_res_track_2         |                                              |
      | p41_res_track_3         |                                              |
      | p41_res_pan             | <pan>                                        |
      | p41_res_masked_pan      | <pan>                                        |
      | p41_res_expiration_date | <exp_date>                                   |
      | p41_res_account_name    | <name>                                       |
      | p41_res_error_code      | 0                                            |

	When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 398 |

	Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000398 |
      | p29_res_variable_data | <pan>  |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 399 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000399 |
      | p29_res_variable_data |<name>  |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 400 |

	Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2          |
      | p29_res_variable_id   | 000400     |
      | p29_res_variable_data | <exp_date> |

	When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    Examples:
      | card_type  | pan                 | name                      | exp_date | code | disc_data_t1         |
      | MasterCard | 6799998900000201011 | EKRLOFKPUUTQURT/ALMPWTZUL | 2007     | 707  | 122560965000469      |
      | VISA       | 34798979016630      | XNHKBPMOENSGWLH/VVKLBTTVC | 2011     | 885  | 131026887693372      |
      | AMEX 1     | 3715841319          | YYBROXFQJRXJW/EVXOV       | 2001     | 442  | 57431313685          |
      | DISCOVER   | 6510000000000091    | CARD/IMAGE 09             | 1712     | 702  | 1000041300000        |
      | Diners     | 36039667170472      | PETTITT/JO                | 0012     | 521  | 16010000000000000946 |


  Scenario Outline: Check MSR flow while using 41.x (track2 only)

    Given I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    When I send a 41.x Card Read Message message to the terminal with params:
      | p41_req_parse_flag       | 1 |
      | p41_req_msr_flag         | 1 |
      | p41_req_contactless_flag | 0 |
      | p41_req_smc_flag         | 0 |

    Then I wait for 3 seconds

    When I swipe card using this params:
      | track1_data |                                      |
      | track2_data | <pan>=<exp_date><code><disc_data_t2> |
      | track3_data |                                      |

    And I wait for 2 seconds

    Then I should receive the 41.x Card Read Message response from terminal with params:
      | p41_res_source          | M                                    |
      | p41_res_encryption      | 00                                   |
      | p41_res_track_1_status  | 1                                    |
      | p41_res_track_2_status  | 0                                    |
      | p41_res_track_3_status  | 1                                    |
      | p41_res_track_1         |                                      |
      | p41_res_track_2         | <pan>=<exp_date><code><disc_data_t2> |
      | p41_res_track_3         |                                      |
      | p41_res_pan             | <pan>                                |
      | p41_res_masked_pan      | <pan>                                |
      | p41_res_expiration_date | <exp_date>                           |
      | p41_res_account_name    |                                      |
      | p41_res_error_code      | 0                                    |

	When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 398 |

	Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000398 |
      | p29_res_variable_data | <pan>  |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 399 |

    Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2      |
      | p29_res_variable_id   | 000399 |
      | p29_res_variable_data |        |

    When I send a 29.x Get Variable message to the terminal with:
      | p29_req_variable_id | 400 |

	Then I should receive the 29.x Get Variable response from terminal with params:
      | p29_res_status        | 2          |
      | p29_res_variable_id   | 000400     |
      | p29_res_variable_data | <exp_date> |

    When I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    Examples:
      | card_type  | pan              | name                      | exp_date | code | disc_data_t2  |
      | MasterCard | 45358179327829   | EKRLOFKPUUTQURT/ALMPWTZUL | 2007     | 707  | 965000469     |
      | VISA       | 34798979016630   | XNHKBPMOENSGWLH/VVKLBTTVC | 2011     | 885  | 823693372     |
      | AMEX 1     | 37158413190797   | YYBROXFQJRXJW/EVXOV       | 2001     | 442  | 13685         |
      | DISCOVER   | 6510000000000091 | CARD/IMAGE 09             | 1712     | 702  | 1000041300000 |
      | Diners     | 36039667170472   | PETTITT/JO                | 0012     | 521  | 1000041300000 |




