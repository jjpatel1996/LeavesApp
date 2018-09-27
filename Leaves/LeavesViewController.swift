//
//  ViewController.swift
//  Leaves
//
//  Created by Jay Patel on 30/07/18.
//  Copyright © 2018 Jay Patel. All rights reserved.
//

import UIKit
import CoreData

//LeavesIDVC
class LeavesViewController: UIViewController, LeaveSetDelegate, UITableViewDelegate, UITableViewDataSource, NotifyDelegate {

    lazy var LeavesFetchResultController:NSFetchedResultsController<LeavesHistory> = {
        
        let fetchRequest:NSFetchRequest<LeavesHistory> = LeavesHistory.fetchRequest()
        let sort1 = NSSortDescriptor(key: #keyPath(LeavesHistory.leave_datetime), ascending: false)
        fetchRequest.sortDescriptors = [sort1]
        fetchRequest.predicate = NSPredicate(format: "dead == %@", argumentArray: [0])
        let fetchRequestController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.managedObjectContext, sectionNameKeyPath: #keyPath(LeavesHistory.leave_type), cacheName: nil)
        fetchRequestController.delegate = self
        return fetchRequestController
    }()
    
    lazy var dateTimeFormaater:DateFormatter = {
        let dtFormatter = DateFormatter()
        dtFormatter.dateFormat = "dd-MM-yyyy"
        return dtFormatter
    }()
    
    @IBOutlet weak var leaveTableView:UITableView!

    var totalSickLeaves:Int = 0
    var totalWorkingLeaves:Int = 0
    var RemainSickLeaves:Int = 0
    var RemainWorkingLeaves:Int = 0
    
    @IBOutlet weak var SickLeaveLabel: UILabel!
    @IBOutlet weak var WorkingLeaveLabel: UILabel!
    
    @IBOutlet weak var SetupView: CardView!
    @IBOutlet weak var TotalLeaveHeaderView: CardView!
    
    var firebaseActivity:FirebaseActivity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseActivity = FirebaseActivity.init()
        setupDesign()
        fetchData()
        firebaseActivity.syncAllLeavesToDB()    //Sync All not synced Local Leaves to server.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLeaves()
        setupInitialProcess()
    }
    
    func setupDesign(){
        
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(gotoEditLeave))
        TotalLeaveHeaderView.addGestureRecognizer(tapGesture)
    }
    
    func fetchData(){
        do {
            try LeavesFetchResultController.performFetch()
        }catch{
            self.showError()
        }
    }
    
    func fetchLeaves(){
        totalSickLeaves = LeavesHandler.getSickLeaves()
        totalWorkingLeaves = LeavesHandler.getWorkingLeaves()
        RemainSickLeaves = LeavesHandler.getRemainSickLeaves()
        RemainWorkingLeaves = LeavesHandler.getRemainWorkingLeaves()
        SickLeaveLabel.text = "\(totalSickLeaves-RemainSickLeaves) taken | \(RemainSickLeaves) remain"
        WorkingLeaveLabel.text = "\(totalWorkingLeaves-RemainWorkingLeaves) taken | \(RemainWorkingLeaves) remain"
    }
    
    func setupInitialProcess(){
        
        if LeavesHandler.isFirstTime() {
            LeavesHandler.DoneFirstTime()
            askForLoginSignup()
        }
        if totalSickLeaves == 0 && totalWorkingLeaves == 0 {
            SetupView.isHidden = false
            TotalLeaveHeaderView.isHidden = true
        }else{
            SetupView.isHidden = true
            TotalLeaveHeaderView.isHidden = false
        }
    }
    
    func askForLoginSignup(){
        self.popupAlert(title: "Login/Register", message: "Do you want to login or register? This will allow you to sync data to server.", actionTitles: ["Cancel","Login"], actions: [ { cancel in }, { login in
               self.gotoLoginPage()
            } ])
    }
    
    func LeavesSetted() {
        fetchLeaves()
        setupInitialProcess()
        //self.leaveTableView.reloadData()
    }
    
    func gotoLoginPage(){
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthID") as! LoginSignupViewController
        loginVC.isPageOpenByPopup = true
        loginVC.delegate = self
        self.present( UINavigationController(rootViewController: loginVC), animated: true, completion: nil)
    }
    
    func notify() {
        firebaseActivity.syncLeavesFromFirebaseToApp()
        firebaseActivity.syncTotalLeaveFromFirebaseToApp { [weak self] (isUpdated) in
            guard let Strong = self else { return }
            Strong.fetchLeaves()
            Strong.setupInitialProcess()
        }
    }
    
    @objc func gotoEditLeave(){
        let editTotalLeaveVC = self.storyboard?.instantiateViewController(withIdentifier: "EditTotalLeaveID") as! EditTotalLeaveViewController
        self.navigationController?.pushViewController(editTotalLeaveVC, animated: true)
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
            
            leave.dead = 1
//            CoreDataStack.managedObjectContext.delete(leave)
            try CoreDataStack.saveContext()
//            FirebaseActivity().DeleteLeave(leave: leave)
            FirebaseActivity().UpdateLeave(leave: leave)
            fetchLeaves()
            
        } catch {
            self.showError()
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
    
    deinit {
        LeavesFetchResultController.delegate = nil
    }
    
    //MARK:------------All Actions------------------
    @IBAction func newLeave(_ sender: Any) {
        let newVC = storyboard?.instantiateViewController(withIdentifier: "NewLeaveViewID") as! NewLeaveViewController
        newVC.delegate = self
        newVC.isNew = true
        self.present(newVC, animated: true, completion: nil)
    }
    
    @IBAction func settingTapped(_ sender: Any) {
        let settingVC = storyboard?.instantiateViewController(withIdentifier: "SettingVCID") as! SettingViewController
        self.present(UINavigationController(rootViewController: settingVC), animated: true, completion: nil)
    }
    
    @IBAction func SetupLeavesTapped(_ sender: Any) {
        let GetLeavesVC = storyboard?.instantiateViewController(withIdentifier: "GetLeavesID") as! GetLeavesViewController
        GetLeavesVC.delegate = self
        self.present(GetLeavesVC, animated: true, completion: nil)
        return
    }

    
    //MARK:------------TableView Methods------------------
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
        if let leaveDate = leaveO.leave_datetime {
            let dateString = dateTimeFormaater.string(from: leaveDate)
            cell.LeaveDate.text = "Leave taken on \(dateString)"
        }else {
            cell.LeaveDate.text = "Date not found"
        }
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.popupAlert(title: "Delete Leave", message: "It will also affect to leaves count.", actionTitles: ["Cancel","Delete"], actions: [
                { cancel in },
                { delete in
                    self.deleteLeave(indexPath: indexPath)
                }])
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
                cell.LeaveDate.text = "Leave taken on \(dateTimeFormaater.string(from: leaveO.leave_datetime! as Date))"
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

