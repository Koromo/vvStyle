#ifndef VVSTYLE_SHADER_FX
#define VVSTYLE_SHADER_FX

#include "Private/SharedParameters.fx"
#include "Private/vvStyleParameters.fx"

#define PI 3.141592
#define VS_MODEL vs_3_0
#define PS_MODEL ps_3_0

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

void GetLightContext(out LightContext Out, float3 N, float3 V, float3 L)
{
    Out.N = N;
    Out.V = V;
    Out.L = L;
    Out.H = normalize(V + L);
    Out.NoL = dot(N, L);
    Out.NoV = dot(N, V);
    Out.NoH = dot(N, Out.H);
}

float HalftoneGloss(float2 ClipPosition)
{
    // Get aspect ratio applied screen position
    float2 Point = (ClipPosition + 1.0) * float2(0.5, -0.5) * float2(ViewportSize.x / ViewportSize.y, 1.0);

    // UV rotation
    const float t = HalftoneGlossAngle * PI;
    const float2x2 Rotation = {cos(t), sin(t), -sin(t), cos(t)};
    Point = mul(Point, Rotation);

    Point *= HalftoneGlossTiles;

    const float r = saturate(distance(frac(Point), 0.5) / 0.5);
    return 1.0 - (1.0 - pow(1.0 - r, 2.0)) * HalftoneGlossIntensify;
}

float HalftoneShadow(float2 ClipPosition)
{
    // Get aspect ratio applied screen position
    float2 Point = (ClipPosition + 1.0) * float2(0.5, -0.5) * float2(ViewportSize.x / ViewportSize.y, 1.0);

    // UV rotation
    const float t = HalftoneShadowAngle * PI;
    const float2x2 Rotation = {cos(t), sin(t), -sin(t), cos(t)};
    Point = mul(Point, Rotation);

    Point *= HalftoneShadowTiles;

    const float r = abs(Point.x - Point.y);
    return 1.0 - (1.0 - pow(cos(r * PI), 2.0)) * HalftoneShadowIntensify;
}

struct BasePassAssembled
{
    float4 Position : POSITION0;
    float3 Normal : NORMAL;
    float2 TexCoord : TEXCOORD0;
};

struct BasePassInterpolants
{
    float4 svClipPosition : SV_POSITION;
    float4 WorldPosition : POSITION1;
    float3 WorldNormal : NORMAL;
    float2 TexCoord : TEXCOORD0;
    float4 ClipPosition : TEXCOORD1;
};

struct SilhouettePassAssembled
{
    float4 Position : POSITION;
};

struct SilhouettePassInterpolants
{
    float4 ClipPosition : SV_POSITION;
};

struct EdgePassAssembled
{
    float4 Position : POSITION;
};

struct EdgePassInterpolants
{
    float4 ClipPosition : SV_POSITION;
};

void BasePassVS(BasePassAssembled In, out BasePassInterpolants Out)
{
    Out.svClipPosition = Out.ClipPosition = mul(In.Position, LocalToClip);
    Out.WorldPosition = mul(In.Position, LocalToWorld);
    Out.WorldNormal = normalize(mul(float4(In.Normal, 0.0), LocalToWorld).xyz);
    Out.TexCoord = In.TexCoord;
}

void BasePassPS(BasePassInterpolants In, out float4 Out : COLOR)
{
    // Alpha
    float Alpha = DiffuseColor.a;

    // Accumulate lights
    float3 LightAccumulator = 0.0;

    LightContext Context;
    GetLightContext(Context, In.WorldNormal, normalize(CameraPosition - In.WorldPosition.xyz), -LightDirection);

    // Diffuse term
    float3 DiffuseTerm = DiffuseColor.rgb;
    if (use_texture)
    {
        DiffuseTerm *= tex2D(ObjectTextureSampler, In.TexCoord).rgb;
    }

    // Specular term
    float3 SpecularTerm = 0.0;

    // Gloss specular
    float GlossLight = pow(saturate(Context.NoH), GlossExponent);
    float HotspotSign = saturate(sign(GlossLight - HotspotThreshold));
    float MidspotSign = saturate(sign(GlossLight - MidspotThreshold)) * (1.0 - HotspotSign);
    float GlossSign = saturate(sign(GlossLight - GlossThreshold)) * (1.0 - HotspotSign) * (1.0 - MidspotSign);
    float GlossMask = HalftoneGloss(In.ClipPosition.xy / In.ClipPosition.w);
    SpecularTerm += GlossLight * GlossMask * (GlossSign * GlossColor + MidspotSign * MidspotColor + HotspotSign * HotspotColor);

    // Emissive term
    float3 EmissiveTerm = 0.0;

    // Rim emissive
    float RimSign = saturate(sign(RimThreshold - abs(Context.NoV)));
    EmissiveTerm += RimSign * saturate(Context.NoL) * RimGlossColor;
    EmissiveTerm += RimSign * saturate(-Context.NoL) * RimShadowColor;

    // Shadow term
    float ShadowSign = saturate(sign(ShadowThreshold - Context.NoL));
    float ShadowMask = HalftoneShadow(In.ClipPosition.xy / In.ClipPosition.w);
    float3 ShadowTerm = lerp(1.0, ShadowColor * ToonColor, ShadowSign * ShadowMask);

    LightAccumulator += (DiffuseTerm + SpecularTerm) * ShadowTerm + EmissiveTerm;

    Out.rgb = LightAccumulator;
    Out.a = Alpha;
}

void SilhouettePassVS(SilhouettePassAssembled In, out SilhouettePassInterpolants Out)
{
    // Offset in screen space
    Out.ClipPosition = mul(In.Position, LocalToClip);
    Out.ClipPosition.xy += SilhouetteOffset * Out.ClipPosition.w;

    if (!SilhouetteEnabled)
    {
        // Always mapped to outside the viewport
        Out.ClipPosition = float4(2.0, 2.0, -1.0, 1.0);
    }
}

void SilhouettePassPS(SilhouettePassInterpolants In, out float4 Out : COLOR)
{
    Out.rgb = SilhouetteColor;
    Out.a = 1.0;
}

void EdgePassVS(EdgePassAssembled In, out EdgePassInterpolants Out)
{
    Out.ClipPosition = mul(In.Position, LocalToClip);
}

void EdgePassPS(EdgePassInterpolants In, out float4 Out : COLOR)
{
    Out = EdgeColor;
}

technique TObject<string MMDPass = "object";>
{
    pass BasePass
    {
        StencilRef = 64;
        StencilPass = REPLACE;
        VertexShader = compile VS_MODEL BasePassVS();
        PixelShader  = compile PS_MODEL BasePassPS();
    }
}

technique TObjectSS<string MMDPass = "object_ss";>
{
    pass BasePass
    {
        StencilRef = 64;
        StencilPass = REPLACE;
        VertexShader = compile VS_MODEL BasePassVS();
        PixelShader  = compile PS_MODEL BasePassPS();
    }
}

technique TEdge<string MMDPass = "edge";>
{
    pass EdgePass
    {
        StencilRef = 64;
        StencilPass = REPLACE;
        VertexShader = compile VS_MODEL EdgePassVS();
        PixelShader  = compile PS_MODEL EdgePassPS();
    }

    pass SilhouettePass
    {
        StencilRef = 64;
        StencilFunc = NOTEQUAL;
        VertexShader = compile VS_MODEL SilhouettePassVS();
        PixelShader  = compile PS_MODEL SilhouettePassPS();
    }
}

#endif
