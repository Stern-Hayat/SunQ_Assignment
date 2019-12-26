import UIKit
import Alamofire
import SwiftyJSON
import Foundation
import CoreLocation
import SafariServices

class TopListPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,CLLocationManagerDelegate{
    @IBOutlet var listTableView: UITableView!
    var listData = [(name: String, Web: String, Mobile: String)]()
    var i = 0;
    var saveDataForKeyName = "savedURLString"
    var jsonDataArrayDataList = "rest"
    var jsonDataArrayDataName = "name"
    var jsonDataArrayDataUrl = "url"
    var jsonDataArrayDataMobile = "url_mobile"
    var noUrlFoundAlertTitle = "エラー"
    var noUrlFoundAlertContent = "このお店はホームページを開設していません．"
    var noUrlFoundAlertOKActionLabel = "OK"
    var dataListCellIdentifierName = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listTableView.delegate = self
        listTableView.dataSource = self
        let ud = UserDefaults.standard
        let URLString = ud.object(forKey: saveDataForKeyName) as! String
        print(URLString)
        Alamofire.request(URLString).responseJSON{ response in
            let json = JSON(response.result.value ?? 0)
            do {
                
                let jsonDataCount = json[self.jsonDataArrayDataList].count
                for i in 0...jsonDataCount{
                    let jsonData = json[self.jsonDataArrayDataList][i][self.jsonDataArrayDataName]
                    let jsonWebData = json[self.jsonDataArrayDataList][i][self.jsonDataArrayDataUrl]
                    let jsonMobileData = json[self.jsonDataArrayDataList][i][self.jsonDataArrayDataMobile]
                    let jsonConvertedData = jsonData.stringValue
                    let jsonWebConvertedData = jsonWebData.stringValue
                    let jsonMobileConvertedData = jsonMobileData.stringValue
                    self.listData.append((name: jsonConvertedData, Web: jsonWebConvertedData, Mobile: jsonMobileConvertedData))
                }
            } catch let jsonError{
                print("jsonError", jsonError)
            }
            //Webサイト及びモバイルサイトがない場合の例外処理検証用のダミーデータ
            self.listData.append((name: "A-ホームページを作っていないお店", Web: "", Mobile: ""))
            self.listData.sort{$0<$1}
            self.listTableView.reloadData()
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.listData[indexPath.row].Mobile != ""{
            let storeURL = NSURL(string: self.listData[indexPath.row].Mobile)
            let safariViewController = SFSafariViewController(url: storeURL! as URL)
            present(safariViewController, animated: false, completion: nil)
        } else if self.listData[indexPath.row].Web != ""{
            let storeURL = NSURL(string: self.listData[indexPath.row].Web)
            let safariViewController = SFSafariViewController(url: storeURL! as URL)
            present(safariViewController, animated: false, completion: nil)
        } else {
            let alert: UIAlertController = UIAlertController(title: noUrlFoundAlertContent, message: noUrlFoundAlertTitle, preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: noUrlFoundAlertOKActionLabel, style: UIAlertAction.Style.default, handler:{
              (action: UIAlertAction!) -> Void in
          })
          alert.addAction(defaultAction)
          present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: dataListCellIdentifierName)
        cell.textLabel?.text = self.listData[indexPath.row].name
        return cell
    }
}
