Shader "DragonCity2/Arenas/Vegetation"
{
    Properties
    {
        [NoScaleOffset]_MainTexture("Main Texture", 2D) = "white" {}
        _Color("Color", Color) = (0.4166895, 0.6037736, 0.3958704, 0)
        _AlphaCutoff("Alpha Cutoff", Range(0, 1)) = 0.5
        _WindDirection("Wind Direction", Vector) = (1, 0, 0, 0)
        _WindSpeed("Wind Speed", Range(0, 2)) = 1
        _WindStrenght("Wind Strenght", Range(0, 1)) = 0.2
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 3.0
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        //#pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            //#pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        //#pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        //#pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        //#pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        //#pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Color;
        float _AlphaCutoff;
        float2 _WindDirection;
        float _WindSpeed;
        float _WindStrenght;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);

            // Graph Functions
            
        void Unity_Normalize_float2(float2 In, out float2 Out)
        {
            Out = normalize(In);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }

        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
        {
            //rotation matrix
            UV -= Center;
            float s = sin(Rotation);
            float c = cos(Rotation);

            //center rotation matrix
            float2x2 rMatrix = float2x2(c, -s, s, c);
            rMatrix *= 0.5;
            rMatrix += 0.5;
            rMatrix = rMatrix*2 - 1;

            //multiply the UVs by the rotation matrix
            UV.xy = mul(UV.xy, rMatrix);
            UV += Center;

            Out = UV;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1 = IN.WorldSpacePosition[0];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_G_2 = IN.WorldSpacePosition[1];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3 = IN.WorldSpacePosition[2];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_A_4 = 0;
            float2 _Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0 = float2(_Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1, _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3);
            float2 _Property_f00371a39d318782a68a4b5266d8947d_Out_0 = _WindDirection;
            float2 _Normalize_209ccab159865f8193f95c1c55f63016_Out_1;
            Unity_Normalize_float2(_Property_f00371a39d318782a68a4b5266d8947d_Out_0, _Normalize_209ccab159865f8193f95c1c55f63016_Out_1);
            float _Property_2c1632165185328c97f032773360ec3b_Out_0 = _WindSpeed;
            float2 _Multiply_680225c15a6a168faad1cd812bfac140_Out_2;
            Unity_Multiply_float(_Normalize_209ccab159865f8193f95c1c55f63016_Out_1, (_Property_2c1632165185328c97f032773360ec3b_Out_0.xx), _Multiply_680225c15a6a168faad1cd812bfac140_Out_2);
            float2 _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2;
            Unity_Multiply_float(_Multiply_680225c15a6a168faad1cd812bfac140_Out_2, (IN.TimeParameters.x.xx), _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2);
            float2 _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2;
            Unity_Add_float2(_Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0, _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2, _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2);
            float _SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2;
            Unity_SimpleNoise_float(_Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2, 2, _SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2);
            float _Property_03d42ffca7dcdc8a8c5caceff1356825_Out_0 = _WindStrenght;
            float _Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2;
            Unity_Multiply_float(_SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2, _Property_03d42ffca7dcdc8a8c5caceff1356825_Out_0, _Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2);
            float3 _Add_6071de5427ea908aacbf1265ad937975_Out_2;
            Unity_Add_float3((_Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2.xxx), IN.WorldSpacePosition, _Add_6071de5427ea908aacbf1265ad937975_Out_2);
            float3 _Transform_f5ad1147d9bdbe8d896e3761311f7116_Out_1 = TransformWorldToObject(_Add_6071de5427ea908aacbf1265ad937975_Out_2.xyz);
            description.Position = _Transform_f5ad1147d9bdbe8d896e3761311f7116_Out_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_e5eaacad97a32788b000ece3d1e082f4_Out_0 = _Color;
            UnityTexture2D _Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1 = IN.WorldSpacePosition[0];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_G_2 = IN.WorldSpacePosition[1];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3 = IN.WorldSpacePosition[2];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_A_4 = 0;
            float2 _Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0 = float2(_Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1, _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3);
            float2 _Property_f00371a39d318782a68a4b5266d8947d_Out_0 = _WindDirection;
            float2 _Normalize_209ccab159865f8193f95c1c55f63016_Out_1;
            Unity_Normalize_float2(_Property_f00371a39d318782a68a4b5266d8947d_Out_0, _Normalize_209ccab159865f8193f95c1c55f63016_Out_1);
            float _Property_2c1632165185328c97f032773360ec3b_Out_0 = _WindSpeed;
            float2 _Multiply_680225c15a6a168faad1cd812bfac140_Out_2;
            Unity_Multiply_float(_Normalize_209ccab159865f8193f95c1c55f63016_Out_1, (_Property_2c1632165185328c97f032773360ec3b_Out_0.xx), _Multiply_680225c15a6a168faad1cd812bfac140_Out_2);
            float2 _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2;
            Unity_Multiply_float(_Multiply_680225c15a6a168faad1cd812bfac140_Out_2, (IN.TimeParameters.x.xx), _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2);
            float2 _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2;
            Unity_Add_float2(_Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0, _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2, _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2);
            float _SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2;
            Unity_SimpleNoise_float(_Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2, 8, _SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2);
            float _Property_331763d7c2737a8d902136d353fa866b_Out_0 = _WindSpeed;
            float _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2;
            Unity_Multiply_float(_SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2, _Property_331763d7c2737a8d902136d353fa866b_Out_0, _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2);
            float2 _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3;
            Unity_Rotate_Radians_float(IN.uv0.xy, float2 (0.5, 0.5), _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2, _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3);
            float4 _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0.tex, _Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0.samplerstate, _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3);
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_R_4 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.r;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_G_5 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.g;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_B_6 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.b;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_A_7 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.a;
            float4 _Multiply_2a67d02edb8b7c8aa44dc72735ece644_Out_2;
            Unity_Multiply_float(_Property_e5eaacad97a32788b000ece3d1e082f4_Out_0, _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0, _Multiply_2a67d02edb8b7c8aa44dc72735ece644_Out_2);
            float _Property_d2a85d83b3a0138a98c436e73322f689_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Multiply_2a67d02edb8b7c8aa44dc72735ece644_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0;
            surface.Occlusion = 1.5;
            surface.Alpha = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_A_7;
            surface.AlphaClipThreshold = _Property_d2a85d83b3a0138a98c436e73322f689_Out_0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // Render State
            Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 3.0
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        //#pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        //#pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_GBUFFER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Color;
        float _AlphaCutoff;
        float2 _WindDirection;
        float _WindSpeed;
        float _WindStrenght;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);

            // Graph Functions
            
        void Unity_Normalize_float2(float2 In, out float2 Out)
        {
            Out = normalize(In);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }

        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
        {
            //rotation matrix
            UV -= Center;
            float s = sin(Rotation);
            float c = cos(Rotation);

            //center rotation matrix
            float2x2 rMatrix = float2x2(c, -s, s, c);
            rMatrix *= 0.5;
            rMatrix += 0.5;
            rMatrix = rMatrix*2 - 1;

            //multiply the UVs by the rotation matrix
            UV.xy = mul(UV.xy, rMatrix);
            UV += Center;

            Out = UV;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1 = IN.WorldSpacePosition[0];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_G_2 = IN.WorldSpacePosition[1];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3 = IN.WorldSpacePosition[2];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_A_4 = 0;
            float2 _Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0 = float2(_Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1, _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3);
            float2 _Property_f00371a39d318782a68a4b5266d8947d_Out_0 = _WindDirection;
            float2 _Normalize_209ccab159865f8193f95c1c55f63016_Out_1;
            Unity_Normalize_float2(_Property_f00371a39d318782a68a4b5266d8947d_Out_0, _Normalize_209ccab159865f8193f95c1c55f63016_Out_1);
            float _Property_2c1632165185328c97f032773360ec3b_Out_0 = _WindSpeed;
            float2 _Multiply_680225c15a6a168faad1cd812bfac140_Out_2;
            Unity_Multiply_float(_Normalize_209ccab159865f8193f95c1c55f63016_Out_1, (_Property_2c1632165185328c97f032773360ec3b_Out_0.xx), _Multiply_680225c15a6a168faad1cd812bfac140_Out_2);
            float2 _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2;
            Unity_Multiply_float(_Multiply_680225c15a6a168faad1cd812bfac140_Out_2, (IN.TimeParameters.x.xx), _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2);
            float2 _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2;
            Unity_Add_float2(_Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0, _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2, _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2);
            float _SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2;
            Unity_SimpleNoise_float(_Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2, 2, _SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2);
            float _Property_03d42ffca7dcdc8a8c5caceff1356825_Out_0 = _WindStrenght;
            float _Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2;
            Unity_Multiply_float(_SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2, _Property_03d42ffca7dcdc8a8c5caceff1356825_Out_0, _Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2);
            float3 _Add_6071de5427ea908aacbf1265ad937975_Out_2;
            Unity_Add_float3((_Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2.xxx), IN.WorldSpacePosition, _Add_6071de5427ea908aacbf1265ad937975_Out_2);
            float3 _Transform_f5ad1147d9bdbe8d896e3761311f7116_Out_1 = TransformWorldToObject(_Add_6071de5427ea908aacbf1265ad937975_Out_2.xyz);
            description.Position = _Transform_f5ad1147d9bdbe8d896e3761311f7116_Out_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_e5eaacad97a32788b000ece3d1e082f4_Out_0 = _Color;
            UnityTexture2D _Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1 = IN.WorldSpacePosition[0];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_G_2 = IN.WorldSpacePosition[1];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3 = IN.WorldSpacePosition[2];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_A_4 = 0;
            float2 _Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0 = float2(_Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1, _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3);
            float2 _Property_f00371a39d318782a68a4b5266d8947d_Out_0 = _WindDirection;
            float2 _Normalize_209ccab159865f8193f95c1c55f63016_Out_1;
            Unity_Normalize_float2(_Property_f00371a39d318782a68a4b5266d8947d_Out_0, _Normalize_209ccab159865f8193f95c1c55f63016_Out_1);
            float _Property_2c1632165185328c97f032773360ec3b_Out_0 = _WindSpeed;
            float2 _Multiply_680225c15a6a168faad1cd812bfac140_Out_2;
            Unity_Multiply_float(_Normalize_209ccab159865f8193f95c1c55f63016_Out_1, (_Property_2c1632165185328c97f032773360ec3b_Out_0.xx), _Multiply_680225c15a6a168faad1cd812bfac140_Out_2);
            float2 _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2;
            Unity_Multiply_float(_Multiply_680225c15a6a168faad1cd812bfac140_Out_2, (IN.TimeParameters.x.xx), _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2);
            float2 _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2;
            Unity_Add_float2(_Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0, _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2, _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2);
            float _SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2;
            Unity_SimpleNoise_float(_Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2, 8, _SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2);
            float _Property_331763d7c2737a8d902136d353fa866b_Out_0 = _WindSpeed;
            float _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2;
            Unity_Multiply_float(_SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2, _Property_331763d7c2737a8d902136d353fa866b_Out_0, _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2);
            float2 _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3;
            Unity_Rotate_Radians_float(IN.uv0.xy, float2 (0.5, 0.5), _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2, _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3);
            float4 _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0.tex, _Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0.samplerstate, _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3);
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_R_4 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.r;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_G_5 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.g;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_B_6 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.b;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_A_7 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.a;
            float4 _Multiply_2a67d02edb8b7c8aa44dc72735ece644_Out_2;
            Unity_Multiply_float(_Property_e5eaacad97a32788b000ece3d1e082f4_Out_0, _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0, _Multiply_2a67d02edb8b7c8aa44dc72735ece644_Out_2);
            float _Property_d2a85d83b3a0138a98c436e73322f689_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Multiply_2a67d02edb8b7c8aa44dc72735ece644_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = 0;
            surface.Smoothness = 0;
            surface.Occlusion = 1.5;
            surface.Alpha = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_A_7;
            surface.AlphaClipThreshold = _Property_d2a85d83b3a0138a98c436e73322f689_Out_0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 3.0
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        //#pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Color;
        float _AlphaCutoff;
        float2 _WindDirection;
        float _WindSpeed;
        float _WindStrenght;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);

            // Graph Functions
            
        void Unity_Normalize_float2(float2 In, out float2 Out)
        {
            Out = normalize(In);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }

        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
        {
            //rotation matrix
            UV -= Center;
            float s = sin(Rotation);
            float c = cos(Rotation);

            //center rotation matrix
            float2x2 rMatrix = float2x2(c, -s, s, c);
            rMatrix *= 0.5;
            rMatrix += 0.5;
            rMatrix = rMatrix*2 - 1;

            //multiply the UVs by the rotation matrix
            UV.xy = mul(UV.xy, rMatrix);
            UV += Center;

            Out = UV;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1 = IN.WorldSpacePosition[0];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_G_2 = IN.WorldSpacePosition[1];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3 = IN.WorldSpacePosition[2];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_A_4 = 0;
            float2 _Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0 = float2(_Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1, _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3);
            float2 _Property_f00371a39d318782a68a4b5266d8947d_Out_0 = _WindDirection;
            float2 _Normalize_209ccab159865f8193f95c1c55f63016_Out_1;
            Unity_Normalize_float2(_Property_f00371a39d318782a68a4b5266d8947d_Out_0, _Normalize_209ccab159865f8193f95c1c55f63016_Out_1);
            float _Property_2c1632165185328c97f032773360ec3b_Out_0 = _WindSpeed;
            float2 _Multiply_680225c15a6a168faad1cd812bfac140_Out_2;
            Unity_Multiply_float(_Normalize_209ccab159865f8193f95c1c55f63016_Out_1, (_Property_2c1632165185328c97f032773360ec3b_Out_0.xx), _Multiply_680225c15a6a168faad1cd812bfac140_Out_2);
            float2 _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2;
            Unity_Multiply_float(_Multiply_680225c15a6a168faad1cd812bfac140_Out_2, (IN.TimeParameters.x.xx), _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2);
            float2 _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2;
            Unity_Add_float2(_Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0, _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2, _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2);
            float _SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2;
            Unity_SimpleNoise_float(_Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2, 2, _SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2);
            float _Property_03d42ffca7dcdc8a8c5caceff1356825_Out_0 = _WindStrenght;
            float _Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2;
            Unity_Multiply_float(_SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2, _Property_03d42ffca7dcdc8a8c5caceff1356825_Out_0, _Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2);
            float3 _Add_6071de5427ea908aacbf1265ad937975_Out_2;
            Unity_Add_float3((_Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2.xxx), IN.WorldSpacePosition, _Add_6071de5427ea908aacbf1265ad937975_Out_2);
            float3 _Transform_f5ad1147d9bdbe8d896e3761311f7116_Out_1 = TransformWorldToObject(_Add_6071de5427ea908aacbf1265ad937975_Out_2.xyz);
            description.Position = _Transform_f5ad1147d9bdbe8d896e3761311f7116_Out_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1 = IN.WorldSpacePosition[0];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_G_2 = IN.WorldSpacePosition[1];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3 = IN.WorldSpacePosition[2];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_A_4 = 0;
            float2 _Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0 = float2(_Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1, _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3);
            float2 _Property_f00371a39d318782a68a4b5266d8947d_Out_0 = _WindDirection;
            float2 _Normalize_209ccab159865f8193f95c1c55f63016_Out_1;
            Unity_Normalize_float2(_Property_f00371a39d318782a68a4b5266d8947d_Out_0, _Normalize_209ccab159865f8193f95c1c55f63016_Out_1);
            float _Property_2c1632165185328c97f032773360ec3b_Out_0 = _WindSpeed;
            float2 _Multiply_680225c15a6a168faad1cd812bfac140_Out_2;
            Unity_Multiply_float(_Normalize_209ccab159865f8193f95c1c55f63016_Out_1, (_Property_2c1632165185328c97f032773360ec3b_Out_0.xx), _Multiply_680225c15a6a168faad1cd812bfac140_Out_2);
            float2 _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2;
            Unity_Multiply_float(_Multiply_680225c15a6a168faad1cd812bfac140_Out_2, (IN.TimeParameters.x.xx), _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2);
            float2 _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2;
            Unity_Add_float2(_Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0, _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2, _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2);
            float _SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2;
            Unity_SimpleNoise_float(_Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2, 8, _SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2);
            float _Property_331763d7c2737a8d902136d353fa866b_Out_0 = _WindSpeed;
            float _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2;
            Unity_Multiply_float(_SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2, _Property_331763d7c2737a8d902136d353fa866b_Out_0, _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2);
            float2 _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3;
            Unity_Rotate_Radians_float(IN.uv0.xy, float2 (0.5, 0.5), _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2, _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3);
            float4 _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0.tex, _Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0.samplerstate, _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3);
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_R_4 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.r;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_G_5 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.g;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_B_6 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.b;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_A_7 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.a;
            float _Property_d2a85d83b3a0138a98c436e73322f689_Out_0 = _AlphaCutoff;
            surface.Alpha = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_A_7;
            surface.AlphaClipThreshold = _Property_d2a85d83b3a0138a98c436e73322f689_Out_0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 3.0
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        //#pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Color;
        float _AlphaCutoff;
        float2 _WindDirection;
        float _WindSpeed;
        float _WindStrenght;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);

            // Graph Functions
            
        void Unity_Normalize_float2(float2 In, out float2 Out)
        {
            Out = normalize(In);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }

        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
        {
            //rotation matrix
            UV -= Center;
            float s = sin(Rotation);
            float c = cos(Rotation);

            //center rotation matrix
            float2x2 rMatrix = float2x2(c, -s, s, c);
            rMatrix *= 0.5;
            rMatrix += 0.5;
            rMatrix = rMatrix*2 - 1;

            //multiply the UVs by the rotation matrix
            UV.xy = mul(UV.xy, rMatrix);
            UV += Center;

            Out = UV;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1 = IN.WorldSpacePosition[0];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_G_2 = IN.WorldSpacePosition[1];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3 = IN.WorldSpacePosition[2];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_A_4 = 0;
            float2 _Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0 = float2(_Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1, _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3);
            float2 _Property_f00371a39d318782a68a4b5266d8947d_Out_0 = _WindDirection;
            float2 _Normalize_209ccab159865f8193f95c1c55f63016_Out_1;
            Unity_Normalize_float2(_Property_f00371a39d318782a68a4b5266d8947d_Out_0, _Normalize_209ccab159865f8193f95c1c55f63016_Out_1);
            float _Property_2c1632165185328c97f032773360ec3b_Out_0 = _WindSpeed;
            float2 _Multiply_680225c15a6a168faad1cd812bfac140_Out_2;
            Unity_Multiply_float(_Normalize_209ccab159865f8193f95c1c55f63016_Out_1, (_Property_2c1632165185328c97f032773360ec3b_Out_0.xx), _Multiply_680225c15a6a168faad1cd812bfac140_Out_2);
            float2 _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2;
            Unity_Multiply_float(_Multiply_680225c15a6a168faad1cd812bfac140_Out_2, (IN.TimeParameters.x.xx), _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2);
            float2 _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2;
            Unity_Add_float2(_Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0, _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2, _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2);
            float _SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2;
            Unity_SimpleNoise_float(_Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2, 2, _SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2);
            float _Property_03d42ffca7dcdc8a8c5caceff1356825_Out_0 = _WindStrenght;
            float _Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2;
            Unity_Multiply_float(_SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2, _Property_03d42ffca7dcdc8a8c5caceff1356825_Out_0, _Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2);
            float3 _Add_6071de5427ea908aacbf1265ad937975_Out_2;
            Unity_Add_float3((_Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2.xxx), IN.WorldSpacePosition, _Add_6071de5427ea908aacbf1265ad937975_Out_2);
            float3 _Transform_f5ad1147d9bdbe8d896e3761311f7116_Out_1 = TransformWorldToObject(_Add_6071de5427ea908aacbf1265ad937975_Out_2.xyz);
            description.Position = _Transform_f5ad1147d9bdbe8d896e3761311f7116_Out_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1 = IN.WorldSpacePosition[0];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_G_2 = IN.WorldSpacePosition[1];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3 = IN.WorldSpacePosition[2];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_A_4 = 0;
            float2 _Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0 = float2(_Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1, _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3);
            float2 _Property_f00371a39d318782a68a4b5266d8947d_Out_0 = _WindDirection;
            float2 _Normalize_209ccab159865f8193f95c1c55f63016_Out_1;
            Unity_Normalize_float2(_Property_f00371a39d318782a68a4b5266d8947d_Out_0, _Normalize_209ccab159865f8193f95c1c55f63016_Out_1);
            float _Property_2c1632165185328c97f032773360ec3b_Out_0 = _WindSpeed;
            float2 _Multiply_680225c15a6a168faad1cd812bfac140_Out_2;
            Unity_Multiply_float(_Normalize_209ccab159865f8193f95c1c55f63016_Out_1, (_Property_2c1632165185328c97f032773360ec3b_Out_0.xx), _Multiply_680225c15a6a168faad1cd812bfac140_Out_2);
            float2 _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2;
            Unity_Multiply_float(_Multiply_680225c15a6a168faad1cd812bfac140_Out_2, (IN.TimeParameters.x.xx), _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2);
            float2 _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2;
            Unity_Add_float2(_Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0, _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2, _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2);
            float _SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2;
            Unity_SimpleNoise_float(_Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2, 8, _SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2);
            float _Property_331763d7c2737a8d902136d353fa866b_Out_0 = _WindSpeed;
            float _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2;
            Unity_Multiply_float(_SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2, _Property_331763d7c2737a8d902136d353fa866b_Out_0, _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2);
            float2 _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3;
            Unity_Rotate_Radians_float(IN.uv0.xy, float2 (0.5, 0.5), _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2, _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3);
            float4 _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0.tex, _Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0.samplerstate, _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3);
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_R_4 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.r;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_G_5 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.g;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_B_6 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.b;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_A_7 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.a;
            float _Property_d2a85d83b3a0138a98c436e73322f689_Out_0 = _AlphaCutoff;
            surface.Alpha = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_A_7;
            surface.AlphaClipThreshold = _Property_d2a85d83b3a0138a98c436e73322f689_Out_0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 3.0
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        //#pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Color;
        float _AlphaCutoff;
        float2 _WindDirection;
        float _WindSpeed;
        float _WindStrenght;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);

            // Graph Functions
            
        void Unity_Normalize_float2(float2 In, out float2 Out)
        {
            Out = normalize(In);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }

        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
        {
            //rotation matrix
            UV -= Center;
            float s = sin(Rotation);
            float c = cos(Rotation);

            //center rotation matrix
            float2x2 rMatrix = float2x2(c, -s, s, c);
            rMatrix *= 0.5;
            rMatrix += 0.5;
            rMatrix = rMatrix*2 - 1;

            //multiply the UVs by the rotation matrix
            UV.xy = mul(UV.xy, rMatrix);
            UV += Center;

            Out = UV;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1 = IN.WorldSpacePosition[0];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_G_2 = IN.WorldSpacePosition[1];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3 = IN.WorldSpacePosition[2];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_A_4 = 0;
            float2 _Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0 = float2(_Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1, _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3);
            float2 _Property_f00371a39d318782a68a4b5266d8947d_Out_0 = _WindDirection;
            float2 _Normalize_209ccab159865f8193f95c1c55f63016_Out_1;
            Unity_Normalize_float2(_Property_f00371a39d318782a68a4b5266d8947d_Out_0, _Normalize_209ccab159865f8193f95c1c55f63016_Out_1);
            float _Property_2c1632165185328c97f032773360ec3b_Out_0 = _WindSpeed;
            float2 _Multiply_680225c15a6a168faad1cd812bfac140_Out_2;
            Unity_Multiply_float(_Normalize_209ccab159865f8193f95c1c55f63016_Out_1, (_Property_2c1632165185328c97f032773360ec3b_Out_0.xx), _Multiply_680225c15a6a168faad1cd812bfac140_Out_2);
            float2 _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2;
            Unity_Multiply_float(_Multiply_680225c15a6a168faad1cd812bfac140_Out_2, (IN.TimeParameters.x.xx), _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2);
            float2 _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2;
            Unity_Add_float2(_Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0, _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2, _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2);
            float _SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2;
            Unity_SimpleNoise_float(_Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2, 2, _SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2);
            float _Property_03d42ffca7dcdc8a8c5caceff1356825_Out_0 = _WindStrenght;
            float _Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2;
            Unity_Multiply_float(_SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2, _Property_03d42ffca7dcdc8a8c5caceff1356825_Out_0, _Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2);
            float3 _Add_6071de5427ea908aacbf1265ad937975_Out_2;
            Unity_Add_float3((_Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2.xxx), IN.WorldSpacePosition, _Add_6071de5427ea908aacbf1265ad937975_Out_2);
            float3 _Transform_f5ad1147d9bdbe8d896e3761311f7116_Out_1 = TransformWorldToObject(_Add_6071de5427ea908aacbf1265ad937975_Out_2.xyz);
            description.Position = _Transform_f5ad1147d9bdbe8d896e3761311f7116_Out_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1 = IN.WorldSpacePosition[0];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_G_2 = IN.WorldSpacePosition[1];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3 = IN.WorldSpacePosition[2];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_A_4 = 0;
            float2 _Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0 = float2(_Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1, _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3);
            float2 _Property_f00371a39d318782a68a4b5266d8947d_Out_0 = _WindDirection;
            float2 _Normalize_209ccab159865f8193f95c1c55f63016_Out_1;
            Unity_Normalize_float2(_Property_f00371a39d318782a68a4b5266d8947d_Out_0, _Normalize_209ccab159865f8193f95c1c55f63016_Out_1);
            float _Property_2c1632165185328c97f032773360ec3b_Out_0 = _WindSpeed;
            float2 _Multiply_680225c15a6a168faad1cd812bfac140_Out_2;
            Unity_Multiply_float(_Normalize_209ccab159865f8193f95c1c55f63016_Out_1, (_Property_2c1632165185328c97f032773360ec3b_Out_0.xx), _Multiply_680225c15a6a168faad1cd812bfac140_Out_2);
            float2 _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2;
            Unity_Multiply_float(_Multiply_680225c15a6a168faad1cd812bfac140_Out_2, (IN.TimeParameters.x.xx), _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2);
            float2 _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2;
            Unity_Add_float2(_Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0, _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2, _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2);
            float _SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2;
            Unity_SimpleNoise_float(_Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2, 8, _SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2);
            float _Property_331763d7c2737a8d902136d353fa866b_Out_0 = _WindSpeed;
            float _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2;
            Unity_Multiply_float(_SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2, _Property_331763d7c2737a8d902136d353fa866b_Out_0, _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2);
            float2 _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3;
            Unity_Rotate_Radians_float(IN.uv0.xy, float2 (0.5, 0.5), _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2, _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3);
            float4 _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0.tex, _Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0.samplerstate, _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3);
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_R_4 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.r;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_G_5 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.g;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_B_6 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.b;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_A_7 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.a;
            float _Property_d2a85d83b3a0138a98c436e73322f689_Out_0 = _AlphaCutoff;
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_A_7;
            surface.AlphaClipThreshold = _Property_d2a85d83b3a0138a98c436e73322f689_Out_0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 3.0
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _AlphaClip 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 _MainTexture_TexelSize;
        float4 _Color;
        float _AlphaCutoff;
        float2 _WindDirection;
        float _WindSpeed;
        float _WindStrenght;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTexture);
        SAMPLER(sampler_MainTexture);

            // Graph Functions
            
        void Unity_Normalize_float2(float2 In, out float2 Out)
        {
            Out = normalize(In);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }


        inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
        }

        inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
        {
            return (1.0-t)*a + (t*b);
        }


        inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
        {
            float2 i = floor(uv);
            float2 f = frac(uv);
            f = f * f * (3.0 - 2.0 * f);

            uv = abs(frac(uv) - 0.5);
            float2 c0 = i + float2(0.0, 0.0);
            float2 c1 = i + float2(1.0, 0.0);
            float2 c2 = i + float2(0.0, 1.0);
            float2 c3 = i + float2(1.0, 1.0);
            float r0 = Unity_SimpleNoise_RandomValue_float(c0);
            float r1 = Unity_SimpleNoise_RandomValue_float(c1);
            float r2 = Unity_SimpleNoise_RandomValue_float(c2);
            float r3 = Unity_SimpleNoise_RandomValue_float(c3);

            float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
            float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
            float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
            return t;
        }
        void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
        {
            float t = 0.0;

            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3-0));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3-1));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3-2));
            t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

            Out = t;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
        {
            //rotation matrix
            UV -= Center;
            float s = sin(Rotation);
            float c = cos(Rotation);

            //center rotation matrix
            float2x2 rMatrix = float2x2(c, -s, s, c);
            rMatrix *= 0.5;
            rMatrix += 0.5;
            rMatrix = rMatrix*2 - 1;

            //multiply the UVs by the rotation matrix
            UV.xy = mul(UV.xy, rMatrix);
            UV += Center;

            Out = UV;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1 = IN.WorldSpacePosition[0];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_G_2 = IN.WorldSpacePosition[1];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3 = IN.WorldSpacePosition[2];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_A_4 = 0;
            float2 _Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0 = float2(_Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1, _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3);
            float2 _Property_f00371a39d318782a68a4b5266d8947d_Out_0 = _WindDirection;
            float2 _Normalize_209ccab159865f8193f95c1c55f63016_Out_1;
            Unity_Normalize_float2(_Property_f00371a39d318782a68a4b5266d8947d_Out_0, _Normalize_209ccab159865f8193f95c1c55f63016_Out_1);
            float _Property_2c1632165185328c97f032773360ec3b_Out_0 = _WindSpeed;
            float2 _Multiply_680225c15a6a168faad1cd812bfac140_Out_2;
            Unity_Multiply_float(_Normalize_209ccab159865f8193f95c1c55f63016_Out_1, (_Property_2c1632165185328c97f032773360ec3b_Out_0.xx), _Multiply_680225c15a6a168faad1cd812bfac140_Out_2);
            float2 _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2;
            Unity_Multiply_float(_Multiply_680225c15a6a168faad1cd812bfac140_Out_2, (IN.TimeParameters.x.xx), _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2);
            float2 _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2;
            Unity_Add_float2(_Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0, _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2, _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2);
            float _SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2;
            Unity_SimpleNoise_float(_Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2, 2, _SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2);
            float _Property_03d42ffca7dcdc8a8c5caceff1356825_Out_0 = _WindStrenght;
            float _Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2;
            Unity_Multiply_float(_SimpleNoise_9a7a9051d62dbf8aab30ed9344bdc88c_Out_2, _Property_03d42ffca7dcdc8a8c5caceff1356825_Out_0, _Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2);
            float3 _Add_6071de5427ea908aacbf1265ad937975_Out_2;
            Unity_Add_float3((_Multiply_db6089e4f5c2cd8fa426723b30942736_Out_2.xxx), IN.WorldSpacePosition, _Add_6071de5427ea908aacbf1265ad937975_Out_2);
            float3 _Transform_f5ad1147d9bdbe8d896e3761311f7116_Out_1 = TransformWorldToObject(_Add_6071de5427ea908aacbf1265ad937975_Out_2.xyz);
            description.Position = _Transform_f5ad1147d9bdbe8d896e3761311f7116_Out_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_e5eaacad97a32788b000ece3d1e082f4_Out_0 = _Color;
            UnityTexture2D _Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0 = UnityBuildTexture2DStructNoScale(_MainTexture);
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1 = IN.WorldSpacePosition[0];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_G_2 = IN.WorldSpacePosition[1];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3 = IN.WorldSpacePosition[2];
            float _Split_c6b61f59bcfebd879181f4c8ec560ce6_A_4 = 0;
            float2 _Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0 = float2(_Split_c6b61f59bcfebd879181f4c8ec560ce6_R_1, _Split_c6b61f59bcfebd879181f4c8ec560ce6_B_3);
            float2 _Property_f00371a39d318782a68a4b5266d8947d_Out_0 = _WindDirection;
            float2 _Normalize_209ccab159865f8193f95c1c55f63016_Out_1;
            Unity_Normalize_float2(_Property_f00371a39d318782a68a4b5266d8947d_Out_0, _Normalize_209ccab159865f8193f95c1c55f63016_Out_1);
            float _Property_2c1632165185328c97f032773360ec3b_Out_0 = _WindSpeed;
            float2 _Multiply_680225c15a6a168faad1cd812bfac140_Out_2;
            Unity_Multiply_float(_Normalize_209ccab159865f8193f95c1c55f63016_Out_1, (_Property_2c1632165185328c97f032773360ec3b_Out_0.xx), _Multiply_680225c15a6a168faad1cd812bfac140_Out_2);
            float2 _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2;
            Unity_Multiply_float(_Multiply_680225c15a6a168faad1cd812bfac140_Out_2, (IN.TimeParameters.x.xx), _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2);
            float2 _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2;
            Unity_Add_float2(_Vector2_f817e12dfd2f418ead39f3c3c240e304_Out_0, _Multiply_a849cc85dc9a14858eaee66976f2ed14_Out_2, _Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2);
            float _SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2;
            Unity_SimpleNoise_float(_Add_6354cb4755785c859d5fd16b4b6c7d84_Out_2, 8, _SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2);
            float _Property_331763d7c2737a8d902136d353fa866b_Out_0 = _WindSpeed;
            float _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2;
            Unity_Multiply_float(_SimpleNoise_b06fb7cee34e0983a5c75af894c1ecf5_Out_2, _Property_331763d7c2737a8d902136d353fa866b_Out_0, _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2);
            float2 _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3;
            Unity_Rotate_Radians_float(IN.uv0.xy, float2 (0.5, 0.5), _Multiply_6302cd032a9fab859be8621ff2642cd1_Out_2, _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3);
            float4 _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0.tex, _Property_4ce3520ebd5e078994429574e8ca5ebd_Out_0.samplerstate, _Rotate_6be3dcfe610841859eb5a12c13cd140c_Out_3);
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_R_4 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.r;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_G_5 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.g;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_B_6 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.b;
            float _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_A_7 = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0.a;
            float4 _Multiply_2a67d02edb8b7c8aa44dc72735ece644_Out_2;
            Unity_Multiply_float(_Property_e5eaacad97a32788b000ece3d1e082f4_Out_0, _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_RGBA_0, _Multiply_2a67d02edb8b7c8aa44dc72735ece644_Out_2);
            float _Property_d2a85d83b3a0138a98c436e73322f689_Out_0 = _AlphaCutoff;
            surface.BaseColor = (_Multiply_2a67d02edb8b7c8aa44dc72735ece644_Out_2.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _SampleTexture2D_028c0c58cd136a86b5cbf241262f2148_A_7;
            surface.AlphaClipThreshold = _Property_d2a85d83b3a0138a98c436e73322f689_Out_0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "ShaderGraph.PBRMasterGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}
