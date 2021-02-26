//
//  Client.swift
//  Offenbach-iOS
//
//  Created by Loïc GRIFFIE on 12/06/2019.
//  Copyright © 2019 Move Upwards. All rights reserved.
//

import Alamofire
import Foundation

open class Client: RequestInterceptor {
    
    // MARK: - Private properties
    
    public private(set) var config: ConfigProtocol = Config(env: .develop)
    
    private var token: String?
    private var apiKey: String?
    
    // MARK: Public functions
    
    public init() { }
    
    public var baseUrl: String {
        config.baseURL
    }
    
    @discardableResult
    public func set(config: ConfigProtocol) -> Self {
        self.config = config
        
        return self
    }
    
    @discardableResult
    public func set(jwt: TokenProtocol?) -> Self {
        self.token = jwt?.token
        
        return self
    }
    
    @discardableResult
    public func set(apiKey: TokenProtocol?) -> Self {
        self.apiKey = apiKey?.token
        
        return self
    }
    
    open lazy var manager: Session = {
        Session(configuration: configuration,
                interceptor: self,
                redirectHandler: redirectionHandler,
                cachedResponseHandler: ResponseCacher(behavior: .cache))
    }()

    open var configuration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        if #available(iOS 11.0, *) { config.waitsForConnectivity = true }
        config.timeoutIntervalForResource = 300

        return config
    }
    
    open var redirectionHandler: Redirector {
        Redirector(behavior: .follow)
    }
    
    open func adapt(_ urlRequest: URLRequest,
                    for session: Session,
                    completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        if let token = token {
            urlRequest.headers.add(.authorization(bearerToken: token))
        }
        
        if let key = apiKey {
            urlRequest.headers.add(HTTPHeader(name: "apikey", value: key))
        }
        
        config.headers.forEach { urlRequest.headers.add($0) }
        
        completion(.success(urlRequest))
    }
    
    private func request<T: Decodable, U: Encodable>(for action: String,
                                                     method: HTTPMethod,
                                                     parameters: U? = nil,
                                                     encoder: ParameterEncoder,
                                                     completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest? {
        do {
            var req = URLRequest(url: try "\(config.baseURL)/\(action)".asURL())
            req.method = method
            req = try encoder.encode(parameters, into: req)
            return execute(request: req, completion: completion)
        } catch let error {
            completion(.failure(error.asAFError(orFailWith: "unknown")))
        }
        
        return nil
    }
    
    @discardableResult
    open func execute<T: Decodable>(request: URLRequestConvertible,
                                    completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest {
        manager.request(request)
            .validate()
            .responseDecodable(of: T.self, decoder: config.decoder) { response in
                completion(response.result)
        }
    }

    @discardableResult
    open func execute<T: Decodable>(request: URLRequestConvertible,
                                    completion: @escaping (Result<[T], AFError>) -> Void) -> DataRequest {
        manager.request(request)
            .validate()
            .responseDecodable(of: [T].self, decoder: config.decoder) { response in
                completion(response.result)
        }
    }
}

extension Client {
    @discardableResult
    public func list<T: Decodable>(action: String,
                                   parameters: [String: String]? = nil,
                                   encoder: ParameterEncoder = URLEncodedFormParameterEncoder.default,
                                   completion: @escaping (Result<[T], AFError>) -> Void) -> DataRequest? {
        do {
            var req = URLRequest(url: try "\(config.baseURL)/\(action)".asURL())
            req.method = .get
            req = try encoder.encode(parameters, into: req)
            return execute(request: req, completion: completion)
        } catch let error {
            completion(.failure(error.asAFError(orFailWith: "unknown")))
        }
        
        return nil
    }
    
    @discardableResult
    public func get<T: Decodable>(action: String,
                                  parameters: [String: String]? = nil,
                                  encoder: ParameterEncoder = URLEncodedFormParameterEncoder.default,
                                  completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest? {
        request(for: action, method: .get, parameters: parameters, encoder: encoder, completion: completion)
    }
    
    @discardableResult
    public func post<T: Decodable, U: Encodable>(action: String,
                                                 parameters: U,
                                                 encoder: ParameterEncoder = JSONParameterEncoder.default,
                                                 completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest? {
        request(for: action, method: .post, parameters: parameters, encoder: encoder, completion: completion)
    }
    
    @discardableResult
    public func patch<T: Decodable, U: Encodable>(action: String,
                                                  parameters: U,
                                                  encoder: ParameterEncoder = JSONParameterEncoder.default,
                                                  completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest? {
        request(for: action, method: .patch, parameters: parameters, encoder: encoder, completion: completion)
    }
    
    @discardableResult
    public func put<T: Decodable, U: Encodable>(action: String,
                                                parameters: U,
                                                encoder: ParameterEncoder = JSONParameterEncoder.default,
                                                completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest? {
        request(for: action, method: .put, parameters: parameters, encoder: encoder, completion: completion)
    }
    
    @discardableResult
    public func delete<T: Decodable>(action: String,
                                     parameters: [String: String]? = nil,
                                     encoder: ParameterEncoder = URLEncodedFormParameterEncoder.default,
                                     completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest? {
        request(for: action, method: .delete, parameters: parameters, encoder: encoder, completion: completion)
    }
    
    @discardableResult
    public func download(url: URL, completion: @escaping (Data?) -> Void) -> DownloadRequest {
        manager.download(url).responseData { response in
            completion(response.value)
        }
    }
    
    @discardableResult
    public func upload<T: Decodable>(action: String,
                                     parameters: Parameters = [:],
                                     files: [MultiPartProtocol],
                                     progress: @escaping (_ progress: Double) -> Void,
                                     completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest {
        manager.upload(multipartFormData: { [weak self] multiPart in
            files.forEach { file in
                guard let url = file.content.url else { return }
                
                multiPart.append(url,
                                 withName: file.name,
                                 fileName: file.content.filename,
                                 mimeType: file.content.mimetype)
            }
                self?.generateMultipart(multiPart, with: parameters)
            }, to: "\(config.baseURL)/\(action)")
            .validate()
            .uploadProgress { value in progress(value.fractionCompleted) }
            .responseDecodable(of: T.self, decoder: config.decoder) { response in
                completion(response.result)
            }
    }
    
    @discardableResult
    private func generateMultipart(_ multiPart: MultipartFormData, with params: Parameters) -> MultipartFormData {
        for (key, value) in params {
            if let temp = value as? String, let data = temp.data(using: .utf8) {
                multiPart.append(data, withName: key)
            }
            if let temp = value as? Int, let data = "\(temp)".data(using: .utf8) {
                multiPart.append(data, withName: key)
            }
            if let temp = value as? NSArray {
                temp.forEach({ element in
                    let keyObj = key + "[]"
                    if let string = element as? String, let data = string.data(using: .utf8) {
                        multiPart.append(data, withName: keyObj)
                    } else
                        if let num = element as? Int, let data = "\(num)".data(using: .utf8) {
                            multiPart.append(data, withName: keyObj)
                    }
                })
            }
        }
        
        return multiPart
    }
}
