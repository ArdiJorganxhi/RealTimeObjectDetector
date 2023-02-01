//
//  ViewController.swift
//  ObjectDetector
//
//  Created by Ardi Jorganxhi on 1.2.23.
//

import UIKit
import AVKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let identifierLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.


        guard let capturingDevice = AVCaptureDevice.default(for: .video) else{
            return
        }
        guard let capturingInput = try? AVCaptureDeviceInput(device: capturingDevice) else{
            return
        }


        let capturingSession = AVCaptureSession()
        capturingSession.sessionPreset = .photo


        capturingSession.addInput(capturingInput)

        capturingSession.startRunning()

        let previewLayer = AVCaptureVideoPreviewLayer(session: capturingSession)

        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame


        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        capturingSession.addOutput(output)


    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else{
            return
        }
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else{
            return
        }
        let request = VNCoreMLRequest(model: model){
            (res, err) in

            guard let results = res.results as? [VNClassificationObservation] else {
                return
            }
            guard let firstObs = results.first else {return}
            print(firstObs.identifier, firstObs.confidence)

            DispatchQueue.main.async {
                self.identifierLabel.text = "\(firstObs.identifier) \(firstObs.confidence * 100)"
            }
        }
        VNImageRequestHandler(cvPixelBuffer: pixelBuffer)




    }

}
