//
//  ViewController.swift
//  Leaves
//
//  Created by Jay Patel on 30/07/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import UIKit
import CoreData

class LeavesViewController: UIViewController, LeaveSetDelegate, UITableViewDelegate, UITableViewDataSource {

    lazy var LeavesFetchResultController:NSFetchedResultsController<LeavesHistory> = {
        
        let fetchRequest:NSFetchRequest<LeavesHistory> = LeavesHistory.fetchRequest()
        let sort1 = NSSortDescriptor(key: #keyPath(LeavesHistory.leave_datetime), ascending: false)
        fetchRequest.sortDescriptors = [sort1]
        
        let fetchRequestController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.managedObjectContext, sectionNameKeyPath: #keyPath(LeavesHistory.leave_type), cacheName: nil)
        fetchRequestController.delegate = self
        return fetchRequestController
    }()
    
    lazy var dateTimeFormaater:DateFormatter = {
        let dtFormatter = DateFormatter()
        dtFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
        return dtFormatter
    }()
    
    @IBOutlet weak var leaveTableView:UITableView!

    var totalSickLeaves:Int = 0
    var totalWorkingLeaves:Int = 0
    var RemainSickLeaves:Int = 0
    var RemainWorkingLeaves:Int = 0
    
    
    @IBOutlet weak var SickLeaveLabel: UILabel!
    @IBOutlet weak var WorkingLeaveLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDesign()
        fetchData()
        fetchLeaves()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if LeavesHandler.isFirstTime() {
            let GetLeavesVC = storyboard?.instantiateViewController(withIdentifier: "GetLeavesID") as! GetLeavesViewController
            GetLeavesVC.delegate = self
            self.present(GetLeavesVC, animated: true, completion: nil)
            return
        }
        
    }
    
    func LeavesSetted() {
        fetchLeaves()
        self.leaveTableView.reloadData()
    }
    
    func fetchLeaves(){
        totalSickLeaves = LeavesHandler.getSickLeaves()
        totalWorkingLeaves = LeavesHandler.getWorkingLeaves()
        RemainSickLeaves = LeavesHandler.getRemainSickLeaves()
        RemainWorkingLeaves = LeavesHandler.getRemainWorkingLeaves()
        SickLeaveLabel.text = "\(totalSickLeaves-RemainSickLeaves) taken | \(RemainSickLeaves) remain"
        WorkingLeaveLabel.text = "\(totalWorkingLeaves-RemainWorkingLeaves) taken | \(RemainWorkingLeaves) remain"
    }

    deinit {
        //NotificationCenter.default.removeObserver(self)
        LeavesFetchResultController.delegate = nil
    }
    
    @IBAction func newLeave(_ sender: Any) {
        let newVC = storyboard?.instantiateViewController(withIdentifier: "NewLeaveViewID") as! NewLeaveViewController
        newVC.delegate = self
        newVC.isNew = true
        self.present(newVC, animated: true, completion: nil)
    }
    
    
    @IBAction func settingTapped(_ sender: Any) {
        //Setting in future
    }
    
    func fetchData(){
        do {
            try LeavesFetchResultController.performFetch()
        }catch{
            self.showError()
        }
    }
    
    func setupDesign(){
        
        //self.title = "Leaves"
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        label.textAlignment = .center
        label.text = "Leaves"
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "Arial-Bold", size: 27)
        self.navigationItem.titleView = label
        self.leaveTableView.tableFooterView = UIView()
        leaveTableView.delegate = self
        leaveTableView.dataSource = self
    }
    
    func showError() {
        
        let message = "There was a fatal error in the app and it cannot continue. Press OK to terminate the app. Sorry for the inconvenience."
        self.popupAlert(title: "Internal Error", message: message, actionTitles: ["Ok"], actions: [ { ok in
            
            let exception = NSException(name: NSExceptionName.internalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
            exception.raise()
            }
            ])
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if LeavesFetchResultController.sections != nil {
          return LeavesFetchResultController.sections!.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if LeavesFetchResultController.sections != nil {
           return LeavesFetchResultController.sections![section].numberOfObjects
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaveID", for: indexPath) as! LeavesCell
        let leaveO = LeavesFetchResultController.object(at: IndexPath(row: indexPath.row, section: indexPath.section))
        cell.LeaveCount.text = "Total: \(leaveO.leave_count)"
        cell.LeaveTextView.text = leaveO.leave_description ?? "No Description written"
        cell.LeaveDate.text = dateTimeFormaater.string(from: leaveO.leave_datetime! as Date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       //go for edit
        tableView.deselectRow(at: indexPath, animated: true)
        gotoEditMode(indexPath: indexPath)
    }
    
    func gotoEditMode(indexPath: IndexPath){
        let leaveO = LeavesFetchResultController.object(at: IndexPath(row: indexPath.row, section: indexPath.section))
        let newVC = storyboard?.instantiateViewController(withIdentifier: "NewLeaveViewID") as! NewLeaveViewController
        newVC.delegate = self
        newVC.isNew = false
        newVC.leave = leaveO
        self.present(newVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return  LeavesFetchResultController.sections![section].name
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.popupAlert(title: "Delete Leave", message: "It will also affect to leaves count.", actionTitles: ["Cancel","Delete"], actions: [
                { cancel in },
                { delete in
                    self.deleteLeave(indexPath: indexPath)
                }])
        }
    }
    
    func deleteLeave(indexPath:IndexPath){
        //LeavesFetchResultController.sections![section]
        
        let leave = LeavesFetchResultController.object(at: indexPath)
        
        do {
            
            let addLeaveBackCount = leave.leave_count
            
            print("Added Back \(addLeaveBackCount) For \(leave.leave_type ?? "leave not found")")
            if leave.leave_type == LeaveType.Sick.rawValue {
                LeavesHandler.SetRemainSickLeaves(leaves: self.RemainSickLeaves + Int(addLeaveBackCount))
            }else{
                LeavesHandler.SetRemainWorkingLeaves(leaves: self.RemainWorkingLeaves + Int(addLeaveBackCount))
            }
            
            CoreDataStack.managedObjectContext.delete(leave)
            try CoreDataStack.saveContext()
            
            fetchLeaves()
            
        } catch {
            self.showError()
        }
    }
    
}
extension LeavesViewController: NSFetchedResultsControllerDelegate {
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        leaveTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            leaveTableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            leaveTableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            
            if let cell = leaveTableView.cellForRow(at: indexPath!) as? LeavesCell {
                let leaveO = LeavesFetchResultController.object(at: indexPath!)
                cell.LeaveCount.text = "Total: \(leaveO.leave_count)"
                cell.LeaveTextView.text = leaveO.leave_description ?? ""
                cell.LeaveDate.text = dateTimeFormaater.string(from: leaveO.leave_datetime! as Date)
            }
            
        case .move:
            leaveTableView.deleteRows(at: [indexPath!], with: .fade)
            leaveTableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            leaveTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            leaveTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        leaveTableView.endUpdates()
    }
    
}










