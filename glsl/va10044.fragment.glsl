#define PROCESSING_COLOR_SHADER




#ifdef GL_ES
precision mediump float;
#endif

const float da = 3.14159/200.0;



const float Radius = 1.3320;
const float Power  = 0.6000;
const float Divider = 35.00000;

uniform float time;
uniform vec2  mouse;
uniform vec2  resolution;


const float R = 0.4;
const float G = 0.8;
const float B = 0.9;

const int Iterations = 50;

vec2 rot  = vec2(1.0, 0.0);
vec2 dir  = vec2(1.0, 0.0);
vec2 ddir = vec2(cos(da), sin(da));

vec3 doColor(int i, vec2 p, float d)
{
  // The color scheme here is based on one
  // from Inigo Quilez's Shader Toy:
  float co = float(i) + 1.0 - log2(.5*log2(dot(p,p)));
  co = sqrt(co/256.0);
  float  co2 = d * Divider;
  float fac = clamp(1.0/pow(co2,Power),0.0,1.0);
  
  return fac*vec3( .5+.5*cos(6.2831*co+R),
		   .5+.5*cos(6.2831*co+G),
		   .5+.5*cos(6.2831*co+B) );
}

vec2 cmul(vec2 a, vec2 b) 
{
  return vec2(a.x*b.x-a.y*b.y, a.x*b.y+a.y*b.x);
}

// double angle wrt positive-x axis
vec2 px2(vec2 z)
{
  float x = (z.x + z.y)*(z.x - z.y);
  float y = z.x * z.y;
  return vec2(x, y+y);
}

// double angle wrt direct line 'l' through origin, 
// square magnitude assuming 'l' is unit length
vec2 doubleAngle(vec2 p, vec2 l)
{
  float a = (p.x + p.y);
  float s = (p.x - p.y);
  float b = 2.0 * p.x * p.y;
  float x = l.y * b + a * s * l.x;   // (x-y)(x+y)cos(t) + 2xy sin(t)
  float y = l.x * b - a * s * l.y;   // (y-x)(x+y)sin(t) + 2xy cos(t)

  return vec2(x, y);
}

vec3 colorq(vec2 c, vec2 m)
{
  vec2 p = vec2(0.0);
  vec2 z;
  int  i = 0;
  float dist = 10000.0;
	
  for (int i = 0; i < Iterations; i++) {

    p    = doubleAngle(p, dir) + c;
    dir  = cmul(dir, ddir);
    dist = min(dist, abs(length(p)-Radius));
	  
    if (max(p.x*p.x,p.y*p.y)>1.) {
      return doColor(i, p, dist);
    }
  }
  return vec3( p*p,p.x*p.y);
}

void main(void) 
{
  vec2 position = (gl_FragCoord.xy / resolution.xy)* 2.0;// - vec2(-mouse.x,mouse.y)
  position.y*=resolution.y/resolution.x;

	
  vec2 mousePosition = vec2(mouse.x+0.5,0.5+mouse.y);
  float t = time * 0.5;
   rot = vec2(cos(t),sin(t));
position=cmul(0.75*position-mousePosition,rot); 
  vec3 c = colorq(position,mousePosition);  
  gl_FragColor.rgb = c;
  gl_FragColor.a   = 1.0;
}