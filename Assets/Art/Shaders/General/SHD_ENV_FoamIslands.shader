Shader "DragonCity2/ENV/Foam Islands"
{
    Properties
    {
        _MainColor("Main Color", Color) = (1, 1, 1, 0)
        _FoamColor("Foam Color", Color) = (1, 1, 1, 0)
        [NoScaleOffset]_FoamMap("Foam Map", 2D) = "white" {}
        _Tilling("Tilling", Vector) = (1, 1, 0, 0)
        _FoamPower("Foam Power", Range(0, 10)) = 1
        _FoamSpeed("Foam Speed", Range(-0.5, 0.5)) = -0.08
        [ToggleUI]_UseVertexAnim("Use Vertex Animation", Float) = 0
        _OverallAnimation("Overall Animation", Range(0, 1)) = 1
        [NoScaleOffset]_AnimationMap("Animation Map", 2D) = "white" {}
        _WindSpeed("Speed", Range(0, 10)) = 0.5
        _WindScale("Scale", Range(0, 1)) = 0.2
        _OffsetAnimation("Offset", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Pass"
            Tags
            {
                // LightMode: <None>
            }

            // Render State
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

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
            //#pragma multi_compile _ LIGHTMAP_ON
        //#pragma multi_compile _ DIRLIGHTMAP_COMBINED
        //#pragma shader_feature _ _SAMPLE_GI
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
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
            float3 positionWS;
            float3 normalWS;
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
            float3 WorldSpaceNormal;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 VertexColor;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
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
            output.interp2.xyzw =  input.texCoord0;
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
            output.texCoord0 = input.interp2.xyzw;
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
        float4 _MainColor;
        float4 _FoamColor;
        float4 _FoamMap_TexelSize;
        float2 _Tilling;
        float _FoamPower;
        float _FoamSpeed;
        float _UseVertexAnim;
        float _OverallAnimation;
        float4 _AnimationMap_TexelSize;
        float _WindSpeed;
        float _WindScale;
        float3 _OffsetAnimation;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FoamMap);
        SAMPLER(sampler_FoamMap);
        TEXTURE2D(_AnimationMap);
        SAMPLER(sampler_AnimationMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }

        struct Bindings_SGVertexAnimationWNoise_4199d1a917d244c44999767de42e7135
        {
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 VertexColor;
            float3 TimeParameters;
        };

        void SG_SGVertexAnimationWNoise_4199d1a917d244c44999767de42e7135(float Boolean_e159330812d24512a3f1203f94de3ddb, float Vector1_a073e91b7fa248d1be392701d8074de3, UnityTexture2D Texture2D_3abc34d6da8e4d2bae3d4056180cc14b, float Vector1_c207ca6102ad4bd1a8c13305b12c30ea, float Vector1_a242c1bedc2941d9b14d53f6bf951fc1, float3 Vector3_5b064d9257f14241a138dd7cb764f536, Bindings_SGVertexAnimationWNoise_4199d1a917d244c44999767de42e7135 IN, out float3 Out_Vector4_1)
        {
            float _Property_cb3d9520c2d245589054bf586f6532e0_Out_0 = Boolean_e159330812d24512a3f1203f94de3ddb;
            float _Property_9aa2019db5244d0c9112d41b9e2e4cbb_Out_0 = Vector1_a073e91b7fa248d1be392701d8074de3;
            float4 _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2;
            Unity_Multiply_float((_Property_9aa2019db5244d0c9112d41b9e2e4cbb_Out_0.xxxx), IN.VertexColor, _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2);
            float _Split_76b24236ba82479c9ee96e6bff99fffb_R_1 = _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2[0];
            float _Split_76b24236ba82479c9ee96e6bff99fffb_G_2 = _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2[1];
            float _Split_76b24236ba82479c9ee96e6bff99fffb_B_3 = _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2[2];
            float _Split_76b24236ba82479c9ee96e6bff99fffb_A_4 = _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2[3];
            UnityTexture2D _Property_c8b150e89fd946f0827c36e9e5ff3cc4_Out_0 = Texture2D_3abc34d6da8e4d2bae3d4056180cc14b;
            float _Property_6ebbdb482ef245059f2e80b17b53a426_Out_0 = Vector1_a242c1bedc2941d9b14d53f6bf951fc1;
            float _Split_35f7f2b53bae47aba08116df940a039b_R_1 = IN.WorldSpacePosition[0];
            float _Split_35f7f2b53bae47aba08116df940a039b_G_2 = IN.WorldSpacePosition[1];
            float _Split_35f7f2b53bae47aba08116df940a039b_B_3 = IN.WorldSpacePosition[2];
            float _Split_35f7f2b53bae47aba08116df940a039b_A_4 = 0;
            float _Property_0ac822f99f9d4a298d1f207bd97053f6_Out_0 = Vector1_c207ca6102ad4bd1a8c13305b12c30ea;
            float _Multiply_caa06c3372364a2b8173f6d8618c9f6d_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_0ac822f99f9d4a298d1f207bd97053f6_Out_0, _Multiply_caa06c3372364a2b8173f6d8618c9f6d_Out_2);
            float _Add_db0a3678fb5f46d387dca5a7664ae4a7_Out_2;
            Unity_Add_float(_Split_35f7f2b53bae47aba08116df940a039b_R_1, _Multiply_caa06c3372364a2b8173f6d8618c9f6d_Out_2, _Add_db0a3678fb5f46d387dca5a7664ae4a7_Out_2);
            float _Add_0da3ac7f1b114ef6a7531947a2ff75b7_Out_2;
            Unity_Add_float(_Split_35f7f2b53bae47aba08116df940a039b_B_3, _Multiply_caa06c3372364a2b8173f6d8618c9f6d_Out_2, _Add_0da3ac7f1b114ef6a7531947a2ff75b7_Out_2);
            float2 _Vector2_e2b98d36b5fc4a4e8fafb96dab2f7c3b_Out_0 = float2(_Add_db0a3678fb5f46d387dca5a7664ae4a7_Out_2, _Add_0da3ac7f1b114ef6a7531947a2ff75b7_Out_2);
            float2 _Multiply_88a0b4289e5941f08b03958867ca5d3f_Out_2;
            Unity_Multiply_float((_Property_6ebbdb482ef245059f2e80b17b53a426_Out_0.xx), _Vector2_e2b98d36b5fc4a4e8fafb96dab2f7c3b_Out_0, _Multiply_88a0b4289e5941f08b03958867ca5d3f_Out_2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_c8b150e89fd946f0827c36e9e5ff3cc4_Out_0.tex, _Property_c8b150e89fd946f0827c36e9e5ff3cc4_Out_0.samplerstate, _Multiply_88a0b4289e5941f08b03958867ca5d3f_Out_2, 0);
            #endif
            float _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_R_5 = _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0.r;
            float _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_G_6 = _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0.g;
            float _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_B_7 = _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0.b;
            float _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_A_8 = _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0.a;
            float _Multiply_fd0db81808444ce59b035aa8b097d80d_Out_2;
            Unity_Multiply_float(_Split_76b24236ba82479c9ee96e6bff99fffb_G_2, _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_R_5, _Multiply_fd0db81808444ce59b035aa8b097d80d_Out_2);
            float _Split_3b5205c8bdda4576821e61c6dcf6836b_R_1 = IN.ObjectSpacePosition[0];
            float _Split_3b5205c8bdda4576821e61c6dcf6836b_G_2 = IN.ObjectSpacePosition[1];
            float _Split_3b5205c8bdda4576821e61c6dcf6836b_B_3 = IN.ObjectSpacePosition[2];
            float _Split_3b5205c8bdda4576821e61c6dcf6836b_A_4 = 0;
            float _Add_a5623a7a143444b987c1ce767efca3c0_Out_2;
            Unity_Add_float(_Multiply_fd0db81808444ce59b035aa8b097d80d_Out_2, _Split_3b5205c8bdda4576821e61c6dcf6836b_R_1, _Add_a5623a7a143444b987c1ce767efca3c0_Out_2);
            float _Multiply_4aae774466ec4a65acd3caed8a20e169_Out_2;
            Unity_Multiply_float(_Split_76b24236ba82479c9ee96e6bff99fffb_G_2, _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_R_5, _Multiply_4aae774466ec4a65acd3caed8a20e169_Out_2);
            float _Add_b905575f5f474b5996309ea150d9a735_Out_2;
            Unity_Add_float(_Split_3b5205c8bdda4576821e61c6dcf6836b_B_3, _Multiply_4aae774466ec4a65acd3caed8a20e169_Out_2, _Add_b905575f5f474b5996309ea150d9a735_Out_2);
            float4 _Combine_a61702d97880410ab247673aa15bb24b_RGBA_4;
            float3 _Combine_a61702d97880410ab247673aa15bb24b_RGB_5;
            float2 _Combine_a61702d97880410ab247673aa15bb24b_RG_6;
            Unity_Combine_float(_Add_a5623a7a143444b987c1ce767efca3c0_Out_2, _Split_3b5205c8bdda4576821e61c6dcf6836b_G_2, _Add_b905575f5f474b5996309ea150d9a735_Out_2, 0, _Combine_a61702d97880410ab247673aa15bb24b_RGBA_4, _Combine_a61702d97880410ab247673aa15bb24b_RGB_5, _Combine_a61702d97880410ab247673aa15bb24b_RG_6);
            float3 _Property_8917cb38b5a44e8ba5a317fdf91e0251_Out_0 = Vector3_5b064d9257f14241a138dd7cb764f536;
            float3 _Subtract_e7baaf5c449042bf96eb6e95e60fc0f8_Out_2;
            Unity_Subtract_float3(_Combine_a61702d97880410ab247673aa15bb24b_RGB_5, _Property_8917cb38b5a44e8ba5a317fdf91e0251_Out_0, _Subtract_e7baaf5c449042bf96eb6e95e60fc0f8_Out_2);
            float3 _Branch_b8453590d5e5418d866e303e4bbae174_Out_3;
            Unity_Branch_float3(_Property_cb3d9520c2d245589054bf586f6532e0_Out_0, _Subtract_e7baaf5c449042bf96eb6e95e60fc0f8_Out_2, IN.ObjectSpacePosition, _Branch_b8453590d5e5418d866e303e4bbae174_Out_3);
            Out_Vector4_1 = _Branch_b8453590d5e5418d866e303e4bbae174_Out_3;
        }

        // 99f4aa4c347fdeb928a4ad3cc5b44bf4
        #include "Assets/Art/Shaders/General/Includes/CustomLighting.hlsl"

        struct Bindings_SGMainFullLight_060327f1397593a4f85103bc6c969728
        {
        };

        void SG_SGMainFullLight_060327f1397593a4f85103bc6c969728(float3 Vector3_ACDB5C20, Bindings_SGMainFullLight_060327f1397593a4f85103bc6c969728 IN, out half3 LightDirection_1, out half3 LightColor_2, out half LightDistanceAtten_3, out half LightShadowAtten_4)
        {
            float3 _Property_5565c4d98c7ff983968d18dc26afa688_Out_0 = Vector3_ACDB5C20;
            half3 _MainLightShadowsCustomFunction_4c7cccbfec4beb8d9b7b3d5425a49675_LightDirection_1;
            half3 _MainLightShadowsCustomFunction_4c7cccbfec4beb8d9b7b3d5425a49675_LightColor_2;
            half _MainLightShadowsCustomFunction_4c7cccbfec4beb8d9b7b3d5425a49675_LightDistanceAtten_3;
            half _MainLightShadowsCustomFunction_4c7cccbfec4beb8d9b7b3d5425a49675_LightShadowAtten_4;
            MainLightShadows_half(_Property_5565c4d98c7ff983968d18dc26afa688_Out_0, _MainLightShadowsCustomFunction_4c7cccbfec4beb8d9b7b3d5425a49675_LightDirection_1, _MainLightShadowsCustomFunction_4c7cccbfec4beb8d9b7b3d5425a49675_LightColor_2, _MainLightShadowsCustomFunction_4c7cccbfec4beb8d9b7b3d5425a49675_LightDistanceAtten_3, _MainLightShadowsCustomFunction_4c7cccbfec4beb8d9b7b3d5425a49675_LightShadowAtten_4);
            LightDirection_1 = _MainLightShadowsCustomFunction_4c7cccbfec4beb8d9b7b3d5425a49675_LightDirection_1;
            LightColor_2 = _MainLightShadowsCustomFunction_4c7cccbfec4beb8d9b7b3d5425a49675_LightColor_2;
            LightDistanceAtten_3 = _MainLightShadowsCustomFunction_4c7cccbfec4beb8d9b7b3d5425a49675_LightDistanceAtten_3;
            LightShadowAtten_4 = _MainLightShadowsCustomFunction_4c7cccbfec4beb8d9b7b3d5425a49675_LightShadowAtten_4;
        }

        void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
        {
            Out = dot(A, B);
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Preview_float(float In, out float Out)
        {
            Out = In;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        struct Bindings_SGAmbient_e13fbf63d7907af4ab4988492ac7bca8
        {
            float3 WorldSpaceNormal;
        };

        void SG_SGAmbient_e13fbf63d7907af4ab4988492ac7bca8(float Vector1_5DDD60EC, Bindings_SGAmbient_e13fbf63d7907af4ab4988492ac7bca8 IN, out float3 Ambient_1)
        {
            float3 _AmbientSampleSHCustomFunction_4419b13d7b31e68e8e059676cfda8898_SH_0;
            AmbientSampleSH_float(IN.WorldSpaceNormal, _AmbientSampleSHCustomFunction_4419b13d7b31e68e8e059676cfda8898_SH_0);
            float _Property_88a145fc6fa0338d9bbc46fed1ed8312_Out_0 = Vector1_5DDD60EC;
            float3 _Multiply_3db54a3cf7879983a778341286ffaebc_Out_2;
            Unity_Multiply_float(_AmbientSampleSHCustomFunction_4419b13d7b31e68e8e059676cfda8898_SH_0, (_Property_88a145fc6fa0338d9bbc46fed1ed8312_Out_0.xxx), _Multiply_3db54a3cf7879983a778341286ffaebc_Out_2);
            Ambient_1 = _Multiply_3db54a3cf7879983a778341286ffaebc_Out_2;
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        struct Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8
        {
            half4 uv0;
        };

        void SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(float4 Vector4_2F6A811A, Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 IN, out float4 Out_Vector2_1)
        {
            float4 _Property_617a4d2ce8938583a2fc0f5865f6d6d7_Out_0 = Vector4_2F6A811A;
            float _Split_111abdeb95a33f8585d7ec4c8193134b_R_1 = _Property_617a4d2ce8938583a2fc0f5865f6d6d7_Out_0[0];
            float _Split_111abdeb95a33f8585d7ec4c8193134b_G_2 = _Property_617a4d2ce8938583a2fc0f5865f6d6d7_Out_0[1];
            float _Split_111abdeb95a33f8585d7ec4c8193134b_B_3 = _Property_617a4d2ce8938583a2fc0f5865f6d6d7_Out_0[2];
            float _Split_111abdeb95a33f8585d7ec4c8193134b_A_4 = _Property_617a4d2ce8938583a2fc0f5865f6d6d7_Out_0[3];
            float2 _Vector2_84d21e7b137fe28bb95ba0383bff379a_Out_0 = float2(_Split_111abdeb95a33f8585d7ec4c8193134b_R_1, _Split_111abdeb95a33f8585d7ec4c8193134b_G_2);
            float2 _Vector2_1571655971098b83bd6db78da85f5d08_Out_0 = float2(_Split_111abdeb95a33f8585d7ec4c8193134b_B_3, _Split_111abdeb95a33f8585d7ec4c8193134b_A_4);
            float2 _TilingAndOffset_54f7abf9415578879df48d2c8bec8335_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_84d21e7b137fe28bb95ba0383bff379a_Out_0, _Vector2_1571655971098b83bd6db78da85f5d08_Out_0, _TilingAndOffset_54f7abf9415578879df48d2c8bec8335_Out_3);
            Out_Vector2_1 = (float4(_TilingAndOffset_54f7abf9415578879df48d2c8bec8335_Out_3, 0.0, 1.0));
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Fog_float(out float4 Color, out float Density, float3 Position)
        {
            SHADERGRAPH_FOG(Position, Color, Density);
        }

        void Unity_Exponential2_float(float In, out float Out)
        {
            Out = exp2(In);
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        struct Bindings_SGFog_6fda06a5a255f8244a0881200c0efc1c
        {
            float3 ObjectSpacePosition;
        };

        void SG_SGFog_6fda06a5a255f8244a0881200c0efc1c(float4 Vector4_dbd06c0350c7420aafeaa3e4830ca41b, Bindings_SGFog_6fda06a5a255f8244a0881200c0efc1c IN, out float4 OutVector4_1)
        {
            float4 _Fog_49ed9f88320e414eaba21e255c409f00_Color_0;
            float _Fog_49ed9f88320e414eaba21e255c409f00_Density_1;
            Unity_Fog_float(_Fog_49ed9f88320e414eaba21e255c409f00_Color_0, _Fog_49ed9f88320e414eaba21e255c409f00_Density_1, IN.ObjectSpacePosition);
            float4 _Property_32d916c6e755465daa887bbd4e2b5b71_Out_0 = Vector4_dbd06c0350c7420aafeaa3e4830ca41b;
            float _Multiply_4cd3f1e051334674922cbdd6bac43016_Out_2;
            Unity_Multiply_float(_Fog_49ed9f88320e414eaba21e255c409f00_Density_1, _Fog_49ed9f88320e414eaba21e255c409f00_Density_1, _Multiply_4cd3f1e051334674922cbdd6bac43016_Out_2);
            float _Multiply_d7b4a7d866dc4499bcce78b7413ecdaf_Out_2;
            Unity_Multiply_float(_Multiply_4cd3f1e051334674922cbdd6bac43016_Out_2, -1, _Multiply_d7b4a7d866dc4499bcce78b7413ecdaf_Out_2);
            float _Exponential_b30cb0ce689a40c2adbff0be2a284c8e_Out_1;
            Unity_Exponential2_float(_Multiply_d7b4a7d866dc4499bcce78b7413ecdaf_Out_2, _Exponential_b30cb0ce689a40c2adbff0be2a284c8e_Out_1);
            float4 _Lerp_2a125fbc6ac74fb985070aeec072184f_Out_3;
            Unity_Lerp_float4(_Fog_49ed9f88320e414eaba21e255c409f00_Color_0, _Property_32d916c6e755465daa887bbd4e2b5b71_Out_0, (_Exponential_b30cb0ce689a40c2adbff0be2a284c8e_Out_1.xxxx), _Lerp_2a125fbc6ac74fb985070aeec072184f_Out_3);
            OutVector4_1 = _Lerp_2a125fbc6ac74fb985070aeec072184f_Out_3;
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
            float _Property_bd8692f2269b46f9bb51baec29544eb8_Out_0 = _UseVertexAnim;
            float _Property_58dfd506237745ee81995750264a1391_Out_0 = _OverallAnimation;
            UnityTexture2D _Property_281f49666eb046f7b650c1ed0901aab8_Out_0 = UnityBuildTexture2DStructNoScale(_AnimationMap);
            float _Property_b3be701ab9824b96b20aafdabba586bb_Out_0 = _WindSpeed;
            float _Property_b0151120e3e648548937c3426af171e4_Out_0 = _WindScale;
            float3 _Property_7684280ab52d4764836240d13e419c3b_Out_0 = _OffsetAnimation;
            Bindings_SGVertexAnimationWNoise_4199d1a917d244c44999767de42e7135 _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a;
            _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a.ObjectSpacePosition = IN.ObjectSpacePosition;
            _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a.WorldSpacePosition = IN.WorldSpacePosition;
            _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a.VertexColor = IN.VertexColor;
            _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a.TimeParameters = IN.TimeParameters;
            float3 _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a_OutVector4_1;
            SG_SGVertexAnimationWNoise_4199d1a917d244c44999767de42e7135(_Property_bd8692f2269b46f9bb51baec29544eb8_Out_0, _Property_58dfd506237745ee81995750264a1391_Out_0, _Property_281f49666eb046f7b650c1ed0901aab8_Out_0, _Property_b3be701ab9824b96b20aafdabba586bb_Out_0, _Property_b0151120e3e648548937c3426af171e4_Out_0, _Property_7684280ab52d4764836240d13e419c3b_Out_0, _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a, _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a_OutVector4_1);
            description.Position = _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a_OutVector4_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            Bindings_SGMainFullLight_060327f1397593a4f85103bc6c969728 _SGMainFullLight_524dd44842f848cbaad57c1ecdc3d010;
            half3 _SGMainFullLight_524dd44842f848cbaad57c1ecdc3d010_LightDirection_1;
            half3 _SGMainFullLight_524dd44842f848cbaad57c1ecdc3d010_LightColor_2;
            half _SGMainFullLight_524dd44842f848cbaad57c1ecdc3d010_LightDistanceAtten_3;
            half _SGMainFullLight_524dd44842f848cbaad57c1ecdc3d010_LightShadowAtten_4;
            SG_SGMainFullLight_060327f1397593a4f85103bc6c969728(IN.WorldSpacePosition, _SGMainFullLight_524dd44842f848cbaad57c1ecdc3d010, _SGMainFullLight_524dd44842f848cbaad57c1ecdc3d010_LightDirection_1, _SGMainFullLight_524dd44842f848cbaad57c1ecdc3d010_LightColor_2, _SGMainFullLight_524dd44842f848cbaad57c1ecdc3d010_LightDistanceAtten_3, _SGMainFullLight_524dd44842f848cbaad57c1ecdc3d010_LightShadowAtten_4);
            float _DotProduct_faf2f53c7b154c019b04863dfec43cf8_Out_2;
            Unity_DotProduct_float3(IN.WorldSpaceNormal, _SGMainFullLight_524dd44842f848cbaad57c1ecdc3d010_LightDirection_1, _DotProduct_faf2f53c7b154c019b04863dfec43cf8_Out_2);
            float _Float_bc0ff8a9e7d8470f9314ff9da54e0c18_Out_0 = 0.5;
            float _Add_2d4f1d31b9274ce5b1cf7e724f2259e9_Out_2;
            Unity_Add_float(_DotProduct_faf2f53c7b154c019b04863dfec43cf8_Out_2, _Float_bc0ff8a9e7d8470f9314ff9da54e0c18_Out_0, _Add_2d4f1d31b9274ce5b1cf7e724f2259e9_Out_2);
            float _Saturate_6a678025bada4dcfb3433ac692e68b1e_Out_1;
            Unity_Saturate_float(_Add_2d4f1d31b9274ce5b1cf7e724f2259e9_Out_2, _Saturate_6a678025bada4dcfb3433ac692e68b1e_Out_1);
            float _Preview_b88ccccad6f24400a20932472ec4104e_Out_1;
            Unity_Preview_float(_SGMainFullLight_524dd44842f848cbaad57c1ecdc3d010_LightShadowAtten_4, _Preview_b88ccccad6f24400a20932472ec4104e_Out_1);
            float _Multiply_f7b1442f53fd4bcebcad42e3badebc99_Out_2;
            Unity_Multiply_float(_Saturate_6a678025bada4dcfb3433ac692e68b1e_Out_1, _Preview_b88ccccad6f24400a20932472ec4104e_Out_1, _Multiply_f7b1442f53fd4bcebcad42e3badebc99_Out_2);
            float _Float_faa8352d193f43a79c030e4d4dd8de98_Out_0 = 0.1;
            Bindings_SGAmbient_e13fbf63d7907af4ab4988492ac7bca8 _SGAmbient_6eb5d551e4bf4fdd86d2c21e24ee5dcc;
            _SGAmbient_6eb5d551e4bf4fdd86d2c21e24ee5dcc.WorldSpaceNormal = IN.WorldSpaceNormal;
            float3 _SGAmbient_6eb5d551e4bf4fdd86d2c21e24ee5dcc_Ambient_1;
            SG_SGAmbient_e13fbf63d7907af4ab4988492ac7bca8(1, _SGAmbient_6eb5d551e4bf4fdd86d2c21e24ee5dcc, _SGAmbient_6eb5d551e4bf4fdd86d2c21e24ee5dcc_Ambient_1);
            float3 _Multiply_848468f0fd8e4ce9887566e7ebacb9e8_Out_2;
            Unity_Multiply_float((_Float_faa8352d193f43a79c030e4d4dd8de98_Out_0.xxx), _SGAmbient_6eb5d551e4bf4fdd86d2c21e24ee5dcc_Ambient_1, _Multiply_848468f0fd8e4ce9887566e7ebacb9e8_Out_2);
            float3 _Add_2c8ba43afbf94ea68652b6d11d3c216c_Out_2;
            Unity_Add_float3((_Multiply_f7b1442f53fd4bcebcad42e3badebc99_Out_2.xxx), _Multiply_848468f0fd8e4ce9887566e7ebacb9e8_Out_2, _Add_2c8ba43afbf94ea68652b6d11d3c216c_Out_2);
            UnityTexture2D _Property_3d22ecc8b6ac4214a1e4858e276d14ef_Out_0 = UnityBuildTexture2DStructNoScale(_FoamMap);
            float2 _Property_52e6c19998d94f34b63272a460bf426a_Out_0 = _Tilling;
            float _Split_9a4c0f80a04c4be19d184de5e253d4b9_R_1 = _Property_52e6c19998d94f34b63272a460bf426a_Out_0[0];
            float _Split_9a4c0f80a04c4be19d184de5e253d4b9_G_2 = _Property_52e6c19998d94f34b63272a460bf426a_Out_0[1];
            float _Split_9a4c0f80a04c4be19d184de5e253d4b9_B_3 = 0;
            float _Split_9a4c0f80a04c4be19d184de5e253d4b9_A_4 = 0;
            float _Property_624a7a01ec774525af237641932562a8_Out_0 = _FoamSpeed;
            float _Multiply_a62e1d5019764bfc9d130966a7f0b1a2_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_624a7a01ec774525af237641932562a8_Out_0, _Multiply_a62e1d5019764bfc9d130966a7f0b1a2_Out_2);
            float4 _Combine_8cce449a474d443884d72d821b5b5f1b_RGBA_4;
            float3 _Combine_8cce449a474d443884d72d821b5b5f1b_RGB_5;
            float2 _Combine_8cce449a474d443884d72d821b5b5f1b_RG_6;
            Unity_Combine_float(_Split_9a4c0f80a04c4be19d184de5e253d4b9_R_1, _Split_9a4c0f80a04c4be19d184de5e253d4b9_G_2, _Multiply_a62e1d5019764bfc9d130966a7f0b1a2_Out_2, 0, _Combine_8cce449a474d443884d72d821b5b5f1b_RGBA_4, _Combine_8cce449a474d443884d72d821b5b5f1b_RGB_5, _Combine_8cce449a474d443884d72d821b5b5f1b_RG_6);
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b;
            _SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b.uv0 = IN.uv0;
            float4 _SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Combine_8cce449a474d443884d72d821b5b5f1b_RGBA_4, _SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b, _SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b_OutVector2_1);
            float4 _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3d22ecc8b6ac4214a1e4858e276d14ef_Out_0.tex, _Property_3d22ecc8b6ac4214a1e4858e276d14ef_Out_0.samplerstate, (_SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b_OutVector2_1.xy));
            float _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_R_4 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0.r;
            float _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_G_5 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0.g;
            float _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_B_6 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0.b;
            float _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_A_7 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0.a;
            float _Split_8c21059e59f84924aab76b886b85cc12_R_1 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0[0];
            float _Split_8c21059e59f84924aab76b886b85cc12_G_2 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0[1];
            float _Split_8c21059e59f84924aab76b886b85cc12_B_3 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0[2];
            float _Split_8c21059e59f84924aab76b886b85cc12_A_4 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0[3];
            float4 _Property_a54954a9257442708a87854c57e5cd40_Out_0 = _FoamColor;
            float4 _Multiply_1ea5697e964c47c68208dc1cc9d14a5a_Out_2;
            Unity_Multiply_float((_Split_8c21059e59f84924aab76b886b85cc12_R_1.xxxx), _Property_a54954a9257442708a87854c57e5cd40_Out_0, _Multiply_1ea5697e964c47c68208dc1cc9d14a5a_Out_2);
            float4 _Property_b83ded0d0d8b41c388bc25052acdbd5b_Out_0 = _MainColor;
            float4 _UV_b6c67e8e92814cae8e03697cb60a6272_Out_0 = IN.uv0;
            float _Split_bb33969032a741839f8c299973e1d678_R_1 = _UV_b6c67e8e92814cae8e03697cb60a6272_Out_0[0];
            float _Split_bb33969032a741839f8c299973e1d678_G_2 = _UV_b6c67e8e92814cae8e03697cb60a6272_Out_0[1];
            float _Split_bb33969032a741839f8c299973e1d678_B_3 = _UV_b6c67e8e92814cae8e03697cb60a6272_Out_0[2];
            float _Split_bb33969032a741839f8c299973e1d678_A_4 = _UV_b6c67e8e92814cae8e03697cb60a6272_Out_0[3];
            float _OneMinus_de9bf5b5ab48485cb022186ac17c137b_Out_1;
            Unity_OneMinus_float(_Split_bb33969032a741839f8c299973e1d678_R_1, _OneMinus_de9bf5b5ab48485cb022186ac17c137b_Out_1);
            float _Absolute_1c89289ffd084866b36b593d3d8ed4ba_Out_1;
            Unity_Absolute_float(_OneMinus_de9bf5b5ab48485cb022186ac17c137b_Out_1, _Absolute_1c89289ffd084866b36b593d3d8ed4ba_Out_1);
            float _Property_a4f821186403487894d4b2791bcca865_Out_0 = _FoamPower;
            float _Power_f128e45538cf4da4af63390f7c452b6f_Out_2;
            Unity_Power_float(_Absolute_1c89289ffd084866b36b593d3d8ed4ba_Out_1, _Property_a4f821186403487894d4b2791bcca865_Out_0, _Power_f128e45538cf4da4af63390f7c452b6f_Out_2);
            float4 _Multiply_d1e37f6f3b754767a3f3612d4a51b227_Out_2;
            Unity_Multiply_float(_Property_b83ded0d0d8b41c388bc25052acdbd5b_Out_0, (_Power_f128e45538cf4da4af63390f7c452b6f_Out_2.xxxx), _Multiply_d1e37f6f3b754767a3f3612d4a51b227_Out_2);
            float4 _Add_d9ba7bfe6aac45fab36724a2514dd461_Out_2;
            Unity_Add_float4(_Multiply_1ea5697e964c47c68208dc1cc9d14a5a_Out_2, _Multiply_d1e37f6f3b754767a3f3612d4a51b227_Out_2, _Add_d9ba7bfe6aac45fab36724a2514dd461_Out_2);
            float3 _Multiply_dec09595e67d4d4db0da401c56eec17e_Out_2;
            Unity_Multiply_float(_Add_2c8ba43afbf94ea68652b6d11d3c216c_Out_2, (_Add_d9ba7bfe6aac45fab36724a2514dd461_Out_2.xyz), _Multiply_dec09595e67d4d4db0da401c56eec17e_Out_2);
            Bindings_SGFog_6fda06a5a255f8244a0881200c0efc1c _SGFog_17285ca0e89f4cf98dc01bbdda30cf3a;
            _SGFog_17285ca0e89f4cf98dc01bbdda30cf3a.ObjectSpacePosition = IN.ObjectSpacePosition;
            float4 _SGFog_17285ca0e89f4cf98dc01bbdda30cf3a_OutVector4_1;
            SG_SGFog_6fda06a5a255f8244a0881200c0efc1c((float4(_Multiply_dec09595e67d4d4db0da401c56eec17e_Out_2, 1.0)), _SGFog_17285ca0e89f4cf98dc01bbdda30cf3a, _SGFog_17285ca0e89f4cf98dc01bbdda30cf3a_OutVector4_1);
            float4 _Multiply_7833484a516b42ed9e0f53c9b6ce2749_Out_2;
            Unity_Multiply_float(_Multiply_1ea5697e964c47c68208dc1cc9d14a5a_Out_2, (_Power_f128e45538cf4da4af63390f7c452b6f_Out_2.xxxx), _Multiply_7833484a516b42ed9e0f53c9b6ce2749_Out_2);
            float4 _Add_53eae0f97ea041caaa38fa99af6ecce4_Out_2;
            Unity_Add_float4(_Multiply_7833484a516b42ed9e0f53c9b6ce2749_Out_2, (_Power_f128e45538cf4da4af63390f7c452b6f_Out_2.xxxx), _Add_53eae0f97ea041caaa38fa99af6ecce4_Out_2);
            surface.BaseColor = (_SGFog_17285ca0e89f4cf98dc01bbdda30cf3a_OutVector4_1.xyz);
            surface.Alpha = (_Add_53eae0f97ea041caaa38fa99af6ecce4_Out_2).x;
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
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.VertexColor =                 input.color;
            output.TimeParameters =              _TimeParameters.xyz;

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


            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
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
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

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
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
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
            float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
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
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 VertexColor;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
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
            output.interp0.xyzw =  input.texCoord0;
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
            output.texCoord0 = input.interp0.xyzw;
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
        float4 _MainColor;
        float4 _FoamColor;
        float4 _FoamMap_TexelSize;
        float2 _Tilling;
        float _FoamPower;
        float _FoamSpeed;
        float _UseVertexAnim;
        float _OverallAnimation;
        float4 _AnimationMap_TexelSize;
        float _WindSpeed;
        float _WindScale;
        float3 _OffsetAnimation;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FoamMap);
        SAMPLER(sampler_FoamMap);
        TEXTURE2D(_AnimationMap);
        SAMPLER(sampler_AnimationMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }

        struct Bindings_SGVertexAnimationWNoise_4199d1a917d244c44999767de42e7135
        {
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 VertexColor;
            float3 TimeParameters;
        };

        void SG_SGVertexAnimationWNoise_4199d1a917d244c44999767de42e7135(float Boolean_e159330812d24512a3f1203f94de3ddb, float Vector1_a073e91b7fa248d1be392701d8074de3, UnityTexture2D Texture2D_3abc34d6da8e4d2bae3d4056180cc14b, float Vector1_c207ca6102ad4bd1a8c13305b12c30ea, float Vector1_a242c1bedc2941d9b14d53f6bf951fc1, float3 Vector3_5b064d9257f14241a138dd7cb764f536, Bindings_SGVertexAnimationWNoise_4199d1a917d244c44999767de42e7135 IN, out float3 Out_Vector4_1)
        {
            float _Property_cb3d9520c2d245589054bf586f6532e0_Out_0 = Boolean_e159330812d24512a3f1203f94de3ddb;
            float _Property_9aa2019db5244d0c9112d41b9e2e4cbb_Out_0 = Vector1_a073e91b7fa248d1be392701d8074de3;
            float4 _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2;
            Unity_Multiply_float((_Property_9aa2019db5244d0c9112d41b9e2e4cbb_Out_0.xxxx), IN.VertexColor, _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2);
            float _Split_76b24236ba82479c9ee96e6bff99fffb_R_1 = _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2[0];
            float _Split_76b24236ba82479c9ee96e6bff99fffb_G_2 = _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2[1];
            float _Split_76b24236ba82479c9ee96e6bff99fffb_B_3 = _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2[2];
            float _Split_76b24236ba82479c9ee96e6bff99fffb_A_4 = _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2[3];
            UnityTexture2D _Property_c8b150e89fd946f0827c36e9e5ff3cc4_Out_0 = Texture2D_3abc34d6da8e4d2bae3d4056180cc14b;
            float _Property_6ebbdb482ef245059f2e80b17b53a426_Out_0 = Vector1_a242c1bedc2941d9b14d53f6bf951fc1;
            float _Split_35f7f2b53bae47aba08116df940a039b_R_1 = IN.WorldSpacePosition[0];
            float _Split_35f7f2b53bae47aba08116df940a039b_G_2 = IN.WorldSpacePosition[1];
            float _Split_35f7f2b53bae47aba08116df940a039b_B_3 = IN.WorldSpacePosition[2];
            float _Split_35f7f2b53bae47aba08116df940a039b_A_4 = 0;
            float _Property_0ac822f99f9d4a298d1f207bd97053f6_Out_0 = Vector1_c207ca6102ad4bd1a8c13305b12c30ea;
            float _Multiply_caa06c3372364a2b8173f6d8618c9f6d_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_0ac822f99f9d4a298d1f207bd97053f6_Out_0, _Multiply_caa06c3372364a2b8173f6d8618c9f6d_Out_2);
            float _Add_db0a3678fb5f46d387dca5a7664ae4a7_Out_2;
            Unity_Add_float(_Split_35f7f2b53bae47aba08116df940a039b_R_1, _Multiply_caa06c3372364a2b8173f6d8618c9f6d_Out_2, _Add_db0a3678fb5f46d387dca5a7664ae4a7_Out_2);
            float _Add_0da3ac7f1b114ef6a7531947a2ff75b7_Out_2;
            Unity_Add_float(_Split_35f7f2b53bae47aba08116df940a039b_B_3, _Multiply_caa06c3372364a2b8173f6d8618c9f6d_Out_2, _Add_0da3ac7f1b114ef6a7531947a2ff75b7_Out_2);
            float2 _Vector2_e2b98d36b5fc4a4e8fafb96dab2f7c3b_Out_0 = float2(_Add_db0a3678fb5f46d387dca5a7664ae4a7_Out_2, _Add_0da3ac7f1b114ef6a7531947a2ff75b7_Out_2);
            float2 _Multiply_88a0b4289e5941f08b03958867ca5d3f_Out_2;
            Unity_Multiply_float((_Property_6ebbdb482ef245059f2e80b17b53a426_Out_0.xx), _Vector2_e2b98d36b5fc4a4e8fafb96dab2f7c3b_Out_0, _Multiply_88a0b4289e5941f08b03958867ca5d3f_Out_2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_c8b150e89fd946f0827c36e9e5ff3cc4_Out_0.tex, _Property_c8b150e89fd946f0827c36e9e5ff3cc4_Out_0.samplerstate, _Multiply_88a0b4289e5941f08b03958867ca5d3f_Out_2, 0);
            #endif
            float _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_R_5 = _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0.r;
            float _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_G_6 = _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0.g;
            float _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_B_7 = _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0.b;
            float _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_A_8 = _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0.a;
            float _Multiply_fd0db81808444ce59b035aa8b097d80d_Out_2;
            Unity_Multiply_float(_Split_76b24236ba82479c9ee96e6bff99fffb_G_2, _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_R_5, _Multiply_fd0db81808444ce59b035aa8b097d80d_Out_2);
            float _Split_3b5205c8bdda4576821e61c6dcf6836b_R_1 = IN.ObjectSpacePosition[0];
            float _Split_3b5205c8bdda4576821e61c6dcf6836b_G_2 = IN.ObjectSpacePosition[1];
            float _Split_3b5205c8bdda4576821e61c6dcf6836b_B_3 = IN.ObjectSpacePosition[2];
            float _Split_3b5205c8bdda4576821e61c6dcf6836b_A_4 = 0;
            float _Add_a5623a7a143444b987c1ce767efca3c0_Out_2;
            Unity_Add_float(_Multiply_fd0db81808444ce59b035aa8b097d80d_Out_2, _Split_3b5205c8bdda4576821e61c6dcf6836b_R_1, _Add_a5623a7a143444b987c1ce767efca3c0_Out_2);
            float _Multiply_4aae774466ec4a65acd3caed8a20e169_Out_2;
            Unity_Multiply_float(_Split_76b24236ba82479c9ee96e6bff99fffb_G_2, _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_R_5, _Multiply_4aae774466ec4a65acd3caed8a20e169_Out_2);
            float _Add_b905575f5f474b5996309ea150d9a735_Out_2;
            Unity_Add_float(_Split_3b5205c8bdda4576821e61c6dcf6836b_B_3, _Multiply_4aae774466ec4a65acd3caed8a20e169_Out_2, _Add_b905575f5f474b5996309ea150d9a735_Out_2);
            float4 _Combine_a61702d97880410ab247673aa15bb24b_RGBA_4;
            float3 _Combine_a61702d97880410ab247673aa15bb24b_RGB_5;
            float2 _Combine_a61702d97880410ab247673aa15bb24b_RG_6;
            Unity_Combine_float(_Add_a5623a7a143444b987c1ce767efca3c0_Out_2, _Split_3b5205c8bdda4576821e61c6dcf6836b_G_2, _Add_b905575f5f474b5996309ea150d9a735_Out_2, 0, _Combine_a61702d97880410ab247673aa15bb24b_RGBA_4, _Combine_a61702d97880410ab247673aa15bb24b_RGB_5, _Combine_a61702d97880410ab247673aa15bb24b_RG_6);
            float3 _Property_8917cb38b5a44e8ba5a317fdf91e0251_Out_0 = Vector3_5b064d9257f14241a138dd7cb764f536;
            float3 _Subtract_e7baaf5c449042bf96eb6e95e60fc0f8_Out_2;
            Unity_Subtract_float3(_Combine_a61702d97880410ab247673aa15bb24b_RGB_5, _Property_8917cb38b5a44e8ba5a317fdf91e0251_Out_0, _Subtract_e7baaf5c449042bf96eb6e95e60fc0f8_Out_2);
            float3 _Branch_b8453590d5e5418d866e303e4bbae174_Out_3;
            Unity_Branch_float3(_Property_cb3d9520c2d245589054bf586f6532e0_Out_0, _Subtract_e7baaf5c449042bf96eb6e95e60fc0f8_Out_2, IN.ObjectSpacePosition, _Branch_b8453590d5e5418d866e303e4bbae174_Out_3);
            Out_Vector4_1 = _Branch_b8453590d5e5418d866e303e4bbae174_Out_3;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        struct Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8
        {
            half4 uv0;
        };

        void SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(float4 Vector4_2F6A811A, Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 IN, out float4 Out_Vector2_1)
        {
            float4 _Property_617a4d2ce8938583a2fc0f5865f6d6d7_Out_0 = Vector4_2F6A811A;
            float _Split_111abdeb95a33f8585d7ec4c8193134b_R_1 = _Property_617a4d2ce8938583a2fc0f5865f6d6d7_Out_0[0];
            float _Split_111abdeb95a33f8585d7ec4c8193134b_G_2 = _Property_617a4d2ce8938583a2fc0f5865f6d6d7_Out_0[1];
            float _Split_111abdeb95a33f8585d7ec4c8193134b_B_3 = _Property_617a4d2ce8938583a2fc0f5865f6d6d7_Out_0[2];
            float _Split_111abdeb95a33f8585d7ec4c8193134b_A_4 = _Property_617a4d2ce8938583a2fc0f5865f6d6d7_Out_0[3];
            float2 _Vector2_84d21e7b137fe28bb95ba0383bff379a_Out_0 = float2(_Split_111abdeb95a33f8585d7ec4c8193134b_R_1, _Split_111abdeb95a33f8585d7ec4c8193134b_G_2);
            float2 _Vector2_1571655971098b83bd6db78da85f5d08_Out_0 = float2(_Split_111abdeb95a33f8585d7ec4c8193134b_B_3, _Split_111abdeb95a33f8585d7ec4c8193134b_A_4);
            float2 _TilingAndOffset_54f7abf9415578879df48d2c8bec8335_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_84d21e7b137fe28bb95ba0383bff379a_Out_0, _Vector2_1571655971098b83bd6db78da85f5d08_Out_0, _TilingAndOffset_54f7abf9415578879df48d2c8bec8335_Out_3);
            Out_Vector2_1 = (float4(_TilingAndOffset_54f7abf9415578879df48d2c8bec8335_Out_3, 0.0, 1.0));
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
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
            float _Property_bd8692f2269b46f9bb51baec29544eb8_Out_0 = _UseVertexAnim;
            float _Property_58dfd506237745ee81995750264a1391_Out_0 = _OverallAnimation;
            UnityTexture2D _Property_281f49666eb046f7b650c1ed0901aab8_Out_0 = UnityBuildTexture2DStructNoScale(_AnimationMap);
            float _Property_b3be701ab9824b96b20aafdabba586bb_Out_0 = _WindSpeed;
            float _Property_b0151120e3e648548937c3426af171e4_Out_0 = _WindScale;
            float3 _Property_7684280ab52d4764836240d13e419c3b_Out_0 = _OffsetAnimation;
            Bindings_SGVertexAnimationWNoise_4199d1a917d244c44999767de42e7135 _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a;
            _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a.ObjectSpacePosition = IN.ObjectSpacePosition;
            _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a.WorldSpacePosition = IN.WorldSpacePosition;
            _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a.VertexColor = IN.VertexColor;
            _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a.TimeParameters = IN.TimeParameters;
            float3 _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a_OutVector4_1;
            SG_SGVertexAnimationWNoise_4199d1a917d244c44999767de42e7135(_Property_bd8692f2269b46f9bb51baec29544eb8_Out_0, _Property_58dfd506237745ee81995750264a1391_Out_0, _Property_281f49666eb046f7b650c1ed0901aab8_Out_0, _Property_b3be701ab9824b96b20aafdabba586bb_Out_0, _Property_b0151120e3e648548937c3426af171e4_Out_0, _Property_7684280ab52d4764836240d13e419c3b_Out_0, _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a, _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a_OutVector4_1);
            description.Position = _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a_OutVector4_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_3d22ecc8b6ac4214a1e4858e276d14ef_Out_0 = UnityBuildTexture2DStructNoScale(_FoamMap);
            float2 _Property_52e6c19998d94f34b63272a460bf426a_Out_0 = _Tilling;
            float _Split_9a4c0f80a04c4be19d184de5e253d4b9_R_1 = _Property_52e6c19998d94f34b63272a460bf426a_Out_0[0];
            float _Split_9a4c0f80a04c4be19d184de5e253d4b9_G_2 = _Property_52e6c19998d94f34b63272a460bf426a_Out_0[1];
            float _Split_9a4c0f80a04c4be19d184de5e253d4b9_B_3 = 0;
            float _Split_9a4c0f80a04c4be19d184de5e253d4b9_A_4 = 0;
            float _Property_624a7a01ec774525af237641932562a8_Out_0 = _FoamSpeed;
            float _Multiply_a62e1d5019764bfc9d130966a7f0b1a2_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_624a7a01ec774525af237641932562a8_Out_0, _Multiply_a62e1d5019764bfc9d130966a7f0b1a2_Out_2);
            float4 _Combine_8cce449a474d443884d72d821b5b5f1b_RGBA_4;
            float3 _Combine_8cce449a474d443884d72d821b5b5f1b_RGB_5;
            float2 _Combine_8cce449a474d443884d72d821b5b5f1b_RG_6;
            Unity_Combine_float(_Split_9a4c0f80a04c4be19d184de5e253d4b9_R_1, _Split_9a4c0f80a04c4be19d184de5e253d4b9_G_2, _Multiply_a62e1d5019764bfc9d130966a7f0b1a2_Out_2, 0, _Combine_8cce449a474d443884d72d821b5b5f1b_RGBA_4, _Combine_8cce449a474d443884d72d821b5b5f1b_RGB_5, _Combine_8cce449a474d443884d72d821b5b5f1b_RG_6);
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b;
            _SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b.uv0 = IN.uv0;
            float4 _SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Combine_8cce449a474d443884d72d821b5b5f1b_RGBA_4, _SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b, _SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b_OutVector2_1);
            float4 _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3d22ecc8b6ac4214a1e4858e276d14ef_Out_0.tex, _Property_3d22ecc8b6ac4214a1e4858e276d14ef_Out_0.samplerstate, (_SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b_OutVector2_1.xy));
            float _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_R_4 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0.r;
            float _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_G_5 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0.g;
            float _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_B_6 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0.b;
            float _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_A_7 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0.a;
            float _Split_8c21059e59f84924aab76b886b85cc12_R_1 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0[0];
            float _Split_8c21059e59f84924aab76b886b85cc12_G_2 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0[1];
            float _Split_8c21059e59f84924aab76b886b85cc12_B_3 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0[2];
            float _Split_8c21059e59f84924aab76b886b85cc12_A_4 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0[3];
            float4 _Property_a54954a9257442708a87854c57e5cd40_Out_0 = _FoamColor;
            float4 _Multiply_1ea5697e964c47c68208dc1cc9d14a5a_Out_2;
            Unity_Multiply_float((_Split_8c21059e59f84924aab76b886b85cc12_R_1.xxxx), _Property_a54954a9257442708a87854c57e5cd40_Out_0, _Multiply_1ea5697e964c47c68208dc1cc9d14a5a_Out_2);
            float4 _UV_b6c67e8e92814cae8e03697cb60a6272_Out_0 = IN.uv0;
            float _Split_bb33969032a741839f8c299973e1d678_R_1 = _UV_b6c67e8e92814cae8e03697cb60a6272_Out_0[0];
            float _Split_bb33969032a741839f8c299973e1d678_G_2 = _UV_b6c67e8e92814cae8e03697cb60a6272_Out_0[1];
            float _Split_bb33969032a741839f8c299973e1d678_B_3 = _UV_b6c67e8e92814cae8e03697cb60a6272_Out_0[2];
            float _Split_bb33969032a741839f8c299973e1d678_A_4 = _UV_b6c67e8e92814cae8e03697cb60a6272_Out_0[3];
            float _OneMinus_de9bf5b5ab48485cb022186ac17c137b_Out_1;
            Unity_OneMinus_float(_Split_bb33969032a741839f8c299973e1d678_R_1, _OneMinus_de9bf5b5ab48485cb022186ac17c137b_Out_1);
            float _Absolute_1c89289ffd084866b36b593d3d8ed4ba_Out_1;
            Unity_Absolute_float(_OneMinus_de9bf5b5ab48485cb022186ac17c137b_Out_1, _Absolute_1c89289ffd084866b36b593d3d8ed4ba_Out_1);
            float _Property_a4f821186403487894d4b2791bcca865_Out_0 = _FoamPower;
            float _Power_f128e45538cf4da4af63390f7c452b6f_Out_2;
            Unity_Power_float(_Absolute_1c89289ffd084866b36b593d3d8ed4ba_Out_1, _Property_a4f821186403487894d4b2791bcca865_Out_0, _Power_f128e45538cf4da4af63390f7c452b6f_Out_2);
            float4 _Multiply_7833484a516b42ed9e0f53c9b6ce2749_Out_2;
            Unity_Multiply_float(_Multiply_1ea5697e964c47c68208dc1cc9d14a5a_Out_2, (_Power_f128e45538cf4da4af63390f7c452b6f_Out_2.xxxx), _Multiply_7833484a516b42ed9e0f53c9b6ce2749_Out_2);
            float4 _Add_53eae0f97ea041caaa38fa99af6ecce4_Out_2;
            Unity_Add_float4(_Multiply_7833484a516b42ed9e0f53c9b6ce2749_Out_2, (_Power_f128e45538cf4da4af63390f7c452b6f_Out_2.xxxx), _Add_53eae0f97ea041caaa38fa99af6ecce4_Out_2);
            surface.Alpha = (_Add_53eae0f97ea041caaa38fa99af6ecce4_Out_2).x;
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
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.VertexColor =                 input.color;
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





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
            Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
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
            float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
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
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 VertexColor;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float4 interp0 : TEXCOORD0;
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
            output.interp0.xyzw =  input.texCoord0;
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
            output.texCoord0 = input.interp0.xyzw;
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
        float4 _MainColor;
        float4 _FoamColor;
        float4 _FoamMap_TexelSize;
        float2 _Tilling;
        float _FoamPower;
        float _FoamSpeed;
        float _UseVertexAnim;
        float _OverallAnimation;
        float4 _AnimationMap_TexelSize;
        float _WindSpeed;
        float _WindScale;
        float3 _OffsetAnimation;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_FoamMap);
        SAMPLER(sampler_FoamMap);
        TEXTURE2D(_AnimationMap);
        SAMPLER(sampler_AnimationMap);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_Branch_float3(float Predicate, float3 True, float3 False, out float3 Out)
        {
            Out = Predicate ? True : False;
        }

        struct Bindings_SGVertexAnimationWNoise_4199d1a917d244c44999767de42e7135
        {
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 VertexColor;
            float3 TimeParameters;
        };

        void SG_SGVertexAnimationWNoise_4199d1a917d244c44999767de42e7135(float Boolean_e159330812d24512a3f1203f94de3ddb, float Vector1_a073e91b7fa248d1be392701d8074de3, UnityTexture2D Texture2D_3abc34d6da8e4d2bae3d4056180cc14b, float Vector1_c207ca6102ad4bd1a8c13305b12c30ea, float Vector1_a242c1bedc2941d9b14d53f6bf951fc1, float3 Vector3_5b064d9257f14241a138dd7cb764f536, Bindings_SGVertexAnimationWNoise_4199d1a917d244c44999767de42e7135 IN, out float3 Out_Vector4_1)
        {
            float _Property_cb3d9520c2d245589054bf586f6532e0_Out_0 = Boolean_e159330812d24512a3f1203f94de3ddb;
            float _Property_9aa2019db5244d0c9112d41b9e2e4cbb_Out_0 = Vector1_a073e91b7fa248d1be392701d8074de3;
            float4 _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2;
            Unity_Multiply_float((_Property_9aa2019db5244d0c9112d41b9e2e4cbb_Out_0.xxxx), IN.VertexColor, _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2);
            float _Split_76b24236ba82479c9ee96e6bff99fffb_R_1 = _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2[0];
            float _Split_76b24236ba82479c9ee96e6bff99fffb_G_2 = _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2[1];
            float _Split_76b24236ba82479c9ee96e6bff99fffb_B_3 = _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2[2];
            float _Split_76b24236ba82479c9ee96e6bff99fffb_A_4 = _Multiply_8797c08d82b64dfba09c030dd9cd26d0_Out_2[3];
            UnityTexture2D _Property_c8b150e89fd946f0827c36e9e5ff3cc4_Out_0 = Texture2D_3abc34d6da8e4d2bae3d4056180cc14b;
            float _Property_6ebbdb482ef245059f2e80b17b53a426_Out_0 = Vector1_a242c1bedc2941d9b14d53f6bf951fc1;
            float _Split_35f7f2b53bae47aba08116df940a039b_R_1 = IN.WorldSpacePosition[0];
            float _Split_35f7f2b53bae47aba08116df940a039b_G_2 = IN.WorldSpacePosition[1];
            float _Split_35f7f2b53bae47aba08116df940a039b_B_3 = IN.WorldSpacePosition[2];
            float _Split_35f7f2b53bae47aba08116df940a039b_A_4 = 0;
            float _Property_0ac822f99f9d4a298d1f207bd97053f6_Out_0 = Vector1_c207ca6102ad4bd1a8c13305b12c30ea;
            float _Multiply_caa06c3372364a2b8173f6d8618c9f6d_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_0ac822f99f9d4a298d1f207bd97053f6_Out_0, _Multiply_caa06c3372364a2b8173f6d8618c9f6d_Out_2);
            float _Add_db0a3678fb5f46d387dca5a7664ae4a7_Out_2;
            Unity_Add_float(_Split_35f7f2b53bae47aba08116df940a039b_R_1, _Multiply_caa06c3372364a2b8173f6d8618c9f6d_Out_2, _Add_db0a3678fb5f46d387dca5a7664ae4a7_Out_2);
            float _Add_0da3ac7f1b114ef6a7531947a2ff75b7_Out_2;
            Unity_Add_float(_Split_35f7f2b53bae47aba08116df940a039b_B_3, _Multiply_caa06c3372364a2b8173f6d8618c9f6d_Out_2, _Add_0da3ac7f1b114ef6a7531947a2ff75b7_Out_2);
            float2 _Vector2_e2b98d36b5fc4a4e8fafb96dab2f7c3b_Out_0 = float2(_Add_db0a3678fb5f46d387dca5a7664ae4a7_Out_2, _Add_0da3ac7f1b114ef6a7531947a2ff75b7_Out_2);
            float2 _Multiply_88a0b4289e5941f08b03958867ca5d3f_Out_2;
            Unity_Multiply_float((_Property_6ebbdb482ef245059f2e80b17b53a426_Out_0.xx), _Vector2_e2b98d36b5fc4a4e8fafb96dab2f7c3b_Out_0, _Multiply_88a0b4289e5941f08b03958867ca5d3f_Out_2);
            #if defined(SHADER_API_GLES) && (SHADER_TARGET < 30)
              float4 _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0 = float4(0.0f, 0.0f, 0.0f, 1.0f);
            #else
              float4 _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0 = SAMPLE_TEXTURE2D_LOD(_Property_c8b150e89fd946f0827c36e9e5ff3cc4_Out_0.tex, _Property_c8b150e89fd946f0827c36e9e5ff3cc4_Out_0.samplerstate, _Multiply_88a0b4289e5941f08b03958867ca5d3f_Out_2, 0);
            #endif
            float _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_R_5 = _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0.r;
            float _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_G_6 = _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0.g;
            float _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_B_7 = _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0.b;
            float _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_A_8 = _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_RGBA_0.a;
            float _Multiply_fd0db81808444ce59b035aa8b097d80d_Out_2;
            Unity_Multiply_float(_Split_76b24236ba82479c9ee96e6bff99fffb_G_2, _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_R_5, _Multiply_fd0db81808444ce59b035aa8b097d80d_Out_2);
            float _Split_3b5205c8bdda4576821e61c6dcf6836b_R_1 = IN.ObjectSpacePosition[0];
            float _Split_3b5205c8bdda4576821e61c6dcf6836b_G_2 = IN.ObjectSpacePosition[1];
            float _Split_3b5205c8bdda4576821e61c6dcf6836b_B_3 = IN.ObjectSpacePosition[2];
            float _Split_3b5205c8bdda4576821e61c6dcf6836b_A_4 = 0;
            float _Add_a5623a7a143444b987c1ce767efca3c0_Out_2;
            Unity_Add_float(_Multiply_fd0db81808444ce59b035aa8b097d80d_Out_2, _Split_3b5205c8bdda4576821e61c6dcf6836b_R_1, _Add_a5623a7a143444b987c1ce767efca3c0_Out_2);
            float _Multiply_4aae774466ec4a65acd3caed8a20e169_Out_2;
            Unity_Multiply_float(_Split_76b24236ba82479c9ee96e6bff99fffb_G_2, _SampleTexture2DLOD_cba4dc5372c444fb936332c8d828fb42_R_5, _Multiply_4aae774466ec4a65acd3caed8a20e169_Out_2);
            float _Add_b905575f5f474b5996309ea150d9a735_Out_2;
            Unity_Add_float(_Split_3b5205c8bdda4576821e61c6dcf6836b_B_3, _Multiply_4aae774466ec4a65acd3caed8a20e169_Out_2, _Add_b905575f5f474b5996309ea150d9a735_Out_2);
            float4 _Combine_a61702d97880410ab247673aa15bb24b_RGBA_4;
            float3 _Combine_a61702d97880410ab247673aa15bb24b_RGB_5;
            float2 _Combine_a61702d97880410ab247673aa15bb24b_RG_6;
            Unity_Combine_float(_Add_a5623a7a143444b987c1ce767efca3c0_Out_2, _Split_3b5205c8bdda4576821e61c6dcf6836b_G_2, _Add_b905575f5f474b5996309ea150d9a735_Out_2, 0, _Combine_a61702d97880410ab247673aa15bb24b_RGBA_4, _Combine_a61702d97880410ab247673aa15bb24b_RGB_5, _Combine_a61702d97880410ab247673aa15bb24b_RG_6);
            float3 _Property_8917cb38b5a44e8ba5a317fdf91e0251_Out_0 = Vector3_5b064d9257f14241a138dd7cb764f536;
            float3 _Subtract_e7baaf5c449042bf96eb6e95e60fc0f8_Out_2;
            Unity_Subtract_float3(_Combine_a61702d97880410ab247673aa15bb24b_RGB_5, _Property_8917cb38b5a44e8ba5a317fdf91e0251_Out_0, _Subtract_e7baaf5c449042bf96eb6e95e60fc0f8_Out_2);
            float3 _Branch_b8453590d5e5418d866e303e4bbae174_Out_3;
            Unity_Branch_float3(_Property_cb3d9520c2d245589054bf586f6532e0_Out_0, _Subtract_e7baaf5c449042bf96eb6e95e60fc0f8_Out_2, IN.ObjectSpacePosition, _Branch_b8453590d5e5418d866e303e4bbae174_Out_3);
            Out_Vector4_1 = _Branch_b8453590d5e5418d866e303e4bbae174_Out_3;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        struct Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8
        {
            half4 uv0;
        };

        void SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(float4 Vector4_2F6A811A, Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 IN, out float4 Out_Vector2_1)
        {
            float4 _Property_617a4d2ce8938583a2fc0f5865f6d6d7_Out_0 = Vector4_2F6A811A;
            float _Split_111abdeb95a33f8585d7ec4c8193134b_R_1 = _Property_617a4d2ce8938583a2fc0f5865f6d6d7_Out_0[0];
            float _Split_111abdeb95a33f8585d7ec4c8193134b_G_2 = _Property_617a4d2ce8938583a2fc0f5865f6d6d7_Out_0[1];
            float _Split_111abdeb95a33f8585d7ec4c8193134b_B_3 = _Property_617a4d2ce8938583a2fc0f5865f6d6d7_Out_0[2];
            float _Split_111abdeb95a33f8585d7ec4c8193134b_A_4 = _Property_617a4d2ce8938583a2fc0f5865f6d6d7_Out_0[3];
            float2 _Vector2_84d21e7b137fe28bb95ba0383bff379a_Out_0 = float2(_Split_111abdeb95a33f8585d7ec4c8193134b_R_1, _Split_111abdeb95a33f8585d7ec4c8193134b_G_2);
            float2 _Vector2_1571655971098b83bd6db78da85f5d08_Out_0 = float2(_Split_111abdeb95a33f8585d7ec4c8193134b_B_3, _Split_111abdeb95a33f8585d7ec4c8193134b_A_4);
            float2 _TilingAndOffset_54f7abf9415578879df48d2c8bec8335_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_84d21e7b137fe28bb95ba0383bff379a_Out_0, _Vector2_1571655971098b83bd6db78da85f5d08_Out_0, _TilingAndOffset_54f7abf9415578879df48d2c8bec8335_Out_3);
            Out_Vector2_1 = (float4(_TilingAndOffset_54f7abf9415578879df48d2c8bec8335_Out_3, 0.0, 1.0));
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
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
            float _Property_bd8692f2269b46f9bb51baec29544eb8_Out_0 = _UseVertexAnim;
            float _Property_58dfd506237745ee81995750264a1391_Out_0 = _OverallAnimation;
            UnityTexture2D _Property_281f49666eb046f7b650c1ed0901aab8_Out_0 = UnityBuildTexture2DStructNoScale(_AnimationMap);
            float _Property_b3be701ab9824b96b20aafdabba586bb_Out_0 = _WindSpeed;
            float _Property_b0151120e3e648548937c3426af171e4_Out_0 = _WindScale;
            float3 _Property_7684280ab52d4764836240d13e419c3b_Out_0 = _OffsetAnimation;
            Bindings_SGVertexAnimationWNoise_4199d1a917d244c44999767de42e7135 _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a;
            _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a.ObjectSpacePosition = IN.ObjectSpacePosition;
            _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a.WorldSpacePosition = IN.WorldSpacePosition;
            _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a.VertexColor = IN.VertexColor;
            _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a.TimeParameters = IN.TimeParameters;
            float3 _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a_OutVector4_1;
            SG_SGVertexAnimationWNoise_4199d1a917d244c44999767de42e7135(_Property_bd8692f2269b46f9bb51baec29544eb8_Out_0, _Property_58dfd506237745ee81995750264a1391_Out_0, _Property_281f49666eb046f7b650c1ed0901aab8_Out_0, _Property_b3be701ab9824b96b20aafdabba586bb_Out_0, _Property_b0151120e3e648548937c3426af171e4_Out_0, _Property_7684280ab52d4764836240d13e419c3b_Out_0, _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a, _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a_OutVector4_1);
            description.Position = _SGVertexAnimationWNoise_4eb52a19711f4f7aa34811f24473f66a_OutVector4_1;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_3d22ecc8b6ac4214a1e4858e276d14ef_Out_0 = UnityBuildTexture2DStructNoScale(_FoamMap);
            float2 _Property_52e6c19998d94f34b63272a460bf426a_Out_0 = _Tilling;
            float _Split_9a4c0f80a04c4be19d184de5e253d4b9_R_1 = _Property_52e6c19998d94f34b63272a460bf426a_Out_0[0];
            float _Split_9a4c0f80a04c4be19d184de5e253d4b9_G_2 = _Property_52e6c19998d94f34b63272a460bf426a_Out_0[1];
            float _Split_9a4c0f80a04c4be19d184de5e253d4b9_B_3 = 0;
            float _Split_9a4c0f80a04c4be19d184de5e253d4b9_A_4 = 0;
            float _Property_624a7a01ec774525af237641932562a8_Out_0 = _FoamSpeed;
            float _Multiply_a62e1d5019764bfc9d130966a7f0b1a2_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_624a7a01ec774525af237641932562a8_Out_0, _Multiply_a62e1d5019764bfc9d130966a7f0b1a2_Out_2);
            float4 _Combine_8cce449a474d443884d72d821b5b5f1b_RGBA_4;
            float3 _Combine_8cce449a474d443884d72d821b5b5f1b_RGB_5;
            float2 _Combine_8cce449a474d443884d72d821b5b5f1b_RG_6;
            Unity_Combine_float(_Split_9a4c0f80a04c4be19d184de5e253d4b9_R_1, _Split_9a4c0f80a04c4be19d184de5e253d4b9_G_2, _Multiply_a62e1d5019764bfc9d130966a7f0b1a2_Out_2, 0, _Combine_8cce449a474d443884d72d821b5b5f1b_RGBA_4, _Combine_8cce449a474d443884d72d821b5b5f1b_RGB_5, _Combine_8cce449a474d443884d72d821b5b5f1b_RG_6);
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b;
            _SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b.uv0 = IN.uv0;
            float4 _SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Combine_8cce449a474d443884d72d821b5b5f1b_RGBA_4, _SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b, _SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b_OutVector2_1);
            float4 _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3d22ecc8b6ac4214a1e4858e276d14ef_Out_0.tex, _Property_3d22ecc8b6ac4214a1e4858e276d14ef_Out_0.samplerstate, (_SGTillingOffset_fb28c462fb684993acba75e8bf7b2f3b_OutVector2_1.xy));
            float _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_R_4 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0.r;
            float _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_G_5 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0.g;
            float _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_B_6 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0.b;
            float _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_A_7 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0.a;
            float _Split_8c21059e59f84924aab76b886b85cc12_R_1 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0[0];
            float _Split_8c21059e59f84924aab76b886b85cc12_G_2 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0[1];
            float _Split_8c21059e59f84924aab76b886b85cc12_B_3 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0[2];
            float _Split_8c21059e59f84924aab76b886b85cc12_A_4 = _SampleTexture2D_a3b34d085bb9496eb1bfaee31cf3ed5c_RGBA_0[3];
            float4 _Property_a54954a9257442708a87854c57e5cd40_Out_0 = _FoamColor;
            float4 _Multiply_1ea5697e964c47c68208dc1cc9d14a5a_Out_2;
            Unity_Multiply_float((_Split_8c21059e59f84924aab76b886b85cc12_R_1.xxxx), _Property_a54954a9257442708a87854c57e5cd40_Out_0, _Multiply_1ea5697e964c47c68208dc1cc9d14a5a_Out_2);
            float4 _UV_b6c67e8e92814cae8e03697cb60a6272_Out_0 = IN.uv0;
            float _Split_bb33969032a741839f8c299973e1d678_R_1 = _UV_b6c67e8e92814cae8e03697cb60a6272_Out_0[0];
            float _Split_bb33969032a741839f8c299973e1d678_G_2 = _UV_b6c67e8e92814cae8e03697cb60a6272_Out_0[1];
            float _Split_bb33969032a741839f8c299973e1d678_B_3 = _UV_b6c67e8e92814cae8e03697cb60a6272_Out_0[2];
            float _Split_bb33969032a741839f8c299973e1d678_A_4 = _UV_b6c67e8e92814cae8e03697cb60a6272_Out_0[3];
            float _OneMinus_de9bf5b5ab48485cb022186ac17c137b_Out_1;
            Unity_OneMinus_float(_Split_bb33969032a741839f8c299973e1d678_R_1, _OneMinus_de9bf5b5ab48485cb022186ac17c137b_Out_1);
            float _Absolute_1c89289ffd084866b36b593d3d8ed4ba_Out_1;
            Unity_Absolute_float(_OneMinus_de9bf5b5ab48485cb022186ac17c137b_Out_1, _Absolute_1c89289ffd084866b36b593d3d8ed4ba_Out_1);
            float _Property_a4f821186403487894d4b2791bcca865_Out_0 = _FoamPower;
            float _Power_f128e45538cf4da4af63390f7c452b6f_Out_2;
            Unity_Power_float(_Absolute_1c89289ffd084866b36b593d3d8ed4ba_Out_1, _Property_a4f821186403487894d4b2791bcca865_Out_0, _Power_f128e45538cf4da4af63390f7c452b6f_Out_2);
            float4 _Multiply_7833484a516b42ed9e0f53c9b6ce2749_Out_2;
            Unity_Multiply_float(_Multiply_1ea5697e964c47c68208dc1cc9d14a5a_Out_2, (_Power_f128e45538cf4da4af63390f7c452b6f_Out_2.xxxx), _Multiply_7833484a516b42ed9e0f53c9b6ce2749_Out_2);
            float4 _Add_53eae0f97ea041caaa38fa99af6ecce4_Out_2;
            Unity_Add_float4(_Multiply_7833484a516b42ed9e0f53c9b6ce2749_Out_2, (_Power_f128e45538cf4da4af63390f7c452b6f_Out_2.xxxx), _Add_53eae0f97ea041caaa38fa99af6ecce4_Out_2);
            surface.Alpha = (_Add_53eae0f97ea041caaa38fa99af6ecce4_Out_2).x;
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
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.VertexColor =                 input.color;
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





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
    }
    CustomEditor "SHD_FoamIslands"
    FallBack "Hidden/Shader Graph/FallbackError"
}
