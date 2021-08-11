//
//  MainViewController.swift
//  Graphics-Demo
//
//  Created by Alberto Saltarelli on 11/08/21.
//  Copyright © 2021 Alberto Saltarelli. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cardsViewController = segue.destination as? GlassmorphicCardsViewController {
            cardsViewController.isDarkModeEnabled = segue.identifier == "dark"
        }
    }
}
