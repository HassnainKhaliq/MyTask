//
//  DownloadingViewController.swift
//  MyTask
//
//  Created by Hassnain Khaliq on 22/11/2021.
//

import UIKit
import SSProgressBar

class DownloadingViewController: UIViewController ,URLSessionDownloadDelegate{
    
        
    @IBOutlet weak var img0: UIImageView!
    @IBOutlet weak var progress0: SSProgressBar!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var progress1: SSProgressBar!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var progress2: SSProgressBar!
    @IBOutlet weak var btnStartSending: UIButton!
    
    let downloadService = DownloadService()
    lazy var downloadsSession: URLSession = {
      let configuration = URLSessionConfiguration.background(withIdentifier:
        "ZAT-Technologies.MyTask.session")
      return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    var arrProgress = [SSProgressBar]()
    var arrImg = [UIImageView]()
    var arrUrl = [String]()
    var task: Int = 0
    
    var url0: String = "https://cdn.arstechnica.net/wp-content/uploads/2018/06/macOS-Mojave-Dynamic-Wallpaper-transition.jpg"
    var url1: String = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/aa/Polarlicht_2.jpg/1920px-Polarlicht_2.jpg?1568971082971"
    var url2: String = "https://upload.wikimedia.org/wikipedia/commons/0/07/Huge_ball_at_Vilnius_center.jpg"
    
    let concurrentQueue = DispatchQueue(label: "com.queue.Concurrent", attributes: .concurrent)
    var myGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadService.downloadsSession = downloadsSession
        
        arrProgress = [progress0,progress1,progress2]
        arrImg = [img0,img1,img2]
        arrUrl = [url0,url1,url2]
        
        progress0.withProgressGradientBackground(from: UIColor.red, to: UIColor.purple, direction: .leftToRight)
        progress1.withProgressGradientBackground(from: UIColor.red, to: UIColor.purple, direction: .leftToRight)
        progress2.withProgressGradientBackground(from: UIColor.red, to: UIColor.purple, direction: .leftToRight)
        // Do any additional setup after loading the view.
        
        self.startDownloading(with: {
            //All images are downloaded perform next operation
            self.btnStartSending.isHidden = false
        })
    }
    
    
    @IBAction func btnStartSendingAction(_ sender: UIButton)
    {
        
    }
    
    func startDownloading(with completion: @escaping () -> ())
    {
        for i in 0..<3
        {
            myGroup.enter()
            concurrentQueue.async {
                let track = Track(previewURL: URL(string: self.arrUrl[i])!, index: i)
                let _ = self.downloadService.startDownload(track)
            }
        }
        myGroup.notify(queue: DispatchQueue.main)
        {
            completion()
        }
    }
    
    func setImageToImageView(from data: Data?,id: Int) {
        guard let imageData = data else { return }
        guard let image = getUIImageFromData(imageData) else { return }
        
        DispatchQueue.main.async {
            self.arrImg[id].image = image
            self.myGroup.leave()
        }
    }
    
    func getUIImageFromData(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
    
    func readDownloadedData(of url: URL) -> Data? {
        do {
            let reader = try FileHandle(forReadingFrom: url)
            let data = reader.readDataToEndOfFile()
            
            return data
        } catch {
            print(error)
            return nil
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let data = readDownloadedData(of: location)
        guard let sourceURL = downloadTask.originalRequest?.url else {
          return
        }
        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil
        download?.track.downloaded = true
        if let index = download?.track.index {
          DispatchQueue.main.async { [weak self] in
              self?.setImageToImageView(from: data, id: index)
          }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard
          let url = downloadTask.originalRequest?.url,
          let download = downloadService.activeDownloads[url]  else {
            return
        }
        
        let progress = Int(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) * 100)
        
        DispatchQueue.main.async {
            self.arrProgress[download.track.index].progress = progress
        }
    }
}
