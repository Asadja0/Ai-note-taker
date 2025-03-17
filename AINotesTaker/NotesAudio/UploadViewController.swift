import UIKit

class UploadViewController: UIViewController {
    private let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Recording..."
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        label.text = formatter.string(from: Date())
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let infoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please leave the app open until the file is uploaded."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    private var uploadProgressView: UIProgressView?
    private var transcriptionProgressView: UIProgressView?
    private var summaryProgressView: UIProgressView?
    
    private let assemblyAIService = AssemblyAIService()
    private var transcriptionId: String?
    private let audioFileURL: URL
    
    init(audioFileURL: URL) {
        self.audioFileURL = audioFileURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        startUploadProcess()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(timeLabel)
        view.addSubview(infoView)
        view.addSubview(stackView)
        
        infoView.addSubview(infoLabel)
        
        stackView.addArrangedSubview(createProgressView(title: "Audio Upload", isActive: true))
        stackView.addArrangedSubview(createProgressView(title: "Audio Transcription"))
        stackView.addArrangedSubview(createProgressView(title: "Generating Summary"))
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            infoView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 24),
            infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            infoLabel.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -16),
            infoLabel.bottomAnchor.constraint(equalTo: infoView.bottomAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private func createProgressView(title: String, isActive: Bool = false) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = .systemFont(ofSize: 16, weight: .medium)
        
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0.0
        progressView.progressTintColor = .systemBlue
        
        switch title {
        case "Audio Upload":
            uploadProgressView = progressView
        case "Audio Transcription":
            transcriptionProgressView = progressView
        case "Generating Summary":
            summaryProgressView = progressView
        default:
            break
        }
        
        containerView.addSubview(label)
        containerView.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 80),
            
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            progressView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 12)
        ])
        
        if isActive {
            simulateProgress(progressView)
        }
        
        return containerView
    }
    
    private func startUploadProcess() {
        self.uploadProgressView?.progress = 0.3
        
        assemblyAIService.uploadAudio(fileURL: audioFileURL) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let uploadURL):
                    print("Successfully uploaded audio to: \(uploadURL)")
                    self?.uploadProgressView?.progress = 1.0
                    self?.startTranscription(uploadURL: uploadURL)
                case .failure(let error):
                    print("Upload error: \(error)")
                    self?.showError("Upload failed", message: error.localizedDescription)
                }
            }
        }
    }

    private func startTranscription(uploadURL: String) {
        self.transcriptionProgressView?.progress = 0.3
        
        assemblyAIService.transcribeAudio(uploadURL: uploadURL) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let transcriptionId):
                    print("Started transcription with ID: \(transcriptionId)")
                    self?.transcriptionId = transcriptionId
                    self?.transcriptionProgressView?.progress = 0.6
                    self?.pollTranscriptionStatus()
                case .failure(let error):
                    print("Transcription error: \(error)")
                    self?.showError("Transcription failed", message: error.localizedDescription)
                }
            }
        }
    }

    private func pollTranscriptionStatus() {
        guard let transcriptionId = self.transcriptionId else { return }
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] timer in
            self?.assemblyAIService.checkTranscriptionStatus(id: transcriptionId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let transcriptionResult):
                        if transcriptionResult.status == "completed" {
                            timer.invalidate()
                            self?.transcriptionProgressView?.progress = 1.0
                            self?.summaryProgressView?.progress = 1.0
                            
                            let transcriptVC = TranscriptViewController()
                            transcriptVC.transcriptionResult = transcriptionResult
                            transcriptVC.modalPresentationStyle = .fullScreen
                            self?.present(transcriptVC, animated: true)
                            
                        } else if transcriptionResult.status == "error" {
                            timer.invalidate()
                            self?.showError("Transcription failed", message: "Please try again")
                        }
                    case .failure(let error):
                        timer.invalidate()
                        self?.showError("Status check failed", message: error.localizedDescription)
                    }
                }
            }
        }
    }

    private func showError(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func simulateProgress(_ progressView: UIProgressView?, completion: (() -> Void)? = nil) {
        guard let progressView = progressView else { return }
        
        var progress: Float = 0.0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            progress += 0.01
            progressView.progress = progress
            
            if progress >= 1.0 {
                timer.invalidate()
                if progressView === self?.summaryProgressView {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let transcriptVC = TranscriptViewController()
                        transcriptVC.modalPresentationStyle = .fullScreen
                        self?.present(transcriptVC, animated: true)
                    }
                } else {
                    completion?()
                }
            }
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}
