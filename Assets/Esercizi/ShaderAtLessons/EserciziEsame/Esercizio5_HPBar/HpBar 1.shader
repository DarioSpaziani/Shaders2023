Shader "Unlit/HpBar"
{
    Properties
    {
        _Value ("Value", Range(0, 1)) = 0.5
        _LowHpValue ("Low Hp Value", Range(0, 1)) = 0.2
        _LowHpColor ("Low Hp Color", Color) = (1,1,1,1) 
        _MidHpValue ("Mid Hp Value", Range(0, 1)) = 0.4
        _MidHpColor ("Mid Hp Color", Color) = (1,1,1,1) 
        _HighHpColor ("High Hp Color", Color) = (1,1,1,1) 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float remap_float(float In, float2 InMinMax, float2 OutMinMax)
            {
                return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

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

            float4 _LowHpColor;
            float4 _MidHpColor;
            float4 _HighHpColor;
            float _Value;
            float _LowHpValue;
            float _MidHpValue;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                if(_Value < _LowHpValue)
                {
                    float timeValue = (sin(_Time.w) + 1) / 2;
                    return lerp(_LowHpColor, (1,1,1,1), timeValue);
                }
                if(_Value < _MidHpValue)
                {
                    return lerp(_LowHpColor, _MidHpColor, remap_float(_Value, float2(_LowHpValue, _MidHpValue), float2(0, 1)));
                }
                return lerp(_MidHpColor, _HighHpColor, remap_float(_Value, float2(_MidHpValue, 1), float2(0, 1)));
            }
            ENDCG
        }
    }
}
