Shader "Unlit/TerrainMio"
{
    Properties
    {
        [Header(Light)]
        _WaterTex("Water Tex", 2D) = "white" {}
        _WaterColor("Water Color", color) = (1,1,1,1)
        _WaterHeight("Water Height", float) = 0

        [Space] [Header(Water)]
        _GrassTex("Grass Tex", 2D) = "white" {}
        _GrassColor("Grass Color", color)=(1,1,1,1)
        _GrassHeight("Grass Height", float) = 5

        [Space] [Header(Water)]
        _RockAngle("Rock asngle", Range(0,1)) = 0.5
        _GrassAngle("Grass angle", Range(0,1)) = 0.45
        _RockTex("Rock Tex", 2D) = "white" {}
        _RockColor("Rock Color", color) = (1,1,1,1)
        _RockHeight("Rock Height", float) = 10

        [Space] [Header(Water)]
        _SnowTex("Snow Tex", 2D) = "white" {}
        _SnowColor("Snow Color", color) = (1,1,1,1)

        _FadeWidth("Fade Width", Range(0,5)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Opaque" "TerrainCompatible"="True" }
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
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 worldPos: TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            float4 tex_ST;
            
            sampler2D _WaterTex;
            float4 _WaterTex_ST;
            float4 _WaterColor;
            float _WaterHeight;

            sampler2D _GrassTex;
            float _GrassAngle;
            float4 _GrassTex_ST;
            float4 _GrassColor;
            float _GrassHeight;

            sampler2D _RockTex;
            float _RockAngle;
            float4 _RockTex_ST;
            float4 _RockColor;
            float _RockHeight;

            sampler2D _SnowTex;
            float4 _SnowTex_ST;
            float4 _SnowColor;
            float _FadeWidth;

            float remap_float(float In, float2 InMinMax, float2 OutMinMax)
            {
                return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float mask;
                float2 inRange;
                fixed4 col = (1,1,1,1);

                //Water range
                if(i.worldPos.y <= _WaterHeight - _FadeWidth)
                {
                    float2 thisUv = TRANSFORM_TEX(i.uv, _WaterTex);
                    col = tex2D(_WaterTex,thisUv) * _WaterColor;
                }
                
                //Water and grass fade
                else if(i.worldPos.y <= _WaterHeight + _FadeWidth)
                {
                    float2 thisUv = TRANSFORM_TEX(i.uv, _WaterTex);
                    float4 colA = tex2D(_WaterTex, thisUv) * _WaterColor;
                    thisUv = TRANSFORM_TEX(i.uv, _GrassTex);
                    float4 colB = tex2D(_GrassTex, thisUv) * _GrassColor;
                    inRange = float2(_WaterHeight - _FadeWidth, _WaterHeight + _FadeWidth);
                    mask = saturate(remap_float(i.worldPos.y, inRange, float2(0,1)));
                    col = lerp(colA, colB, mask);
                }
                
                //Grass range
                else if(i.worldPos.y <= _GrassHeight - _FadeWidth)
                {
                    float2 thisUv = TRANSFORM_TEX(i.uv, _GrassTex);
                    col = tex2D(_GrassTex,thisUv) * _GrassColor;
                }
                
                //Grass and rock fade
                else if(i.worldPos.y <= _GrassHeight + _FadeWidth)
                {
                    float2 thisUv = TRANSFORM_TEX(i.uv, _GrassTex); //TRANSFORM_TEX utilizza una tex(_GrassTex)
                    //che ha anche la versione _ST(Scale Translate) = Scale(float2 x,y) Tiling(*) Translate(float2 z,w) Offset(+)
                    
                    float4 colA = tex2D(_GrassTex, thisUv) * _GrassColor;
                    thisUv = TRANSFORM_TEX(i.uv, _RockTex);
                    float4 colB = tex2D(_RockTex, thisUv) * _RockColor;
                    inRange = float2(_GrassHeight - _FadeWidth, _GrassHeight + _FadeWidth);
                    mask = saturate(remap_float(i.worldPos.y, inRange, float2(0,1)));
                    col = lerp(colA, colB, mask);
                }

                //Rock range
                else if(i.worldPos.y <= _RockHeight - _FadeWidth)
                {
                    float2 thisUv = TRANSFORM_TEX(i.uv, _RockTex);
                    col = tex2D(_RockTex,thisUv) * _RockColor;
                }

                //Rock and snow fade
                else if(i.worldPos.y <= _RockHeight + _FadeWidth)
                {
                    float2 thisUv = TRANSFORM_TEX(i.uv, _RockTex);
                    float4 colA = tex2D(_RockTex, thisUv) * _RockColor;
                    thisUv = TRANSFORM_TEX(i.uv, _SnowTex);
                    float4 colB = tex2D(_SnowTex, thisUv) * _SnowColor;
                    inRange = float2(_RockHeight - _FadeWidth, _RockHeight + _FadeWidth);
                    mask = saturate(remap_float(i.worldPos.y, inRange, float2(0,1)));
                    col = lerp(colA, colB, mask);
                }
                //Snow range
                else
                {
                    float2 thisUv = TRANSFORM_TEX(i.uv, _SnowTex);
                    col = tex2D(_SnowTex,thisUv) * _SnowColor;
                }
                
                return col;
            }
            ENDCG
        }
    }
}
