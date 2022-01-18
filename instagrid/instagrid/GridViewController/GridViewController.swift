//
//  ViewController.swift
//  instagrid
//
//  Created by Florian Fourcade on 22/12/2021.
//

import UIKit

class GridViewController: UIViewController{
    
    @IBOutlet var appView: UIView!
    @IBOutlet weak var arrowUp: UIImageView!
    @IBOutlet weak var instagridImageView: UIImageView!
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var gridView: UIStackView!
    @IBOutlet weak var gridStackView: UIStackView!
    @IBOutlet weak var firstSelectedImageView: UIImageView!
    @IBOutlet weak var secondSelectedImageView: UIImageView!
    @IBOutlet weak var thirdSelectedImageView: UIImageView!
    
    @IBOutlet weak var topRightView: UIView!
    @IBOutlet weak var bottomRightView: UIView!
    
    private var chooseButton: UIButton!
    private var imageSave : UIImage?
    var images : [UIImage] = []
    
    
    private var selectedLayout: Layout = .layout1 {
        //        willSet{
        //            images = retrieveImages(from: selectedLayout)
        //        }
        didSet {
            updateLayout()
            //            resetLayout()
            //            swapToLayout(layout: selectedLayout, images: images)
            //            images.removeAll()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedLayout = .layout1
        prepareUserInterface()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        var title = "Swipe up to share"
        if UIDevice.current.orientation.isLandscape {
            title = "Swipe left to share"
        }
        swipeLabel.text = title
    }
    
    // Ajouter une photo
    @IBAction func gridButtonIsTapped(_ sender: UIButton) {
        addPhoto(button: sender)
    }
    
    // Changer la vue
    @IBAction func layoutButtonIsTapped(_ sender: UIButton) {
        guard let layout = Layout(rawValue: sender.tag) else {
            return
        }
        self.selectedLayout = layout
    }
}

// MARK: - Manage Layout

extension GridViewController {
    
    func updateLayout() {
        print("Le layout selectionné est : \(selectedLayout)")
        
        updateStackViewLayout()
        updateBottomStackViewSelectedImage()
    }
    
    private func updateStackViewLayout() {
        switch selectedLayout {
        case .layout1:
            topRightView.isHidden = true
            bottomRightView.isHidden = false
            break
        case .layout2:
            topRightView.isHidden = false
            bottomRightView.isHidden = true
            // Montrer les deux vues d'en au cacher celle d'en base
            break
        case .layout3:
            topRightView.isHidden = false
            bottomRightView.isHidden = false
            break
        }
    }
    
    private func updateBottomStackViewSelectedImage() {
        [
            firstSelectedImageView,
            secondSelectedImageView,
            thirdSelectedImageView
        ].forEach { imageView in
            imageView?.isHidden = true
        }
        
        switch selectedLayout {
        case .layout1:
            firstSelectedImageView.isHidden = false
        case .layout2:
            secondSelectedImageView.isHidden = false
        case .layout3:
            thirdSelectedImageView.isHidden = false
        }
    }
    
    private func fillGrids(layoutButtons : [UIButton?]) {
        var indexButton = 0
        for image in images {
            layoutButtons[indexButton]?.contentMode = .scaleAspectFill
            layoutButtons[indexButton]?.setImage(image, for: .normal)
            indexButton += 1
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension GridViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("\(info)")
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            chooseButton.setImage(pickedImage, for: .normal)
            chooseButton.contentMode = .scaleAspectFill
            chooseButton.clipsToBounds = true
        }
        //La galerie se ferme quand on a choisi
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Message d'alerte
    private func alertUser(title: String , message: String) -> UIAlertController  {
        let alertVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVc.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            UIView.animate(withDuration: 3) {
                self.gridView.transform = .identity
            }
        }))
        return alertVc
    }
    
    // MARK: Add photo
    // Cette fonction permet de récupérer la photo de l'utilisateur
    private func addPhoto(button : UIButton) {
        chooseButton = button
        let photoSourceRequestController = UIAlertController(title: "", message: "Choisir une photo", preferredStyle: .actionSheet)
        
        let cameraAlertAction = choiceSourceType(messageAlert: "Camera", sourceType: .camera)
        photoSourceRequestController.addAction(cameraAlertAction)
        
        let photoLibraryAlertAction = choiceSourceType(messageAlert: "Galerie photo", sourceType: .photoLibrary)
        photoSourceRequestController.addAction(photoLibraryAlertAction)
        
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel)
        photoSourceRequestController.addAction(cancelAction)
        
        present(photoSourceRequestController, animated: true, completion: nil)
    }
    private func choiceSourceType(messageAlert: String, sourceType: UIImagePickerController.SourceType ) -> UIAlertAction {
        let alertAction = UIAlertAction(title: messageAlert , style: .default) { (action) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        return alertAction
    }
    
    // MARK: Swipe To Share Image
    //    Cette func permet de sélectionner le mouvement selon l'orientation
    @objc private func swipe(sender : UISwipeGestureRecognizer) {
        // Permet de detecter l'orientation de l'ecran sans necessiter de mouvement
        let positionPortrait : Bool = UIScreen.main.bounds.height > UIScreen.main.bounds.width
        switch sender.direction {
        case .left:
            if UIDevice.current.orientation.isLandscape || !positionPortrait{
                transformImageField(landScape: true)
            }
        default:
            if positionPortrait {
                transformImageField(landScape: false)
            }
        }
    }
    // Cette func affiche l'ecran de partage (share sheet)
    private func shareImageField() {
        let renderer = UIGraphicsImageRenderer(size: gridView.bounds.size)
        let image = renderer.image { ctx in
            gridView.drawHierarchy(in: gridView.bounds, afterScreenUpdates: false)
        }
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil )
        vc.popoverPresentationController?.sourceView = self.view
        vc.excludedActivityTypes = [.assignToContact]
        vc.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            let alertUser = completed ? self.alertUser(title: "Le partage est un succès", message: "L'action est terminée") : self.alertUser(title: "Le partage a échoué", message: "Action échouée")
            self.present(alertUser, animated: true, completion: nil)
            
        }
        present(vc, animated: true, completion: nil)
    }
    // Cette func bouge l'image lors du swipe
    private func transformImageField(landScape : Bool){
        let transform = landScape ? CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0) : CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
        let labelToShake : UILabel = landScape ? swipeLabel : swipeLabel
        UIView.animate(withDuration: 1.5, animations: {
            self.gridView.transform = transform
            self.swipeLabel.shake()
            labelToShake.shake()
            self.shareImageField()
        })
    }
    // Cette fonction est utilisée pour afficher le launch screen + ajoute une reconnaissance de swipe
    private func prepareUserInterface() {
        
        let swipeUp = UISwipeGestureRecognizer()
        swipeUp.direction = .up
        let swipeLeft = UISwipeGestureRecognizer()
        swipeLeft.direction = .left
        appView.addGestureRecognizer(swipeUp)
        appView.addGestureRecognizer(swipeLeft)
        swipeUp.addTarget(self, action: #selector(swipe))
        swipeLeft.addTarget(self, action: #selector(swipe))
        
    }
}



