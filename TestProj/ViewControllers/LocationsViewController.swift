//
//  LocationsViewController.swift
//  TestProj
//
//  Created by Ilya Ilin on 1/30/18.
//  Copyright © 2018 Ilya Ilin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class LocationsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    lazy var viewModel: LocationsViewModel = LocationsViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.locations.bind(to: tableView.rx.items) { tv, ip, element in
            let cell = tv.dequeueReusableCell(withIdentifier: "locationCell") as! LocationTableViewCell
            cell.location = element
            return cell
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { indexPath in
            if let cell = self.tableView.cellForRow(at: indexPath) as? LocationTableViewCell {
                self.performSegue(withIdentifier: "notesSegue", sender: cell.location)
            }
        }).disposed(by: disposeBag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "notesSegue" {
            if let destination = segue.destination as? NoteViewController, let location = sender as? Location {
                destination.viewModel = NoteViewModel(locationName: location.name)
                
            }
        }
    }
}

extension LocationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
