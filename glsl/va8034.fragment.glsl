#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

float w = resolution.x;
float h = resolution.y;

void main( void ) {
	float move = w / 15.0;
	vec2 pos1 = vec2(w * 0.5 + move * (sin(time)), h * 0.5);
	vec2 pos2 = vec2(w * 0.5, h * 0.5);
	
	float dist1 = length(gl_FragCoord.xy - pos1);
	float dist2 = length(gl_FragCoord.xy - pos2);
	
	// 円のサイズ\n	float size = 15.0;
	
	float color = 0.;
	color += pow(size / dist1, 2.0);
	color += pow(size / dist2, 2.0);
	gl_FragColor = vec4(vec3(color / 1.0, color / 4.0, color / 1.5), 1.0);
} 
