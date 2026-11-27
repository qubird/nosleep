import Cocoa

/// Menu bar icons, drawn as template images (monochrome, adapt to light/dark menu bars).
enum Icons {
    static let size = NSSize(width: 20, height: 18)

    private static func stroke(_ p: NSBezierPath, _ w: CGFloat = 1.4) {
        p.lineWidth = w
        p.lineCapStyle = .round
        p.lineJoinStyle = .round
        NSColor.black.setStroke()
        p.stroke()
    }

    private static func line(_ a: NSPoint, _ b: NSPoint, _ w: CGFloat = 1.3) {
        let p = NSBezierPath()
        p.move(to: a); p.line(to: b)
        stroke(p, w)
    }

    /// Wide-open, strained eye: staring almond, ringed iris, pupil, red-eye veins and tension lines above.
    static let awake: NSImage = {
        let img = NSImage(size: size, flipped: false) { _ in
            let cy: CGFloat = 6.5
            let almond = NSBezierPath()
            almond.move(to: NSPoint(x: 1, y: cy))
            almond.curve(to: NSPoint(x: 19, y: cy), controlPoint1: NSPoint(x: 6, y: cy + 7), controlPoint2: NSPoint(x: 14, y: cy + 7))
            almond.curve(to: NSPoint(x: 1, y: cy), controlPoint1: NSPoint(x: 14, y: cy - 7), controlPoint2: NSPoint(x: 6, y: cy - 7))
            almond.close()
            stroke(almond)

            // iris ring + solid pupil
            stroke(NSBezierPath(ovalIn: NSRect(x: 10 - 3.4, y: cy - 3.4, width: 6.8, height: 6.8)), 1.2)
            NSColor.black.setFill()
            NSBezierPath(ovalIn: NSRect(x: 10 - 1.5, y: cy - 1.5, width: 3, height: 3)).fill()

            // bloodshot veins creeping in from the corners
            line(NSPoint(x: 2.6, y: cy + 0.2), NSPoint(x: 5.2, y: cy + 1.1), 1.0)
            line(NSPoint(x: 2.8, y: cy - 0.9), NSPoint(x: 5.0, y: cy - 1.8), 1.0)
            line(NSPoint(x: 17.4, y: cy + 0.2), NSPoint(x: 14.8, y: cy + 1.1), 1.0)
            line(NSPoint(x: 17.2, y: cy - 0.9), NSPoint(x: 15.0, y: cy - 1.8), 1.0)

            // tension lines above the eye
            line(NSPoint(x: 10, y: 14.3), NSPoint(x: 10, y: 17.2))
            line(NSPoint(x: 5.2, y: 13.2), NSPoint(x: 3.6, y: 15.8))
            line(NSPoint(x: 14.8, y: 13.2), NSPoint(x: 16.4, y: 15.8))
            return true
        }
        img.isTemplate = true
        img.accessibilityDescription = "NoSleep on"
        return img
    }()

    /// Closed eye: a relaxed downward arc with lashes.
    static let asleep: NSImage = {
        let img = NSImage(size: size, flipped: false) { _ in
            let p0 = NSPoint(x: 1.5, y: 11), p1 = NSPoint(x: 6, y: 4), p2 = NSPoint(x: 14, y: 4), p3 = NSPoint(x: 18.5, y: 11)
            let arc = NSBezierPath()
            arc.move(to: p0)
            arc.curve(to: p3, controlPoint1: p1, controlPoint2: p2)
            stroke(arc)

            func bezier(_ t: CGFloat) -> NSPoint {
                let u = 1 - t
                return NSPoint(
                    x: u*u*u*p0.x + 3*u*u*t*p1.x + 3*u*t*t*p2.x + t*t*t*p3.x,
                    y: u*u*u*p0.y + 3*u*u*t*p1.y + 3*u*t*t*p2.y + t*t*t*p3.y)
            }
            for (t, dx) in [(0.18, -0.9), (0.5, 0.0), (0.82, 0.9)] as [(CGFloat, CGFloat)] {
                let a = bezier(t)
                line(a, NSPoint(x: a.x + dx, y: a.y - 2.8))
            }
            return true
        }
        img.isTemplate = true
        img.accessibilityDescription = "NoSleep off"
        return img
    }()
}
