//
//  TubeView.swift
//  oscituner
//
//  Created by Denis Kreshikhin on 13.12.14.
//  Copyright (c) 2014 Denis Kreshikhin. All rights reserved.
//

import UIKit
import GLKit
import OpenGLES

class TubeView: GLKView{
    var fb: GLuint = 0
    var rb: GLuint = 0
    var blured: GLuint = 0
    var table: [Character: [[Float]]] = [Character: [[Float]]]()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareTable()
        
        self.context = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        EAGLContext.setCurrentContext(self.context)
        
        glClearColor(0.5, 0.5, 0.5, 0.5)
    }
    
    override func drawRect(rect: CGRect) {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    func prepareTubeBuffer() {
        var width: GLsizei = 512
        var height: GLsizei = 512
        var pixels = [Byte](count: Int(width * height * 4), repeatedValue: 0)

        glGenTextures(1, &blured);
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), blured)

        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, width, height, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), &pixels)

        glGenRenderbuffers(1, &rb)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), rb)
        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16), width, height)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), 0) // unbind

        glGenFramebuffers(1, &fb)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fb)
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), blured, 0);
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), rb);

        var status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER));

        if status != GLenum(GL_FRAMEBUFFER_COMPLETE) {
            NSLog("failed to make complete framebuffer object @", status);
            /*switch status {
            case GLenum(GL_FRAMEBUFFER_COMPLETE):
                NSLog("failed to make complete framebuffer object")
            case GLenum(GL_FRAMEBUFFER_UNDEFINED):
                NSLog("target is the default framebuffer, but the default framebuffer does not exist.")
            case GLenum(GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT):
                NSLog("any of the framebuffer attachment points are framebuffer incomplete")
            case GLenum(GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT):
                NSLog("the framebuffer does not have at least one image attached to it.")
            //case GLenum(GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER):
            //    NSLog("the value of GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE is GL_NONE for any color attachment point(s) named by GL_DRAW_BUFFERi.")
            //case GLenum(GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER):
            //    NSLog("GL_READ_BUFFER is not GL_NONE and the value of GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE is GL_NONE for the color attachment point named by GL_READ_BUFFER.")
            case GLenum(GL_FRAMEBUFFER_UNSUPPORTED):
                NSLog("the combination of internal formats of the attached images violates an implementation-dependent set of restrictions.")
            case GLenum(GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE):
                NSLog("the value of GL_RENDERBUFFER_SAMPLES is not the same for all attached renderbuffers; if the value of GL_TEXTURE_SAMPLES is the not same for all attached textures; or, if the attached images are a mix of renderbuffers and textures, the value of GL_RENDERBUFFER_SAMPLES does not match the value of GL_TEXTURE_SAMPLES.")
                NSLog("the value of GL_TEXTURE_FIXED_SAMPLE_LOCATIONS is not the same for all attached textures; or, if the attached images are a mix of renderbuffers and textures, the value of GL_TEXTURE_FIXED_SAMPLE_LOCATIONS is not GL_TRUE for all attached textures.")
            //case GLenum(GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS):
            //    NSLog("is returned if any framebuffer attachment is layered, and any populated attachment is not layered, or if all populated color attachments are not from textures of the same target.")
            default:
                NSLog("unknown framebuffer error")
            }*/
        }

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }

    func Render(draw:() -> ()) {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fb)
        draw()
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }


    func GenerateTextPolyline(x0: Float, y0: Float, width: Float, height: Float, step: Float, text: String) -> [[Float]] {
        var result = [[Float]]()
        var x = x0
        for s in text {
            var glyph = table[s]

            if glyph == nil {
                glyph = table["_"]
            }

            for line in glyph! {
                var resizedLine = [Float](count: line.count, repeatedValue: 0)

                for var j = 0; j < line.count; j += 2 {
                    resizedLine[j] = x + width * line[j]
                    resizedLine[j+1] = y0 + height * line[j+1]
                }
                
                result.append(resizedLine)
            }

            x += step
        }

        return result
    }

    func prepareTable() {
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

