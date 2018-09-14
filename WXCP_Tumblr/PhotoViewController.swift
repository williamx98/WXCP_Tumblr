//
//  PhotoViewController.swift
//  WXCP_Tumblr
//
//  Created by Will Xu  on 9/6/18.
//  Copyright © 2018 Will Xu . All rights reserved.
//

import UIKit
import AlamofireImage

class PhotoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{

    var posts: [[String: Any]] = []
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var refreshIndicator: UIActivityIndicatorView!
    var refreshControl: UIRefreshControl!
    var isMoreDataLoading = false
    var offset = 0
    var loadingMoreView:InfiniteScrollActivityView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPosts()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getPosts(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        self.refreshIndicator.startAnimating()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifer = "PostCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifer, for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        if let photos = post["photos"] as? [[String: Any]] {
            let photo = photos[0]
            // 2.
            let originalSize = photo["original_size"] as! [String: Any]
            // 3.
            let urlString = originalSize["url"] as! String
            // 4.
            let url = URL(string: urlString)
            
            let imageView = cell.postImageView
            let placeholderImage = UIImage(named: "tumblrLogo")!
            
            imageView?.af_setImage(withURL: url!, placeholderImage: placeholderImage)
        }
        
        return cell
    }

    @objc func getPosts(_ refreshControl: UIRefreshControl = UIRefreshControl()) {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&offset=" + String(offset))!
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 3.0
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                let alertController = UIAlertController(title: error.localizedDescription, message: "", preferredStyle: .alert)
                let refreshAction = UIAlertAction(title: "Refresh", style: .cancel) { (action) in
                    self.getPosts()
                }
                alertController.addAction(refreshAction)
                self.present(alertController, animated: true) {}
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // TODO: Get the posts and store in posts property
                // Get the dictionary from the response key
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                // Store the returned array of dictionaries in our posts property
                let loadedPosts = (responseDictionary["posts"] as! [[String: Any]])
                for post in loadedPosts {
                    self.posts.append(post)
                }
                // TODO: Reload the table view
                self.isMoreDataLoading = false
                self.loadingMoreView!.stopAnimating()
                self.refreshControl.endRefreshing()
                self.refreshIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? PhotoDetailViewController {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                dest.post = posts[indexPath.row]
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                
                isMoreDataLoading = true
                // Cod to load more results
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                offset += 20
                print(offset)
                self.getPosts()
            }
        }
    }
}

class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.isHidden = true
    }
    
    func startAnimating() {
        self.isHidden = false
        self.activityIndicatorView.startAnimating()
    }
}
