import UIKit

public class BaseFilterPackage {

    // Define the size of the scanning window
    private let windowSize = 5
    
    private var colorRectValues = [[(color: UIColor, rect: CGRect)]]()
    private var queue = DispatchQueue(label: "com.BaseFilterPackage.serial.queue", attributes: .concurrent)
    
    public init() { }

    public func createMagic(inputImage: UIImage, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let width = Int(inputImage.size.width)
            let height = Int(inputImage.size.height)
            
            self.colorRectValues = .init(repeating: .init(repeating: (.clear, .zero), count: height), count: width)
            
            let group = DispatchGroup()
            // Iterate over each pixel in the input image
            for x in 0..<width {
                for y in 0..<height {
                    DispatchQueue.global(qos: .userInteractive).async(group: group) {
                        // Initialize the filter value and count
                        var filterValue = 0.0
                        var count = 0
                        
                        // Iterate over each pixel in the scanning window
                        for i in -self.windowSize..<self.windowSize {
                            for j in -self.windowSize..<self.windowSize {
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
                        let rect = CGRect(x: x, y: y, width: 1, height: 1)
                        
                        self.queue.async(group: group, flags: .barrier) {
                            self.colorRectValues[x][y] = (filteredColor, rect)
                        }
                        print("""
----------------------------------
BaseFilterPackage
x = \(x)
y = \(y)
width = \(width)
height = \(height)
----------------------------------
""")
                    }
                }
            }
            
            group.notify(queue: .main) {
                // Create a new output image context
                UIGraphicsBeginImageContextWithOptions(inputImage.size, false, inputImage.scale)
                
                for arr in self.colorRectValues {
                    for value in arr {
                        // Set the pixel color in the output image context
                        value.color.setFill()
                        UIRectFill(value.rect)
                    }
                }
                
                // Get the output image from the context
                guard let outputImage = UIGraphicsGetImageFromCurrentImageContext() else {
                    fatalError("Output image cannot be accessed.")
                }
                
                // End the image context
                UIGraphicsEndImageContext()
                
                // Display the output image on the screen
                completion(outputImage)
            }
        }
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
