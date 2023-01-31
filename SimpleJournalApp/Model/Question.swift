//
//  Question.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 1/31/23.
//

import Foundation


public enum Question: String, CaseIterable {
    case summary = "Summary of the day"
    case good = "What did i do good?"
    case bad = "What did i do bad?"
    case improve = "How can I improve on that?"
    case tested = "Where was my discipline and self-control tested?"
}


