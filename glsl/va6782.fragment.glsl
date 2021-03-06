#ifdef GL_ES
precision mediump float;
#endif
// mods by dist

uniform float time;
//uniform vec2 mouse;
uniform vec2 resolution;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 758.5453);
}

void main( void )
{
	vec2 pos = gl_FragCoord.xy / resolution.xy;
	vec2 uPos = pos;
	uPos.y -= 0.1;
	
	vec3 color = vec3(.0);
	float vertColor = 0.0;
	const float k = 20.;
	for( float i = k; i > 1.; --i )
	{
		float t = time * (10.0);
	
		uPos.y += sin( uPos.x*exp(i/k + 1.) - (t * 0.11) ) * 0.15 - 0.01 * sin(0.1 * t);
		float fTemp = abs(1.0/(20.0*k) / uPos.y);
		vertColor += fTemp;
		color += vec3( fTemp*(i*0.1), fTemp*i/k, pow(fTemp,0.93)*0.3 );
		color += vec3(0.0, (1. - fTemp) * fTemp, 0.0);
	}
	
	vec4 color_final = vec4(color, 1.0);
	gl_FragColor = color_final;
	float ft = fract(time);
	gl_FragColor.rgb += vec3( rand( pos +  7.+ ft ), 
				  rand( pos +  9.+ ft ),
        				  rand( pos + 11.+ ft ) ) / 32.0;
}
