#version 100

#ifdef GL_ES
precision mediump float;
#endif

// Distance fields raymarching, again. IQ will not cease to amuse us !

//
// GLSL 2D simplex noise function by Ian McEwan, Ashima Arts.
// https://github.com/ashima/webgl-noise
//

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187, // (3.0-sqrt(3.0))/6.0
                      0.366025403784439, // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626, // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i = floor(v + dot(v, C.yy) );
  vec2 x0 = v - i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
+ i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x = a0.x * x0.x + h.x * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

/// ------------------------ GLSL noise ends here -----------

float rand(in vec2 co)
{
        // implementation found at: lumina.sourceforge.net/Tutorials/Noise.html
        return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

#define ITER_MAX 50
#define MAX_DIST 13.0
#define EPS 0.01
#define AO_EPS 0.05
#define AO_SAMPLES 5


struct Material
{
	// Let's not bother with complex materials, 1 color will be enough
	vec3 color;
	float hardness;
};
	

float sphere(in vec3 p, float radius)
{
	return length(p) - radius;
}

float box(in vec3 p, in vec3 sz)
{
	return length(max(abs(p) - sz, 0.0));	
}

vec3 opRepNoZ(vec3 p, vec3 c)
{
	vec3 q = mod(p, c) - 0.5 * c;

	q.z = p.z;

	return q;
}

vec3 opTranslate(vec3 p, vec3 t)
{
	return p + t;
}

float Wall(in vec3 p)
{
	#define BRICK vec3(0.07, 0.03, 0.015)
	#define BRICK_ROW vec3(0.16, 0.16, 1.0)
	
	float n = snoise(p.yx * 100.0) ;
	float f1 = box(opRepNoZ(p, BRICK_ROW), BRICK) ;
	float f2 = box(opRepNoZ(opTranslate(p, vec3(0.08, 0.08, 0.0)), BRICK_ROW), BRICK) ;

	return min(f1, f2);
}

Material WallMat()
{
	Material m;
	
	m.color = vec3(1.0, 0.0, 0.0);
	m.hardness = 32.0;
	return m;
}

float FMat(in vec3 p, out Material mat)
{
	float dWall = Wall(p);
	mat = WallMat();
	
	return dWall;
}

float F(in vec3 p)
{
	float dWall = Wall(p);
	
	return dWall;
}

vec3 getNormal(vec3 p)
{
	vec3 e = vec3(0.0, EPS, 0.0);
	vec3 n = vec3(F(p + e.yxx) - F(p - e.yxx),
                      F(p + e.xyx) - F(p - e.xyx),
                      F(p + e.xxy) - F(p - e.xxy));
        n = normalize(n);
        return n;
}


float getAO(in vec3 p, in vec3 n)
{
	#define Dither 0.001
	float ao = 0.0;
        float de = F(p);
        float sum = 0.0;
        float w = 1.0;
    	float d = 1.0 - (Dither * rand(p.xy));

        for (float i = 1.0; i < float(AO_SAMPLES) + 1.0; i++)
        {
                float dist = (F(p + d * n * pow(i, 2.0) * AO_EPS) - de) / (d * pow(i, 2.0) * AO_EPS);
                w *= 0.6; //decay
                ao += w * clamp(1.0 - dist, 0.0, 1.0);
                sum += w;
        }
        return 1.0 - clamp(ao / sum, 0.0, 1.0);	
}

float softshadow(in vec3 p, in vec3 d, float k)
{
	float res = 1.0;
	float h = 0.01;
	float dist = 0.01;
	
	for (int i = 0; i < ITER_MAX; i++)
	{
        	h = F(p + d * dist);

	        if (h < 0.001)
			return 0.0;

		res = min(res, k * h / dist);
		dist += h;
	}
	return clamp(res, 0.0, 1.0);
}

vec3 rayCast(in vec3 o, in vec3 d)
{
	float dist = 0.0;
	float totalDist = 0.0;
	vec3 FogColor = vec3(0.5);
	vec3 color = FogColor * 0.5;
	float minDist = 0.05;
	
	vec3 LightPos = vec3(2.0, 2.5, 5.0);
	float lightIntensity = abs(rand(vec2(sin(time * 10.0), cos(time * 10.0)))) / 20.0 + 0.8;
	vec3 LightColor = vec3(0.8, 0.8, 0.8) * lightIntensity;
	
	Material material;
	
	for (int step = 0; step < ITER_MAX; step++)
	{
		vec3 p = o + totalDist * d;
		dist = FMat(p, material);
		totalDist += dist;
	
		if (abs(dist) < 0.1)
			break;
		
		if (totalDist > MAX_DIST)
		{
			totalDist = MAX_DIST;
			break;
		}
	}
	
	vec3 P = o + totalDist * d;
	
	// hit
	if (dist < 0.1)
	{
		vec3 N = getNormal(P);
		vec3 L = normalize(LightPos - P);
                vec3 V = normalize(o - P);
                vec3 H = normalize(V + L);		//vec3 V, H
		//float falloff = ...
		
		float ambient = max(0.1, dot(N, d));
		float diffuse = max(0.0, dot(N, L));
		float specular = pow(max(0.0, dot(N, H)), material.hardness);
		
		//float spec = todo
		float ao = getAO(P, N);
		
		color = (material.color *  LightColor * diffuse) + // diffuse
			(LightColor * specular) + // specular
			(material.color * ambient);
	
		color *= ao;
		color *= softshadow(P, normalize(LightPos - P), 16.0 * lightIntensity);
	}

	float lightAngle = dot(normalize(o - LightPos), d);
	

	//color *= vec3(shade(o, P, d, LightPos));
	//color = mix(color, FogColor, smoothstep(0.0, 1.0, totalDist / MAX_DIST));
	//color += pow(lightAngle, 16.0) * LightColor;

	
	return color;
}

void main( void )
{

	vec2 texcoord = gl_FragCoord.xy / resolution;
	vec2 pix = -1.0 + 2.0 * texcoord;
	pix.x *= resolution.x / resolution.y;
	pix.x = -pix.x;

	float r = 4.0;
	//vec3 campos = vec3(r * cos(mouse.x * 10.0), /*mouse.y * 4.0*/ 3.0, r * sin(mouse.x * 10.0));
	vec3 campos = vec3(0.0, 1.0, 2.0);
	
	vec3 camLookAt = vec3(0.0);
	vec3 upVector = vec3(0.0, 1.0, 0.0);

	vec3 rayOrigin = campos;
	vec3 ww = normalize(camLookAt - rayOrigin);
	vec3 uu = normalize(cross(upVector, ww));
	vec3 vv = normalize(cross(ww, uu));
	vec3 rayDir = normalize(pix.x * uu + pix.y * vv + 1.5 * ww);

	vec3 color = rayCast(rayOrigin, rayDir);
	
	
	gl_FragColor = vec4(color, 1.0);
	
	// noise
	
	if (texcoord.x > 1.0)
	{
		gl_FragColor += snoise(texcoord * rand(texcoord) * time * 10.0) / 8.0;
        	// vignetting
		vec2 vignet = vec2(1.0, .3);
        	float vd = distance(texcoord, vec2(0.5,0.5));
        	gl_FragColor *= smoothstep(vignet.x, vignet.y, vd);
	}
	
}