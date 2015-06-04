﻿//
// Transparent surface shader for Spray
//
// Vertex format:
// position.xyz = vertex position
// texcoord.xy  = uv for PositionTex/RotationTex
//
// Texture format:
// _PositionTex.xyz = particle position
// _PositionTex.w   = life
// _RotationTex.xyz = particle rotation
// _RotstionTex.w   = scale factor
//
Shader "Hidden/Kvant/Spray/Transparent PBR"
{
    Properties
    {
        _PositionTex  ("-", 2D)     = ""{}
        _RotationTex  ("-", 2D)     = ""{}
        _Color        ("-", Color)  = (1, 1, 1, 1)
        _Color2       ("-", Color)  = (1, 1, 1, 1)
        _PbrParams    ("-", Vector) = (0.5, 0.5, 0, 0) // (metalness, smoothness)
        _ScaleParams  ("-", Vector) = (1, 1, 0, 0)     // (min scale, max scale)
        _BufferOffset ("-", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        CGPROGRAM

        #pragma multi_compile COLOR_SINGLE COLOR_ANIMATE COLOR_RANDOM

        #pragma target 3.0

        #pragma surface surf Standard vertex:vert nolightmap noshadow alpha:fade

        #include "Common.cginc"

        struct Input
        {
            half4 color : COLOR;
        };

        void vert(inout appdata_full v)
        {
            float2 uv = v.texcoord.xy + _BufferOffset;

            float4 p = tex2D(_PositionTex, uv);
            float4 r = tex2D(_RotationTex, uv);
            float4 q = normalize_quaternion(r);
            float s = calc_scale(r.w, p.w);

            v.vertex.xyz = rotate_vector(v.vertex.xyz, q) * s + p.xyz;
            v.normal = rotate_vector(v.normal, q);
            v.color = calc_color(uv, p.w);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = IN.color.rgb * IN.color.a;
            o.Metallic = _PbrParams.x;
            o.Smoothness = _PbrParams.y;
            o.Alpha = IN.color.a;
        }

        ENDCG
    }
}
