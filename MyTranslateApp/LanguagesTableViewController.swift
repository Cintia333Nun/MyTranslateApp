import UIKit

/// Model for storing languages in a table.
/// - Parameter language: Stores the name of the language.
/// - Parameter languageImage: Displays the flag image of the language to be selected.
/// - Parameter tag: Represents the language symbol for consumption with a translation API.
struct Languages {
    let language: String
    let languageImage: String
    let tag: String
}

/// A protocol is defined to be delegated to the previous view to receive the language selected by the user.
protocol SelectLanguageDelegate: AnyObject {
    /// Defined method to be used for data transfer between both views.
    func onClickSelectedLanguage(image: String, tag: String, type: String)
}

/// Controller responsible for handling the information used to populate the table of languages available for translation. This controller should be connected to the relevant element from the user interface.
class LanguagesTableViewController: UITableViewController {
    /// Model created for consuming the service to obtain the available languages in the API-RAPI translation service.
    /// - Parameter data: Contains the base of the response.
    /// - Parameter languages: Contains an array of all languages available through the API.
    /// - Parameter language: Contains the symbol of a language, for example, "en" or "es".
    struct LanguagesResponse: Codable {
        let data: DataResponse
        struct DataResponse: Codable {
            let languages: [Language]
            struct Language: Codable {
                let language: String
            }
        }
    }
    /// Optional variable to be used for implementing the delegate design pattern.
    weak var delegate: SelectLanguageDelegate?
    /// Array for managing the list of countries to be displayed in the table. It is initialized with 5 default languages, each with its name and symbol hardcoded.
    private var arrayLanguagues: [Languages] = [
        .init(language: "Inglés", languageImage: "reino-unido", tag: "en"),
        .init(language: "Español", languageImage: "mexico (1)", tag: "es"),
        .init(language: "Frances", languageImage: "francia", tag: "fr"),
        .init(language: "Alemán", languageImage: "alemania", tag: "de"),
        .init(language: "Portugues", languageImage: "portugal", tag: "pt")
    ]
    /// It will be stored to indicate whether the selected language is the source language or the target language for translation.
    var type = ""

    /// This class extends from a ViewController, so it also has the same lifecycle.
    /// In this method, which is called when the view is created, languages available in the service can be downloaded.
    /// In this case, nothing is done, and we stick with the 5 languages that are hardcoded as they provide a better UX & UI experience.

    override func viewDidLoad() {
        super.viewDidLoad()
        //getAllLanguagesService()
    }
    
    // MARK: Consume API get languages Service
    /// The service that responds with all available languages in the API is consumed. These languages only include the symbol, and to populate them, the same array is reused. The current information is cleared, and the array is filled with data from the service. Subsequently, the table content is updated.
    private func getAllLanguagesService() {
        if let url = URL(string: "https://google-translate1.p.rapidapi.com/language/translate/v2/languages") {
            let request = getUrlRequest(url)
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request) { data, response, error in
                if error != nil {
                    print("error")
                } else if let data = data {
                    do {
                        let response = try JSONDecoder().decode(LanguagesResponse.self, from: data)
                        self.arrayLanguagues.removeAll()
                        for language in response.data.languages {
                            self.arrayLanguagues.append(
                                Languages(
                                    language: language.language,
                                    languageImage: "default_flag",
                                    tag: language.language
                                )
                            )
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } catch {
                        print("Excepción en ")
                    }
                }
            }
            
            dataTask.resume()
        }
    }
    
    private func getUrlRequest(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = getHeadersAllLanguagesService()
        return request
    }
    
    private func getHeadersAllLanguagesService() -> [String : String] {
        return  [
            "Accept-Encoding": "application/gzip",
            "X-RapidAPI-Key": "YOUR_KEY",
            "X-RapidAPI-Host": "google-translate1.p.rapidapi.com"
        ]
    }

    // MARK: - Table view data source
    /// Returns the number of sections the table will have.
    /// In this context, similar to WhatsApp, the number of grouped cells could be seen as the number of sections in that table.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /// - Returns: Number of cells to be created for section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayLanguagues.count
    }

    /// Customizes the cell with information stored in the array. The identifier of the specific cell instance needs to be modified to "reuseIdentifier".
    /// - Returns: The customized cell or, if it does not exist, an instance of a cell.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? LanguageTableViewCell
        
        let language = arrayLanguagues[indexPath.row]
        
        cell?.languagueLabel.text = language.language
        cell?.imageLanguage.image = UIImage(named: language.languageImage)

        return cell ?? UITableViewCell()
    }
    
    /// Este metodo es llamado cuando se selecciona una celda. En este caso se almacenan los datos del lenguaje seleccionado, se usa la variable delegate para el envio de estos datos a la vista anterior y se cierra la vista actual.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = arrayLanguagues[indexPath.row]
        delegate?.onClickSelectedLanguage(image: language.languageImage, tag: language.tag, type: type)
        dismiss(animated: true)
    }

}
