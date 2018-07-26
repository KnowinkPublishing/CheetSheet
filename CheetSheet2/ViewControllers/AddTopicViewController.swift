//
//  AddTopicViewController.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/17/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit
import Photos
import Firebase

class AddTopicViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtSubtopic: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnNewTopic: UIButton!
    @IBOutlet weak var lblDone: UILabel!
    @IBOutlet weak var btnLibrary: UIButton!
    @IBOutlet weak var btnPicture: UIButton!
    @IBOutlet weak var vImageCollection: UIView!
    @IBOutlet weak var cImages: UICollectionView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lcVImageCollection: NSLayoutConstraint!
    @IBOutlet weak var vImageWrapper: UIView!
    @IBOutlet weak var ivSelectedImage: UIImageView!
    @IBOutlet weak var btnCloseImage: UIButton!
    @IBOutlet weak var lcImageWrapperBottom: NSLayoutConstraint!

    var myModel = AddViewModel()
    var myController = Controller.sharedInstance

    var currentSequenceID: String?
    var currentSequenceName: String?
    var currentSectionName: String?
    var currentSectionID: String?

    //images
    let imagePicker = UIImagePickerController()
    var imgSelected: UIImage?
    var arrImageIdentifiers: Array<String> = []
    var arrImagePaths: Array<String> = []
    var arrImageViews: Array<UIImageView> = []
    var arrImageObjs: Array<CS_ImagePath> = []
    var bHasImages = false
    fileprivate let reuseIdentifier = "imageCell"
    var bIsEditing = false
    var myTopic: CS_Topic?
    var textTag: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self

        let viewTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.closeKeyboard(_:)))
        self.view.addGestureRecognizer(viewTap)

        txtDescription.layer.borderColor = UIColor.lightGray.cgColor

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }

    override func viewDidAppear(_ animated: Bool) {

        myController.animationManager.backButtonHandler(btnBack)

        if !bIsEditing {
            lblTitle.text = "Add Topic"

        } else {
            lblTitle.text = "Edit Topic"

            if let thisTopic = myTopic {

                txtTitle.text = thisTopic.topicTitle
                txtSubtopic.text = thisTopic.topicSubTitle
                txtDescription.text = thisTopic.topicDescription

                thisTopic.topicImagePaths.forEach {
                    self.arrImagePaths.append($0.imagePath)
                    self.arrImageIdentifiers.append($0.imagePHLIdentifier)
                }

                loadCollectionView()
            }
        }

        if arrImagePaths.count > 0 {
            btnPicture.alpha = 1.0
        } else {
            btnPicture.alpha = 0.0
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Topic Methods

    @IBAction func newTopic(_ sender: Any) {

        let titleIsEmpty = txtTitle.text?.isEmpty ?? false
        let subtopicIsEmpty = txtSubtopic.text?.isEmpty ?? false
        let descriptionIsEmpty = txtDescription.text?.isEmpty ?? false

        if !titleIsEmpty || !subtopicIsEmpty || !descriptionIsEmpty {

            let myAlert = UIAlertController(title: "Create New Topic", message: "Select the OK button if you want to create a new topic. Any text you currently have will be deleted.", preferredStyle: .alert)

            let okAction = UIAlertAction(
            title: "OK", style: UIAlertActionStyle.default) { (_) in

                self.lblTitle.text = "Add Topic"
                self.txtTitle.text = ""
                self.txtSubtopic.text = ""
                self.txtDescription.text = ""
                self.bIsEditing = false
                self.myTopic = nil

            }
            myAlert.addAction(okAction)

            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            myAlert.addAction(cancelAction)

            self.present(myAlert, animated: true, completion: nil)
        }

    }

    @IBAction func submitTopic(_ sender: Any) {

        var dictData: Dictionary<String, Any> = [:]

        dictData["topicTitle"] = self.txtTitle.text
        dictData["subTopic"] = self.txtSubtopic.text
        dictData["topicDesc"] = self.txtDescription.text
        dictData["sectionTitle"] = currentSectionName ?? ""
        dictData["sectionID"] = currentSectionID ?? ""
        dictData["imageObjs"] = arrImageObjs
        dictData["hasImage"] = self.bHasImages

        myModel.validateForm(dictData, completion: { [weak self] (_ bSuccess: Bool, _ strErrMsg: String) in

            if !bSuccess {
                myController.alert.presentAlert("Topic Submission Error", strErrMsg, self!)
            } else {

                //save topic

                self!.myModel.createTopic(dictData: dictData, completion: { (_ bSuccess: Bool, _ newTopic: CS_Topic, _ strErrMsg: String) in

                    if bSuccess {
                        myController.alert.presentAlert("New Topic Added", "A new topic with the title \(newTopic.topicTitle) has been created!", self!)

                        Analytics.logEvent("Topic Created", parameters: [AnalyticsParameterItemName: newTopic.topicTitle, AnalyticsParameterStartDate: newTopic.topicCreateDt])

                    } else {
                        myController.alert.presentAlert("New Topic Error", strErrMsg, self!)
                    }
                })

            }
        })
    }

    // MARK: - Image Methods

    @IBAction func accessCamera(_ sender: Any) {

        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            if arrImagePaths.count < 5 {

                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                imagePicker.cameraCaptureMode = .photo
                imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
                present(imagePicker, animated: true, completion: nil)

            } else {

                myController.alert.presentAlert("Image Limit Reached", "You cannot add more than five images to a topic.", self)
            }

        } else {

            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    //access allowed
                } else {
                    //access denied
                }
            })
        }

    }

    @IBAction func accessLibrary(_ sender: Any) {

        let status = PHPhotoLibrary.authorizationStatus()

        if (status == PHAuthorizationStatus.denied || status == PHAuthorizationStatus.notDetermined) {

            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in

                if (newStatus == PHAuthorizationStatus.authorized) {
                    self.showLibrary()
                } else {
                    self.myController.alert.presentAlert("Photo Library Access Denied", "CheetSheet needs access to your photo library. Without it you will not be able to access any of your images. Please go into your app privacy settings and allow access.", self)
                }
            })

         } else if status == PHAuthorizationStatus.authorized {
            showLibrary()
         }

    }

    func showLibrary() {

        if arrImagePaths.count < 5 {

            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            present(imagePicker, animated: true, completion: nil)

        } else {
            myController.alert.presentAlert("Image Limit Reached", "You cannot add more than five images to a topic.", self)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {

        imgSelected = info[UIImagePickerControllerOriginalImage] as? UIImage

        if picker.sourceType == .photoLibrary {

            if let thisAsset: PHAsset = info[UIImagePickerControllerPHAsset] as? PHAsset {

                thisAsset.getPHAssetURL(completionHandler: {(imageURL) in
                    if let urlString = imageURL?.absoluteString {

                        let thisURL: NSURL = NSURL(string: urlString)!
                        self.arrImagePaths.append(thisURL.absoluteString!)
                        self.arrImageIdentifiers.append(thisAsset.localIdentifier)

                        self.bHasImages = true
                        self.arrImageObjs.append(self.myModel.createImagePathObject(thisURL.absoluteString!, thisAsset.localIdentifier))
                        self.loadCollectionView()
                    }
                })
            }

        } else if picker.sourceType == .camera {

            //we need to save the image to the photo library first
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                UIImageWriteToSavedPhotosAlbum(pickedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }

        }

        self.dismiss(animated: true, completion: nil)

    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        if let error = error {

            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)

        } else {

            //find image in photo library
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let arrResults = PHAsset.fetchAssets(with: .image, options: options)
            if (arrResults.firstObject != nil) {
                let lastImageAsset: PHAsset = arrResults.firstObject!

                lastImageAsset.getURL(completionHandler: {(_ responseURL: URL?) in

                    if let  myResponseURL = responseURL as NSURL? {
                        self.arrImagePaths.append(myResponseURL.absoluteString!)
                        self.bHasImages = true

                        UIView.animate(withDuration: 0.3, animations: {
                            self.btnPicture.alpha = 1.0
                        })

                        self.btnPicture.alpha = 1.0

                        self.loadCollectionView()
                    }

                })

            }
        }
    }

    @IBAction func closeImageCollection(_ sender: Any) {
        toggleImageCollection()
    }

    @IBAction func showImageCollection(_ sender: Any) {
        toggleImageCollection()
    }

    func toggleImageCollection() {

        var thisConstant = lcVImageCollection.constant

        if thisConstant == -249 {
            thisConstant = 0
        } else {
            thisConstant = -249
        }

        UIView.animate(withDuration: 0.3, animations: {

            self.lcVImageCollection.constant = thisConstant
            self.view.layoutIfNeeded()
            self.view.needsUpdateConstraints()

        })

    }

    func loadCollectionView() {

        arrImageViews.removeAll()

        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: true)
        ]

        let results = PHAsset.fetchAssets(withLocalIdentifiers: arrImageIdentifiers, options: options)

        let manager = PHImageManager.default()

        results.enumerateObjects { (thisAsset, _, _) in

            manager.requestImage(for: thisAsset, targetSize: CGSize(width: 80.0, height: 80.0), contentMode: .aspectFit, options: nil, resultHandler: {(thisImage, _) in
                self.arrImageViews.append(UIImageView(image: thisImage))
            })
        }

        self.cImages.reloadData()

    }

    @objc func showImage(_ tap: UITapGestureRecognizer) {

        if let vSource = tap.view {

            let arrThisIdentifier = [arrImageIdentifiers[vSource.tag]]

            let options = PHFetchOptions()
            options.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: true)
            ]

            let results = PHAsset.fetchAssets(withLocalIdentifiers: arrThisIdentifier, options: options)

            let manager = PHImageManager.default()

            results.enumerateObjects { (thisAsset, _, _) in

                manager.requestImage(for: thisAsset, targetSize: CGSize(width: 80.0, height: 80.0), contentMode: .aspectFit, options: nil, resultHandler: {(thisImage, _) in

                    self.ivSelectedImage.contentMode = .scaleAspectFit
                    self.ivSelectedImage.image = thisImage
                })
            }

            toggleImage()
        }

    }

    @IBAction func closeImage(_ sender: Any) {
        toggleImage()
        ivSelectedImage.image = nil
    }

    func toggleImage() {

        var thisConstant = lcImageWrapperBottom.constant

        if thisConstant != 0 {
            thisConstant = 0
        } else {
            thisConstant = -251.0
        }

        UIView.animate(withDuration: 0.3, animations: {

            self.lcImageWrapperBottom.constant = thisConstant
            self.view.setNeedsLayout()
            self.view.needsUpdateConstraints()

        })
    }

    // MARK: - Collection View Methods

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImageViews.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath)

        cell.backgroundColor = UIColor.clear

        let ivThisImage = arrImageViews[indexPath.row]
        var ivFrame = ivThisImage.frame
        ivFrame.origin.x = 5.0
        ivFrame.origin.y = 5.0
        ivThisImage.frame = ivFrame

        let imageTap = UITapGestureRecognizer(target: self, action: #selector(self.showImage))
        ivThisImage.addGestureRecognizer(imageTap)
        ivThisImage.isUserInteractionEnabled = true
        ivThisImage.tag = indexPath.row

        cell.addSubview(ivThisImage)

        return cell
    }

    // MARK: - TextField Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textTag = textField.tag
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textTag = textView.tag
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        //check to make sure we are under 60 characters
        if range.length <= 60 {
            return true
        }

        self.myController.alert.presentAlert("Topic Form Error", "Form field entries are limited to 60 characters except for the description field", self)
        return false

    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        if(text == "\n") {
            view.endEditing(true)
            return false
        } else {
            return true
        }

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    // MARK: - Keyboard Methods

    @objc func closeKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @objc func keyboardDidShow(notification: NSNotification) {

        //check text tag
        if textTag == 5 {

            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {

                    UIView.animate(withDuration: 0.3, animations: {
                        self.lblDone.alpha = 1.0
                        self.view.frame.origin.y -= (keyboardSize.height - 65.0)
                    })

                }
            }

        }

    }

    @objc func keyboardWillHide(notification: NSNotification) {

        if textTag == 5 {

            //if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y != 0 {

                    UIView.animate(withDuration: 0.3, animations: {
                        self.lblDone.alpha = 0.0
                        self.view.frame.origin.y = 0.0
                    })
                    print(self.view.frame)
                }
            //}

            textTag = 0
        }

    }

    @IBAction func goBack(_ sender: Any) {

        arrImageIdentifiers.removeAll()
        arrImageObjs.removeAll()
        arrImagePaths.removeAll()
        arrImageViews.removeAll()

        myController.animationManager.backButtonCloseHandler(btnBack, self)

    }

    // MARK: - Rotation
    override open var shouldAutorotate: Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
