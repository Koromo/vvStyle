#ifndef SHARED_PARAMETERS_FX
#define SHARED_PARAMETERS_FX

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

// テクスチャ
texture ObjectTexture : MATERIALTEXTURE;

sampler ObjectTextureSampler = sampler_state
{
    texture = <ObjectTexture>;
    Filter = ANISOTROPIC;
    MaxAnisotropy = 16;
};

// シェーダー
float2 ViewportSize : VIEWPORTPIXELSIZE;
bool use_texture;

#endif
