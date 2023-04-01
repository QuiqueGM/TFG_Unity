Shader "DragonCity2/Arenas/Terrain Simple"
{
    Properties
    {
        _Color("Tint", Color) = (0.7921569, 0.7921569, 0.7921569, 0)
        [NoScaleOffset]_Mask("Mask", 2D) = "white" {}
        _TllingOffsetMaks("Tlling Offset Maks", Vector) = (1, 1, 0, 0)
        [NoScaleOffset]_MainTextureA("Main Texture A", 2D) = "white" {}
        _TllingOffsetA("Tlling Offset A", Vector) = (1, 1, 0, 0)
        [NoScaleOffset]_MainTextureB("Main Texture B", 2D) = "white" {}
        _TllingOffsetB("Tlling Offset B", Vector) = (1, 1, 0, 0)
        [NoScaleOffset]_MainTextureC("Main Texture C", 2D) = "white" {}
        _TllingOffsetC("Tlling Offset C", Vector) = (1, 1, 0, 0)
        [NoScaleOffset]_MainTextureD("Main Texture D", 2D) = "white" {}
        _TllingOffsetD("Tlling Offset D", Vector) = (1, 1, 0, 0)
        _RimColor("Rim Color", Color) = (0.7921569, 0.7921569, 0.7921569, 0)
        _RimPower("Rim Power", Range(0, 10)) = 10
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
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
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
        float4 _Color;
        float4 _Mask_TexelSize;
        float4 _TllingOffsetMaks;
        float4 _MainTextureA_TexelSize;
        float4 _TllingOffsetA;
        float4 _MainTextureB_TexelSize;
        float4 _TllingOffsetB;
        float4 _MainTextureC_TexelSize;
        float4 _TllingOffsetC;
        float4 _MainTextureD_TexelSize;
        float4 _TllingOffsetD;
        float4 _RimColor;
        float _RimPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_MainTextureA);
        SAMPLER(sampler_MainTextureA);
        TEXTURE2D(_MainTextureB);
        SAMPLER(sampler_MainTextureB);
        TEXTURE2D(_MainTextureC);
        SAMPLER(sampler_MainTextureC);
        TEXTURE2D(_MainTextureD);
        SAMPLER(sampler_MainTextureD);

            // Graph Functions
            
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

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Blend_SoftLight_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            float4 result1 = 2.0 * Base * Blend + Base * Base * (1.0 - 2.0 * Blend);
            float4 result2 = sqrt(Base) * (2.0 * Blend - 1.0) + 2.0 * Base * (1.0 - Blend);
            float4 zeroOrOne = step(0.5, Blend);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
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
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_85de13a593ec46c7b9e625e59455e6b8_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float4 _Property_5a9f831d83d44691aa469dfc576735e3_Out_0 = _TllingOffsetMaks;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_342cdbb66be0482aafca7456adafb348;
            _SGTillingOffset_342cdbb66be0482aafca7456adafb348.uv0 = IN.uv0;
            float4 _SGTillingOffset_342cdbb66be0482aafca7456adafb348_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_5a9f831d83d44691aa469dfc576735e3_Out_0, _SGTillingOffset_342cdbb66be0482aafca7456adafb348, _SGTillingOffset_342cdbb66be0482aafca7456adafb348_OutVector2_1);
            float4 _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_85de13a593ec46c7b9e625e59455e6b8_Out_0.tex, _Property_85de13a593ec46c7b9e625e59455e6b8_Out_0.samplerstate, (_SGTillingOffset_342cdbb66be0482aafca7456adafb348_OutVector2_1.xy));
            float _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_R_4 = _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_RGBA_0.r;
            float _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_G_5 = _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_RGBA_0.g;
            float _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_B_6 = _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_RGBA_0.b;
            float _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_A_7 = _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_RGBA_0.a;
            UnityTexture2D _Property_2bdb816d98a0435987aed7c5b03a0f8b_Out_0 = UnityBuildTexture2DStructNoScale(_MainTextureA);
            float4 _Property_f7a584084e4544bba1d002359989612d_Out_0 = _TllingOffsetA;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_688a4c1f39664011a97cada16e9700f1;
            _SGTillingOffset_688a4c1f39664011a97cada16e9700f1.uv0 = IN.uv0;
            float4 _SGTillingOffset_688a4c1f39664011a97cada16e9700f1_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_f7a584084e4544bba1d002359989612d_Out_0, _SGTillingOffset_688a4c1f39664011a97cada16e9700f1, _SGTillingOffset_688a4c1f39664011a97cada16e9700f1_OutVector2_1);
            float4 _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2bdb816d98a0435987aed7c5b03a0f8b_Out_0.tex, _Property_2bdb816d98a0435987aed7c5b03a0f8b_Out_0.samplerstate, (_SGTillingOffset_688a4c1f39664011a97cada16e9700f1_OutVector2_1.xy));
            float _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_R_4 = _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0.r;
            float _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_G_5 = _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0.g;
            float _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_B_6 = _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0.b;
            float _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_A_7 = _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0.a;
            float4 _Multiply_f645f1e643994499abb84958db341b73_Out_2;
            Unity_Multiply_float((_SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_R_4.xxxx), _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0, _Multiply_f645f1e643994499abb84958db341b73_Out_2);
            UnityTexture2D _Property_269855d6f8e3416983b5f21989c190ca_Out_0 = UnityBuildTexture2DStructNoScale(_MainTextureB);
            float4 _Property_ddad5c1009c1473b8ea59ce2d84f58b8_Out_0 = _TllingOffsetB;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40;
            _SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40.uv0 = IN.uv0;
            float4 _SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_ddad5c1009c1473b8ea59ce2d84f58b8_Out_0, _SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40, _SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40_OutVector2_1);
            float4 _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_269855d6f8e3416983b5f21989c190ca_Out_0.tex, _Property_269855d6f8e3416983b5f21989c190ca_Out_0.samplerstate, (_SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40_OutVector2_1.xy));
            float _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_R_4 = _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0.r;
            float _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_G_5 = _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0.g;
            float _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_B_6 = _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0.b;
            float _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_A_7 = _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0.a;
            float4 _Multiply_03569deece38492580a48553dea8a594_Out_2;
            Unity_Multiply_float((_SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_G_5.xxxx), _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0, _Multiply_03569deece38492580a48553dea8a594_Out_2);
            float4 _Add_4758f69b4dfe424ab0b532619d959939_Out_2;
            Unity_Add_float4(_Multiply_f645f1e643994499abb84958db341b73_Out_2, _Multiply_03569deece38492580a48553dea8a594_Out_2, _Add_4758f69b4dfe424ab0b532619d959939_Out_2);
            UnityTexture2D _Property_736168764d4b4593913a05fd1502a441_Out_0 = UnityBuildTexture2DStructNoScale(_MainTextureC);
            float4 _Property_5621d3e51ec142b991d4bd9bafcf467e_Out_0 = _TllingOffsetC;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_1956a95d18d444b997d4c8019f1311ec;
            _SGTillingOffset_1956a95d18d444b997d4c8019f1311ec.uv0 = IN.uv0;
            float4 _SGTillingOffset_1956a95d18d444b997d4c8019f1311ec_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_5621d3e51ec142b991d4bd9bafcf467e_Out_0, _SGTillingOffset_1956a95d18d444b997d4c8019f1311ec, _SGTillingOffset_1956a95d18d444b997d4c8019f1311ec_OutVector2_1);
            float4 _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0 = SAMPLE_TEXTURE2D(_Property_736168764d4b4593913a05fd1502a441_Out_0.tex, _Property_736168764d4b4593913a05fd1502a441_Out_0.samplerstate, (_SGTillingOffset_1956a95d18d444b997d4c8019f1311ec_OutVector2_1.xy));
            float _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_R_4 = _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0.r;
            float _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_G_5 = _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0.g;
            float _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_B_6 = _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0.b;
            float _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_A_7 = _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0.a;
            float4 _Multiply_01e4ae6a065a4d6081b266dde9c3906c_Out_2;
            Unity_Multiply_float((_SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_B_6.xxxx), _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0, _Multiply_01e4ae6a065a4d6081b266dde9c3906c_Out_2);
            float4 _Add_288fbce320144e03863bb280239cf268_Out_2;
            Unity_Add_float4(_Add_4758f69b4dfe424ab0b532619d959939_Out_2, _Multiply_01e4ae6a065a4d6081b266dde9c3906c_Out_2, _Add_288fbce320144e03863bb280239cf268_Out_2);
            UnityTexture2D _Property_4efc512729084e4797e61a977b441d72_Out_0 = UnityBuildTexture2DStructNoScale(_MainTextureD);
            float4 _Property_471edbbd54c647e98d3f2bcd959cb7cb_Out_0 = _TllingOffsetD;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111;
            _SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111.uv0 = IN.uv0;
            float4 _SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_471edbbd54c647e98d3f2bcd959cb7cb_Out_0, _SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111, _SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111_OutVector2_1);
            float4 _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4efc512729084e4797e61a977b441d72_Out_0.tex, _Property_4efc512729084e4797e61a977b441d72_Out_0.samplerstate, (_SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111_OutVector2_1.xy));
            float _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_R_4 = _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0.r;
            float _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_G_5 = _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0.g;
            float _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_B_6 = _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0.b;
            float _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_A_7 = _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0.a;
            float _Split_ff2e2e4dbf7c4c0191aef52e3a036cac_R_1 = IN.VertexColor[0];
            float _Split_ff2e2e4dbf7c4c0191aef52e3a036cac_G_2 = IN.VertexColor[1];
            float _Split_ff2e2e4dbf7c4c0191aef52e3a036cac_B_3 = IN.VertexColor[2];
            float _Split_ff2e2e4dbf7c4c0191aef52e3a036cac_A_4 = IN.VertexColor[3];
            float4 _Lerp_1f585f8fb1404de6b13b917d8b44c94e_Out_3;
            Unity_Lerp_float4(_Add_288fbce320144e03863bb280239cf268_Out_2, _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0, (_Split_ff2e2e4dbf7c4c0191aef52e3a036cac_R_1.xxxx), _Lerp_1f585f8fb1404de6b13b917d8b44c94e_Out_3);
            float4 _Lerp_7727be9c62a34dfc94db2a8853da3021_Out_3;
            Unity_Lerp_float4(_Lerp_1f585f8fb1404de6b13b917d8b44c94e_Out_3, _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0, (_Split_ff2e2e4dbf7c4c0191aef52e3a036cac_G_2.xxxx), _Lerp_7727be9c62a34dfc94db2a8853da3021_Out_3);
            float4 _Property_4e6736f664c54b48b99cf1f9e81db7da_Out_0 = _Color;
            float4 _Blend_88b4e7eec64b4851a33fba317570829e_Out_2;
            Unity_Blend_SoftLight_float4(_Lerp_7727be9c62a34dfc94db2a8853da3021_Out_3, _Property_4e6736f664c54b48b99cf1f9e81db7da_Out_0, _Blend_88b4e7eec64b4851a33fba317570829e_Out_2, 1);
            float4 _Property_233266bb55e948db8d06dc640435906c_Out_0 = _RimColor;
            float _Property_502cc9e1c9b4433cab7f73473f0264b1_Out_0 = _RimPower;
            float _FresnelEffect_dfc780974cdf4e2a9c32820d6adb1dff_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_502cc9e1c9b4433cab7f73473f0264b1_Out_0, _FresnelEffect_dfc780974cdf4e2a9c32820d6adb1dff_Out_3);
            float4 _Multiply_f879bbd04cac4cdda41dec3bfd3c230c_Out_2;
            Unity_Multiply_float(_Property_233266bb55e948db8d06dc640435906c_Out_0, (_FresnelEffect_dfc780974cdf4e2a9c32820d6adb1dff_Out_3.xxxx), _Multiply_f879bbd04cac4cdda41dec3bfd3c230c_Out_2);
            float4 Color_eb1d2349d9a94fa996e347cedede2b8c = IsGammaSpace() ? float4(0, 0, 0, 0) : float4(SRGBToLinear(float3(0, 0, 0)), 0);
            float4 _Lerp_63dfa5a5a1074715818ec17e079bf31c_Out_3;
            Unity_Lerp_float4(_Multiply_f879bbd04cac4cdda41dec3bfd3c230c_Out_2, Color_eb1d2349d9a94fa996e347cedede2b8c, (_Split_ff2e2e4dbf7c4c0191aef52e3a036cac_R_1.xxxx), _Lerp_63dfa5a5a1074715818ec17e079bf31c_Out_3);
            surface.BaseColor = (_Blend_88b4e7eec64b4851a33fba317570829e_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Lerp_63dfa5a5a1074715818ec17e079bf31c_Out_3.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0;
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
        float4 _Color;
        float4 _Mask_TexelSize;
        float4 _TllingOffsetMaks;
        float4 _MainTextureA_TexelSize;
        float4 _TllingOffsetA;
        float4 _MainTextureB_TexelSize;
        float4 _TllingOffsetB;
        float4 _MainTextureC_TexelSize;
        float4 _TllingOffsetC;
        float4 _MainTextureD_TexelSize;
        float4 _TllingOffsetD;
        float4 _RimColor;
        float _RimPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_MainTextureA);
        SAMPLER(sampler_MainTextureA);
        TEXTURE2D(_MainTextureB);
        SAMPLER(sampler_MainTextureB);
        TEXTURE2D(_MainTextureC);
        SAMPLER(sampler_MainTextureC);
        TEXTURE2D(_MainTextureD);
        SAMPLER(sampler_MainTextureD);

            // Graph Functions
            
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

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Blend_SoftLight_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            float4 result1 = 2.0 * Base * Blend + Base * Base * (1.0 - 2.0 * Blend);
            float4 result2 = sqrt(Base) * (2.0 * Blend - 1.0) + 2.0 * Base * (1.0 - Blend);
            float4 zeroOrOne = step(0.5, Blend);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
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
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_85de13a593ec46c7b9e625e59455e6b8_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float4 _Property_5a9f831d83d44691aa469dfc576735e3_Out_0 = _TllingOffsetMaks;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_342cdbb66be0482aafca7456adafb348;
            _SGTillingOffset_342cdbb66be0482aafca7456adafb348.uv0 = IN.uv0;
            float4 _SGTillingOffset_342cdbb66be0482aafca7456adafb348_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_5a9f831d83d44691aa469dfc576735e3_Out_0, _SGTillingOffset_342cdbb66be0482aafca7456adafb348, _SGTillingOffset_342cdbb66be0482aafca7456adafb348_OutVector2_1);
            float4 _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_85de13a593ec46c7b9e625e59455e6b8_Out_0.tex, _Property_85de13a593ec46c7b9e625e59455e6b8_Out_0.samplerstate, (_SGTillingOffset_342cdbb66be0482aafca7456adafb348_OutVector2_1.xy));
            float _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_R_4 = _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_RGBA_0.r;
            float _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_G_5 = _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_RGBA_0.g;
            float _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_B_6 = _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_RGBA_0.b;
            float _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_A_7 = _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_RGBA_0.a;
            UnityTexture2D _Property_2bdb816d98a0435987aed7c5b03a0f8b_Out_0 = UnityBuildTexture2DStructNoScale(_MainTextureA);
            float4 _Property_f7a584084e4544bba1d002359989612d_Out_0 = _TllingOffsetA;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_688a4c1f39664011a97cada16e9700f1;
            _SGTillingOffset_688a4c1f39664011a97cada16e9700f1.uv0 = IN.uv0;
            float4 _SGTillingOffset_688a4c1f39664011a97cada16e9700f1_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_f7a584084e4544bba1d002359989612d_Out_0, _SGTillingOffset_688a4c1f39664011a97cada16e9700f1, _SGTillingOffset_688a4c1f39664011a97cada16e9700f1_OutVector2_1);
            float4 _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2bdb816d98a0435987aed7c5b03a0f8b_Out_0.tex, _Property_2bdb816d98a0435987aed7c5b03a0f8b_Out_0.samplerstate, (_SGTillingOffset_688a4c1f39664011a97cada16e9700f1_OutVector2_1.xy));
            float _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_R_4 = _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0.r;
            float _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_G_5 = _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0.g;
            float _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_B_6 = _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0.b;
            float _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_A_7 = _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0.a;
            float4 _Multiply_f645f1e643994499abb84958db341b73_Out_2;
            Unity_Multiply_float((_SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_R_4.xxxx), _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0, _Multiply_f645f1e643994499abb84958db341b73_Out_2);
            UnityTexture2D _Property_269855d6f8e3416983b5f21989c190ca_Out_0 = UnityBuildTexture2DStructNoScale(_MainTextureB);
            float4 _Property_ddad5c1009c1473b8ea59ce2d84f58b8_Out_0 = _TllingOffsetB;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40;
            _SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40.uv0 = IN.uv0;
            float4 _SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_ddad5c1009c1473b8ea59ce2d84f58b8_Out_0, _SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40, _SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40_OutVector2_1);
            float4 _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_269855d6f8e3416983b5f21989c190ca_Out_0.tex, _Property_269855d6f8e3416983b5f21989c190ca_Out_0.samplerstate, (_SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40_OutVector2_1.xy));
            float _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_R_4 = _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0.r;
            float _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_G_5 = _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0.g;
            float _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_B_6 = _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0.b;
            float _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_A_7 = _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0.a;
            float4 _Multiply_03569deece38492580a48553dea8a594_Out_2;
            Unity_Multiply_float((_SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_G_5.xxxx), _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0, _Multiply_03569deece38492580a48553dea8a594_Out_2);
            float4 _Add_4758f69b4dfe424ab0b532619d959939_Out_2;
            Unity_Add_float4(_Multiply_f645f1e643994499abb84958db341b73_Out_2, _Multiply_03569deece38492580a48553dea8a594_Out_2, _Add_4758f69b4dfe424ab0b532619d959939_Out_2);
            UnityTexture2D _Property_736168764d4b4593913a05fd1502a441_Out_0 = UnityBuildTexture2DStructNoScale(_MainTextureC);
            float4 _Property_5621d3e51ec142b991d4bd9bafcf467e_Out_0 = _TllingOffsetC;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_1956a95d18d444b997d4c8019f1311ec;
            _SGTillingOffset_1956a95d18d444b997d4c8019f1311ec.uv0 = IN.uv0;
            float4 _SGTillingOffset_1956a95d18d444b997d4c8019f1311ec_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_5621d3e51ec142b991d4bd9bafcf467e_Out_0, _SGTillingOffset_1956a95d18d444b997d4c8019f1311ec, _SGTillingOffset_1956a95d18d444b997d4c8019f1311ec_OutVector2_1);
            float4 _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0 = SAMPLE_TEXTURE2D(_Property_736168764d4b4593913a05fd1502a441_Out_0.tex, _Property_736168764d4b4593913a05fd1502a441_Out_0.samplerstate, (_SGTillingOffset_1956a95d18d444b997d4c8019f1311ec_OutVector2_1.xy));
            float _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_R_4 = _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0.r;
            float _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_G_5 = _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0.g;
            float _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_B_6 = _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0.b;
            float _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_A_7 = _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0.a;
            float4 _Multiply_01e4ae6a065a4d6081b266dde9c3906c_Out_2;
            Unity_Multiply_float((_SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_B_6.xxxx), _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0, _Multiply_01e4ae6a065a4d6081b266dde9c3906c_Out_2);
            float4 _Add_288fbce320144e03863bb280239cf268_Out_2;
            Unity_Add_float4(_Add_4758f69b4dfe424ab0b532619d959939_Out_2, _Multiply_01e4ae6a065a4d6081b266dde9c3906c_Out_2, _Add_288fbce320144e03863bb280239cf268_Out_2);
            UnityTexture2D _Property_4efc512729084e4797e61a977b441d72_Out_0 = UnityBuildTexture2DStructNoScale(_MainTextureD);
            float4 _Property_471edbbd54c647e98d3f2bcd959cb7cb_Out_0 = _TllingOffsetD;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111;
            _SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111.uv0 = IN.uv0;
            float4 _SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_471edbbd54c647e98d3f2bcd959cb7cb_Out_0, _SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111, _SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111_OutVector2_1);
            float4 _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4efc512729084e4797e61a977b441d72_Out_0.tex, _Property_4efc512729084e4797e61a977b441d72_Out_0.samplerstate, (_SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111_OutVector2_1.xy));
            float _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_R_4 = _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0.r;
            float _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_G_5 = _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0.g;
            float _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_B_6 = _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0.b;
            float _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_A_7 = _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0.a;
            float _Split_ff2e2e4dbf7c4c0191aef52e3a036cac_R_1 = IN.VertexColor[0];
            float _Split_ff2e2e4dbf7c4c0191aef52e3a036cac_G_2 = IN.VertexColor[1];
            float _Split_ff2e2e4dbf7c4c0191aef52e3a036cac_B_3 = IN.VertexColor[2];
            float _Split_ff2e2e4dbf7c4c0191aef52e3a036cac_A_4 = IN.VertexColor[3];
            float4 _Lerp_1f585f8fb1404de6b13b917d8b44c94e_Out_3;
            Unity_Lerp_float4(_Add_288fbce320144e03863bb280239cf268_Out_2, _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0, (_Split_ff2e2e4dbf7c4c0191aef52e3a036cac_R_1.xxxx), _Lerp_1f585f8fb1404de6b13b917d8b44c94e_Out_3);
            float4 _Lerp_7727be9c62a34dfc94db2a8853da3021_Out_3;
            Unity_Lerp_float4(_Lerp_1f585f8fb1404de6b13b917d8b44c94e_Out_3, _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0, (_Split_ff2e2e4dbf7c4c0191aef52e3a036cac_G_2.xxxx), _Lerp_7727be9c62a34dfc94db2a8853da3021_Out_3);
            float4 _Property_4e6736f664c54b48b99cf1f9e81db7da_Out_0 = _Color;
            float4 _Blend_88b4e7eec64b4851a33fba317570829e_Out_2;
            Unity_Blend_SoftLight_float4(_Lerp_7727be9c62a34dfc94db2a8853da3021_Out_3, _Property_4e6736f664c54b48b99cf1f9e81db7da_Out_0, _Blend_88b4e7eec64b4851a33fba317570829e_Out_2, 1);
            float4 _Property_233266bb55e948db8d06dc640435906c_Out_0 = _RimColor;
            float _Property_502cc9e1c9b4433cab7f73473f0264b1_Out_0 = _RimPower;
            float _FresnelEffect_dfc780974cdf4e2a9c32820d6adb1dff_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_502cc9e1c9b4433cab7f73473f0264b1_Out_0, _FresnelEffect_dfc780974cdf4e2a9c32820d6adb1dff_Out_3);
            float4 _Multiply_f879bbd04cac4cdda41dec3bfd3c230c_Out_2;
            Unity_Multiply_float(_Property_233266bb55e948db8d06dc640435906c_Out_0, (_FresnelEffect_dfc780974cdf4e2a9c32820d6adb1dff_Out_3.xxxx), _Multiply_f879bbd04cac4cdda41dec3bfd3c230c_Out_2);
            float4 Color_eb1d2349d9a94fa996e347cedede2b8c = IsGammaSpace() ? float4(0, 0, 0, 0) : float4(SRGBToLinear(float3(0, 0, 0)), 0);
            float4 _Lerp_63dfa5a5a1074715818ec17e079bf31c_Out_3;
            Unity_Lerp_float4(_Multiply_f879bbd04cac4cdda41dec3bfd3c230c_Out_2, Color_eb1d2349d9a94fa996e347cedede2b8c, (_Split_ff2e2e4dbf7c4c0191aef52e3a036cac_R_1.xxxx), _Lerp_63dfa5a5a1074715818ec17e079bf31c_Out_3);
            surface.BaseColor = (_Blend_88b4e7eec64b4851a33fba317570829e_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Lerp_63dfa5a5a1074715818ec17e079bf31c_Out_3.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0;
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
        float4 _Color;
        float4 _Mask_TexelSize;
        float4 _TllingOffsetMaks;
        float4 _MainTextureA_TexelSize;
        float4 _TllingOffsetA;
        float4 _MainTextureB_TexelSize;
        float4 _TllingOffsetB;
        float4 _MainTextureC_TexelSize;
        float4 _TllingOffsetC;
        float4 _MainTextureD_TexelSize;
        float4 _TllingOffsetD;
        float4 _RimColor;
        float _RimPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_MainTextureA);
        SAMPLER(sampler_MainTextureA);
        TEXTURE2D(_MainTextureB);
        SAMPLER(sampler_MainTextureB);
        TEXTURE2D(_MainTextureC);
        SAMPLER(sampler_MainTextureC);
        TEXTURE2D(_MainTextureD);
        SAMPLER(sampler_MainTextureD);

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
        float4 _Color;
        float4 _Mask_TexelSize;
        float4 _TllingOffsetMaks;
        float4 _MainTextureA_TexelSize;
        float4 _TllingOffsetA;
        float4 _MainTextureB_TexelSize;
        float4 _TllingOffsetB;
        float4 _MainTextureC_TexelSize;
        float4 _TllingOffsetC;
        float4 _MainTextureD_TexelSize;
        float4 _TllingOffsetD;
        float4 _RimColor;
        float _RimPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_MainTextureA);
        SAMPLER(sampler_MainTextureA);
        TEXTURE2D(_MainTextureB);
        SAMPLER(sampler_MainTextureB);
        TEXTURE2D(_MainTextureC);
        SAMPLER(sampler_MainTextureC);
        TEXTURE2D(_MainTextureD);
        SAMPLER(sampler_MainTextureD);

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
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
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
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
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
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS;
            float4 tangentWS;
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
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
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
            output.tangentWS = input.interp1.xyzw;
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
        float4 _Mask_TexelSize;
        float4 _TllingOffsetMaks;
        float4 _MainTextureA_TexelSize;
        float4 _TllingOffsetA;
        float4 _MainTextureB_TexelSize;
        float4 _TllingOffsetB;
        float4 _MainTextureC_TexelSize;
        float4 _TllingOffsetC;
        float4 _MainTextureD_TexelSize;
        float4 _TllingOffsetD;
        float4 _RimColor;
        float _RimPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_MainTextureA);
        SAMPLER(sampler_MainTextureA);
        TEXTURE2D(_MainTextureB);
        SAMPLER(sampler_MainTextureB);
        TEXTURE2D(_MainTextureC);
        SAMPLER(sampler_MainTextureC);
        TEXTURE2D(_MainTextureD);
        SAMPLER(sampler_MainTextureD);

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
            float3 NormalTS;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.NormalTS = IN.TangentSpaceNormal;
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



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


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
        float4 _Color;
        float4 _Mask_TexelSize;
        float4 _TllingOffsetMaks;
        float4 _MainTextureA_TexelSize;
        float4 _TllingOffsetA;
        float4 _MainTextureB_TexelSize;
        float4 _TllingOffsetB;
        float4 _MainTextureC_TexelSize;
        float4 _TllingOffsetC;
        float4 _MainTextureD_TexelSize;
        float4 _TllingOffsetD;
        float4 _RimColor;
        float _RimPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);
        TEXTURE2D(_MainTextureA);
        SAMPLER(sampler_MainTextureA);
        TEXTURE2D(_MainTextureB);
        SAMPLER(sampler_MainTextureB);
        TEXTURE2D(_MainTextureC);
        SAMPLER(sampler_MainTextureC);
        TEXTURE2D(_MainTextureD);
        SAMPLER(sampler_MainTextureD);

            // Graph Functions
            
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

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Blend_SoftLight_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            float4 result1 = 2.0 * Base * Blend + Base * Base * (1.0 - 2.0 * Blend);
            float4 result2 = sqrt(Base) * (2.0 * Blend - 1.0) + 2.0 * Base * (1.0 - Blend);
            float4 zeroOrOne = step(0.5, Blend);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
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
            float3 Emission;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_85de13a593ec46c7b9e625e59455e6b8_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float4 _Property_5a9f831d83d44691aa469dfc576735e3_Out_0 = _TllingOffsetMaks;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_342cdbb66be0482aafca7456adafb348;
            _SGTillingOffset_342cdbb66be0482aafca7456adafb348.uv0 = IN.uv0;
            float4 _SGTillingOffset_342cdbb66be0482aafca7456adafb348_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_5a9f831d83d44691aa469dfc576735e3_Out_0, _SGTillingOffset_342cdbb66be0482aafca7456adafb348, _SGTillingOffset_342cdbb66be0482aafca7456adafb348_OutVector2_1);
            float4 _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_RGBA_0 = SAMPLE_TEXTURE2D(_Property_85de13a593ec46c7b9e625e59455e6b8_Out_0.tex, _Property_85de13a593ec46c7b9e625e59455e6b8_Out_0.samplerstate, (_SGTillingOffset_342cdbb66be0482aafca7456adafb348_OutVector2_1.xy));
            float _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_R_4 = _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_RGBA_0.r;
            float _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_G_5 = _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_RGBA_0.g;
            float _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_B_6 = _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_RGBA_0.b;
            float _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_A_7 = _SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_RGBA_0.a;
            UnityTexture2D _Property_2bdb816d98a0435987aed7c5b03a0f8b_Out_0 = UnityBuildTexture2DStructNoScale(_MainTextureA);
            float4 _Property_f7a584084e4544bba1d002359989612d_Out_0 = _TllingOffsetA;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_688a4c1f39664011a97cada16e9700f1;
            _SGTillingOffset_688a4c1f39664011a97cada16e9700f1.uv0 = IN.uv0;
            float4 _SGTillingOffset_688a4c1f39664011a97cada16e9700f1_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_f7a584084e4544bba1d002359989612d_Out_0, _SGTillingOffset_688a4c1f39664011a97cada16e9700f1, _SGTillingOffset_688a4c1f39664011a97cada16e9700f1_OutVector2_1);
            float4 _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0 = SAMPLE_TEXTURE2D(_Property_2bdb816d98a0435987aed7c5b03a0f8b_Out_0.tex, _Property_2bdb816d98a0435987aed7c5b03a0f8b_Out_0.samplerstate, (_SGTillingOffset_688a4c1f39664011a97cada16e9700f1_OutVector2_1.xy));
            float _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_R_4 = _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0.r;
            float _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_G_5 = _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0.g;
            float _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_B_6 = _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0.b;
            float _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_A_7 = _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0.a;
            float4 _Multiply_f645f1e643994499abb84958db341b73_Out_2;
            Unity_Multiply_float((_SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_R_4.xxxx), _SampleTexture2D_ee8e343d526c42428a1690b24d27391a_RGBA_0, _Multiply_f645f1e643994499abb84958db341b73_Out_2);
            UnityTexture2D _Property_269855d6f8e3416983b5f21989c190ca_Out_0 = UnityBuildTexture2DStructNoScale(_MainTextureB);
            float4 _Property_ddad5c1009c1473b8ea59ce2d84f58b8_Out_0 = _TllingOffsetB;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40;
            _SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40.uv0 = IN.uv0;
            float4 _SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_ddad5c1009c1473b8ea59ce2d84f58b8_Out_0, _SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40, _SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40_OutVector2_1);
            float4 _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_269855d6f8e3416983b5f21989c190ca_Out_0.tex, _Property_269855d6f8e3416983b5f21989c190ca_Out_0.samplerstate, (_SGTillingOffset_6d0acb4c6f1a4077acb45d4e76aeba40_OutVector2_1.xy));
            float _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_R_4 = _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0.r;
            float _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_G_5 = _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0.g;
            float _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_B_6 = _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0.b;
            float _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_A_7 = _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0.a;
            float4 _Multiply_03569deece38492580a48553dea8a594_Out_2;
            Unity_Multiply_float((_SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_G_5.xxxx), _SampleTexture2D_b6547e6c8b2446ae853abbc964c9db5b_RGBA_0, _Multiply_03569deece38492580a48553dea8a594_Out_2);
            float4 _Add_4758f69b4dfe424ab0b532619d959939_Out_2;
            Unity_Add_float4(_Multiply_f645f1e643994499abb84958db341b73_Out_2, _Multiply_03569deece38492580a48553dea8a594_Out_2, _Add_4758f69b4dfe424ab0b532619d959939_Out_2);
            UnityTexture2D _Property_736168764d4b4593913a05fd1502a441_Out_0 = UnityBuildTexture2DStructNoScale(_MainTextureC);
            float4 _Property_5621d3e51ec142b991d4bd9bafcf467e_Out_0 = _TllingOffsetC;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_1956a95d18d444b997d4c8019f1311ec;
            _SGTillingOffset_1956a95d18d444b997d4c8019f1311ec.uv0 = IN.uv0;
            float4 _SGTillingOffset_1956a95d18d444b997d4c8019f1311ec_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_5621d3e51ec142b991d4bd9bafcf467e_Out_0, _SGTillingOffset_1956a95d18d444b997d4c8019f1311ec, _SGTillingOffset_1956a95d18d444b997d4c8019f1311ec_OutVector2_1);
            float4 _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0 = SAMPLE_TEXTURE2D(_Property_736168764d4b4593913a05fd1502a441_Out_0.tex, _Property_736168764d4b4593913a05fd1502a441_Out_0.samplerstate, (_SGTillingOffset_1956a95d18d444b997d4c8019f1311ec_OutVector2_1.xy));
            float _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_R_4 = _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0.r;
            float _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_G_5 = _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0.g;
            float _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_B_6 = _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0.b;
            float _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_A_7 = _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0.a;
            float4 _Multiply_01e4ae6a065a4d6081b266dde9c3906c_Out_2;
            Unity_Multiply_float((_SampleTexture2D_24958fe7d53842efb19536b14a48ba4f_B_6.xxxx), _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0, _Multiply_01e4ae6a065a4d6081b266dde9c3906c_Out_2);
            float4 _Add_288fbce320144e03863bb280239cf268_Out_2;
            Unity_Add_float4(_Add_4758f69b4dfe424ab0b532619d959939_Out_2, _Multiply_01e4ae6a065a4d6081b266dde9c3906c_Out_2, _Add_288fbce320144e03863bb280239cf268_Out_2);
            UnityTexture2D _Property_4efc512729084e4797e61a977b441d72_Out_0 = UnityBuildTexture2DStructNoScale(_MainTextureD);
            float4 _Property_471edbbd54c647e98d3f2bcd959cb7cb_Out_0 = _TllingOffsetD;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111;
            _SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111.uv0 = IN.uv0;
            float4 _SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_471edbbd54c647e98d3f2bcd959cb7cb_Out_0, _SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111, _SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111_OutVector2_1);
            float4 _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_4efc512729084e4797e61a977b441d72_Out_0.tex, _Property_4efc512729084e4797e61a977b441d72_Out_0.samplerstate, (_SGTillingOffset_ff016387f1fc496bb0de7ba23fd0e111_OutVector2_1.xy));
            float _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_R_4 = _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0.r;
            float _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_G_5 = _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0.g;
            float _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_B_6 = _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0.b;
            float _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_A_7 = _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0.a;
            float _Split_ff2e2e4dbf7c4c0191aef52e3a036cac_R_1 = IN.VertexColor[0];
            float _Split_ff2e2e4dbf7c4c0191aef52e3a036cac_G_2 = IN.VertexColor[1];
            float _Split_ff2e2e4dbf7c4c0191aef52e3a036cac_B_3 = IN.VertexColor[2];
            float _Split_ff2e2e4dbf7c4c0191aef52e3a036cac_A_4 = IN.VertexColor[3];
            float4 _Lerp_1f585f8fb1404de6b13b917d8b44c94e_Out_3;
            Unity_Lerp_float4(_Add_288fbce320144e03863bb280239cf268_Out_2, _SampleTexture2D_462b1d88232244ba9cfc846f15d4b05b_RGBA_0, (_Split_ff2e2e4dbf7c4c0191aef52e3a036cac_R_1.xxxx), _Lerp_1f585f8fb1404de6b13b917d8b44c94e_Out_3);
            float4 _Lerp_7727be9c62a34dfc94db2a8853da3021_Out_3;
            Unity_Lerp_float4(_Lerp_1f585f8fb1404de6b13b917d8b44c94e_Out_3, _SampleTexture2D_0c42838308ca4d809c720b464cc529a9_RGBA_0, (_Split_ff2e2e4dbf7c4c0191aef52e3a036cac_G_2.xxxx), _Lerp_7727be9c62a34dfc94db2a8853da3021_Out_3);
            float4 _Property_4e6736f664c54b48b99cf1f9e81db7da_Out_0 = _Color;
            float4 _Blend_88b4e7eec64b4851a33fba317570829e_Out_2;
            Unity_Blend_SoftLight_float4(_Lerp_7727be9c62a34dfc94db2a8853da3021_Out_3, _Property_4e6736f664c54b48b99cf1f9e81db7da_Out_0, _Blend_88b4e7eec64b4851a33fba317570829e_Out_2, 1);
            float4 _Property_233266bb55e948db8d06dc640435906c_Out_0 = _RimColor;
            float _Property_502cc9e1c9b4433cab7f73473f0264b1_Out_0 = _RimPower;
            float _FresnelEffect_dfc780974cdf4e2a9c32820d6adb1dff_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_502cc9e1c9b4433cab7f73473f0264b1_Out_0, _FresnelEffect_dfc780974cdf4e2a9c32820d6adb1dff_Out_3);
            float4 _Multiply_f879bbd04cac4cdda41dec3bfd3c230c_Out_2;
            Unity_Multiply_float(_Property_233266bb55e948db8d06dc640435906c_Out_0, (_FresnelEffect_dfc780974cdf4e2a9c32820d6adb1dff_Out_3.xxxx), _Multiply_f879bbd04cac4cdda41dec3bfd3c230c_Out_2);
            float4 Color_eb1d2349d9a94fa996e347cedede2b8c = IsGammaSpace() ? float4(0, 0, 0, 0) : float4(SRGBToLinear(float3(0, 0, 0)), 0);
            float4 _Lerp_63dfa5a5a1074715818ec17e079bf31c_Out_3;
            Unity_Lerp_float4(_Multiply_f879bbd04cac4cdda41dec3bfd3c230c_Out_2, Color_eb1d2349d9a94fa996e347cedede2b8c, (_Split_ff2e2e4dbf7c4c0191aef52e3a036cac_R_1.xxxx), _Lerp_63dfa5a5a1074715818ec17e079bf31c_Out_3);
            surface.BaseColor = (_Blend_88b4e7eec64b4851a33fba317570829e_Out_2.xyz);
            surface.Emission = (_Lerp_63dfa5a5a1074715818ec17e079bf31c_Out_3.xyz);
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
    }
    CustomEditor "SHD_TerrainSimpleEditor"
    FallBack "Hidden/Shader Graph/FallbackError"
}
