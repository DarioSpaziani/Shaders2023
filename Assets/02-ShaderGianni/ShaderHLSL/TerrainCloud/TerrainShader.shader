Shader "Unlit/TerrainShader"
{
    Properties
    {
         [Header(Light)] 
        _SpecularPower ("Specular", float) = 0.5
        _Gloss ("Gloss", float) = 0.5

        [Header(Global Rules)]
        _TransitionWidth ("Transition Width", float) = 1
        
         [Space, Header(Water)]
        _WaterTex ("Water Texture", 2D) = "white" {}
        _WaterLevel ("Water level", float) = 0
        _WaterColor ("Water color", Color) = (1,1,1,1) 

         [Space, Header(Grass)]
        _GrassTex ("Grass Texture", 2D) = "white" {}
        _GrassColor ("Grass color", Color) = (0,1,0,1) 

         [Space, Header(Rock)]
        _RockTex ("Rock Texture", 2D) = "white" {}
        _RockLevel ("Rock level", float) = 10
        _RockColor ("Rock color", Color) = (0,0,1,1)
        
         [Space, Header(Snow)]
        _SnowTex ("Snow Texture", 2D) = "white" {}
        _SnowLevel ("Snow level", float) = 20
        _SnowColor ("Snow color", Color) = (1,0,0,1) 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "TerrainCompatible"="True" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

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
                float3 wPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _WaterTex;
            float4 _WaterTex_ST;
            sampler2D _GrassTex;
            float4 _GrassTex_ST;
            sampler2D _RockTex;
            float4 _RockTex_ST;
            sampler2D _SnowTex;
            float4 _SnowTex_ST;
            float4 tex_ST;
            float4 _WaterColor;
            float4 _GrassColor;
            float4 _RockColor;
            float4 _SnowColor;
            float3 _ViewDirection;
            float _SpecularPower;
            float _Gloss;
            float _WaterLevel;
            float _RockLevel;
            float _SnowLevel;
            float _TransitionWidth;

            float remap_float(float In, float2 InMinMax, float2 OutMinMax)
            {
                return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            fixed4 simpleLambert(fixed3 normal) 
            {
                fixed3 lightDir = _WorldSpaceLightPos0.xyz;
                fixed3 lightCol = _LightColor0.rgb;

                // Normal
                fixed NdotL = max(dot(normal, lightDir), 0);
                fixed4 c;

                // Specular
                fixed3 h = (lightDir - _ViewDirection) / (float)2;
                fixed s = pow(dot(normal, h), _SpecularPower) * _Gloss;

                // Color
                c.rgb = lightCol * NdotL + s;
                c.a = 1;
                return c;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.normal = v.normal;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                _ViewDirection = normalize(i.wPos - _WorldSpaceCameraPos);

                fixed4 col = (1,1,1,1);
                //Water
                if (i.wPos.y < _WaterLevel - _TransitionWidth)
                {
                    float2 thisUv = TRANSFORM_TEX(i.uv, _WaterTex);
                    col = tex2D(_WaterTex, thisUv) * _WaterColor;
                }
                else if (i.wPos.y < _WaterLevel + _TransitionWidth)
                {
                    float2 thisUv = TRANSFORM_TEX(i.uv, _WaterTex);
                    float4 colA = tex2D(_WaterTex, thisUv) * _WaterColor;
                    thisUv = TRANSFORM_TEX(i.uv, _GrassTex);
                    float4 colB = tex2D(_GrassTex, thisUv) * _GrassColor;
                    float remapValue = remap_float(i.wPos.y, 
                        float2(_WaterLevel - _TransitionWidth, _WaterLevel + _TransitionWidth),
                        float2(0, 1));
                    col = lerp(colA, colB, remapValue);
                }
                //Grass
                else if (i.wPos.y < _RockLevel - _TransitionWidth)
                {
                    float2 thisUv = TRANSFORM_TEX(i.uv, _GrassTex);
                    col = tex2D(_GrassTex, thisUv) * _GrassColor;
                }
                else if (i.wPos.y < _RockLevel + _TransitionWidth)
                {
                    float2 thisUv = TRANSFORM_TEX(i.uv, _GrassTex);
                    float4 colA = tex2D(_GrassTex, thisUv) * _GrassColor;
                    thisUv = TRANSFORM_TEX(i.uv, _RockTex);
                    float4 colB = tex2D(_RockTex, thisUv) * _RockColor;
                    float remapValue = remap_float(i.wPos.y, 
                        float2(_RockLevel - _TransitionWidth, _RockLevel + _TransitionWidth),
                        float2(0, 1));
                    col = lerp(colA, colB, remapValue);
                }
                //Rock
                else if (i.wPos.y < _SnowLevel - _TransitionWidth)
                {
                    float2 thisUv = TRANSFORM_TEX(i.uv, _RockTex);
                    col = tex2D(_RockTex, thisUv) * _RockColor;
                }
                else if (i.wPos.y < _SnowLevel + _TransitionWidth)
                {
                    float2 thisUv = TRANSFORM_TEX(i.uv, _RockTex);
                    float4 colA = tex2D(_RockTex, thisUv) * _RockColor;
                    thisUv = TRANSFORM_TEX(i.uv, _SnowTex);
                    float4 colB = tex2D(_SnowTex, thisUv) * _SnowColor;
                    float remapValue = remap_float(i.wPos.y, 
                        float2(_SnowLevel - _TransitionWidth, _SnowLevel + _TransitionWidth),
                        float2(0, 1));
                    col = lerp(colA, colB, remapValue);
                }
                //Snow
                else
                {
                    float2 thisUv = TRANSFORM_TEX(i.uv, _SnowTex);
                    col = tex2D(_SnowTex, thisUv) * _SnowColor;
                }

                return col * simpleLambert(i.normal);
            }
            ENDCG
        }
    }
}
