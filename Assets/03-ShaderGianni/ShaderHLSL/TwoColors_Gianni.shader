Shader "Unlit/TwoColors_Gianni"
{
    Properties
    {
        _ColorA ("Color A", Color) = (1,1,1,1)
        _ColorB ("Color B", Color) = (1,1,1,1)
        _ColorC ("Color C", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

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

            float4 _ColorA;
            float4 _ColorB;
            float4 _ColorC;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float cutLevel = (_SinTime.w + 1) / 2;

                //i.uv.y => Da 0 a 1
                if(i.uv.y < cutLevel) //Da 0 a cutLevel  =>  Da _ColorA a _ColorC
                {
                    float botRemapValue = remap_float(i.uv.y, float2(0, cutLevel), float2(0, 1));
                    return lerp(_ColorA, _ColorC, botRemapValue);
                }
                else //Da cutLevel a 1  =>  Da _ColorC a _ColorB
                {
                    float topRemapValue = remap_float(i.uv.y, float2(cutLevel, 1), float2(0, 1));
                    return lerp(_ColorC, _ColorB, topRemapValue);
                }
            }
            ENDCG
        }
    }
}
