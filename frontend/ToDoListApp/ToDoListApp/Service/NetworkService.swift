//
//  NetworkService.swift
//  ToDoListApp
//
//  Created by 이다훈 on 2021/04/06.
//

import Foundation

class NetworkService {
    
    enum NetworkError : Error {
        case invalidData
        case nilData
        case nilResponse
        case badResponse
    }
    
    enum apiList : String {
        case none = ""
        case readHistory = "api/histories"
    }
    
    private let session : URLSessionProtocol
    private let urlString = "http://54.180.218.17:8080/"
    
    init(session : URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    private func decode<T:Codable> (form : T.Type, data: Data?) -> Result<T,NetworkError> {
        guard let data = data else {
            return .failure(.nilData)
        }
        
        let decoder = try? JSONDecoder().decode(T.self, from: data)
        guard let returnData = decoder else {
            return .failure(.invalidData)
        }
        return .success(returnData)
    }
    
    func getRequest<T:Codable> (needs dataSet : T.Type, api : apiList, closure : @escaping (Result<T,NetworkError>) -> Void) {
        guard let url = URL.init(string: self.urlString + api.rawValue) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        session.dataTask(with: request, completionHandler: {(data,response,error) in
            
            let result = self.decode(form : T.self, data: data)
            
            closure(result)
        }).resume()
    }
    
    func postRequest<T:Codable> (input : T, post type : String, closure : @escaping (Result<Int,NetworkError>) -> Void) {
        
        let optionalURL = URL.init(string: urlString + type)
        guard let url = optionalURL else {
            return
        }
        
        let sendData = try? JSONEncoder().encode(input)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = sendData
        
        session.dataTask(with: request, completionHandler: {(data,response,error) in
            
            let result = self.checkStatus(with: response)
            closure(result)
        }).resume()
    }
    
    private func checkStatus(with response : URLResponse?) -> Result<Int,NetworkError> {
        
        guard let response = response as? HTTPURLResponse else {
            return .failure(.nilResponse)
        }
        
        if response.statusCode != 200 {
            return .failure(.badResponse)
        }
        
        return .success(response.statusCode)
    }
}