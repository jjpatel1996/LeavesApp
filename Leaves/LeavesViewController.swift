//
//  ViewController.swift
//  Leaves
//
//  Created by Jay Patel on 30/07/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import UIKit
import CoreData

class LeavesViewController: UITableViewController {

    lazy var LeavesFetchResultController:NSFetchedResultsController<LeavesHistory> = {
        
        let fetchRequest:NSFetchRequest<LeavesHistory> = LeavesHistory.fetchRequest()
        let sort1 = NSSortDescriptor(key: #keyPath(LeavesHistory.leave_datetime), ascending: false)
        fetchRequest.sortDescriptors = [sort1]
        
        let fetchRequestController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.managedObjectContext, sectionNameKeyPath: #keyPath(LeavesHistory.leave_type), cacheName: "LeavesHistory")
        fetchRequestController.delegate = self
        return fetchRequestController
    }()
    
    lazy var dateTimeFormaater:DateFormatter = {
        let dtFormatter = DateFormatter()
        dtFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dtFormatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if LeavesHandler.isFirstTime() {
            let GetLeavesVC = storyboard?.instantiateViewController(withIdentifier: GetLeavesID) as! GetLeavesViewController
            self.present(GetLeavesVC, animated: true, completion: nil)
            return
        }
        //Now What to do
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        LeavesFetchResultController.delegate = nil
    }
    
    @IBAction func newLeave(_ sender: Any) {
        let newVC = storyboard?.instantiateViewController(withIdentifier: "NewLeaveViewID") as! NewLeaveViewController
        self.present(newVC, animated: true, completion: nil)
    }
    
    func fetchData(){
        do {
            try LeavesFetchResultController.performFetch()
        }catch{
            self.showError()
        }
    }
    
    func setupDesign(){
        
        self.title = "Leaves"
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }

    }
    
    func showError() {
        
        let message = "There was a fatal error in the app and it cannot continue. Press OK to terminate the app. Sorry for the inconvenience."
        self.popupAlert(title: "Internal Error", message: message, actionTitles: ["Ok"], actions: [ { ok in
            
            let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
            exception.raise()
            }
            ])
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if LeavesFetchResultController.sections != nil {
            return LeavesFetchResultController.sections!.count + 1
        }else{
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if LeavesFetchResultController.sections != nil {
            if section == 0 {
               return 1
            }else{
               return LeavesFetchResultController.sections![section].numberOfObjects
            }
        }else{
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeaveHeaderID", for: indexPath) as! LeaveHeaderCell
            //Show Total Leaves
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeaveID", for: indexPath) as! LeavesCell
            let leaveO = LeavesFetchResultController.object(at: indexPath)
            cell.LeaveCount.text = "Total: \(leaveO.leave_count)"
            cell.LeaveTextView.text = leaveO.leave_description ?? ""
            cell.LeaveDate.text = dateTimeFormaater.string(from: leaveO.leave_datetime! as Date)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       //
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : LeavesFetchResultController.sections![section].name
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.popupAlert(title: "Delete Leave", message: "It will also affect to leaves count.", actionTitles: ["Cancel","Delete"], actions: [
                { cancel in },
                { delete in  }])
        }
    }
    
}
extension LeavesViewController: NSFetchedResultsControllerDelegate {
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            
            if let cell = tableView.cellForRow(at: indexPath!) as? LeavesCell {
                let leaveO = LeavesFetchResultController.object(at: indexPath!)
                cell.LeaveCount.text = "Total: \(leaveO.leave_count)"
                cell.LeaveTextView.text = leaveO.leave_description ?? ""
                cell.LeaveDate.text = dateTimeFormaater.string(from: leaveO.leave_datetime! as Date)
            }
            
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}










