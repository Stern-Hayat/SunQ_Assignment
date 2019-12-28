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
    var saveDataForKeyName = "savedURLString"
    var moveToNextPageName = "mainView"
    var moveToNextStoryBoardName = "AppContents"
    var locationFuncIsOffAlert = "エラー"
    var locationFuncIsOffContent = "位置情報がオンになっていないためデータを取得できません"
    var regetDataContent = "データを取得できなかったため，再取得します"
    var noUrlFoundAlertOKActionLabel = "OK"
    @IBOutlet weak var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProviderLoginView()
        setupLocationManager()
    }
    
    func moveToLoginPage() {
        let subStoryboard: UIStoryboard = UIStoryboard(name: moveToNextStoryBoardName, bundle: nil)
        let subExam: UIViewController = subStoryboard.instantiateViewController(withIdentifier: moveToNextPageName)
        show(subExam, sender: nil)
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse || status == .authorizedAlways{
            locationManager.delegate = self
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        latitude = location?.coordinate.latitude
        longitude = location?.coordinate.longitude
        getDataMethod()
    }
    
    func getDataMethod(){
        let URLString = URLPrefix + String(latitude) + URLBond + String(longitude) + URLSuffix
        print(URLString)
        let ud = UserDefaults.standard
        ud.set(URLString, forKey: saveDataForKeyName)
        ud.synchronize()
    }

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
        }
        
        let loginStatus = CLLocationManager.authorizationStatus()
        if loginStatus == .authorizedWhenInUse || loginStatus == .authorizedAlways{
            switch UserDefaults.standard.object(forKey: saveDataForKeyName) {
            case nil :
                setupLocationManager()
                getDataMethod()
                locationOffAlert(message: regetDataContent)
            default:
                moveToLoginPage()
            }
        } else {
            locationOffAlert(message: locationFuncIsOffContent)
        }
    }
    
    func locationOffAlert(message: String) {
        let alert: UIAlertController = UIAlertController(title: locationFuncIsOffAlert, message: message, preferredStyle: .alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: noUrlFoundAlertOKActionLabel, style: .default, handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization Failed: \(error)")
    }
}
