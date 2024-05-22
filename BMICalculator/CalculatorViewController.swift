//
//  CalculatorViewController.swift
//  BMICalculator
//
//  Created by 김성민 on 5/21/24.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var mainImageView: UIImageView!
    
    @IBOutlet var heightLabel: UILabel!
    @IBOutlet var heightTextField: UITextField!
    @IBOutlet var weightLabel: UILabel!
    @IBOutlet var weightTextField: UITextField!
    
    @IBOutlet var hideButton: UIButton!
    @IBOutlet var randomButton: UIButton!
    @IBOutlet var resultButton: UIButton!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 마지막 검색 불러오기
        let height = UserDefaults.standard.string(forKey: "height")
        heightTextField.text = height
        let weight = UserDefaults.standard.string(forKey: "weight")
        weightTextField.text = weight
        
        configureUI()
    }
    
    // MARK: - UI
    
    func configureUI() {
        configureLabels()
        
        mainImageView.image = UIImage(named: "image")
        mainImageView.contentMode = .scaleToFill
        
        configureTextField(heightTextField)
        configureTextField(weightTextField)
        weightTextField.isSecureTextEntry = true
        
        hideButton.setTitle("", for: .normal)
        hideButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        hideButton.tintColor = .gray
        
        randomButton.setTitle("랜덤으로 BMI 계산하기", for: .normal)
        randomButton.setTitleColor(.red, for: .normal)
        randomButton.setTitleColor(.systemPink, for: .highlighted)
        randomButton.contentHorizontalAlignment = .trailing
        
        resultButton.setTitle("결과 확인", for: .normal)
        resultButton.setTitleColor(.white, for: .normal)
        resultButton.titleLabel?.font = .systemFont(ofSize: 20)
        resultButton.backgroundColor = .purple
        resultButton.layer.cornerRadius = 20
    }
    
    func configureLabels() {
        titleLabel.text = "BMI Calculator"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        descriptionLabel.text = "당신의 BMI 지수를 알려드릴게요."
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        
        heightLabel.text = "키(cm)가 어떻게 되시나요?"
        heightLabel.font = .systemFont(ofSize: 16)
        
        weightLabel.text = "몸무게(kg)는 어떻게 되시나요?"
        weightLabel.font = .systemFont(ofSize: 16)
    }
    
    func configureTextField(_ textField: UITextField) {
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        // textField.keyboardType = .numberPad
    }
    
    // MARK: - Logic
    
    func getRandomHeightAndWeight() -> (Double, Double) {
        let height = Double.random(in: 100...200)
        let weight = Double.random(in: 40...200)
        return (height, weight)
    }
    
    func getAlertMessage(BMI: Double) -> (String, String) {
        let title = "BMI: \(String(format: "%.1f", BMI))"
        var message = ""
        switch BMI {
        case ..<18.5:
            message = "저체중"
        case 18.5..<23:
            message = "정상"
        case 23..<25:
            message = "비만전단계"
        case 25..<30:
            message = "1단계 비만"
        case 30..<35:
            message = "2단계 비만"
        case 35...:
            message = "3단계 비만"
        default:
            message = "오류 발생"
        }
        return (title, message)
    }
    
    func calculateBMI(height: Double, weight: Double) -> Double {
        // BMI = 체중(kg) / 신장(m)^2
        return weight / (height * height * 0.0001)
    }
    
    func presentAlert(title: String?, message: String?) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let confirm = UIAlertAction(title: "확인", style: .default)
        alert.addAction(confirm)
        present(alert, animated: true)
    }
    
    // MARK: - IBAction
    
    @IBAction func hideButtonTapped(_ sender: UIButton) {
        // 1. 버튼 이미지 바꿔주기
        if weightTextField.isSecureTextEntry {
            hideButton.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            hideButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }
        // 2. weight 텍스트필드 보여주기, 가려주기
        weightTextField.isSecureTextEntry.toggle()
    }
    
    @IBAction func randomButtonTapped(_ sender: UIButton) {
        // 텍스트필드 랜덤값으로 채워주기
        let (height, weight) = getRandomHeightAndWeight()
        heightTextField.text = String(format: "%.2f", height)
        weightTextField.text = String(format: "%.2f", weight)
    }
    
    @IBAction func resultButtonTapped(_ sender: UIButton) {
        // 1. 키보드 내리기
        view.endEditing(true)
        
        // 2. 예외 처리
        guard let heightString = heightTextField.text,
              let weightString = weightTextField.text,
              // 공백 제거, 형변환
              let height = Double(heightString.split(separator: " ").joined()),
              let weight = Double(weightString.split(separator: " ").joined()),
              // 범위 확인
              (100...200).contains(height),
              (40...200).contains(weight) else {
            presentAlert(title: "키와 몸무게를 정확하게 입력해주세요", message: nil)
            return
        }
        
        // 3. BMI 계산하기
        let BMI = calculateBMI(height: height, weight: weight)
        
        // 4. 얼럿 띄워서 결과 보여주기
        let (title, message) = getAlertMessage(BMI: BMI)
        presentAlert(title: title, message: message)
        
        // 마지막 검색 영구 저장하기
        UserDefaults.standard.setValue(heightString, forKey: "height")
        UserDefaults.standard.setValue(weightString, forKey: "weight")
    }
    
    @IBAction func heightTextFieldEditingChanged(_ sender: UITextField) {
        print(sender.text ?? "")
    }
    
    @IBAction func weightTextFieldEditingChanged(_ sender: UITextField) {
        print(sender.text ?? "")
    }
    
    // 아무 화면 터치시 키보드 내리기
    @IBAction func keyboardDismiss(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}
