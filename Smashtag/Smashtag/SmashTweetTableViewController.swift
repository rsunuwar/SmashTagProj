//
//  SmashTweetTableViewController.swift
//  Smashtag
//
//  Created by Rosy on 1/18/18.
//  Copyright © 2018 MacPractice. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class SmashTweetTableViewController: TweetTableViewController {
	
	var container: NSPersistentContainer? =
		(UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
	
	
	override func insertTweets(_ newTweets: [Twitter.Tweet]) {
		super.insertTweets(newTweets)
		updateDatabase(with: newTweets)
	}
	
	private func updateDatabase(with tweets: [Twitter.Tweet]) {
		container?.performBackgroundTask {[weak self] context in
			for twitterInfo in tweets {
				// add Tweet - to our dataModel
				_ = try? Tweet.findOrCreateTweet(matching: twitterInfo, in: context)
			}
			try? context.save()
			self?.printDatabaseStatistics()
		}
	}
	
	private func printDatabaseStatistics() {
		// viewContext -- main context here but this is called from within a block (above)
		// so will have problems - context are different
		// add context.perform -- performs in whatever context is right for it i.e. viewContext (main context)
		// COREDATA THREAD SAFETY
		if let context = container?.viewContext {
			context.perform {
				if Thread.isMainThread {
					print("on main thread")
				}
				else {
					print("not on main thread")
				}
				let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
				if let tweetCount = (try? context.fetch(request))?.count {
					print("\(tweetCount) tweets")
				}
				if let tweeterCount = try? context.count(for: TwitterUser.fetchRequest()) {
					print("\(tweeterCount) Twitter users")
				}
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "Tweeters Mentioning Search Term" {
			if let tweetersTVC = segue.destination as? SmashTweetersTableViewController {
				tweetersTVC.mention = searchText
				tweetersTVC.container = container
				
				
			}
			
		}
	}
	
}
