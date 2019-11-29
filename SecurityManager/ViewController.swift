//
//  ViewController.swift
//  SecurityManager
//
//  Created by brave on 2019/11/28.
//  Copyright © 2019 brave. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var privatedEnTextField: NSTextField!
    @IBOutlet weak var pinTextField: NSSecureTextField!
    @IBOutlet weak var privateTextField: NSTextField!
    @IBOutlet weak var sureButton: NSButton!
        
    let iv = "4e5Wa71fYoT7MFEX"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "BR去中心化钱包密钥管理工具"
        sureButton.isHighlighted = true
        privateTextField.isEditable = false
        
//        textDecrypt()
    }
    
    @IBAction func qrButtonAction(_ sender: Any) {
//        ProgressHUD.showTextWithStatus("敬请期待")
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        let response = panel.runModal()
        
        if response == .OK {
            debugPrint(panel.url)
            if let fileURL = panel.url {
                if let iconImage = NSImage(contentsOf: fileURL) {
                    print(recognizeQRCode(targetImage: iconImage) ?? "can not recoginize")
                    if let privatedEn = recognizeQRCode(targetImage: iconImage) {
                        privatedEnTextField.stringValue = privatedEn
                    } else {
                        privatedEnTextField.stringValue = "can not recoginize"
                        ProgressHUD.showErrorWithStatus("can not recoginize")
                    }
                }
             
            }
        }

    }
    
    @IBAction func sureButtonAction(_ sender: NSButton) {
        if isValidInput() == false {
            return
        }
        let privateEn = privatedEnTextField.stringValue
        let key = pinTextField.stringValue.appending("0000000000000000").prefix(16)
        
        let plainText = privateEn.aesDecrypt(keyString: String(key), ivString: iv)
        print(plainText)
        privateTextField.stringValue = plainText
        
        if privateTextField.stringValue.isEmpty {
            ProgressHUD.showErrorWithStatus("密文私钥和PIN码不匹配，解密失败")
        } else {
            ProgressHUD.showSuccessWithStatus("解密成功")
        }
    }
    
    @IBAction func copyButton(_ sender: Any) {

        if privateTextField.stringValue.isEmpty {
            ProgressHUD.showErrorWithStatus("复制失败，明文私钥为空")
        } else {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(privateTextField.stringValue, forType: NSPasteboard.PasteboardType.string)
            ProgressHUD.showSuccessWithStatus("复制成功")
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController {
    func textDecrypt() {
        let cryptedText = "yUCfovFBI82XTZbSV+B+fetH6vn+lIYTMRCK8uPiJG3AAoMsncucRb1ckheUDw/Sgx1zjZdZgzvvxfnuAxBneg=="
        let key = "1234560000000000"
        
        let plainText = cryptedText.aesDecrypt(keyString: key, ivString: iv)
        print(plainText)
    }
    
    func textQRReader() {
        let iconImage = NSImage(named: "qrImage")!
        print(recognizeQRCode(targetImage: iconImage) ?? "")
//        privatedEnTextField.stringValue = recognizeQRCode(targetImage: iconImage) ?? "can not recoginize"
    }
    
    func isValidInput() -> Bool {
        if privatedEnTextField.stringValue.isEmpty {
             ProgressHUD.showErrorWithStatus("密文私钥不能为空")
            return false
        }
        if pinTextField.stringValue.isEmpty {
            ProgressHUD.showErrorWithStatus("钱包PIN码不能为空")
            return false
        }
        
        return true
    }
    
    /// 识别二维码
    ///
    /// - Parameter targetImage: 目标图片
    /// - Returns: 二维码信息字符串
    func recognizeQRCode(targetImage: NSImage) -> String? {
        
        let imageData = targetImage.tiffRepresentation(using: .none, factor: 0)
        let ciImage = CIImage(data: imageData!)
        /*创建探测器 options 是字典key:
         CIDetectorAccuracy 精度
         CIDetectorTracking 轨迹
         CIDetectorMinFeatureSize 最小特征尺寸
         CIDetectorNumberOfAngles 角度**/
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: CIContext(), options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        
        let featers = detector?.features(in: ciImage!) as? [CIQRCodeFeature]
        return featers?.last?.messageString
    }
    
}
