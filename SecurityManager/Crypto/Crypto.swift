//
//  Crypto.swift
//  SwiftyEOS
//
//  Created by croath on 2018/5/14.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Foundation
import Security

/*
 let message     = "base58 or base64"
 let messageData = message.data(using:String.Encoding.utf8)!
 let keyData     = "16BytesLengthKey".data(using:String.Encoding.utf8)!
 let ivData      = "A-16-Byte-String".data(using:String.Encoding.utf8)!
 
 let decryptedData = testCrypt(inData:messageData, keyData:keyData, ivData:ivData, operation:kCCEncrypt)
 var decrypted     = String(data:decryptedData, encoding:String.Encoding.utf8)
 print(decrypted)
 */

func AESCrypt(inData:Data, keyData:Data, ivData:Data, operation:Int) -> Data {
    var data : Data
    if operation == kCCDecrypt {
        data = Data(base64Encoded: inData)!
    } else {
        data = inData
    }
    
    let cryptLength  = size_t(data.count + kCCBlockSizeAES128)
    var cryptData = Data(count:cryptLength)
    
    let keyLength = size_t(kCCKeySizeAES128)
    let options   = CCOptions(kCCOptionPKCS7Padding)
    
    
    var numBytesEncrypted :size_t = 0
    
    let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
        data.withUnsafeBytes {dataBytes in
            ivData.withUnsafeBytes {ivBytes in
                keyData.withUnsafeBytes {keyBytes in
                    CCCrypt(CCOperation(operation),
                            CCAlgorithm(kCCAlgorithmAES),
                            options,
                            keyBytes, keyLength,
                            ivBytes,
                            dataBytes, data.count,
                            cryptBytes, cryptLength,
                            &numBytesEncrypted)
                }
            }
        }
    }
    
    if UInt32(cryptStatus) == UInt32(kCCSuccess) {
        cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
        
    } else {
        print("Error: \(cryptStatus)")
    }
    
    if operation == kCCDecrypt {
        return cryptData
    } else {
        return cryptData.base64EncodedData()
    }
}
