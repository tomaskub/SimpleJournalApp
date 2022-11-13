//
//  TabBarViewController.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/13/22.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    
    let layer = CAShapeLayer()
    var layerHeight = CGFloat()
    
    let backgroundColor: UIColor = .black
    let secondaryColor: UIColor = .white
    let shadowcolor: UIColor = .darkGray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBar()
        // Do any additional setup after loading the view.
    }
    
    func setUpTabBar() {
        // create and configure tab bar layer
        let x: CGFloat = 10
        let y: CGFloat = 20
        let width = self.tabBar.bounds.width - x * 2
        let height = self.tabBar.bounds.height + y * 1.5
        layerHeight = height
        layer.fillColor = backgroundColor.cgColor
        layer.path = UIBezierPath(roundedRect: CGRect(x: x, y: self.tabBar.bounds.minY - y, width: width, height: height), cornerRadius: height / 2 ).cgPath
        // add tab bar shadow
        layer.shadowColor = shadowcolor.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.5
        
        // add tab bar layer
        self.tabBar.layer.insertSublayer(layer, at: 0)
        
        //
        self.tabBar.itemWidth = width / 6
        self.tabBar.itemPositioning = .centered
        self.tabBar.unselectedItemTintColor = secondaryColor
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
