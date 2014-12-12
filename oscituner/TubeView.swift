import UIKit
import GLKit
import OpenGLES

class GLEditorView: GLKView {
    var blured: Int
    var table: [String: [[Float]]]

    override func drawRect(rect: CGRect) {
        glClearColor(0.1, 0.3, 0.9, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }

    func init(width: Int, height: Int) {
        var pixels [Byte] // width * height * 4)

        blured = glGenTexture()
        glActiveTexture(GL_TEXTURE0)
        glBind(GL_TEXTURE_2D)

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, &pixels)

        rb = glGenRenderbuffer()
        glBindFramebuffer()
        gl.RenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height)
        glUnbindFramebuffer()

        fb = gl.GenFramebuffer()
        glBindBuffer(fb)
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, blured, 0);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER);

        status = glCheckFramebufferStatus(GL_FRAMEBUFFER);

        if status != GL_FRAMEBUFFER_COMPLETE {
            NSLog("failed to make complete framebuffer object @", status);
            switch status {
            case GL_FRAMEBUFFER_COMPLETE:
                NSLog("failed to make complete framebuffer object");
            case GL_FRAMEBUFFER_UNDEFINED:
                NSLog("target is the default framebuffer, but the default framebuffer does not exist.")
            case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
                NsLog("any of the framebuffer attachment points are framebuffer incomplete")
            case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
                NSLog("the framebuffer does not have at least one image attached to it.")
            case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER:
                NSLog("the value of GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE is GL_NONE for any color attachment point(s) named by GL_DRAW_BUFFERi.")
            case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER:
                NSLog("GL_READ_BUFFER is not GL_NONE and the value of GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE is GL_NONE for the color attachment point named by GL_READ_BUFFER.")
            case GL_FRAMEBUFFER_UNSUPPORTED:
                NSLog("the combination of internal formats of the attached images violates an implementation-dependent set of restrictions.")
            case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE:
                NSLog("the value of GL_RENDERBUFFER_SAMPLES is not the same for all attached renderbuffers; if the value of GL_TEXTURE_SAMPLES is the not same for all attached textures; or, if the attached images are a mix of renderbuffers and textures, the value of GL_RENDERBUFFER_SAMPLES does not match the value of GL_TEXTURE_SAMPLES.")
                NSLog("the value of GL_TEXTURE_FIXED_SAMPLE_LOCATIONS is not the same for all attached textures; or, if the attached images are a mix of renderbuffers and textures, the value of GL_TEXTURE_FIXED_SAMPLE_LOCATIONS is not GL_TRUE for all attached textures.")
            case GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS:
                NSLog("is returned if any framebuffer attachment is layered, and any populated attachment is not layered, or if all populated color attachments are not from textures of the same target.")
            }
        }

        t.BuildGlyphTable()
        t.fb.Unbind()

        return &t
    }

    func Render(draw: func()) {
        glBindFramebuffer(GL_FRAMEBUFFER, fb)
        draw()
        glUnbindFramebuffer(fb)
    }


    func GenerateTextPolyline(x0, y0, width, height, step:  Float, text: String) -> [[Float]] {
        var result: [[Float]]
        var x = x0
        for _, s in text {
            var glyph = table[s]

            if glyph == nil {
                glyph = table["_"]
            }

            for _, line in glyph {
                var resizedLine = [Float](count: line.count)

                for var j = 0; j < line.count; j += 2 {
                    resizedLine[j] = x + width * line[j]
                    resizedLine[j+1] = y0 + height * line[j+1]
                }

                result = append(result, resizedLine)
            }

            x += step
        }

        return result
    }

    func BuildGlyphTable() {
        table["1"] = [[1, 0, 1, 1]]
        table["2"] = [[1, 0, 0, 0, 0, 0.5, 1.0, 0.5, 1.0, 1.0, 0, 1.0]]
        table["3"] = [[0, 0, 1, 0, 1, 1, 0, 1], [0, 0.5, 1, 0.5]]
        table["4"] = [[1, 0, 1, 1], [0, 1, 0, 0.5, 1, 0.5]]
        table["5"] = [[0, 0, 1, 0, 1, 0.5, 0, 0.5, 0, 1, 1, 1]]
        table["6"] = [[0, 0.5, 0, 0, 1, 0, 1, 0.5, 0, 0.5, 0, 1, 1, 1]]
        table["7"] = [[0, 1, 1, 1, 1, 0]]
        table["8"] = [[0, 0, 0, 1, 1, 1, 1, 0, 0, 0], [0, 0.5, 1, 0.5]]
        table["9"] = [[0, 0, 1, 0, 1, 0.5, 0, 0.5, 0, 1, 1, 1, 1, 0.5]]
        table["0"] = [[0, 0, 0, 1, 1, 1, 1, 0, 0, 0]]
        table[","] = [[0.6, 0.1, 0.4, -0.1]]
        table["."] = [[0.6, 0.1, 0.4, -0.1]]
        table["H"] = [[0, 0, 0, 1], [1, 0, 1, 1], [0, 0.5, 1, 0.5]]
        table["z"] = [[1, 0, 0, 0, 1, 0.5, 0, 0.5]]
        table["3"] = [[0, 0, 1, 0, 1, 1, 0, 1], [0, 0.5, 1, 0.5]]
        table["_"] = [[0, 0, 1, 0]]
        table[" "] = []
    }
}
