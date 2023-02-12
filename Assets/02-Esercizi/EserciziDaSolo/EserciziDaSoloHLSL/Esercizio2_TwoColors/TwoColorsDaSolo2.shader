Shader "Unlit/TwoColorsDaSolo2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorA("Color A", color) = (1,1,0,1)
        _ColorB("Color B", color) = (0,1,1,1)
        _ColorC("Color C", color) = (0,0,1,1)
        _CutLevel("Cut Level", Range(0,1)) = 0.5
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ColorA;
            float4 _ColorB;
            float4 _ColorC;
            float _CutLevel;

            float remap_float(float In, float2 InMinMax, float2 OutMinMax)
            {
                return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float cutLevel = (_SinTime.w +1) / 2;
                
                if(i.uv.y < cutLevel)
                {
                    float botRemapValue = remap_float(i.uv.y, float2(0,cutLevel), float2(0,1));
                    return lerp(_ColorA,_ColorC, botRemapValue);
                }
                else
                {
                    float botRemapValue = remap_float(i.uv.y, float2(0, cutLevel), float2(0, 1));
                    return lerp(_ColorC,_ColorB, botRemapValue);
                }

                
                
            }
            ENDCG
        }
    }
}
