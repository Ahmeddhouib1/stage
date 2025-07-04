@87x @msr @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: MSR transaction For Non Standard Card Using 87.x Card Read Request
"""
  This feature file Validates MSR transaction For Non Standard Card using 87.x Card Read Request
  TestLink test case link: https://testlink.evf.us/linkto.php?tprojectPrefix=ARC&item=testcase&id=ARC-1199
  """

  Scenario Outline: Check MSR flow while using 87.x with Non-Standard two tracks(track1 ,track2)



    Given I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    When I send a 87.x On-Guard and KME Card Read message to the terminal with:
      | p87_req_prompt_index    | 3          |
      | p87_req_form_name       | read_cards |
      | p87_req_enabled_devices | M          |

    Then I Wait until Element "title" contains "Please slide card"

    And I wait until Element "btn_cancel" visible

    And I wait for 1 second

    When I swipe card using this params:
      | track1_data | <track1_data> |
      | track2_data | <track2_data> |
      | track3_data |               |

    Then I should receive the 87.x On-Guard and KME Card Read Data response from terminal with params:
      | p87_res_exit_type   | 0                                                |
      | p87_res_card_source | M                                                |
      | p87_res_card_data   | @regexp:^<track1_res>\u001c<track2_res>\u001c.*$ |


    Examples:
      | track1_data                                                      | track2_data                            | track1_res                                                       | track2_res                             |
      | B4147200000002105 KOIRALA/SASMIT 2603201000000000000000000000000 | 4147200000002105=260320100000000       | B4147200000002105 KOIRALA/SASMIT 2603201000000000000000000000000 | 4147200000002105=260320100000000       |
      | 1234567890123456                                                 | 1234567890123456                       | 1234567890123456                                                 | 1234567890123456                       |
      | 7080010000123456 ENCODING TEST 2012 00011VEH IDFILLERXX0XX40000  | 0000198800001234560011=2012=0000002008 | 7080010000123456 ENCODING TEST 2012 00011VEH IDFILLERXX0XX40000  | 0000198800001234560011=2012=0000002008 |

  Scenario Outline: Check MSR flow while using 87.x with  Non-Standard track1 only

    Given I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    When I send a 87.x On-Guard and KME Card Read message to the terminal with:
      | p87_req_prompt_index    | 3          |
      | p87_req_form_name       | read_cards |
      | p87_req_enabled_devices | M          |

    Then I Wait until Element "title" contains "Please slide card"

    And I wait until Element "btn_cancel" visible

    And I wait for 1 second

    When I swipe card using this params:
      | track1_data | <track1_data> |
      | track2_data |               |
      | track3_data |               |

    Then I should receive the 87.x On-Guard and KME Card Read Data response from terminal with params:
      | p87_res_exit_type   | 0                        |
      | p87_res_card_source | M                        |
      | p87_res_card_data   | @regexp:^<track1_res>.*$ |

    Examples:
      | track1_data                         | track2_data | track1_res                          | track1_res |
      | 1234567890123456                    |             | 1234567890123456                    |            |
      | 1006357681?3       1234567890123456 |             | 1006357681?3       1234567890123456 |            |
      | 5413339000000119                    |             | 5413339000000119                    |            |

  Scenario Outline: Check MSR flow while using 87.x with Non-Standard track2 only

    Given I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    When I send a 87.x On-Guard and KME Card Read message to the terminal with:
      | p87_req_prompt_index    | 3          |
      | p87_req_form_name       | read_cards |
      | p87_req_enabled_devices | M          |

    Then I Wait until Element "title" contains "Please slide card"

    And I wait until Element "btn_cancel" visible

    And I wait for 1 second

    When I swipe card using this params:
      | track1_data |               |
      | track2_data | <track2_data> |
      | track3_data |               |

    Then I should receive the 87.x On-Guard and KME Card Read Data response from terminal with params:
      | p87_res_exit_type   | 0                        |
      | p87_res_card_source | M                        |
      | p87_res_card_data   | @regexp:^<track1_res>.*$ |

    Examples:
      | track1_data | track2_data                            | track1_res | track2_res                             |
      |             | B4445222AE299990007                    |            | B4445222AE299990007                    |
      |             | 1234567890123456                       |            | 1234567890123456                       |
      |             | 0000198800001234560011=2012=0000002008 |            | 0000198800001234560011=2012=0000002008 |
