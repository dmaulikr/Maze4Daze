//
//  PrintManager.swift
//  Maze
//
//  Created by Evan Bernstein on 11/21/16.
//  Copyright © 2016 Evan Bernstein. All rights reserved.
//

import Foundation
import SwiftyRSA
import Alamofire

enum KeyError: Error {
    case NoKeyFile
}

enum FileError: Error {
    case CouldNotLocateDocumentsDirectory
    case NoSTLFileSaved
}

enum SessionError: Error {
    case UnverifiedSessionKey
    case SessionKeyNoLongerValid
}

class PrintManager {
    static let sharedInstance = PrintManager()
    
    private let privateKeyFilename = "maze_rsa"
    private let appid = "io.evanb.amazeing"
    private let appversion = "1.0"
    
    static private let baseURL = "http://192.168.0.139/"
    static private let authRoute = baseURL + "apps/auth"
    
    private let currentSTLFilename = "aMAZEing-maze-file.stl"
    
    var sessionKey: String?
    var validUntil: Date?
    
    var verified = false
    
    typealias SuccessCompletion = (Bool) -> ()
    
    func storeSTLFile(stlText: String) throws {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(currentSTLFilename)
            try stlText.write(to: path, atomically: false, encoding: String.Encoding.utf8)
        } else {
            throw FileError.CouldNotLocateDocumentsDirectory
        }
    }
    
    func storeSTLFile(stlData: Data) throws {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(currentSTLFilename)
            try stlData.write(to: path)
        } else {
            throw FileError.CouldNotLocateDocumentsDirectory
        }
    }
    
    func clearSTLFile() throws {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(currentSTLFilename)
            try FileManager.default.removeItem(at: path)
        } else {
            throw FileError.CouldNotLocateDocumentsDirectory
        }
    }
    
    func doesFileExistInDocDir(filename: String) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let fileManager = FileManager.default
        if let filePath = url.appendingPathComponent(filename)?.path {
            return fileManager.fileExists(atPath: filePath)
        }
        return false
    }
    
    func uploadSTLFile(completion: SuccessCompletion? = nil) throws {
        guard verified else { throw SessionError.UnverifiedSessionKey }
        if let sessionKey = sessionKey, let validUntil = validUntil, validUntil.compare(Date()) != ComparisonResult.orderedAscending {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let filePath = dir.appendingPathComponent(currentSTLFilename)
//              guard FileManager.default.fileExists(atPath: filePath.absoluteString) else { throw FileError.NoSTLFileSaved }
                guard doesFileExistInDocDir(filename: currentSTLFilename) else { throw FileError.NoSTLFileSaved }
                let uploadPath = PrintManager.baseURL + "api/files/local"
                let headers = ["X-Api-Key": sessionKey]
                let uploadRequest = try URLRequest(url: uploadPath, method: .post, headers: headers)
                
                Alamofire.upload(
                    multipartFormData: { multipartFormData in
                        multipartFormData.append(filePath, withName: "file")
                },
                    with: uploadRequest,
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                debugPrint(response)
                                if let json = response.result.value {
                                    print(json)
                                }
                                completion?(true)
                            }
                        case .failure(let encodingError):
                            print("ENCODING FAILURE")
                            print(encodingError)
                            completion?(false)
                        }
                }
                )
            } else {
                throw FileError.CouldNotLocateDocumentsDirectory
            }
        } else {
            throw SessionError.SessionKeyNoLongerValid
        }
    }
    
    func printUploadedSTLFile(completion: SuccessCompletion? = nil) throws {
        if let sessionKey = sessionKey, let validUntil = validUntil, validUntil.compare(Date()) != ComparisonResult.orderedAscending {
            let parameters: [String: Any] = ["command": "slice", "print": true]
            let headers = ["X-Api-Key": sessionKey]
            let requestPath = PrintManager.baseURL + "api/files/local/" + currentSTLFilename
            Alamofire.request(requestPath, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON {
                (response:DataResponse<Any>) in
                switch(response.result) {
                case .success(_):
                    if let value = response.result.value{
                        print(value)
                    }
                    completion?(true)
                    break
                case .failure(_):
                    print(response.result.error)
                    completion?(false)
                    break
                }
            }
        } else {
            throw SessionError.SessionKeyNoLongerValid
        }
    }
    
    func useAPIKey() {
        let APIKey = "C6F8C3A2742747C0916BD854DF09B0A2"
        sessionKey = APIKey
        verified = true
        validUntil = Date(timeIntervalSinceNow: 60 * 60 * 24 * 7 * 4)
    }
    
    func readPrivateKey(filename: String) throws -> String {
        if let path = Bundle.main.path(forResource: filename, ofType: "privKey") {
            return try String(contentsOfFile: path, encoding: String.Encoding.utf8)
        } else {
            throw KeyError.NoKeyFile
        }
    }
    
    func signWithPrivateKey(appId: String, version: String, unverifiedKey: String) -> String? {
        do {
            let encryptor = SwiftyRSA()
            let privateKeyText = try readPrivateKey(filename: privateKeyFilename)
            let privateKey = try encryptor.privateKeyFromPEMString(privateKeyText)
            let clearText = appId + ":" + version + ":" + unverifiedKey
            
            let signature = try encryptor.signString(clearText, privateKey: privateKey, digestMethod: SwiftyRSA.DigestType.SHA1)
            
            return signature
        } catch let error {
            print("Error signing: ", error)
            
            return nil
        }
    }
    
    func requestTemporarySessionKey(completion: @escaping (Bool) -> ()) {
        Alamofire.request(PrintManager.authRoute).responseJSON { response in
            if let json = response.result.value as? Dictionary<String, Any> {
                if let sessionKey = json["unverifiedKey"] as? String, let validUntil = json["validUntil"] as? Double {
                    self.sessionKey = sessionKey
                    self.validUntil = Date(timeIntervalSince1970: validUntil) // Is this how the date is encoded?
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func verifyTemporarySessionKey(completion: @escaping (Bool) -> ()) {
        if let sessionKey = sessionKey, let signature = signWithPrivateKey(appId: appid, version: appversion, unverifiedKey: sessionKey) {
            let parameters = ["appid": appid, "appversion": appversion, "key": sessionKey, "_sig": signature]
            Alamofire.request(PrintManager.authRoute, method: .post, parameters: parameters).responseString {
                response in
                print(response)
            }/*.responseJSON { response in
                if let json = response.result.value as? Dictionary<String, Any> {
                    if let sessionKey = json["key"] as? String, let validUntil = json["validUntil"] as? Double {
                        self.sessionKey = sessionKey
                        self.validUntil = Date(timeIntervalSince1970: validUntil) // Is this how the date is encoded?
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            }*/
        } else {
            completion(false)
        }
    }
    
    func performHandshake(completion: @escaping () -> ()) {
        requestTemporarySessionKey() { success in
            guard success else { print("Failed requesting temporary session key"); completion(); return }
            self.verifyTemporarySessionKey() { success in
                guard success else { print("Failed verifying temporary session key"); completion(); return }
                self.verified = true
                completion()
            }
        }
    }
}
