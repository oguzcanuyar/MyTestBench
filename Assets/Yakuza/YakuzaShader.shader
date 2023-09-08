Shader "Fomo/JapaneseSunShader"
{

    Properties
    {
        Radius ("Circle Radius", Range(0,1)) = 1
        DivisionCount ("Division Count", Int) = 4
        PaintColor ("Paint Color", Color) = (1,1,1,1)
        _SecondaryColor ("Secondary Color", Color) = (1, 1, 1, 1)
        timeMult ("Rotation Speed", float) = 0
        fadeMult ("Fade Multiplier", Range(0,1)) = 0
        angularFadeMult ("Angular Fade Multiplier", Range(0,1)) = 0
        angularOffset("Angular Offset", float) = 0
        centerOffsetX("Center Offset : X", Range(-0.5,0.5)) = 0.0
        centerOffsetY("Center Offset : Y", Range(-0.5,0.5)) = 0.0

        _NoiseTex ("Noise Tex", 2D) = "white"
        _FlowStrength ("Flow Strength", Float) = 1
        _FlowSpeed ("Flow Speed", Float) = 1
        _ScreenY("Screen Y", Float) = 1
        _ScreenX("Screen X", Float) = 1

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
            float _ScreenY, _ScreenX;
            fixed4 _SecondaryColor;
            
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
                float rate = _ScreenY / _ScreenX;
                float yRate = 1;
                float xRate = 1;

                if (rate > 1)
                    yRate = rate;
                else
                    xRate = 1/rate;
                
                s.uv.y *= yRate;
                s.uv.x *= xRate;
                
                fixed2 flowOffset = tex2D(
                    _NoiseTex, s.uv + float2(sin(_Time.y * _FlowSpeed), cos(_Time.y * _FlowSpeed)));
                flowOffset -= fixed2(0.5, 0.5);
                flowOffset *= _FlowStrength;


                float2 imageCenter = float2(0.5 * xRate, 0.5 * yRate);


                float2 center = float2(xRate*centerOffsetX + imageCenter.x, yRate * centerOffsetY + imageCenter.y);
                float rotateAngle = _Time * timeMult;
                float new_u = center.x + (s.uv.x - center.x) * cos(rotateAngle) - (s.uv.y - center.y) *
                    sin(rotateAngle);
                float new_v = center.y + (s.uv.x - center.x) * sin(rotateAngle) + (s.uv.y - center.y) *
                    cos(rotateAngle);
                float2 rotatedUV = float2(new_u, new_v);
                float distanceToOrigin = distance(imageCenter, s.uv);
                s.uv = rotatedUV;
                s.uv += flowOffset;

                //float xDist = abs(imageCenter.x - s.uv.x);
                if (distanceToOrigin > Radius * yRate)
                {
                    return float4(0, 0, 0, 0); // set it white if in radius
                }

                float2 dir = s.uv - center;
                float angle = atan2(dir.y, dir.x);
                angle = degrees(angle);
                if (angle < 0) angle += 360;
                float angularDistanceToPivot;

                float interval = (360 / DivisionCount);
                float mod = angle % interval;
                float mod2 = mod - interval;
                float minPoint = min(abs(mod), abs(mod2));

                if (minPoint < angularOffset)
                {
                    angularDistanceToPivot = minPoint;
                    float4 result = PaintColor;
                    
                    result.a *= 1 - distance(center, s.uv) * fadeMult * 2 * 0.5 / Radius;
                    float sideMult = (angularFadeMult * (angularDistanceToPivot * 10) / ((360 / DivisionCount) +
                        angularOffset * 2));
                    result.a *= 1 - sideMult;
                    
                    result.a = clamp(result.a, 0, 1);

                    result.rgb = lerp(PaintColor, _SecondaryColor, sideMult);

                    return result;
                }


                return float4(0, 0, 0, 0);
            }
            ENDCG
        }
    }

}