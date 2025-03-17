import UIKit
import AVFoundation

class TranscriptViewController: UIViewController {
    private let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let heartButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .systemRed
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Friendly Wellbeing Check Between Two People"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "7:59 PM"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let actionStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 24
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Summary", "Transcript"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 1
        return control
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let transcriptStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let playerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    private let waveformView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        return imageView
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0:07"
        label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var isPlaying = false
    
    private let voiceButtons: [UIButton] = {
        let voices = ["American", "British", "Australian"]
        return voices.map { voice in
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(voice, for: .normal)
            button.setTitleColor(.systemBlue, for: .normal)
            button.backgroundColor = .systemGray6
            button.layer.cornerRadius = 8
            return button
        }
    }()
    
    private struct VoiceConfig {
        let title: String
        let identifier: String
        static let voices: [VoiceConfig] = [
            VoiceConfig(title: "American Male", identifier: "com.apple.ttsbundle.siri_male_en-US_compact"),
            VoiceConfig(title: "British Male", identifier: "com.apple.ttsbundle.Daniel-compact"),
            VoiceConfig(title: "Australian Male", identifier: "com.apple.ttsbundle.lee-compact")
        ]
    }
    
    private let voiceStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private var selectedVoiceIndex = 0
    
    var transcriptionResult: TranscriptionResult? {
        didSet {
            updateTranscriptDisplay()
        }
    }
    
    private let speakerColorMap: [String: UIColor] = [
        "Host": .systemBlue,
        "Guest 1": .systemGreen,
        "Guest 2": .systemOrange
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        updateTranscriptDisplay()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add action buttons (Folder, Edit, WaveAI, etc)
        let actionButtons = createActionButtons()
        actionButtons.forEach { actionStack.addArrangedSubview($0) }
        
        view.addSubview(closeButton)
        view.addSubview(shareButton)
        view.addSubview(heartButton)
        view.addSubview(titleLabel)
        view.addSubview(timeLabel)
        view.addSubview(actionStack)
        view.addSubview(segmentedControl)
        view.addSubview(searchButton)
        view.addSubview(scrollView)
        view.addSubview(playerView)
        
        scrollView.addSubview(transcriptStack)
        
        playerView.addSubview(playButton)
        playerView.addSubview(waveformView)
        playerView.addSubview(durationLabel)
        playerView.addSubview(voiceStackView)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            shareButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            shareButton.trailingAnchor.constraint(equalTo: heartButton.leadingAnchor, constant: -16),
            
            heartButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            heartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            actionStack.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 24),
            actionStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            actionStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            segmentedControl.topAnchor.constraint(equalTo: actionStack.bottomAnchor, constant: 24),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.widthAnchor.constraint(equalToConstant: 280),
            
            searchButton.centerYAnchor.constraint(equalTo: segmentedControl.centerYAnchor),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: playerView.topAnchor, constant: -16),
            
            transcriptStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            transcriptStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            transcriptStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            transcriptStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            transcriptStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            
            ,
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerView.heightAnchor.constraint(equalToConstant: 80),
            
            playButton.leadingAnchor.constraint(equalTo: playerView.leadingAnchor, constant: 16),
            playButton.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 44),
            playButton.heightAnchor.constraint(equalToConstant: 44),
            
            waveformView.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 16),
            waveformView.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -16),
            waveformView.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
            waveformView.heightAnchor.constraint(equalToConstant: 44),
            
            durationLabel.trailingAnchor.constraint(equalTo: playerView.trailingAnchor, constant: -16),
            durationLabel.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
            
            voiceStackView.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 16),
            voiceStackView.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -16),
            voiceStackView.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
            voiceStackView.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        setupPlayerView()
    }
    
    private func setupPlayerView() {
        // Add voice buttons to player view
        
        // Create voice buttons
        VoiceConfig.voices.enumerated().forEach { index, voice in
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(voice.title, for: .normal)
            button.setTitleColor(.systemBlue, for: .normal)
            button.backgroundColor = index == 0 ? .systemBlue : .systemGray6
            button.setTitleColor(index == 0 ? .white : .systemBlue, for: .normal)
            button.layer.cornerRadius = 8
            button.tag = index
            button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            button.addTarget(self, action: #selector(voiceButtonTapped(_:)), for: .touchUpInside)
            voiceStackView.addArrangedSubview(button)
        }
        
        // Add play button action
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
    }
    
    private func createActionButtons() -> [UIButton] {
        let buttonConfigs = [
            ("folder", "Folder"),
            ("pencil", "Edit"),
            ("waveform", "Al Notes Taker"),
            ("slider.horizontal.3", "Customize"),
            ("person.2", "Speakers")
        ]
        
        return buttonConfigs.map { (imageName, title) in
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setImage(UIImage(systemName: imageName), for: .normal)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 12)
            button.setTitleColor(.systemBlue, for: .normal)
            button.tintColor = .systemBlue
            button.alignTextBelow()
            return button
        }
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }
    
    @objc private func closeButtonTapped() {
        // Dismiss all presented view controllers and return to HomeViewController
        guard let presentingVC = presentingViewController else { return }
        
        if let uploadVC = presentingVC as? UploadViewController,
           let recordingVC = uploadVC.presentingViewController as? RecordingViewController {
            recordingVC.dismiss(animated: true) // This will dismiss everything and return to home
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func segmentedControlValueChanged() {
        updateTranscriptDisplay()
    }
    
    private func updateTranscriptDisplay() {
        guard let result = transcriptionResult,
              isViewLoaded else { return }
        
        // Clear existing content
        transcriptStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if segmentedControl.selectedSegmentIndex == 0 { // Summary
            if let text = result.text {
                let messageView = createMessageView(for: TranscriptMessage(
                    speaker: "Summary",
                    message: text,
                    timestamp: "0:00"
                ))
                transcriptStack.addArrangedSubview(messageView)
            }
        } else { // Transcript
            if let utterances = result.utterances {
                let transcript = formatTranscriptWithSpeakers(utterances)
                let transcriptView = createTranscriptView(with: transcript)
                transcriptStack.addArrangedSubview(transcriptView)
            } else if let text = result.text {
                let messageView = createMessageView(for: TranscriptMessage(
                    speaker: "Speaker:",
                    message: text,
                    timestamp: "0:00"
                ))
                transcriptStack.addArrangedSubview(messageView)
            }
        }
    }
    
    private func formatTimestamp(_ milliseconds: Int) -> String {
        let seconds = milliseconds / 1000
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func createMessageView(for message: TranscriptMessage) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground
        
        let speakerBadge = UIView()
        speakerBadge.translatesAutoresizingMaskIntoConstraints = false
        speakerBadge.backgroundColor = getSpeakerColor(for: message.speaker).withAlphaComponent(0.15)
        speakerBadge.layer.cornerRadius = 4
        
        let speakerLabel = UILabel()
        speakerLabel.translatesAutoresizingMaskIntoConstraints = false
        speakerLabel.text = message.speaker
        speakerLabel.font = .systemFont(ofSize: 14, weight: .medium)
        speakerLabel.textColor = getSpeakerColor(for: message.speaker)
        
        let timestampLabel = UILabel()
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.text = message.timestamp
        timestampLabel.font = .systemFont(ofSize: 14)
        timestampLabel.textColor = .gray
        
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message.message
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        
        containerView.addSubview(speakerBadge)
        containerView.addSubview(timestampLabel)
        containerView.addSubview(messageLabel)
        speakerBadge.addSubview(speakerLabel)
        
        NSLayoutConstraint.activate([
            speakerBadge.topAnchor.constraint(equalTo: containerView.topAnchor),
            speakerBadge.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            speakerBadge.heightAnchor.constraint(equalToConstant: 24),
            
            speakerLabel.topAnchor.constraint(equalTo: speakerBadge.topAnchor, constant: 4),
            speakerLabel.leadingAnchor.constraint(equalTo: speakerBadge.leadingAnchor, constant: 8),
            speakerLabel.trailingAnchor.constraint(equalTo: speakerBadge.trailingAnchor, constant: -8),
            speakerLabel.bottomAnchor.constraint(equalTo: speakerBadge.bottomAnchor, constant: -4),
            
            timestampLabel.centerYAnchor.constraint(equalTo: speakerBadge.centerYAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: speakerBadge.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func formatTranscriptWithSpeakers(_ utterances: [Utterance]) -> NSAttributedString {
        let transcript = NSMutableAttributedString()
        
        utterances.forEach { utterance in
            // Format timestamp
            let timestamp = formatTimestamp(utterance.start)
            let timestampAttr = NSAttributedString(
                string: "[\(timestamp)] ",
                attributes: [.foregroundColor: UIColor.gray, .font: UIFont.systemFont(ofSize: 12)]
            )
            
            // Format speaker name
            let speakerAttr = NSAttributedString(
                string: "\(utterance.speaker): ",
                attributes: [.foregroundColor: UIColor.blue, .font: UIFont.boldSystemFont(ofSize: 14)]
            )
            
            // Format utterance text
            let textAttr = NSAttributedString(
                string: "\(utterance.text)\n\n",
                attributes: [.font: UIFont.systemFont(ofSize: 14)]
            )
            
            transcript.append(timestampAttr)
            transcript.append(speakerAttr)
            transcript.append(textAttr)
        }
        
        return transcript
    }
    
    private func createTranscriptView(with transcript: NSAttributedString) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .systemBackground
        
        let transcriptLabel = UILabel()
        transcriptLabel.translatesAutoresizingMaskIntoConstraints = false
        transcriptLabel.attributedText = transcript
        transcriptLabel.numberOfLines = 0
        
        containerView.addSubview(transcriptLabel)
        
        NSLayoutConstraint.activate([
            transcriptLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            transcriptLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            transcriptLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            transcriptLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        return containerView
    }
    
    private func getSpeakerColor(for speaker: String) -> UIColor {
        if speaker == "Host" {
            return .systemBlue
        } else if speaker == "Guest 1" {
            return .systemGreen
        } else if speaker == "Guest 2" {
            return .systemOrange
        } else if speaker == "Summary" {
            return .systemBlue
        }
        return .systemGray
    }
    
    public func configure(with result: TranscriptionResult) {
        if let utterances = result.utterances {
            var attributedText = NSMutableAttributedString()
            
            for utterance in utterances {
                let color = speakerColorMap[utterance.speaker] ?? .black
                
                let speakerText = NSAttributedString(
                    string: "\n\(utterance.speaker): ",
                    attributes: [
                        .font: UIFont.boldSystemFont(ofSize: 16),
                        .foregroundColor: color
                    ]
                )
                
                let utteranceText = NSAttributedString(
                    string: "\(utterance.text)\n",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 16),
                        .foregroundColor: UIColor.black
                    ]
                )
                
                attributedText.append(speakerText)
                attributedText.append(utteranceText)
            }
            
            let transcriptView = createTranscriptView(with: attributedText)
            transcriptStack.addArrangedSubview(transcriptView)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        titleLabel.text = "Recording from \(formatter.string(from: Date()))"
        transcriptionResult = result
        updateTranscriptDisplay()
    }
    
    @objc private func voiceButtonTapped(_ sender: UIButton) {
        voiceStackView.arrangedSubviews.forEach { view in
            guard let button = view as? UIButton else { return }
            button.backgroundColor = button == sender ? .systemBlue : .systemGray6
            button.setTitleColor(button == sender ? .white : .systemBlue, for: .normal)
        }
        
        selectedVoiceIndex = sender.tag
        
        if isPlaying {
            stopSpeaking()
            startSpeaking()
        }
    }
    
    @objc private func playButtonTapped() {
        if isPlaying {
            stopSpeaking()
        } else {
            startSpeaking()
        }
    }
    
    private func startSpeaking() {
        guard let text = transcriptionResult?.text else { return }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: VoiceConfig.voices[selectedVoiceIndex].identifier)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        
        playButton.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
        isPlaying = true
        speechSynthesizer.speak(utterance)
    }
    
    private func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        isPlaying = false
    }
}

extension TranscriptViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.stopSpeaking()
        }
    }
}

extension UIButton {
    func alignTextBelow(spacing: CGFloat = 4) {
        guard let image = imageView?.image, let title = titleLabel?.text else { return }
        
        let imageSize = image.size
        let titleSize = title.size(withAttributes: [.font: titleLabel?.font ?? .systemFont(ofSize: 12)])
        
        imageEdgeInsets = UIEdgeInsets(
            top: -(titleSize.height + spacing),
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )
        
        titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width,
            bottom: -(imageSize.height + spacing),
            right: 0
        )
    }
}

struct TranscriptMessage {
    let speaker: String
    let message: String
    let timestamp: String
}
