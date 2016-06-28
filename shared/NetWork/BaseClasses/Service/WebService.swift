/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation

enum WebServiceError: ErrorType {
  case BadResponse
  case NoResponse
  case Other
}


class WebService {
  let session: NSURLSession
  let rootURL: NSURL
  
  init (rootURL:NSURL) {
    self.rootURL = rootURL;
    
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    
    session = NSURLSession(configuration: configuration)
  }
  
  
  // MARK: - ****** Request Helpers ******
  
    internal func requestWithURLString(string: String, postDictionary: NSDictionary!) -> NSURLRequest? {
    if let url = NSURL(string: string, relativeToURL: rootURL) {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        var jsonData: NSData?
        var jsonString: String? = ""
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(postDictionary, options: NSJSONWritingOptions.init(rawValue: 0))
            // here "jsonData" is the dictionary encoded in JSON data
            jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)! as String
        } catch let error as NSError {
            print(error)
        }
        let strings = "message=" + jsonString!
        request.HTTPBody = strings.dataUsingEncoding(NSUTF8StringEncoding)
      return request
    }
    return nil
  }
  
  internal func executeDictionaryRequest(requestPath:String, postData: NSDictionary!, completion: (dictionary:NSDictionary?, error: NSError!) -> Void) {
    
    print("Executing Request With Path: \(requestPath)")
    if let request = requestWithURLString(requestPath, postDictionary:postData) {
      // Create the task
      let task = session.dataTaskWithRequest(request) { data, response, error in
        
        if error != nil {
          completion(dictionary: nil, error: error)
          return
        }
        
        // Check to see if there was an HTTP Error
        let cleanResponse = self.checkResponseForErrors(response)
        if let errorCode = cleanResponse.errorCode {
          print("An error occured: \(errorCode)")
          completion(dictionary: nil, error: error)
          return
        }
        //
        print("Request success...:" + String(data: data!, encoding: NSUTF8StringEncoding)!)
        
        // Make sure you got a dictionary back after parsing
        guard let dataDictionary = self.jsonDictionary(withData: data!) where dataDictionary.count > 0 else {
          print("Parsing Issues")
          completion(dictionary: nil, error: error)
          return
        }
        
        
        // Things went well, call the completion handler
        completion(dictionary: dataDictionary, error: error)
      }
      task.resume()
      
    } else {
      // It was a bad URL, so just fire an error
      let error = NSError(domain:NSURLErrorDomain,
        code:NSURLErrorBadURL,
        userInfo:[ NSLocalizedDescriptionKey : "There was a problem creating the request URL:\n\(requestPath)"] )
      completion(dictionary: nil, error: error)
    }
  }

  // TODO - Implement Functionality
  internal func executeArrayRequest(requestPath:String, postData: NSDictionary!, completion: (array:NSArray?, error: NSError!) -> Void) {
    
    print("Executing Request With Path: \(requestPath)")
    if let request = requestWithURLString(requestPath, postDictionary: postData) {
      // Create the request
      let task = session.dataTaskWithRequest(request) { data, response, error in
        
        if error != nil {
          completion(array: nil, error: error)
          return
        }
        
        // Check to see if there was an HTTP Error
        let cleanResponse = self.checkResponseForErrors(response)
        if let errorCode = cleanResponse.errorCode {
          print("An error occured: \(errorCode)")
          completion(array: nil, error: error)
          return
        }
        
        // Make sure you got an array back after parsing
        guard let dataArray = self.jsonArray(withData: data!) else {
          print("Parsing Issues")
          completion(array: nil, error: error)
          return
        }
        
        // Things went well, call the completion handler
        completion(array: dataArray, error: error)
      }
      task.resume()
      
    } else {
      // It was a bad URL, so just fire an error
      let error = NSError(domain:NSURLErrorDomain,
        code:NSURLErrorBadURL,
        userInfo:[ NSLocalizedDescriptionKey : "There was a problem creating the request URL:\n\(requestPath)"] )
      completion(array: nil, error: error)
    }
  }
  
  
  // MARK: - ****** Response Helpers ******
  
  /**
  Takes an `NSURLResponse` object and attempts to determine if any errors occured
  - parameter response: The `NSURLResponse` generated by the task
  - returns: Tuple (`httpResponse` - The `NSURLResponse` cast to a `NSHTTPURLResponse` and `errorCode` - An error code enum representing detecable problems.)
  */
  internal func checkResponseForErrors(response: NSURLResponse?) -> (httpResponse: NSHTTPURLResponse?, errorCode: WebServiceError?) {
    // Make sure there was an actual response
    guard response != nil else {
      return (nil, WebServiceError.NoResponse)
    }
    
    // Convert the response to an `NSHTTPURLResponse` (You can do this because you know that you are making HTTP calls in this scenario, so the cast will work.)
    guard let httpResponse = response as? NSHTTPURLResponse else {
      return (nil, WebServiceError.BadResponse)
    }
    
    // Check to see if the response contained and HTTP response code of something other than 200
    let statusCode = httpResponse.statusCode
    guard statusCode == 200 else {
      return (nil, WebServiceError.Other)
    }
    
    return (httpResponse, nil)
  }
  
  /**
  Takes an `NSData` object and attempts to extract a dictionary from it
  - parameter data: The `NSData` object that contains a `JSON` string
  - returns: A dictionary of objects keyed with Strings
  - SeeAlso: `jsonArray(withData data: NSData)`, `stripJSONPWrapper(jsonp: NSData)`
  */
  internal func jsonDictionary(withData data: NSData) -> NSDictionary? {
    do {
      
      // Extract the JSON object and check to see if its a dictionary
      return try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary
      
    } catch {
      return nil
    }
  }
  
  /**
  Takes an `NSData` object and attempts to extract an array from it
  - parameter data: The `NSData` object that contains a `JSON` string
  - returns: A dictionary of objects keyed with Strings
  - SeeAlso: `jsonDictionary(withData data: NSData)`, `stripJSONPWrapper(jsonp: NSData)`
  */
  internal func jsonArray(withData data: NSData) -> NSArray? {
    do {
      
      // Extract the JSON object and check to see if its an array
      return try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSArray
      
    } catch {
      return nil
    }
  }
  
}