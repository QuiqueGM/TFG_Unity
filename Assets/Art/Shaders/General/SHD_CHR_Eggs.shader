Shader "DragonCity2/Generic Egg"
{
    Properties
    {
        [NoScaleOffset]_MainTex("Albedo (RGB) Smoothness (A)", 2D) = "white" {}
        [NoScaleOffset]_NormalMap("Normal Map", 2D) = "bump" {}
        [ToggleUI]_UseEmission("Emission", Float) = 0
        [ToggleUI]_UseMetallic("Metallic", Float) = 0
        [NoScaleOffset]_EmissiveMetallicMap("Emission + Metallic", 2D) = "white" {}
        [HDR]_EmissionColor("Emission Color", Color) = (0, 0, 0, 0)
        [ToggleUI]_UseFresnel("Use Fresnel", Float) = 0
        [HDR]_FresnelColor("Fresnel Color", Color) = (1, 1, 1, 0)
        _FresnelPower("Fresnel Power", Range(-1, 1)) = 0
        _FresnelIntensity("Fresnel Intensity", Range(-1, 1)) = 0
        _ExtraTintColor("Extra Tint Color", Color) = (1, 1, 1, 1)
        _ExtraTintColorMultiplier("Extra Tint Color Multiplier", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="Geometry"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Back
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
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        //#pragma multi_compile _ _SHADOWS_SOFT
            // GraphKeywords: <None>

            // Defines
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
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
            float4 color : COLOR;
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
            float4 color;
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
            float3 WorldSpaceNormal;
            float3 TangentSpaceNormal;
            float3 WorldSpaceViewDirection;
            float4 uv0;
            float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float4 interp4 : TEXCOORD4;
            float3 interp5 : TEXCOORD5;
            #if defined(LIGHTMAP_ON)
            float2 interp6 : TEXCOORD6;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp7 : TEXCOORD7;
            #endif
            float4 interp8 : TEXCOORD8;
            float4 interp9 : TEXCOORD9;
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
            output.interp4.xyzw =  input.color;
            output.interp5.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp6.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz =  input.sh;
            #endif
            output.interp8.xyzw =  input.fogFactorAndVertexLight;
            output.interp9.xyzw =  input.shadowCoord;
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
            output.color = input.interp4.xyzw;
            output.viewDirectionWS = input.interp5.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            output.shadowCoord = input.interp9.xyzw;
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
        float4 _MainTex_TexelSize;
        float4 _NormalMap_TexelSize;
        half _UseEmission;
        half _UseMetallic;
        float4 _EmissiveMetallicMap_TexelSize;
        half4 _EmissionColor;
        half _UseFresnel;
        half4 _FresnelColor;
        half _FresnelPower;
        half _FresnelIntensity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_EmissiveMetallicMap);
        SAMPLER(sampler_EmissiveMetallicMap);
        half4 _ExtraTintColor;
        half _ExtraTintColorMultiplier;

            // Graph Functions

        void Unity_Add_float(half A, half B, out half Out)
        {
            Out = A + B;
        }

        void Unity_Absolute_float(half In, out half Out)
        {
            Out = abs(In);
        }

        void Unity_Power_float(half A, half B, out half Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(half A, half B, out half Out)
        {
            Out = A * B;
        }

        void Unity_FresnelEffect_float(half3 Normal, half3 ViewDir, half Power, out half Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Branch_float4(half Predicate, half4 True, half4 False, out half4 Out)
        {
            Out = Predicate ? True : False;
        }

        struct Bindings_SGFresnel_7e6160c35a63ef34a922355032c45814
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
        };

        void SG_SGFresnel_7e6160c35a63ef34a922355032c45814(float Boolean_30747C25, float4 Color_9F29EFCD, float Vector1_3C7524C4, float Vector1_74197E61, Bindings_SGFresnel_7e6160c35a63ef34a922355032c45814 IN, out float4 OutVector4_1)
        {
            float _Property_2809b3725785408c9b209c2f393adbfe_Out_0 = Boolean_30747C25;
            float _Property_375d6da72c208186b6051f95dc8dfe19_Out_0 = Vector1_74197E61;
            float _Add_83f5e08bf068c48d934c4b77fffc923f_Out_2;
            Unity_Add_float(_Property_375d6da72c208186b6051f95dc8dfe19_Out_0, 1, _Add_83f5e08bf068c48d934c4b77fffc923f_Out_2);
            float _Absolute_f22a13df5318c584bd91eb939b680f75_Out_1;
            Unity_Absolute_float(_Add_83f5e08bf068c48d934c4b77fffc923f_Out_2, _Absolute_f22a13df5318c584bd91eb939b680f75_Out_1);
            float _Power_64af6442a01454829e1bc876ed24082d_Out_2;
            Unity_Power_float(_Absolute_f22a13df5318c584bd91eb939b680f75_Out_1, 10, _Power_64af6442a01454829e1bc876ed24082d_Out_2);
            float4 _Property_eeb18107bd8d1d8ebb1f18b8017a57e0_Out_0 = Color_9F29EFCD;
            float4 _Multiply_75e09c235c25948090ea4d8278ef8128_Out_2;
            Unity_Multiply_float((_Power_64af6442a01454829e1bc876ed24082d_Out_2.xxxx), _Property_eeb18107bd8d1d8ebb1f18b8017a57e0_Out_0, _Multiply_75e09c235c25948090ea4d8278ef8128_Out_2);
            float _Property_13a729f7c7c92b8d8d28a87ab57268ff_Out_0 = Vector1_3C7524C4;
            float _Add_d82201bd9d0b6988bae88f9be0af636a_Out_2;
            Unity_Add_float(_Property_13a729f7c7c92b8d8d28a87ab57268ff_Out_0, 1, _Add_d82201bd9d0b6988bae88f9be0af636a_Out_2);
            float _Multiply_f85ae4a372a4c682939795a92e796fa9_Out_2;
            Unity_Multiply_float(_Add_d82201bd9d0b6988bae88f9be0af636a_Out_2, 0.5, _Multiply_f85ae4a372a4c682939795a92e796fa9_Out_2);
            float _Power_b829bc935b090b8b8d01421079dbec58_Out_2;
            Unity_Power_float(10, _Multiply_f85ae4a372a4c682939795a92e796fa9_Out_2, _Power_b829bc935b090b8b8d01421079dbec58_Out_2);
            float _FresnelEffect_14488595fead3e8e83fb92850e7317d6_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Power_b829bc935b090b8b8d01421079dbec58_Out_2, _FresnelEffect_14488595fead3e8e83fb92850e7317d6_Out_3);
            float4 _Multiply_1242e07ae96a0986be2465dd335ea3ce_Out_2;
            Unity_Multiply_float(_Property_eeb18107bd8d1d8ebb1f18b8017a57e0_Out_0, (_FresnelEffect_14488595fead3e8e83fb92850e7317d6_Out_3.xxxx), _Multiply_1242e07ae96a0986be2465dd335ea3ce_Out_2);
            float4 _Multiply_c04d39982eed868d85bfb6d91eb9c90c_Out_2;
            Unity_Multiply_float(_Multiply_75e09c235c25948090ea4d8278ef8128_Out_2, _Multiply_1242e07ae96a0986be2465dd335ea3ce_Out_2, _Multiply_c04d39982eed868d85bfb6d91eb9c90c_Out_2);
            float4 _Branch_26b3208110eff88aa733fd6d76443174_Out_3;
            Unity_Branch_float4(_Property_2809b3725785408c9b209c2f393adbfe_Out_0, _Multiply_c04d39982eed868d85bfb6d91eb9c90c_Out_2, float4(0, 0, 0, 0), _Branch_26b3208110eff88aa733fd6d76443174_Out_3);
            OutVector4_1 = _Branch_26b3208110eff88aa733fd6d76443174_Out_3;
        }

        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_half(half2 UV, half2 Tiling, half2 Offset, out half2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Lerp_half4(half4 A, half4 B, half4 T, out half4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Add_half4(half4 A, half4 B, out half4 Out)
        {
            Out = A + B;
        }

        void Unity_Preview_half4(half4 In, out half4 Out)
        {
            Out = In;
        }

        void Unity_Branch_half4(half Predicate, half4 True, half4 False, out half4 Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Preview_half(half In, out half Out)
        {
            Out = In;
        }

        void Unity_InvertColors_half(half In, half InvertColors, out half Out)
        {
            Out = abs(InvertColors - In);
        }

        void Unity_Branch_half(half Predicate, half True, half False, out half Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            half3 Position;
            half3 Normal;
            half3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            half3 BaseColor;
            half3 NormalTS;
            half3 Emission;
            half Metallic;
            half Smoothness;
            half Occlusion;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_R_1 = IN.VertexColor[0];
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_G_2 = IN.VertexColor[1];
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_B_3 = IN.VertexColor[2];
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_A_4 = IN.VertexColor[3];
            half _Property_87f4585dc8d54b05a0f25e8f107eef53_Out_0 = _UseFresnel;
            half4 _Property_1dac7c791a734e8fb2be234bcdd44337_Out_0 = IsGammaSpace() ? LinearToSRGB(_FresnelColor) : _FresnelColor;
            half _Property_a251014b95cc4e7db4743e47f6e8e93d_Out_0 = _FresnelPower;
            half _Property_5ec5aecdbf354f7585529f0672a64b78_Out_0 = _FresnelIntensity;
            Bindings_SGFresnel_7e6160c35a63ef34a922355032c45814 _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb;
            _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb.WorldSpaceNormal = IN.WorldSpaceNormal;
            _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            float4 _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb_OutVector4_1;
            SG_SGFresnel_7e6160c35a63ef34a922355032c45814(_Property_87f4585dc8d54b05a0f25e8f107eef53_Out_0, _Property_1dac7c791a734e8fb2be234bcdd44337_Out_0, _Property_a251014b95cc4e7db4743e47f6e8e93d_Out_0, _Property_5ec5aecdbf354f7585529f0672a64b78_Out_0, _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb, _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb_OutVector4_1);
            half4 _Multiply_6403337995204d2abcbf761062ce966e_Out_2;
            Unity_Multiply_half((_Split_ba230f5013744bfc8f8620b0f3cd990d_R_1.xxxx), _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb_OutVector4_1, _Multiply_6403337995204d2abcbf761062ce966e_Out_2);
            UnityTexture2D _Property_e7a99399bafa0587ba2e7079a5f728a1_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            half4 _UV_bfbe2619257a2686b08dc866af6ca964_Out_0 = IN.uv0;
            half2 _Vector2_c024e53e7d93da8a9574f74d5bf3f82f_Out_0 = half2(1, 1);
            half2 _Vector2_3c1621063ea091898c7642481de4a887_Out_0 = half2(0, 0);
            half2 _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3;
            Unity_TilingAndOffset_half((_UV_bfbe2619257a2686b08dc866af6ca964_Out_0.xy), _Vector2_c024e53e7d93da8a9574f74d5bf3f82f_Out_0, _Vector2_3c1621063ea091898c7642481de4a887_Out_0, _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3);
            half4 _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e7a99399bafa0587ba2e7079a5f728a1_Out_0.tex, _Property_e7a99399bafa0587ba2e7079a5f728a1_Out_0.samplerstate, _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3);
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_R_4 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.r;
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_G_5 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.g;
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_B_6 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.b;
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_A_7 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.a;
            half4 _Property_d1ce3ca7b148b78b9f5ccb04071f99e8_Out_0 = _ExtraTintColor;
            half _Property_960135caf923da82aa3565beb428b1af_Out_0 = _ExtraTintColorMultiplier;
            half4 _Lerp_efe9cdb25609028d801ea5aef49f1f50_Out_3;
            Unity_Lerp_half4(_SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0, _Property_d1ce3ca7b148b78b9f5ccb04071f99e8_Out_0, (_Property_960135caf923da82aa3565beb428b1af_Out_0.xxxx), _Lerp_efe9cdb25609028d801ea5aef49f1f50_Out_3);
            half4 _Add_4ccb3017631f4894b58f5b76aa0f4b2e_Out_2;
            Unity_Add_half4(_Multiply_6403337995204d2abcbf761062ce966e_Out_2, _Lerp_efe9cdb25609028d801ea5aef49f1f50_Out_3, _Add_4ccb3017631f4894b58f5b76aa0f4b2e_Out_2);
            UnityTexture2D _Property_83408f73f894c685bf6153270087b8de_Out_0 = UnityBuildTexture2DStructNoScale(_NormalMap);
            half4 _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_83408f73f894c685bf6153270087b8de_Out_0.tex, _Property_83408f73f894c685bf6153270087b8de_Out_0.samplerstate, _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3);
            _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0);
            half _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_R_4 = _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0.r;
            half _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_G_5 = _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0.g;
            half _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_B_6 = _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0.b;
            half _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_A_7 = _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0.a;
            half4 _Preview_03a1fc616cdfbe8486bff19a80f303ef_Out_1;
            Unity_Preview_half4(_SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0, _Preview_03a1fc616cdfbe8486bff19a80f303ef_Out_1);
            half _Property_20d3b24d820d0088ad2a145930e4a35c_Out_0 = _UseEmission;
            UnityTexture2D _Property_4d7844d686e0f983b887497a853eb5e1_Out_0 = UnityBuildTexture2DStructNoScale(_EmissiveMetallicMap);
            half4 _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4d7844d686e0f983b887497a853eb5e1_Out_0.tex, _Property_4d7844d686e0f983b887497a853eb5e1_Out_0.samplerstate, _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3);
            half _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_R_4 = _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0.r;
            half _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_G_5 = _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0.g;
            half _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_B_6 = _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0.b;
            half _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_A_7 = _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0.a;
            half4 _Branch_47381574f58f6c8681d309ea31449593_Out_3;
            Unity_Branch_half4(_Property_20d3b24d820d0088ad2a145930e4a35c_Out_0, _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0, half4(0, 0, 0, 0), _Branch_47381574f58f6c8681d309ea31449593_Out_3);
            half4 _Property_37720cf7049ae08289f4ae8b53085aaf_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            half4 _Multiply_8e3164fb1efdbb8ab6fad98c47359f3b_Out_2;
            Unity_Multiply_half(_Branch_47381574f58f6c8681d309ea31449593_Out_3, _Property_37720cf7049ae08289f4ae8b53085aaf_Out_0, _Multiply_8e3164fb1efdbb8ab6fad98c47359f3b_Out_2);
            half4 _Preview_303732097ce2c18cb43acfb058702795_Out_1;
            Unity_Preview_half4(_Multiply_8e3164fb1efdbb8ab6fad98c47359f3b_Out_2, _Preview_303732097ce2c18cb43acfb058702795_Out_1);
            half _Preview_540b725491637b82826b30d365b34860_Out_1;
            Unity_Preview_half(_SampleTexture2D_3d211e837b7d078bb23247c37ff80245_A_7, _Preview_540b725491637b82826b30d365b34860_Out_1);
            half _InvertColors_30aaf0081e3f038e8aa39e99807d617c_Out_1;
            half _InvertColors_30aaf0081e3f038e8aa39e99807d617c_InvertColors = half (1
        );    Unity_InvertColors_half(_Preview_540b725491637b82826b30d365b34860_Out_1, _InvertColors_30aaf0081e3f038e8aa39e99807d617c_InvertColors, _InvertColors_30aaf0081e3f038e8aa39e99807d617c_Out_1);
            half _Property_ba3b39acfe478f8b921fb54e436abcc8_Out_0 = _UseMetallic;
            half _Property_b0accd90b3492f8db55aa30a01180e22_Out_0 = _UseEmission;
            half _Branch_088d1cf29808a780b1935e7e9c72caa2_Out_3;
            Unity_Branch_half(_Property_b0accd90b3492f8db55aa30a01180e22_Out_0, _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_A_7, _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_R_4, _Branch_088d1cf29808a780b1935e7e9c72caa2_Out_3);
            half _Branch_27f5358f38bba587ac947708a94b7e07_Out_3;
            Unity_Branch_half(_Property_ba3b39acfe478f8b921fb54e436abcc8_Out_0, _Branch_088d1cf29808a780b1935e7e9c72caa2_Out_3, 0, _Branch_27f5358f38bba587ac947708a94b7e07_Out_3);
            half _Multiply_6ed6500d70e56d82a083c76a08d89c27_Out_2;
            Unity_Multiply_half(_InvertColors_30aaf0081e3f038e8aa39e99807d617c_Out_1, _Branch_27f5358f38bba587ac947708a94b7e07_Out_3, _Multiply_6ed6500d70e56d82a083c76a08d89c27_Out_2);
            surface.BaseColor = (_Add_4ccb3017631f4894b58f5b76aa0f4b2e_Out_2.xyz);
            surface.NormalTS = (_Preview_03a1fc616cdfbe8486bff19a80f303ef_Out_1.xyz);
            surface.Emission = (_Preview_303732097ce2c18cb43acfb058702795_Out_1.xyz);
            surface.Metallic = _Multiply_6ed6500d70e56d82a083c76a08d89c27_Out_2;
            surface.Smoothness = _Preview_540b725491637b82826b30d365b34860_Out_1;
            surface.Occlusion = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.uv0 =                         input.texCoord0;
            output.VertexColor =                 input.color;
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
            Cull Back
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
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        //#pragma multi_compile _ _SHADOWS_SOFT
        //#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
            // GraphKeywords: <None>

            // Defines
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
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
            float4 color : COLOR;
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
            float4 color;
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
            float3 WorldSpaceNormal;
            float3 TangentSpaceNormal;
            float3 WorldSpaceViewDirection;
            float4 uv0;
            float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float4 interp4 : TEXCOORD4;
            float3 interp5 : TEXCOORD5;
            #if defined(LIGHTMAP_ON)
            float2 interp6 : TEXCOORD6;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp7 : TEXCOORD7;
            #endif
            float4 interp8 : TEXCOORD8;
            float4 interp9 : TEXCOORD9;
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
            output.interp4.xyzw =  input.color;
            output.interp5.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp6.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp7.xyz =  input.sh;
            #endif
            output.interp8.xyzw =  input.fogFactorAndVertexLight;
            output.interp9.xyzw =  input.shadowCoord;
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
            output.color = input.interp4.xyzw;
            output.viewDirectionWS = input.interp5.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp6.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp7.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp8.xyzw;
            output.shadowCoord = input.interp9.xyzw;
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
        float4 _MainTex_TexelSize;
        float4 _NormalMap_TexelSize;
        half _UseEmission;
        half _UseMetallic;
        float4 _EmissiveMetallicMap_TexelSize;
        half4 _EmissionColor;
        half _UseFresnel;
        half4 _FresnelColor;
        half _FresnelPower;
        half _FresnelIntensity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_EmissiveMetallicMap);
        SAMPLER(sampler_EmissiveMetallicMap);
        half4 _ExtraTintColor;
        half _ExtraTintColorMultiplier;

            // Graph Functions

        void Unity_Add_float(half A, half B, out half Out)
        {
            Out = A + B;
        }

        void Unity_Absolute_float(half In, out half Out)
        {
            Out = abs(In);
        }

        void Unity_Power_float(half A, half B, out half Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(half A, half B, out half Out)
        {
            Out = A * B;
        }

        void Unity_FresnelEffect_float(half3 Normal, half3 ViewDir, half Power, out half Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Branch_float4(half Predicate, half4 True, half4 False, out half4 Out)
        {
            Out = Predicate ? True : False;
        }

        struct Bindings_SGFresnel_7e6160c35a63ef34a922355032c45814
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
        };

        void SG_SGFresnel_7e6160c35a63ef34a922355032c45814(float Boolean_30747C25, float4 Color_9F29EFCD, float Vector1_3C7524C4, float Vector1_74197E61, Bindings_SGFresnel_7e6160c35a63ef34a922355032c45814 IN, out float4 OutVector4_1)
        {
            float _Property_2809b3725785408c9b209c2f393adbfe_Out_0 = Boolean_30747C25;
            float _Property_375d6da72c208186b6051f95dc8dfe19_Out_0 = Vector1_74197E61;
            float _Add_83f5e08bf068c48d934c4b77fffc923f_Out_2;
            Unity_Add_float(_Property_375d6da72c208186b6051f95dc8dfe19_Out_0, 1, _Add_83f5e08bf068c48d934c4b77fffc923f_Out_2);
            float _Absolute_f22a13df5318c584bd91eb939b680f75_Out_1;
            Unity_Absolute_float(_Add_83f5e08bf068c48d934c4b77fffc923f_Out_2, _Absolute_f22a13df5318c584bd91eb939b680f75_Out_1);
            float _Power_64af6442a01454829e1bc876ed24082d_Out_2;
            Unity_Power_float(_Absolute_f22a13df5318c584bd91eb939b680f75_Out_1, 10, _Power_64af6442a01454829e1bc876ed24082d_Out_2);
            float4 _Property_eeb18107bd8d1d8ebb1f18b8017a57e0_Out_0 = Color_9F29EFCD;
            float4 _Multiply_75e09c235c25948090ea4d8278ef8128_Out_2;
            Unity_Multiply_float((_Power_64af6442a01454829e1bc876ed24082d_Out_2.xxxx), _Property_eeb18107bd8d1d8ebb1f18b8017a57e0_Out_0, _Multiply_75e09c235c25948090ea4d8278ef8128_Out_2);
            float _Property_13a729f7c7c92b8d8d28a87ab57268ff_Out_0 = Vector1_3C7524C4;
            float _Add_d82201bd9d0b6988bae88f9be0af636a_Out_2;
            Unity_Add_float(_Property_13a729f7c7c92b8d8d28a87ab57268ff_Out_0, 1, _Add_d82201bd9d0b6988bae88f9be0af636a_Out_2);
            float _Multiply_f85ae4a372a4c682939795a92e796fa9_Out_2;
            Unity_Multiply_float(_Add_d82201bd9d0b6988bae88f9be0af636a_Out_2, 0.5, _Multiply_f85ae4a372a4c682939795a92e796fa9_Out_2);
            float _Power_b829bc935b090b8b8d01421079dbec58_Out_2;
            Unity_Power_float(10, _Multiply_f85ae4a372a4c682939795a92e796fa9_Out_2, _Power_b829bc935b090b8b8d01421079dbec58_Out_2);
            float _FresnelEffect_14488595fead3e8e83fb92850e7317d6_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Power_b829bc935b090b8b8d01421079dbec58_Out_2, _FresnelEffect_14488595fead3e8e83fb92850e7317d6_Out_3);
            float4 _Multiply_1242e07ae96a0986be2465dd335ea3ce_Out_2;
            Unity_Multiply_float(_Property_eeb18107bd8d1d8ebb1f18b8017a57e0_Out_0, (_FresnelEffect_14488595fead3e8e83fb92850e7317d6_Out_3.xxxx), _Multiply_1242e07ae96a0986be2465dd335ea3ce_Out_2);
            float4 _Multiply_c04d39982eed868d85bfb6d91eb9c90c_Out_2;
            Unity_Multiply_float(_Multiply_75e09c235c25948090ea4d8278ef8128_Out_2, _Multiply_1242e07ae96a0986be2465dd335ea3ce_Out_2, _Multiply_c04d39982eed868d85bfb6d91eb9c90c_Out_2);
            float4 _Branch_26b3208110eff88aa733fd6d76443174_Out_3;
            Unity_Branch_float4(_Property_2809b3725785408c9b209c2f393adbfe_Out_0, _Multiply_c04d39982eed868d85bfb6d91eb9c90c_Out_2, float4(0, 0, 0, 0), _Branch_26b3208110eff88aa733fd6d76443174_Out_3);
            OutVector4_1 = _Branch_26b3208110eff88aa733fd6d76443174_Out_3;
        }

        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_half(half2 UV, half2 Tiling, half2 Offset, out half2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Lerp_half4(half4 A, half4 B, half4 T, out half4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Add_half4(half4 A, half4 B, out half4 Out)
        {
            Out = A + B;
        }

        void Unity_Preview_half4(half4 In, out half4 Out)
        {
            Out = In;
        }

        void Unity_Branch_half4(half Predicate, half4 True, half4 False, out half4 Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Preview_half(half In, out half Out)
        {
            Out = In;
        }

        void Unity_InvertColors_half(half In, half InvertColors, out half Out)
        {
            Out = abs(InvertColors - In);
        }

        void Unity_Branch_half(half Predicate, half True, half False, out half Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Multiply_half(half A, half B, out half Out)
        {
            Out = A * B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            half3 Position;
            half3 Normal;
            half3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            half3 BaseColor;
            half3 NormalTS;
            half3 Emission;
            half Metallic;
            half Smoothness;
            half Occlusion;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_R_1 = IN.VertexColor[0];
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_G_2 = IN.VertexColor[1];
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_B_3 = IN.VertexColor[2];
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_A_4 = IN.VertexColor[3];
            half _Property_87f4585dc8d54b05a0f25e8f107eef53_Out_0 = _UseFresnel;
            half4 _Property_1dac7c791a734e8fb2be234bcdd44337_Out_0 = IsGammaSpace() ? LinearToSRGB(_FresnelColor) : _FresnelColor;
            half _Property_a251014b95cc4e7db4743e47f6e8e93d_Out_0 = _FresnelPower;
            half _Property_5ec5aecdbf354f7585529f0672a64b78_Out_0 = _FresnelIntensity;
            Bindings_SGFresnel_7e6160c35a63ef34a922355032c45814 _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb;
            _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb.WorldSpaceNormal = IN.WorldSpaceNormal;
            _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            float4 _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb_OutVector4_1;
            SG_SGFresnel_7e6160c35a63ef34a922355032c45814(_Property_87f4585dc8d54b05a0f25e8f107eef53_Out_0, _Property_1dac7c791a734e8fb2be234bcdd44337_Out_0, _Property_a251014b95cc4e7db4743e47f6e8e93d_Out_0, _Property_5ec5aecdbf354f7585529f0672a64b78_Out_0, _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb, _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb_OutVector4_1);
            half4 _Multiply_6403337995204d2abcbf761062ce966e_Out_2;
            Unity_Multiply_half((_Split_ba230f5013744bfc8f8620b0f3cd990d_R_1.xxxx), _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb_OutVector4_1, _Multiply_6403337995204d2abcbf761062ce966e_Out_2);
            UnityTexture2D _Property_e7a99399bafa0587ba2e7079a5f728a1_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            half4 _UV_bfbe2619257a2686b08dc866af6ca964_Out_0 = IN.uv0;
            half2 _Vector2_c024e53e7d93da8a9574f74d5bf3f82f_Out_0 = half2(1, 1);
            half2 _Vector2_3c1621063ea091898c7642481de4a887_Out_0 = half2(0, 0);
            half2 _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3;
            Unity_TilingAndOffset_half((_UV_bfbe2619257a2686b08dc866af6ca964_Out_0.xy), _Vector2_c024e53e7d93da8a9574f74d5bf3f82f_Out_0, _Vector2_3c1621063ea091898c7642481de4a887_Out_0, _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3);
            half4 _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e7a99399bafa0587ba2e7079a5f728a1_Out_0.tex, _Property_e7a99399bafa0587ba2e7079a5f728a1_Out_0.samplerstate, _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3);
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_R_4 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.r;
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_G_5 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.g;
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_B_6 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.b;
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_A_7 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.a;
            half4 _Property_d1ce3ca7b148b78b9f5ccb04071f99e8_Out_0 = _ExtraTintColor;
            half _Property_960135caf923da82aa3565beb428b1af_Out_0 = _ExtraTintColorMultiplier;
            half4 _Lerp_efe9cdb25609028d801ea5aef49f1f50_Out_3;
            Unity_Lerp_half4(_SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0, _Property_d1ce3ca7b148b78b9f5ccb04071f99e8_Out_0, (_Property_960135caf923da82aa3565beb428b1af_Out_0.xxxx), _Lerp_efe9cdb25609028d801ea5aef49f1f50_Out_3);
            half4 _Add_4ccb3017631f4894b58f5b76aa0f4b2e_Out_2;
            Unity_Add_half4(_Multiply_6403337995204d2abcbf761062ce966e_Out_2, _Lerp_efe9cdb25609028d801ea5aef49f1f50_Out_3, _Add_4ccb3017631f4894b58f5b76aa0f4b2e_Out_2);
            UnityTexture2D _Property_83408f73f894c685bf6153270087b8de_Out_0 = UnityBuildTexture2DStructNoScale(_NormalMap);
            half4 _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0 = SAMPLE_TEXTURE2D(_Property_83408f73f894c685bf6153270087b8de_Out_0.tex, _Property_83408f73f894c685bf6153270087b8de_Out_0.samplerstate, _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3);
            _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0);
            half _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_R_4 = _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0.r;
            half _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_G_5 = _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0.g;
            half _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_B_6 = _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0.b;
            half _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_A_7 = _SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0.a;
            half4 _Preview_03a1fc616cdfbe8486bff19a80f303ef_Out_1;
            Unity_Preview_half4(_SampleTexture2D_3b70f0fd51a05981bb4beb370ce98c10_RGBA_0, _Preview_03a1fc616cdfbe8486bff19a80f303ef_Out_1);
            half _Property_20d3b24d820d0088ad2a145930e4a35c_Out_0 = _UseEmission;
            UnityTexture2D _Property_4d7844d686e0f983b887497a853eb5e1_Out_0 = UnityBuildTexture2DStructNoScale(_EmissiveMetallicMap);
            half4 _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4d7844d686e0f983b887497a853eb5e1_Out_0.tex, _Property_4d7844d686e0f983b887497a853eb5e1_Out_0.samplerstate, _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3);
            half _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_R_4 = _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0.r;
            half _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_G_5 = _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0.g;
            half _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_B_6 = _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0.b;
            half _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_A_7 = _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0.a;
            half4 _Branch_47381574f58f6c8681d309ea31449593_Out_3;
            Unity_Branch_half4(_Property_20d3b24d820d0088ad2a145930e4a35c_Out_0, _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0, half4(0, 0, 0, 0), _Branch_47381574f58f6c8681d309ea31449593_Out_3);
            half4 _Property_37720cf7049ae08289f4ae8b53085aaf_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            half4 _Multiply_8e3164fb1efdbb8ab6fad98c47359f3b_Out_2;
            Unity_Multiply_half(_Branch_47381574f58f6c8681d309ea31449593_Out_3, _Property_37720cf7049ae08289f4ae8b53085aaf_Out_0, _Multiply_8e3164fb1efdbb8ab6fad98c47359f3b_Out_2);
            half4 _Preview_303732097ce2c18cb43acfb058702795_Out_1;
            Unity_Preview_half4(_Multiply_8e3164fb1efdbb8ab6fad98c47359f3b_Out_2, _Preview_303732097ce2c18cb43acfb058702795_Out_1);
            half _Preview_540b725491637b82826b30d365b34860_Out_1;
            Unity_Preview_half(_SampleTexture2D_3d211e837b7d078bb23247c37ff80245_A_7, _Preview_540b725491637b82826b30d365b34860_Out_1);
            half _InvertColors_30aaf0081e3f038e8aa39e99807d617c_Out_1;
            half _InvertColors_30aaf0081e3f038e8aa39e99807d617c_InvertColors = half (1
        );    Unity_InvertColors_half(_Preview_540b725491637b82826b30d365b34860_Out_1, _InvertColors_30aaf0081e3f038e8aa39e99807d617c_InvertColors, _InvertColors_30aaf0081e3f038e8aa39e99807d617c_Out_1);
            half _Property_ba3b39acfe478f8b921fb54e436abcc8_Out_0 = _UseMetallic;
            half _Property_b0accd90b3492f8db55aa30a01180e22_Out_0 = _UseEmission;
            half _Branch_088d1cf29808a780b1935e7e9c72caa2_Out_3;
            Unity_Branch_half(_Property_b0accd90b3492f8db55aa30a01180e22_Out_0, _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_A_7, _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_R_4, _Branch_088d1cf29808a780b1935e7e9c72caa2_Out_3);
            half _Branch_27f5358f38bba587ac947708a94b7e07_Out_3;
            Unity_Branch_half(_Property_ba3b39acfe478f8b921fb54e436abcc8_Out_0, _Branch_088d1cf29808a780b1935e7e9c72caa2_Out_3, 0, _Branch_27f5358f38bba587ac947708a94b7e07_Out_3);
            half _Multiply_6ed6500d70e56d82a083c76a08d89c27_Out_2;
            Unity_Multiply_half(_InvertColors_30aaf0081e3f038e8aa39e99807d617c_Out_1, _Branch_27f5358f38bba587ac947708a94b7e07_Out_3, _Multiply_6ed6500d70e56d82a083c76a08d89c27_Out_2);
            surface.BaseColor = (_Add_4ccb3017631f4894b58f5b76aa0f4b2e_Out_2.xyz);
            surface.NormalTS = (_Preview_03a1fc616cdfbe8486bff19a80f303ef_Out_1.xyz);
            surface.Emission = (_Preview_303732097ce2c18cb43acfb058702795_Out_1.xyz);
            surface.Metallic = _Multiply_6ed6500d70e56d82a083c76a08d89c27_Out_2;
            surface.Smoothness = _Preview_540b725491637b82826b30d365b34860_Out_1;
            surface.Occlusion = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.uv0 =                         input.texCoord0;
            output.VertexColor =                 input.color;
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
            Cull Back
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
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
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
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
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
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
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
        float4 _MainTex_TexelSize;
        float4 _NormalMap_TexelSize;
        half _UseEmission;
        half _UseMetallic;
        float4 _EmissiveMetallicMap_TexelSize;
        half4 _EmissionColor;
        half _UseFresnel;
        half4 _FresnelColor;
        half _FresnelPower;
        half _FresnelIntensity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_EmissiveMetallicMap);
        SAMPLER(sampler_EmissiveMetallicMap);
        half4 _ExtraTintColor;
        half _ExtraTintColorMultiplier;

            // Graph Functions
            // GraphFunctions: <None>

            // Graph Vertex
            struct VertexDescription
        {
            half3 Position;
            half3 Normal;
            half3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





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
            Cull Back
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
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
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
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
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
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
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
        float4 _MainTex_TexelSize;
        float4 _NormalMap_TexelSize;
        half _UseEmission;
        half _UseMetallic;
        float4 _EmissiveMetallicMap_TexelSize;
        half4 _EmissionColor;
        half _UseFresnel;
        half4 _FresnelColor;
        half _FresnelPower;
        half _FresnelIntensity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_EmissiveMetallicMap);
        SAMPLER(sampler_EmissiveMetallicMap);
        half4 _ExtraTintColor;
        half _ExtraTintColorMultiplier;

            // Graph Functions
            // GraphFunctions: <None>

            // Graph Vertex
            struct VertexDescription
        {
            half3 Position;
            half3 Normal;
            half3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





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
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
            #define VARYINGS_NEED_VIEWDIRECTION_WS
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
            float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS;
            float4 texCoord0;
            float4 color;
            float3 viewDirectionWS;
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
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float4 uv0;
            float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
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
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.color;
            output.interp3.xyz =  input.viewDirectionWS;
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
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.color = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
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
        float4 _MainTex_TexelSize;
        float4 _NormalMap_TexelSize;
        half _UseEmission;
        half _UseMetallic;
        float4 _EmissiveMetallicMap_TexelSize;
        half4 _EmissionColor;
        half _UseFresnel;
        half4 _FresnelColor;
        half _FresnelPower;
        half _FresnelIntensity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_EmissiveMetallicMap);
        SAMPLER(sampler_EmissiveMetallicMap);
        half4 _ExtraTintColor;
        half _ExtraTintColorMultiplier;

            // Graph Functions

        void Unity_Add_float(half A, half B, out half Out)
        {
            Out = A + B;
        }

        void Unity_Absolute_float(half In, out half Out)
        {
            Out = abs(In);
        }

        void Unity_Power_float(half A, half B, out half Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(half A, half B, out half Out)
        {
            Out = A * B;
        }

        void Unity_FresnelEffect_float(half3 Normal, half3 ViewDir, half Power, out half Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Branch_float4(half Predicate, half4 True, half4 False, out half4 Out)
        {
            Out = Predicate ? True : False;
        }

        struct Bindings_SGFresnel_7e6160c35a63ef34a922355032c45814
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
        };

        void SG_SGFresnel_7e6160c35a63ef34a922355032c45814(float Boolean_30747C25, float4 Color_9F29EFCD, float Vector1_3C7524C4, float Vector1_74197E61, Bindings_SGFresnel_7e6160c35a63ef34a922355032c45814 IN, out float4 OutVector4_1)
        {
            float _Property_2809b3725785408c9b209c2f393adbfe_Out_0 = Boolean_30747C25;
            float _Property_375d6da72c208186b6051f95dc8dfe19_Out_0 = Vector1_74197E61;
            float _Add_83f5e08bf068c48d934c4b77fffc923f_Out_2;
            Unity_Add_float(_Property_375d6da72c208186b6051f95dc8dfe19_Out_0, 1, _Add_83f5e08bf068c48d934c4b77fffc923f_Out_2);
            float _Absolute_f22a13df5318c584bd91eb939b680f75_Out_1;
            Unity_Absolute_float(_Add_83f5e08bf068c48d934c4b77fffc923f_Out_2, _Absolute_f22a13df5318c584bd91eb939b680f75_Out_1);
            float _Power_64af6442a01454829e1bc876ed24082d_Out_2;
            Unity_Power_float(_Absolute_f22a13df5318c584bd91eb939b680f75_Out_1, 10, _Power_64af6442a01454829e1bc876ed24082d_Out_2);
            float4 _Property_eeb18107bd8d1d8ebb1f18b8017a57e0_Out_0 = Color_9F29EFCD;
            float4 _Multiply_75e09c235c25948090ea4d8278ef8128_Out_2;
            Unity_Multiply_float((_Power_64af6442a01454829e1bc876ed24082d_Out_2.xxxx), _Property_eeb18107bd8d1d8ebb1f18b8017a57e0_Out_0, _Multiply_75e09c235c25948090ea4d8278ef8128_Out_2);
            float _Property_13a729f7c7c92b8d8d28a87ab57268ff_Out_0 = Vector1_3C7524C4;
            float _Add_d82201bd9d0b6988bae88f9be0af636a_Out_2;
            Unity_Add_float(_Property_13a729f7c7c92b8d8d28a87ab57268ff_Out_0, 1, _Add_d82201bd9d0b6988bae88f9be0af636a_Out_2);
            float _Multiply_f85ae4a372a4c682939795a92e796fa9_Out_2;
            Unity_Multiply_float(_Add_d82201bd9d0b6988bae88f9be0af636a_Out_2, 0.5, _Multiply_f85ae4a372a4c682939795a92e796fa9_Out_2);
            float _Power_b829bc935b090b8b8d01421079dbec58_Out_2;
            Unity_Power_float(10, _Multiply_f85ae4a372a4c682939795a92e796fa9_Out_2, _Power_b829bc935b090b8b8d01421079dbec58_Out_2);
            float _FresnelEffect_14488595fead3e8e83fb92850e7317d6_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Power_b829bc935b090b8b8d01421079dbec58_Out_2, _FresnelEffect_14488595fead3e8e83fb92850e7317d6_Out_3);
            float4 _Multiply_1242e07ae96a0986be2465dd335ea3ce_Out_2;
            Unity_Multiply_float(_Property_eeb18107bd8d1d8ebb1f18b8017a57e0_Out_0, (_FresnelEffect_14488595fead3e8e83fb92850e7317d6_Out_3.xxxx), _Multiply_1242e07ae96a0986be2465dd335ea3ce_Out_2);
            float4 _Multiply_c04d39982eed868d85bfb6d91eb9c90c_Out_2;
            Unity_Multiply_float(_Multiply_75e09c235c25948090ea4d8278ef8128_Out_2, _Multiply_1242e07ae96a0986be2465dd335ea3ce_Out_2, _Multiply_c04d39982eed868d85bfb6d91eb9c90c_Out_2);
            float4 _Branch_26b3208110eff88aa733fd6d76443174_Out_3;
            Unity_Branch_float4(_Property_2809b3725785408c9b209c2f393adbfe_Out_0, _Multiply_c04d39982eed868d85bfb6d91eb9c90c_Out_2, float4(0, 0, 0, 0), _Branch_26b3208110eff88aa733fd6d76443174_Out_3);
            OutVector4_1 = _Branch_26b3208110eff88aa733fd6d76443174_Out_3;
        }

        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_half(half2 UV, half2 Tiling, half2 Offset, out half2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Lerp_half4(half4 A, half4 B, half4 T, out half4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Add_half4(half4 A, half4 B, out half4 Out)
        {
            Out = A + B;
        }

        void Unity_Branch_half4(half Predicate, half4 True, half4 False, out half4 Out)
        {
            Out = Predicate ? True : False;
        }

        void Unity_Preview_half4(half4 In, out half4 Out)
        {
            Out = In;
        }

            // Graph Vertex
            struct VertexDescription
        {
            half3 Position;
            half3 Normal;
            half3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            half3 BaseColor;
            half3 Emission;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_R_1 = IN.VertexColor[0];
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_G_2 = IN.VertexColor[1];
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_B_3 = IN.VertexColor[2];
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_A_4 = IN.VertexColor[3];
            half _Property_87f4585dc8d54b05a0f25e8f107eef53_Out_0 = _UseFresnel;
            half4 _Property_1dac7c791a734e8fb2be234bcdd44337_Out_0 = IsGammaSpace() ? LinearToSRGB(_FresnelColor) : _FresnelColor;
            half _Property_a251014b95cc4e7db4743e47f6e8e93d_Out_0 = _FresnelPower;
            half _Property_5ec5aecdbf354f7585529f0672a64b78_Out_0 = _FresnelIntensity;
            Bindings_SGFresnel_7e6160c35a63ef34a922355032c45814 _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb;
            _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb.WorldSpaceNormal = IN.WorldSpaceNormal;
            _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            float4 _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb_OutVector4_1;
            SG_SGFresnel_7e6160c35a63ef34a922355032c45814(_Property_87f4585dc8d54b05a0f25e8f107eef53_Out_0, _Property_1dac7c791a734e8fb2be234bcdd44337_Out_0, _Property_a251014b95cc4e7db4743e47f6e8e93d_Out_0, _Property_5ec5aecdbf354f7585529f0672a64b78_Out_0, _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb, _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb_OutVector4_1);
            half4 _Multiply_6403337995204d2abcbf761062ce966e_Out_2;
            Unity_Multiply_half((_Split_ba230f5013744bfc8f8620b0f3cd990d_R_1.xxxx), _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb_OutVector4_1, _Multiply_6403337995204d2abcbf761062ce966e_Out_2);
            UnityTexture2D _Property_e7a99399bafa0587ba2e7079a5f728a1_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            half4 _UV_bfbe2619257a2686b08dc866af6ca964_Out_0 = IN.uv0;
            half2 _Vector2_c024e53e7d93da8a9574f74d5bf3f82f_Out_0 = half2(1, 1);
            half2 _Vector2_3c1621063ea091898c7642481de4a887_Out_0 = half2(0, 0);
            half2 _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3;
            Unity_TilingAndOffset_half((_UV_bfbe2619257a2686b08dc866af6ca964_Out_0.xy), _Vector2_c024e53e7d93da8a9574f74d5bf3f82f_Out_0, _Vector2_3c1621063ea091898c7642481de4a887_Out_0, _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3);
            half4 _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e7a99399bafa0587ba2e7079a5f728a1_Out_0.tex, _Property_e7a99399bafa0587ba2e7079a5f728a1_Out_0.samplerstate, _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3);
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_R_4 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.r;
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_G_5 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.g;
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_B_6 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.b;
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_A_7 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.a;
            half4 _Property_d1ce3ca7b148b78b9f5ccb04071f99e8_Out_0 = _ExtraTintColor;
            half _Property_960135caf923da82aa3565beb428b1af_Out_0 = _ExtraTintColorMultiplier;
            half4 _Lerp_efe9cdb25609028d801ea5aef49f1f50_Out_3;
            Unity_Lerp_half4(_SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0, _Property_d1ce3ca7b148b78b9f5ccb04071f99e8_Out_0, (_Property_960135caf923da82aa3565beb428b1af_Out_0.xxxx), _Lerp_efe9cdb25609028d801ea5aef49f1f50_Out_3);
            half4 _Add_4ccb3017631f4894b58f5b76aa0f4b2e_Out_2;
            Unity_Add_half4(_Multiply_6403337995204d2abcbf761062ce966e_Out_2, _Lerp_efe9cdb25609028d801ea5aef49f1f50_Out_3, _Add_4ccb3017631f4894b58f5b76aa0f4b2e_Out_2);
            half _Property_20d3b24d820d0088ad2a145930e4a35c_Out_0 = _UseEmission;
            UnityTexture2D _Property_4d7844d686e0f983b887497a853eb5e1_Out_0 = UnityBuildTexture2DStructNoScale(_EmissiveMetallicMap);
            half4 _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4d7844d686e0f983b887497a853eb5e1_Out_0.tex, _Property_4d7844d686e0f983b887497a853eb5e1_Out_0.samplerstate, _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3);
            half _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_R_4 = _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0.r;
            half _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_G_5 = _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0.g;
            half _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_B_6 = _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0.b;
            half _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_A_7 = _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0.a;
            half4 _Branch_47381574f58f6c8681d309ea31449593_Out_3;
            Unity_Branch_half4(_Property_20d3b24d820d0088ad2a145930e4a35c_Out_0, _SampleTexture2D_d193981dcfa5c0829b48423600b7a24d_RGBA_0, half4(0, 0, 0, 0), _Branch_47381574f58f6c8681d309ea31449593_Out_3);
            half4 _Property_37720cf7049ae08289f4ae8b53085aaf_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            half4 _Multiply_8e3164fb1efdbb8ab6fad98c47359f3b_Out_2;
            Unity_Multiply_half(_Branch_47381574f58f6c8681d309ea31449593_Out_3, _Property_37720cf7049ae08289f4ae8b53085aaf_Out_0, _Multiply_8e3164fb1efdbb8ab6fad98c47359f3b_Out_2);
            half4 _Preview_303732097ce2c18cb43acfb058702795_Out_1;
            Unity_Preview_half4(_Multiply_8e3164fb1efdbb8ab6fad98c47359f3b_Out_2, _Preview_303732097ce2c18cb43acfb058702795_Out_1);
            surface.BaseColor = (_Add_4ccb3017631f4894b58f5b76aa0f4b2e_Out_2.xyz);
            surface.Emission = (_Preview_303732097ce2c18cb43acfb058702795_Out_1.xyz);
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.uv0 =                         input.texCoord0;
            output.VertexColor =                 input.color;
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
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Back
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
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
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
            float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS;
            float4 texCoord0;
            float4 color;
            float3 viewDirectionWS;
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
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float4 uv0;
            float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float4 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
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
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.color;
            output.interp3.xyz =  input.viewDirectionWS;
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
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            output.color = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
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
        float4 _MainTex_TexelSize;
        float4 _NormalMap_TexelSize;
        half _UseEmission;
        half _UseMetallic;
        float4 _EmissiveMetallicMap_TexelSize;
        half4 _EmissionColor;
        half _UseFresnel;
        half4 _FresnelColor;
        half _FresnelPower;
        half _FresnelIntensity;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_NormalMap);
        SAMPLER(sampler_NormalMap);
        TEXTURE2D(_EmissiveMetallicMap);
        SAMPLER(sampler_EmissiveMetallicMap);
        half4 _ExtraTintColor;
        half _ExtraTintColorMultiplier;

            // Graph Functions

        void Unity_Add_float(half A, half B, out half Out)
        {
            Out = A + B;
        }

        void Unity_Absolute_float(half In, out half Out)
        {
            Out = abs(In);
        }

        void Unity_Power_float(half A, half B, out half Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(half A, half B, out half Out)
        {
            Out = A * B;
        }

        void Unity_FresnelEffect_float(half3 Normal, half3 ViewDir, half Power, out half Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Branch_float4(half Predicate, half4 True, half4 False, out half4 Out)
        {
            Out = Predicate ? True : False;
        }

        struct Bindings_SGFresnel_7e6160c35a63ef34a922355032c45814
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
        };

        void SG_SGFresnel_7e6160c35a63ef34a922355032c45814(float Boolean_30747C25, float4 Color_9F29EFCD, float Vector1_3C7524C4, float Vector1_74197E61, Bindings_SGFresnel_7e6160c35a63ef34a922355032c45814 IN, out float4 OutVector4_1)
        {
            float _Property_2809b3725785408c9b209c2f393adbfe_Out_0 = Boolean_30747C25;
            float _Property_375d6da72c208186b6051f95dc8dfe19_Out_0 = Vector1_74197E61;
            float _Add_83f5e08bf068c48d934c4b77fffc923f_Out_2;
            Unity_Add_float(_Property_375d6da72c208186b6051f95dc8dfe19_Out_0, 1, _Add_83f5e08bf068c48d934c4b77fffc923f_Out_2);
            float _Absolute_f22a13df5318c584bd91eb939b680f75_Out_1;
            Unity_Absolute_float(_Add_83f5e08bf068c48d934c4b77fffc923f_Out_2, _Absolute_f22a13df5318c584bd91eb939b680f75_Out_1);
            float _Power_64af6442a01454829e1bc876ed24082d_Out_2;
            Unity_Power_float(_Absolute_f22a13df5318c584bd91eb939b680f75_Out_1, 10, _Power_64af6442a01454829e1bc876ed24082d_Out_2);
            float4 _Property_eeb18107bd8d1d8ebb1f18b8017a57e0_Out_0 = Color_9F29EFCD;
            float4 _Multiply_75e09c235c25948090ea4d8278ef8128_Out_2;
            Unity_Multiply_float((_Power_64af6442a01454829e1bc876ed24082d_Out_2.xxxx), _Property_eeb18107bd8d1d8ebb1f18b8017a57e0_Out_0, _Multiply_75e09c235c25948090ea4d8278ef8128_Out_2);
            float _Property_13a729f7c7c92b8d8d28a87ab57268ff_Out_0 = Vector1_3C7524C4;
            float _Add_d82201bd9d0b6988bae88f9be0af636a_Out_2;
            Unity_Add_float(_Property_13a729f7c7c92b8d8d28a87ab57268ff_Out_0, 1, _Add_d82201bd9d0b6988bae88f9be0af636a_Out_2);
            float _Multiply_f85ae4a372a4c682939795a92e796fa9_Out_2;
            Unity_Multiply_float(_Add_d82201bd9d0b6988bae88f9be0af636a_Out_2, 0.5, _Multiply_f85ae4a372a4c682939795a92e796fa9_Out_2);
            float _Power_b829bc935b090b8b8d01421079dbec58_Out_2;
            Unity_Power_float(10, _Multiply_f85ae4a372a4c682939795a92e796fa9_Out_2, _Power_b829bc935b090b8b8d01421079dbec58_Out_2);
            float _FresnelEffect_14488595fead3e8e83fb92850e7317d6_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Power_b829bc935b090b8b8d01421079dbec58_Out_2, _FresnelEffect_14488595fead3e8e83fb92850e7317d6_Out_3);
            float4 _Multiply_1242e07ae96a0986be2465dd335ea3ce_Out_2;
            Unity_Multiply_float(_Property_eeb18107bd8d1d8ebb1f18b8017a57e0_Out_0, (_FresnelEffect_14488595fead3e8e83fb92850e7317d6_Out_3.xxxx), _Multiply_1242e07ae96a0986be2465dd335ea3ce_Out_2);
            float4 _Multiply_c04d39982eed868d85bfb6d91eb9c90c_Out_2;
            Unity_Multiply_float(_Multiply_75e09c235c25948090ea4d8278ef8128_Out_2, _Multiply_1242e07ae96a0986be2465dd335ea3ce_Out_2, _Multiply_c04d39982eed868d85bfb6d91eb9c90c_Out_2);
            float4 _Branch_26b3208110eff88aa733fd6d76443174_Out_3;
            Unity_Branch_float4(_Property_2809b3725785408c9b209c2f393adbfe_Out_0, _Multiply_c04d39982eed868d85bfb6d91eb9c90c_Out_2, float4(0, 0, 0, 0), _Branch_26b3208110eff88aa733fd6d76443174_Out_3);
            OutVector4_1 = _Branch_26b3208110eff88aa733fd6d76443174_Out_3;
        }

        void Unity_Multiply_half(half4 A, half4 B, out half4 Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_half(half2 UV, half2 Tiling, half2 Offset, out half2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Lerp_half4(half4 A, half4 B, half4 T, out half4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Add_half4(half4 A, half4 B, out half4 Out)
        {
            Out = A + B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            half3 Position;
            half3 Normal;
            half3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            half3 BaseColor;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_R_1 = IN.VertexColor[0];
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_G_2 = IN.VertexColor[1];
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_B_3 = IN.VertexColor[2];
            half _Split_ba230f5013744bfc8f8620b0f3cd990d_A_4 = IN.VertexColor[3];
            half _Property_87f4585dc8d54b05a0f25e8f107eef53_Out_0 = _UseFresnel;
            half4 _Property_1dac7c791a734e8fb2be234bcdd44337_Out_0 = IsGammaSpace() ? LinearToSRGB(_FresnelColor) : _FresnelColor;
            half _Property_a251014b95cc4e7db4743e47f6e8e93d_Out_0 = _FresnelPower;
            half _Property_5ec5aecdbf354f7585529f0672a64b78_Out_0 = _FresnelIntensity;
            Bindings_SGFresnel_7e6160c35a63ef34a922355032c45814 _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb;
            _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb.WorldSpaceNormal = IN.WorldSpaceNormal;
            _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb.WorldSpaceViewDirection = IN.WorldSpaceViewDirection;
            float4 _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb_OutVector4_1;
            SG_SGFresnel_7e6160c35a63ef34a922355032c45814(_Property_87f4585dc8d54b05a0f25e8f107eef53_Out_0, _Property_1dac7c791a734e8fb2be234bcdd44337_Out_0, _Property_a251014b95cc4e7db4743e47f6e8e93d_Out_0, _Property_5ec5aecdbf354f7585529f0672a64b78_Out_0, _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb, _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb_OutVector4_1);
            half4 _Multiply_6403337995204d2abcbf761062ce966e_Out_2;
            Unity_Multiply_half((_Split_ba230f5013744bfc8f8620b0f3cd990d_R_1.xxxx), _SGFresnel_4396082a90d345bc8f80a8f62d0ba7fb_OutVector4_1, _Multiply_6403337995204d2abcbf761062ce966e_Out_2);
            UnityTexture2D _Property_e7a99399bafa0587ba2e7079a5f728a1_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            half4 _UV_bfbe2619257a2686b08dc866af6ca964_Out_0 = IN.uv0;
            half2 _Vector2_c024e53e7d93da8a9574f74d5bf3f82f_Out_0 = half2(1, 1);
            half2 _Vector2_3c1621063ea091898c7642481de4a887_Out_0 = half2(0, 0);
            half2 _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3;
            Unity_TilingAndOffset_half((_UV_bfbe2619257a2686b08dc866af6ca964_Out_0.xy), _Vector2_c024e53e7d93da8a9574f74d5bf3f82f_Out_0, _Vector2_3c1621063ea091898c7642481de4a887_Out_0, _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3);
            half4 _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0 = SAMPLE_TEXTURE2D(_Property_e7a99399bafa0587ba2e7079a5f728a1_Out_0.tex, _Property_e7a99399bafa0587ba2e7079a5f728a1_Out_0.samplerstate, _TilingAndOffset_c4575d7de02a298584b9954f48e98e0d_Out_3);
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_R_4 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.r;
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_G_5 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.g;
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_B_6 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.b;
            half _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_A_7 = _SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0.a;
            half4 _Property_d1ce3ca7b148b78b9f5ccb04071f99e8_Out_0 = _ExtraTintColor;
            half _Property_960135caf923da82aa3565beb428b1af_Out_0 = _ExtraTintColorMultiplier;
            half4 _Lerp_efe9cdb25609028d801ea5aef49f1f50_Out_3;
            Unity_Lerp_half4(_SampleTexture2D_3d211e837b7d078bb23247c37ff80245_RGBA_0, _Property_d1ce3ca7b148b78b9f5ccb04071f99e8_Out_0, (_Property_960135caf923da82aa3565beb428b1af_Out_0.xxxx), _Lerp_efe9cdb25609028d801ea5aef49f1f50_Out_3);
            half4 _Add_4ccb3017631f4894b58f5b76aa0f4b2e_Out_2;
            Unity_Add_half4(_Multiply_6403337995204d2abcbf761062ce966e_Out_2, _Lerp_efe9cdb25609028d801ea5aef49f1f50_Out_3, _Add_4ccb3017631f4894b58f5b76aa0f4b2e_Out_2);
            surface.BaseColor = (_Add_4ccb3017631f4894b58f5b76aa0f4b2e_Out_2.xyz);
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.uv0 =                         input.texCoord0;
            output.VertexColor =                 input.color;
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "SHD_EggEditor"
    FallBack "Unlit/Texture"
}
