Shader "Unlit/VDisplacementHLSL"
{
    Properties
    {
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Intensity ("Intensity", float) = 1 
        _BlinkTime ("BlinkTime", float) = 1 
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

            sampler2D _NoiseTex;
            float _Intensity;
            float _BlinkTime;

            v2f vert (appdata v)
            {
                //v.vertex è la LOCAL vertex position
                v2f o;

                float noiseValue = tex2Dlod(_NoiseTex, float4(v.uv,0,0)); //Utilizzo v.uv e non i.uv perchè qui si chiamano così
                float4 offset = v.normal * noiseValue * _Intensity;

                offset *= pow(sin(_Time.y * _BlinkTime), 6);

                v.vertex += offset; //Esplosione dei vertici

                //Eventuali modifiche a v.vertex vanno fatte prima di questo
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return 1;
            }
            ENDCG
        }
    }
}
