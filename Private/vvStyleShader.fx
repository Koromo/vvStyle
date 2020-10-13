#define PI 3.141592
#define VS_MODEL vs_3_0
#define PS_MODEL ps_3_0

struct ShaderParameters
{
    float ShadowThreshold;
    float3 ShadowColor;

    float GlossExponent;
    float GlossThreshold;
    float3 GlossColor;

    float GlossMidspotThreshold;
    float3 GlossMidspotColor;

    float GlossHotspotThreshold;
    float3 GlossHotspotColor;

    float RimThreshold;
    float3 RimGlossColor;
    float3 RimShadowColor;
    
    float HalftoneGlossTiles;
    float HalftoneGlossAngle;
    float HalftoneGlossIntensify;
    
    float HalftoneShadowTiles;
    float HalftoneShadowAngle;
    float HalftoneShadowIntensify;

    float AspectRatio;
};

struct LightContext
{
    float3 N;
    float3 V;
    float3 L;
    float3 H;
    float NoL;
    float NoV;
    float NoH;
};

void DecodeShaderParameters(out ShaderParameters OutParameters)
{
    // Set default values
    OutParameters.ShadowThreshold = -0.4;
    OutParameters.ShadowColor = float3(0.0, 0.0, 0.6);
    OutParameters.GlossExponent = 64;
    OutParameters.GlossThreshold = 0.1;
    OutParameters.GlossColor = float3(0.6, 0.6, 0.6);
    OutParameters.GlossMidspotThreshold = 0.6;
    OutParameters.GlossMidspotColor = float3(1.0, 0.5, 1.0);
    OutParameters.GlossHotspotThreshold = 0.8;
    OutParameters.GlossHotspotColor = float3(0.5, 0.5, 1.2);
    OutParameters.RimThreshold = 0.3;
    OutParameters.RimGlossColor = float3(0.7, 0.7, 0.3);
    OutParameters.RimShadowColor = float3(0.7, 0.2, 0.7);
    OutParameters.HalftoneGlossTiles = 256;
    OutParameters.HalftoneGlossAngle = 0.25;
    OutParameters.HalftoneGlossIntensify = 1.0;
    OutParameters.HalftoneShadowTiles = 128;
    OutParameters.HalftoneShadowAngle = 0.0;
    OutParameters.HalftoneShadowIntensify = 0.14;
    OutParameters.AspectRatio = 1.0;

    // Override parameters
#ifdef SHADOW_THRESHOLD
    OutParameters.ShadowThreshold = SHADOW_THRESHOLD;
#endif
#ifdef SHADOW_COLOR
    OutParameters.ShadowColor = SHADOW_COLOR;
#endif
#ifdef GLOSS_EXPONENT
    OutParameters.GlossExponent = GLOSS_EXPONENT;
#endif
#ifdef GLOSS_THRESHOLD
    OutParameters.GlossThreshold = GLOSS_THRESHOLD;
#endif
#ifdef GLOSS_COLOR
    OutParameters.GlossColor = GLOSS_COLOR;
#endif
#ifdef GLOSS_MIDSPOT_THRESHOLD
    OutParameters.GlossMidspotThreshold = GLOSS_MIDSPOT_THRESHOLD;
#endif
#ifdef GLOSS_MIDSPOT_COLOR
    OutParameters.GlossMidspotColor = GLOSS_MIDSPOT_COLOR;
#endif
#ifdef GLOSS_HOTSPOT_THRESHOLD
    OutParameters.GlossHotspotThreshold = GLOSS_HOTSPOT_THRESHOLD;
#endif
#ifdef GLOSS_HOTSPOT_COLOR
    OutParameters.GlossHotspotColor = GLOSS_HOTSPOT_COLOR;
#endif
#ifdef RIM_THRESHOLD
    OutParameters.RimThreshold = RIM_THRESHOLD;
#endif
#ifdef RIM_GLOSS_COLOR
    OutParameters.RimGlossColor = RIM_GLOSS_COLOR;
#endif
#ifdef RIM_SHADOW_COLOR
    OutParameters.RimShadowColor = RIM_SHADOW_COLOR;
#endif
#ifdef HALFTONE_GLOSS_TILES
    OutParameters.HalftoneGlossTiles = HALFTONE_GLOSS_TILES;
#endif
#ifdef HALFTONE_GLOSS_ANGLE
    OutParameters.HalftoneGlossAngle = HALFTONE_GLOSS_ANGLE;
#endif
#ifdef HALFTONE_GLOSS_INTENSIFY
    OutParameters.HalftoneGlossIntensify = HALFTONE_GLOSS_INTENSIFY;
#endif
#ifdef HALFTONE_SHADOW_TILES
    OutParameters.HalftoneShadowTiles = HALFTONE_SHADOW_TILES;
#endif
#ifdef HALFTONE_SHADOW_ANGLE
    OutParameters.HalftoneShadowAngle = HALFTONE_SHADOW_ANGLE;
#endif
#ifdef HALFTONE_SHADOW_INTENSIFY
    OutParameters.HalftoneShadowIntensify = HALFTONE_SHADOW_INTENSIFY;
#endif
#ifdef ASPECT_RATIO
    OutParameters.AspectRatio = ASPECT_RATIO;
#endif
}

void GetLightContext(out LightContext OutContext, float3 N, float3 V, float3 L)
{
    float3 H = normalize(V + L);
    OutContext.N = N;
    OutContext.V = V;
    OutContext.L = L;
    OutContext.H = H;
    OutContext.NoL = dot(N, L);
    OutContext.NoV = dot(N, V);
    OutContext.NoH = dot(N, H);
}

float HalftoneGloss(ShaderParameters Parameters, float2 ClipPosition)
{
    // UV rotation
    float t = Parameters.HalftoneGlossAngle * PI;
    float2x2 Rotation = {cos(t), sin(t), -sin(t), cos(t)};
    float2 Point = (ClipPosition + 1.0) * 0.5 * float2(Parameters.AspectRatio, 1.0);
    Point = mul(Point, Rotation);
    Point *= Parameters.HalftoneGlossTiles;

    float r = saturate(distance(frac(Point), 0.5) / 0.5);
    return 1.0 - (1.0 - pow(1.0 - r, 2.0)) * Parameters.HalftoneGlossIntensify;
}

float HalftoneShadow(ShaderParameters Parameters, float2 ClipPosition)
{
    // UV rotation
    float t = Parameters.HalftoneShadowAngle * PI;
    float2x2 Rotation = {cos(t), sin(t), -sin(t), cos(t)};
    float2 Point = (ClipPosition + 1.0) * 0.5 * float2(Parameters.AspectRatio, 1.0);
    Point = mul(Point, Rotation);
    Point *= Parameters.HalftoneShadowTiles;

    float r = abs(Point.x - Point.y);
    return 1.0 - (1.0 - pow(cos(r * PI), 2.0)) * Parameters.HalftoneShadowIntensify;
}

struct BasePassAssembled
{
    float4 Position : POSITION0;
    float3 Normal : NORMAL;
    float2 TexCoord : TEXCOORD0;
};

struct BasePassInterpolants
{
    float4 SysClipPosition : SV_POSITION;
    float4 WorldPosition : POSITION1;
    float3 WorldNormal : NORMAL;
    float2 TexCoord : TEXCOORD0;
    float4 ClipPosition : TEXCOORD1;
};

void BasePassVS(BasePassAssembled In, out BasePassInterpolants Out)
{
    Out.SysClipPosition = Out.ClipPosition = mul(In.Position, LocalToClip);
    Out.WorldPosition = mul(In.Position, LocalToWorld);
    Out.WorldNormal = normalize(mul(float4(In.Normal, 0.0), LocalToWorld).xyz);
    Out.TexCoord = In.TexCoord;
}

void BasePassPS(BasePassInterpolants In, out float4 Out : COLOR, uniform bool UseTexture)
{
    ShaderParameters Parameters;
    DecodeShaderParameters(Parameters);    
    
    // Alpha
    float Alpha = DiffuseColor.a;

    // Accumulate lights
    float3 LightAccumulator = 0.0;

    LightContext Context;
    GetLightContext(Context, In.WorldNormal, normalize(CameraPosition - In.WorldPosition.xyz), -LightDirection);

    // Diffuse term
    float3 DiffuseTerm = DiffuseColor.rgb;
    if (UseTexture)
    {
        DiffuseTerm *= tex2D(BaseTextureSampler, In.TexCoord);
    }

    // Specular term
    float3 SpecularTerm = 0.0;

    // Gloss specular
    float GlossLight = pow(saturate(Context.NoH), Parameters.GlossExponent);
    float HotspotSign = saturate(sign(GlossLight - Parameters.GlossHotspotThreshold));
    float MidspotSign = saturate(sign(GlossLight - Parameters.GlossMidspotThreshold)) * (1.0 - HotspotSign);
    float GlossSign = saturate(sign(GlossLight - Parameters.GlossThreshold)) * (1.0 - HotspotSign) * (1.0 - MidspotSign);
    float GlossMask = HalftoneGloss(Parameters, In.ClipPosition.xy / In.ClipPosition.w);
    SpecularTerm += GlossLight * GlossMask *
        (GlossSign * Parameters.GlossColor +
        MidspotSign * Parameters.GlossMidspotColor +
        HotspotSign * Parameters.GlossHotspotColor);

    // Emissive term
    float3 EmissiveTerm = 0.0;

    // Rim emissive
    float RimSign = saturate(sign(Parameters.RimThreshold - abs(Context.NoV)));
    EmissiveTerm += RimSign * saturate(Context.NoL) * Parameters.RimGlossColor;
    EmissiveTerm += RimSign * saturate(-Context.NoL) * Parameters.RimShadowColor;

    // Shadow color
    float ShadowSign = saturate(sign(Parameters.ShadowThreshold - Context.NoL));
    float ShadowMask = HalftoneShadow(Parameters, In.ClipPosition.xy / In.ClipPosition.w);
    float3 ShadowColor = lerp(1.0, Parameters.ShadowColor, ShadowSign * ShadowMask);

    LightAccumulator += (DiffuseTerm + SpecularTerm) * ShadowColor + EmissiveTerm;

    Out.rgb = LightAccumulator;
    Out.a = Alpha;
}

technique TObjectSS_F<string MMDPass = "object_ss"; bool UseTexture = false;>
{
    pass BasePass
    {
        VertexShader = compile VS_MODEL BasePassVS();
        PixelShader  = compile PS_MODEL BasePassPS(false);
    }
}

technique TObjectSS_T<string MMDPass = "object_ss"; bool UseTexture = true;>
{
    pass BasePass
    {
        VertexShader = compile VS_MODEL BasePassVS();
        PixelShader  = compile PS_MODEL BasePassPS(true);
    }
}
