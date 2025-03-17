import UIKit
import AVFoundation

class RecordingViewController: UIViewController {
    private let waveformView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private let waveformContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:02.2"
        label.font = .monospacedDigitSystemFont(ofSize: 72, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let recordingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Recording"
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 60
        return stack
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icon_cancel"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "Cancel"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: button.topAnchor, constant: 50),
            label.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: button.bottomAnchor)
        ])
        
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        return button
    }()
    
    private let stopButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icon_stop"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return button
    }()
    
    private let pauseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icon_pause"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "Pause"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: button.topAnchor, constant: 50),
            label.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: button.bottomAnchor)
        ])
        
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        return button
    }()
    
    private let assemblyAIService = AssemblyAIService()
    private var audioFileURL: URL?
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var elapsedTime: TimeInterval = 0
    private var waveformLayers: [CALayer] = []
    private var displayLink: CADisplayLink?
    private var isRecording = true
    
    private var meterTimer: Timer?
    private var averagePowerForChannel = -160.0
    private var peakValues: [CGFloat] = Array(repeating: 0.2, count: 80)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        startRecording()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if waveformLayers.isEmpty {
            createWaveform()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(waveformView)
        waveformView.addSubview(waveformContainerView)
        view.addSubview(recordingLabel)
        view.addSubview(timerLabel)
        view.addSubview(buttonStack)
        
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(stopButton)
        buttonStack.addArrangedSubview(pauseButton)
        
        NSLayoutConstraint.activate([
            waveformView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            waveformView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waveformView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            waveformView.heightAnchor.constraint(equalToConstant: 180),
            
            waveformContainerView.centerXAnchor.constraint(equalTo: waveformView.centerXAnchor),
            waveformContainerView.centerYAnchor.constraint(equalTo: waveformView.centerYAnchor),
            waveformContainerView.widthAnchor.constraint(equalToConstant: 240),
            waveformContainerView.heightAnchor.constraint(equalToConstant: 120),
            
            recordingLabel.topAnchor.constraint(equalTo: waveformView.bottomAnchor, constant: 40),
            recordingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            timerLabel.topAnchor.constraint(equalTo: recordingLabel.bottomAnchor, constant: 20),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.widthAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    private func createWaveform() {
        waveformLayers.forEach { $0.removeFromSuperlayer() }
        waveformLayers.removeAll()
        
        let barWidth: CGFloat = 3
        let barSpacing: CGFloat = 2
        let containerWidth = waveformContainerView.bounds.width
        let numberOfBars = Int(containerWidth / (barWidth + barSpacing))
        
        for i in 0..<numberOfBars {
            let barLayer = CALayer()
            
            let xPosition = CGFloat(i) * (barWidth + barSpacing)
            
            let initialHeight: CGFloat = 20
            
            barLayer.frame = CGRect(
                x: xPosition,
                y: (waveformContainerView.bounds.height - initialHeight) / 2,
                width: barWidth,
                height: initialHeight
            )
            barLayer.backgroundColor = UIColor.systemRed.cgColor
            barLayer.cornerRadius = barWidth / 2
            
            waveformContainerView.layer.addSublayer(barLayer)
            waveformLayers.append(barLayer)
        }
        
        startWaveformAnimation()
    }
    
    private func startWaveformAnimation() {
        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateAudioMeters()
        }
    }
    
    private func updateAudioMeters() {
        guard isRecording else { return }
        
        audioRecorder?.updateMeters()
        
        let power = audioRecorder?.averagePower(forChannel: 0) ?? -160.0
        
        averagePowerForChannel = 0.8 * averagePowerForChannel + 0.2 * Double(power)
        
        let level = max(0.0, min(1.0, (averagePowerForChannel + 160.0) / 160.0))
        
        peakValues.removeFirst()
        peakValues.append(CGFloat(level))
        
        updateWaveformWithAudioLevels()
    }
    
    private func updateWaveformWithAudioLevels() {
        let maxHeight = waveformContainerView.bounds.height * 0.9
        let minHeight = waveformContainerView.bounds.height * 0.1
        
        for (index, layer) in waveformLayers.enumerated() {
            let peakIndex = index % peakValues.count
            
            let randomFactor = 0.8 + CGFloat.random(in: 0...0.4)
            let heightFactor = peakValues[peakIndex] * randomFactor
            let barHeight = minHeight + (maxHeight - minHeight) * heightFactor
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.1)
            
            let newY = (waveformContainerView.bounds.height - barHeight) / 2
            layer.frame = CGRect(
                x: layer.frame.origin.x,
                y: newY,
                width: layer.frame.width,
                height: barHeight
            )
            
            CATransaction.commit()
        }
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
    }
    
    @objc private func cancelButtonTapped() {
        stopRecording()
        dismiss(animated: true)
    }
    
    @objc private func stopButtonTapped() {
        print("Stop button tapped")
        stopRecording()
        
        guard let fileURL = audioFileURL else {
            print("No audio file URL found")
            return
        }
        
        print("Starting upload process for file: \(fileURL.path)")
        print("File exists: \(FileManager.default.fileExists(atPath: fileURL.path))")
        
        if let fileSize = try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64 {
            print("File size: \(fileSize) bytes")
        }
        
        let uploadVC = UploadViewController(audioFileURL: fileURL)
        uploadVC.modalPresentationStyle = .fullScreen
        present(uploadVC, animated: true)
    }
    
    @objc private func pauseButtonTapped() {
        if audioRecorder?.isRecording == true {
            audioRecorder?.pause()
            timer?.invalidate()
            meterTimer?.invalidate()
            isRecording = false
            
            if let playImage = UIImage(named: "icon_play") {
                pauseButton.setImage(playImage, for: .normal)
            } else {
                let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
                let image = UIImage(systemName: "play.fill", withConfiguration: imageConfig)
                pauseButton.setImage(image, for: .normal)
            }
            
            let pauseLabel = pauseButton.subviews.compactMap { $0 as? UILabel }.first
            pauseLabel?.text = "Resume"
        } else {
            audioRecorder?.record()
            startTimer()
            startWaveformAnimation()
            isRecording = true
            
            if let pauseImage = UIImage(named: "icon_pause") {
                pauseButton.setImage(pauseImage, for: .normal)
            } else {
                let imageConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
                let image = UIImage(systemName: "pause", withConfiguration: imageConfig)
                pauseButton.setImage(image, for: .normal)
            }
            
            let pauseLabel = pauseButton.subviews.compactMap { $0 as? UILabel }.first
            pauseLabel?.text = "Pause"
        }
    }
    
    private func startRecording() {
        print("Starting recording process...")
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord)
        try? audioSession.setActive(true)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsDirectory.appendingPathComponent("recording.m4a")
        print("Audio will be saved to: \(audioFilename.path)")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings as [String : Any])
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecording = true
            audioFileURL = audioFilename
            print("Recording started successfully")
        } catch {
            print("Recording setup failed with error: \(error)")
        }
        
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.elapsedTime += 0.1
            self?.updateTimerLabel()
        }
    }
    
    private func stopRecording() {
        timer?.invalidate()
        timer = nil
        meterTimer?.invalidate()
        meterTimer = nil
        audioRecorder?.stop()
        isRecording = false
    }
    
    private func updateTimerLabel() {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        let tenths = Int((elapsedTime * 10).truncatingRemainder(dividingBy: 10))
        timerLabel.text = String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }
    
    private func pollTranscriptionStatus(id: String) {
        print("\n🎙 Starting transcription polling for ID: \(id)")
        var retryCount = 0
        let maxRetries = 60
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] timer in
            retryCount += 1
            print("\n⏳ Polling attempt \(retryCount)/\(maxRetries)")
            
            if retryCount > maxRetries {
                print("❌ Maximum polling attempts reached")
                timer.invalidate()
                return
            }
            
            self?.assemblyAIService.checkTranscriptionStatus(id: id) { result in
                switch result {
                case .success(let transcriptionResult):
                    print("📝 Status: \(transcriptionResult.status)")
                    if let text = transcriptionResult.text {
                        print("Current text: \(text)")
                    }
                    
                    switch transcriptionResult.status {
                    case "completed":
                        print("\n✅ Transcription completed successfully!")
                        timer.invalidate()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self?.handleCompletedTranscription(transcriptionResult)
                        }
                        
                    case "error":
                        print("\n❌ Transcription failed")
                        timer.invalidate()
                        
                    case "processing":
                        print("⚙️ Still processing...")
                        
                    case "queued":
                        print("⏳ Queued for processing...")
                        
                    default:
                        print("ℹ️ Status: \(transcriptionResult.status)")
                    }
                    
                case .failure(let error):
                    print("\n❌ Polling error: \(error)")
                }
            }
        }
    }
    
    private func handleCompletedTranscription(_ result: TranscriptionResult) {
        print("\n📝 Final Transcript:")
        print(result.text ?? "No text available")
        print("Number of utterances: \(result.utterances?.count ?? 0)")
        
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true) { [weak self] in
                let transcriptVC = TranscriptViewController()
                transcriptVC.modalPresentationStyle = .fullScreen
                transcriptVC.configure(with: result)
                self?.present(transcriptVC, animated: true)
            }
        }
    }
    
    private func formatTimestamp(_ milliseconds: Int) -> String {
        let seconds = milliseconds / 1000
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRecording()
    }
    
    deinit {
        stopRecording()
    }
}
