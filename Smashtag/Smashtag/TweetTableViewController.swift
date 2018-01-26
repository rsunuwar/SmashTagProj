//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Rosy on 11/7/17.
//  Copyright © 2017 MacPractice. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
	
	@IBOutlet weak var searchTextField: UITextField! {
		didSet {
			searchTextField.delegate = self
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == searchTextField {
			searchText = searchTextField.text
		}
		return true
	}
	
	private var tweets = [Array<Twitter.Tweet>] () {
		didSet {
			print(tweets)
		}
	}
	
	var searchText: String? {
		didSet {
			searchTextField?.text = searchText
			searchTextField?.resignFirstResponder()
			tweets.removeAll()
			tableView.reloadData()
			searchForTweets()
			title = searchText
		}
	}
	
	func insertTweets(_ newTweets: [Twitter.Tweet]) {
		self.tweets.insert(newTweets, at: 0)
		self.tableView.insertSections([0], with: .fade)
	}
	
	private func twitterRequest() -> Twitter.Request? {
		if let query = searchText, !query.isEmpty {
			return Twitter.Request(search: "\(query) -filter:safe -filter:retweets", count: 100)
		}
		return nil
	}
	
	private var lastTwitterRequest: Twitter.Request?
	
	private func searchForTweets() {
		if let request = twitterRequest() {
			lastTwitterRequest = request
			request.fetchTweets { [weak self] newTweets in
				DispatchQueue.main.async {					
					if request == self?.lastTwitterRequest {
						 // UI calls should be done in main queue
						self?.insertTweets(newTweets)
					}
				}
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.estimatedRowHeight = tableView.rowHeight
		tableView.rowHeight = UITableViewAutomaticDimension
//		searchText = "#stanford"
	}

    // MARK: - UITableDataViewSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)

        // Configure the cell...
		let tweet: Twitter.Tweet = tweets[indexPath.section][indexPath.row]
//		cell.textLabel?.text = tweet.text		// this is for subtitle view type
//		cell.detailTextLabel?.text = tweet.user.name
		
		if let tweetCell = cell as? TweetTableViewCell {
			tweetCell.tweet = tweet
		}

        return cell
    }
	

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
