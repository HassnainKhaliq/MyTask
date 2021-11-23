//
//  Track.swift
//  MyTask
//
//  Created by Hassnain Khaliq on 23/11/2021.
//

import Foundation

class Track {
 
  let index: Int
  let previewURL: URL
  
  var downloaded = false
  
  init(previewURL: URL, index: Int) {
    self.previewURL = previewURL
    self.index = index
  }
}
