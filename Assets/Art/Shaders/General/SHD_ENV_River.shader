Shader "DragonCity2/ENV/River"
{
    Properties
    {
        [NoScaleOffset]_Mask("Mask", 2D) = "white" {}
        _MidColor("Mid Color", Color) = (0.3215686, 0.6862745, 0.8862746, 1)
        _DownColor("Shore Color", Color) = (1, 1, 1, 1)
        _Threshold("Threshold", Range(0, 20)) = 1
        _Edge("Edge", Range(0, 10)) = 1
        _FoamColor("Foam Color", Color) = (0.8313726, 0.8313726, 0.8313726, 1)
        _FoamShore("Foam Shore", Vector) = (1, 1, 0, 1)
        _AnimOverall("Anim Overall", Range(0, 1)) = 1
        _AnimSpeed("Anim Speed", Range(0, 10)) = 1
        _AnimFrequency("Anim Frequency", Range(-1, 1)) = 0.3
        //[HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        //[HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        //[HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
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
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
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
            float3 WorldSpacePosition;
            float4 VertexColor;
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
        float4 _Mask_TexelSize;
        float4 _MidColor;
        float4 _DownColor;
        float _Threshold;
        float _Edge;
        float4 _FoamColor;
        float4 _FoamShore;
        float _AnimOverall;
        float _AnimSpeed;
        float _AnimFrequency;
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

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
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

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Blend_Difference_float(float Base, float Blend, out float Out, float Opacity)
        {
            Out = abs(Blend - Base);
            Out = lerp(Base, Out, Opacity);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Preview_float4(float4 In, out float4 Out)
        {
            Out = In;
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
            float _Property_65a8a91311b44887acfb14661d02c91a_Out_0 = _AnimSpeed;
            float _Multiply_218f69d9fbfe4492875058aef8b7fcfc_Out_2;
            Unity_Multiply_float(_Property_65a8a91311b44887acfb14661d02c91a_Out_0, IN.TimeParameters.x, _Multiply_218f69d9fbfe4492875058aef8b7fcfc_Out_2);
            float3 _Add_7d0949541c4d420faa84fb2bf37c186c_Out_2;
            Unity_Add_float3(IN.WorldSpacePosition, (_Multiply_218f69d9fbfe4492875058aef8b7fcfc_Out_2.xxx), _Add_7d0949541c4d420faa84fb2bf37c186c_Out_2);
            float _SimpleNoise_cfcc5fedefb24baba52474b599b7feef_Out_2;
            Unity_SimpleNoise_float((_Add_7d0949541c4d420faa84fb2bf37c186c_Out_2.xy), 1, _SimpleNoise_cfcc5fedefb24baba52474b599b7feef_Out_2);
            float _Remap_a77daf14089d4a2f9c16436c38f705c2_Out_3;
            Unity_Remap_float(_SimpleNoise_cfcc5fedefb24baba52474b599b7feef_Out_2, float2 (0, 1), float2 (-1, 1), _Remap_a77daf14089d4a2f9c16436c38f705c2_Out_3);
            float _Property_3b41071045a0461bb35a9276b067ca72_Out_0 = _AnimFrequency;
            float _Multiply_980c5e3b5f884be18f6c9b770a08ce21_Out_2;
            Unity_Multiply_float(_Remap_a77daf14089d4a2f9c16436c38f705c2_Out_3, _Property_3b41071045a0461bb35a9276b067ca72_Out_0, _Multiply_980c5e3b5f884be18f6c9b770a08ce21_Out_2);
            float _Property_1cf31d923ef14a4681113e6f4500abf6_Out_0 = _AnimOverall;
            float4 _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2;
            Unity_Multiply_float((_Property_1cf31d923ef14a4681113e6f4500abf6_Out_0.xxxx), IN.VertexColor, _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2);
            float _Split_8ebfb054556c40cbaa0b9b7829f74c15_R_1 = _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2[0];
            float _Split_8ebfb054556c40cbaa0b9b7829f74c15_G_2 = _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2[1];
            float _Split_8ebfb054556c40cbaa0b9b7829f74c15_B_3 = _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2[2];
            float _Split_8ebfb054556c40cbaa0b9b7829f74c15_A_4 = _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2[3];
            float _Multiply_8d99d113bc214350b316ba166ae74400_Out_2;
            Unity_Multiply_float(_Multiply_980c5e3b5f884be18f6c9b770a08ce21_Out_2, _Split_8ebfb054556c40cbaa0b9b7829f74c15_G_2, _Multiply_8d99d113bc214350b316ba166ae74400_Out_2);
            float _Split_a024714bec7c430daedd26da01f965fa_R_1 = IN.ObjectSpacePosition[0];
            float _Split_a024714bec7c430daedd26da01f965fa_G_2 = IN.ObjectSpacePosition[1];
            float _Split_a024714bec7c430daedd26da01f965fa_B_3 = IN.ObjectSpacePosition[2];
            float _Split_a024714bec7c430daedd26da01f965fa_A_4 = 0;
            float _Add_65d400517ed941c7892172fba3701399_Out_2;
            Unity_Add_float(_Multiply_8d99d113bc214350b316ba166ae74400_Out_2, _Split_a024714bec7c430daedd26da01f965fa_R_1, _Add_65d400517ed941c7892172fba3701399_Out_2);
            float _Multiply_efb4e3a277cf4cefba297c8b106ec6e2_Out_2;
            Unity_Multiply_float(_Multiply_980c5e3b5f884be18f6c9b770a08ce21_Out_2, _Split_8ebfb054556c40cbaa0b9b7829f74c15_G_2, _Multiply_efb4e3a277cf4cefba297c8b106ec6e2_Out_2);
            float _Add_cfebc3f4133a49bc99ce0c2df8f33b7f_Out_2;
            Unity_Add_float(_Split_a024714bec7c430daedd26da01f965fa_B_3, _Multiply_efb4e3a277cf4cefba297c8b106ec6e2_Out_2, _Add_cfebc3f4133a49bc99ce0c2df8f33b7f_Out_2);
            float4 _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RGBA_4;
            float3 _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RGB_5;
            float2 _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RG_6;
            Unity_Combine_float(_Add_65d400517ed941c7892172fba3701399_Out_2, _Split_a024714bec7c430daedd26da01f965fa_G_2, _Add_cfebc3f4133a49bc99ce0c2df8f33b7f_Out_2, 0, _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RGBA_4, _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RGB_5, _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RG_6);
            description.Position = (_Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RGBA_4.xyz);
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
            float4 _Property_d7374fb015344ef98a70e74469e0abdb_Out_0 = _MidColor;
            float4 _Property_cbff7a245d0144c7a0d6ed9528407f84_Out_0 = _DownColor;
            float4 _UV_5a81c32cd287457e87b4f85500034137_Out_0 = IN.uv0;
            float _Split_60ce20ead5bd43a7bd5375a0e70c64e5_R_1 = _UV_5a81c32cd287457e87b4f85500034137_Out_0[0];
            float _Split_60ce20ead5bd43a7bd5375a0e70c64e5_G_2 = _UV_5a81c32cd287457e87b4f85500034137_Out_0[1];
            float _Split_60ce20ead5bd43a7bd5375a0e70c64e5_B_3 = _UV_5a81c32cd287457e87b4f85500034137_Out_0[2];
            float _Split_60ce20ead5bd43a7bd5375a0e70c64e5_A_4 = _UV_5a81c32cd287457e87b4f85500034137_Out_0[3];
            float _OneMinus_8ea30c2c746c4054b519c845ea0a4a89_Out_1;
            Unity_OneMinus_float(_Split_60ce20ead5bd43a7bd5375a0e70c64e5_R_1, _OneMinus_8ea30c2c746c4054b519c845ea0a4a89_Out_1);
            float _Blend_a3fd93addb334192b9e54b92cd68dfb1_Out_2;
            Unity_Blend_Difference_float(_Split_60ce20ead5bd43a7bd5375a0e70c64e5_R_1, _OneMinus_8ea30c2c746c4054b519c845ea0a4a89_Out_1, _Blend_a3fd93addb334192b9e54b92cd68dfb1_Out_2, 1);
            float _Property_070465d6803f4a2b9fe099157283f0b2_Out_0 = _Threshold;
            float _Power_04f18a4fb2bf4f32b0eb3d29ab9ef627_Out_2;
            Unity_Power_float(_Blend_a3fd93addb334192b9e54b92cd68dfb1_Out_2, _Property_070465d6803f4a2b9fe099157283f0b2_Out_0, _Power_04f18a4fb2bf4f32b0eb3d29ab9ef627_Out_2);
            float _Property_e8914ad34c8b4212b3f064d86da034ad_Out_0 = _Edge;
            float _Multiply_6ba0d27e506443388d256cf57c4391d7_Out_2;
            Unity_Multiply_float(_Power_04f18a4fb2bf4f32b0eb3d29ab9ef627_Out_2, _Property_e8914ad34c8b4212b3f064d86da034ad_Out_0, _Multiply_6ba0d27e506443388d256cf57c4391d7_Out_2);
            float4 _Lerp_9ba671136c89432596c30846c8534da3_Out_3;
            Unity_Lerp_float4(_Property_d7374fb015344ef98a70e74469e0abdb_Out_0, _Property_cbff7a245d0144c7a0d6ed9528407f84_Out_0, (_Multiply_6ba0d27e506443388d256cf57c4391d7_Out_2.xxxx), _Lerp_9ba671136c89432596c30846c8534da3_Out_3);
            UnityTexture2D _Property_b4318a99f1ce417bb2ffb42132be0497_Out_0 = UnityBuildTexture2DStructNoScale(_Mask);
            float4 _Property_6160b5c585224811b7688fab096c8bf5_Out_0 = _FoamShore;
            float _Split_8f76f11849f2413ebc13e1d7ed81353d_R_1 = _Property_6160b5c585224811b7688fab096c8bf5_Out_0[0];
            float _Split_8f76f11849f2413ebc13e1d7ed81353d_G_2 = _Property_6160b5c585224811b7688fab096c8bf5_Out_0[1];
            float _Split_8f76f11849f2413ebc13e1d7ed81353d_B_3 = _Property_6160b5c585224811b7688fab096c8bf5_Out_0[2];
            float _Split_8f76f11849f2413ebc13e1d7ed81353d_A_4 = _Property_6160b5c585224811b7688fab096c8bf5_Out_0[3];
            float2 _Vector2_3dac657ac7c845869a79432c5f262072_Out_0 = float2(_Split_8f76f11849f2413ebc13e1d7ed81353d_R_1, _Split_8f76f11849f2413ebc13e1d7ed81353d_G_2);
            float _Multiply_79b353cc84c64085971a0cbeedb5469a_Out_2;
            Unity_Multiply_float(_Split_8f76f11849f2413ebc13e1d7ed81353d_B_3, IN.TimeParameters.x, _Multiply_79b353cc84c64085971a0cbeedb5469a_Out_2);
            float _Multiply_b4e2bc3740c54f579b6c1717b9052d70_Out_2;
            Unity_Multiply_float(_Split_8f76f11849f2413ebc13e1d7ed81353d_A_4, IN.TimeParameters.x, _Multiply_b4e2bc3740c54f579b6c1717b9052d70_Out_2);
            float2 _Vector2_863ba9dab95c4a1a8b10bd4c4af37e24_Out_0 = float2(_Multiply_79b353cc84c64085971a0cbeedb5469a_Out_2, _Multiply_b4e2bc3740c54f579b6c1717b9052d70_Out_2);
            float2 _TilingAndOffset_b11ae9f135184b0fb3308d540b4e1dd8_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_3dac657ac7c845869a79432c5f262072_Out_0, _Vector2_863ba9dab95c4a1a8b10bd4c4af37e24_Out_0, _TilingAndOffset_b11ae9f135184b0fb3308d540b4e1dd8_Out_3);
            float4 _SampleTexture2D_57b4f2cc3baf486281c4def03790ec47_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b4318a99f1ce417bb2ffb42132be0497_Out_0.tex, _Property_b4318a99f1ce417bb2ffb42132be0497_Out_0.samplerstate, _TilingAndOffset_b11ae9f135184b0fb3308d540b4e1dd8_Out_3);
            float _SampleTexture2D_57b4f2cc3baf486281c4def03790ec47_R_4 = _SampleTexture2D_57b4f2cc3baf486281c4def03790ec47_RGBA_0.r;
            float _SampleTexture2D_57b4f2cc3baf486281c4def03790ec47_G_5 = _SampleTexture2D_57b4f2cc3baf486281c4def03790ec47_RGBA_0.g;
            float _SampleTexture2D_57b4f2cc3baf486281c4def03790ec47_B_6 = _SampleTexture2D_57b4f2cc3baf486281c4def03790ec47_RGBA_0.b;
            float _SampleTexture2D_57b4f2cc3baf486281c4def03790ec47_A_7 = _SampleTexture2D_57b4f2cc3baf486281c4def03790ec47_RGBA_0.a;
            float _Multiply_a1c63e1e7a934449a9bedaab4d7df769_Out_2;
            Unity_Multiply_float(_Multiply_6ba0d27e506443388d256cf57c4391d7_Out_2, _SampleTexture2D_57b4f2cc3baf486281c4def03790ec47_R_4, _Multiply_a1c63e1e7a934449a9bedaab4d7df769_Out_2);
            float4 _Property_16f45c0cd9a740c6942d7980ece2262e_Out_0 = _FoamColor;
            float4 _Multiply_e0b9cb618f174e0889238061ee0f0d99_Out_2;
            Unity_Multiply_float((_Multiply_a1c63e1e7a934449a9bedaab4d7df769_Out_2.xxxx), _Property_16f45c0cd9a740c6942d7980ece2262e_Out_0, _Multiply_e0b9cb618f174e0889238061ee0f0d99_Out_2);
            float4 _Lerp_898ac5cefa6d40f281f0e9e1661418ac_Out_3;
            Unity_Lerp_float4(_Lerp_9ba671136c89432596c30846c8534da3_Out_3, (_Multiply_a1c63e1e7a934449a9bedaab4d7df769_Out_2.xxxx), _Multiply_e0b9cb618f174e0889238061ee0f0d99_Out_2, _Lerp_898ac5cefa6d40f281f0e9e1661418ac_Out_3);
            float4 _Preview_0bbd4539ef0847f6907ac88012a0b3c7_Out_1;
            Unity_Preview_float4(_Lerp_898ac5cefa6d40f281f0e9e1661418ac_Out_3, _Preview_0bbd4539ef0847f6907ac88012a0b3c7_Out_1);
            Bindings_SGFog_6fda06a5a255f8244a0881200c0efc1c _SGFog_bc0c68b7fbfe494d869662621f5876d5;
            _SGFog_bc0c68b7fbfe494d869662621f5876d5.ObjectSpacePosition = IN.ObjectSpacePosition;
            float4 _SGFog_bc0c68b7fbfe494d869662621f5876d5_OutVector4_1;
            SG_SGFog_6fda06a5a255f8244a0881200c0efc1c(_Preview_0bbd4539ef0847f6907ac88012a0b3c7_Out_1, _SGFog_bc0c68b7fbfe494d869662621f5876d5, _SGFog_bc0c68b7fbfe494d869662621f5876d5_OutVector4_1);
            surface.BaseColor = (_SGFog_bc0c68b7fbfe494d869662621f5876d5_OutVector4_1.xyz);
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
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_COLOR
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
            float4 color : COLOR;
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
            float3 WorldSpacePosition;
            float4 VertexColor;
            float3 TimeParameters;
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
        float4 _Mask_TexelSize;
        float4 _MidColor;
        float4 _DownColor;
        float _Threshold;
        float _Edge;
        float4 _FoamColor;
        float4 _FoamShore;
        float _AnimOverall;
        float _AnimSpeed;
        float _AnimFrequency;
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

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
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

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
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
            float _Property_65a8a91311b44887acfb14661d02c91a_Out_0 = _AnimSpeed;
            float _Multiply_218f69d9fbfe4492875058aef8b7fcfc_Out_2;
            Unity_Multiply_float(_Property_65a8a91311b44887acfb14661d02c91a_Out_0, IN.TimeParameters.x, _Multiply_218f69d9fbfe4492875058aef8b7fcfc_Out_2);
            float3 _Add_7d0949541c4d420faa84fb2bf37c186c_Out_2;
            Unity_Add_float3(IN.WorldSpacePosition, (_Multiply_218f69d9fbfe4492875058aef8b7fcfc_Out_2.xxx), _Add_7d0949541c4d420faa84fb2bf37c186c_Out_2);
            float _SimpleNoise_cfcc5fedefb24baba52474b599b7feef_Out_2;
            Unity_SimpleNoise_float((_Add_7d0949541c4d420faa84fb2bf37c186c_Out_2.xy), 1, _SimpleNoise_cfcc5fedefb24baba52474b599b7feef_Out_2);
            float _Remap_a77daf14089d4a2f9c16436c38f705c2_Out_3;
            Unity_Remap_float(_SimpleNoise_cfcc5fedefb24baba52474b599b7feef_Out_2, float2 (0, 1), float2 (-1, 1), _Remap_a77daf14089d4a2f9c16436c38f705c2_Out_3);
            float _Property_3b41071045a0461bb35a9276b067ca72_Out_0 = _AnimFrequency;
            float _Multiply_980c5e3b5f884be18f6c9b770a08ce21_Out_2;
            Unity_Multiply_float(_Remap_a77daf14089d4a2f9c16436c38f705c2_Out_3, _Property_3b41071045a0461bb35a9276b067ca72_Out_0, _Multiply_980c5e3b5f884be18f6c9b770a08ce21_Out_2);
            float _Property_1cf31d923ef14a4681113e6f4500abf6_Out_0 = _AnimOverall;
            float4 _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2;
            Unity_Multiply_float((_Property_1cf31d923ef14a4681113e6f4500abf6_Out_0.xxxx), IN.VertexColor, _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2);
            float _Split_8ebfb054556c40cbaa0b9b7829f74c15_R_1 = _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2[0];
            float _Split_8ebfb054556c40cbaa0b9b7829f74c15_G_2 = _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2[1];
            float _Split_8ebfb054556c40cbaa0b9b7829f74c15_B_3 = _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2[2];
            float _Split_8ebfb054556c40cbaa0b9b7829f74c15_A_4 = _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2[3];
            float _Multiply_8d99d113bc214350b316ba166ae74400_Out_2;
            Unity_Multiply_float(_Multiply_980c5e3b5f884be18f6c9b770a08ce21_Out_2, _Split_8ebfb054556c40cbaa0b9b7829f74c15_G_2, _Multiply_8d99d113bc214350b316ba166ae74400_Out_2);
            float _Split_a024714bec7c430daedd26da01f965fa_R_1 = IN.ObjectSpacePosition[0];
            float _Split_a024714bec7c430daedd26da01f965fa_G_2 = IN.ObjectSpacePosition[1];
            float _Split_a024714bec7c430daedd26da01f965fa_B_3 = IN.ObjectSpacePosition[2];
            float _Split_a024714bec7c430daedd26da01f965fa_A_4 = 0;
            float _Add_65d400517ed941c7892172fba3701399_Out_2;
            Unity_Add_float(_Multiply_8d99d113bc214350b316ba166ae74400_Out_2, _Split_a024714bec7c430daedd26da01f965fa_R_1, _Add_65d400517ed941c7892172fba3701399_Out_2);
            float _Multiply_efb4e3a277cf4cefba297c8b106ec6e2_Out_2;
            Unity_Multiply_float(_Multiply_980c5e3b5f884be18f6c9b770a08ce21_Out_2, _Split_8ebfb054556c40cbaa0b9b7829f74c15_G_2, _Multiply_efb4e3a277cf4cefba297c8b106ec6e2_Out_2);
            float _Add_cfebc3f4133a49bc99ce0c2df8f33b7f_Out_2;
            Unity_Add_float(_Split_a024714bec7c430daedd26da01f965fa_B_3, _Multiply_efb4e3a277cf4cefba297c8b106ec6e2_Out_2, _Add_cfebc3f4133a49bc99ce0c2df8f33b7f_Out_2);
            float4 _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RGBA_4;
            float3 _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RGB_5;
            float2 _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RG_6;
            Unity_Combine_float(_Add_65d400517ed941c7892172fba3701399_Out_2, _Split_a024714bec7c430daedd26da01f965fa_G_2, _Add_cfebc3f4133a49bc99ce0c2df8f33b7f_Out_2, 0, _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RGBA_4, _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RGB_5, _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RG_6);
            description.Position = (_Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RGBA_4.xyz);
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
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.VertexColor =                 input.color;
            output.TimeParameters =              _TimeParameters.xyz;

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
        //#pragma multi_compile _ DOTS_INSTANCING_ON
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
            #define ATTRIBUTES_NEED_COLOR
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
            float4 color : COLOR;
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
            float3 WorldSpacePosition;
            float4 VertexColor;
            float3 TimeParameters;
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
        float4 _Mask_TexelSize;
        float4 _MidColor;
        float4 _DownColor;
        float _Threshold;
        float _Edge;
        float4 _FoamColor;
        float4 _FoamShore;
        float _AnimOverall;
        float _AnimSpeed;
        float _AnimFrequency;
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

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
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

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
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
            float _Property_65a8a91311b44887acfb14661d02c91a_Out_0 = _AnimSpeed;
            float _Multiply_218f69d9fbfe4492875058aef8b7fcfc_Out_2;
            Unity_Multiply_float(_Property_65a8a91311b44887acfb14661d02c91a_Out_0, IN.TimeParameters.x, _Multiply_218f69d9fbfe4492875058aef8b7fcfc_Out_2);
            float3 _Add_7d0949541c4d420faa84fb2bf37c186c_Out_2;
            Unity_Add_float3(IN.WorldSpacePosition, (_Multiply_218f69d9fbfe4492875058aef8b7fcfc_Out_2.xxx), _Add_7d0949541c4d420faa84fb2bf37c186c_Out_2);
            float _SimpleNoise_cfcc5fedefb24baba52474b599b7feef_Out_2;
            Unity_SimpleNoise_float((_Add_7d0949541c4d420faa84fb2bf37c186c_Out_2.xy), 1, _SimpleNoise_cfcc5fedefb24baba52474b599b7feef_Out_2);
            float _Remap_a77daf14089d4a2f9c16436c38f705c2_Out_3;
            Unity_Remap_float(_SimpleNoise_cfcc5fedefb24baba52474b599b7feef_Out_2, float2 (0, 1), float2 (-1, 1), _Remap_a77daf14089d4a2f9c16436c38f705c2_Out_3);
            float _Property_3b41071045a0461bb35a9276b067ca72_Out_0 = _AnimFrequency;
            float _Multiply_980c5e3b5f884be18f6c9b770a08ce21_Out_2;
            Unity_Multiply_float(_Remap_a77daf14089d4a2f9c16436c38f705c2_Out_3, _Property_3b41071045a0461bb35a9276b067ca72_Out_0, _Multiply_980c5e3b5f884be18f6c9b770a08ce21_Out_2);
            float _Property_1cf31d923ef14a4681113e6f4500abf6_Out_0 = _AnimOverall;
            float4 _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2;
            Unity_Multiply_float((_Property_1cf31d923ef14a4681113e6f4500abf6_Out_0.xxxx), IN.VertexColor, _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2);
            float _Split_8ebfb054556c40cbaa0b9b7829f74c15_R_1 = _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2[0];
            float _Split_8ebfb054556c40cbaa0b9b7829f74c15_G_2 = _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2[1];
            float _Split_8ebfb054556c40cbaa0b9b7829f74c15_B_3 = _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2[2];
            float _Split_8ebfb054556c40cbaa0b9b7829f74c15_A_4 = _Multiply_b7e3fd634f964b15a6828a2b62c58acd_Out_2[3];
            float _Multiply_8d99d113bc214350b316ba166ae74400_Out_2;
            Unity_Multiply_float(_Multiply_980c5e3b5f884be18f6c9b770a08ce21_Out_2, _Split_8ebfb054556c40cbaa0b9b7829f74c15_G_2, _Multiply_8d99d113bc214350b316ba166ae74400_Out_2);
            float _Split_a024714bec7c430daedd26da01f965fa_R_1 = IN.ObjectSpacePosition[0];
            float _Split_a024714bec7c430daedd26da01f965fa_G_2 = IN.ObjectSpacePosition[1];
            float _Split_a024714bec7c430daedd26da01f965fa_B_3 = IN.ObjectSpacePosition[2];
            float _Split_a024714bec7c430daedd26da01f965fa_A_4 = 0;
            float _Add_65d400517ed941c7892172fba3701399_Out_2;
            Unity_Add_float(_Multiply_8d99d113bc214350b316ba166ae74400_Out_2, _Split_a024714bec7c430daedd26da01f965fa_R_1, _Add_65d400517ed941c7892172fba3701399_Out_2);
            float _Multiply_efb4e3a277cf4cefba297c8b106ec6e2_Out_2;
            Unity_Multiply_float(_Multiply_980c5e3b5f884be18f6c9b770a08ce21_Out_2, _Split_8ebfb054556c40cbaa0b9b7829f74c15_G_2, _Multiply_efb4e3a277cf4cefba297c8b106ec6e2_Out_2);
            float _Add_cfebc3f4133a49bc99ce0c2df8f33b7f_Out_2;
            Unity_Add_float(_Split_a024714bec7c430daedd26da01f965fa_B_3, _Multiply_efb4e3a277cf4cefba297c8b106ec6e2_Out_2, _Add_cfebc3f4133a49bc99ce0c2df8f33b7f_Out_2);
            float4 _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RGBA_4;
            float3 _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RGB_5;
            float2 _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RG_6;
            Unity_Combine_float(_Add_65d400517ed941c7892172fba3701399_Out_2, _Split_a024714bec7c430daedd26da01f965fa_G_2, _Add_cfebc3f4133a49bc99ce0c2df8f33b7f_Out_2, 0, _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RGBA_4, _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RGB_5, _Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RG_6);
            description.Position = (_Combine_6ae839fdd7bd4719a76f697bfbdef9b5_RGBA_4.xyz);
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
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.VertexColor =                 input.color;
            output.TimeParameters =              _TimeParameters.xyz;

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
