Shader "Unlit/YakuzaShader"
{

    Properties
    {
        Radius ("Circle Radius", Range(0,1)) = 1
        DivisionCount ("Division Count", Int) = 4
        PaintColor ("Paint Color", Color) = (1,1,1,1)
        timeMult ("Rotation Speed", float) = 0
        fadeMult ("Fade Multiplier", Range(0,1)) = 0
        angularFadeMult ("Angular Fade Multiplier", Range(0,1)) = 0
        angularOffset("Angular Offset", float) = 0
        centerOffsetX("Center Offset : X", Range(-0.5,0.5)) = 0.0
        centerOffsetY("Center Offset : Y", Range(-0.5,0.5)) = 0.0

        _NoiseTex ("Noise Tex", 2D) = "white"
        _FlowStrength ("Flow Strength", Float) = 1
        _FlowSpeed ("Flow Speed", Float) = 1

    }
    SubShader
    {

        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float Radius;
            float4 PaintColor;
            int DivisionCount;
            float timeMult;
            float fadeMult;
            float angularFadeMult;
            float centerOffsetX;
            float centerOffsetY;
            float angularOffset;
            sampler2D _NoiseTex;
            float _FlowStrength;
            float _FlowSpeed;


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f s) : SV_Target
            {
                DivisionCount *= 2;
                
                fixed2 flowOffset = tex2D(
                    _NoiseTex, s.uv + float2(sin(_Time.y * _FlowSpeed), cos(_Time.y * _FlowSpeed)));
                flowOffset -= fixed2(0.5, 0.5);
                flowOffset *= _FlowStrength;


                float2 imageCenter = (0.5, 0.5);
                float2 center = float2(centerOffsetX + imageCenter.x, centerOffsetY + imageCenter.y);
                float rotateAngle = _Time * timeMult;
                float new_u = center.x + (s.uv.x - center.x) * cos(rotateAngle) - (s.uv.y - center.y) *
                    sin(rotateAngle);
                float new_v = center.y + (s.uv.x - center.x) * sin(rotateAngle) + (s.uv.y - center.y) *
                    cos(rotateAngle);
                float2 rotatedUV = float2(new_u, new_v);
                s.uv = rotatedUV;
                s.uv += flowOffset;

                
                if (distance(center, s.uv) > Radius)
                {
                    return float4(0, 0, 0, 0); // set it white if in radius
                }
                
                float2 dir = s.uv - center;
                float angle = atan2(dir.y, dir.x);
                angle = degrees(angle);
                if (angle < 0) angle += 360;
                bool isPainted = false;

                float angularDistanceToPivot;
                for (int i = 0; i < DivisionCount; i++)
                {
                    float startAngle = i * 360 / DivisionCount;
                    float endAngle = (i + 1) * 360 / DivisionCount;

                    if (i % 2 == 0 && angle > (startAngle - angularOffset) && angle < endAngle + angularOffset)
                    {
                        float centerPivot = (startAngle + endAngle) / 2;
                        angularDistanceToPivot = abs(centerPivot - angle);
                        isPainted = true;
                        break;
                    }
                }


                if (isPainted)
                {
                    float4 result = PaintColor;
                    float4 distanceToCenterMultiplier = distance(imageCenter, s.uv);
                    
                    result.a *= 1 - distanceToCenterMultiplier * fadeMult / Radius;
                    result.a *= 1 - (angularFadeMult * (angularDistanceToPivot * 2) / ((360 / DivisionCount) +
                        angularOffset * 2));
                    result.a = clamp(result.a, 0, 1);

                    return result;
                }
                return float4(0, 0, 0, 0);
            }
            ENDCG
        }
    }

}