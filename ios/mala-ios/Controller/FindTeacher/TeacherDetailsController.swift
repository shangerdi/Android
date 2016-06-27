//
//  TeacherDetailsController.swift
//  mala-ios
//
//  Created by Elors on 12/30/15.
//  Copyright © 2015 Mala Online. All rights reserved.
//

import UIKit

private let TeacherDetailsCellReuseId = [
    0: "TeacherDetailsSubjectCellReuseId",
    1: "TeacherDetailsTagsCellReuseId",
    2: "TeacherDetailsHighScoreCellReuseId",
    3: "TeacherDetailsPhotosCellReuseId",
    4: "TeacherDetailsCertificateCellReuseId",
    5: "TeacherDetailsPlaceCellReuseId",
    6: "TeacherDetailsVipServiceCellReuseId",
//    7: "TeacherDetailsLevelCellReuseId",
//    8: "TeacherDetailsPriceCellReuseId"
]

private let TeacherDetailsCellTitle = [
    1: "教授年级",
    2: "风格标签",
    3: "提分榜",
    4: "个人相册",
    5: "特殊成就",
    6: "教学环境",
    7: "会员服务",
    8: "教龄 级别",
    9: "价格表"
]

class TeacherDetailsController: BaseViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, SignupButtonDelegate {

    // MARK: - Property
    var teacherID: Int = 0
    var model: TeacherDetailModel = MalaConfig.defaultTeacherDetail() {
        didSet {
            MalaOrderOverView.avatarURL = model.avatar
            MalaOrderOverView.teacherName = model.name
            MalaOrderOverView.subjectName = model.subject
            MalaOrderOverView.teacher = model.id
            
            tableHeaderView.model = model
            self.tableView.reloadData()
        }
    }
    var schoolArray: [SchoolModel] = [SchoolModel(id: 0, name: "线下体验店", address: "----")] {
        didSet {
            // 刷新 [教学环境] Cell
            self.tableView.reloadSections(NSIndexSet(index: 5), withRowAnimation: .None)
        }
    }
    var memberServiceArray: [MemberServiceModel] = [] {
        didSet {
            // 刷新 [会员服务] Cell
            self.tableView.reloadSections(NSIndexSet(index: 6), withRowAnimation: .None)
        }
    }
    var isOpenSchoolsCell: Bool = false
    var isNavigationBarShow: Bool = false
    /// 必要数据加载完成计数
    private var requiredCount: Int = 0 {
        didSet {
            // [老师详情][上课地点][会员服务]三个必要数据加载完成才激活界面
            if requiredCount == 3 {
                ThemeHUD.hideActivityIndicator()
            }
        }
    }

    
    // MARK: - Components
    /// 主体TableView
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: MalaScreenWidth, height: MalaScreenHeight - MalaLayout_DetailBottomViewHeight), style: .Grouped)
        tableView.contentInset = UIEdgeInsets(top: MalaLayout_DetailBottomViewHeight, left: 0, bottom: 0, right: 0)
        return tableView
    }()
    /// TableView头部视图
    private lazy var tableHeaderView: TeacherDetailsHeaderView = {
        let tableHeaderView = TeacherDetailsHeaderView(frame: CGRect(x: 0, y: 0, width: MalaScreenWidth, height: 170))
        return tableHeaderView
    }()
    /// 顶部背景图
    private lazy var headerBackground: UIImageView = {
        let image = UIImageView(image: UIImage(named: "teacherDetailHeader_placeholder"))
        image.contentMode = .ScaleAspectFill
        return image
    }()
    /// 底部 [立即报名] 按钮
    private lazy var signupView: TeacherDetailsSignupView = {
        let signupView = TeacherDetailsSignupView(frame: CGRect(x: 0, y: 0,
            width: MalaScreenWidth, height: MalaLayout_DetailBottomViewHeight))
        return signupView
    }()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeHUD.showActivityIndicator()
        
        setupUserInterface()
        loadTeacherDetail()
        setupNotification()
        loadSchoolsData()
        loadMemberServices()
        
        // 激活Pop手势识别
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.enabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // 设置 NavigationBar 透明色
        // makeStatusBarWhite()
        self.navigationController?.navigationBarHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isNavigationBarShow {
            showBackground()
        }else {
            hideBackground()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage.withColor(UIColor.whiteColor()), forBarMetrics: .Default)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.shadowImage = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Private Method
    private func setupUserInterface() {
        // Style
        tableView.estimatedRowHeight = 240
        tableView.backgroundColor = MalaColor_EDEDED_0
        tableView.separatorStyle = .None
        
        // TableView
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(TeacherDetailsSubjectCell.self, forCellReuseIdentifier: TeacherDetailsCellReuseId[0]!)
        tableView.registerClass(TeacherDetailsTagsCell.self, forCellReuseIdentifier: TeacherDetailsCellReuseId[1]!)
        tableView.registerClass(TeacherDetailsHighScoreCell.self, forCellReuseIdentifier: TeacherDetailsCellReuseId[2]!)
        tableView.registerClass(TeacherDetailsPhotosCell.self, forCellReuseIdentifier: TeacherDetailsCellReuseId[3]!)
        tableView.registerClass(TeacherDetailsCertificateCell.self, forCellReuseIdentifier: TeacherDetailsCellReuseId[4]!)
        tableView.registerClass(TeacherDetailsPlaceCell.self, forCellReuseIdentifier: TeacherDetailsCellReuseId[5]!)
        tableView.registerClass(TeacherDetailsVipServiceCell.self, forCellReuseIdentifier: TeacherDetailsCellReuseId[6]!)
//        tableView.registerClass(TeacherDetailsLevelCell.self, forCellReuseIdentifier: TeacherDetailsCellReuseId[7]!)
//        tableView.registerClass(TeacherDetailsPriceCell.self, forCellReuseIdentifier: TeacherDetailsCellReuseId[8]!)
        
        // SubViews
        view.addSubview(signupView)
        signupView.delegate = self
        tableView.tableHeaderView = tableHeaderView
        tableView.insertSubview(headerBackground, atIndex: 0)
        
        // Autolayout
        signupView.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(self.view.snp_left)
            make.right.equalTo(self.view.snp_right)
            make.bottom.equalTo(self.view.snp_bottom)
            make.height.equalTo(MalaLayout_DetailBottomViewHeight)
        })
        headerBackground.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(0).offset(-MalaScreenNaviHeight)
            make.centerX.equalTo(self.tableView.snp_centerX)
            make.width.equalTo(MalaScreenWidth)
            make.height.equalTo(MalaLayout_DetailHeaderLayerHeight)
        }
    }
    
    private func setupNotification() {
        NSNotificationCenter.defaultCenter().addObserverForName(
            MalaNotification_OpenSchoolsCell,
            object: nil,
            queue: nil
            ) { [weak self] (notification) -> Void in
            // 展开 [教学环境] Cell
                if let isOpen = notification.object as? Bool {
                    self?.isOpenSchoolsCell = isOpen
//                    self?.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 6), atScrollPosition: .Top, animated: true)
                    self?.tableView.reloadSections(NSIndexSet(index: 5), withRowAnimation: .Fade)
                }
        }
        NSNotificationCenter.defaultCenter().addObserverForName(
            MalaNotification_PushPhotoBrowser,
            object: nil,
            queue: nil
            ) { [weak self] (notification) -> Void in
                // push图片浏览器
                if let photoBrowser = notification.object as? SKPhotoBrowser {
                    
                    self?.navigationController?.presentViewController(photoBrowser, animated: true, completion: nil)
                    
                }else if let malaPhotoBrowser = notification.object as? MalaPhotoBrowser {
                    
                    self?.navigationController?.pushViewController(malaPhotoBrowser, animated: true)
                }
        }
    }
    
    private func loadTeacherDetail() {
        MalaNetworking.sharedTools.loadTeacherDetail(self.teacherID, finished: {[weak self] (result, error) -> () in
            
            ThemeHUD.hideActivityIndicator()
            
            if error != nil {
                println("TeahcerDeatilsController - loadTeacherDetail Request Error")
                return
            }
            guard let dict = result as? [String: AnyObject] else {
                println("TeahcerDeatilsController - loadTeacherDetail Format Error")
                return
            }
            
            self?.model = TeacherDetailModel(dict: dict)
            self?.requiredCount += 1
            })
    }
    
    private func loadSchoolsData() {
        // // 获取 [教学环境] 数据
        MalaNetworking.sharedTools.loadSchools{[weak self] (result, error) -> () in
            
            ThemeHUD.hideActivityIndicator()
            
            if error != nil {
                println("TeacherDetailsController - loadSchools Request Error")
                return
            }
            guard let dict = result as? [String: AnyObject] else {
                println("TeacherDetailsController - loadSchools Format Error")
                return
            }
            
            // result 字典转 [SchoolModel] 模型数组
            let resultArray = ResultModel(dict: dict).results
            var tempArray: [SchoolModel] = []
            for object in resultArray ?? [] {
                if let dict = object as? [String: AnyObject] {
                    let set = SchoolModel(dict: dict)
                    tempArray.append(set)
                }
            }
            self?.schoolArray = tempArray
            self?.requiredCount += 1
        }
    }
    
    private func loadMemberServices() {
        // 获取 [会员服务] 数据
        MalaNetworking.sharedTools.loadMemberServices{[weak self] (result, error) -> () in
            
            ThemeHUD.hideActivityIndicator()
            
            if error != nil {
                println("TeacherDetailsController - loadMemberServices Request Error")
                return
            }
            guard let dict = result as? [String: AnyObject] else {
                println("TeacherDetailsController - loadMemberServices Format Error")
                return
            }
            
            // Transfer results to [MemberServiceModel]
            let resultArray = ResultModel(dict: dict).results
            var tempArray: [MemberServiceModel] = []
            for object in resultArray ?? [] {
                if let dict = object as? [String: AnyObject] {
                    let set = MemberServiceModel(dict: dict)
                    tempArray.append(set)
                }
            }
            self?.memberServiceArray = tempArray
            self?.requiredCount += 1
        }
    }
    
    private func showBackground() {
        // makeStatusBarBlack()
        self.title = model.name 
        navigationController?.navigationBar.setBackgroundImage(UIImage.withColor(UIColor.whiteColor()), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = nil
        turnBackButtonBlack()
    }
    
    private func hideBackground() {
        // makeStatusBarWhite()
        self.title = ""
        navigationController?.navigationBar.setBackgroundImage(UIImage.withColor(UIColor.clearColor()), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        turnBackButtonWhite()
    }
    
    // 跳转到课程购买页
    private func pushToCourseChoosingView() {
        let viewController = CourseChoosingViewController()
        viewController.teacherModel = model
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    // MARK: - Deleagte
    func signupButtonDidTap(sender: UIButton) {
        
        // 未登陆则进行登陆动作
        if !MalaUserDefaults.isLogined {
            
            let loginController = LoginViewController()
            loginController.popAction = { [weak self] in
                if MalaUserDefaults.isLogined {
                    self?.pushToCourseChoosingView()
                }
            }
            
            self.presentViewController(
                UINavigationController(rootViewController: loginController),
                animated: true,
                completion: nil)
        
        }else {
            self.pushToCourseChoosingView()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let displacement = scrollView.contentOffset.y
        
        // 向下滑动页面时，使顶部图片跟随放大
        if displacement < -MalaScreenNaviHeight {
            headerBackground.snp_updateConstraints(closure: { (make) -> Void in
                make.top.equalTo(0).offset(displacement)
                // 1.1为放大速率
                make.height.equalTo(MalaLayout_DetailHeaderLayerHeight + abs(displacement+MalaScreenNaviHeight)*1.1)
            })
        }
        
        // 上下滑动页面到一定程度且 NavigationBar 尚未显示，渲染NavigationBar样式
        if displacement > -40 && !isNavigationBarShow {
            showBackground()
            isNavigationBarShow = true
        }
        if displacement < -40 && isNavigationBarShow {
            hideBackground()
            isNavigationBarShow = false
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 8 : 4
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == TeacherDetailsCellReuseId.count-1 ? 8 : 4
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    // MARK: - DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TeacherDetailsCellReuseId.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let reuseCell = tableView.dequeueReusableCellWithIdentifier(TeacherDetailsCellReuseId[indexPath.section]!, forIndexPath: indexPath)
        (reuseCell as! MalaBaseCell).title.text = TeacherDetailsCellTitle[indexPath.section+1]
        
        switch indexPath.section {
        case 0:
            
            let cell = reuseCell as! TeacherDetailsSubjectCell
            cell.gradeStrings = self.model.grades
            return cell
            
        case 1:
            let cell = reuseCell as! TeacherDetailsTagsCell
            cell.labels = self.model.tags
            return cell
            
        case 2:
            let cell = reuseCell as! TeacherDetailsHighScoreCell
            cell.model = self.model.highscore_set
            return cell
            
        case 3:
            let cell = reuseCell as! TeacherDetailsPhotosCell
            cell.photos = self.model.photo_set ?? []
            cell.accessory = .RightArrow
            return cell
            
        case 4:
            let cell = reuseCell as! TeacherDetailsCertificateCell
            cell.models = self.model.achievement_set
            return cell
            
        case 5:
            let cell = reuseCell as! TeacherDetailsPlaceCell
            cell.schools = self.schoolArray
            cell.isOpen = self.isOpenSchoolsCell
            return cell
            
        case 6:
            let cell = reuseCell as! TeacherDetailsVipServiceCell
            cell.labels = self.memberServiceArray.map({ (model) -> String in
                return model.name ?? ""
            })
            return cell
            
        case 7:
            let cell = reuseCell as! TeacherDetailsLevelCell
//            cell.labels = [self.model.teachingAgeString, (self.model.level) ?? ""]
            return cell
            
        case 8:
            let cell = reuseCell as! TeacherDetailsPriceCell
            cell.accessory = .SubTitle
            cell.prices = self.model.prices
            return cell
            
        default:
            break
        }

        return reuseCell
    }


    deinit {
        
        println("TeacherDetailController Deinit")
        // 移除观察者
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MalaNotification_OpenSchoolsCell, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MalaNotification_PushPhotoBrowser, object: nil)
    }
}