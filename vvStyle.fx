// Don't Touch!
#include "Private/SharedParameters.fx"


////////////////////////////////////////////////////////////////
// シャドウ
////////////////////////////////////////////////////////////////
// -1~1
#define SHADOW_THRESHOLD -0.4
// 0~
#define SHADOW_COLOR float3(0.0, 0.0, 0.6)

////////////////////////////////////////////////////////////////
// スペキュラ
////////////////////////////////////////////////////////////////
// 0~
#define GLOSS_EXPONENT 64
// 0~1 (GLOSS_HOTSPOT_THRESHOLD >= GLOSS_MIDSPOT_THRESHOLD >= GLOSS_THRESHOLD)
#define GLOSS_THRESHOLD 0.1
// 0~
#define GLOSS_COLOR float3(0.6, 0.6, 0.6)
// 0~1
#define GLOSS_MIDSPOT_THRESHOLD 0.6
// 0~
#define GLOSS_MIDSPOT_COLOR float3(1.0, 0.5, 1.0)
// 0~1
#define GLOSS_HOTSPOT_THRESHOLD 0.8
// 0~
#define GLOSS_HOTSPOT_COLOR float3(0.5, 0.5, 1.2)

////////////////////////////////////////////////////////////////
// リムライト
////////////////////////////////////////////////////////////////
// 0~1
#define RIM_THRESHOLD 0.3
// 0~
#define RIM_GLOSS_COLOR float3(0.7, 0.7, 0.3)
// 0~
#define RIM_SHADOW_COLOR float3(0.7, 0.2, 0.7)

////////////////////////////////////////////////////////////////
// ハーフトーン
////////////////////////////////////////////////////////////////
// 1~
#define HALFTONE_GLOSS_TILES 256
// 0~1
#define HALFTONE_GLOSS_ANGLE 0.25
// 0~1
#define HALFTONE_GLOSS_INTENSIFY 1.0
// 1~
#define HALFTONE_SHADOW_TILES 128
// 0~1
#define HALFTONE_SHADOW_ANGLE 0.0
// 0~1
#define HALFTONE_SHADOW_INTENSIFY 0.14

////////////////////////////////////////////////////////////////
// Width/Height
#define ASPECT_RATIO (1.9 / 1.0)


// Don't Touch!
#include "Private/vvStyleShader.fx"
