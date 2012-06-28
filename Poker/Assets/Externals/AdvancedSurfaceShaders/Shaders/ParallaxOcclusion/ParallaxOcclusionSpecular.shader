Shader "Advanced SS/Parallax Occlusion (D3D)/Specular" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
	_Shininess ("Shininess", Range (0.01, 1)) = 0.078125
	_Parallax ("Height", Range (0.005, 0.16)) = 0.02
	_NumSamples ("NumSamples", Float) = 40
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_BumpMap ("Normalmap", 2D) = "bump" {}
	_SpecMap ("Heightmap (A)", 2D) = "black" {}
}

SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 500

CGPROGRAM
#pragma surface surf BlinnPhong
#pragma target 3.0
#pragma only_renderers d3d9
#include "../AdvancedSS.cginc"

sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _SpecMap;
fixed4 _Color;
half _Shininess;
float _Parallax;
float _NumSamples;

struct Input {
	float2 uv_MainTex;
	float2 uv_BumpMap;
	float3 viewDir;
	float3 normal;
	float3 viewDirWS;
};

void vert (inout appdata_full v, out Input o)
{
	o.viewDirWS = normalize(WorldSpaceViewDir( v.vertex ));
	o.normal = normalize(v.normal);
}

void surf (Input IN, inout SurfaceOutput o) {
	
	float2 offset = ParallaxOcclusionOffset( IN.viewDir, IN.viewDirWS, _Parallax, IN.normal, IN.uv_BumpMap, _SpecMap, _NumSamples );
    
	IN.uv_MainTex -= offset;
	IN.uv_BumpMap -= offset;
	
	half4 tex = tex2D(_MainTex, IN.uv_MainTex);
	o.Albedo = tex.rgb * _Color.rgb;
	o.Gloss = tex.a;
	o.Alpha = tex.a * _Color.a;
	o.Specular = _Shininess;
	o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
}
ENDCG
}

FallBack "Specular"
}