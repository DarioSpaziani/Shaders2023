Shader "Unlit/B&W"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LineColor("LineColor", Color) = (1,1,1,1)
        _LineThickness("Line Thickness", float) =0.0001
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
            float4 _LineColor;
            float _LineThickness;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float cutLevel = 0.5;
                if(i.uv.x < cutLevel)
                {
                    float mid = col.r * 0.2126f + col.g * 0.7152f + col.b * 0.0722f;
                    return col = mid;
                }
                if(i.uv.x > cutLevel)
                {
                    return col;
                }
                return _LineColor;
            }
            ENDCG
        }
    }
}
