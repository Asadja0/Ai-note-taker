import UIKit

class HomeViewController: UIViewController {
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["All Waves", "Folders", "Favorites", "Meetings", "Phone"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let bottomToolbar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "redcircle"), for: .normal)
        button.layer.cornerRadius = 35
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "All Waves"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search waves"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let importButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupToolbar()
        setupRecordButton()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.titleView = nil
        
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(segmentedControl)
        view.addSubview(scrollView)
        view.addSubview(bottomToolbar)
        view.addSubview(recordButton)
        
        scrollView.addSubview(stackView)
        
        let recordings = [
            ("Friendly Wellbeing Check Between Two People", "7:59 PM", "00:08"),
            ("Greeting Cassio And Tico: A Warm Welcome", "7:59 PM", "00:07"),
            ("Simple Greetings: Connecting Through Warmth", "6:59 PM", "00:03"),
            ("Introducing Ali Javed Tiga: Personal Overview", "6:09 PM", "00:03"),
            ("Urgent Request for Your Immediate Attention", "6:00 PM", "00:05"),
            ("Transportation Elements in Banara Tales", "Yesterday, 3:42 PM", "00:20"),
            ("No Speech Detected", "Yesterday, 2:45 PM", "00:00"),
            ("Friendly Greeting and Positive Response", "Yesterday, 2:57 AM", "00:05")
        ]
        
        for recording in recordings {
            let entryView = createRecordingEntry(title: recording.0, time: recording.1, duration: recording.2)
            stackView.addArrangedSubview(entryView)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            segmentedControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 84),
            
            recordButton.centerXAnchor.constraint(equalTo: bottomToolbar.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: bottomToolbar.centerYAnchor, constant: -10),
            recordButton.widthAnchor.constraint(equalToConstant: 70),
            recordButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func createRecordingEntry(title: String, time: String, duration: String) -> UIView {
        let entryView = UIView()
        entryView.translatesAutoresizingMaskIntoConstraints = false
        
        let micImageView = UIImageView(image: UIImage(named: "talk"))
        micImageView.contentMode = .scaleAspectFit
        micImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .gray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let durationLabel = UILabel()
        durationLabel.text = duration
        durationLabel.font = .systemFont(ofSize: 8)
        durationLabel.textColor = .gray
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        entryView.addSubview(micImageView)
        entryView.addSubview(titleLabel)
        entryView.addSubview(timeLabel)
        entryView.addSubview(durationLabel)
        
        NSLayoutConstraint.activate([
            micImageView.leadingAnchor.constraint(equalTo: entryView.leadingAnchor),
            micImageView.centerYAnchor.constraint(equalTo: entryView.centerYAnchor),
            micImageView.widthAnchor.constraint(equalToConstant: 40),
            micImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: micImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: entryView.topAnchor),
            
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timeLabel.bottomAnchor.constraint(equalTo: entryView.bottomAnchor),
            
            durationLabel.trailingAnchor.constraint(equalTo: entryView.trailingAnchor),
            durationLabel.centerYAnchor.constraint(equalTo: entryView.centerYAnchor)
        ])
        
        return entryView
    }
    
    private func setupToolbar() {
        let micButton = UIButton()
        micButton.translatesAutoresizingMaskIntoConstraints = false
        micButton.setImage(UIImage(named: "mic"), for: .normal)
        micButton.addTarget(self, action: #selector(micButtonTapped), for: .touchUpInside)
        
        let phoneButton = UIButton()
        phoneButton.translatesAutoresizingMaskIntoConstraints = false
        phoneButton.setImage(UIImage(named: "phonecall"), for: .normal)
        phoneButton.addTarget(self, action: #selector(phoneButtonTapped), for: .touchUpInside)
        
        let importButton = UIButton()
        importButton.translatesAutoresizingMaskIntoConstraints = false
        importButton.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        importButton.tintColor = .systemBlue
        importButton.addTarget(self, action: #selector(importButtonTapped), for: .touchUpInside)
        
        let settingsButton = UIButton()
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.setImage(UIImage(named: "setting"), for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        
        bottomToolbar.addSubview(micButton)
        bottomToolbar.addSubview(phoneButton)
        bottomToolbar.addSubview(importButton)
        bottomToolbar.addSubview(settingsButton)
        
        NSLayoutConstraint.activate([
            micButton.leadingAnchor.constraint(equalTo: bottomToolbar.leadingAnchor, constant: 32),
            micButton.centerYAnchor.constraint(equalTo: bottomToolbar.centerYAnchor, constant: -10),
            micButton.widthAnchor.constraint(equalToConstant: 24),
            micButton.heightAnchor.constraint(equalToConstant: 24),
            
            phoneButton.leadingAnchor.constraint(equalTo: micButton.trailingAnchor, constant: 48),
            phoneButton.centerYAnchor.constraint(equalTo: bottomToolbar.centerYAnchor, constant: -10),
            phoneButton.widthAnchor.constraint(equalToConstant: 24),
            phoneButton.heightAnchor.constraint(equalToConstant: 24),
            
            importButton.trailingAnchor.constraint(equalTo: settingsButton.leadingAnchor, constant: -48),
            importButton.centerYAnchor.constraint(equalTo: bottomToolbar.centerYAnchor, constant: -10),
            importButton.widthAnchor.constraint(equalToConstant: 24),
            importButton.heightAnchor.constraint(equalToConstant: 24),
            
            settingsButton.trailingAnchor.constraint(equalTo: bottomToolbar.trailingAnchor, constant: -32),
            settingsButton.centerYAnchor.constraint(equalTo: bottomToolbar.centerYAnchor, constant: -10),
            settingsButton.widthAnchor.constraint(equalToConstant: 24),
            settingsButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupRecordButton() {
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
    }
    
    @objc private func recordButtonTapped() {
        let recordingVC = RecordingViewController()
        recordingVC.modalPresentationStyle = .fullScreen
        present(recordingVC, animated: true)
    }
    
    @objc private func microphoneButtonTapped() {
        // Handle microphone button tap
    }
    
    @objc private func micButtonTapped() {
        // Handle mic button tap
    }
    
    @objc private func phoneButtonTapped() {
        // Handle phone button tap
    }
    
    @objc private func settingsButtonTapped() {
        // Handle settings button tap
    }
    
    @objc private func importButtonTapped() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.shouldShowFileExtensions = true
        
        // Request security scoped resource access
        if #available(iOS 13, *) {
            documentPicker.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
        present(documentPicker, animated: true)
    }
}

extension HomeViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        // Start accessing the security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            // Handle the failure here
            let alert = UIAlertController(title: "Access Denied",
                                        message: "Could not access the selected file. Please make sure you have permission to access this file.",
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Create a local copy of the file in the app's document directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: url, to: destinationURL)
            
            // Stop accessing the security-scoped resource
            url.stopAccessingSecurityScopedResource()
            
            // Present the upload view controller with the local copy
            let uploadVC = UploadViewController(audioFileURL: destinationURL)
            uploadVC.modalPresentationStyle = .fullScreen
            present(uploadVC, animated: true)
            
        } catch {
            // Handle any errors
            url.stopAccessingSecurityScopedResource()
            
            let alert = UIAlertController(title: "Import Failed",
                                        message: "Failed to import the audio file. Please try again.",
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
