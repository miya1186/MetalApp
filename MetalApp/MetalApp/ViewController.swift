//
//  ViewController.swift
//  MetalApp
//
//  Created by miyazawaryohei on 2020/09/21.
//

import UIKit
import MetalKit
import Metal

class ViewController: UIViewController, MTKViewDelegate {
    
    private let device = MTLCreateSystemDefaultDevice()!
    private var commandQueue: MTLCommandQueue!
    private var texture: MTLTexture!
    @IBOutlet var metalView: MTKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commandQueue = device.makeCommandQueue()
        metalView.device = device
        metalView.delegate = self
        
        let textureLoader = MTKTextureLoader(device: device)
        texture = try! textureLoader.newTexture(
            name: "buildings",
            scaleFactor: view.contentScaleFactor,
            bundle: nil)
        metalView.colorPixelFormat = texture.pixelFormat
        metalView.enableSetNeedsDisplay = true
        metalView.framebufferOnly = false
        // ビューの更新依頼 → draw(in:)が呼ばれる
        metalView.setNeedsDisplay()
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("\(self.classForCoder)/" + #function)
    }
    //MTKViewへの描画の依頼があるたびに呼ばれるメソッド
    func draw(in view: MTKView) {
        // ドローアブルを取得
        let drawable = view.currentDrawable!
        // コマンドバッファを作成
        let commandBuffer = commandQueue.makeCommandBuffer()!
        // コピーするサイズを計算
        let w = min(texture.width, drawable.texture.width)
        let h = min(texture.height, drawable.texture.height)
        // MTLBlitCommandEncoder を作成
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        // コピーコマンドをエンコード
        blitEncoder.copy(from: texture,
                         sourceSlice: 0,
                         sourceLevel: 0,
                         sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                         sourceSize: MTLSizeMake(w, h, texture.depth),
                         to:drawable.texture,
                         destinationSlice: 0,
                         destinationLevel: 0,
                         destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        // エンコード完了
        blitEncoder.endEncoding()
        // 表示するドローアブルを登録
        commandBuffer.present(drawable)
        commandBuffer.present(drawable)
        // コマンドバッファをコミット(→エンキュー)
        commandBuffer.commit()
    }
    
    
}


