//
//  ContentView.swift
//  CoreDataTutorial
//
//  Created by Miroslav Perovic on 10.5.23..
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var moc

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.lastName, ascending: true)],
        animation: .default)
    private var users: FetchedResults<User>

    var body: some View {
        NavigationView {
			VStack {
				AddNewUserView()
					.environment(\.managedObjectContext, moc)
				List {
					ForEach(users) { user in
						NavigationLink {
							Text("User: \(user.displayName)")
						} label: {
							Text(user.displayName)
						}
					}
					.onDelete(perform: deleteItems)
				}
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						EditButton()
					}
					ToolbarItem {
						Button(action: addUser) {
							Label("Add User", systemImage: "plus")
						}
					}
			}
			}
            Text("Select an user")
        }
    }

    private func addUser() {
        withAnimation {
            let newItem = User(context: moc)
			newItem.firstName = "Test"
			newItem.lastName = "User"
			newItem.email = "test.user@mydomain.com"

            do {
                try moc.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { users[$0] }.forEach(moc.delete)

            do {
                try moc.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct AddNewUserView: View {
	@Environment(\.managedObjectContext) private var moc

	@State private var firstName = ""
	@State private var lastName = ""
	@State private var email = ""
	
	@State private var validationError = ""
	@State private var duplicatesError = ""
	var body: some View {
		VStack {
			TextField("Enter First Name", text: $firstName)
				.textFieldStyle(.roundedBorder)
				.padding()
			TextField("Enter Last Name", text: $lastName)
				.textFieldStyle(.roundedBorder)
				.padding()
			
			TextField("Enter Email", text: $email)
				.keyboardType(.emailAddress)
				.textInputAutocapitalization(.never)
				.textFieldStyle(.roundedBorder)
				.padding()
			
			Button("Add") {
				let newUser = User(context: moc)
				newUser.firstName = firstName
				newUser.lastName = lastName
				newUser.email = email
				
				do {
					try moc.save()
				} catch let err as CocoaError {
					let errorDictionary = err.userInfo
					
					if let conflictList = errorDictionary[NSPersistentStoreSaveConflictsErrorKey] {
						let constraintConflicts = conflictList as! [NSConstraintConflict]
						for conflict in constraintConflicts {
							validationError = "Constraint violation(s) from: " + conflict.constraint.joined(separator: ", ")
							
							var duplicates: [String] = []
							for (propertyName, value) in conflict.constraintValues {
								duplicates.append("The \(propertyName) field should have a unique value. ' \(value)' already exists.")
							}
							duplicatesError = duplicates.joined(separator: "\n")
						}
						
						moc.delete(newUser)
					}
				} catch {
					validationError = error.localizedDescription
				}
				
				firstName = ""
				lastName = ""
				email = ""
			}
		
			if !validationError.isEmpty || !duplicatesError.isEmpty {
				Divider()
				Text(validationError)
					.foregroundColor(.red)
				Text(duplicatesError)
					.foregroundColor(.red)
			}
		}
	}
}
