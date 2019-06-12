//
//  FileProtocol.swift
//  Offenbach
//
//  Created by Loïc GRIFFIE on 12/06/2019.
//  Copyright © 2019 Move Upwards. All rights reserved.
//

import Foundation

public protocol FileProcotol {
    /// The file's local url.
    var url: URL? { get }

    /// The file's data.
    var data: Data { get }

    /// Name of the file, including extension.
    var filename: String { get }

    /// Name of the file, including extension.
    var mimetype: String { get }

    /// Date of file.
    var date: Date { get }

    /// Save file to disk at the given URL.
    func save() throws

    init(data: Data, filename: String, mimetype: String, date: Date)
}

public extension FileProcotol {
    var documentsDirectoryUrl: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }

    func save() throws {
        guard let url = url else { throw ClientError.noUrl }

        try data.write(to: url, options: .atomic)
    }
}
