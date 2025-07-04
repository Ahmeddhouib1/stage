@41 @msr @00x @dx8000 @ex8000 @dx4000 @rx5000 @rx7000
Feature:Swipe Transaction with 41.x Card Read without parse fields

  Scenario: Send 41.x Card Read Request then simulate swipe

    Given I send a 00.x Offline message to the terminal with params:
      | p00_req_reason_code | 0000 |

    Then I should receive the 00.x Offline response from terminal with params:
      | p00_res_reason_code | 0000 |

    And I Wait until Element "title" contains "This Lane Closed"

    When I send a 41.x Card Read Message message to the terminal with params:
      | p41_req_parse_flag       | 0 |
      | p41_req_msr_flag         | 1 |
      | p41_req_contactless_flag | 0 |
      | p41_req_smc_flag         | 0 |

    And I wait for 2 seconds

    Then Axium swipe magnetic card:
      | track1 | B5413330089099130^UAT USA/TEST CARD 20^25122011483594900000000000000000 |
      | track2 | 5413330089099130=25122011483594900000                                   |
      | track3 |                                                                         |

    And I wait for 30 seconds

    And I should receive the 41.x Card Read Message response from terminal with params:
      | p41_res_source         | M                                                                       |
      | p41_res_encryption     | 00                                                                      |
      | p41_res_track_1_status | 0                                                                       |
      | p41_res_track_2_status | 0                                                                       |
      | p41_res_track_3_status | 1                                                                       |
      | p41_res_track_1        | B5413330089099130^UAT USA/TEST CARD 20^25122011483594900000000000000000 |
      | p41_res_track_2        | 5413330089099130=25122011483594900000                                   |
      | p41_res_track_3        |                                                                         |
      | p41_res_error_code     | 0                                                                       |