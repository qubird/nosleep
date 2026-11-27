// Generates AppIcon.icns from the same strained-eye artwork used in the menu bar.
// Usage: swiftc make_icon.swift icons.swift -o make_icon -framework Cocoa && ./make_icon
import Cocoa

let S: CGFloat = 1024
let master = NSImage(size: NSSize(width: S, height: S), flipped: false) { rect in
    // macOS icon grid: 824pt squircle centred in a 1024pt canvas
    let body = rect.insetBy(dx: 100, dy: 100)
    let shape = NSBezierPath(roundedRect: body, xRadius: 184, yRadius: 184)

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor(white: 0, alpha: 0.35)
    shadow.shadowOffset = NSSize(width: 0, height: -10)
    shadow.shadowBlurRadius = 24
    shadow.set()
    NSColor.black.setFill()
    shape.fill()
    NSGraphicsContext.restoreGraphicsState()

    NSGradient(colors: [NSColor(red: 0.16, green: 0.17, blue: 0.30, alpha: 1),
                        NSColor(red: 0.04, green: 0.04, blue: 0.09, alpha: 1)])!.draw(in: shape, angle: -90)

    // soft highlight along the top edge
    NSGraphicsContext.saveGraphicsState()
    shape.addClip()
    NSGradient(colors: [NSColor(white: 1, alpha: 0.10), NSColor(white: 1, alpha: 0)])!
        .draw(in: NSRect(x: body.minX, y: body.midY, width: body.width, height: body.height / 2), angle: -90)
    NSGraphicsContext.restoreGraphicsState()

    // the eye, tinted white
    let w: CGFloat = 600, h = w * Icons.size.height / Icons.size.width
    let eyeRect = NSRect(x: (S - w) / 2, y: (S - h) / 2 - 8, width: w, height: h)
    let eye = NSImage(size: eyeRect.size, flipped: false) { r in
        Icons.awake.draw(in: r)
        NSColor.white.setFill()
        r.fill(using: .sourceAtop)
        return true
    }
    eye.draw(in: eyeRect)
    return true
}

func writePNG(_ px: Int, to path: String) {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.imageInterpolation = .high
    master.draw(in: NSRect(x: 0, y: 0, width: px, height: px))
    NSGraphicsContext.restoreGraphicsState()
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

let fm = FileManager.default
let iconset = "AppIcon.iconset"
try? fm.removeItem(atPath: iconset)
try! fm.createDirectory(atPath: iconset, withIntermediateDirectories: true)
for base in [16, 32, 128, 256, 512] {
    writePNG(base,     to: "\(iconset)/icon_\(base)x\(base).png")
    writePNG(base * 2, to: "\(iconset)/icon_\(base)x\(base)@2x.png")
}
writePNG(1024, to: "AppIcon-preview.png")
