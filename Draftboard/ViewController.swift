//
//  ViewController.swift
//  Draftboard
//
//  Created by Hans Wang on 1/16/21.
//

import UIKit
import PencilKit

let Paper_Increase_Offset: CGFloat = 500
let Paper_BG_Margin: CGFloat = 4

class ViewController: UIViewController, PKCanvasViewDelegate, MenuDelegate {
    
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var modeBtn: UIButton!
    @IBOutlet weak var modeBtnContainer: UIView!
    @IBOutlet weak var settingBtnContainer: UIView!
    @IBOutlet weak var modeBtnLeadingContstraint: NSLayoutConstraint!
    @IBOutlet weak var settingTrailingConstraint: NSLayoutConstraint!
    
    let toolPicker = PKToolPicker()
    let dataModelController = DataModelController()
    let contentBG: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.backgroundColor = .systemBackground
        view.layer.shadowOffset = .init(width: 1, height: 1)
        view.layer.shadowOpacity = 0.1
        return view
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configSubview()
        
        toolPicker.setVisible(true, forFirstResponder: self.canvasView)
        toolPicker.addObserver(canvasView)
        
        loadingIndicator.isHidden = false
        dataModelController.loadDataModel { drawing in
            self.loadingIndicator.isHidden = true
            self.canvasView.drawing = drawing
            self.canvasView.becomeFirstResponder()
        }
    }
    
    func configSubview() {
        modeBtnContainer.layer.cornerRadius = 20
        modeBtnContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        modeBtnContainer.layer.shadowRadius = 2
        modeBtnContainer.layer.shadowOffset = .init(width: 1, height: 1)
        modeBtnContainer.layer.shadowOpacity = 0.1
        
        updateBtns(canvasView.isDrawingMode)
        
        settingBtnContainer.layer.cornerRadius = 16
        settingBtnContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        settingBtnContainer.layer.shadowRadius = 2
        settingBtnContainer.layer.shadowOffset = .init(width: 1, height: 1)
        settingBtnContainer.layer.shadowOpacity = 0.1
        
        canvasView.delegate = self
        canvasView.backgroundColor = .clear
        canvasView.alwaysBounceVertical = true
        canvasView.alwaysBounceHorizontal = true
        canvasView.maximumZoomScale = 3
        canvasView.bouncesZoom = true
        canvasView.insertSubview(contentBG, at: 0)
        contentBG.frame = CGRect.init(origin: .zero, size: canvasView.contentSize)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateContentSizeForDrawing()
    }
    
    @IBAction func toggleMode(_ sender: Any) {
        let isDrawingMode = !self.canvasView.isDrawingMode
        self.canvasView.isDrawingMode = isDrawingMode
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {self.updateBtns(isDrawingMode)},
                       completion: nil)
    }
    
    func updateBtns(_ isDrawingMode: Bool) {
        let config = UIImage.SymbolConfiguration.init(scale: .large)
        let img =  UIImage(systemName: isDrawingMode ? "pencil.circle.fill" :"pencil.circle", withConfiguration: config)
        self.modeBtn.setImage(img, for: .normal)
        self.modeBtnLeadingContstraint.constant = isDrawingMode ? -20 : -30
        self.settingTrailingConstraint.constant = isDrawingMode ? -self.settingBtnContainer.frame.width : -20
        self.view.layoutIfNeeded()
    }
    
    func cleanBoard() {
        UIView.animate(withDuration: 0.5) {
            self.canvasView.alpha = 0
        } completion: { _ in
            self.canvasView.drawing = PKDrawing()
            UIView.animate(withDuration: 0.5) {
                self.canvasView.alpha = 1
            } completion: { _ in
                // enter edit mode after cleaning
                self.toggleMode(self)
            }
        }
    }
    
    // MARK: Canvas View Delegate
    
    /// Delegate method: Note that the drawing has changed.
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSizeForDrawing()
        self.dataModelController.saveDrawing(canvasView.drawing)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentSizeForDrawing()
    }
    
    /// Helper method to set a suitable content size for the canvas view.
    func updateContentSizeForDrawing() {
        // Update the content size to match the drawing.
        let drawing = canvasView.drawing
        let contentHeight: CGFloat
        let contentWidth: CGFloat
        // Adjust the content size to always be bigger than the drawing height.
        if !drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + Paper_Increase_Offset) * canvasView.zoomScale) - canvasView.adjustedContentInset.top - canvasView.adjustedContentInset.bottom
        } else {
            contentHeight = canvasView.bounds.height - canvasView.adjustedContentInset.top - canvasView.adjustedContentInset.bottom
        }
        // Adjust the content size to always be bigger than the drawing width.
        if !drawing.bounds.isNull {
            contentWidth = max(canvasView.bounds.width, (drawing.bounds.maxX + Paper_Increase_Offset) * canvasView.zoomScale)
        } else {
            contentWidth = canvasView.bounds.width
        }
        canvasView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        contentBG.frame = CGRect.init(origin: .init(x: Paper_BG_Margin*canvasView.zoomScale, y: Paper_BG_Margin*canvasView.zoomScale), size: .init(width: contentWidth-Paper_BG_Margin*2*canvasView.zoomScale, height: contentHeight))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue)
        if let menuTVC = segue.destination as? MenuTableViewController {
            menuTVC.delegate = self
        }
    }
}
