//
//  CanvasView.swift
//  InterviewWhiteboard
//
//  Created by Hans Wang on 1/17/21.
//

import UIKit
import PencilKit

class CanvasView: PKCanvasView {
    
    var isDrawingMode: Bool {
        set{
            self.drawingGestureRecognizer.isEnabled = newValue
            if newValue {
                self.becomeFirstResponder()
            } else{
                self.resignFirstResponder()
            }
        }
        get{self.drawingGestureRecognizer.isEnabled}
    }
    
    let glowView: UIView = {
        let view = UIView(frame: .init(origin: .zero, size: .init(width: 16, height: 16)))
        view.backgroundColor = .systemYellow
        view.layer.cornerRadius = 8
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = .zero
        view.layer.shadowColor = UIColor.systemYellow.cgColor
        view.layer.shadowOpacity = 1
        view.alpha = 0.0
        return view
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addSubview(glowView)
    }
    
    func showGlowAt(_ center: CGPoint) {
        if self.isDrawingMode { return }
        self.glowView.center = center
        self.glowView.alpha = 0.8
        UIView.animate(withDuration: 0.5) {
            self.glowView.alpha = 0
        }
    }
    
    // MARK: Touch Handling

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { (touch) in
            if touch.type == .pencil {
                showGlowAt(touch.location(in: self))
            }
        }
    }
    
    override func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {
        super.toolPickerSelectedToolDidChange(toolPicker)
        print(toolPicker.selectedTool)
        // todo - fix bugs related to lasso tool
    }
}
