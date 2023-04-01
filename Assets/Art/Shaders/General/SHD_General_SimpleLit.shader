Shader "DragonCity2/General/Simple Lit"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_BaseMap("Base Map", 2D) = "white" {}
        _TilingOffset("Tiling / Offset", Vector) = (1, 1, 0, 0)
        _Smoothness("Smoothness", Range(0, 1)) = 0
        _Metalness("Metalness", Range(0, 1)) = 0
        _Cutoff("Alpha Clip", Range(0, 1)) = 0
        [NoScaleOffset]_EmissionMap("Emission Map", 2D) = "white" {}
        [HDR]_EmissionColor("Emission Color", Color) = (0, 0, 0, 0)
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
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        //#pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        //#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        //#pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        //#pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
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
            float4 uv0;
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
        float4 _BaseColor;
        float4 _BaseMap_TexelSize;
        float4 _TilingOffset;
        float _Smoothness;
        float _Metalness;
        float4 _EmissionMap_TexelSize;
        float4 _EmissionColor;
        float _Cutoff;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

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
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_4f3d7a11ea774ed28531730e7d059b41_Out_0 = _BaseColor;
            UnityTexture2D _Property_82886b68491946858e87d281a907b861_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _Property_04af543af1af492bb8fb29923a880f88_Out_0 = _TilingOffset;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06;
            _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06.uv0 = IN.uv0;
            float4 _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_04af543af1af492bb8fb29923a880f88_Out_0, _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06, _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1);
            float4 _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0 = SAMPLE_TEXTURE2D(_Property_82886b68491946858e87d281a907b861_Out_0.tex, _Property_82886b68491946858e87d281a907b861_Out_0.samplerstate, (_SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1.xy));
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_R_4 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.r;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_G_5 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.g;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_B_6 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.b;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_A_7 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.a;
            float4 _Multiply_5f0ed060e86043c58be8eea071ab4b1f_Out_2;
            Unity_Multiply_float(_Property_4f3d7a11ea774ed28531730e7d059b41_Out_0, _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0, _Multiply_5f0ed060e86043c58be8eea071ab4b1f_Out_2);
            float4 _Property_4349d0e6d66c416a9df2b54676c3dad4_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_45101ab371fd4f3fa1c25b9ed977e4b5_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0 = SAMPLE_TEXTURE2D(_Property_45101ab371fd4f3fa1c25b9ed977e4b5_Out_0.tex, _Property_45101ab371fd4f3fa1c25b9ed977e4b5_Out_0.samplerstate, (_SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1.xy));
            float _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_R_4 = _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0.r;
            float _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_G_5 = _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0.g;
            float _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_B_6 = _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0.b;
            float _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_A_7 = _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0.a;
            float4 _Multiply_33ebba5645a04b8f86f5eda326fee4ec_Out_2;
            Unity_Multiply_float(_Property_4349d0e6d66c416a9df2b54676c3dad4_Out_0, _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0, _Multiply_33ebba5645a04b8f86f5eda326fee4ec_Out_2);
            float _Property_5ed4a87f95c74338afcdc0c3c54b6521_Out_0 = _Metalness;
            float _Property_d692892147924984b4cd6afb53a9bad5_Out_0 = _Smoothness;
            float _Property_bfc16cfafd89495b800b315d45d618bc_Out_0 = _Cutoff;
            surface.BaseColor = (_Multiply_5f0ed060e86043c58be8eea071ab4b1f_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_33ebba5645a04b8f86f5eda326fee4ec_Out_2.xyz);
            surface.Metallic = _Property_5ed4a87f95c74338afcdc0c3c54b6521_Out_0;
            surface.Smoothness = _Property_d692892147924984b4cd6afb53a9bad5_Out_0;
            surface.Occlusion = 1;
            surface.Alpha = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_A_7;
            surface.AlphaClipThreshold = _Property_bfc16cfafd89495b800b315d45d618bc_Out_0;
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


            output.uv0 =                         input.texCoord0;
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
        #pragma multi_compile _ _SHADOWS_SOFT
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
            float4 uv0;
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
        float4 _BaseColor;
        float4 _BaseMap_TexelSize;
        float4 _TilingOffset;
        float _Smoothness;
        float _Metalness;
        float4 _EmissionMap_TexelSize;
        float4 _EmissionColor;
        float _Cutoff;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

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
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_4f3d7a11ea774ed28531730e7d059b41_Out_0 = _BaseColor;
            UnityTexture2D _Property_82886b68491946858e87d281a907b861_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _Property_04af543af1af492bb8fb29923a880f88_Out_0 = _TilingOffset;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06;
            _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06.uv0 = IN.uv0;
            float4 _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_04af543af1af492bb8fb29923a880f88_Out_0, _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06, _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1);
            float4 _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0 = SAMPLE_TEXTURE2D(_Property_82886b68491946858e87d281a907b861_Out_0.tex, _Property_82886b68491946858e87d281a907b861_Out_0.samplerstate, (_SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1.xy));
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_R_4 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.r;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_G_5 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.g;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_B_6 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.b;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_A_7 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.a;
            float4 _Multiply_5f0ed060e86043c58be8eea071ab4b1f_Out_2;
            Unity_Multiply_float(_Property_4f3d7a11ea774ed28531730e7d059b41_Out_0, _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0, _Multiply_5f0ed060e86043c58be8eea071ab4b1f_Out_2);
            float4 _Property_4349d0e6d66c416a9df2b54676c3dad4_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_45101ab371fd4f3fa1c25b9ed977e4b5_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0 = SAMPLE_TEXTURE2D(_Property_45101ab371fd4f3fa1c25b9ed977e4b5_Out_0.tex, _Property_45101ab371fd4f3fa1c25b9ed977e4b5_Out_0.samplerstate, (_SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1.xy));
            float _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_R_4 = _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0.r;
            float _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_G_5 = _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0.g;
            float _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_B_6 = _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0.b;
            float _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_A_7 = _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0.a;
            float4 _Multiply_33ebba5645a04b8f86f5eda326fee4ec_Out_2;
            Unity_Multiply_float(_Property_4349d0e6d66c416a9df2b54676c3dad4_Out_0, _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0, _Multiply_33ebba5645a04b8f86f5eda326fee4ec_Out_2);
            float _Property_5ed4a87f95c74338afcdc0c3c54b6521_Out_0 = _Metalness;
            float _Property_d692892147924984b4cd6afb53a9bad5_Out_0 = _Smoothness;
            float _Property_bfc16cfafd89495b800b315d45d618bc_Out_0 = _Cutoff;
            surface.BaseColor = (_Multiply_5f0ed060e86043c58be8eea071ab4b1f_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_33ebba5645a04b8f86f5eda326fee4ec_Out_2.xyz);
            surface.Metallic = _Property_5ed4a87f95c74338afcdc0c3c54b6521_Out_0;
            surface.Smoothness = _Property_d692892147924984b4cd6afb53a9bad5_Out_0;
            surface.Occlusion = 1;
            surface.Alpha = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_A_7;
            surface.AlphaClipThreshold = _Property_bfc16cfafd89495b800b315d45d618bc_Out_0;
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


            output.uv0 =                         input.texCoord0;
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
        float4 _BaseColor;
        float4 _BaseMap_TexelSize;
        float4 _TilingOffset;
        float _Smoothness;
        float _Metalness;
        float4 _EmissionMap_TexelSize;
        float4 _EmissionColor;
        float _Cutoff;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

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
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_82886b68491946858e87d281a907b861_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _Property_04af543af1af492bb8fb29923a880f88_Out_0 = _TilingOffset;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06;
            _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06.uv0 = IN.uv0;
            float4 _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_04af543af1af492bb8fb29923a880f88_Out_0, _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06, _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1);
            float4 _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0 = SAMPLE_TEXTURE2D(_Property_82886b68491946858e87d281a907b861_Out_0.tex, _Property_82886b68491946858e87d281a907b861_Out_0.samplerstate, (_SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1.xy));
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_R_4 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.r;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_G_5 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.g;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_B_6 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.b;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_A_7 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.a;
            float _Property_bfc16cfafd89495b800b315d45d618bc_Out_0 = _Cutoff;
            surface.Alpha = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_A_7;
            surface.AlphaClipThreshold = _Property_bfc16cfafd89495b800b315d45d618bc_Out_0;
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





            output.uv0 =                         input.texCoord0;
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
        float4 _BaseColor;
        float4 _BaseMap_TexelSize;
        float4 _TilingOffset;
        float _Smoothness;
        float _Metalness;
        float4 _EmissionMap_TexelSize;
        float4 _EmissionColor;
        float _Cutoff;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

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
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_82886b68491946858e87d281a907b861_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _Property_04af543af1af492bb8fb29923a880f88_Out_0 = _TilingOffset;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06;
            _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06.uv0 = IN.uv0;
            float4 _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_04af543af1af492bb8fb29923a880f88_Out_0, _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06, _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1);
            float4 _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0 = SAMPLE_TEXTURE2D(_Property_82886b68491946858e87d281a907b861_Out_0.tex, _Property_82886b68491946858e87d281a907b861_Out_0.samplerstate, (_SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1.xy));
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_R_4 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.r;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_G_5 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.g;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_B_6 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.b;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_A_7 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.a;
            float _Property_bfc16cfafd89495b800b315d45d618bc_Out_0 = _Cutoff;
            surface.Alpha = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_A_7;
            surface.AlphaClipThreshold = _Property_bfc16cfafd89495b800b315d45d618bc_Out_0;
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





            output.uv0 =                         input.texCoord0;
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
            float4 uv0;
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
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
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
        float4 _BaseColor;
        float4 _BaseMap_TexelSize;
        float4 _TilingOffset;
        float _Smoothness;
        float _Metalness;
        float4 _EmissionMap_TexelSize;
        float4 _EmissionColor;
        float _Cutoff;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

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
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_82886b68491946858e87d281a907b861_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _Property_04af543af1af492bb8fb29923a880f88_Out_0 = _TilingOffset;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06;
            _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06.uv0 = IN.uv0;
            float4 _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_04af543af1af492bb8fb29923a880f88_Out_0, _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06, _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1);
            float4 _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0 = SAMPLE_TEXTURE2D(_Property_82886b68491946858e87d281a907b861_Out_0.tex, _Property_82886b68491946858e87d281a907b861_Out_0.samplerstate, (_SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1.xy));
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_R_4 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.r;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_G_5 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.g;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_B_6 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.b;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_A_7 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.a;
            float _Property_bfc16cfafd89495b800b315d45d618bc_Out_0 = _Cutoff;
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_A_7;
            surface.AlphaClipThreshold = _Property_bfc16cfafd89495b800b315d45d618bc_Out_0;
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


            output.uv0 =                         input.texCoord0;
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
        float4 _BaseColor;
        float4 _BaseMap_TexelSize;
        float4 _TilingOffset;
        float _Smoothness;
        float _Metalness;
        float4 _EmissionMap_TexelSize;
        float4 _EmissionColor;
        float _Cutoff;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_BaseMap);
        SAMPLER(sampler_BaseMap);
        TEXTURE2D(_EmissionMap);
        SAMPLER(sampler_EmissionMap);

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
            float Alpha;
            float AlphaClipThreshold;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_4f3d7a11ea774ed28531730e7d059b41_Out_0 = _BaseColor;
            UnityTexture2D _Property_82886b68491946858e87d281a907b861_Out_0 = UnityBuildTexture2DStructNoScale(_BaseMap);
            float4 _Property_04af543af1af492bb8fb29923a880f88_Out_0 = _TilingOffset;
            Bindings_SGTillingOffset_26340359382e7054f90b8ffabbb581b8 _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06;
            _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06.uv0 = IN.uv0;
            float4 _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1;
            SG_SGTillingOffset_26340359382e7054f90b8ffabbb581b8(_Property_04af543af1af492bb8fb29923a880f88_Out_0, _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06, _SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1);
            float4 _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0 = SAMPLE_TEXTURE2D(_Property_82886b68491946858e87d281a907b861_Out_0.tex, _Property_82886b68491946858e87d281a907b861_Out_0.samplerstate, (_SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1.xy));
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_R_4 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.r;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_G_5 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.g;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_B_6 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.b;
            float _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_A_7 = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0.a;
            float4 _Multiply_5f0ed060e86043c58be8eea071ab4b1f_Out_2;
            Unity_Multiply_float(_Property_4f3d7a11ea774ed28531730e7d059b41_Out_0, _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_RGBA_0, _Multiply_5f0ed060e86043c58be8eea071ab4b1f_Out_2);
            float4 _Property_4349d0e6d66c416a9df2b54676c3dad4_Out_0 = IsGammaSpace() ? LinearToSRGB(_EmissionColor) : _EmissionColor;
            UnityTexture2D _Property_45101ab371fd4f3fa1c25b9ed977e4b5_Out_0 = UnityBuildTexture2DStructNoScale(_EmissionMap);
            float4 _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0 = SAMPLE_TEXTURE2D(_Property_45101ab371fd4f3fa1c25b9ed977e4b5_Out_0.tex, _Property_45101ab371fd4f3fa1c25b9ed977e4b5_Out_0.samplerstate, (_SGTillingOffset_533257e5e7a248b1b1fda6aaf0773a06_OutVector2_1.xy));
            float _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_R_4 = _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0.r;
            float _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_G_5 = _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0.g;
            float _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_B_6 = _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0.b;
            float _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_A_7 = _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0.a;
            float4 _Multiply_33ebba5645a04b8f86f5eda326fee4ec_Out_2;
            Unity_Multiply_float(_Property_4349d0e6d66c416a9df2b54676c3dad4_Out_0, _SampleTexture2D_a26b0a7737d2414da425665d5b7a0134_RGBA_0, _Multiply_33ebba5645a04b8f86f5eda326fee4ec_Out_2);
            float _Property_bfc16cfafd89495b800b315d45d618bc_Out_0 = _Cutoff;
            surface.BaseColor = (_Multiply_5f0ed060e86043c58be8eea071ab4b1f_Out_2.xyz);
            surface.Emission = (_Multiply_33ebba5645a04b8f86f5eda326fee4ec_Out_2.xyz);
            surface.Alpha = _SampleTexture2D_8ca0ae6f02dd41e09061ee742b65e4eb_A_7;
            surface.AlphaClipThreshold = _Property_bfc16cfafd89495b800b315d45d618bc_Out_0;
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





            output.uv0 =                         input.texCoord0;
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
    CustomEditor "SHD_General_SimpleLit"
    FallBack "Hidden/Shader Graph/FallbackError"
}
