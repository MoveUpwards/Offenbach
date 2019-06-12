//
//  Client.swift
//  Offenbach-iOS
//
//  Created by Loïc GRIFFIE on 12/06/2019.
//  Copyright © 2019 Move Upwards. All rights reserved.
//

import Alamofire
import Foundation

public typealias Headers = [String: String]?

open class Client: ClientProtocol {
    // MARK: Public functions

    @discardableResult
    public func set(config: ConfigProtocol) -> ClientProtocol {
        self.config = config

        return self
    }

    @discardableResult
    public func set(token: TokenProtocol?) -> ClientProtocol {
        var headers = Config.headers
        if let apiKey = token?.apiKey {
            headers?["apikey"] = apiKey
        } else if let token = token?.jwt {
            headers?["Authorization"] = "Bearer \(token)"
        }

        configureManager(with: headers)
        backgroundConfigureManager(with: headers)

        return self
    }

    @discardableResult
    public func post<T: Decodable>(action: String,
                                   parameters: Parameters = [:],
                                   encoder: ParameterEncoding = JSONEncoding.default,
                                   completion: @escaping (Result<T, Error>) -> Void) -> DataRequest {
        return manager.request("\(config.baseURL)/\(action)", method: .post, parameters: parameters, encoding: encoder)
            .validate()
            .responseDecodable(decoder: config.decoder) { (response: DataResponse<T>) in
                if case .failure(let error) = response.result {
                    print("[MAPPING]", error)
                }
                completion(response.result)
        }
    }

    @discardableResult
    public func get<T: Decodable>(action: String,
                                  parameters: Parameters = [:],
                                  completion: @escaping (Result<T, Error>) -> Void) -> DataRequest {
        return manager.request("\(config.baseURL)/\(action)", method: .get, parameters: parameters)
            .validate()
            .responseDecodable(decoder: config.decoder) { (response: DataResponse<T>) in
                if case .failure(let error) = response.result {
                    print("[MAPPING]", error)
                }
                completion(response.result)
        }
    }

    @discardableResult
    public func list<T: Decodable>(action: String,
                                   parameters: Parameters = [:],
                                   completion: @escaping (Result<[T], Error>) -> Void) -> DataRequest {
        return manager.request("\(config.baseURL)/\(action)", method: .get, parameters: parameters)
            .validate()
            .responseDecodable(decoder: config.decoder) { (response: DataResponse<[T]>) in
                if case .failure(let error) = response.result {
                    print("[MAPPING]", error)
                }
                completion(response.result)
        }
    }

    @discardableResult
    public func patch<T: Decodable>(action: String,
                                    parameters: Parameters = [:],
                                    encoder: ParameterEncoding = JSONEncoding.default,
                                    completion: @escaping (Result<T, Error>) -> Void) -> DataRequest {
        return manager.request("\(config.baseURL)/\(action)", method: .patch, parameters: parameters, encoding: encoder)
            .validate()
            .responseDecodable(decoder: config.decoder) { (response: DataResponse<T>) in
                if case .failure(let error) = response.result {
                    print("[MAPPING]", error)
                }
                completion(response.result)
        }
    }

    @discardableResult
    public func upload<T: Decodable>(action: String,
                                     parameters: Parameters = [:],
                                     file: FileProcotol,
                                     progress: @escaping (_ progress: Double) -> Void,
                                     completion: @escaping (Result<T, Error>) -> Void) -> DataRequest {
        return backgroundManager
            .upload(multipartFormData: { [weak self] multiPart in
                guard let url = file.url else {
                    return
                }

                multiPart.append(url, withName: "file", fileName: file.filename, mimeType: file.mimetype)
                self?.generateMultipart(multiPart, with: parameters)
                }, to: "\(config.baseURL)/\(action)")
            .validate()
            .uploadProgress { value in
                progress(value.fractionCompleted)
            }
            .responseDecodable(decoder: config.decoder) { (response: DataResponse<T>) in
                if case .failure(let error) = response.result {
                    print("[MAPPING]", error)
                }
                completion(response.result)
        }
    }

    // MARK: - Private properties

    private(set) var manager = Alamofire.Session.default
    private(set) var backgroundManager = Alamofire.Session.default

    private var config: ConfigProtocol = Config(baseURL: "http://localhost:8080")

    // MARK: Private functions

    required public init() {
        configureManager(with: Config.headers)
        backgroundConfigureManager(with: Config.headers)
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

    private func configureManager(with headers: [String: String]?) {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache?.removeAllCachedResponses()

        manager = Alamofire.Session(configuration: configuration,
                                    delegate: Alamofire.SessionDelegate(),
                                    redirectHandler: redirectionHandler(with: headers))
    }

    private func backgroundConfigureManager(with headers: [String: String]?) {
        let identifier = "com.offenbach.background.transfert.\(UUID().uuidString)"
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: identifier)
        backgroundConfiguration.httpAdditionalHeaders = headers
        backgroundConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        backgroundConfiguration.urlCache?.removeAllCachedResponses()

        if #available(iOS 11.0, *) {
            backgroundConfiguration.waitsForConnectivity = true
        }

        backgroundManager = Alamofire.Session(configuration: backgroundConfiguration,
                                              delegate: Alamofire.SessionDelegate(),
                                              redirectHandler: redirectionHandler(with: headers))
    }

    private func redirectionHandler(with headers: Headers) -> Redirector {
        let redirect = Redirector(behavior: .modify({ _, request, _ -> URLRequest? in
            var finalRequest = request
            finalRequest.allHTTPHeaderFields = headers

            return finalRequest
        }))

        return redirect
    }
}
