import UIKit
import CoreLocation
import AuthenticationServices

@available(iOS 13.0, *)
class LoginViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var longitude: Double!
    var latitude: Double!
    let URLPrefix = "https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=15052231058811e607cb99145249b3ed&latitude="
    let URLBond = "&longitude="
    let URLSuffix = "&range=2&sort=1&hit_per_page=100"
    var URLString: String!
    
    var functionRestrictedAlert = "位置情報サービスの利用が制限されている利用できません。「設定」⇒「一般」⇒「機能制限」"
    var functionForbiddenAlert = "位置情報の利用が許可されていないため利用できません。「設定」⇒「プライバシー」⇒「位置情報サービス」⇒「アプリ名」"
    var locationInfoIsOffAlert = "位置情報サービスがONになっていないため利用できません。「設定」⇒「プライバシー」⇒「位置情報サービス」"
    var loctionFuncIsOffAlert = "エラー：位置情報の設定がオフになっています"
    var saveDataForKeyName = "savedURLString"
    var moveToNextPageName = "loginView"
    var moveToNextStoryBoardName = "AppContents"
    var noUrlFoundAlertOKActionLabel = "OK"
    
    @IBOutlet weak var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProviderLoginView()
        setupLocationManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
           if(CLLocationManager.locationServicesEnabled() == true){
               switch CLLocationManager.authorizationStatus() {
               
               case CLAuthorizationStatus.notDetermined:
                   locationManager.requestWhenInUseAuthorization()
               
               case CLAuthorizationStatus.restricted:
                locationInfoIsOffAlert(message: functionRestrictedAlert)
               
               case CLAuthorizationStatus.denied:
                locationInfoIsOffAlert(message: functionForbiddenAlert)
    
               case CLAuthorizationStatus.authorizedWhenInUse:
                   locationManager.startUpdatingLocation()
               
               case CLAuthorizationStatus.authorizedAlways:
                   locationManager.startUpdatingLocation()
               }
               
           } else {
            locationInfoIsOffAlert(message: locationInfoIsOffAlert)
           }
       }
    
    func moveToLoginPage(){
        let SubStoryboard: UIStoryboard = UIStoryboard(name: moveToNextStoryBoardName, bundle: nil)
        let subExam: UIViewController = SubStoryboard.instantiateViewController(withIdentifier: moveToNextPageName)
        show(subExam, sender: nil)
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()

        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        latitude = location?.coordinate.latitude
        longitude = location?.coordinate.longitude
        let URLString = URLPrefix + String(latitude) + URLBond + String(longitude) + URLSuffix
        let ud = UserDefaults.standard
        ud.set(URLString, forKey: saveDataForKeyName)
    }
    
    // 2. ログインボタンの配置
    @available(iOS 13.0, *)
    func setupProviderLoginView() {
      let authorizationButton = ASAuthorizationAppleIDButton()
      authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
      self.stackView.addArrangedSubview(authorizationButton)
    }
     
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email, .fullName]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
 
}
 
@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
 
@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
 
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard
                let authCodeData = appleIDCredential.authorizationCode,
                let authCode = String(data: authCodeData, encoding: .utf8),
                let idTokenData = appleIDCredential.identityToken,
                let idToken = String(data: idTokenData, encoding: .utf8),
                let fullName = appleIDCredential.fullName else {
                print("Problem with the authorizationCode")
                return
            }
            print("authorization code : \(authCode)")
            print("identity token : \(idToken)")
            print("full name : \(fullName)")
            moveToLoginPage()
        }
    }
 
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization Failed: \(error)")
    }
    
    func locationInfoIsOffAlert(message: String) {
      let alert: UIAlertController = UIAlertController(title: loctionFuncIsOffAlert, message: message, preferredStyle:  UIAlertController.Style.alert)
      let defaultAction: UIAlertAction = UIAlertAction(title: noUrlFoundAlertOKActionLabel, style: UIAlertAction.Style.default, handler:{
          (action: UIAlertAction!) -> Void in
      })
      alert.addAction(defaultAction)
      present(alert, animated: true, completion: nil)
    }
}
