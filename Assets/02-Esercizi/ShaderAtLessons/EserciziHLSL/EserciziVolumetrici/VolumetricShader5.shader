Shader "Unlit/VolumetricShader5"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Center ("Sphere Center", Vector) = (0, 0, 0, 0)
        _BoxCenter ("Box Center", Vector) = (0, 0, 0, 0)
        _BoxSize ("Box Size", Vector) = (0, 0, 0, 0)
        _Radius ("Radius", float) = 1
        _Color ("Tint", Color) = (1, 1, 1, 1)
        _SpecularPower ("Specular", float) = 0.5
        _Gloss ("Gloss", float) = 0.5
        _K ("K Value", float) = 32
        _A ("A Value", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

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
            float3 _BoxCenter;
            float3 _ViewDirection;
            float3 _BoxSize;
            float _Radius;
            float _SpecularPower;
            float _Gloss;
            float _K;
            float _A;

            #define MAX_STEPS 64
            #define MIN_DISTANCE 0.000001

            float sdf_blend(float d1, float d2, float a)
            {
                return a * d1 + (1 - a) * d2;
            }

            float sdf_smin(float a, float b, float k = 32)
            {
                float res = exp(-k * a) + exp(-k * b);
                return -log(max(0.0001, res)) / k;
            }

            float v_max(float x, float y, float z)
            {
                float d = x;
                d = max(d, y);
                d = max(d, z);
                return d;
            }

            float sdf_box(float3 p, float3 c, float3 s)
            {
                float x = max
                (
                    p.x - c.x - float3(s.x / 2., 0, 0),
                    c.x - p.x - float3(s.x / 2., 0, 0)
                );

                float y = max
                (
                    p.y - c.y - float3(s.y / 2., 0, 0),
                    c.y - p.y - float3(s.y / 2., 0, 0)
                );

                float z = max
                (
                    p.z - c.z - float3(s.z / 2., 0, 0),
                    c.z - p.z - float3(s.z / 2., 0, 0)
                );

                return v_max(x, y, z);
            }

            float sdf_sphere(float3 p, float3 c, float r)
            {
                return distance(p, c) - r;
            }

            float map(float3 p)
            {
                return sdf_smin
                (
                    min
                    (
                        sdf_box(p, _BoxCenter, _BoxSize),
                        sdf_sphere(p, -_Center, _Radius)
                    ),
                    sdf_sphere(p, _Center, _Radius),
                    _K
                );
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
                c.rgb = _Color * lightCol * NdotL + s;
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
                return fixed4(0, 0, 0, 0);
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
                _ViewDirection = normalize(i.wPos - _WorldSpaceCameraPos);
                return raymarch(i.wPos, _ViewDirection);
            }
            ENDCG
        }
    }
}
