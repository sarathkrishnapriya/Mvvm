//
//  ViewController.swift
//  mvvm
//
//  Created by MacBook on 23/11/22.
//

import UIKit
import Network

class ViewController: UIViewController {
    
    var networkManager : NetworkManager = NetworkManager()
    var status = ""
    lazy var Internet  = Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
     let isConnected =   Internet.isConnected()
        
        print(isConnected)
        
        let parameter = ["ReqMode":"4",
                         "Token":"92167983-9C58-4F95-B772-320D3B4C4394",
                         "FK_Customer":"23",
                         "BankKey" : "d.22333",
                         "BankHeader" : "PERFECT SCORE BANK HEAD OFFICE"]
        
        networkManager.apiCall(urlPath: "", withMethod: .GET) { result in
            
            switch result{
            case.success(let successResponse):
                DispatchQueue.main.async {
                    print(successResponse)
                }
                
                
            case .failure(let error) : print(error.localizedDescription)
                
            }
        }
        // Do any additional setup after loading the view.
        //monitorNetwork()
    }
    
    
//    func monitorNetwork(){
//        let monitor = NWPathMonitor()
//        monitor.pathUpdateHandler = { path in
//
//            if path.status == .satisfied{
//
//                DispatchQueue.main.async {
//
//                    print("internet is connected")
//                }
//
//            }else{
//
//                DispatchQueue.main.async {
//
//                    print("internet not connected")
//                }
//
//            }
//
//        }
//
//        let queue = DispatchQueue(label: "Network")
//        monitor.start(queue: queue)
//
//    }


}

protocol NetworkProtocol{
    
   
    func isConnected()->(Bool,String)
    
}



struct Reachability:NetworkProtocol{
   
    
   
    
    
    
    func isConnected() -> (Bool, String) {
        
        var result =  (false,"not connected")
        
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            
            if path.status == .satisfied{
                
                DispatchQueue.main.async {
                    
                    result =  (true,"connected")
                    
                }
                
               
                
            }else{
                
                DispatchQueue.main.async {
                    
                    result =  (false,"not connected")
                }
                
            }
            
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
        
        return result
        
    }
    
    
}


enum HttpMethod: String{
    
    case GET
    case POST
    case PUT
    case DELETE
    
    
}

class NetworkManager{
    
    
    
    let ProductIP = "https://jsonplaceholder.typicode.com"
    let baseUrl = "/todos/"
    
    
    

    
    func apiCall(urlPath:String,parameter:[String:Any]=[:],withMethod:HttpMethod=HttpMethod.POST,completion: @escaping (Result<NSDictionary,Error>) -> Void){
        
        
        let url = URL(string: ProductIP + baseUrl + urlPath)
        var UrlRequest = URLRequest(url: url!)
        UrlRequest.timeoutInterval = 45
        UrlRequest.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        UrlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        
        switch withMethod {
        case .GET:
            UrlRequest.httpMethod  = withMethod.rawValue
            
            
            
            
        case .POST:
            UrlRequest.httpMethod  = withMethod.rawValue
            
            do{
                
                UrlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
            }
            catch let error{
                print(error.localizedDescription)
            }
        case .PUT:
            UrlRequest.httpMethod  = withMethod.rawValue
        case .DELETE:
            UrlRequest.httpMethod  = withMethod.rawValue
            
        }
        
        
        URLSession.shared.dataTask(with: UrlRequest) { data, response, error in
            
            guard let datas = data, error == nil else {
                
                return }
            
            do{
            
                let jsonResponse = try JSONSerialization.jsonObject(with: datas, options: .mutableContainers) as? NSDictionary ?? [:]
                
                let httpResponse = response as! HTTPURLResponse
                
                switch httpResponse.statusCode{
                                 
                case 200..<300: completion(.success(jsonResponse))
            
                    
                default:
                    completion(.failure("Something went wrong" as! Error))
                }
              
            
                
            }
            
            catch let error{
                completion(.failure("Json error" as! Error))
            }
            
        }.resume()
        
        
     
        
    }
}


