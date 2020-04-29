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

    private var config: ConfigProtocol = Config(env: .develop)
    private var token: String?
    private var apiKey: String?

    // MARK: Public functions

    public init() { }

    public var baseUrl: String {
        return config.baseURL
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
        Session(interceptor: self,
                redirectHandler: redirectionHandler(),
                cachedResponseHandler: ResponseCacher(behavior: .cache))
    }()

    open func redirectionHandler() -> Redirector {
        return Redirector(behavior: .follow)
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

        config.headers?.forEach { urlRequest.headers.add($0) }

        completion(.success(urlRequest))
    }
}

extension Client {
    @discardableResult
    public func post<T: Decodable>(action: String,
                                   parameters: Parameters = [:],
                                   encoder: ParameterEncoding = JSONEncoding.default,
                                   completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest {
        return manager.request("\(config.baseURL)/\(action)", method: .post, parameters: parameters, encoding: encoder)
            .validate()
            .responseDecodable(of: T.self, decoder: config.decoder) { response in
                if case .failure(let error) = response.result {
                    print("[MAPPING]", error)
                }
                completion(response.result)
        }

    }

    @discardableResult
    public func get<T: Decodable>(action: String,
                                  parameters: Parameters = [:],
                                  completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest {
        return AF.request("\(config.baseURL)/\(action)", method: .get, parameters: parameters)
            .validate()
            .responseDecodable(of: T.self, decoder: config.decoder) { response in
                if case .failure(let error) = response.result {
                    print("[MAPPING]", error)
                }
                completion(response.result)
        }
    }

    @discardableResult
    public func list<T: Decodable>(action: String,
                                   parameters: Parameters = [:],
                                   completion: @escaping (Result<[T], AFError>) -> Void) -> DataRequest {
        return manager.request("\(config.baseURL)/\(action)", method: .get, parameters: parameters)
            .validate()
            .responseDecodable(of: [T].self, decoder: config.decoder) { response in
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
                                    completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest {
        return manager.request("\(config.baseURL)/\(action)", method: .patch, parameters: parameters, encoding: encoder)
            .validate()
            .responseDecodable(of: T.self, decoder: config.decoder) { response in
                if case .failure(let error) = response.result {
                    print("[MAPPING]", error)
                }
                completion(response.result)
        }
    }

    @discardableResult
    public func put<T: Decodable>(action: String,
                                  parameters: Parameters = [:],
                                  encoder: ParameterEncoding = JSONEncoding.default,
                                  completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest {
        return manager.request("\(config.baseURL)/\(action)", method: .put, parameters: parameters, encoding: encoder)
            .validate()
            .responseDecodable(of: T.self, decoder: config.decoder) { response in
                if case .failure(let error) = response.result {
                    print("[MAPPING]", error)
                }
                completion(response.result)
        }
    }

    @discardableResult
    public func delete<T: Decodable>(action: String,
                                     parameters: Parameters = [:],
                                     encoder: ParameterEncoding = JSONEncoding.default,
                                     completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest {
        return manager.request("\(config.baseURL)/\(action)",
            method: .delete,
            parameters: parameters,
            encoding: encoder)
            .validate()
            .responseDecodable(of: T.self, decoder: config.decoder) { response in
                if case .failure(let error) = response.result {
                    print("[MAPPING]", error)
                }
                completion(response.result)
        }
    }

    @discardableResult
    public func download(url: URL, completion: @escaping (Data?) -> Void) -> DownloadRequest {
        return manager.download(url).responseData { response in
            if case .failure(let error) = response.result {
                print("[DOWNLOAD]", error)
            }
            completion(response.value)
        }
    }

    @discardableResult
    public func upload<T: Decodable>(action: String,
                                     parameters: Parameters = [:],
                                     files: [MultiPartProtocol],
                                     progress: @escaping (_ progress: Double) -> Void,
                                     completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest {
        return manager.upload(multipartFormData: { [weak self] multiPart in
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
            .uploadProgress { value in
                progress(value.fractionCompleted)
        }
        .responseDecodable(of: T.self, decoder: config.decoder) { response in
            if case .failure(let error) = response.result {
                print("[MAPPING]", error)
            }
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
