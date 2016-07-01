//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Hung-Yun Liao on 6/28/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: model
    var tweets = [Array<Tweet>]() { // an array consists of [Tweet] arrays. Also works: var tweets = [[Tweet]]() ~ tweets[sections][rows]
        //[(Tweet1, Tweet2), (Tweet3, Tweet4, Tweet5), (Tweet6, Tweet7)]
        didSet {
            tableView.reloadData() // will reload all the data in the UITableViewDataSource section
        }
    }
    
    var searchText: String? {
        didSet {
            tweets.removeAll()
            searchForTweets()
            title = searchText  // set the navigation title
        }
    }
    
    private var tweetsRequest: Twitter.Request? {
        if let query = searchText where !query.isEmpty { // where clause is sort of like "if ... && ...". See the following.
            return Twitter.Request(search: query + " -filter:retweets", count: 100) // -filter:retweets -> do not show the duplicate tweets.
        }
        
        // Following also works:
//        if searchText != nil && !(searchText?.isEmpty)! {
//            let query = searchText!
//            return Twitter.Request(search: query + " -filter:retweets", count: 100)
//        }
        
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        if let request = tweetsRequest {
            lastTwitterRequest = request
            request.fetchTweets { [weak weakSelf = self] (newTweets) in // here use weakSelf to not keep it in the heap because the user might navigate to other place while requesting. So in this case, it's perfect to get rid of it in the heap.
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, atIndex: 0)
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight // set to the original value to improve the performance of creating a table
        tableView.rowHeight = UITableViewAutomaticDimension // if using automaticDimension, always remember to set the estimatedRowHeight before this statement to improve the performance of creating a table.
        //searchText = "#USC" // To initialize. The flow: "viewDidLoad() -> searchText = '#stanford' -> searchText -> tweets.removeAll() -> searchForTweets() -> modify tweets -> reloadData() -> title = searchText"
    }

    // MARK: - UITableViewDataSource
 
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // return the number of sections
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return tweets[section].count
    }
    
    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetCellIdentifier, forIndexPath: indexPath) // get a tableViewCell
        
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell { // if cell != nil and the type is TweetTableViewCell, in this case, it must be.
            tweetCell.tweet = tweet
        }
        
        return cell // class is passed by reference, so we change tweetCell and then cell is changed too.
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self // if UITextField wants to pass data, pass to me and I can handle it via my implementation of the protocol
            searchTextField.text = searchText
        }
    }
    
    // MARK: Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want t he specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
