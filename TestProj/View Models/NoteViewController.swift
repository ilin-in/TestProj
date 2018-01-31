//
//  NoteViewController.swift
//  TestProj
//
//  Created by Ilya Ilin on 1/31/18.
//  Copyright © 2018 Ilya Ilin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class NoteViewController: UIViewController {
    @IBOutlet weak var lblDefault: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var txtNote: UITextField!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    
    let disposeBag = DisposeBag()
    var viewModel: NoteViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSave.rx.tap.subscribe(onNext: {
            self.viewModel.updateNote(newNote: self.txtNote.text)
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        viewModel.location.map { !$0.isDefault }.bind(to: lblDefault.rx.isHidden).disposed(by: disposeBag)
        viewModel.location.map { $0.distanceString }.bind(to: lblDistance.rx.text).disposed(by: disposeBag)
        viewModel.location.map { $0.name }.bind(to: lblName.rx.text).disposed(by: disposeBag)
        viewModel.location.take(1).map { $0.note }.bind(to: txtNote.rx.text).disposed(by: disposeBag)
        
    }
}
