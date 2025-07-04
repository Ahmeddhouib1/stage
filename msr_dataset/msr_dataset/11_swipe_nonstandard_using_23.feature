@23x @msr @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: Swipe non standard cards
  """
  This feature file Validates MSR transaction For Non Standard Card using 23.x Card Read Request
  TestLink test case link: https://testlink.evf.us/linkto.php?tprojectPrefix=ARC&item=testcase&id=ARC-1207
  """

  Scenario Outline: Check MSR flow while using Non-Standard cards with two tracks(track1 ,track2)

    Given I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    And I wait until Element "imageOffline" visible

    When I send a 23.x Read Card message to the terminal with:
      | p23_req_prompt_index   | 3          |
      | p23_req_form_name      | read_cards |
      | p23_req_enable_devices | M          |

    Then I Wait until Element "title" contains "Please slide card"

    And I wait until Element "btn_cancel" visible

    And I wait for 1 second

    When I swipe card using this params:
      | track1_data | <track1_data> |
      | track2_data | <track2_data> |
      | track3_data |               |

    Then I should receive the 23.x Card Read response from terminal with params:
      | p23_res_exit_type   | 0            |
      | p23_res_card_source | M            |
      | p23_res_track1      | <track1_res> |
      | p23_res_track2      | <track2_res> |
      | p23_res_track3      |              |

    When I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    Examples:
      | type                                                             | track1_data                                                     | track2_data                            | track1_res                                                      | track2_res                             |
      | NonStandard card -- ISO parser                                   | B4147200000002105 TEST/CARD 2603201000000000000000000000000     | 4147200000002105=260320100000000       | B4147200000002105 TEST/CARD 2603201000000000000000000000000     | 4147200000002105=260320100000000       |
      | NonStandard card -- Track 1 and Track 2 pan-only                 | 1234567890123456                                                | 1234567890123456                       | 1234567890123456                                                | 1234567890123456                       |
      | NonStandard card -- Non Payment card                             | 7080010000123456 ENCODING TEST 2012 00011VEH IDFILLERXX0XX40000 | 0000198800001234560011=2012=0000002008 | 7080010000123456 ENCODING TEST 2012 00011VEH IDFILLERXX0XX40000 | 0000198800001234560011=2012=0000002008 |
      | NonStandard card -- FDMS TEST CARD/VISA modified without exp-dat | B4000620001234803^FDMS TEST CARD/VISA^                          | 4000620001234803                       | B4000620001234803^FDMS TEST CARD/VISA^                          | 4000620001234803                       |


  Scenario Outline: Check MSR flow while using Non-Standard cards with track1 only

    Given I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    When I send a 23.x Read Card message to the terminal with:
      | p23_req_prompt_index   | 3          |
      | p23_req_form_name      | read_cards |
      | p23_req_enable_devices | M          |

    Then I Wait until Element "title" contains "Please slide card"

    And I wait until Element "btn_cancel" visible

    And I wait for 1 second

    When I swipe card using this params:
      | track1_data | <track1_data> |
      | track2_data |               |
      | track3_data |               |

    Then I should receive the 23.x Card Read response from terminal with params:
      | p23_res_exit_type   | 0            |
      | p23_res_card_source | M            |
      | p23_res_track1      | <track1_res> |
      | p23_res_track2      |              |
      | p23_res_track3      |              |

    When I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    Examples:
      | type                                 | track1_data                         | track1_res                         |
      | NonStandard Card -- Track 1 pan-only | 1234567890123456                    | 1234567890123456                   |
      | NonStandard Card -- Non Payment card | 1006357681?3       1234567890123456 | 10063576813       1234567890123456 |
      | NonStandard Card -- Track 1 pan-only | 5413339000000119                    | 5413339000000119                   |


  Scenario Outline: Check MSR flow while using Non-Standard cards with track2 only

    Given I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    When I send a 23.x Read Card message to the terminal with:
      | p23_req_prompt_index   | 3          |
      | p23_req_form_name      | read_cards |
      | p23_req_enable_devices | M          |

    Then I Wait until Element "title" contains "Please slide card"

    And I wait until Element "btn_cancel" visible

    And I wait for 1 second

    When I swipe card using this params:
      | track1_data |               |
      | track2_data | <track2_data> |
      | track3_data |               |

    Then I should receive the 23.x Card Read response from terminal with params:
      | p23_res_exit_type   | 0            |
      | p23_res_card_source | M            |
      | p23_res_track1      |              |
      | p23_res_track2      | <track2_res> |
      | p23_res_track3      |              |

    When I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    Examples:
      | type                                 | track2_data                            | track2_res                             |
      | NonStandard Card -- Track 2 pan-only | B4445222AE299990007                    | B4445222AE299990007                    |
      | NonStandard Card -- Track 2 pan-only | 1234567890123456                       | 1234567890123456                       |
      | NonStandard Card -- Non Payment card | 0000198800001234560011=2012=0000002008 | 0000198800001234560011=2012=0000002008 |
      | NonStandard Card -- Gift ECR         | 1234567897=251210100000001             | 1234567897=251210100000001             |

