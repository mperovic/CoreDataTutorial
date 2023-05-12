//
//  User+Extensions.swift
//  CoreDataTutorial
//
//  Created by Miroslav Perovic on 10.5.23..
//

import CoreData

extension User {
	var displayName: String {
		switch (firstName, lastName) {
		case let (firstName?, lastName?):
			return "\(firstName) \(lastName)"
		case let (firstName?, nil):
			return ("\(firstName)")
		case let (nil, lastName?):
			return ("\(lastName)")
		default:
			return "N/A"	// Not Available
		}
	}
}
