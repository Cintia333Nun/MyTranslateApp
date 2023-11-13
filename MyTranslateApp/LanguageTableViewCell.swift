//
//  LanguageTableViewCell.swift
//  MyTranslateApp
//
//  Created by CinNun on 12/11/23.
//

import UIKit

/// Define the elements available in cell design
/// This element should be connected to the relevant component from the user interface.
class LanguageTableViewCell: UITableViewCell {
    /// Display the name of the language.
    @IBOutlet weak var languagueLabel: UILabel!
    /// Display the flag image of the language you want to select.
    @IBOutlet weak var imageLanguage: UIImageView!
}
