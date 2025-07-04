@41x @msr @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: Swipe non standard cards
"""
  This feature file Validates MSR transaction For Non Standard Card using 41.x Card Read Request
  TestLink test case link: https://testlink.evf.us/linkto.php?tprojectPrefix=ARC&item=testcase&id=ARC-1208
  """

  Scenario Outline: Check MSR flow while using Non-Standard cards with two tracks(track1 ,track2)

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

    And I wait for 2 seconds

    And I swipe card using this params:
      | track1_data | <track1_data> |
      | track2_data | <track2_data> |
      | track3_data |               |

    And I wait 3 seconds

    Then I should receive the 41.x Card Read Message response from terminal with params:
      | p41_res_source          | M             |
      | p41_res_encryption      | 00            |
      | p41_res_track_1_status  | 0             |
      | p41_res_track_2_status  | 0             |
      | p41_res_track_3_status  | 1             |
      | p41_res_track_1         | <track1_data> |
      | p41_res_track_2         | <track2_data> |
      | p41_res_track_3         |               |
      | p41_res_pan             | <pan>         |
      | p41_res_masked_pan      | <masked_pan>  |
      | p41_res_expiration_date | <exp_date>    |
      | p41_res_account_name    | <name>        |
      | p41_res_error_code      | 0             |

    When I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    Examples:
      | type                                                             | track1_data                                                     | track2_data                            | track1_res                                                      | track2_res                             | pan                    | masked_pan             | exp_date | name                |
      | NonStandard card -- ISO parser                                   | B4147200000002105 TEST/CARD 2603201000000000000000000000000     | 4147200000002105=260320100000000       | B4147200000002105 TEST/CARD 2603201000000000000000000000000     | 4147200000002105=260320100000000       | 4147200000002105       | 4147200000002105       | 2603     |                     |
      | NonStandard card -- Track 1 and Track 2 pan-only                 | 1234567890123456                                                | 1234567890123456                       | 1234567890123456                                                | 1234567890123456                       | 1234567890123456       | 1234567890123456       |          |                     |
      | NonStandard card -- Non Payment card                             | 7080010000123456 ENCODING TEST 2012 00011VEH IDFILLERXX0XX40000 | 0000198800001234560011=2012=0000002008 | 7080010000123456 ENCODING TEST 2012 00011VEH IDFILLERXX0XX40000 | 0000198800001234560011=2012=0000002008 | 0000198800001234560011 | 0000198800001234560011 | 2012     |                     |
      | NonStandard card -- FDMS TEST CARD/VISA modified without exp-dat | B4000620001234803^FDMS TEST CARD/VISA^                          | 4000620001234803                       | B4000620001234803^FDMS TEST CARD/VISA^                          | 4000620001234803                       | 4000620001234803       | 4000620001234803       |          | FDMS TEST CARD/VISA |

  Scenario Outline: Check MSR flow while using Non-Standard cards with track1 only

    Given I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    When I send a 41.x Card Read Message message to the terminal with:
      | p41_req_parse_flag       | 1 |
      | p41_req_msr_flag         | 1 |
      | p41_req_contactless_flag | 0 |
      | p41_req_smc_flag         | 0 |

    And I wait for 2 seconds

    And I swipe card using this params:
      | track1_data | <track1_data> |
      | track2_data |               |
      | track3_data |               |

    And I wait 3 seconds

    Then I should receive the 41.x Card Read Message response from terminal with params:
      | p41_res_source          | M             |
      | p41_res_encryption      | 00            |
      | p41_res_track_1_status  | 0             |
      | p41_res_track_2_status  | 1             |
      | p41_res_track_3_status  | 1             |
      | p41_res_track_1         | <track1_data> |
      | p41_res_track_2         |               |
      | p41_res_track_3         |               |
      | p41_res_pan             | <pan>         |
      | p41_res_masked_pan      | <masked_pan>  |
      | p41_res_expiration_date |               |
      | p41_res_account_name    |               |
      | p41_res_error_code      | 0             |

    When I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible


    Examples:
      | type                                 | track1_data                        | track1_res                         | pan                         | masked_pan                  | exp_date | name |
      | NonStandard Card -- Track 1 pan-only | 1234567890123456                   | 1234567890123456                   | 1234567890123456            | 1234567890123456            | 2603     |      |
      | NonStandard Card -- Non Payment card | 10063576813       1234567890123456 | 10063576813       1234567890123456 | 100635768131234567890123456 | 100635768131234567890123456 |          |      |
      | NonStandard Card -- Track 1 pan-only | 5413339000000119                   | 5413339000000119                   | 5413339000000119            | 5413339000000119            | 2012     |      |


  Scenario Outline: Check MSR flow while using Non-Standard cards with track2 only

    Given I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    When I send a 41.x Card Read Message message to the terminal with params:
      | p41_req_parse_flag       | 1 |
      | p41_req_msr_flag         | 1 |
      | p41_req_contactless_flag | 0 |
      | p41_req_smc_flag         | 0 |

    And I wait for 2 seconds

    And I swipe card using this params:
      | track1_data |               |
      | track2_data | <track2_data> |
      | track3_data |               |

    Then I should receive the 41.x Card Read Message response from terminal with params:
      | p41_res_source          | M             |
      | p41_res_encryption      | 00            |
      | p41_res_track_1_status  | 1             |
      | p41_res_track_2_status  | 0             |
      | p41_res_track_3_status  | 1             |
      | p41_res_track_1         |               |
      | p41_res_track_2         | <track2_data> |
      | p41_res_track_3         |               |
      | p41_res_pan             | <pan>         |
      | p41_res_masked_pan      | <masked_pan>  |
      | p41_res_expiration_date | <exp_date>    |
      | p41_res_account_name    | <name>        |
      | p41_res_error_code      | 0             |

    When I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    Examples:
      | type                                 | track2_data                            | track2_res                             | pan                    | masked_pan             | exp_date | name |
      | NonStandard Card -- Track 2 pan-only | 1234567890123456                       | 1234567890123456                       | 1234567890123456       | 1234567890123456       |          |      |
      | NonStandard Card -- Track 2 pan-only | B4445222AE299990007                    | B4445222AE299990007                    |                        |                        |          |      |
      | NonStandard Card -- Non Payment card | 0000198800001234560011=2012=0000002008 | 0000198800001234560011=2012=0000002008 | 0000198800001234560011 | 0000198800001234560011 | 2012     |      |
      | NonStandard Card -- Gift ECR         | 1234567897=251210100000001             | 1234567897=251210100000001             | 1234567897             | 1234567897             | 2512     |      |
