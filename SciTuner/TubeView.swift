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
    var onDraw: (rect: CGRect)->() = { (rect: CGRect) -> () in
    }
    
    var drawingProgram: GLuint = 0
    
    var wavePoints = [Float]()
    var waveLightPoints = [Float]()
    
    var spectrumPoints = [Float]()
    var frequency = String()
    let lineWidth: GLfloat = 5
    
    let foreColor: [Float] = [1.0, 1.0, 1.0, 0]
    let backColor: [Float] = [0.0, 0.0, 0.35, 0]
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.context = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        EAGLContext.setCurrentContext(self.context)

        glClearColor(backColor[0], backColor[1], backColor[2], 0)
        glColor4f(foreColor[0], foreColor[1], foreColor[2], 0)
        
        glEnable(GLenum(GL_BLEND));
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
        

        drawingProgram = newProgram(
        "    attribute vec2 a_position;" +
        "    attribute vec4 a_light;" +
        "    varying vec4 light;" +
        "    varying vec2 v_coord;" +
        "    void main() {" +
        "       light = a_light; " +
        "       v_coord = a_position.xy; " +
        "       gl_Position = vec4(0.9*a_position.xy, 0, 1);" +
        "    }",
        fragmentCode:
        "   precision highp float; " +
        "   uniform vec4 color;" +
        "   varying vec4 light;" +
        "   varying vec2 v_coord;" +
        "   float DistToLine(vec2 pt1, vec2 pt2, vec2 testPt) {" +
        "       vec2 lineDir = normalize(pt2 - pt1);" +
        "       float len = length(pt2 - pt1);" +
        "       vec2 perpDir = vec2(lineDir.y, -lineDir.x);" +
        "       vec2 toTest = testPt - pt1;" +
        "       float proj = dot(lineDir, toTest);" +
        "       if(proj < 0.0 ){ " +
        "           return distance(testPt, pt1);" +
        "       }" +
        "       if(proj > len){ " +
        "           return distance(testPt, pt2);" +
        "       }" +
        "       return abs(dot(perpDir, toTest)); " +
        "   }" +
        "   void main() {" +
        "       float d = DistToLine(light.xy, light.zw, v_coord.xy);" +
        "       float min_d = 0.01;" +
        "       float max_d = 0.02;" +
        "       float alpha = 1.0;" +
        "       if (min_d<d && d<max_d) alpha = (max_d-d)/(max_d - min_d);" +
        "       if (d > max_d) discard;" +
        "       gl_FragColor = vec4(color.rgb, alpha);" +
        "   }")
    }

    override func drawRect(rect: CGRect) {
        self.onDraw(rect: rect)
    }

    func drawPoints(points: [Float], lightPoints: [Float]) {
        glUseProgram(drawingProgram)

        glLineWidth(lineWidth)

        var col = glGetUniformLocation(drawingProgram, "color")
        glUniform4f(col, foreColor[0], foreColor[1], foreColor[2], 0.0)
        
        var a_position: GLuint = GLuint(glGetAttribLocation(drawingProgram, "a_position"))
        glVertexAttribPointer(a_position, 2, GLenum(GL_FLOAT), GLboolean(0), 0 , points)
        glEnableVertexAttribArray(GLuint(a_position))
        
        var a_light: GLuint = GLuint(glGetAttribLocation(drawingProgram, "a_light"))
        glVertexAttribPointer(a_light, 4, GLenum(GL_FLOAT), GLboolean(0), 0 , lightPoints)
        glEnableVertexAttribArray(GLuint(a_light))
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(points.count / 2))
        //glFlush()
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
