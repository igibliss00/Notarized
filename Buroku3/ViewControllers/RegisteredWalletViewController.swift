//
//  RegisteredWalletViewController.swift
//  Buroku3
//
//  Created by J C on 2021-03-23.
//

import UIKit
import web3swift

class RegisteredWalletViewController: UIViewController {
    var pvc: UIPageViewController!
    let galleries: [String] = ["1", "2"]
    var topBackgroundView: BackgroundView4!
    var ethLabel: UILabel!
    var sendButton: WalletButtonView!
    var receiveButton: WalletButtonView!
//    var rightBarButtonItem: UIBarButtonItem?
    
    let localDatabase = LocalDatabase()
    let keyservice = KeysService()
    let transactionService = TransactionService()
    let alert = Alerts()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configureTopView()
        setTopViewConstraints()
        
        configurePageVC()
        setSinglePageConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureWallet()
        configureNavigationItem(isVisible: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        configureNavigationItem(isVisible: false)
    }
}

extension RegisteredWalletViewController {
    // MARK: - Configure Navigation Item
    func configureNavigationItem(isVisible: Bool) {
        if isVisible {
            let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(buttonHandler))
            if rootViewController.children[0] is ContainerViewController {
                rootViewController.children[0].navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
            }
        } else {
            if rootViewController.children[0] is ContainerViewController {
                rootViewController.children[0].navigationItem.setRightBarButton(nil, animated: true)
            }
        }
    }
    
    func configureTopView() {
        // container view
        topBackgroundView = BackgroundView4()
        topBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBackgroundView)
        
        // eth label
        ethLabel = UILabel()
        ethLabel.text = "0 ETH"
        ethLabel.textColor = .white
        ethLabel.font = UIFont.systemFont(ofSize: 30, weight: .regular)
        ethLabel.sizeToFit()
        ethLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(ethLabel)
        
        // send button
        sendButton = WalletButtonView(imageName: "arrow.up.to.line", labelName: "Send", bgColor: UIColor(red: 47/255, green: 74/255, blue: 84/255, alpha: 1), labelTextColor: .white, imageTintColor: .white)
        sendButton.buttonAction = { [weak self] in
            let sendVC = SendViewController()
            sendVC.modalPresentationStyle = .fullScreen
            self?.present(sendVC, animated: true, completion: nil)
        }
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendButton)
        
        // receive button
        receiveButton = WalletButtonView(imageName: "arrow.down.to.line", labelName: "Receive", bgColor: UIColor(red: 47/255, green: 74/255, blue: 84/255, alpha: 1), labelTextColor: .white, imageTintColor: .white)
        receiveButton.buttonAction = { [weak self] in
            let receiveVC = ReceiveViewController()
            receiveVC.modalPresentationStyle = .fullScreen
            self?.present(receiveVC, animated: true, completion: nil)
        }
        receiveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(receiveButton)
    }
    
    // MARK: - setTopViewConstraints
    func setTopViewConstraints() {
        NSLayoutConstraint.activate([
            // container for top view
            topBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            topBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBackgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            // eth label
            ethLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ethLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 130),
            
            // send button
            sendButton.bottomAnchor.constraint(equalTo: topBackgroundView.bottomAnchor, constant: -90),
            sendButton.centerXAnchor.constraint(equalTo: topBackgroundView.centerXAnchor, constant: -80),
            sendButton.widthAnchor.constraint(equalToConstant: 100),
            sendButton.heightAnchor.constraint(equalToConstant: 100),
            
            // receive button
            receiveButton.bottomAnchor.constraint(equalTo: topBackgroundView.bottomAnchor, constant: -90),
            receiveButton.centerXAnchor.constraint(equalTo: topBackgroundView.centerXAnchor, constant: 80),
            receiveButton.widthAnchor.constraint(equalToConstant: 100),
            receiveButton.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    // MARK: - configurePageVC
    func configurePageVC() {
        let singlePageVC = SinglePageViewController(gallery: "1")
        guard let walletVC = self.parent as? WalletViewController else { return }
        singlePageVC.delegate =  walletVC // wallet view controller for a protocol
        pvc = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pvc.setViewControllers([singlePageVC], direction: .forward, animated: false, completion: nil)
        pvc.dataSource = self
        addChild(pvc)
        view.addSubview(pvc.view)
        pvc.didMove(toParent: self)
        pvc.view.translatesAutoresizingMaskIntoConstraints = false
        
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.6)
        pageControl.currentPageIndicatorTintColor = .gray
        pageControl.backgroundColor = .clear
    }
    
    // MARK: - setSinglePageConstraints
    func setSinglePageConstraints() {
        guard let pv = pvc.view else { return }
        NSLayoutConstraint.activate([
            pv.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pv.widthAnchor.constraint(equalTo: view.widthAnchor),
            pv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pv.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
    }
    
    @objc func buttonHandler(_ sender: UIButton!) {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.tintColor = UIColor.black
        spinner.startAnimating()
        rootViewController.children[0].navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [self] (_) in
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            spinner.stopAnimating()
            rootViewController.children[0].navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.configureWallet))
        }
    }
    
    @objc func configureWallet() {
        guard let address = Web3swiftService.currentAddress else {
            alert.show("Error", with: "There was an error obtaining the wallet address", for: self)
            return
        }
        
        DispatchQueue.global().async {
            do {
                let balance = try Web3swiftService.web3instance.eth.getBalance(address: address)
                if let balanceString = Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth, decimals: 4) {
                    DispatchQueue.main.async {
                        self.ethLabel.text = "\(self.transactionService.stripZeros(balanceString)) ETH"
                    }
                }
            } catch {
                self.alert.show("Error", with: "Sorry, there was an error retrieving your balance.", for: self)
            }
        }
    }
}

extension RegisteredWalletViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let gallery = (viewController as! SinglePageViewController).gallery, var index = galleries.firstIndex(of: gallery) else { return nil }
        index -= 1
        if index < 0 {
            return nil
        }
        return SinglePageViewController(gallery: galleries[index])
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let gallery = (viewController as! SinglePageViewController).gallery, var index = galleries.firstIndex(of: gallery) else { return nil }
        index += 1
        if index >= galleries.count {
            return nil
        }
        return SinglePageViewController(gallery: galleries[index])
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.galleries.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        let page = pageViewController.viewControllers![0] as! SinglePageViewController
        let gallery = page.gallery!
        return self.galleries.firstIndex(of: gallery)!
    }
}
