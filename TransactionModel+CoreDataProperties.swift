//
//  TransactionModel+CoreDataProperties.swift
//  Buroku3
//
//  Created by J C on 2021-04-05.
//
//

import Foundation
import CoreData


extension TransactionModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionModel> {
        return NSFetchRequest<TransactionModel>(entityName: "TransactionModel")
    }

    @NSManaged public var date: Date?
    @NSManaged public var fileHash: String?
    @NSManaged public var transactionHash: String?
    @NSManaged public var walletAddress: String?
    @NSManaged public var transactionType: String?

}

extension TransactionModel : Identifiable {

}
