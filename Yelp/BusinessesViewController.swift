//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UISearchBarDelegate {

    var businesses: [Business]!
    var lastSearchTerm = "Restaurants"
    var lastSearchFilters: [String: AnyObject]?

    let searchDefaultLimit = 20
    let searchDefaultOffset = 0
    var searchCurrentLimit = 20
    var searchCurrentOffset = 0
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?

    var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90

        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)

        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets

        // Run initial search
        searchWithTerm(lastSearchTerm, limit: searchDefaultLimit, offset: searchDefaultOffset)
        searchBar.text = lastSearchTerm
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
        let filterViewController = navigationController.topViewController as! FilterViewController
        filterViewController.delegate = self
    }

    // MARK: - Search

    private func searchWithTerm(term: String, limit: Int?, offset: Int?) {
        Business.searchWithTerm(term, limit: limit, offset: offset, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
        })
    }

    private func searchWithTerm(term: String, limit: Int?, offset: Int?, filters: [String: AnyObject]) {
        let deals = filters["deals"] as? Bool
        let distance = filters["distance"] as? Int
        let sortBy = filters["sortBy"] as? Int
        let categories = filters["categories"] as? [String]
        Business.searchWithTerm(lastSearchTerm, limit: limit, offset: offset, sort: YelpSortMode(rawValue: sortBy!), categories: categories, distance: distance, deals: deals) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
        }
    }

    private func loadMoreData() {
        searchCurrentOffset += searchDefaultLimit
        if lastSearchFilters == nil {
            Business.searchWithTerm(lastSearchTerm, limit: searchDefaultLimit, offset: searchCurrentOffset, completion: { (businesses: [Business]!, error: NSError!) -> Void in
                self.isMoreDataLoading = false

                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()

                for business in businesses {
                    self.businesses.append(business)
                }
                self.tableView.reloadData()
            })
        } else {
            let deals = lastSearchFilters!["deals"] as? Bool
            let distance = lastSearchFilters!["distance"] as? Int
            let sortBy = lastSearchFilters!["sortBy"] as? Int
            let categories = lastSearchFilters!["categories"] as? [String]
            Business.searchWithTerm(lastSearchTerm, limit: searchDefaultLimit, offset: searchCurrentOffset, sort: YelpSortMode(rawValue: sortBy!), categories: categories, distance: distance, deals: deals) { (businesses: [Business]!, error: NSError!) -> Void in
                self.isMoreDataLoading = false

                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()

                for business in businesses {
                    self.businesses.append(business)
                }
                self.tableView.reloadData()
            }
        }
    }
}

extension BusinessesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let businesses = businesses {
            return businesses.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell

        cell.row = indexPath.row
        cell.business = businesses[indexPath.row]

        return cell
    }
}

extension BusinessesViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !isMoreDataLoading {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height

            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true

                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()

                loadMoreData()
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension BusinessesViewController {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchTerm = searchBar.text!
        lastSearchTerm = searchTerm
        lastSearchFilters = nil
        searchCurrentOffset = searchDefaultOffset
        searchWithTerm(searchTerm, limit: searchDefaultLimit, offset: searchDefaultOffset)
        searchBar.resignFirstResponder()
    }
}

// MARK: - FilterViewControllerDelegate

extension BusinessesViewController: FilterViewControllerDelegate {
    func filterViewController(filterViewController: FilterViewController, diUpdateFilters filters: [String: AnyObject]) {
        lastSearchFilters = filters
        searchCurrentOffset = searchDefaultOffset
        searchWithTerm(lastSearchTerm, limit: searchDefaultLimit, offset: searchDefaultOffset, filters: filters)
    }
}
