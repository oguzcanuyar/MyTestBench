// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DeformeShader"
{

    Properties
    {
        _Rate("Rate",Range(-1.0, 1.0)) = 1
        _MainTex ("Texture", 2D) = "white" {}
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
                if
                (position.x < 0 && position.y > 0)
                {
                    newPosition = float3(position.x, position.y - position.x * _Rate, position.z);
                }
                float4 newPos = float4(newPosition.xyz, 1);

                return UnityObjectToClipPos(newPos);
            }

            float4 MyFragmentProgram(float2 uv : TEXCOORD0) : SV_TARGET
            {
                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
}