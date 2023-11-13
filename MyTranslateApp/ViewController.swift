import UIKit

class ViewController: UIViewController {
    //MARK: Models
    /// Model for consuming the API-RAPI translation service
    /// - Parameter data: Contains the base of the response
    /// - Parameter translation: Contains an array of all requested translations
    /// - Parameter translatedText: Contains the requested translated text
    private struct TranslationResponse: Codable {
        let data: DataResponse
        struct DataResponse: Codable {
            let translations: [Translation]
            
            struct Translation: Codable {
                let translatedText: String
            }
        }
    }
    
    //MARK: IBOutlets
    /// Flag image of the language to which translation
    @IBOutlet weak var imageCountryTranslate: UIButton!
    /// Flag image of the language in which the text is being written
    @IBOutlet weak var imageCountry: UIButton!
    /// Text entered for translation
    @IBOutlet weak var textTranslate: UITextView!
    /// Translated text
    @IBOutlet weak var textTranslated: UITextView!
    
    /// Symbol of the language being entered, initialized with Spanish
    private var tagSource = "es"
    /// Symbol of the language to be translated, initialized with English
    private var tagTranslate = "en"
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        customViews()
    }
    
    //MARK: Custom Views
    private func customViews() {
        customNavigationItem()
        customImageCountry()
        customImageCountryTranslate()
    }
    
    /// Customizes the top bar with the application title. Modifies the background color and text color
    private func customNavigationItem() {
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.backgroundColor = .tintColor
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    /// Customizes the border of the image for the entered language
    private func customImageCountry() {
        imageCountry.layer.cornerRadius = 15
        imageCountry.layer.borderWidth = 1
        imageCountry.layer.borderColor = UIColor.systemGreen.cgColor
    }
    
    /// Customizes the border of the image of the language to which translation
    private func customImageCountryTranslate() {
        imageCountryTranslate.layer.cornerRadius = 15
        imageCountryTranslate.layer.borderWidth = 1
        imageCountryTranslate.layer.borderColor = UIColor.systemGreen.cgColor
    }
    
    //MARK: Buttons Events
    /// Swaps the images, language symbols, and translation texts for the entered and to-be-translated languages
    @IBAction func changeTranslation(_ sender: Any) {
        let tempTextTranslate = textTranslate.text
        let tempTextTranslated = textTranslated.text
        let tempImageTranslate = imageCountry.currentImage
        let tempImageTranslated = imageCountryTranslate.currentImage
        let tempTagSource = tagSource
        let tempTagTranslate = tagTranslate
        
        textTranslate.text = tempTextTranslated
        textTranslated.text = tempTextTranslate
        imageCountry.setImage(tempImageTranslated, for: .normal)
        imageCountryTranslate.setImage(tempImageTranslate, for: .normal)
        tagSource = tempTagTranslate
        tagTranslate = tempTagSource
    }
    
    /// Assigns an empty string to the text input fields of the translator for the "Clear" function
    @IBAction func clearTranslation(_ sender: Any) {
        textTranslate.text = ""
        textTranslated.text = ""
    }
    
    /// Navigate to select a new language from the source language
    @IBAction func selectCountryTranslateButton(_ sender: Any) {
        performSegue(withIdentifier: "selectLenguage", sender: "CountryTranslate")
    }
    
    /// Navigate to select a new language from the language to be translated
    @IBAction func selectCountryTranslatedButton(_ sender: Any) {
        performSegue(withIdentifier: "selectLenguage", sender: "CountryTranslated")
    }
    
    /// Consume the RAPI_API translation service with the requested header and the assigned test key.
    /// In this case, the body of the request includes the entered text and the source and target languages.
    /// If the response is successful, it is displayed in the text field; otherwise, the error is printed to the console
    @IBAction func translateText(_ sender: Any) {
        if let textToTranslate = textTranslate.text, !textToTranslate.isEmpty {
            translateTextService(
                text: textTranslate.text,
                targetLanguage: tagTranslate,
                sourceLanguage: tagSource
            ) { result in
                switch result {
                case .success(let translatedText): self.updateTextTranslate(text: translatedText)
                case .failure(let error): print("Error: \(error)")
                }
            }
        }
    }
    
    //MARK: Consume API Translate
    func translateTextService(text: String, targetLanguage: String, sourceLanguage: String, completion: @escaping (Result<String, Error>) -> Void) {
        if let url = URL(string: "https://google-translate1.p.rapidapi.com/language/translate/v2") {
            let request = getRequestTranslateService(url: url, text: text, targetLanguage: targetLanguage, sourceLanguage: sourceLanguage)
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                } else if let data = data {
                    do {
                        let translationResponse = try JSONDecoder().decode(TranslationResponse.self, from: data)
                        let translatedText = translationResponse.data.translations.first?.translatedText
                        completion(.success(translatedText ?? ""))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
            
            dataTask.resume()
        }
    }
    
    
    private func getRequestTranslateService(url: URL, text: String, targetLanguage: String, sourceLanguage: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = getHeadersTranslateService()
        request.httpBody = getRequestBodyTranslateService(text, targetLanguage, sourceLanguage)
        return request
    }
    
    private func getHeadersTranslateService() -> [String : String] {
        return [
            "Accept-Encoding": "application/gzip",
            "X-RapidAPI-Key": "582de0c4demsh642394a9b710ec7p1dd672jsn9464f91df962",
            "X-RapidAPI-Host": "google-translate1.p.rapidapi.com"
        ]
    }
    
    private func getRequestBodyTranslateService(
        _ text: String, _ targetLanguage: String, _ sourceLanguage: String
    ) -> Data? {
        return "q=\(text)&target=\(targetLanguage)&source=\(sourceLanguage)".data(using: .utf8)
    }
    
    private func updateTextTranslate(text: String) -> Void {
        DispatchQueue.main.async {
            self.textTranslated.text = text
        }
    }
    
    //MARK: Pattern Delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? LanguagesTableViewController {
            view.type = sender as! String
            view.delegate = self
        }
    }
}

//MARK: Pattern Delegate
extension ViewController: SelectLanguageDelegate {
    func onClickSelectedLanguage(image: String, tag: String, type: String) {
        if(type == "CountryTranslate") {
            tagSource = tag
            imageCountry.setImage(UIImage(named: image), for: .normal)
        } else {
            tagTranslate = tag
            imageCountryTranslate.setImage(UIImage(named: image), for: .normal)
        }
    }
}
