// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DeformeSphere"
{

    Properties
    {
        _Rate("Rate",Range(0, 1.0)) = 1
    }
    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex MyVertexProgram
            #pragma fragment MyFragmentProgram
            #include "UnityCG.cginc"

            float _Rate;
            sampler2D _MainTex;
            
            float4 MyVertexProgram(float4 position : POSITION, float2 uv : TEXCOORD0) : SV_POSITION
            {
                float3 newPosition = float3(position.x, position.y, position.z);
                float4 pos = float4(newPosition.xyz, 1);

                float4 center = float4(0, 0, 0, 1);
                float3 distanceToCenter = pos - center;
                distanceToCenter = normalize(distanceToCenter);

                float3 distFromCamera = ObjSpaceViewDir(position);
                return UnityObjectToClipPos(pos + distanceToCenter * _Rate);
            }

            float4 MyFragmentProgram(float2 uv : TEXCOORD0) : SV_TARGET
            {
                return tex2D(_MainTex, uv);
                return 1;
            }
            ENDCG
        }
    }
}