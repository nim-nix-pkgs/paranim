import paranim/opengl
import paranim/gl, paranim/gl/uniforms
import paranim/math as pmath
import examples_common, examples_data
from bitops import bitor
from std/math import nil
import paranim/glm

var entity: ThreeDTextureEntity
var rx = degToRad(190f)
var ry = degToRad(40f)
const pattern = [GLubyte(128), GLubyte(64), GLubyte(128), GLubyte(0), GLubyte(192), GLubyte(0)]

proc init*(game: var Game) =
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_CULL_FACE)
  glEnable(GL_DEPTH_TEST)

  var image = Texture[GLubyte](
    opts: TextureOpts(
      mipLevel: 0,
      internalFmt: GL_R8,
      width: GLsizei(3),
      height: GLsizei(2),
      border: 0,
      srcFmt: GL_RED
    ),
    params: @[
      (GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE),
      (GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE),
      (GL_TEXTURE_MIN_FILTER, GL_NEAREST),
      (GL_TEXTURE_MAG_FILTER, GL_NEAREST)
    ],
    pixelStoreParams: @[(GL_UNPACK_ALIGNMENT, GLint(1))]
  )
  new(image.data)
  image.data[] = @pattern

  entity = compile(game, initThreeDTextureEntity(cube, cubeTexcoords, image))

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GLbitfield(bitor(GL_COLOR_BUFFER_BIT.ord, GL_DEPTH_BUFFER_BIT.ord)))
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))

  var camera = mat4f(1)
  camera.translate(0f, 0f, 2f)
  camera.lookAt(vec3(0f, 0f, 0f), vec3(0f, 1f, 0f))

  var e = entity
  e.project(degToRad(60f), float(game.frameWidth) / float(game.frameHeight), 1f, 2000f)
  e.invert(camera)
  e.rotateX(rx)
  e.rotateY(ry)
  render(game, e)

  rx += 1.2f * game.deltaTime
  ry += 0.7f * game.deltaTime

