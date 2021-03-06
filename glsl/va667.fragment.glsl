#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

void main( void ) {  
  	vec2 t = gl_FragCoord.xy / resolution;
    	float c = 1.0 - distance(vec2(0.5, 0.5), t);
    	c = c * c;
  	float d = distance(vec2(0.5, 0.5), mouse) * 10.0;
    	c = sin(3.141592 * c * time * d + time);
    	gl_FragColor = vec4(c, c, c, 1);
}