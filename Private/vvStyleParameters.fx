#ifndef VVSTYLE_PARAMETERS_FX
#define VVSTYLE_PARAMETERS_FX

////////////////////////////////////////////////////////////////
// シャドウ
////////////////////////////////////////////////////////////////
// -1~1
#ifndef ShadowThreshold
#define ShadowThreshold (-0.5)
#endif
// 0~
#ifndef ShadowColor
#define ShadowColor float3(0.8, 0.8, 1.0)
#endif

////////////////////////////////////////////////////////////////
// スペキュラ
////////////////////////////////////////////////////////////////
// 0~
#ifndef GlossExponent
#define GlossExponent (64)
#endif
// 0~1 (HotspotThreshold >= MidspotThreshold >= GlossThreshold)
#ifndef GlossThreshold
#define GlossThreshold (0.1)
#endif
// 0~
#ifndef GlossColor
#define GlossColor float3(0.6, 0.6, 0.6)
#endif
// 0~1
#ifndef MidspotThreshold
#define MidspotThreshold (0.6)
#endif
// 0~
#ifndef MidspotColor
#define MidspotColor float3(1.0, 0.5, 1.0)
#endif
// 0~1
#ifndef HotspotThreshold
#define HotspotThreshold (0.8)
#endif
// 0~
#ifndef HotspotColor
#define HotspotColor float3(0.5, 0.5, 1.4)
#endif

////////////////////////////////////////////////////////////////
// リムライト
////////////////////////////////////////////////////////////////
// 0~1
#ifndef RimThreshold
#define RimThreshold (0.2)
#endif
// 0~
#ifndef RimGlossColor
#define RimGlossColor float3(0.8, 0.8, 0.3)
#endif
// 0~
#ifndef RimShadowColor
#define RimShadowColor float3(0.6, 0.2, 0.6)
#endif

////////////////////////////////////////////////////////////////
// ハーフトーン
////////////////////////////////////////////////////////////////
// 1~
#ifndef HalftoneGlossTiles
#define HalftoneGlossTiles (256)
#endif
// 0~1
#ifndef HalftoneGlossAngle
#define HalftoneGlossAngle (0.25)
#endif
// 0~1
#ifndef HalftoneGlossIntensify
#define HalftoneGlossIntensify (1.0)
#endif
// 1~
#ifndef HalftoneShadowTiles
#define HalftoneShadowTiles (180)
#endif
// 0~1
#ifndef HalftoneShadowAngle
#define HalftoneShadowAngle (0.0)
#endif
// 0~1
#ifndef HalftoneShadowIntensify
#define HalftoneShadowIntensify (0.04)
#endif

////////////////////////////////////////////////////////////////
// シルエット
////////////////////////////////////////////////////////////////
// Boolean
#ifndef SilhouetteEnabled
#define SilhouetteEnabled (true)
#endif
// -1~1
#ifndef SilhouetteOffset
#define SilhouetteOffset float2(-0.012, 0.012)
#endif
// 0~
#ifndef SilhouetteColor
#define SilhouetteColor float3(1.0, 1.0, 0.0)
#endif

#endif
