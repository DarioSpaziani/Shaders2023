Shader "Unlit/Grayscale"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Intensity("Intensity", float) = 1
        _Speed("Speed", float) = 1 
        _Color("Color", color) = (1,1,1,1)
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

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            float _Intensity;
            float _Speed;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;

                float noiseValue = tex2Dlod(_NoiseTex, float4(v.uv + (0, - _Time.y * _Speed), 0, 0));
                
                v.vertex += noiseValue * v.normal;                
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col=tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
