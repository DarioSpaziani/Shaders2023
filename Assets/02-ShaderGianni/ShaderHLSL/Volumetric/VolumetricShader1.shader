Shader "Unlit/VolumetricShader1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Center ("Sphere Center", Vector) = (0, 0, 0, 0)
        _Radius ("Radius", float) = 1
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
            float3 _Center;
            float _Radius;

            #define STEPS 64
            #define STEP_SIZE 0.01

            bool sphereHit(float3 p)
            {
                return distance(p, _Center) < _Radius;
            }

            fixed4 raymarch(float3 position, float3 direction)
            {
                for (int i = 0; i < STEPS; i++)
                {
                    if (sphereHit(position))
                        return fixed4(1, 0, 0, 1); // Red

                    position += direction * STEP_SIZE;
                }

                return fixed4(0, 0, 0, 1); // Black
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
