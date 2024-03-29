//
//  SetupBackgoundState.swift
//  BackgroundRemover
//
//  Created by Sergei on 4.3.24..
//
import UIKit
import Vision
import CoreImage

public final class SetupBackgoundState: MainState {
    override func enter() {
        super.enter()
        
        guard let image = viewController.takenImage,
              let bgImage = imageFromColor(
                color: viewController.selectedColor,
                size: image.size,
                scale: image.scale
              ) else {
            debugPrint("can't get image")
            return
        }
        
        let swappedImage: UIImage? = swapBackgroundOfPerson(personUIImage: image, backgroundUIImage: bgImage)
        viewController.takenImage = swappedImage
    }
    
    private func imageFromColor(color: UIColor, size: CGSize = CGSize(width: 1, height: 1), scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    lazy var segmentationRequest:VNCoreMLRequest? = {
        guard let coreMLModel = try? RMBG(configuration: MLModelConfiguration()),
              let model = try? VNCoreMLModel(for: RMBG().model) else { return nil }
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .scaleFill
        return request
    }()
    
    let ciContext = CIContext()
    
    public func swapBackgroundOfPerson(personUIImage: UIImage, backgroundUIImage: UIImage) -> UIImage? {
        let newPersonUIImage = getCorrectOrientationUIImage(uiImage:personUIImage)
        let newBackgroundUIImage = getCorrectOrientationUIImage(uiImage:backgroundUIImage)
        
        guard let personCIImage = CIImage(image: newPersonUIImage),
              let backgroundCIImage = CIImage(image: newBackgroundUIImage),
              let maskUIImage = personMaskImage(uiImage: newPersonUIImage),
              let maskCIImage = CIImage(image: maskUIImage) else {
            return nil }
        
        let backgroundImageSize = backgroundCIImage.extent
        let originalSize = personCIImage.extent
        var scale:CGFloat = 1
        let widthScale =  originalSize.width / backgroundImageSize.width
        let heightScale = originalSize.height / backgroundImageSize.height
        if widthScale > heightScale {
            scale = personCIImage.extent.width / backgroundImageSize.width
        } else {
            scale = personCIImage.extent.height / backgroundImageSize.height
        }
        
        let scaledBG = backgroundCIImage.resize(as: CGSize(width: backgroundCIImage.extent.width*scale, height: backgroundCIImage.extent.height*scale))
        let BGCenter = CGPoint(x: scaledBG.extent.width/2, y: scaledBG.extent.height/2)
        let originalExtent = personCIImage.extent
        let cropRect = CGRect(x: BGCenter.x-(originalExtent.width/2), y: BGCenter.y-(originalExtent.height/2), width: originalExtent.width, height: originalExtent.height)
        let croppedBG = scaledBG.cropped(to: cropRect)
        let translate = CGAffineTransform(translationX: -croppedBG.extent.minX, y: -croppedBG.extent.minY)
        let traslatedBG = croppedBG.transformed(by: translate)
        guard let blended = CIFilter(name: "CIBlendWithMask", parameters: [
            kCIInputImageKey: personCIImage,
            kCIInputBackgroundImageKey:traslatedBG,
            kCIInputMaskImageKey:maskCIImage])?.outputImage else { return nil }
        guard let safeCGImage = ciContext.createCGImage(blended, from: blended.extent) else { print("Image processing failed.Please try with another image.") ; return nil }
        let blendedUIImage = UIImage(cgImage: safeCGImage)
        return blendedUIImage
    }
    
    public func personMaskImage(uiImage:UIImage) -> UIImage? {
        let newImage = getCorrectOrientationUIImage(uiImage:uiImage)
        guard let ciImage = CIImage(image: newImage) else { print("Image processing failed.Please try with another image."); return nil }
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            guard let segmentationRequest = segmentationRequest else {
                print("This func can't be used in this OS version."); return nil
            }
            try handler.perform([segmentationRequest])
            guard let result = segmentationRequest.results?.first as? VNPixelBufferObservation
            else { print("Image processing failed.Please try with another image.") ; return nil }
            let maskCIImage = CIImage(cvPixelBuffer: result.pixelBuffer)
            let scaledMask = maskCIImage.resize(as: CGSize(width: ciImage.extent.width, height: ciImage.extent.height))
            
            guard let safeCGImage = ciContext.createCGImage(scaledMask, from: scaledMask.extent) else { print("Image processing failed.Please try with another image.") ; return nil }
            let maskUIImage = UIImage(cgImage: safeCGImage)
            return maskUIImage
        } catch let error {
            print("Vision error \(error)")
            return nil
        }
    }
    
    public func getCorrectOrientationUIImage(uiImage:UIImage) -> UIImage {
        var newImage = UIImage()
        switch uiImage.imageOrientation.rawValue {
        case 1:
            guard let orientedCIImage = CIImage(image: uiImage)?.oriented(CGImagePropertyOrientation.down),
                  let cgImage = ciContext.createCGImage(orientedCIImage, from: orientedCIImage.extent) else { return uiImage}
            
            newImage = UIImage(cgImage: cgImage)
        case 3:
            guard let orientedCIImage = CIImage(image: uiImage)?.oriented(CGImagePropertyOrientation.right),
                  let cgImage = ciContext.createCGImage(orientedCIImage, from: orientedCIImage.extent) else { return uiImage}
            newImage = UIImage(cgImage: cgImage)
        default:
            newImage = uiImage
        }
        return newImage
    }
}

extension CIImage {
    func resize(as size: CGSize) -> CIImage {
        let selfSize = extent.size
        let transform = CGAffineTransform(scaleX: size.width / selfSize.width, y: size.height / selfSize.height)
        return transformed(by: transform)
    }
}
