//-----------------------------------
//-Singularity Studios Cardioid Walk-
//-	 Made by Philip Haynes      -
//-	 for no reason at all       -
//-		Enjoy!              -
//-----------------------------------
// Added pan/zoom - @emackey
#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
varying vec2 surfacePosition;

vec3 lerp(vec3 a, vec3 b, float i)
{
	return a*i+b*(1.-i);
}
float sqr(float a) {
	return a*a;
}

void main( void ) {
	vec2 position = surfacePosition * 2.0;
	float speed = .25;
	vec3 color = vec3(0.,0.,0.);
	vec3 c1 = vec3(1.,0.5,.25);
	vec3 c2 = vec3(0.,0.,1.);
	vec3 c3 = vec3(1.,0.25,0.5);
	vec2 c, z, nz, loc;
	float its, its2;
	float dist = 0.;
	c = position;
	z = c;
	loc.x = cos(time/4.*speed)/1.9-cos(time/2.*speed)/3.8;
	loc.y = sin(time/4.*speed)/1.9-sin(time/2.*speed)/3.8;
	float leng = pow((sqr(position.x-loc.x)+sqr(position.y-loc.y))*16.,.01);
	color+=max(c3-c3*leng,0.)*32.;
	for(int itss = 0; itss < 200; itss+=1)
	{
		nz.x = z.x*z.x-z.y*z.y+loc.x;
		nz.y = 2.*z.x*z.y+loc.y;
		z = nz;
		its = float(itss);
		if((z.x*z.x+z.y*z.y) >= 4.)
			break;
	}
	color += c1*its/25.;;
	z = c;
	for(int itss = 0; itss < 200; itss+=1)
	{
		nz.x = z.x*z.x-z.y*z.y+c.x;
		nz.y = 2.*z.x*z.y+c.y;
		z = nz;
		its2 = float(itss);
		if((z.x*z.x+z.y*z.y) >= 4.)
			break;
	}
	color += c2*its2/200.;
	
	gl_FragColor = vec4( color, 1.0 );

}