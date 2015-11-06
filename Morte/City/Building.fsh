/*

uniform float u_winPaddingX;
uniform float u_winPaddingY;

uniform float u_winLightDim;
 
uniform sampler2D u_noiseTexture;
 
uniform float u_seedX;
uniform float u_seedY;
 

*/


// color of the lit windows, could be converted to uniform
const vec4 u_winColor = vec4(1.0, 1.0, 0.5, 1.0);


float modf( float x, out float i) {
    
    // simulates the native modf function
    i = floor(x);
    return x - i;
}

float noise2d(vec2 coord) {
    
    // sample from the noise texture, adding up the seed, repeatable
    return texture2D(u_noiseTexture, mod(coord + vec2(u_seedX, u_seedY), vec2(1.0, 1.0)) ).x;
    
}

float binaryNoise2d(vec2 coord, float threshold) {
    
    // get the noise value
    float val = noise2d(coord);
    
    // convert it to either 0.0 or 1.0 using threshold
    return step(threshold, val);
    
}

void main() {
    
    float wx = 0.0;
    float wy = 0.0;
    
    // (wx, wy) are the intere parts, (wfx, wfy) are the decimal parts
    float wfx = modf( v_tex_coord.x * u_subdivX, wx );
    float wfy = modf( v_tex_coord.y * u_subdivY, wy );
    
    // noise dim
    float dim =  noise2d(vec2(wx/512.0, wy/512.0));
    
    // blink the lights
    dim = mix(pow(dim, 100.0), dim, mix(sin(u_time + (u_seedX + wy) * 10.0) /2.0 + 0.5, 1.0, step(0.5, (cos( wx * 3.0 ) + cos( wy * 7.0 )) / 4.0 + 0.5)));
    
    // global dimming
    dim *= u_winLightDim;
    
    // window padding
    dim *= step(u_winPaddingX, wfx) * (1.0 - step(1.0-u_winPaddingX, wfx));
    dim *= step(u_winPaddingY, wfy) * (1.0 - step(1.0-u_winPaddingY, wfy));
    
    // darker on top
    dim *= 1.0 - v_tex_coord.y;
    
    // finally mix down with base color
    gl_FragColor = mix( v_color_mix, u_winColor, dim);
    
    //gl_FragColor = vec4(dim, 1.0, dim, 1.0);

    
}