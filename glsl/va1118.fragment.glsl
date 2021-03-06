#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

void main( void ) {

	vec2 position = gl_FragCoord.xy * 0.1;
	
	float color = 1.5;
	color += sin(position.x) - (fract(position.y));
	color -= cos(position.y) - (fract(position.x));

	gl_FragColor = vec4( vec3( color, color, color ), 1.0 );

}