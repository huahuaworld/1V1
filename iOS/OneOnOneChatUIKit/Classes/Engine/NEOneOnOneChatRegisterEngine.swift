// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NEChatUIKit
import NIMSDK

public class NEOneOnOneChatRegisterEngine: NSObject {
  private static let instance = NEOneOnOneChatRegisterEngine()
  /// 单例初始化
  /// - Returns: 单例对象
  public static func getInstance() -> NEOneOnOneChatRegisterEngine {
    // 自定义解析器注册
    NIMCustomObject.registerCustomDecoder(CustomAttachmentDecoder())
    IMKitClient.instance.repo.setShowReadStatus(true)
    /// 更多
    var index = -1
    for moreModel in NEChatUIKitClient.instance.moreAction {
      if moreModel.type == .file {
        index = NEChatUIKitClient.instance.moreAction.firstIndex(of: moreModel) ?? -1
        continue
      }

      if moreModel.type == .takePicture {
        moreModel.title = ne_localized("拍摄")
        moreModel.image = ne_chatUI_imageName(imageName: "more_camera_icon")
        continue
      }
      if moreModel.type == .location {
        moreModel.title = ne_localized("位置")
        moreModel.image = ne_chatUI_imageName(imageName: "more_location_icon")
        continue
      }
    }
    if index != -1 {
      NEChatUIKitClient.instance.moreAction.remove(at: index)
    }

    return instance
  }

  public func resgiterEngine() {
    // 初始化路由
    ChatRouter.register()
    /// 注册替换路由控制器
//           p2p
    Router.shared.register(PushP2pChatVCRouter) { param in
      print("param:\(param)")
      let nav = param["nav"] as? UINavigationController
      guard let session = param["session"] as? NIMSession else {
        return
      }
      let anchor = param["anchor"] as? NIMMessage
      let p2pChatVC = NEOneOnOneChatP2PViewController(session: session, anchor: anchor)
      p2pChatVC.hidesBottomBarWhenPushed = true
      for (i, vc) in (nav?.viewControllers ?? []).enumerated() {
        if vc.isMember(of: NEOneOnOneChatP2PViewController.self) {
          nav?.viewControllers[i] = p2pChatVC
          nav?.popToViewController(p2pChatVC, animated: true)
          return
        }
      }
      p2pChatVC.hidesBottomBarWhenPushed = true
      nav?.pushViewController(p2pChatVC, animated: true)

//      p2pChatVC.thanksForGiven = { data in
//        nav?.popViewController(animated: false)
//        let session = NIMSession(data, type: .P2P)
//        Router.shared.use(
//          PushP2pChatVCRouter,
//          parameters: ["nav": nav as Any, "session": session as Any],
//          closure: nil
//        )
//      }
    }
  }
}
