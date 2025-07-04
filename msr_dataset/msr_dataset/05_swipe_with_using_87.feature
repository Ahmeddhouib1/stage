@87x @msr @00x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: MSR transaction using 87.x Card Read Request
"""
  This feature file Validates MSR transaction using 87.x Card Read Request
  TestLink test case link: https://testlink.evf.us/linkto.php?tprojectPrefix=ARC&item=testcase&id=ARC-1155
  """

  Scenario Outline: Check MSR flow while using 87.x with two tracks(track1 ,track2)

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
      | track1_data | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2_data | <pan>=<exp_date><code><disc_data_t2>         |
      | track3_data |                                              |

    Then I should receive the 87.x On-Guard and KME Card Read Data response from terminal with params:
      | p87_res_exit_type   | 0                                                                                                    |
      | p87_res_card_source | M                                                                                                    |
      | p87_res_card_data   | @regexp:^B<pan>\^<name>\^<exp_date><code><disc_data_t1>\x1C<pan>=<exp_date><code><disc_data_t2>\x1C$ |

    Examples:
      | card_type   | pan                 | name                      | exp_date | code  | disc_data_t1    | disc_data_t2 |
      | MasterCard  | 6799998900000201011 | EKRLOFKPUUTQURT/ALMPWTZUL | 2007     | 707   | 122560965000469 | 965000469    |
      | VISA        | 34798979016630      | XNHKBPMOENSGWLH/VVKLBTTVC | 2011     | 885   | 131026887693372 | 887693372    |
      | AMEX 1      | 3715841319          | YYBROXFQJRXJW/EVXOV       | 2001     | 442   | 57431313685     | 13685        |
      | NonStandard | 999000              | NENNAEVXO-VVVV            | 001      | 55442 | 333657431313685 | 000013685    |


  Scenario Outline: Check MSR flow while using  87.x with  track1 only

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
      | track1_data | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2_data |                                              |
      | track3_data |                                              |

    Then I should receive the 87.x On-Guard and KME Card Read Data response from terminal with params:
      | p87_res_exit_type   | 0                                                                |
      | p87_res_card_source | M                                                                |
      | p87_res_card_data   | @regexp:^B<pan>\^<name>\^<exp_date><code><disc_data_t1>\x1C\x1C$ |


    Examples:
      | card_type   | pan                 | name                      | exp_date | code  | disc_data_t1    | disc_data_t2 |
      | MasterCard  | 6799998900000201011 | EKRLOFKPUUTQURT/ALMPWTZUL | 2007     | 707   | 122560965000469 | 965000469    |
      | VISA        | 34798979016630      | XNHKBPMOENSGWLH/VVKLBTTVC | 2011     | 885   | 131026887693372 | 887693372    |
      | AMEX 1      | 3715841319          | YYBROXFQJRXJW/EVXOV       | 2001     | 442   | 57431313685     | 13685        |
      | NonStandard | 999000              | NENNAEVXO-VVVV            | 001      | 55442 | 333657431313685 | 000013685    |

  Scenario Outline: Check MSR flow while using 87.x with track2 only

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
      | track1_data |                                      |
      | track2_data | <pan>=<exp_date><code><disc_data_t2> |
      | track3_data |                                      |

    Then I should receive the 87.x On-Guard and KME Card Read Data response from terminal with params:
      | p87_res_exit_type   | 0                                                      |
      | p87_res_card_source | M                                                      |
      | p87_res_card_data   | @regexp:^\x1C<pan>=<exp_date><code><disc_data_t2>\x1C$ |

    Examples:
      | card_type   | pan            | name                      | exp_date | code  | disc_data_t1    | disc_data_t2 |
      | MasterCard  | 45358179327829 | EKRLOFKPUUTQURT/ALMPWTZUL | 2007     | 707   | 122560965000469 | 965000469    |
      | VISA        | 34798979016630 | XNHKBPMOENSGWLH/VVKLBTTVC | 2011     | 885   | 131026823693372 | 823693372    |
      | AMEX 1      | 37158413190797 | YYBROXFQJRXJW/EVXOV       | 2001     | 442   | 57431313685     | 13685        |
      | NonStandard | 999000         | NENNAEVXO-VVVV            | 001      | 55442 | 333657431313685 | 000013685    |
