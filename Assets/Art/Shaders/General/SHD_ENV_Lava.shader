Shader "DragonCity2/ENV/Lava"
{
    Properties
    {
        _Color("Color 1", Color) = (1, 0.2901961, 0.04313726, 0)
        _Color1Strength("Color 1 Strength", Range(0, 10)) = 0.1
        _Color2("Color 2", Color) = (1, 0.7882353, 0, 0)
        _Color2Strength("Color 2 Strength", Range(0, 10)) = 1
        _Offset("Offset", Range(0, 10)) = 1.4
        _OverBright("OverBright", Float) = 1.95
        [NoScaleOffset]_MainTex("Main Tex", 2D) = "white" {}
        _MapScaleXYPanningZW("Map Scale (XY) / Panning (ZW)", Vector) = (3, 3, -0.05, -0.05)
        [NoScaleOffset]_DistortTex("Distort Tex", 2D) = "white" {}
        _DistortionScaleXYPanningZW("Distortion Scale (XY) / Panning (ZW)", Vector) = (3, 3, 0.025, -0.025)
        _Distortion("Distortion", Range(0, 1)) = 0.2
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Geometry"
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
            // GraphKeywords: <None>

            // Defines
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
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
            float3 ObjectSpacePosition;
            float4 uv0;
            float3 TimeParameters;
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
        float4 _Color;
        float _Color1Strength;
        float4 _Color2;
        float _Color2Strength;
        float _Offset;
        float _OverBright;
        float4 _MainTex_TexelSize;
        float4 _MapScaleXYPanningZW;
        float4 _DistortTex_TexelSize;
        float4 _DistortionScaleXYPanningZW;
        float _Distortion;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_DistortTex);
        SAMPLER(sampler_DistortTex);

            // Graph Functions
            
        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float4(float4 In, out float4 Out)
        {
            Out = saturate(In);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Fog_float(out float4 Color, out float Density, float3 Position)
        {
            SHADERGRAPH_FOG(Position, Color, Density);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Exponential2_float(float In, out float Out)
        {
            Out = exp2(In);
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
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_2fb9d81d2e9447f7a7a743ba49ffa8f4_Out_0 = _Color;
            float _Property_97ef8c2b0777468d97e284b7b7747b56_Out_0 = _Color1Strength;
            float4 _Multiply_345eb7e11a324c8daf52457da9f77391_Out_2;
            Unity_Multiply_float(_Property_2fb9d81d2e9447f7a7a743ba49ffa8f4_Out_0, (_Property_97ef8c2b0777468d97e284b7b7747b56_Out_0.xxxx), _Multiply_345eb7e11a324c8daf52457da9f77391_Out_2);
            float4 _Saturate_a7d46e88932e4412a24f688cd1521591_Out_1;
            Unity_Saturate_float4(_Multiply_345eb7e11a324c8daf52457da9f77391_Out_2, _Saturate_a7d46e88932e4412a24f688cd1521591_Out_1);
            float4 _Property_d8d89492123d47199e68f23977a1bed2_Out_0 = _Color2;
            float _Property_86035ebccd144cb7a7369d9f366ae3f8_Out_0 = _Color2Strength;
            float4 _Multiply_248f07c8a771489daeea3f2eabd6020e_Out_2;
            Unity_Multiply_float(_Property_d8d89492123d47199e68f23977a1bed2_Out_0, (_Property_86035ebccd144cb7a7369d9f366ae3f8_Out_0.xxxx), _Multiply_248f07c8a771489daeea3f2eabd6020e_Out_2);
            float4 _Saturate_8d75e9eca7fd485a9bc656ba1fa37d1c_Out_1;
            Unity_Saturate_float4(_Multiply_248f07c8a771489daeea3f2eabd6020e_Out_2, _Saturate_8d75e9eca7fd485a9bc656ba1fa37d1c_Out_1);
            float _Property_307132c48ad94a0785ca5efa4f9a5dbd_Out_0 = _Offset;
            UnityTexture2D _Property_557323da4d85458fa4a766d5a0cfc788_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float _Property_e86d565eb7a24b62a7102b8d5db1b39b_Out_0 = _Distortion;
            UnityTexture2D _Property_5e2119865ad34fb681994209355a47d8_Out_0 = UnityBuildTexture2DStructNoScale(_DistortTex);
            float _Float_532be6c968bc4705a42ae60248c55ac3_Out_0 = 0.5;
            float4 _Property_880efd9a6ffd4ca2b85815f23d1921d7_Out_0 = _DistortionScaleXYPanningZW;
            float _Split_df65368bfc514b8f8e65a992bc417cf3_R_1 = _Property_880efd9a6ffd4ca2b85815f23d1921d7_Out_0[0];
            float _Split_df65368bfc514b8f8e65a992bc417cf3_G_2 = _Property_880efd9a6ffd4ca2b85815f23d1921d7_Out_0[1];
            float _Split_df65368bfc514b8f8e65a992bc417cf3_B_3 = _Property_880efd9a6ffd4ca2b85815f23d1921d7_Out_0[2];
            float _Split_df65368bfc514b8f8e65a992bc417cf3_A_4 = _Property_880efd9a6ffd4ca2b85815f23d1921d7_Out_0[3];
            float2 _Vector2_82e1b3f995f0401d8d2dc87ecb1ba34d_Out_0 = float2(_Split_df65368bfc514b8f8e65a992bc417cf3_R_1, _Split_df65368bfc514b8f8e65a992bc417cf3_G_2);
            float2 _Multiply_abea7536e1f8405489b359b3e4262fc3_Out_2;
            Unity_Multiply_float((_Float_532be6c968bc4705a42ae60248c55ac3_Out_0.xx), _Vector2_82e1b3f995f0401d8d2dc87ecb1ba34d_Out_0, _Multiply_abea7536e1f8405489b359b3e4262fc3_Out_2);
            float2 _Vector2_da549d29decd4f8e9d3722e02f4a99c9_Out_0 = float2(_Split_df65368bfc514b8f8e65a992bc417cf3_B_3, _Split_df65368bfc514b8f8e65a992bc417cf3_A_4);
            float2 _Multiply_7e91dcaed14c41eb86084d0bc4e74921_Out_2;
            Unity_Multiply_float(_Vector2_da549d29decd4f8e9d3722e02f4a99c9_Out_0, (IN.TimeParameters.x.xx), _Multiply_7e91dcaed14c41eb86084d0bc4e74921_Out_2);
            float2 _TilingAndOffset_45b66b5d61934ed480e1658fe9992722_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Multiply_abea7536e1f8405489b359b3e4262fc3_Out_2, _Multiply_7e91dcaed14c41eb86084d0bc4e74921_Out_2, _TilingAndOffset_45b66b5d61934ed480e1658fe9992722_Out_3);
            float4 _SampleTexture2D_f093bc135fcc40759ef2d4dca34edea0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5e2119865ad34fb681994209355a47d8_Out_0.tex, _Property_5e2119865ad34fb681994209355a47d8_Out_0.samplerstate, _TilingAndOffset_45b66b5d61934ed480e1658fe9992722_Out_3);
            float _SampleTexture2D_f093bc135fcc40759ef2d4dca34edea0_R_4 = _SampleTexture2D_f093bc135fcc40759ef2d4dca34edea0_RGBA_0.r;
            float _SampleTexture2D_f093bc135fcc40759ef2d4dca34edea0_G_5 = _SampleTexture2D_f093bc135fcc40759ef2d4dca34edea0_RGBA_0.g;
            float _SampleTexture2D_f093bc135fcc40759ef2d4dca34edea0_B_6 = _SampleTexture2D_f093bc135fcc40759ef2d4dca34edea0_RGBA_0.b;
            float _SampleTexture2D_f093bc135fcc40759ef2d4dca34edea0_A_7 = _SampleTexture2D_f093bc135fcc40759ef2d4dca34edea0_RGBA_0.a;
            float2 _TilingAndOffset_2b07a3ceea524194a4ffa891bd135077_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_82e1b3f995f0401d8d2dc87ecb1ba34d_Out_0, _Multiply_7e91dcaed14c41eb86084d0bc4e74921_Out_2, _TilingAndOffset_2b07a3ceea524194a4ffa891bd135077_Out_3);
            float4 _SampleTexture2D_88474594aae846afb0a0817356124e96_RGBA_0 = SAMPLE_TEXTURE2D(_Property_5e2119865ad34fb681994209355a47d8_Out_0.tex, _Property_5e2119865ad34fb681994209355a47d8_Out_0.samplerstate, _TilingAndOffset_2b07a3ceea524194a4ffa891bd135077_Out_3);
            float _SampleTexture2D_88474594aae846afb0a0817356124e96_R_4 = _SampleTexture2D_88474594aae846afb0a0817356124e96_RGBA_0.r;
            float _SampleTexture2D_88474594aae846afb0a0817356124e96_G_5 = _SampleTexture2D_88474594aae846afb0a0817356124e96_RGBA_0.g;
            float _SampleTexture2D_88474594aae846afb0a0817356124e96_B_6 = _SampleTexture2D_88474594aae846afb0a0817356124e96_RGBA_0.b;
            float _SampleTexture2D_88474594aae846afb0a0817356124e96_A_7 = _SampleTexture2D_88474594aae846afb0a0817356124e96_RGBA_0.a;
            float4 _Add_978d11f5c50e429f857b63a420667e0a_Out_2;
            Unity_Add_float4(_SampleTexture2D_f093bc135fcc40759ef2d4dca34edea0_RGBA_0, _SampleTexture2D_88474594aae846afb0a0817356124e96_RGBA_0, _Add_978d11f5c50e429f857b63a420667e0a_Out_2);
            float _Float_c574404dff2e4dbab8dea9bf1d2bdc51_Out_0 = 0.5;
            float4 _Multiply_1d678f193f554f77ba81e3e926fac769_Out_2;
            Unity_Multiply_float(_Add_978d11f5c50e429f857b63a420667e0a_Out_2, (_Float_c574404dff2e4dbab8dea9bf1d2bdc51_Out_0.xxxx), _Multiply_1d678f193f554f77ba81e3e926fac769_Out_2);
            float4 _Saturate_f24dceb5700a47fcb10676c55091d284_Out_1;
            Unity_Saturate_float4(_Multiply_1d678f193f554f77ba81e3e926fac769_Out_2, _Saturate_f24dceb5700a47fcb10676c55091d284_Out_1);
            float4 _Multiply_fdfa062784da429ea3bc61ad6fb796ff_Out_2;
            Unity_Multiply_float((_Property_e86d565eb7a24b62a7102b8d5db1b39b_Out_0.xxxx), _Saturate_f24dceb5700a47fcb10676c55091d284_Out_1, _Multiply_fdfa062784da429ea3bc61ad6fb796ff_Out_2);
            float4 _Property_abde502aca8a4604abe3fe161befdd7b_Out_0 = _MapScaleXYPanningZW;
            float _Split_e3e194f179354b31b5be5d0b6f4fdbde_R_1 = _Property_abde502aca8a4604abe3fe161befdd7b_Out_0[0];
            float _Split_e3e194f179354b31b5be5d0b6f4fdbde_G_2 = _Property_abde502aca8a4604abe3fe161befdd7b_Out_0[1];
            float _Split_e3e194f179354b31b5be5d0b6f4fdbde_B_3 = _Property_abde502aca8a4604abe3fe161befdd7b_Out_0[2];
            float _Split_e3e194f179354b31b5be5d0b6f4fdbde_A_4 = _Property_abde502aca8a4604abe3fe161befdd7b_Out_0[3];
            float2 _Vector2_5703721f1b6a415a93ddc8018957ae18_Out_0 = float2(_Split_e3e194f179354b31b5be5d0b6f4fdbde_R_1, _Split_e3e194f179354b31b5be5d0b6f4fdbde_G_2);
            float2 _Vector2_0f46ac541e7b47659cc57041e30c9082_Out_0 = float2(_Split_e3e194f179354b31b5be5d0b6f4fdbde_B_3, _Split_e3e194f179354b31b5be5d0b6f4fdbde_A_4);
            float2 _Multiply_dc18aec6b821419285dc5a86b731a66f_Out_2;
            Unity_Multiply_float(_Vector2_0f46ac541e7b47659cc57041e30c9082_Out_0, (IN.TimeParameters.x.xx), _Multiply_dc18aec6b821419285dc5a86b731a66f_Out_2);
            float2 _TilingAndOffset_77df16a04f544330b944136901ce5a3b_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_5703721f1b6a415a93ddc8018957ae18_Out_0, _Multiply_dc18aec6b821419285dc5a86b731a66f_Out_2, _TilingAndOffset_77df16a04f544330b944136901ce5a3b_Out_3);
            float2 _Add_5809ee4256c5457c83cc7a8507d75c70_Out_2;
            Unity_Add_float2((_Multiply_fdfa062784da429ea3bc61ad6fb796ff_Out_2.xy), _TilingAndOffset_77df16a04f544330b944136901ce5a3b_Out_3, _Add_5809ee4256c5457c83cc7a8507d75c70_Out_2);
            float4 _SampleTexture2D_a11c58ef23194ef88ae18d58c24ccd04_RGBA_0 = SAMPLE_TEXTURE2D(_Property_557323da4d85458fa4a766d5a0cfc788_Out_0.tex, _Property_557323da4d85458fa4a766d5a0cfc788_Out_0.samplerstate, _Add_5809ee4256c5457c83cc7a8507d75c70_Out_2);
            float _SampleTexture2D_a11c58ef23194ef88ae18d58c24ccd04_R_4 = _SampleTexture2D_a11c58ef23194ef88ae18d58c24ccd04_RGBA_0.r;
            float _SampleTexture2D_a11c58ef23194ef88ae18d58c24ccd04_G_5 = _SampleTexture2D_a11c58ef23194ef88ae18d58c24ccd04_RGBA_0.g;
            float _SampleTexture2D_a11c58ef23194ef88ae18d58c24ccd04_B_6 = _SampleTexture2D_a11c58ef23194ef88ae18d58c24ccd04_RGBA_0.b;
            float _SampleTexture2D_a11c58ef23194ef88ae18d58c24ccd04_A_7 = _SampleTexture2D_a11c58ef23194ef88ae18d58c24ccd04_RGBA_0.a;
            float4 _Multiply_5176441c90bd420cad977a29a20f6ccf_Out_2;
            Unity_Multiply_float((_Property_307132c48ad94a0785ca5efa4f9a5dbd_Out_0.xxxx), _SampleTexture2D_a11c58ef23194ef88ae18d58c24ccd04_RGBA_0, _Multiply_5176441c90bd420cad977a29a20f6ccf_Out_2);
            float4 _Saturate_a88a3904c87e4abe81317511263c0809_Out_1;
            Unity_Saturate_float4(_Multiply_5176441c90bd420cad977a29a20f6ccf_Out_2, _Saturate_a88a3904c87e4abe81317511263c0809_Out_1);
            float4 _Lerp_9b1d3a56001c4880b4efa918066866c3_Out_3;
            Unity_Lerp_float4(_Saturate_a7d46e88932e4412a24f688cd1521591_Out_1, _Saturate_8d75e9eca7fd485a9bc656ba1fa37d1c_Out_1, _Saturate_a88a3904c87e4abe81317511263c0809_Out_1, _Lerp_9b1d3a56001c4880b4efa918066866c3_Out_3);
            float _Property_ab4e671514ce4da9928470bd78b0a280_Out_0 = _OverBright;
            float4 _Multiply_738212b32c884334955c15d00132ad63_Out_2;
            Unity_Multiply_float(_Lerp_9b1d3a56001c4880b4efa918066866c3_Out_3, (_Property_ab4e671514ce4da9928470bd78b0a280_Out_0.xxxx), _Multiply_738212b32c884334955c15d00132ad63_Out_2);
            Bindings_SGFog_6fda06a5a255f8244a0881200c0efc1c _SGFog_3df67eb1d63d4fe2bd4c40110bd21c7b;
            _SGFog_3df67eb1d63d4fe2bd4c40110bd21c7b.ObjectSpacePosition = IN.ObjectSpacePosition;
            float4 _SGFog_3df67eb1d63d4fe2bd4c40110bd21c7b_OutVector4_1;
            SG_SGFog_6fda06a5a255f8244a0881200c0efc1c(_Multiply_738212b32c884334955c15d00132ad63_Out_2, _SGFog_3df67eb1d63d4fe2bd4c40110bd21c7b, _SGFog_3df67eb1d63d4fe2bd4c40110bd21c7b_OutVector4_1);
            surface.BaseColor = (_SGFog_3df67eb1d63d4fe2bd4c40110bd21c7b_OutVector4_1.xyz);
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
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
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
        float4 _Color;
        float _Color1Strength;
        float4 _Color2;
        float _Color2Strength;
        float _Offset;
        float _OverBright;
        float4 _MainTex_TexelSize;
        float4 _MapScaleXYPanningZW;
        float4 _DistortTex_TexelSize;
        float4 _DistortionScaleXYPanningZW;
        float _Distortion;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        TEXTURE2D(_DistortTex);
        SAMPLER(sampler_DistortTex);

            // Graph Functions
            // GraphFunctions: <None>

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
    }
    FallBack "Hidden/Shader Graph/FallbackError"
}
