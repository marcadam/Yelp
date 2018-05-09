//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import MBProgressHUD

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

    enum ViewMode: String {
        case List = "List"
        case Map = "Map"
    }

    var currentViewMode = ViewMode.List

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: nil, action: nil)

        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90

        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)

        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets

        // Set tableView footer to an empty view to prevent empty cells from being rendered
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        // Run initial search
        searchWithTerm(lastSearchTerm, limit: searchDefaultLimit, offset: searchDefaultOffset)
        searchBar.text = lastSearchTerm

        // set the region to display, this also sets a correct zoom level
        // set starting center location in San Francisco
        let centerLocation = CLLocation(latitude: Constants.DefaultLocation.latitude, longitude: Constants.DefaultLocation.longitude)
        goToLocation(centerLocation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FiltersSegue" {
            let navigationController = segue.destination as! UINavigationController
            let filterViewController = navigationController.topViewController as! FilterViewController
            filterViewController.delegate = self
        } else if segue.identifier == "BusinessDetailSegue" {
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
            let businessDetailVC = segue.destination as! BusinessDetailViewController
            businessDetailVC.business = businesses[indexPath.row]
        }
    }

    @IBAction func didToggleViewMode(_ sender: UIBarButtonItem) {
        if currentViewMode == .List {
            currentViewMode = .Map
            UIView.transition(
                with: view,
                duration: 0.5,
                options: [.transitionFlipFromRight],
                animations: {
                    self.tableView.isHidden = true
                    self.mapView.isHidden = false
                },
                completion: nil
            )
            sender.title = ViewMode.List.rawValue
        } else {
            currentViewMode = .List
            UIView.transition(
                with: view,
                duration: 0.5,
                options: [.transitionFlipFromLeft],
                animations: {
                    self.tableView.isHidden = false
                    self.mapView.isHidden = true
                },
                completion: nil
            )
            sender.title = ViewMode.Map.rawValue
        }
    }

    // MARK: - Search

    fileprivate func searchWithTerm(_ term: String, limit: Int?, offset: Int?) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Business.searchWithTerm(term, limit: limit, offset: offset, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.businesses = businesses
            self.tableView.reloadData()
            // Need to ensure we have at least one business otherwise we will crash when scrolling to a row that does not exist.
            if businesses.count > 0 {
                self.tableView.backgroundView = nil
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            } else {
                 let emptyStateView = BusinessesEmptyState()
                emptyStateView.searchTerm = term
                self.tableView.backgroundView = emptyStateView
            }
            self.addAnnotationForBusinesses(self.businesses)
        })
    }

    fileprivate func searchWithTerm(_ term: String, limit: Int?, offset: Int?, filters: [String: AnyObject]) {
        let deals = filters["deals"] as? Bool
        let distance = filters["distance"] as? Int
        let sortBy = filters["sortBy"] as? Int
        let categories = filters["categories"] as? [String]
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Business.searchWithTerm(lastSearchTerm, limit: limit, offset: offset, sort: YelpSortMode(rawValue: sortBy!), categories: categories, distance: distance, deals: deals) { (businesses: [Business]!, error: NSError!) -> Void in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.businesses = businesses
            self.tableView.reloadData()
            // Need to ensure we have at least one business otherwise we will crash when scrolling to a row that does not exist.
            if businesses.count > 0 {
                 self.tableView.backgroundView = nil
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            } else {
                let emptyStateView = BusinessesEmptyState()
                emptyStateView.searchTerm = term
                self.tableView.backgroundView = emptyStateView
            }
            self.addAnnotationForBusinesses(self.businesses)
        }
    }

    fileprivate func loadMoreData() {
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

                self.addAnnotationForBusinesses(self.businesses)
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

                self.addAnnotationForBusinesses(self.businesses)
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension BusinessesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let businesses = businesses {
            return businesses.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell

        // Reset content to defaults
        cell.nameLabel.text = nil
        cell.distanceLabel.text = nil
        cell.reviewsCountLabel.text = nil
        cell.addressLabel.text = nil
        cell.categoriesLabel.text = nil
        cell.thumbImageView.image = nil
        cell.ratingImageView.image = nil

        // Set new content
        cell.row = indexPath.row
        cell.business = businesses[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension BusinessesViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isMoreDataLoading {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height

            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true

                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()

                loadMoreData()
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension BusinessesViewController {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
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
    func filterViewController(_ filterViewController: FilterViewController, didUpdateFilters filters: [String: AnyObject]) {
        lastSearchFilters = filters
        searchCurrentOffset = searchDefaultOffset
        searchWithTerm(lastSearchTerm, limit: searchDefaultLimit, offset: searchDefaultOffset, filters: filters)
    }
}

// MARK: - Map related methods

extension BusinessesViewController {

    fileprivate func goToLocation(_ location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }

    fileprivate func addAnnotationForBusinesses(_ businesses: [Business]) {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations(annotationsToRemove)

        for business in businesses {
            let coordinate = CLLocationCoordinate2D(latitude: business.coordinate.latitude!, longitude: business.coordinate.longitude!)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = business.name
            mapView.addAnnotation(annotation)
        }

        zoomMapToFitAnnotationsForBusiness(businesses)
    }

    fileprivate func zoomMapToFitAnnotationsForBusiness(_ businesses: [Business]) {
        let rectToDisplay = self.businesses.reduce(MKMapRectNull) { (mapRect: MKMapRect, business: Business) -> MKMapRect in
            let coordinate = CLLocationCoordinate2D(latitude: business.coordinate.latitude!, longitude: business.coordinate.longitude!)
            let businessPointRect = MKMapRect(origin: MKMapPointForCoordinate(coordinate), size: MKMapSize(width: 0, height: 0))
            return MKMapRectUnion(mapRect, businessPointRect)
        }
        self.mapView.setVisibleMapRect(rectToDisplay, edgePadding: UIEdgeInsetsMake(74, 20, 20, 20), animated: false)
    }
}
