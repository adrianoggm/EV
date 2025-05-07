shader_type spatial;

render_mode specular_schlick_ggx;



// Mapa de alturas (blanco = alto, negro = bajo)

uniform sampler2D height_map;

// Intensidad del relieve (evitamos cero para no dividir por 0)

uniform float strength : hint_range(0.001, 100.0) = 0.5;



void fragment() {

    // 1) Coordenadas UV y tamaño de un texel en UV

    vec2 uv    = UV;

    ivec2 sz   = textureSize(height_map, 0);

    vec2 texel = vec2(1.0 / float(sz.x), 1.0 / float(sz.y));



    // 2) Muestreo central y vecinos para diferencia central

    float hC = texture(height_map, uv).r;

    float hL = texture(height_map, uv - vec2(texel.x, 0.0)).r;

    float hR = texture(height_map, uv + vec2(texel.x, 0.0)).r;

    float hD = texture(height_map, uv - vec2(0.0, texel.y)).r;

    float hU = texture(height_map, uv + vec2(0.0, texel.y)).r;



    // 3) Derivadas aproximadas dH/dX y dH/dY (sin strength)

    float dHdX = (hR - hL) * 0.5;

    float dHdY = (hU - hD) * 0.5;



    // 4) Construir TBN

    vec3 T = normalize(TANGENT);

    vec3 B = normalize(cross(NORMAL, T));



    // 5) Normal bump en espacio tangente

    //    Aplicamos strength solo en Z (más eficiente)

    float invS  = 1.0 / strength;

    vec3  bumpN = normalize(vec3(-dHdX, -dHdY, invS));

    NORMAL = normalize(mat3(T, B, NORMAL) * bumpN);



    // 6) Salida de color heightmap en grises

    ALBEDO = vec3(hC);

}