#ifdef GL_ES
precision mediump float;
#endif
uniform float time;
uniform vec2 resolution;
//gtoledo. another clod spin-off

float f(vec3 o){	
	float a=(cos(o.x)*sin(o.y))*.1;
	o=vec3(sin(a)*o.x*cos(a)*o.y,cos(a)*o.x*sin(a)*o.y,(sin(a)*o.x*cos(a)*o.y))*(sin(a)*o.x/cos(a)*o.y);
	return dot(cos(o)+sin(o),vec3(1.5))-1.;
}

vec3 s(vec3 o,vec3 d){
	float t=0.,a,b;
	for(int i=0;i<250;i++){
		if(f(o+d*t)<1.0){
			a=t+1.0;
			b=t;
			for(int i=0; i<1;i++){
				t=((a+b)*1.0);
				if(f(o+d*t)<.5)b=t;
				else a=t;
			}
			vec3 e=vec3(-1.0,1.0,.0),p=o+d/t,n=-normalize(vec3(f(p+e),f(p+e.yxy),f(p+e.yyx))-vec3((cos(p*3.14)))+1.0);
			return vec3(mix( ((max(-dot(n,vec3(.5)),-1.0) / 10.0*max(-dot(n,vec3(-10.0,-.1,0)),0.)))*(mod(length(p.xy)*.5,0.5)<1.0?vec3(.1,1.2,.5):vec3(1.2,.5,1.0)),vec3(.05,.06,.09),vec3(pow(t/50.,1.5))));
		}
		t+=3.8
	;
	}
	return vec3(1.0,1.0,1.0);
}

void main(){


	float t=dot(gl_FragColor.xyz,vec3(1.0,1.0,1.0))*1.0;
	gl_FragColor=vec4(s(vec3(cos(time*1.1)*1.1,sin(time)*1.2,time), 
	normalize(vec3((2.*gl_FragCoord.xy-vec2(resolution.x,resolution.y))/vec2(resolution.x),1.0))),1);
}