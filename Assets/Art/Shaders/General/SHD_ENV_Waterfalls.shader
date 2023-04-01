Shader "DragonCity2/ENV/Waterfalls"
{
    Properties
    {
        [NoScaleOffset]_Mask("Mask", 2D) = "white" {}
        _UpColor("Up Color", Color) = (0.2313726, 0.4196079, 0.6509804, 1)
        _MidColor("Mid Color", Color) = (0.3215686, 0.6862745, 0.8862746, 1)
        _DownColor("Down Color", Color) = (1, 1, 1, 1)
        _Threshold("Threshold", Range(0, 1)) = 0
        _Edge("Edge", Range(0, 1)) = 0
        _FoamColor("Foam Color", Color) = (0.8313726, 0.8313726, 0.8313726, 1)
        _FoamDispersion("Foam Dispersion", Vector) = (0.5, 0.8, 0, 0)
        _FoamBack("Foam Back", Vector) = (1, 1, 0, 1)
        _FoamFront("Foam Front", Vector) = (1, 1, 0, 1)
        //[HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        //[HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        //[HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
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
        //    #pragma multi_compile _ LIGHTMAP_ON
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
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
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
            float4 texCoord0;
            float4 color;
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
            float4 VertexColor;
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
            output.interp1.xyzw =  input.texCoord0;
            output.interp2.xyzw =  input.color;
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
            output.color = input.interp2.xyzw;
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
        float4 _Mask_TexelSize;
        float4 _UpColor;
        float4 _MidColor;
        float4 _DownColor;
        float _Threshold;
        float _Edge;
        float4 _FoamColor;
        float2 _FoamDispersion;
        float4 _FoamBack;
        float4 _FoamFront;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Fog_float(out float4 Color, out float Density, float3 Position)
        {
            SHADERGRAPH_FOG(Position, Color, Density);
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
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_3f878a90cefa474eb79262c73ddce0e5_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float4 _Property_e5bdda1562d24b919e8f1c68743f52b0_Out_0 = _FoamFront;
            float _Split_d7a95a700b6440d4937b76c547bc8a71_R_1 = _Property_e5bdda1562d24b919e8f1c68743f52b0_Out_0[0];
            float _Split_d7a95a700b6440d4937b76c547bc8a71_G_2 = _Property_e5bdda1562d24b919e8f1c68743f52b0_Out_0[1];
            float _Split_d7a95a700b6440d4937b76c547bc8a71_B_3 = _Property_e5bdda1562d24b919e8f1c68743f52b0_Out_0[2];
            float _Split_d7a95a700b6440d4937b76c547bc8a71_A_4 = _Property_e5bdda1562d24b919e8f1c68743f52b0_Out_0[3];
            float2 _Vector2_f3bc6ee402f04383926b04bc571d2ba5_Out_0 = float2(_Split_d7a95a700b6440d4937b76c547bc8a71_R_1, _Split_d7a95a700b6440d4937b76c547bc8a71_G_2);
            float _Multiply_43b239ba29754ce0b09f219d8921a483_Out_2;
            Unity_Multiply_float(_Split_d7a95a700b6440d4937b76c547bc8a71_B_3, IN.TimeParameters.x, _Multiply_43b239ba29754ce0b09f219d8921a483_Out_2);
            float _Multiply_b73125d50dd348d79fca090501053298_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Split_d7a95a700b6440d4937b76c547bc8a71_A_4, _Multiply_b73125d50dd348d79fca090501053298_Out_2);
            float2 _Vector2_2ac5c04cf87d4be6b94dbe6c1a194ba9_Out_0 = float2(_Multiply_43b239ba29754ce0b09f219d8921a483_Out_2, _Multiply_b73125d50dd348d79fca090501053298_Out_2);
            float2 _TilingAndOffset_7fd667118f454492964e6fc37f6a9055_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_f3bc6ee402f04383926b04bc571d2ba5_Out_0, _Vector2_2ac5c04cf87d4be6b94dbe6c1a194ba9_Out_0, _TilingAndOffset_7fd667118f454492964e6fc37f6a9055_Out_3);
            float4 _SampleTexture2D_1a8c5dc6ccfc482dbc17cb61b3e482f4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.tex, _Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.samplerstate, _TilingAndOffset_7fd667118f454492964e6fc37f6a9055_Out_3);
            float _SampleTexture2D_1a8c5dc6ccfc482dbc17cb61b3e482f4_R_4 = _SampleTexture2D_1a8c5dc6ccfc482dbc17cb61b3e482f4_RGBA_0.r;
            float _SampleTexture2D_1a8c5dc6ccfc482dbc17cb61b3e482f4_G_5 = _SampleTexture2D_1a8c5dc6ccfc482dbc17cb61b3e482f4_RGBA_0.g;
            float _SampleTexture2D_1a8c5dc6ccfc482dbc17cb61b3e482f4_B_6 = _SampleTexture2D_1a8c5dc6ccfc482dbc17cb61b3e482f4_RGBA_0.b;
            float _SampleTexture2D_1a8c5dc6ccfc482dbc17cb61b3e482f4_A_7 = _SampleTexture2D_1a8c5dc6ccfc482dbc17cb61b3e482f4_RGBA_0.a;
            float4 _Property_f424f944abf2474e9bbddd2a0dd6a993_Out_0 = _FoamColor;
            float4 _Multiply_35f00f598ed24e13800a97eae3215b8a_Out_2;
            Unity_Multiply_float((_SampleTexture2D_1a8c5dc6ccfc482dbc17cb61b3e482f4_G_5.xxxx), _Property_f424f944abf2474e9bbddd2a0dd6a993_Out_0, _Multiply_35f00f598ed24e13800a97eae3215b8a_Out_2);
            float4 _Property_7011b5eda06740d0b71807f9d014dc27_Out_0 = _FoamBack;
            float _Split_47c83671f39647118c74511b3fd15b27_R_1 = _Property_7011b5eda06740d0b71807f9d014dc27_Out_0[0];
            float _Split_47c83671f39647118c74511b3fd15b27_G_2 = _Property_7011b5eda06740d0b71807f9d014dc27_Out_0[1];
            float _Split_47c83671f39647118c74511b3fd15b27_B_3 = _Property_7011b5eda06740d0b71807f9d014dc27_Out_0[2];
            float _Split_47c83671f39647118c74511b3fd15b27_A_4 = _Property_7011b5eda06740d0b71807f9d014dc27_Out_0[3];
            float2 _Vector2_a10dc13d16514485b3911cea15222970_Out_0 = float2(_Split_47c83671f39647118c74511b3fd15b27_R_1, _Split_47c83671f39647118c74511b3fd15b27_G_2);
            float _Multiply_4aea5552b96941339f9b7ec21abb8758_Out_2;
            Unity_Multiply_float(_Split_47c83671f39647118c74511b3fd15b27_B_3, IN.TimeParameters.x, _Multiply_4aea5552b96941339f9b7ec21abb8758_Out_2);
            float _Multiply_a30744876db24b24b3b8ac0105075165_Out_2;
            Unity_Multiply_float(_Split_47c83671f39647118c74511b3fd15b27_A_4, IN.TimeParameters.x, _Multiply_a30744876db24b24b3b8ac0105075165_Out_2);
            float2 _Vector2_914752b829e24f6bbdb1e9b2240f524c_Out_0 = float2(_Multiply_4aea5552b96941339f9b7ec21abb8758_Out_2, _Multiply_a30744876db24b24b3b8ac0105075165_Out_2);
            float2 _TilingAndOffset_1b8c221b1f724e2b96195cbd9ee6f94a_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_a10dc13d16514485b3911cea15222970_Out_0, _Vector2_914752b829e24f6bbdb1e9b2240f524c_Out_0, _TilingAndOffset_1b8c221b1f724e2b96195cbd9ee6f94a_Out_3);
            float4 _SampleTexture2D_721301d46e074488b027fa72c5071bda_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.tex, _Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.samplerstate, _TilingAndOffset_1b8c221b1f724e2b96195cbd9ee6f94a_Out_3);
            float _SampleTexture2D_721301d46e074488b027fa72c5071bda_R_4 = _SampleTexture2D_721301d46e074488b027fa72c5071bda_RGBA_0.r;
            float _SampleTexture2D_721301d46e074488b027fa72c5071bda_G_5 = _SampleTexture2D_721301d46e074488b027fa72c5071bda_RGBA_0.g;
            float _SampleTexture2D_721301d46e074488b027fa72c5071bda_B_6 = _SampleTexture2D_721301d46e074488b027fa72c5071bda_RGBA_0.b;
            float _SampleTexture2D_721301d46e074488b027fa72c5071bda_A_7 = _SampleTexture2D_721301d46e074488b027fa72c5071bda_RGBA_0.a;
            float4 _Multiply_9e646c5b29714f31ad7ba67868960330_Out_2;
            Unity_Multiply_float(_Property_f424f944abf2474e9bbddd2a0dd6a993_Out_0, (_SampleTexture2D_721301d46e074488b027fa72c5071bda_R_4.xxxx), _Multiply_9e646c5b29714f31ad7ba67868960330_Out_2);
            float4 _Add_2ff2d13e737748b787bb2ca4cab599ab_Out_2;
            Unity_Add_float4(_Multiply_35f00f598ed24e13800a97eae3215b8a_Out_2, _Multiply_9e646c5b29714f31ad7ba67868960330_Out_2, _Add_2ff2d13e737748b787bb2ca4cab599ab_Out_2);
            float4 _Property_546de876dba44270930e2b45b5e19e94_Out_0 = _UpColor;
            float _Split_ff06d176f61b49f593539bf6c7d7a346_R_1 = IN.VertexColor[0];
            float _Split_ff06d176f61b49f593539bf6c7d7a346_G_2 = IN.VertexColor[1];
            float _Split_ff06d176f61b49f593539bf6c7d7a346_B_3 = IN.VertexColor[2];
            float _Split_ff06d176f61b49f593539bf6c7d7a346_A_4 = IN.VertexColor[3];
            float4 _Lerp_b81517ec126c4aa0bf8eec6b0680fa70_Out_3;
            Unity_Lerp_float4(_Add_2ff2d13e737748b787bb2ca4cab599ab_Out_2, _Property_546de876dba44270930e2b45b5e19e94_Out_0, (_Split_ff06d176f61b49f593539bf6c7d7a346_R_1.xxxx), _Lerp_b81517ec126c4aa0bf8eec6b0680fa70_Out_3);
            float4 _Property_64f9220e798c4f52aee0125b725dac18_Out_0 = _MidColor;
            float4 _Property_144da344617b462cbb5b6cf2fa334037_Out_0 = _DownColor;
            float _Split_68cb3ccdbe454696b58c1324424c99b2_R_1 = IN.VertexColor[0];
            float _Split_68cb3ccdbe454696b58c1324424c99b2_G_2 = IN.VertexColor[1];
            float _Split_68cb3ccdbe454696b58c1324424c99b2_B_3 = IN.VertexColor[2];
            float _Split_68cb3ccdbe454696b58c1324424c99b2_A_4 = IN.VertexColor[3];
            float _Property_fbbb61d352db47578adbde4ca93bdc96_Out_0 = _Edge;
            float _Add_068e6281061448cf92c8bc9bbe286470_Out_2;
            Unity_Add_float(_Split_68cb3ccdbe454696b58c1324424c99b2_B_3, _Property_fbbb61d352db47578adbde4ca93bdc96_Out_0, _Add_068e6281061448cf92c8bc9bbe286470_Out_2);
            float _Property_225369c6e70c403a82cc3eacec0e63d5_Out_0 = _Threshold;
            float _Smoothstep_f235c37362cb4036b2d72882ac2ff7ec_Out_3;
            Unity_Smoothstep_float(_Split_68cb3ccdbe454696b58c1324424c99b2_B_3, _Add_068e6281061448cf92c8bc9bbe286470_Out_2, _Property_225369c6e70c403a82cc3eacec0e63d5_Out_0, _Smoothstep_f235c37362cb4036b2d72882ac2ff7ec_Out_3);
            float4 _Lerp_9af6a45bca904477b1c5e3f8f11528e9_Out_3;
            Unity_Lerp_float4(_Property_64f9220e798c4f52aee0125b725dac18_Out_0, _Property_144da344617b462cbb5b6cf2fa334037_Out_0, (_Smoothstep_f235c37362cb4036b2d72882ac2ff7ec_Out_3.xxxx), _Lerp_9af6a45bca904477b1c5e3f8f11528e9_Out_3);
            float4 _Lerp_7d9876c6d1ac4a3382c477749c82d138_Out_3;
            Unity_Lerp_float4(_Lerp_9af6a45bca904477b1c5e3f8f11528e9_Out_3, _Property_546de876dba44270930e2b45b5e19e94_Out_0, (_Split_ff06d176f61b49f593539bf6c7d7a346_R_1.xxxx), _Lerp_7d9876c6d1ac4a3382c477749c82d138_Out_3);
            float4 _Add_94628f6c027d4825a4ba0b06827f2fc1_Out_2;
            Unity_Add_float4(_Lerp_b81517ec126c4aa0bf8eec6b0680fa70_Out_3, _Lerp_7d9876c6d1ac4a3382c477749c82d138_Out_3, _Add_94628f6c027d4825a4ba0b06827f2fc1_Out_2);
            Bindings_SGFog_6fda06a5a255f8244a0881200c0efc1c _SGFog_8f25fc908d864baeb84225732a69fd40;
            _SGFog_8f25fc908d864baeb84225732a69fd40.ObjectSpacePosition = IN.ObjectSpacePosition;
            float4 _SGFog_8f25fc908d864baeb84225732a69fd40_OutVector4_1;
            SG_SGFog_6fda06a5a255f8244a0881200c0efc1c(_Add_94628f6c027d4825a4ba0b06827f2fc1_Out_2, _SGFog_8f25fc908d864baeb84225732a69fd40, _SGFog_8f25fc908d864baeb84225732a69fd40_OutVector4_1);
            float2 _Property_d5eb8cc63ba646b38ce2e474a10015f4_Out_0 = _FoamDispersion;
            float _Split_56558aed0c214082bdcbda09996f7786_R_1 = _Property_d5eb8cc63ba646b38ce2e474a10015f4_Out_0[0];
            float _Split_56558aed0c214082bdcbda09996f7786_G_2 = _Property_d5eb8cc63ba646b38ce2e474a10015f4_Out_0[1];
            float _Split_56558aed0c214082bdcbda09996f7786_B_3 = 0;
            float _Split_56558aed0c214082bdcbda09996f7786_A_4 = 0;
            float _Multiply_ecfc78ba18c04d8fb56abd85c7761a43_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Split_56558aed0c214082bdcbda09996f7786_R_1, _Multiply_ecfc78ba18c04d8fb56abd85c7761a43_Out_2);
            float2 _Vector2_d445a1988cf3464d9cdb22718df580c5_Out_0 = float2(_Multiply_ecfc78ba18c04d8fb56abd85c7761a43_Out_2, 0);
            float2 _TilingAndOffset_842a0fc0d8e344abbaf9336f464a4253_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_d445a1988cf3464d9cdb22718df580c5_Out_0, _TilingAndOffset_842a0fc0d8e344abbaf9336f464a4253_Out_3);
            float4 _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.tex, _Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.samplerstate, _TilingAndOffset_842a0fc0d8e344abbaf9336f464a4253_Out_3);
            float _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_R_4 = _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_RGBA_0.r;
            float _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_G_5 = _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_RGBA_0.g;
            float _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_B_6 = _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_RGBA_0.b;
            float _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_A_7 = _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_RGBA_0.a;
            float _Multiply_bb14b4e6f948428daa8fc5feec2fc0ff_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Split_56558aed0c214082bdcbda09996f7786_G_2, _Multiply_bb14b4e6f948428daa8fc5feec2fc0ff_Out_2);
            float2 _Vector2_c0ac03cb4aae4842a417dc9599aee317_Out_0 = float2(_Multiply_bb14b4e6f948428daa8fc5feec2fc0ff_Out_2, 0);
            float2 _TilingAndOffset_fa1f6c97dd0344db9f4e6e0358110fd9_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_c0ac03cb4aae4842a417dc9599aee317_Out_0, _TilingAndOffset_fa1f6c97dd0344db9f4e6e0358110fd9_Out_3);
            float4 _SampleTexture2D_37188129f1bc479582c29ce50795b405_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.tex, _Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.samplerstate, _TilingAndOffset_fa1f6c97dd0344db9f4e6e0358110fd9_Out_3);
            float _SampleTexture2D_37188129f1bc479582c29ce50795b405_R_4 = _SampleTexture2D_37188129f1bc479582c29ce50795b405_RGBA_0.r;
            float _SampleTexture2D_37188129f1bc479582c29ce50795b405_G_5 = _SampleTexture2D_37188129f1bc479582c29ce50795b405_RGBA_0.g;
            float _SampleTexture2D_37188129f1bc479582c29ce50795b405_B_6 = _SampleTexture2D_37188129f1bc479582c29ce50795b405_RGBA_0.b;
            float _SampleTexture2D_37188129f1bc479582c29ce50795b405_A_7 = _SampleTexture2D_37188129f1bc479582c29ce50795b405_RGBA_0.a;
            float _Multiply_f9bfd9e13f014454b5551569a253e909_Out_2;
            Unity_Multiply_float(_SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_B_6, _SampleTexture2D_37188129f1bc479582c29ce50795b405_B_6, _Multiply_f9bfd9e13f014454b5551569a253e909_Out_2);
            surface.BaseColor = (_SGFog_8f25fc908d864baeb84225732a69fd40_OutVector4_1.xyz);
            surface.Alpha = _Multiply_f9bfd9e13f014454b5551569a253e909_Out_2;
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
            output.VertexColor =                 input.color;
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
        float4 _Mask_TexelSize;
        float4 _UpColor;
        float4 _MidColor;
        float4 _DownColor;
        float _Threshold;
        float _Edge;
        float4 _FoamColor;
        float2 _FoamDispersion;
        float4 _FoamBack;
        float4 _FoamFront;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_3f878a90cefa474eb79262c73ddce0e5_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float2 _Property_d5eb8cc63ba646b38ce2e474a10015f4_Out_0 = _FoamDispersion;
            float _Split_56558aed0c214082bdcbda09996f7786_R_1 = _Property_d5eb8cc63ba646b38ce2e474a10015f4_Out_0[0];
            float _Split_56558aed0c214082bdcbda09996f7786_G_2 = _Property_d5eb8cc63ba646b38ce2e474a10015f4_Out_0[1];
            float _Split_56558aed0c214082bdcbda09996f7786_B_3 = 0;
            float _Split_56558aed0c214082bdcbda09996f7786_A_4 = 0;
            float _Multiply_ecfc78ba18c04d8fb56abd85c7761a43_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Split_56558aed0c214082bdcbda09996f7786_R_1, _Multiply_ecfc78ba18c04d8fb56abd85c7761a43_Out_2);
            float2 _Vector2_d445a1988cf3464d9cdb22718df580c5_Out_0 = float2(_Multiply_ecfc78ba18c04d8fb56abd85c7761a43_Out_2, 0);
            float2 _TilingAndOffset_842a0fc0d8e344abbaf9336f464a4253_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_d445a1988cf3464d9cdb22718df580c5_Out_0, _TilingAndOffset_842a0fc0d8e344abbaf9336f464a4253_Out_3);
            float4 _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.tex, _Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.samplerstate, _TilingAndOffset_842a0fc0d8e344abbaf9336f464a4253_Out_3);
            float _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_R_4 = _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_RGBA_0.r;
            float _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_G_5 = _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_RGBA_0.g;
            float _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_B_6 = _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_RGBA_0.b;
            float _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_A_7 = _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_RGBA_0.a;
            float _Multiply_bb14b4e6f948428daa8fc5feec2fc0ff_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Split_56558aed0c214082bdcbda09996f7786_G_2, _Multiply_bb14b4e6f948428daa8fc5feec2fc0ff_Out_2);
            float2 _Vector2_c0ac03cb4aae4842a417dc9599aee317_Out_0 = float2(_Multiply_bb14b4e6f948428daa8fc5feec2fc0ff_Out_2, 0);
            float2 _TilingAndOffset_fa1f6c97dd0344db9f4e6e0358110fd9_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_c0ac03cb4aae4842a417dc9599aee317_Out_0, _TilingAndOffset_fa1f6c97dd0344db9f4e6e0358110fd9_Out_3);
            float4 _SampleTexture2D_37188129f1bc479582c29ce50795b405_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.tex, _Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.samplerstate, _TilingAndOffset_fa1f6c97dd0344db9f4e6e0358110fd9_Out_3);
            float _SampleTexture2D_37188129f1bc479582c29ce50795b405_R_4 = _SampleTexture2D_37188129f1bc479582c29ce50795b405_RGBA_0.r;
            float _SampleTexture2D_37188129f1bc479582c29ce50795b405_G_5 = _SampleTexture2D_37188129f1bc479582c29ce50795b405_RGBA_0.g;
            float _SampleTexture2D_37188129f1bc479582c29ce50795b405_B_6 = _SampleTexture2D_37188129f1bc479582c29ce50795b405_RGBA_0.b;
            float _SampleTexture2D_37188129f1bc479582c29ce50795b405_A_7 = _SampleTexture2D_37188129f1bc479582c29ce50795b405_RGBA_0.a;
            float _Multiply_f9bfd9e13f014454b5551569a253e909_Out_2;
            Unity_Multiply_float(_SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_B_6, _SampleTexture2D_37188129f1bc479582c29ce50795b405_B_6, _Multiply_f9bfd9e13f014454b5551569a253e909_Out_2);
            surface.Alpha = _Multiply_f9bfd9e13f014454b5551569a253e909_Out_2;
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
        float4 _Mask_TexelSize;
        float4 _UpColor;
        float4 _MidColor;
        float4 _DownColor;
        float _Threshold;
        float _Edge;
        float4 _FoamColor;
        float2 _FoamDispersion;
        float4 _FoamBack;
        float4 _FoamFront;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Mask);
        SAMPLER(sampler_Mask);

            // Graph Functions
            
        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
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
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_3f878a90cefa474eb79262c73ddce0e5_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float2 _Property_d5eb8cc63ba646b38ce2e474a10015f4_Out_0 = _FoamDispersion;
            float _Split_56558aed0c214082bdcbda09996f7786_R_1 = _Property_d5eb8cc63ba646b38ce2e474a10015f4_Out_0[0];
            float _Split_56558aed0c214082bdcbda09996f7786_G_2 = _Property_d5eb8cc63ba646b38ce2e474a10015f4_Out_0[1];
            float _Split_56558aed0c214082bdcbda09996f7786_B_3 = 0;
            float _Split_56558aed0c214082bdcbda09996f7786_A_4 = 0;
            float _Multiply_ecfc78ba18c04d8fb56abd85c7761a43_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Split_56558aed0c214082bdcbda09996f7786_R_1, _Multiply_ecfc78ba18c04d8fb56abd85c7761a43_Out_2);
            float2 _Vector2_d445a1988cf3464d9cdb22718df580c5_Out_0 = float2(_Multiply_ecfc78ba18c04d8fb56abd85c7761a43_Out_2, 0);
            float2 _TilingAndOffset_842a0fc0d8e344abbaf9336f464a4253_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_d445a1988cf3464d9cdb22718df580c5_Out_0, _TilingAndOffset_842a0fc0d8e344abbaf9336f464a4253_Out_3);
            float4 _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.tex, _Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.samplerstate, _TilingAndOffset_842a0fc0d8e344abbaf9336f464a4253_Out_3);
            float _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_R_4 = _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_RGBA_0.r;
            float _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_G_5 = _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_RGBA_0.g;
            float _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_B_6 = _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_RGBA_0.b;
            float _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_A_7 = _SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_RGBA_0.a;
            float _Multiply_bb14b4e6f948428daa8fc5feec2fc0ff_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Split_56558aed0c214082bdcbda09996f7786_G_2, _Multiply_bb14b4e6f948428daa8fc5feec2fc0ff_Out_2);
            float2 _Vector2_c0ac03cb4aae4842a417dc9599aee317_Out_0 = float2(_Multiply_bb14b4e6f948428daa8fc5feec2fc0ff_Out_2, 0);
            float2 _TilingAndOffset_fa1f6c97dd0344db9f4e6e0358110fd9_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_c0ac03cb4aae4842a417dc9599aee317_Out_0, _TilingAndOffset_fa1f6c97dd0344db9f4e6e0358110fd9_Out_3);
            float4 _SampleTexture2D_37188129f1bc479582c29ce50795b405_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.tex, _Property_3f878a90cefa474eb79262c73ddce0e5_Out_0.samplerstate, _TilingAndOffset_fa1f6c97dd0344db9f4e6e0358110fd9_Out_3);
            float _SampleTexture2D_37188129f1bc479582c29ce50795b405_R_4 = _SampleTexture2D_37188129f1bc479582c29ce50795b405_RGBA_0.r;
            float _SampleTexture2D_37188129f1bc479582c29ce50795b405_G_5 = _SampleTexture2D_37188129f1bc479582c29ce50795b405_RGBA_0.g;
            float _SampleTexture2D_37188129f1bc479582c29ce50795b405_B_6 = _SampleTexture2D_37188129f1bc479582c29ce50795b405_RGBA_0.b;
            float _SampleTexture2D_37188129f1bc479582c29ce50795b405_A_7 = _SampleTexture2D_37188129f1bc479582c29ce50795b405_RGBA_0.a;
            float _Multiply_f9bfd9e13f014454b5551569a253e909_Out_2;
            Unity_Multiply_float(_SampleTexture2D_ba8dde7e439a45de967da91547b45d7e_B_6, _SampleTexture2D_37188129f1bc479582c29ce50795b405_B_6, _Multiply_f9bfd9e13f014454b5551569a253e909_Out_2);
            surface.Alpha = _Multiply_f9bfd9e13f014454b5551569a253e909_Out_2;
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
    CustomEditor "SHD_WaterfallsEditor"
    FallBack "Hidden/Shader Graph/FallbackError"
}
