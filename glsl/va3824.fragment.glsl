// Starfield effect, extracted from: http://glsl.heroku.com/e#883.0

#ifdef GL_ES
precision mediump float;
#endif
 
uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

void main(void)
{
	float scale = sin(1.0* time) * 1.5 + 5.0;

	vec2 position = (((gl_FragCoord.xy / resolution) - 0.5) * scale)  ;

	float gradient = 0.0; 
	vec3 color = vec3(0.0);
 
	float fade = 0.0;
	float z;
 
	vec2 centered_coord = position - vec2(0.5);

	for (float i=1.0; i<=128.0; i++)
	{
		vec2 star_pos = vec2(sin(i) * 200.0, sin(i*i*i) * 200.0);
		
		float m = 0.15*sin(time/16.0)*0.5+0.5;
		star_pos.x *= mod(star_pos.x, m)-0.5*m;

		float z = mod(i*i - 28.0*time, 256.0);
		float fade = (256.0 - z) / 256.0;
		vec2 blob_coord = star_pos / z;
		
		gradient += ((fade / 384.0) / pow(length(centered_coord - blob_coord), 1.5)) * (fade * fade);
	}

	color = vec3(gradient * 2.0, gradient, gradient / 2.0);

	gl_FragColor = vec4(color, 1.0 );
}
