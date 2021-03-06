#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

void main( void ) {

	float rings = 50.0; // Not the exact amount of rings, but higher value means more rings
	float speed = 10.0;
	
	vec2 position = ( gl_FragCoord.xy / resolution.xy );
        float aspect = resolution.x / resolution.y;
	position.x *= aspect;
	float dist_x = abs(position.x - 0.7);
	float dist_y = abs(position.y - 0.5);
	float dist_h = sqrt(dist_x * dist_x + dist_y * dist_y);
	
	float color = sin(rings*dist_h + (time*speed));
	
	
	
	gl_FragColor = vec4( color, color, color, 1.0 );

}