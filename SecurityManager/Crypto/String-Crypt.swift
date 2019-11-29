//
//  String-Crypt.swift
//  SecurityManager
//
//  Created by brave on 2019/11/28.
//  Copyright © 2019 brave. All rights reserved.
//

import Foundation

extension String {
    /// AES-CBC-IV 加密
    func aesCrypt(keyString: String, ivString: String) -> String {
        // 1.取前16位，不足补零
        let limitKey = keyString.appending("0000000000000000").prefix(16)
        if let indata = self.data(using: .utf8), let keyData = limitKey.data(using: .utf8), let ivData = ivString.data(using: .utf8) {
            let plainEnData = AESCrypt(inData: indata, keyData: keyData, ivData: ivData, operation: kCCEncrypt)
            return String(data: plainEnData, encoding: .utf8) ?? ""
        } else {
            return ""
        }
    }
    
    /// AES-CBC-IV 解密
    func aesDecrypt(keyString: String, ivString: String) -> String {
        // 1.取前16位，不足补零
        let limitKey = keyString.appending("0000000000000000").prefix(16)
        
        if let indata = self.data(using: .utf8), let keyData = limitKey.data(using: .utf8), let ivData = ivString.data(using: .utf8) {
            
            if let _ = Data(base64Encoded: indata) {
                let plainData = AESCrypt(inData: indata, keyData: keyData, ivData: ivData, operation: kCCDecrypt)
                return String(data: plainData, encoding: .utf8) ?? ""
            } else {
                return ""
            }

        } else {
            return ""
        }
    }
}
