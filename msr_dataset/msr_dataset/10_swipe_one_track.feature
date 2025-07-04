@23x @msr @00x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: 23.x Card Read Request Swipe one track

  Scenario Outline: Send 23.x Card Read Request swipe first track

    Given I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    When I send a 23.x Card Read message to the terminal with:
      | p23_req_enable_devices | M  |
      | p23_req_prompt_index   | 03 |

    And I Wait until Element "title" contains "Please slide card"

    And I wait until Element "btn_cancel" visible

    And I wait for 1 second

    When Axium swipe magnetic card:
      | track1 | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | track2 |                                              |
      | track3 |                                              |

    Then I should receive the 23.x Read Card response from terminal with params:
      | p23_res_exit_type   | 0                                            |
      | p23_res_card_source | M                                            |
      | p23_res_track1      | B<pan>^<name>^<exp_date><code><disc_data_t1> |
      | p23_res_track2      | @regexp:.*                                   |
      | p23_res_track3      | @regexp:.*                                   |

    Examples:
      | card_type     | pan                 | name                       | exp_date | code | disc_data_t1    | disc_data_t2 |
      | Discover 1    | 62217984210356      | LYUATZMDAU/ABKBXTDWTDZJPHY | 2008     | 305  | 937343886685    | 886685       |
      | Discover 2    | 648682809137410     | YHQJOKMYVWVNLRP/RHWSDMBOER | 2009     | 418  | 7254640409      | 0409         |
      | Discover 3    | 656147069906747     | ICVLSVZXZM/RLBOT           | 2011     | 596  | 11020664082766  | 64082766     |
      | Discover 4    | 521781446878188     | MCOZPS/FTYJMUOLLBYS        | 2006     | 651  | 95135762802916  | 62802916     |
      | MasterCard    | 45358179327829      | EKRLOFKPUUTQURT/ALMPWTZUL  | 2007     | 707  | 122560965000469 | 965000469    |
      | VISA          | 34798979016630      | XNHKBPMOENSGWLH/VVKLBTTVC  | 2011     | 885  | 131026823693372 | 823693372    |
      | AMEX 1        | 37158413190797      | YYBROXFQJRXJW/EVXOV        | 2001     | 442  | 57431313685     | 13685        |
      | AMEX 2        | 700199380329310926  | TPZRJLK/NKTUBHJNNWZI       | 2005     | 807  | 3121187689      | 7689         |
      | loyalty cards | 62211933327452      | PZNLQXRGCDILK/TDDZHWEUCTJ  | 2009     | 680  | 9497511743      | 1743         |
      | other cards   | 2830654628589795710 | XSYWIV/LHJPNU              | 2008     | 770  | 29814983505     | 83505        |

  Scenario Outline: Send 23.x Card Read Request swipe second track

    Given I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    When I send a 23.x Card Read message to the terminal with:
      | p23_req_enable_devices | M  |
      | p23_req_prompt_index   | 03 |

    And I Wait until Element "title" contains "Please slide card"

    Then I wait until Element "btn_cancel" visible

    And I wait for 1 second

    When Axium swipe magnetic card:
      | track1 |                                      |
      | track2 | <pan>=<exp_date><code><disc_data_t2> |
      | track3 |                                      |

    Then I should receive the 23.x Read Card response from terminal with params:
      | p23_res_exit_type   | 0                                    |
      | p23_res_card_source | M                                    |
      | p23_res_track1      | @regexp:.*                           |
      | p23_res_track2      | <pan>=<exp_date><code><disc_data_t2> |
      | p23_res_track3      | @regexp:.*                           |

    When I send a 00.x Offline message to the terminal with:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    Examples:
      | card_type     | pan                 | name                       | exp_date | code | disc_data_t1    | disc_data_t2 |
      | Discover 1    | 62217984210356      | LYUATZMDAU/ABKBXTDWTDZJPHY | 2008     | 305  | 937343886685    | 886685       |
      | Discover 2    | 648682809137410     | YHQJOKMYVWVNLRP/RHWSDMBOER | 2009     | 418  | 7254640409      | 0409         |
      | Discover 3    | 656147069906747     | ICVLSVZXZM/RLBOT           | 2011     | 596  | 11020664082766  | 64082766     |
      | Discover 4    | 521781446878188     | MCOZPS/FTYJMUOLLBYS        | 2006     | 651  | 95135762802916  | 62802916     |
      | MasterCard    | 45358179327829      | EKRLOFKPUUTQURT/ALMPWTZUL  | 2007     | 707  | 122560965000469 | 965000469    |
      | VISA          | 34798979016630      | XNHKBPMOENSGWLH/VVKLBTTVC  | 2011     | 885  | 131026823693372 | 823693372    |
      | AMEX 1        | 37158413190797      | YYBROXFQJRXJW/EVXOV        | 2001     | 442  | 57431313685     | 13685        |
      | AMEX 2        | 700199380329310926  | TPZRJLK/NKTUBHJNNWZI       | 2005     | 807  | 3121187689      | 7689         |
      | loyalty cards | 62211933327452      | PZNLQXRGCDILK/TDDZHWEUCTJ  | 2009     | 680  | 9497511743      | 1743         |
      | other cards   | 2830654628589795710 | XSYWIV/LHJPNU              | 2008     | 770  | 29814983505     | 83505        |
