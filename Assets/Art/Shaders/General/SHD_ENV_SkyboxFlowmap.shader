Shader "DragonCity2/ENV/Skybox/Skybox FlowMap"
{
    Properties
    {
        [HDR]_TintColor("Base Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _MainTex ("Skybox", 2D) = "grey" {}
	    [NoScaleOffset] _FlowMap ("FlowMap", 2D) = "grey" {}
        _Rotation ("Rotation", Range(0, 360)) = 0
	    _WindDir ("Wind Rotation", Range(0, 360)) = 0
        _WindSpeed ("Wind Speed", Range(0, 10)) = 3
	    _FlowStrength ("Flow Strenght", Range(0, 5)) = 1
        [Toggle] _UseFog("Apply fog", Float) = 0
        _FogIntensity ("Fog Intensity", Range(0, 1)) = .5
    }

    SubShader
    {
        Tags
        {
            "Queue"="Background"
            "RenderType"="Background"
            "PreviewType"="Skybox"
        }

        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            float4          _TintColor;
            sampler2D       _MainTex;
		    sampler2D       _FlowMap;
            float           _Rotation;
            float           _WindDir;
		    float           _FlowStrength;
            float           _WindSpeed;
            int             _UseFog;
            float           _FogIntensity;

            inline float2 ToRadialCoords(float3 coords)
            {
                float3 normalizedCoords = normalize(coords);
                float latitude = acos(normalizedCoords.y);
                float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
                float2 sphereCoords = float2(longitude, latitude) * float2(0.5/UNITY_PI, 1.0/UNITY_PI);
                return float2(0.5,1.0) - sphereCoords;
            }

            float3 RotateAroundYInDegrees (float3 vertex, float degrees)
            {
                float alpha = degrees * UNITY_PI / 180.0;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                return float3(mul(m, vertex.xz), vertex.y).xzy;
            }

            struct appdata
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4	vertex : SV_POSITION;
                float3	texcoord : TEXCOORD0;
			    float3	texcoord2 : TEXCOORD6;
                float2 image180ScaleAndCutoff : TEXCOORD1;
                float4 layout3DScaleAndOffset : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
                UNITY_FOG_COORDS(3)
            };

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                float3 rotated = RotateAroundYInDegrees(v.vertex, _Rotation);
			    float3 rotated2 = RotateAroundYInDegrees(v.vertex, _WindDir);
                o.vertex = UnityObjectToClipPos(rotated);
                o.texcoord = v.vertex.xyz;
			    o.texcoord2 = UnityObjectToClipPos(rotated2);
                o.image180ScaleAndCutoff = float2(1.0, 1.0);
                o.layout3DScaleAndOffset = float4(0,0,1,1);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 tc = ToRadialCoords(i.texcoord);
                if (tc.x > i.image180ScaleAndCutoff[1])
                    return half4(0,0,0,1);
                tc.x = fmod(tc.x*i.image180ScaleAndCutoff[0], 1);
                tc = (tc + i.layout3DScaleAndOffset.xy) * i.layout3DScaleAndOffset.zw;

			    half4	baseTexture = tex2D(_MainTex, tc);
			    float2	windDir = float2(_WindDir / 360.0, 0);
			    float2	flowDir = tex2D(_FlowMap, tc + windDir) * 2.0f - 1.0f;
			    float2	flowSpeed = flowDir * _FlowStrength * baseTexture.a * 0.1;
			    float	t = _WindSpeed * _Time.x;

			    float2	scroll = float2(sin(_WindDir), cos(_WindDir));
			    float	phase0 = frac(t + 0.5f);
			    float	phase1 = frac(t + 1.0f);

			    float2	gradient = abs(tc * 2 - 1);	
			    float	rMask = smoothstep(0.9, 1, gradient.r);
			    float	gMask = smoothstep(0.7, 0.9, gradient.g);

			    half4	tex0 = tex2D(_MainTex, tc + flowSpeed * phase0);
			    half4	tex1 = tex2D(_MainTex, tc + flowSpeed * phase1);

			    float	sinLerp = abs((0.5f - phase0) / 0.5f);
			    float4	flowColor = lerp(tex0, tex1, sinLerp);
			    float4	hideLine = lerp(flowColor, baseTexture, rMask);
			    float4	hideTop = lerp(hideLine, baseTexture, gMask) * _TintColor;

                if (_UseFog == 1)
                    UNITY_APPLY_FOG(i.fogCoord + (1 - _FogIntensity), hideTop);

                return hideTop;
            }
            ENDCG
        }
    }
    CustomEditor "SHD_SkyboxFlowmap"
    Fallback Off
}
