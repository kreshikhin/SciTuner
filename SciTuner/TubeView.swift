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
    
    var drawingProgram: GLuint = 0
    var textureProgram: GLuint = 0
    var blendProgram: GLuint = 0
    
    var wavePoints = [Float]()
    var spectrumPoints = [Float]()
    var frequency = String()
    let lineWidth: GLfloat = 1
    
    let foreColor: [Float] = [0.7, 0.9, 0.7, 0]
    let backColor: [Float] = [0.05, 0.15, 0.05, 0]
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        prepareTable()

        self.context = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        EAGLContext.setCurrentContext(self.context)

        glClearColor(backColor[0], backColor[1], backColor[2], 0)
        glColor4f(foreColor[0], foreColor[1], foreColor[2], 0)

        drawingProgram = newProgram(
        "    attribute vec4 a_position;" +
        "    void main() {" +
        "       gl_Position = a_position;" +
        "    }",
        fragmentCode:
        "    precision highp float; " +
        "    uniform vec4 color;" +
        "    void main() {" +
        "        gl_FragColor = color;" +
        "    }")

        textureProgram = newProgram(
        "    attribute vec4 a_position;" +
        "    attribute vec2 a_coord;" +
        "    varying vec2 v_coord;" +
        "    void main() {" +
        "        gl_Position = a_position;" +
        "        v_coord = a_coord;" +
        "    }",
        fragmentCode:
        "   precision highp float; " +
        "   varying vec2 v_coord;" +
        "   uniform sampler2D s_picture;" +
        "   void main() {" +
        "       float d = 0.0015;" +
        "       vec4 c0 = texture2D(s_picture, v_coord + vec2(d,d));" +
        "       vec4 c1 = texture2D(s_picture, v_coord + vec2(-d,d));" +
        "       vec4 c2 = texture2D(s_picture, v_coord + vec2(d,-d));" +
        "       vec4 c3 = texture2D(s_picture, v_coord + vec2(-d,-d));" +
        "       vec4 c = c0 + c1 + c2 + c3;" +
        "       gl_FragColor = texture2D(s_picture, v_coord) * 0.2 + c * 0.2;" +
        "   }")

        blendProgram = newProgram(
        "   attribute vec4 a_position;" +
        "   attribute vec2 a_coord;" +
        "   varying vec2 v_coord;" +
        "   void main() {" +
        "       gl_Position = a_position;" +
        "       v_coord = a_coord;" +
        "   }",
        fragmentCode:
        "   precision highp float; " +
        "   varying vec2 v_coord;" +
        "   uniform sampler2D s_picture;" +
        "   void main() {" +
        "       float k = 0.5;" +
        "       gl_FragColor = k * texture2D(s_picture, v_coord) + (1.0 - k) * vec4(125.0/256.0, 155.0/256.0, 125.0/256.0, 0);" +
        "   }")
        
        prepareTubeBuffer()
    }

    override func drawRect(rect: CGRect) {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

        var text = self.frequency //"123.45 Hz"

        /*renderInFramebuffer({ () -> () in
            self.capture(self.blendProgram)
            self.drawPoints(self.wavePoints)
            self.drawPoints(self.spectrumPoints)
            self.drawText(text)
        })*/
        
        self.bindDrawable()

        //capture(textureProgram)
        drawPoints(wavePoints)
        drawPoints(spectrumPoints)
        drawText(text)
    }

    func drawPoints(points: [Float]) {
        glUseProgram(drawingProgram)

        glLineWidth(lineWidth)

        var col = glGetUniformLocation(drawingProgram, "color")
        glUniform4f(col, foreColor[0], foreColor[1], foreColor[2], 0)

        var a_position: GLuint = GLuint(glGetAttribLocation(drawingProgram, "a_position"))
        glVertexAttribPointer(a_position, 2, GLenum(GL_FLOAT), GLboolean(0), 0 , points)
        glEnableVertexAttribArray(GLuint(a_position))

        glDrawArrays(GLenum(GL_LINE_STRIP), 0, GLsizei(points.count / 2))
        //glFlush()
    }

    func drawText(text: String) {
        var polyline = generateTextPolyline(0, y0: 0, width: 0.05, height: 0.1, step: 0.07, text: text)

        for line in polyline {
            glUseProgram(drawingProgram)

            glLineWidth(lineWidth)

            var col = glGetUniformLocation(drawingProgram, "color")
            glUniform4f(col, foreColor[0], foreColor[1], foreColor[2], 0)

            var a_position: GLuint = GLuint(glGetAttribLocation(drawingProgram, "a_position"))
            glVertexAttribPointer(a_position, 2, GLenum(GL_FLOAT), GLboolean(0), 0 , line)
            glEnableVertexAttribArray(GLuint(a_position))

            glDrawArrays(GLenum(GL_LINE_STRIP), 0, GLsizei(line.count / 2))
            //glFlush()
        }
    }

    func capture(program: GLuint){
        //glClear(GLenum(GL_COLOR_BUFFER_BIT))
        glUseProgram(program)

        var vertices: [Float] = [-1, -1, -1, 1, 1, -1, 1, 1]
        var texturePoints: [Float] = [0.0, 0.0, 0.0, 1.0,   1.0, 0.0, 1.0, 1.0]

        var s_picture = glGetUniformLocation(program, "s_picture")
        glUniform1i(s_picture, 0)

        glPixelStorei(GLenum(GL_UNPACK_ALIGNMENT), GLint(GL_UNSIGNED_BYTE));
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLint(GL_NEAREST));

        var a_position: GLuint = GLuint(glGetAttribLocation(program, "a_position"))
        glVertexAttribPointer(a_position, 2, GLenum(GL_FLOAT), GLboolean(0), 0 , vertices)
        glEnableVertexAttribArray(GLuint(a_position))

        var a_coord: GLuint = GLuint(glGetAttribLocation(program, "a_coord"))
        glVertexAttribPointer(a_coord, 2, GLenum(GL_FLOAT), GLboolean(0), 0 , texturePoints)
        glEnableVertexAttribArray(GLuint(a_coord))

        glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, GLsizei(vertices.count / 2))
        //glFlush()
    }

    func prepareTubeBuffer() {
        var width: GLsizei = 256
        var height: GLsizei = 256
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
            switch status {
            case GLenum(GL_FRAMEBUFFER_COMPLETE):
                NSLog("failed to make complete framebuffer object")
            case GLenum(GL_FRAMEBUFFER_UNDEFINED):
                NSLog("target is the default framebuffer, but the default framebuffer does not exist.")
            case GLenum(GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT):
                NSLog("any of the framebuffer attachment points are framebuffer incomplete")
            case GLenum(GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT):
                NSLog("the framebuffer does not have at least one image attached to it.")
            case GLenum(GL_FRAMEBUFFER_UNSUPPORTED):
                NSLog("the combination of internal formats of the attached images violates an implementation-dependent set of restrictions.")
            case GLenum(GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE):
                NSLog("the value of GL_RENDERBUFFER_SAMPLES is not the same for all attached renderbuffers; if the value of GL_TEXTURE_SAMPLES is the not same for all attached textures; or, if the attached images are a mix of renderbuffers and textures, the value of GL_RENDERBUFFER_SAMPLES does not match the value of GL_TEXTURE_SAMPLES.")
                NSLog("the value of GL_TEXTURE_FIXED_SAMPLE_LOCATIONS is not the same for all attached textures; or, if the attached images are a mix of renderbuffers and textures, the value of GL_TEXTURE_FIXED_SAMPLE_LOCATIONS is not GL_TRUE for all attached textures.")
            default:
                NSLog("unknown framebuffer error")
            }
        }

        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }

    func renderInFramebuffer(draw: (() -> ())) {
        glViewport(0, 0, 256, 256)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fb)
        draw()
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }


    func generateTextPolyline(x0: Float, y0: Float, width: Float, height: Float, step: Float, text: String) -> [[Float]] {
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


    func newProgram(vertexCode: String, fragmentCode: String) -> GLuint {
        var program = glCreateProgram()

        var vertexShader = compileShader(vertexCode, shaderType: GLenum(GL_VERTEX_SHADER))
        var fragmentShader = compileShader(fragmentCode, shaderType: GLenum(GL_FRAGMENT_SHADER))

        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)

        glLinkProgram(program)

        var isLinked: GLint = 0

        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &isLinked)
        NSLog(" linked: %i ", isLinked)

        if isLinked == 0 {
            var infolen: GLsizei = 0
            var stringLen: GLsizei = 1024
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &infolen)

            var info: [GLchar] = Array(count: Int(stringLen), repeatedValue: GLchar(0))
            var lenActual: GLsizei = 0

            glGetProgramInfoLog(program, stringLen, &lenActual, UnsafeMutablePointer(info))
            NSLog(String(UTF8String:info)!)
        }

        return program
    }

    func compileShader(code: String, shaderType: GLenum) -> GLuint {
        var shader = glCreateShader(shaderType)

        var cStringSource = (code as NSString).UTF8String
        let stringfromutf8string = String.fromCString(cStringSource)

        glShaderSource(shader, GLsizei(1), &cStringSource, nil)
        glCompileShader(shader);

        var isCompiled: GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &isCompiled)
        NSLog(" is compiled : %i ", isCompiled)

        if isCompiled == 0 {
            var infolen: GLsizei = 0
            var stringLen: GLsizei = 1024
            glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &infolen)

            var info: [GLchar] = Array(count: Int(stringLen), repeatedValue: GLchar(0))
            var lenActual: GLsizei = 0

            glGetShaderInfoLog(shader, stringLen, &lenActual, UnsafeMutablePointer(info))
            NSLog(String(UTF8String:info)!)
        }

        return shader
    }
}
