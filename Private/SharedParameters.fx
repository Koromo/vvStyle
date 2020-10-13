// 座標変換行列
float4x4 LocalToWorld : WORLD;
float4x4 LocalToClip : WORLDVIEWPROJECTION;

// カメラ、ライト
float3 LightDirection : DIRECTION<string Object = "Light";>;
float3 CameraPosition : POSITION<string Object = "Camera";>;

// マテリアル
float4 DiffuseColor : DIFFUSE<string Object = "Geometry";>;
float3 ToonColor : TOONCOLOR;
float4 EdgeColor : EDGECOLOR;

// シェーダー
bool use_texture;
float2 ViewportSize : VIEWPORTPIXELSIZE;
texture BaseTexture : MATERIALTEXTURE;

sampler BaseTextureSampler = sampler_state
{
    texture = <BaseTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};
