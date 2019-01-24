precision mediump float;
uniform float iTime;
uniform vec2 iResolution;
#define PI 3.141592

const vec3 cPos = vec3(0.0, 0.0, -5.0);
const vec3 cDir = vec3(0.0, 0.0, 1.0);
const vec3 cUp = vec3(0.0, 1.0, 0.0);
const float depth = 1.0;
const vec3 lPos = vec3(10.0, 10.0, -10.0);

float sphereDistFunc(vec3 p, float r) { return length(p) - r; }

float distFunc(vec3 p) { return sphereDistFunc(p, 1.0); }

vec3 getNormal(vec3 p) {
  float d = 0.001;
  return normalize(
      vec3(distFunc(p + vec3(d, 0.0, 0.0)) - distFunc(p + vec3(-d, 0.0, 0.0)),
           distFunc(p + vec3(0.0, d, 0.0)) - distFunc(p + vec3(0.0, -d, 0.0)),
           distFunc(p + vec3(0.0, 0.0, d)) - distFunc(p + vec3(0.0, 0.0, -d))));
}

vec3 rayMarching(vec3 color, vec2 p) {
  vec3 cSide = cross(cDir, cUp);
  vec3 ray = normalize(cSide * p.x + cUp * p.y + cDir * depth);
  vec3 rPos = cPos;
  float rLen = 0.0;
  float maxDist = 30.0;
  vec3 sphereColor = vec3(0.8, 0.2, 0.6);
  for (float i = 0.0; i < 60.0; i++) {
    float distance = distFunc(rPos);
    if (abs(distance) < 0.01) {
      vec3 normal = getNormal(rPos);
      vec3 halfLE = normalize(lPos + rPos);
      float specular = pow(clamp(dot(normal, halfLE), 0.0, 1.0), 50.0);
      float diffuse = clamp(dot(normal, lPos), 0.0, 1.0) + 0.1;
      color = (sphereColor * diffuse + specular);
      break;
    }
    rLen += distance;
    if (rLen > maxDist) {
      break;
    }
    rPos = cPos + rLen * ray;
  }
  return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 p =
      (fragCoord.xy * 2.0 - iResolution.xy) / min(iResolution.x, iResolution.y);
  vec3 color = rayMarching(vec3(0.5), p);
  fragColor = vec4(color, 1.0);
}