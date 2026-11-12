import AppKit
let out = CommandLine.arguments[1]
let colorSpace = CGColorSpaceCreateDeviceRGB()
let ctx = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 4096, space: colorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
ctx.setFillColor(CGColor(red: 0.035, green: 0.04, blue: 0.12, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: 1024, height: 1024))
let balloon = CGMutablePath()
balloon.move(to: CGPoint(x: 512, y: 300))
balloon.addCurve(to: CGPoint(x: 512, y: 865), control1: CGPoint(x: 115, y: 470), control2: CGPoint(x: 185, y: 865))
balloon.addCurve(to: CGPoint(x: 512, y: 300), control1: CGPoint(x: 839, y: 865), control2: CGPoint(x: 909, y: 470))
balloon.closeSubpath()
ctx.saveGState(); ctx.addPath(balloon); ctx.clip()
let gradient = CGGradient(colorsSpace: colorSpace, colors: [CGColor(red: 1, green: 0.44, blue: 0.48, alpha: 1), CGColor(red: 0.99, green: 0.14, blue: 0.24, alpha: 1), CGColor(red: 0.57, green: 0.03, blue: 0.14, alpha: 1)] as CFArray, locations: [0, 0.55, 1])!
ctx.drawLinearGradient(gradient, start: CGPoint(x: 280, y: 830), end: CGPoint(x: 730, y: 300), options: [])
ctx.restoreGState()
ctx.setFillColor(CGColor(red: 0.9, green: 0.13, blue: 0.24, alpha: 1)); ctx.move(to: CGPoint(x: 512,y:310)); ctx.addLine(to: CGPoint(x: 548,y:263)); ctx.addQuadCurve(to: CGPoint(x:476,y:263),control:CGPoint(x:512,y:278)); ctx.closePath(); ctx.fillPath()
ctx.setStrokeColor(CGColor(gray: 0.9, alpha: 0.6)); ctx.setLineWidth(5); ctx.setLineCap(.round); ctx.move(to: CGPoint(x:512,y:265)); ctx.addCurve(to:CGPoint(x:510,y:110),control1:CGPoint(x:420,y:205),control2:CGPoint(x:605,y:175));ctx.strokePath()
ctx.saveGState();ctx.translateBy(x:364,y:726);ctx.rotate(by: -0.43);ctx.setFillColor(CGColor(gray:1,alpha:0.65));ctx.fillEllipse(in:CGRect(x:-20,y:-65,width:40,height:130));ctx.restoreGState()
let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath:out))
