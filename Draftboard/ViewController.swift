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
let Paper_Corner_Radius: CGFloat = 5
let Paper_Shadow: CGFloat = 1
let Paper_Size_Change_Animation_Duration: CGFloat = 0.8

class ViewController: UIViewController, PKCanvasViewDelegate, MenuDelegate {
    
    @IBOutlet weak var canvasView: CanvasView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var modeBtn: UIButton!
    @IBOutlet weak var modeBtnContainer: UIView!
    @IBOutlet weak var settingBtnContainer: UIView!
    @IBOutlet weak var modeBtnLeadingContstraint: NSLayoutConstraint!
    @IBOutlet weak var modeBtnArrowLeft: UIImageView!
    @IBOutlet weak var modeBtnArrowRight: UIImageView!
    @IBOutlet weak var settingLeadingConstraint: NSLayoutConstraint!
    let toolPicker = PKToolPicker()
    let dataModelController = DataModelController()
    let contentBG: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Paper_Corner_Radius
        view.backgroundColor = .systemBackground
        view.layer.shadowOffset = .init(width: Paper_Shadow, height: Paper_Shadow)
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
        
        settingBtnContainer.layer.cornerRadius = 18
        settingBtnContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
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
        canvasView.contentInset = .init(top: Paper_BG_Margin, left: Paper_BG_Margin, bottom: Paper_BG_Margin, right: Paper_BG_Margin)
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
        self.modeBtnLeadingContstraint.constant = isDrawingMode ? -36 : -12
        self.modeBtnArrowLeft.alpha = isDrawingMode ? 0:1;
        self.modeBtnArrowRight.alpha = isDrawingMode ? 1:0;
        self.settingLeadingConstraint.constant = isDrawingMode ? -self.settingBtnContainer.frame.width : -20
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
        updateContentSizeForDrawing(animated: true)
        self.dataModelController.saveDrawing(canvasView.drawing)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentSizeForDrawing()
    }
    
    /// Helper method to set a suitable content size for the canvas view.
    func updateContentSizeForDrawing(animated: Bool = false) {
        //MARK: todo - use closure to avoid overhead of non animated mode
        UIView.animate(withDuration: animated ? Paper_Size_Change_Animation_Duration : 0) {
            let canvasView = self.canvasView!
            let contentBG = self.contentBG
            // Update the content size of canvasView to match the drawing area.
            let drawing = canvasView.drawing
            let contentWidth = (max(canvasView.bounds.width, drawing.bounds.isNull ? 0 : drawing.bounds.maxX + Paper_Increase_Offset)
                                - canvasView.adjustedContentInset.left - canvasView.adjustedContentInset.right) * canvasView.zoomScale
            let contentHeight = (max(canvasView.bounds.height, drawing.bounds.isNull ? 0 : drawing.bounds.maxY + Paper_Increase_Offset)
                                 - canvasView.adjustedContentInset.top - canvasView.adjustedContentInset.bottom) * canvasView.zoomScale
            canvasView.contentSize = CGSize(width: contentWidth, height: contentHeight)
            // Update content background view to reflect content area
            contentBG.frame = CGRect.init(origin: .zero, size: .init(width: contentWidth, height: contentHeight))
            contentBG.layer.shadowOffset = .init(width: Paper_Shadow*canvasView.zoomScale, height: Paper_Shadow*canvasView.zoomScale)
            contentBG.layer.cornerRadius = Paper_Corner_Radius * canvasView.zoomScale
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue)
        if let menuTVC = segue.destination as? MenuTableViewController {
            menuTVC.delegate = self
        }
    }
}
