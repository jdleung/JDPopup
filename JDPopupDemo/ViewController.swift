//
//  ViewController.swift
//  JDPopupDemo
//
//  Created by jdleung on 2021/9/8.
//

import UIKit
import JDPopup

class ViewController: UIViewController {

    var jdPopView: JDPopup!
    
    lazy var sampleTextView: UITextView = {
        let txv = UITextView()
        txv.font = UIFont.systemFont(ofSize: 17)
        txv.isEditable = false
        txv.isSelectable = false
        txv.contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        return txv
    }()
    
    // Tree photo created by wirestock - www.freepik.com
    // https://www.freepik.com/photos/tree
    lazy var treeImageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "tree")
        return img
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "JDPopup Demo"
        self.view.backgroundColor = #colorLiteral(red: 0.9807812572, green: 0.9357372522, blue: 0.7789309025, alpha: 1)
                
        sampleTextView.text = """
            Xcode 13 adds powerful new team development features, perfect for working with Xcode Cloud as well as with GitHub, Bitbucket, and GitLab collaboration features. Initiate, review, comment, and merge pull requests directly within Xcode. See your teammates’ comments right inside your code. And quickly compare any two versions of your code files.
            
            Take advantage of a complete workflow to manage pull requests directly within Xcode. Create new requests, see a queue of pull requests ready for your review, and quickly view, build, and test results generated locally or by Xcode Cloud.
            
            Apps are code-signed using an Apple-hosted service that manages all of your certificates, making App Store submission easier and more reliable. Just sign in to Xcode using your Apple ID, and your Mac is configured for development and deployment based on your membership roles and permissions.
            
            Build documentation for your Swift framework or package directly from your source code’s documentation comments, then view it in Xcode’s Quick Help and dedicated documentation viewer. Extend those comments by adding extension files, articles, and tutorials — all written in Markdown — and choose to share the compiled DocC Archive with other developers or host it on your website.
            """
    }
    

    @IBAction
    func showFullHeightPopView(_ sender: UIButton) {
        let titleLabel = UILabel()
        titleLabel.text = "Full available size"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        let popView = JDPopup(
            sender: sender,
            barViewAdapter: { barView in
                titleLabel.frame = CGRect(x: 15, y: 5, width: barView.frame.width - 35, height: 30)
                barView.addSubview(titleLabel)
            },
            contentViewAdapter: { contentView in
                self.treeImageView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
                contentView.addSubview(self.treeImageView)
            })
        
        popView.config.borderWidth = 0
        popView.config.bgColor = .white
        self.present(popView, animated: false, completion: nil)
    }
    
    
    @IBAction
    func showLimitHeightPopView(_ sender: UIButton) {
        
        let popView = JDPopup(
            sender: sender,
            barTitle: "Custom width and height",
            contentViewAdapter: { contentView in
                self.treeImageView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
                contentView.addSubview(self.treeImageView)
            })
        
        popView.config.borderWidth = 0.0
        popView.config.customHeight = 300.0
        popView.config.customWidth = 300.0
        popView.config.bgColor = .white
        self.present(popView, animated: false, completion: nil)
    }
    
    
    @IBAction
    func showPopupViewWithSegment(_ sender: UIBarButtonItem, event: UIEvent) {
        
        let seg = UISegmentedControl(items: ["TextView", "TableView"])
        seg.frame = CGRect(x: 15, y: 5, width: 200, height: 30)
        seg.addTarget(self, action: #selector(self.segmentChanged(_:)), for: .valueChanged)
        seg.selectedSegmentIndex = 0
        seg.backgroundColor = UIColor.yellow.withAlphaComponent(0.6)

        jdPopView = JDPopup(
            event: event,
            barViewAdapter: { barView in
                barView.addSubview(seg)
            },
            contentViewAdapter: { contentView in
                self.sampleTextView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
                contentView.addSubview(self.sampleTextView)
            })
        
        jdPopView.config.bgColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        jdPopView.config.exitBtnTintColor = .white
        self.present(jdPopView, animated: false, completion: nil)
    }
    
    
    @objc
    func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            jdPopView.toggleContentView({ contentView in
                self.sampleTextView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
                contentView.addSubview(self.sampleTextView)
            })
            
        } else {
            
            let tv = UITableView()
            tv.register(UITableViewCell.self, forCellReuseIdentifier: "TableCell")
            tv.delegate = self
            tv.dataSource = self
            
            jdPopView.toggleContentView({ contentView in
                tv.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
                contentView.addSubview(tv)
            })
        }
    }

    
    @IBAction
    func showPopupCollectionView(_ sender: UIButton) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 70, height: 70)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionCell")
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false

        let popView = JDPopup(
            sender: sender,
            barTitle: "CollectionView",
            contentViewAdapter: { contentView in
                cv.frame = CGRect(x: 20, y: 10, width: contentView.frame.width-40, height: contentView.frame.height-20)
                contentView.addSubview(cv)
            })
        
        popView.config.customHeight = 330
        popView.config.bgColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        popView.config.barTitleColor = .white
        popView.config.exitBtnTintColor = .white
        self.present(popView, animated: false, completion: nil)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell")
        cell?.textLabel?.text = "Tableview cell \(indexPath.row)"
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        print(indexPath.row)
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
        cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        cell.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        cell.layer.borderWidth = 1.0
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = true
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        imgView.image = UIImage(named: "tree")
        cell.contentView.addSubview(imgView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

