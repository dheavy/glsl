// voxels!
// @simesgreen

#ifdef GL_ES
precision highp float;
#endif

uniform vec2 resolution;
uniform float time;
uniform vec2 mouse;

// CSG operations
float _union(float a, float b)
{
    return min(a, b);
}

float intersect(float a, float b)
{
    return max(a, b);
}

float diff(float a, float b)
{
    return max(-a, b);
}

// primitive functions
// these all return the distance to the surface from a given point

float plane(vec3 p, vec3 planeN, vec3 planePos)
{
    return dot(p - planePos, planeN);
}

float box( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float sdCone( vec3 p, vec2 c )
{
    // c must be normalized
    float q = length(p.xz);
    return dot(c, vec2(q, p.y));
}

float sphere(vec3 p, float r)
{
    return length(p) - r;
}

// transforms
vec3 rotateX(vec3 p, float a)
{
    float sa = sin(a);
    float ca = cos(a);
    vec3 r;
    r.x = p.x;
    r.y = ca*p.y - sa*p.z;
    r.z = sa*p.y + ca*p.z;
    return r;
}

vec3 rotateY(vec3 p, float a)
{
    float sa = sin(a);
    float ca = cos(a);
    vec3 r;
    r.x = ca*p.x + sa*p.z;
    r.y = p.y;
    r.z = -sa*p.x + ca*p.z;
    return r;
}

// distance to scene
float scene(vec3 p)
{	
    float d;
    //d = box(p, vec3(1.0));
    //p.z += sin(time)*1.5;
    //d = diff( d, sphere(p, sin(time*0.5)*1.5) );
	
    //d = sphere(p, 1.0);	
    d = sphere(p, sin(time)*0.5+0.5);

    vec3 pr = p - vec3(1.5, 0.0, 0.0);
    pr = rotateX(pr, time);
    pr = rotateY(pr, time*0.3);	
    d= _union(d, box(pr , vec3(0.6)) );

    d = _union(d, sdCone(p + vec3(1.5, -0.5, 0.0), vec2(1.0, 0.5)));
	
    d = _union(d, plane(p, vec3(0.0, 1.0, 0.0), vec3(0.0, -1.0, 0.0)) );
    return d;
}

// calculate scene normal
vec3 sceneNormal(vec3 pos )
{
    float eps = 0.0001;
    vec3 n;
#if 0
    n.x = scene( vec3(pos.x+eps, pos.y, pos.z) ) - scene( vec3(pos.x-eps, pos.y, pos.z) );
    n.y = scene( vec3(pos.x, pos.y+eps, pos.z) ) - scene( vec3(pos.x, pos.y-eps, pos.z) );
    n.z = scene( vec3(pos.x, pos.y, pos.z+eps) ) - scene( vec3(pos.x, pos.y, pos.z-eps) );
#else
    float d = scene(pos);
    n.x = scene( vec3(pos.x+eps, pos.y, pos.z) ) - d;
    n.y = scene( vec3(pos.x, pos.y+eps, pos.z) ) - d;
    n.z = scene( vec3(pos.x, pos.y, pos.z+eps) ) - d;
#endif
    return normalize(n);
}

// ambient occlusion approximation
float ambientOcclusion(vec3 p, vec3 n)
{
    const int steps = 3;
    const float delta = 0.5;

    float a = 0.0;
    float weight = 1.0;
    for(int i=1; i<=steps; i++) {
        float d = (float(i) / float(steps)) * delta; 
        a += weight*(d - scene(p + n*d));
        weight *= 0.5;
    }
    return clamp(1.0 - a, 0.0, 1.0);
}

// lighting
vec3 shade(vec3 pos, vec3 n, vec3 eyePos)
{
    const vec3 lightPos = vec3(5.0, 10.0, 5.0);
    const vec3 color = vec3(1.0, 1.0, 0.0);
    const float shininess = 40.0;

    vec3 l = normalize(lightPos - pos);
    vec3 v = normalize(eyePos - pos);
    vec3 h = normalize(v + l);
    float diff = dot(n, l);
    float spec = max(0.0, pow(dot(n, h), shininess)) * float(diff > 0.0);
    //diff = max(0.0, diff);
    diff = 0.5+0.5*diff;

    float fresnel = pow(1.0 - dot(n, v), 5.0);
    float ao = ambientOcclusion(pos, n);

//    return vec3(diff*ao) * color + vec3(spec + fresnel*0.5);
    return vec3(diff*ao)*color + vec3(spec);
//    return vec3(ao);
//    return vec3(fresnel);
}

// trace ray using sphere tracing
vec3 trace(vec3 ro, vec3 rd, out bool hit)
{
    const int maxSteps = 128;
    const float hitThreshold = 0.001;
    hit = false;
    vec3 pos = ro;
    vec3 hitPos = ro;

    for(int i=0; i<maxSteps; i++)
    {
        float d = scene(pos);
	//d = max(d, 0.000001);
        if (d < hitThreshold) {
            hit = true;
            hitPos = pos;
            //return pos;
        }
        pos += d*rd;
    }
    return hitPos;
}

// Amanatides & Woo style voxel traversal
const vec3 voxelSize = vec3(0.1); // in world space
//const vec3 voxelSize = vec3(0.2);

vec3 worldToVoxel(vec3 i)
{
    return floor(i/voxelSize);
}

vec3 voxelToWorld(vec3 i)
{
    return i*voxelSize;	
}

vec3 voxelTrace(vec3 ro, vec3 rd, out bool hit, out vec3 hitNormal)
{
    const int maxSteps = 64;
    const float isoValue = 0.0;

    vec3 voxel = worldToVoxel(ro);
    vec3 step = sign(rd);

    vec3 nearestVoxel = voxel + vec3(rd.x > 0.0, rd.y > 0.0, rd.z > 0.0);
    vec3 tMax = (voxelToWorld(nearestVoxel) - ro) / rd;
    vec3 tDelta = voxelSize / abs(rd);

    vec3 hitVoxel = voxel;
	
    hit = false;
    float dist = 0.0;
    for(int i=0; i<maxSteps; i++) {
        float d = scene(voxelToWorld(voxel));        
        if (d <= isoValue && !hit) {
            hit = true;
	    hitVoxel = voxel;
            //break;
        }

        bool c1 = tMax.x < tMax.y;
        bool c2 = tMax.x < tMax.z;
        bool c3 = tMax.y < tMax.z;

        if (c1 && c2) { 
            voxel.x += step.x;
            tMax.x += tDelta.x;
	    if (!hit) hitNormal = vec3(-step.x, 0.0, 0.0);
        } else if (c3 && !c1) {
            voxel.y += step.y;
            tMax.y += tDelta.y;
	    if (!hit) hitNormal = vec3(0.0, -step.y, 0.0);		
        } else {
            voxel.z += step.z;
            tMax.z += tDelta.z;
	    if (!hit) hitNormal = vec3(0.0, 0.0, -step.z);		
        }
     
#if 0
        if ((voxel.x < 0) || (voxel.x >= size.width) ||
            (voxel.y < 0) || (voxel.y >= size.height) ||
            (voxel.z < 0) || (voxel.z >= size.depth)) {
            break;            
        }
#endif	    
    }

    return voxelToWorld(hitVoxel);
}


vec3 background(vec3 rd)
{
     //return mix(vec3(1.0), vec3(0.0), rd.y);
     return mix(vec3(1.0, 1.0, 1.0), vec3(0.0, 0.0, 1.0), rd.y);
     //return vec3(0.0);
}

void main(void)
{
    vec2 pixel = -1.0 + 2.0 * gl_FragCoord.xy / resolution.xy;

    // compute ray origin and direction
    float asp = resolution.x / resolution.y;
    vec3 rd = normalize(vec3(asp*pixel.x, pixel.y, -2.0));
    vec3 ro = vec3(0.0, 0.25, 4.5);

    ro += rd*2.0;
		
    float a;

    //a = sin(time*0.25)*0.3;
    a = -(1.0 - mouse.y)*1.5;
    rd = rotateX(rd, a);
    ro = rotateX(ro, a);
		
    //a = sin(time*0.3)*1.5;
    a = -(mouse.x-0.5)*3.0;
    rd = rotateY(rd, a);
    ro = rotateY(ro, a);

    // trace ray
    bool hit;
    //vec3 pos = trace(ro, rd, hit);
    vec3 n;
    vec3 pos = voxelTrace(ro, rd, hit, n);

    vec3 rgb;
    if(hit)
    {
        // calc normal
        //vec3 n = sceneNormal(pos);
	    
        // shade
        rgb = shade(pos, n, ro);

#if 0
        // reflection
        vec3 v = normalize(ro - pos);
        float fresnel = 0.1 + 0.4*pow(1.0 - dot(n, v), 5.0);

        ro = pos + n*0.01; // offset to avoid self-intersection
        rd = reflect(-v, n);
        //pos = trace(ro, rd, hit);
	pos = voxelTrace(ro, rd, hit, n);
	    
        if (hit) {
            //vec3 n = sceneNormal(pos);
            rgb += shade(pos, n, ro) * vec3(fresnel);
        } else {
            rgb += background(rd) * vec3(fresnel);
        }
#endif 

     } else {
        rgb = background(rd);
     }

    // vignetting
    //rgb *= 0.5+0.5*smoothstep(2.0, 0.5, dot(pixel, pixel));

    gl_FragColor=vec4(rgb, 1.0);
}