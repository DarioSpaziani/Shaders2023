Shader "Unlit/Transition"
{
    Properties
    {
        _MaskTex ("Main Texture", 2D) = "white" {}
        _PrimaryColor ("Primary Color", Color) = (1,1,1,1)
        _SecondaryColor ("Primary Color", Color) = (1,1,1,1)
        _CutLevel("Cut Level", Range (0, 1)) = 0.5
        _TransitionWidth("Transition Width", Range (0, 0.3)) = 0.15
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
            // make fog work

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

            struct v2f //sta per vertex to fragment
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            fixed4 _PrimaryColor;
            fixed4 _SecondaryColor;
            float _CutLevel;
            float _TransitionWidth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MaskTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float maskValue = tex2D(_MaskTex, i.uv).x;

                //_Time float4 (t/20, t,t*2, t*3)
                //_SinTime float4 (t/8, t/4, t/2, t)
                //_CosTime (t/8, t/4, t/2, t)
                //unity_DeltaTime float4 (dt, 1/dt, smoothDt, 1/smoothDt)

                float cutLevel =(_SinTime.w+1) /2;
                //Remap
                //[A;B] Prima di A torna sempre 0
                //      Dopo di B torna sempre 1
                //      Il range corretto (A;B) torna "gradient" da 0 a 1;
                                
                float2 inRange =float2 (cutLevel,cutLevel + _TransitionWidth);
                

                maskValue= remap_float(maskValue, inRange, float2(0,1));

                maskValue = saturate(maskValue);

                return lerp(_PrimaryColor,_SecondaryColor,maskValue);
            }
            
            ENDCG
        }
    }
}
