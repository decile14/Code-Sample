//
//  ViewController.swift
//  quiz
//
//  Created by Dominique Dorvil on 11/22/19.
//  Copyright © 2019 Dominique Dorvil. All rights reserved.
//

import UIKit
import WebKit
import CoreData
import AVFoundation

let model = userHelp()

protocol VCDelegate: class {
    func userInput()
}

class ViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate {
    
    var audioPlayer:AVAudioPlayer?
    var webView: WKWebView!
    var nextIsClicked = false;
    var click = 0
   
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var genBtn: UIButton!
    @IBOutlet weak var input1: UITextField!
    
    @IBOutlet weak var input2: UITextField!
    @IBOutlet weak var input3: UITextField!
    @IBOutlet weak var input4: UITextField!
    @IBOutlet weak var input5: UITextField!
    @IBOutlet weak var input6: UITextField!
    @IBOutlet weak var input7: UITextField!
    @IBOutlet weak var input8: UITextField!
    @IBOutlet weak var input9: UITextField!
    @IBOutlet weak var input10: UITextField!
    
    @IBOutlet weak var inputStack: UIStackView!
    //variables
    var currentQuestions = 0;
    var currentAnswers = 0;
    var points = 0;
    //label
    @IBOutlet weak var lbl: UILabel!

    
    // Delegate
    
    weak var delegate: VCDelegate?
    
    @IBAction func onDone(_ sender: UIButton) {
        delegate?.userInput()
        
    }
    
    @IBOutlet weak var dailyLabel: UILabel!
    @IBOutlet weak var darkLabel: UILabel!
    @IBOutlet weak var pinkLabel: UILabel!
    
    @IBOutlet weak var pinkModeSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var dailyTipSwitch: UISwitch!
    
    @IBOutlet weak var swipeLibs: UIImageView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    
    //Transitions
    @objc func flip() {
        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        UIView.transition(with: firstView, duration: 1.0, options: transitionOptions, animations: {
            self.firstView.isHidden = true
        })
        
        UIView.transition(with: secondView, duration: 1.0, options: transitionOptions, animations: {
            self.secondView.isHidden = false
        })
    }
    
    //Gesture Recognizer
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .left) {
            print("Swipe Left")
            let labelPosition = CGPoint(x: swipeLibs.frame.origin.x - 50.0, y: swipeLibs.frame.origin.y)
            swipeLibs.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: swipeLibs.frame.size.width, height: swipeLibs.frame.size.height)
        }
        
        if (sender.direction == .right) {
            print("Swipe Right")
            let labelPosition = CGPoint(x: self.swipeLibs.frame.origin.x + 50.0, y: self.swipeLibs.frame.origin.y)
            swipeLibs.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: self.swipeLibs.frame.size.width, height: self.swipeLibs.frame.size.height)
        }
    }
    
    //audio, localization, and alerts located here
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { _ in
            if UserDefaults.standard.bool(forKey: dShowDailyTip) {
                let alert = UIAlertController(title: "Tip of the Day", message: "Use a dictionary! 🤓", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
        }
        
         if UserDefaults.standard.bool(forKey: dDarkMode) {
            self.view.backgroundColor = #colorLiteral(red: 0.2666666667, green: 0.2666666667, blue: 0.2666666667, alpha: 1)
        }
        
        if UserDefaults.standard.bool(forKey: dPinkMode) {
//            self.view.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.3977976441, alpha: 1)
            let url = Bundle.main.url(forResource: "t", withExtension: "mp3")
            
            guard url != nil else {
                return
            }
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url!)
                audioPlayer?.play()
            } catch {
                print("error")
            }

        }
        
        secondView.isHidden = true
        
        view.addSubview(firstView)
        view.addSubview(secondView)
        
        perform(#selector(flip), with: nil, afterDelay: 2)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        configureTextfields()
        configureTapGesture()
        
         doneBtn.layer.cornerRadius = 25.0
         genBtn.layer.cornerRadius = 25.0
        
        input1.placeholder = NSLocalizedString("str_input1", comment: "")
        input2.placeholder = NSLocalizedString("str_input2", comment: "")
        input3.placeholder = NSLocalizedString("str_input3", comment: "")
        input4.placeholder = NSLocalizedString("str_input4", comment: "")
        input5.placeholder = NSLocalizedString("str_input5", comment: "")
        input6.placeholder = NSLocalizedString("str_input6", comment: "")
        input7.placeholder = NSLocalizedString("str_input7", comment: "")
        input8.placeholder = NSLocalizedString("str_input8", comment: "")
        input9.placeholder = NSLocalizedString("str_input9", comment: "")
        input10.placeholder = NSLocalizedString("str_input10", comment: "")

        
        doneBtn.setTitle(NSLocalizedString("str_doneBtn", comment: ""), for: .normal)
        genBtn.setTitle(NSLocalizedString("str_genBtn", comment: ""), for: .normal)
        
         dailyLabel.text = NSLocalizedString("str_dailyLabel", comment: "")
         darkLabel.text = NSLocalizedString("str_darkLabel", comment: "")
         pinkLabel.text = NSLocalizedString("str_pinkLabel", comment: "")
        
        
    
    }
    
    @IBAction func doneIsClicked(_ sender: UIButton) {
        
        endQuiz()
    }
 
    override func viewDidAppear(_ animated: Bool) {
        
//        newQuestion()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dailyTipSwitch.isOn = UserDefaults.standard.bool(forKey: dShowDailyTip)
        
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: dDarkMode)
        
        pinkModeSwitch.isOn = UserDefaults.standard.bool(forKey: dPinkMode)
    }
    
    // MARK: - Actions
    
    @IBAction func onDarkModeSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: dDarkMode)
    }
    @IBAction func onDailyTipsSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: dShowDailyTip)
    }
    
    
    @IBAction func onPinkModeSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: dPinkMode)
    }
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        print("Handle tap was called")
        view.endEditing(true)
    }

    //function to help save data in textfield
    private func configureTextfields() {
        input7.delegate = self
        input6.delegate = self
        input5.delegate = self
        input4.delegate = self
        input8.delegate = self
        input1.delegate = self
        input2.delegate = self
        input3.delegate = self
        input10.delegate = self
        input9.delegate = self
    }
    
   
     let questions = ["loocation", "noun", "noun(plural)", "body part", "verb", "verb", "body part", "verb", "body part", "verb(ing)"]

    //function that calls new question
//    func newQuestion() {
//        lbl.text = questions[currentQuestions]
//        currentQuestions += 1
//    }

    func endQuiz() {
        performSegue(withIdentifier: "fullStory", sender: self)
    }
    
    enum FieldTags : Int{
        
       case input1Tag = 0
       case input2Tag = 1
       case input3Tag = 2
       case input4Tag = 3
       case input5Tag = 4
       case input6Tag = 5
       case input7Tag = 6
       case input8Tag = 7
       case input9Tag = 8
       case input10Tag = 9
    
    };
    
    //makes the text input from this view visible on another view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "fullStory":
            let vc = segue.destination as? StoryTVC
            vc?.blank1 = input1.text!
            vc?.blank2 = input2.text!
            vc?.blank3 = input3.text!
            vc?.blank4 = input4.text!
            vc?.blank5 = input5.text!
            vc?.blank6 = input6.text!
            vc?.blank7 = input7.text!
            vc?.blank8 = input8.text!
            vc?.blank9 = input9.text!
            vc?.blank10 = input10.text!
        default:
            fatalError("Invalid segue identifier")
            
        }
    }
    
    func getHint() {
        let alertController = UIAlertController(title: "Hint", message: "Fill in the blanks with the help of the place holder! Noun: person, place or thing. Verb: action. Adjective: Descriptive word", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func findWords() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
        let url = URL(string: "https://icebreakerideas.com/mad-libs/#Word_Lists_for_Mad_Libs")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    //this method makes each textfield show up one at a time
    //goes to next textfield when return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        //ALERT SHEET
        if textField.text == "" {
            // 1 make the alert that houses the alert actions
            let alert = UIAlertController(title: "Help With Libs", message: "Cause: Empty Text-Field", preferredStyle: .actionSheet)
            
            // 2
//            let autoGenerate = UIAlertAction(title: "Generate Word", style: .default){_ in
//                let generated = model.generate()
//                textField.text = generated
//
//            }
            
            let searchOnline =  UIAlertAction(title: "Search Online", style: .default){_ in
                self.findWords()
                
            }
            
            let hint = UIAlertAction(title: "Hint", style: .default){_ in
                self.getHint()
                
            }
                let keepSame = UIAlertAction(title: "Exit", style: .default){_ in
//                     self.dismiss(animated: true, completion: nil)
                    
                }
            
                
                
                //3
//                alert.addAction(autoGenerate)
                alert.addAction(searchOnline)
                alert.addAction(hint)
                alert.addAction(keepSame)
                
                // 4 There is no step 4 for this simple alert : )
                
                alert.popoverPresentationController?.permittedArrowDirections = []
                alert.popoverPresentationController?.sourceView = self.view
                alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width:0, height:0)
                
                
                // 5 present the dialog
                self.present(alert, animated: true, completion:nil)
                
        }
        
        //allows each textField to appear one at a time
        switch (textField.tag) {
            case 0:
                textField.isHidden = false;
            break;
            case 1:
                textField.isHidden = false;
                break;
            case 2:
               textField.isHidden = false;
                break;
            case 3:
                textField.isHidden = false;
                break;
            case 4:
                textField.isHidden = false;
                break;
            case 5:
                textField.isHidden = false;
                break;
            case 6:
                textField.isHidden = false;
                break;
            case 7:
                textField.isHidden = false;
                break;
            case 8:
                textField.isHidden = false;
                break;
            case 9:
                textField.isHidden = false;
                break;
            
            default:
                endQuiz()
            }
        
        
        
//        if (currentQuestions != questions.count) {
//            newQuestion()
//
//        }
//        else if currentQuestions == questions.count {
//            endQuiz()
//        }
        
        
        
        return true
    }
    
    

}
