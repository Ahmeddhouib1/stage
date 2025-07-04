@23x @msr @00x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature: Cancel 23.x Card Read Request

  Scenario: Send 23.x Card Read Request then simulate swipe

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    When I send a 23.x Read Card message to the terminal with:
      | p23_req_prompt_index   | 3          |
      | p23_req_form_name      | read_cards |
      | p23_req_enable_devices | M          |

    And I Wait until Element "title" contains "Please slide card"

    And I wait until Element "btn_cancel" visible

    And I wait for 1 second

    And Axium swipe magnetic card:
      | track1 | B62217984210356^LYUATZMDAU/ABKBXTDWTDZJPHY^2008305937343886685 |
      | track2 | 62217984210356=2008305886685                                   |
      | track3 |                                                                |

    Then I should receive the 23.x Read Card response from terminal with params:
      | p23_res_exit_type   | 0                                                              |
      | p23_res_card_source | M                                                              |
      | p23_res_track1      | B62217984210356^LYUATZMDAU/ABKBXTDWTDZJPHY^2008305937343886685 |
      | p23_res_track2      | 62217984210356=2008305886685                                   |
      | p23_res_track3      |                                                                |