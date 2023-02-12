Shader "Unlit/TransitionDaSolo"
{
    Properties
    {
        _MaskTex ("Main Texture", 2D) = "white" {}
        _PrimaryColor("Primary Color", color) = (1,1,1,1)
        _SecondaryColor("Primary Color", color) = (1,1,1,1)
        _CutLevel("Cut Level", Range(0,1)) = 0.3
        _TransitionWidth("Transition Width", Range (0,0.2)) = 0.5
    }
    SubShader
    {
        Tags { "Queue"="Transparent"  "RenderType"="Transparent" }
        LOD 100

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

            sampler2D _MaskTex;
            float4 _MainTex_ST;
            float4 _PrimaryColor;
            float4 _SecondaryColor;
            float _CutLevel;
            float _TransitionWidth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MaskTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
