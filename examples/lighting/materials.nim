
# OpenGL example using SDL2

import sdl2
import opengl
import easygl
import easygl.utils
import stb_image/read as stbi
import glm
import ../utils/camera_util
import times
import os

discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 800
var screenHeight: cint = 600

let window = createWindow("Materials", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
discard setRelativeMouseMode(true.Bool32)
discard window.glCreateContext()

# Initialize OpenGL
loadExtensions()

### Build and compile shader program
let appDir = getAppDir()
let lightingShader = CreateAndLinkProgram(appDir&"/shaders/materials.vert",appDir&"/shaders/materials.frag")
let lampShader = CreateAndLinkProgram(appDir&"/shaders/lamp.vert",appDir&"/shaders/lamp.frag")


Enable(Capability.DEPTH_TEST)

# Set up vertex data
let vertices : seq[float32]  =
  @[
    # positions                 

    -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,
    0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,
    0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,
    0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,
    -0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32,  0.0'f32, -1.0'f32,
    
    -0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32, 1.0'f32,
    0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32, 1.0'f32,
    0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32, 1.0'f32,
    0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32, 1.0'f32,
    -0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32, 1.0'f32,
    -0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32,  0.0'f32, 1.0'f32,
    
    -0.5'f32,  0.5'f32,  0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,
    -0.5'f32,  0.5'f32, -0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,
    -0.5'f32, -0.5'f32,  0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,
    -0.5'f32,  0.5'f32,  0.5'f32, -1.0'f32,  0.0'f32,  0.0'f32,
    
    0.5'f32,  0.5'f32,  0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,
    0.5'f32,  0.5'f32, -0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,
    0.5'f32, -0.5'f32, -0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,
    0.5'f32, -0.5'f32, -0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,
    0.5'f32, -0.5'f32,  0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,
    0.5'f32,  0.5'f32,  0.5'f32,  1.0'f32,  0.0'f32,  0.0'f32,
    
    -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,
    0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,
    0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,
    0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,
    -0.5'f32, -0.5'f32,  0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,
    -0.5'f32, -0.5'f32, -0.5'f32,  0.0'f32, -1.0'f32,  0.0'f32,
    
    -0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,
    0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,
    0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,
    0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,
    -0.5'f32,  0.5'f32,  0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32,
    -0.5'f32,  0.5'f32, -0.5'f32,  0.0'f32,  1.0'f32,  0.0'f32]

let cubeVAO = GenVertexArray()
let VBO = GenBuffer()

# Bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).HH
BindBuffer(BufferTarget.ARRAY_BUFFER,VBO)
BufferData(BufferTarget.ARRAY_BUFFER,vertices,BufferDataUsage.STATIC_DRAW)

BindVertexArray(cubeVAO)

VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,6*float32.sizeof(),0)
EnableVertexAttribArray(0)
VertexAttribPointer(1,3,VertexAttribType.FLOAT,false,6*float32.sizeof(),3*float32.sizeof())
EnableVertexAttribArray(1)

let lightVAO = GenVertexArray()
BindVertexArray(lightVAO)
BindBuffer(BufferTarget.ARRAY_BUFFER,VBO)
VertexAttribPointer(0,3,VertexAttribType.FLOAT,false,6*float32.sizeof(),0)
EnableVertexAttribArray(0)

var lightPos = vec3(0.5'f32,0.5'f32,1.0'f32)
var
  evt = sdl2.defaultEvent
  run = true

glViewport(0, 0, screenWidth, screenHeight)   # Set the viewport to cover the new window
let camera = newCamera(vec3(0.0'f32,0.0'f32,9.0'f32))

var currentTime,prevTime:float
prevTime=epochTime()
while run:  
  currentTime = epochTime()
  let keyState = getKeyboardState()
  let elapsedTime = (currentTime - prevTime).float32*10.0'f32
  prevTime = currentTime
  while pollEvent(evt):
    case evt.kind
        of QuitEvent:
            run = false
        of WindowEvent:
            var windowEvent = cast[WindowEventPtr](addr(evt))
            if windowEvent.event == WindowEvent_Resized:
                let newWidth = windowEvent.data1
                let newHeight = windowEvent.data2
                glViewport(0, 0, newWidth, newHeight)   # Set the viewport to cover the new window       
        of MouseWheel:
            var wheelEvent = cast[MouseWheelEventPtr](addr(evt))
            camera.ProcessMouseScroll(wheelEvent.y.float32)
        of MouseMotion:
            var motionEvent = cast[MouseMotionEventPtr](addr(evt))
            camera.ProcessMouseMovement(motionEvent.xrel.float32,motionEvent.yrel.float32)
        else:
            discard
             
  if keyState[SDL_SCANCODE_W.uint8] != 0:
    camera.ProcessKeyboard(FORWARD,elapsedTime)
  if keyState[SDL_SCANCODE_S.uint8] != 0:
    camera.ProcessKeyBoard(BACKWARD,elapsedTime)
  if keyState[SDL_SCANCODE_A.uint8] != 0:
    camera.ProcessKeyBoard(LEFT,elapsedTime)
  if keyState[SDL_SCANCODE_D.uint8] != 0:
    camera.ProcessKeyBoard(RIGHT,elapsedTime)
  if keyState[SDL_SCANCODE_ESCAPE.uint8] != 0:
    break

  # Render
  ClearColor(0.1,0.1,0.1,1.0)
  easygl.Clear(BufferMask.COLOR_BUFFER_BIT, BufferMask.DEPTH_BUFFER_BIT)

 
  lightingShader.Use()
  lightingShader.SetVec3("light.position", lightPos)
  lightingShader.SetVec3("viewPos",camera.Position)
  var lightColor = vec3(sin(currentTime).float32*4.0'f32, sin(currentTime).float32*1.7'f32, sin(currentTime).float32*2.3'f32)  
  var diffuseColor = lightColor * vec3(0.5'f32)
  var ambientColor = diffuseColor * vec3(0.2'f32)
  lightingShader.SetVec3("light.ambient",ambientColor)
  lightingShader.SetVec3("light.diffuse",diffuseColor)
  lightingShader.SetVec3("light.specular",1.0'f32,1.0'f32,1.0'f32)
  lightingShader.SetVec3("material.ambient", 1.0'f32,0.5'f32,0.31'f32)
  lightingShader.SetVec3("material.diffuse", 1.0'f32,0.5'f32,0.31'f32)
  lightingShader.SetVec3("material.specular", 0.5'f32,0.5'f32,0.5'f32)
  lightingShader.SetFloat("material.shininess", 32.0'f32)
  

  var projection = perspective(radians(camera.Zoom),screenWidth.float32/screenHeight.float32,0.1'f32,100.0'f32)
  var view = camera.GetViewMatrix()

  lightingShader.SetMat4("projection",projection)
  lightingShader.SetMat4("view",view)
  
  var model = mat4(1.0'f32)
  lightingShader.SetMat4("model",model)

  BindVertexArray(cubeVAO)
  DrawArrays(DrawMode.TRIANGLES,0,36)
  
  lampShader.Use()
  lampShader.SetMat4("projection",projection)
  lampShader.SetMat4("view",view)

  model = translate(model,lightPos)
  model = scale(model,vec3(0.2'f32))
  lampShader.SetMat4("model",model)
  BindVertexArray(lightVao)
  DrawArrays(DrawMode.TRIANGLES,0,36)

  window.glSwapWindow()

DeleteVertexArray(cubeVAO)
DeleteVertexArray(lightVAO)
DeleteBuffer(VBO)
destroy window
