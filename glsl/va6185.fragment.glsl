#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

// a raymarching experiment by kabuto
//fork by tigrou ind (2013.01.22)
//Funky texturing by T21

float rand(vec3 n, float res){
  n = floor(n*res);
  return fract(sin((n.x+n.y*1e1+n.z*1e2)*1e-1)*1e5);
}

const int MAXITER = 30;

vec3 field(vec3 p) {
	p *= .1;
	float f = .1;
	for (int i = 0; i < 3; i++) {
		p = p.yzx*mat3(.8,.6,0,-.6,.8,0,0,0,1);
		p += vec3(.123,.456,.789)*float(i);
		p = abs(fract(p)-.5);
		p *= 3.0;
		f *= 3.0;
	}
	p *= p;
	return sqrt(p+p.yzx)/f-.05;
}

void main( void ) {
	vec3 dir = normalize(vec3((gl_FragCoord.xy-resolution*.5)/resolution.x,1.));
	float a = time * 0.1;
	vec3 pos = vec3(0.0,time*0.1,0.0);
	dir *= mat3(1,0,0,0,cos(a),-sin(a),0,sin(a),cos(a));
	dir *= mat3(cos(a),0,-sin(a),0,1,0,sin(a),0,cos(a));
	vec3 color = vec3(0);
	for (int i = 0; i < MAXITER; i++) {
		vec3 f2 = field(pos);
		float f = min(min(f2.x,f2.y),f2.z);
		
		pos += dir*f;
		color += float(MAXITER-i)/(f2+.01);
	}
	vec3 color3 = vec3(1.-1./(1.+color*(.09/float(MAXITER*MAXITER))));
	color3 *= color3;
	gl_FragColor = vec4(mix(color3, vec3(dot(color3, color3)), rand(pos, 10.)+.5),1.);
}