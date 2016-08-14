//
//  ViewController.swift
//  StarWarAlamo
//
//  Created by John Regner on 8/14/16.
//  Copyright © 2016 WigglingScholars. All rights reserved.
//

import UIKit
import Alamofire

struct URL {
    private static let base = "https://swapi.co/api/"
    static let People = base + "people"
    static let Ships = base + "starships"
}

class ViewController: UITableViewController {

    var persons = [Nameable]()
    var nextURL : String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        Network.request(URL.People, callback: networkingFinished )
    }

    func networkingFinished(newPeople: [Person], next: String?) {
        nextURL = next
        persons += newPeople.map({ $0 as Nameable })
        tableView.reloadData()
    }

    // MARK: - Table View Stuff
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("persons Count: \(persons.count)")
        return persons.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = persons[indexPath.row].name
        getMoreDataIfNeeded(indexPath.row)
        return cell
    }

    func getMoreDataIfNeeded(count: Int) {
        guard let nextURL = nextURL else { return }
        if (persons.count - 5) == count {
            Network.request(nextURL, callback: networkingFinished)
        }
    }
}


class Network {

    static func request<T:NetworkObject>(url: String, callback: ([T], next: String?)-> () ){

        Alamofire
            .request(.GET, url)
            .responseJSON { response in
                guard let JSON = response.result.value as? NSDictionary else {
                    print("No Value")
                    return
                }
                guard let results = JSON["results"] as? NSArray else {
                    print("No Results")
                        return
                }

                let next = JSON["next"] as? String

                var people = [T]()

                for personData in results {
                    guard let newPerson = T(data: personData) else { return }
                    people.append(newPerson)
                }

                //get people
                callback(people, next: next )
        }
    }

}

protocol NetworkObject {
    init?(data: AnyObject?)
}

struct Person {
    let name: String

    init?(data: AnyObject?) {
        guard let data = data,
            dict = data as? NSDictionary,
            name = dict["name"] as? String else {
                return nil
        }

        self.name = name
    }
}

extension Person: NetworkObject {}

protocol Nameable {
    var name: String { get }
}

extension Person : Nameable {}

