import UIKit

public struct BaseFilterPackage {
    
    // Load the input image
//    public var inputImage: UIImage
    
    // Define the size of the scanning window
    private let windowSize = 5
//    private var width = 0
//    private var height = 0
    
    public init() { }
    
    // Get the width and height of the input image
//    private mutating func getSizeOfElement(inputImage: UIImage) {
//        width = Int(inputImage.size.width)
//        height = Int(inputImage.size.height)
//    }
    
    
    public func createMagic(inputImage: UIImage) -> UIImageView {
        let width = Int(inputImage.size.width)
        let height = Int(inputImage.size.height)
        // Create a new output image context
        UIGraphicsBeginImageContextWithOptions(inputImage.size, false, inputImage.scale)
        
        // Iterate over each pixel in the input image
        for x in 0..<width {
            for y in 0..<height {
                // Initialize the filter value and count
                var filterValue = 0.0
                var count = 0
                
                // Iterate over each pixel in the scanning window
                for i in -windowSize..<windowSize {
                    for j in -windowSize..<windowSize {
                        // Calculate the coordinates of the current pixel in the input image
                        let xCoord = x + i
                        let yCoord = y + j
                        
                        // Check if the current pixel is within the input image bounds
                        if xCoord >= 0 && xCoord < width && yCoord >= 0 && yCoord < height {
                            // Get the color of the current pixel
                            let pixelColor = inputImage.getPixelColor(x: xCoord, y: yCoord)
                            
                            // Apply the filter operation to the pixel color
                            if let pixelColor {
                                filterValue += (pixelColor.red + pixelColor.green + pixelColor.blue) / 3.0
                                count += 1
                            }
                        }
                    }
                }
                
                // Calculate the filtered pixel value
                let filteredValue = filterValue / Double(count)
                
                // Create a new pixel color with the filtered value
                let filteredColor = UIColor(red: CGFloat(filteredValue), green: CGFloat(filteredValue), blue: CGFloat(filteredValue), alpha: 1.0)
                
                // Set the pixel color in the output image context
                filteredColor.setFill()
                UIRectFill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
        
        // Get the output image from the context
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the image context
        UIGraphicsEndImageContext()
        
        // Display the output image on the screen
        let imageView = UIImageView(image: outputImage)
        return imageView
    }
}

extension UIImage {
    func getPixelColor(x: Int, y: Int) -> (red: Double, green: Double, blue: Double)? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        let pixelData = cgImage.dataProvider!.data!
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let bytesPerPixel = 4
        let bytesPerRow = cgImage.bytesPerRow
        let pixelOffset = (y * bytesPerRow) + (x * bytesPerPixel)
        let r = CGFloat(data[pixelOffset]) / 255.0
        let g = CGFloat(data[pixelOffset + 1]) / 255.0
        let b = CGFloat(data[pixelOffset + 2]) / 255.0
        
        let red = Double(r)
        let green = Double(g)
        let blue = Double(b)
        
        return (red, green, blue)
    }
}
