@appium @smoke @wpay @credit @me @verification @retail @dx8000 @ex8000 @dx4000 @rx5000 @rx7000

Feature: Add Support for Credit card verification transaction Manual Entry 
"""
   	==================================================================================================================================================================================================
	==================================================================================================================================================================================================
	================================================================= Test Case : Add Support for Credit card verification transaction Manual Entry  =================================================
	==================================================================================================================================================================================================
	==================================================================================================================================================================================================
    	Test Link : https://testlink.evf.us/linkto.php?tprojectPrefix=ARC-SI&item=testcase&id=ARC-SI-1005

	Preconditions :
	- Load latest ARCSI wpay build
	- Load wpay keys
	- Use the default config HostCardConfig.json
	- Connect to validation tool

"""

	Scenario Outline: Ensure Credit Verification transaction with Manual Entry is correctly performed.

    Given I use upp-ws transaction endpoint
    
	When I setup prompt on display: Executing scenario related to Credit Card Verification transaction

    When I send upp-ws request
    """      
	 "type": "verification",
     "payment_type": "credit",
     "amount": {
     "total": <amount>
      },
     "txn_status_events": false,
     "display_txn_result": true,
     "confirm_amount": false,
     "manual_entry": true	
	"""
     Then I should receive upp-ws response
      """
        "status" : "started"
      """

    And I Wait until Element "title" contains "Insert, Swipe or Tap Card"

	When I click Element "btn_manual_entry"

	Then I Wait until Element "Card_Input_Title" contains "Card Number"

	When I click Element "ed_pan"

	Then I send keys to Element "ed_pan" text "<pan>" and then ENTER

	Then I Wait until Element "Expiry_Date_Title" contains "Expiry Date"

	When I click Element "ed_expiry_date"

	And I send keys to Element "ed_expiry_date" text "<exp_date>" 

	Then I Wait until Element "Cvv_Input_Title" contains "Security Code"

    When I click Element "ed_cvv"

    And I send keys to Element "ed_cvv" text "<CVV>" and then ENTER

	Then I Wait until Element "fixed_title" contains "Enter ZIP code"

    And I wait 1 seconds
	
    When I setup prompt on display: Please enter zip code then 33606

    Then I click Element "input_box"

    And I send keys to Element "input_box" text "<zip_code>" and then ENTER
 
    Then I Wait until Element "title" contains "Processing… Please wait"

    Then  I should receive upp-ws event subset within 50s
    """
	"time":"@regexp:^$|.*",
	"date":"@regexp:^$|.*",
	"txn_type":"verification",
	"payment_type":"credit",
	"client_txn_id":"@regexp:^$|.*",
	"card": {
		"brand": "<brand>",
		"exp": "<exp>",
		"mnemonic": "<mnemonic>",
		"pan": "<pan_in_response>",
		"service_code": "<code>"
   	},
    "host": {
		"approval_code": "@regexp:^$|.*",
		"response_text": "<response_text>",
		"response_code": "<response_code>",
		"authorized_amount": "<responce_amount>",
		"retrieval_ref_num": "@regexp:^$|.*",
		"batch_number": "@regexp:^$|.*",  
		"cvv_result": "<cvv_result>",
		"avs_result": "@regexp:^$|.",
		"trace_number": "@regexp:^$|.*"
    },
	"type":"transaction_completed",
	"status":"proceed",
	"source":"manual_entry"
    """

      When I send upp-ws event_ack with status "ok"
      Then I should receive upp-ws event within 50s
    """
    "status":"completed",
    "type":"post_txn_reset"
    """

     When I send upp-ws event_ack with status "ok"
  
    Then I Wait until Element "title" contains "<response_text>"

    And I wait 3 seconds

   Examples:
      | card_type  | pan              | pan_in_response  | response_text| exp_date | code |amount | CVV  | mnemonic | brand         | exp  | response_code 	  |cvv_result |  zip_code | responce_amount |
      | AMEX       | 341111597242000  | 341111000002000  |  Approved    |1225      | 000  |1000   | 1234 | AE       | American Exp. | 2512 |    00            |      M    |    33606  |      0          |
      | MasterCard | 5444009999222205 | 5444000000002205 |  Approved    |1225      | 000  |1000   | 382  | MC       | MasterCard    | 2512 |    00            |      M    |    33606  |      0          |
      | VISA       | 4445222299990007 | 4445220000000007 |  Approved    |1225      | 000  |1000   | 382  | VI       | Visa          | 2512 |    00            |      M    |    33606  |      0          |
      | DISCOVER   | 6011000990911111 | 6011000000001111 |  Approved    |1225      | 000  |1000   | 111  | DS       | Discover      | 2512 |    00            |      M    |    33606  |      0          |
      | JCB        | 3566007770017510 | 3566000000007510 |  Approved    |1225      | 000  |1000   | 111  | JC       | JCB           | 2512 |    00            |      M    |    33606  |      0          |
      | CUP        | 6221261111117766 | 6221260000007766 |  Approved    |1225      | 000  |1000   | 111  | UP       | UnionPay      | 2512 |    00            |      M    |    33606  |      0          |