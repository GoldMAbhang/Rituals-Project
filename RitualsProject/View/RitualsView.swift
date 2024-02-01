//
//  RitualsView.swift
//  RitualsTask
//
//  Created by Abhang Mane @Goldmedal on 22/01/24.

//Main view controller
import Foundation
import UIKit
import Kingfisher
import CoreData

class RitualsView: UIViewController{
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentControl: UISegmentedControl!
    
    struct DetailsPair{
        var PinName:String
        var PinType:String
        var LocationName:String
        var Lmodifydt:String
        var PinImages:String
    }
    public var detailsPair = [RitualsDetails]()
    
    public var filteredDetails = [RitualsDetails]()
    
    public var searching = false
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let addDetailsButton = UIButton()
    
    var alertViewController = AlertViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        fetchDetails()
        self.tableView.dataSource = self
        loadDetails()
        tableView.register(UINib(nibName:K.nibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        navigationItem.titleView = searchBar
        addDetails()
        alertViewController.delegate = self
    }
    
    private func addDetails() {
        
        // login button customization
        addDetailsButton.setTitle("+", for: .normal)
        addDetailsButton.setTitleColor(.white, for: .normal)
        addDetailsButton.layer.cornerRadius = 25
        addDetailsButton.backgroundColor = UIColor(red:0.549,green:0.153,blue:0.000, alpha: 1.0)
        addDetailsButton.layer.masksToBounds = true
        addDetailsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        addDetailsButton.addTarget(self, action: #selector(handleaddDetailsButtonTapped), for: .touchUpInside)
        
        // adding the constraints to login button
        view.addSubview(addDetailsButton)
        addDetailsButton.translatesAutoresizingMaskIntoConstraints = false
        addDetailsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        addDetailsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -16).isActive = true
        addDetailsButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addDetailsButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    @objc private func handleaddDetailsButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController
        myAlert?.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        myAlert?.delegate = self
        self.present(myAlert!, animated: true, completion: nil)
    }
    
    @IBAction func segmentControlClicked(_ sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    
    //MARK: - Data Manipulation Methods
    
    //save to coredata
    func saveDetails() {
        do {
            // Check if the data already exists in Core Data
            let existingData = try context.fetch(RitualsDetails.fetchRequest())
            if existingData.isEmpty {
                // If data doesn't exist, then save it
                try context.save()
            } else {
                print("Data already exists, not saving again.")
            }
        } catch {
            print("Error saving details \(error)")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //For newly added details
    func addNewDetails() {
        do {
            try context.save()
        } catch {
            print("Error saving details \(error)")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //to load all the details from coredata
    func loadDetails() {
        
        let request : NSFetchRequest<RitualsDetails> = RitualsDetails.fetchRequest()
        
        do{
            detailsPair = try context.fetch(request)
            if detailsPair.count > 0 {
                //To avoid duplication of data
                for doubledData in detailsPair {
                    context.delete(doubledData)
                }
            }
        } catch{
            print("Error loading details \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    //search for the matching/contaning word/characters
    func searchDetails(sText:String) -> [RitualsDetails] {
        
        let request : NSFetchRequest = RitualsDetails.fetchRequest()
        
        let predicate = NSPredicate(format: "pinname contains[c] %@ OR locationname contains[c] %@", sText ,sText)
        
        request.predicate = predicate
        
        do{
            filteredDetails = try (context.fetch(request))
        }
        catch{
            print(error)
        }
        return filteredDetails
    }
    
    
    
    //MARK: - API Data Manipulation Methods
    //fetch Details for this user id
    func fetchDetails(){
        let apiURL = "https://crm-uat.goldmedalindia.in/api/Rituals/v1/manage/get-map-pin-list"
        let userId = 93
        performRequest(with: apiURL, userId: userId)
    }
    
    
    //(with) here increases code readability
    func performRequest(with urlString: String, userId: Int) {
        //1. Create URL
        if let url = URL(string: urlString) {
            //2. Create URLSession
            let session = URLSession(configuration: .default)
            
            //3. Prepare JSON data
            let userData = ["UserID": userId]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: userData)
                
                //4. Prepare URLRequest
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                //5. Create URLSession task for the POST request
                let task = session.dataTask(with: request) { (data, response, error) in
                    if error != nil {
                        print(error ?? "")
                        return
                    }
                    
                    if let safeData = data {
                        if let _ = self.parseJSON(safeData) {
                            print("detail")
                        }
                    }
                }
                
                //6. Start the task
                task.resume()
            }
            catch {
                print(error)
            }
        }
    }
    
    //Function to parse the JSON fetched form the apiurl and decode returning the details
    func parseJSON(_ detailsData: Data) -> DetailsModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(UserData.self,from: detailsData)
            //print(decodedData)
            for i in decodedData.Data{
                let pinName = i.PinName
                //print("Pin Name: \(pinName)")
                let pinType = i.TypeID
                //print("Pin Type: \(pinType)")
                let locationName = i.LocationName
                //print("Location Name: \(locationName)")
                let lmodifydt = i.Lmodifydt
                //print("Last Updated: \(lmodifydt)")
                let pinImages = i.PinImages
                //print("Image Pin: \(pinImages)")
                
                let newdetailsPair = RitualsDetails(context: self.context)
                newdetailsPair.pinname = pinName
                newdetailsPair.pintype = pinType
                newdetailsPair.locationname = locationName
                newdetailsPair.lmodifydt = lmodifydt
                newdetailsPair.pinimages = pinImages
                self.detailsPair.append(newdetailsPair)
                self.saveDetails()
            }
        }
        catch{
            print(error)
        }
        return nil
    }
    
    
}



// MARK: - Table view data source
extension RitualsView: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! DetailsCell
        
        //adding additional conditionals for displaying searchresults or just the array as per the condition
        var details: RitualsDetails
        
        if searching {
            details = filteredDetails[indexPath.row]
        }
        else{
            details = detailsPair[indexPath.row]
        }
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            //setting labeltext as per recieved data
            cell.pinName.text = "Pin Name: \(details.pinname ?? "")"
            
            if details.pintype == "1" {
                cell.pinType.text = "Pin Type: Amenities"
            } else if details.pintype == "2" {
                cell.pinType.text = "Pin Type: Events"
            }
            
            cell.locationName.text = "Location Name: \(details.locationname ?? "")"
            cell.lastUpdated.text = "Last Updated: \(details.lmodifydt ?? "")"
            
            //image as per fixed link appending specific image address recieved
            let testImage = URL(string: "https://goldmedalblob.blob.core.windows.net/goldappdata/goldapp/base/rituals/amenitiesmaster/\(details.pinimages ?? "")")
            cell.imageRecieved.kf.setImage(with: testImage)
            
        case 1:
            if details.pintype == "1" || details.pintype == "Amenities"{
                cell.pinName.text = "Pin Name: \(details.pinname ?? "")"
                cell.pinType.text = "Pin Type: Amenities"
                cell.locationName.text = "Location Name: \(details.locationname ?? "")"
                cell.lastUpdated.text = "Last Updated: \(details.lmodifydt ?? "")"
                
                //image as per fixed link appending specific image address recieved
                let testImage = URL(string: "https://goldmedalblob.blob.core.windows.net/goldappdata/goldapp/base/rituals/amenitiesmaster/\(details.pinimages ?? "")")
                cell.imageRecieved.kf.setImage(with: testImage)
            }
            
        case 2:
            if details.pintype == "2" || details.pintype == "Events"{
                cell.pinName.text = "Pin Name: \(details.pinname ?? "")"
                cell.pinType.text = "Pin Type: Events"
                cell.locationName.text = "Location Name: \(details.locationname ?? "")"
                cell.lastUpdated.text = "Last Updated: \(details.lmodifydt ?? "")"
                
                //image as per fixed link appending specific image address recieved
                let testImage = URL(string: "https://goldmedalblob.blob.core.windows.net/goldappdata/goldapp/base/rituals/amenitiesmaster/\(details.pinimages ?? "")")
                cell.imageRecieved.kf.setImage(with: testImage)
            }
            
        default:
            break
        }
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentControl.selectedSegmentIndex {
        case 0,1,2:
            return searching ? filteredDetails.count : detailsPair.count
        default:
            break
        }
        return 0
    }
}


// MARK: - UISearchBarDelegate

extension RitualsView: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            searching = true
            filteredDetails = searchDetails(sText: searchText)
            self.tableView.reloadData()
        }
        else if searchText == "" {
            searching = false
            filteredDetails = detailsPair
            self.tableView.reloadData()
        }
    }
}

// MARK: - AlertViewDelegate
extension RitualsView:AlertViewDelegate{
    func pinDetails(pinName: String, locationName: String,pinType:String) {
        //print(pinName,locationName,pinType)
        
        let newdetailsPair = RitualsDetails(context: self.context)
        newdetailsPair.pinname = pinName
        newdetailsPair.pintype = pinType
        newdetailsPair.locationname = locationName
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let lastModified = dateFormatter.string(from: date)
        newdetailsPair.lmodifydt = lastModified
        self.detailsPair.append(newdetailsPair)
        addNewDetails()
    }
}
