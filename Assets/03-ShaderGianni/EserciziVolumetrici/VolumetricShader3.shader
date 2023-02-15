Shader "Unlit/VolumetricShader3"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Center ("Sphere Center", Vector) = (0, 0, 0, 0)
        _Radius ("Radius", float) = 1
        _Color ("Tint", Color) = (1, 1, 1, 1)
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
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 wPos : TEXCOORD1;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float3 _Center;
            float _Radius;

            #define MAX_STEPS 64
            #define MIN_DISTANCE 0.000001

            float map(float3 p)
            {
                return distance(p, _Center) - _Radius; //This is for a sphere
            }

            fixed4 simpleLambert(fixed3 normal) {
                fixed3 lightDir = _WorldSpaceLightPos0.xyz;
                fixed3 lightCol = _LightColor0.rgb;

                fixed NdotL = max(dot(normal, lightDir), 0);
                fixed4 c;
                c.rgb = _Color * lightCol * NdotL;
                c.a = 1;
                return c;
            }

            float3 normal(float3 p)
            {
                const float eps = 0.01;

                return normalize
                (float3
                    (map(p + float3(eps, 0, 0)) - map(p - float3(eps, 0, 0)),
                        map(p + float3(0, eps, 0)) - map(p - float3(0, eps, 0)),
                        map(p + float3(0, 0, eps)) - map(p - float3(0, 0, eps))
                    )
                );
            }

            fixed4 renderSurface(float3 p)
            {
                float3 n = normal(p);
                return simpleLambert(n);
            }

            fixed4 raymarch(float3 position, float3 direction)
            {
                for (int i = 0; i < MAX_STEPS; i++)
                {
                    float distance = map(position);
                    if (distance < MIN_DISTANCE)
                        return renderSurface(position);

                    position += distance * direction;
                }
                return fixed4(1, 0, 0, 1);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewDirection = normalize(i.wPos - _WorldSpaceCameraPos);
                return raymarch(i.wPos, viewDirection);
            }
            ENDCG
        }
    }
}
