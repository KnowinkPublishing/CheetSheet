//
//  NewtonViewController.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 7/5/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit

class NewtonViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var pvOperations: UIPickerView!
    @IBOutlet weak var txtEquation: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var lblAnswer: UILabel!
    @IBOutlet weak var btnhelp: UIButton!
    @IBOutlet weak var vHelpWrapper: UIView!
    @IBOutlet weak var btnCloseHelp: UIButton!
    @IBOutlet weak var tblEquations: UITableView!
    @IBOutlet weak var lcHelpWrapperBottom: NSLayoutConstraint!
    @IBOutlet weak var lblOperation: UILabel!
    @IBOutlet weak var lblExpression: UILabel!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var vResultsWrapper: UIView!

    var myController = Controller.sharedInstance
    var myConfig = csConfig()
    var myModel = NewtonModel()
    var idxSelectedOperation: Int?

    var arrOperations = ["", "Simplify", "Factor", "Derive", "Integrate", "Cosine", "Sine", "Tangent", "Inverse Cosine", "Inverse Sine", "Inverse Tangent", "Absolute Value"]
    var arrOperationQuery = ["", "simplify", "factor", "derive", "integrate", "cos", "sin", "tan", "arccos", "arcsin", "arctan", "abs"]
    var arrMathExpressions = [
        ["Expression": "Addition", "Symbol": "+", "Sample": "1+1", "Answer": "2"],
        ["Expression": "Subtraction", "Symbol": "-", "Sample": "1-1", "Answer": "0"],
        ["Expression": "Multiplication", "Symbol": "*", "Sample": "1*1", "Answer": "1"],
        ["Expression": "Division", "Symbol": "/", "Sample": "1/1", "Answer": "1"],
        ["Expression": "Equals", "Symbol": "=", "Sample": "1=1", "Answer": "1"],
        ["Expression": "Fraction", "Symbol": "/", "Sample": "1/2", "Answer": "One half"],
        ["Expression": "Decimal", "Symbol": ".", "Sample": "1.5", "Answer": "One and a half."],
        ["Expression": "Exponent", "Symbol": "^", "Sample": "10^2", "Answer": "100"],
        ["Expression": "Exponent With Fraction", "Symbol": "^", "Sample": "10^(2/3)", "Answer": "4.641"],
        ["Expression": "Inverse", "Symbol": "^(-1)", "Sample": "10^(-1) (12)", "Answer": "1.2"],
        ["Expression": "Square Root", "Symbol": "sqrt", "Sample": "sqrt(100)", "Answer": "10"],
        ["Expression": "Cube Root", "Symbol": "cbrt", "Sample": "cbrt(27)", "Answer": "3"],
        ["Expression": "Log", "Symbol": "log", "Sample": "log_2(5)", "Answer": "2.3219"],
        ["Expression": "Natural Log", "Symbol": "ln", "Sample": "ln(10)", "Answer": "2.3025"],
        ["Expression": "Absolute Value", "Symbol": "abs", "Sample": "abs(-10)", "Answer": "10"]
    ]

    var strSelectedOperaton: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        tblEquations.rowHeight = UITableViewAutomaticDimension
        tblEquations.estimatedRowHeight = 105
    }

    override func viewDidAppear(_ animated: Bool) {
        myController.animationManager.backButtonHandler(btnBack)
    }

    @IBAction func sendEquation(_ sender: Any) {

        var bIsValid = true
        var strErrMsg = ""

        guard let strExpression = txtEquation.text, let idxOperation = idxSelectedOperation else {
            myController.alert.presentAlert("Error with equation", "You did not enter all the information required.", self)
            return
        }

        if strExpression.isEmpty {
            bIsValid = false
            strErrMsg = "It appears you didn't enter an equation."
        }

        if bIsValid {

            let strOperationQuery = arrOperationQuery[idxOperation]
            myModel.getEquationResults(strExpression, strOperationQuery, completion: { (bSuccess, dictResult, _) in

                if bSuccess {

                    if let strResult = dictResult["result"] as? String, let strExpression = dictResult["expression"] as? String, let strOperation = dictResult["operation"] as? String {

                        DispatchQueue.main.async {
                            self.vResultsWrapper.alpha = 1.0
                            self.lblOperation.text = strOperation.capitalized
                            self.lblExpression.text = strExpression
                            self.lblResult.text = strResult
                        }

                    }
                }
            })

        } else {
            myController.alert.presentAlert("Error with equation", strErrMsg, self)
        }

    }

    // MARK: Toggle Help
    @IBAction func showHelp(_ sender: Any) {
        toggleHelp()
    }

    @IBAction func closeHelp(_ sender: Any) {
        toggleHelp()
    }

    func toggleHelp() {

        var wrapperY: CGFloat = 0.0
        var wrapperFrame = vHelpWrapper.frame
        if wrapperFrame.origin.y < self.view.frame.size.height {
            wrapperY = self.view.frame.size.height + 1.0
        } else {
            wrapperY = self.view.frame.size.height - 355.0
        }

        wrapperFrame.origin.y = wrapperY

        UIView.animate(withDuration: 0.3, animations: {
            self.vHelpWrapper.frame = wrapperFrame
        })
    }

    // MARK: - Picker View Delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrOperations.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrOperations[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if row > 0 {
            idxSelectedOperation = row
        }
    }

    // MARK: - Table View Delegates

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMathExpressions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: mathCell = tblEquations.dequeueReusableCell(withIdentifier: "mathCell", for: indexPath) as! mathCell

        let dictEquation = arrMathExpressions[indexPath.row]

        if let strExpression = dictEquation["Expression"], let strSymbol = dictEquation["Symbol"], let strSample = dictEquation["Sample"], let strResult = dictEquation["Answer"] {
            cell.lblExpression.text = strExpression
            cell.lblSymbol.text = "Symbol: \(strSymbol)"
            cell.lblSample.text = "Sample: \(strSample)"
            cell.lblResult.text = "Result: \(strResult)"
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105.0
    }

    // MARK: - TextField Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        //closes keyboard
        self.view.endEditing(true)

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        //closes keyboard
        self.view.endEditing(true)

    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func goBack(_ sender: Any) {
         myController.animationManager.backButtonCloseHandler(btnBack, self)
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
