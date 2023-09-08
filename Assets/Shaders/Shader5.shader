Shader "Custom/Shader5"
{
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
	}

	SubShader {

		Pass {
			CGPROGRAM

			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram

			#include "UnityCG.cginc"

			float4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct vertexData {
				float4 position : POSITION;
				float3 localPosition : TEXCOORD0;
			};

			struct fragmentData
			{
				float4 position : POSITION;
				float3 localPosition : TEXCOORD0;
			};
			fragmentData MyVertexProgram (vertexData v) {
				fragmentData i;
				i.position = UnityObjectToClipPos(v.position);
				i.localPosition = v.localPosition;
				i.localPosition.xy = TRANSFORM_TEX(v.localPosition, _MainTex).xy;
				return i;
			}

			float4 MyFragmentProgram (fragmentData i) : SV_TARGET {
				return tex2D(_MainTex, i.localPosition.xy);
			}

			ENDCG
		}
	}
}