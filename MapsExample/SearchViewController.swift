//
//  SearchViewController.swift
//  MapsExample
//
//  Created by LOWCOST on 27/03/19.
//  Copyright © 2019 pagseguro. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Contacts

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        searchTableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "locationCell")
    }
    
    @objc func searchLocations() {
        guard let searchTableView = searchTableView, let text = searchBar.text else { return }
        
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = text
        
        let region = Locations.region
        
        if region != nil {
            request.region = region!
        }
        
        let search = MKLocalSearch(request: request)
        search.start { (response, _) in
            guard let response = response else {
                return
            }
            
            Locations.generalPlaces = response.mapItems
            Locations.myPlaces = []
            
            searchTableView.reloadData()
            
            self.view.endEditing(true)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: 0.8,
                                     target: self,
                                     selector: #selector (searchLocations),
                                     userInfo: nil,
                                     repeats: false)
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = Locations.generalPlaces[indexPath.row]
        
        if !Locations.myPlaces.contains(place) {
            Locations.myPlaces.append(place)
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Locations.generalPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LocationTableViewCell
        
        let place = Locations.generalPlaces[indexPath.row].placemark
        cell.lblTitle.text = place.name ?? ""
        
        if let postalAddress = place.postalAddress {
            cell.lblAddress.text = postalAddress.street
        }
        
        return cell
    }
}
