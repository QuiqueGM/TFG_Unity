Shader "DragonCity2/ENV/Clouds"
{
    Properties
    {
        [NoScaleOffset]_MainTex("Main Texture", 2D) = "white" {}
        _AnimFrequency("Anim Frequency", Range(-1, 1)) = 1
        _AnimSpeed("Anim Speed", Range(0, 3)) = 1
        _DepthDistance("Depth Distance", Range(0.001, 10)) = 1
        _TopTint("Top Tint", Color) = (0.1882353, 0.1882353, 0.1882353, 1)
        _BottomTint("Bottom Tint", Color) = (0.1882353, 0.1882353, 0.1882353, 1)
        _FresnelIntensity("Fresnel Intensity", Range(-1, 1)) = 0
        _FresnelPower("Fresnel Power", Range(-2, 2)) = 0
        _FresnelColor("Fresnel  Color", Color) = (0.3019608, 0.3019608, 0.3019608, 1)
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
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
        #define REQUIRE_DEPTH_TEXTURE
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
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
            float4 VertexColor;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
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
            output.interp3.xyzw =  input.color;
            output.interp4.xyz =  input.viewDirectionWS;
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
            output.color = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
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
        float _AnimFrequency;
        float _AnimSpeed;
        float _DepthDistance;
        float4 _TopTint;
        float4 _BottomTint;
        float _FresnelIntensity;
        float _FresnelPower;
        float4 _FresnelColor;
        float _Overbright;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        

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

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Preview_float(float In, out float Out)
        {
            Out = In;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
        {
            float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
            float4 result2 = 2.0 * Base * Blend;
            float4 zeroOrOne = step(Base, 0.5);
            Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
            Out = lerp(Base, Out, Opacity);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
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
            float _Property_9d39f7fdbc214eeda7ab5aa2081d93bc_Out_0 = _AnimSpeed;
            float _Multiply_d00bbce379ba412691ad0e83722f107b_Out_2;
            Unity_Multiply_float(_Property_9d39f7fdbc214eeda7ab5aa2081d93bc_Out_0, IN.TimeParameters.x, _Multiply_d00bbce379ba412691ad0e83722f107b_Out_2);
            float3 _Add_046d3f3af76145e3a5fffc6a52f2d627_Out_2;
            Unity_Add_float3(IN.WorldSpacePosition, (_Multiply_d00bbce379ba412691ad0e83722f107b_Out_2.xxx), _Add_046d3f3af76145e3a5fffc6a52f2d627_Out_2);
            float _SimpleNoise_6c1db57c68634caab5c62b42ac5c1168_Out_2;
            Unity_SimpleNoise_float((_Add_046d3f3af76145e3a5fffc6a52f2d627_Out_2.xy), 1, _SimpleNoise_6c1db57c68634caab5c62b42ac5c1168_Out_2);
            float _Remap_cd88984cdccd4c439d019333e44cf0c8_Out_3;
            Unity_Remap_float(_SimpleNoise_6c1db57c68634caab5c62b42ac5c1168_Out_2, float2 (0, 1), float2 (-1, 1), _Remap_cd88984cdccd4c439d019333e44cf0c8_Out_3);
            float _Property_3cd3dfc854e145578868ba236cc0c28a_Out_0 = _AnimFrequency;
            float _Multiply_b267b8c0de894ea1b30d2a261256d97c_Out_2;
            Unity_Multiply_float(_Remap_cd88984cdccd4c439d019333e44cf0c8_Out_3, _Property_3cd3dfc854e145578868ba236cc0c28a_Out_0, _Multiply_b267b8c0de894ea1b30d2a261256d97c_Out_2);
            float _Split_4bfcd7f997d146f5bf59eec9ea64c746_R_1 = IN.ObjectSpacePosition[0];
            float _Split_4bfcd7f997d146f5bf59eec9ea64c746_G_2 = IN.ObjectSpacePosition[1];
            float _Split_4bfcd7f997d146f5bf59eec9ea64c746_B_3 = IN.ObjectSpacePosition[2];
            float _Split_4bfcd7f997d146f5bf59eec9ea64c746_A_4 = 0;
            float _Add_c1e2910825a744548516ca92090ec9db_Out_2;
            Unity_Add_float(_Multiply_b267b8c0de894ea1b30d2a261256d97c_Out_2, _Split_4bfcd7f997d146f5bf59eec9ea64c746_R_1, _Add_c1e2910825a744548516ca92090ec9db_Out_2);
            float _Add_08ca879e55aa422c9920ab447ecedb95_Out_2;
            Unity_Add_float(_Multiply_b267b8c0de894ea1b30d2a261256d97c_Out_2, _Split_4bfcd7f997d146f5bf59eec9ea64c746_B_3, _Add_08ca879e55aa422c9920ab447ecedb95_Out_2);
            float4 _Combine_c72bf8fac51c48ce9665b81bd40edc28_RGBA_4;
            float3 _Combine_c72bf8fac51c48ce9665b81bd40edc28_RGB_5;
            float2 _Combine_c72bf8fac51c48ce9665b81bd40edc28_RG_6;
            Unity_Combine_float(_Add_c1e2910825a744548516ca92090ec9db_Out_2, _Split_4bfcd7f997d146f5bf59eec9ea64c746_G_2, _Add_08ca879e55aa422c9920ab447ecedb95_Out_2, 0, _Combine_c72bf8fac51c48ce9665b81bd40edc28_RGBA_4, _Combine_c72bf8fac51c48ce9665b81bd40edc28_RGB_5, _Combine_c72bf8fac51c48ce9665b81bd40edc28_RG_6);
            description.Position = (_Combine_c72bf8fac51c48ce9665b81bd40edc28_RGBA_4.xyz);
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
            UnityTexture2D _Property_8fd1b74a4007498e9364a151dae97a69_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
            float4 _SampleTexture2D_0c1189d6f5a746b7ad30778cd5da289c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8fd1b74a4007498e9364a151dae97a69_Out_0.tex, _Property_8fd1b74a4007498e9364a151dae97a69_Out_0.samplerstate, IN.uv0.xy);
            float _SampleTexture2D_0c1189d6f5a746b7ad30778cd5da289c_R_4 = _SampleTexture2D_0c1189d6f5a746b7ad30778cd5da289c_RGBA_0.r;
            float _SampleTexture2D_0c1189d6f5a746b7ad30778cd5da289c_G_5 = _SampleTexture2D_0c1189d6f5a746b7ad30778cd5da289c_RGBA_0.g;
            float _SampleTexture2D_0c1189d6f5a746b7ad30778cd5da289c_B_6 = _SampleTexture2D_0c1189d6f5a746b7ad30778cd5da289c_RGBA_0.b;
            float _SampleTexture2D_0c1189d6f5a746b7ad30778cd5da289c_A_7 = _SampleTexture2D_0c1189d6f5a746b7ad30778cd5da289c_RGBA_0.a;
            float4 _Multiply_4cafb28e404548de907a5f9b4f43d10c_Out_2;
            Unity_Multiply_float(_SampleTexture2D_0c1189d6f5a746b7ad30778cd5da289c_RGBA_0, IN.VertexColor, _Multiply_4cafb28e404548de907a5f9b4f43d10c_Out_2);
            float _Property_1c1e5a25ac074918a72ae18038ecab63_Out_0 = _Overbright;
            float _Preview_a949dc5763d348f2955718ed61da9ba2_Out_1;
            Unity_Preview_float(_Property_1c1e5a25ac074918a72ae18038ecab63_Out_0, _Preview_a949dc5763d348f2955718ed61da9ba2_Out_1);
            float4 _Multiply_dccdb1fea4b8419c9b4dd4f81d79638d_Out_2;
            Unity_Multiply_float(_Multiply_4cafb28e404548de907a5f9b4f43d10c_Out_2, (_Preview_a949dc5763d348f2955718ed61da9ba2_Out_1.xxxx), _Multiply_dccdb1fea4b8419c9b4dd4f81d79638d_Out_2);
            float4 _Property_24520bd5363747aeb7c071308901113a_Out_0 = _TopTint;
            float4 _Property_15ad97bfbe7842fba93e44d8e78b0a85_Out_0 = _BottomTint;
            float _Split_e39e52ba299b449eae0e3417c783cf6e_R_1 = IN.ObjectSpacePosition[0];
            float _Split_e39e52ba299b449eae0e3417c783cf6e_G_2 = IN.ObjectSpacePosition[1];
            float _Split_e39e52ba299b449eae0e3417c783cf6e_B_3 = IN.ObjectSpacePosition[2];
            float _Split_e39e52ba299b449eae0e3417c783cf6e_A_4 = 0;
            float4 _Lerp_f494e6250cfa452a890fbfffb84ed825_Out_3;
            Unity_Lerp_float4(_Property_24520bd5363747aeb7c071308901113a_Out_0, _Property_15ad97bfbe7842fba93e44d8e78b0a85_Out_0, (_Split_e39e52ba299b449eae0e3417c783cf6e_R_1.xxxx), _Lerp_f494e6250cfa452a890fbfffb84ed825_Out_3);
            float4 _Blend_3d65183a6731476ea91f6fb7e20d4e25_Out_2;
            Unity_Blend_Overlay_float4(_Multiply_dccdb1fea4b8419c9b4dd4f81d79638d_Out_2, _Lerp_f494e6250cfa452a890fbfffb84ed825_Out_3, _Blend_3d65183a6731476ea91f6fb7e20d4e25_Out_2, 1);
            float _Property_a29624add78240d08610697424a70dd6_Out_0 = _FresnelIntensity;
            float _Add_73cf7aff4ffe416c821e8fe6577810cb_Out_2;
            Unity_Add_float(_Property_a29624add78240d08610697424a70dd6_Out_0, 1, _Add_73cf7aff4ffe416c821e8fe6577810cb_Out_2);
            float _Absolute_30a172109df243f0a7d5b643c38ee8f2_Out_1;
            Unity_Absolute_float(_Add_73cf7aff4ffe416c821e8fe6577810cb_Out_2, _Absolute_30a172109df243f0a7d5b643c38ee8f2_Out_1);
            float _Power_e9174b9ae2f44ee0bd192347e3fa8fee_Out_2;
            Unity_Power_float(_Absolute_30a172109df243f0a7d5b643c38ee8f2_Out_1, 10, _Power_e9174b9ae2f44ee0bd192347e3fa8fee_Out_2);
            float4 _Property_c9974a65c6064d559cfaaeb35ec7c562_Out_0 = _FresnelColor;
            float4 _Multiply_7f08aa2d263741a08dee652dddf4d57d_Out_2;
            Unity_Multiply_float((_Power_e9174b9ae2f44ee0bd192347e3fa8fee_Out_2.xxxx), _Property_c9974a65c6064d559cfaaeb35ec7c562_Out_0, _Multiply_7f08aa2d263741a08dee652dddf4d57d_Out_2);
            float4 _Property_98ed6217eea641a4810bc6a9ba47c1e1_Out_0 = _FresnelColor;
            float _Property_e5bfc078005e4eb7ab8efbdb29497dbb_Out_0 = _FresnelPower;
            float _Add_6a9e108bb2bd4545ad99feaa47c07ae8_Out_2;
            Unity_Add_float(_Property_e5bfc078005e4eb7ab8efbdb29497dbb_Out_0, 1, _Add_6a9e108bb2bd4545ad99feaa47c07ae8_Out_2);
            float _Multiply_48a118d700624a0b84caf8b6fa097a45_Out_2;
            Unity_Multiply_float(_Add_6a9e108bb2bd4545ad99feaa47c07ae8_Out_2, 0.5, _Multiply_48a118d700624a0b84caf8b6fa097a45_Out_2);
            float _Power_1cf836cdcb3f46f9bea71bd1a2f3dd0e_Out_2;
            Unity_Power_float(10, _Multiply_48a118d700624a0b84caf8b6fa097a45_Out_2, _Power_1cf836cdcb3f46f9bea71bd1a2f3dd0e_Out_2);
            float _FresnelEffect_92a60ec6da1544399b9c4a0d0e91433a_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Power_1cf836cdcb3f46f9bea71bd1a2f3dd0e_Out_2, _FresnelEffect_92a60ec6da1544399b9c4a0d0e91433a_Out_3);
            float4 _Multiply_3d2ea018f92244d7a7b023002ad7e42e_Out_2;
            Unity_Multiply_float(_Property_98ed6217eea641a4810bc6a9ba47c1e1_Out_0, (_FresnelEffect_92a60ec6da1544399b9c4a0d0e91433a_Out_3.xxxx), _Multiply_3d2ea018f92244d7a7b023002ad7e42e_Out_2);
            float4 _Multiply_4c02be23b1a542cd9e1d24611e0a1b4c_Out_2;
            Unity_Multiply_float(_Multiply_7f08aa2d263741a08dee652dddf4d57d_Out_2, _Multiply_3d2ea018f92244d7a7b023002ad7e42e_Out_2, _Multiply_4c02be23b1a542cd9e1d24611e0a1b4c_Out_2);
            float4 _Add_691e2fa29f6f430dab34d504744b5fbf_Out_2;
            Unity_Add_float4(_Blend_3d65183a6731476ea91f6fb7e20d4e25_Out_2, _Multiply_4c02be23b1a542cd9e1d24611e0a1b4c_Out_2, _Add_691e2fa29f6f430dab34d504744b5fbf_Out_2);
            float _Property_5aea71ade7e74b02a9b5b04905061570_Out_0 = _DepthDistance;
            float _SceneDepth_6c34c59ea9984b91aced5501fcc5e5c5_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_6c34c59ea9984b91aced5501fcc5e5c5_Out_1);
            float _Multiply_62ef9066d0f043f1b190d50dd7fdb3e5_Out_2;
            Unity_Multiply_float(_SceneDepth_6c34c59ea9984b91aced5501fcc5e5c5_Out_1, _ProjectionParams.z, _Multiply_62ef9066d0f043f1b190d50dd7fdb3e5_Out_2);
            float4 _ScreenPosition_83424637c6684503b9d73d0153a660db_Out_0 = IN.ScreenPosition;
            float _Split_d853420c036441318b4758de0306ec8b_R_1 = _ScreenPosition_83424637c6684503b9d73d0153a660db_Out_0[0];
            float _Split_d853420c036441318b4758de0306ec8b_G_2 = _ScreenPosition_83424637c6684503b9d73d0153a660db_Out_0[1];
            float _Split_d853420c036441318b4758de0306ec8b_B_3 = _ScreenPosition_83424637c6684503b9d73d0153a660db_Out_0[2];
            float _Split_d853420c036441318b4758de0306ec8b_A_4 = _ScreenPosition_83424637c6684503b9d73d0153a660db_Out_0[3];
            float _Subtract_5167b06c256541438c4915925cea2ae3_Out_2;
            Unity_Subtract_float(_Multiply_62ef9066d0f043f1b190d50dd7fdb3e5_Out_2, _Split_d853420c036441318b4758de0306ec8b_A_4, _Subtract_5167b06c256541438c4915925cea2ae3_Out_2);
            float _Multiply_7e956687b5b24a93a389b65c3ece8fe2_Out_2;
            Unity_Multiply_float(_Property_5aea71ade7e74b02a9b5b04905061570_Out_0, _Subtract_5167b06c256541438c4915925cea2ae3_Out_2, _Multiply_7e956687b5b24a93a389b65c3ece8fe2_Out_2);
            float _Saturate_0691b124985d4119a2667b842f143a2c_Out_1;
            Unity_Saturate_float(_Multiply_7e956687b5b24a93a389b65c3ece8fe2_Out_2, _Saturate_0691b124985d4119a2667b842f143a2c_Out_1);
            float _Preview_f40620465f4844f2a9f8895194793694_Out_1;
            Unity_Preview_float(_Saturate_0691b124985d4119a2667b842f143a2c_Out_1, _Preview_f40620465f4844f2a9f8895194793694_Out_1);
            surface.BaseColor = (_Add_691e2fa29f6f430dab34d504744b5fbf_Out_2.xyz);
            surface.Alpha = _Preview_f40620465f4844f2a9f8895194793694_Out_1;
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


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
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
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
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
            float3 positionWS;
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
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
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
        float _AnimFrequency;
        float _AnimSpeed;
        float _DepthDistance;
        float4 _TopTint;
        float4 _BottomTint;
        float _FresnelIntensity;
        float _FresnelPower;
        float4 _FresnelColor;
        float _Overbright;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);

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

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Preview_float(float In, out float Out)
        {
            Out = In;
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
            float _Property_9d39f7fdbc214eeda7ab5aa2081d93bc_Out_0 = _AnimSpeed;
            float _Multiply_d00bbce379ba412691ad0e83722f107b_Out_2;
            Unity_Multiply_float(_Property_9d39f7fdbc214eeda7ab5aa2081d93bc_Out_0, IN.TimeParameters.x, _Multiply_d00bbce379ba412691ad0e83722f107b_Out_2);
            float3 _Add_046d3f3af76145e3a5fffc6a52f2d627_Out_2;
            Unity_Add_float3(IN.WorldSpacePosition, (_Multiply_d00bbce379ba412691ad0e83722f107b_Out_2.xxx), _Add_046d3f3af76145e3a5fffc6a52f2d627_Out_2);
            float _SimpleNoise_6c1db57c68634caab5c62b42ac5c1168_Out_2;
            Unity_SimpleNoise_float((_Add_046d3f3af76145e3a5fffc6a52f2d627_Out_2.xy), 1, _SimpleNoise_6c1db57c68634caab5c62b42ac5c1168_Out_2);
            float _Remap_cd88984cdccd4c439d019333e44cf0c8_Out_3;
            Unity_Remap_float(_SimpleNoise_6c1db57c68634caab5c62b42ac5c1168_Out_2, float2 (0, 1), float2 (-1, 1), _Remap_cd88984cdccd4c439d019333e44cf0c8_Out_3);
            float _Property_3cd3dfc854e145578868ba236cc0c28a_Out_0 = _AnimFrequency;
            float _Multiply_b267b8c0de894ea1b30d2a261256d97c_Out_2;
            Unity_Multiply_float(_Remap_cd88984cdccd4c439d019333e44cf0c8_Out_3, _Property_3cd3dfc854e145578868ba236cc0c28a_Out_0, _Multiply_b267b8c0de894ea1b30d2a261256d97c_Out_2);
            float _Split_4bfcd7f997d146f5bf59eec9ea64c746_R_1 = IN.ObjectSpacePosition[0];
            float _Split_4bfcd7f997d146f5bf59eec9ea64c746_G_2 = IN.ObjectSpacePosition[1];
            float _Split_4bfcd7f997d146f5bf59eec9ea64c746_B_3 = IN.ObjectSpacePosition[2];
            float _Split_4bfcd7f997d146f5bf59eec9ea64c746_A_4 = 0;
            float _Add_c1e2910825a744548516ca92090ec9db_Out_2;
            Unity_Add_float(_Multiply_b267b8c0de894ea1b30d2a261256d97c_Out_2, _Split_4bfcd7f997d146f5bf59eec9ea64c746_R_1, _Add_c1e2910825a744548516ca92090ec9db_Out_2);
            float _Add_08ca879e55aa422c9920ab447ecedb95_Out_2;
            Unity_Add_float(_Multiply_b267b8c0de894ea1b30d2a261256d97c_Out_2, _Split_4bfcd7f997d146f5bf59eec9ea64c746_B_3, _Add_08ca879e55aa422c9920ab447ecedb95_Out_2);
            float4 _Combine_c72bf8fac51c48ce9665b81bd40edc28_RGBA_4;
            float3 _Combine_c72bf8fac51c48ce9665b81bd40edc28_RGB_5;
            float2 _Combine_c72bf8fac51c48ce9665b81bd40edc28_RG_6;
            Unity_Combine_float(_Add_c1e2910825a744548516ca92090ec9db_Out_2, _Split_4bfcd7f997d146f5bf59eec9ea64c746_G_2, _Add_08ca879e55aa422c9920ab447ecedb95_Out_2, 0, _Combine_c72bf8fac51c48ce9665b81bd40edc28_RGBA_4, _Combine_c72bf8fac51c48ce9665b81bd40edc28_RGB_5, _Combine_c72bf8fac51c48ce9665b81bd40edc28_RG_6);
            description.Position = (_Combine_c72bf8fac51c48ce9665b81bd40edc28_RGBA_4.xyz);
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
            float _Property_5aea71ade7e74b02a9b5b04905061570_Out_0 = _DepthDistance;
            float _SceneDepth_6c34c59ea9984b91aced5501fcc5e5c5_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_6c34c59ea9984b91aced5501fcc5e5c5_Out_1);
            float _Multiply_62ef9066d0f043f1b190d50dd7fdb3e5_Out_2;
            Unity_Multiply_float(_SceneDepth_6c34c59ea9984b91aced5501fcc5e5c5_Out_1, _ProjectionParams.z, _Multiply_62ef9066d0f043f1b190d50dd7fdb3e5_Out_2);
            float4 _ScreenPosition_83424637c6684503b9d73d0153a660db_Out_0 = IN.ScreenPosition;
            float _Split_d853420c036441318b4758de0306ec8b_R_1 = _ScreenPosition_83424637c6684503b9d73d0153a660db_Out_0[0];
            float _Split_d853420c036441318b4758de0306ec8b_G_2 = _ScreenPosition_83424637c6684503b9d73d0153a660db_Out_0[1];
            float _Split_d853420c036441318b4758de0306ec8b_B_3 = _ScreenPosition_83424637c6684503b9d73d0153a660db_Out_0[2];
            float _Split_d853420c036441318b4758de0306ec8b_A_4 = _ScreenPosition_83424637c6684503b9d73d0153a660db_Out_0[3];
            float _Subtract_5167b06c256541438c4915925cea2ae3_Out_2;
            Unity_Subtract_float(_Multiply_62ef9066d0f043f1b190d50dd7fdb3e5_Out_2, _Split_d853420c036441318b4758de0306ec8b_A_4, _Subtract_5167b06c256541438c4915925cea2ae3_Out_2);
            float _Multiply_7e956687b5b24a93a389b65c3ece8fe2_Out_2;
            Unity_Multiply_float(_Property_5aea71ade7e74b02a9b5b04905061570_Out_0, _Subtract_5167b06c256541438c4915925cea2ae3_Out_2, _Multiply_7e956687b5b24a93a389b65c3ece8fe2_Out_2);
            float _Saturate_0691b124985d4119a2667b842f143a2c_Out_1;
            Unity_Saturate_float(_Multiply_7e956687b5b24a93a389b65c3ece8fe2_Out_2, _Saturate_0691b124985d4119a2667b842f143a2c_Out_1);
            float _Preview_f40620465f4844f2a9f8895194793694_Out_1;
            Unity_Preview_float(_Saturate_0691b124985d4119a2667b842f143a2c_Out_1, _Preview_f40620465f4844f2a9f8895194793694_Out_1);
            surface.Alpha = _Preview_f40620465f4844f2a9f8895194793694_Out_1;
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
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
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
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define REQUIRE_DEPTH_TEXTURE
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
            float3 positionWS;
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
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
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
        float _AnimFrequency;
        float _AnimSpeed;
        float _DepthDistance;
        float4 _TopTint;
        float4 _BottomTint;
        float _FresnelIntensity;
        float _FresnelPower;
        float4 _FresnelColor;
        float _Overbright;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);

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

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Preview_float(float In, out float Out)
        {
            Out = In;
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
            float _Property_9d39f7fdbc214eeda7ab5aa2081d93bc_Out_0 = _AnimSpeed;
            float _Multiply_d00bbce379ba412691ad0e83722f107b_Out_2;
            Unity_Multiply_float(_Property_9d39f7fdbc214eeda7ab5aa2081d93bc_Out_0, IN.TimeParameters.x, _Multiply_d00bbce379ba412691ad0e83722f107b_Out_2);
            float3 _Add_046d3f3af76145e3a5fffc6a52f2d627_Out_2;
            Unity_Add_float3(IN.WorldSpacePosition, (_Multiply_d00bbce379ba412691ad0e83722f107b_Out_2.xxx), _Add_046d3f3af76145e3a5fffc6a52f2d627_Out_2);
            float _SimpleNoise_6c1db57c68634caab5c62b42ac5c1168_Out_2;
            Unity_SimpleNoise_float((_Add_046d3f3af76145e3a5fffc6a52f2d627_Out_2.xy), 1, _SimpleNoise_6c1db57c68634caab5c62b42ac5c1168_Out_2);
            float _Remap_cd88984cdccd4c439d019333e44cf0c8_Out_3;
            Unity_Remap_float(_SimpleNoise_6c1db57c68634caab5c62b42ac5c1168_Out_2, float2 (0, 1), float2 (-1, 1), _Remap_cd88984cdccd4c439d019333e44cf0c8_Out_3);
            float _Property_3cd3dfc854e145578868ba236cc0c28a_Out_0 = _AnimFrequency;
            float _Multiply_b267b8c0de894ea1b30d2a261256d97c_Out_2;
            Unity_Multiply_float(_Remap_cd88984cdccd4c439d019333e44cf0c8_Out_3, _Property_3cd3dfc854e145578868ba236cc0c28a_Out_0, _Multiply_b267b8c0de894ea1b30d2a261256d97c_Out_2);
            float _Split_4bfcd7f997d146f5bf59eec9ea64c746_R_1 = IN.ObjectSpacePosition[0];
            float _Split_4bfcd7f997d146f5bf59eec9ea64c746_G_2 = IN.ObjectSpacePosition[1];
            float _Split_4bfcd7f997d146f5bf59eec9ea64c746_B_3 = IN.ObjectSpacePosition[2];
            float _Split_4bfcd7f997d146f5bf59eec9ea64c746_A_4 = 0;
            float _Add_c1e2910825a744548516ca92090ec9db_Out_2;
            Unity_Add_float(_Multiply_b267b8c0de894ea1b30d2a261256d97c_Out_2, _Split_4bfcd7f997d146f5bf59eec9ea64c746_R_1, _Add_c1e2910825a744548516ca92090ec9db_Out_2);
            float _Add_08ca879e55aa422c9920ab447ecedb95_Out_2;
            Unity_Add_float(_Multiply_b267b8c0de894ea1b30d2a261256d97c_Out_2, _Split_4bfcd7f997d146f5bf59eec9ea64c746_B_3, _Add_08ca879e55aa422c9920ab447ecedb95_Out_2);
            float4 _Combine_c72bf8fac51c48ce9665b81bd40edc28_RGBA_4;
            float3 _Combine_c72bf8fac51c48ce9665b81bd40edc28_RGB_5;
            float2 _Combine_c72bf8fac51c48ce9665b81bd40edc28_RG_6;
            Unity_Combine_float(_Add_c1e2910825a744548516ca92090ec9db_Out_2, _Split_4bfcd7f997d146f5bf59eec9ea64c746_G_2, _Add_08ca879e55aa422c9920ab447ecedb95_Out_2, 0, _Combine_c72bf8fac51c48ce9665b81bd40edc28_RGBA_4, _Combine_c72bf8fac51c48ce9665b81bd40edc28_RGB_5, _Combine_c72bf8fac51c48ce9665b81bd40edc28_RG_6);
            description.Position = (_Combine_c72bf8fac51c48ce9665b81bd40edc28_RGBA_4.xyz);
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
            float _Property_5aea71ade7e74b02a9b5b04905061570_Out_0 = _DepthDistance;
            float _SceneDepth_6c34c59ea9984b91aced5501fcc5e5c5_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_6c34c59ea9984b91aced5501fcc5e5c5_Out_1);
            float _Multiply_62ef9066d0f043f1b190d50dd7fdb3e5_Out_2;
            Unity_Multiply_float(_SceneDepth_6c34c59ea9984b91aced5501fcc5e5c5_Out_1, _ProjectionParams.z, _Multiply_62ef9066d0f043f1b190d50dd7fdb3e5_Out_2);
            float4 _ScreenPosition_83424637c6684503b9d73d0153a660db_Out_0 = IN.ScreenPosition;
            float _Split_d853420c036441318b4758de0306ec8b_R_1 = _ScreenPosition_83424637c6684503b9d73d0153a660db_Out_0[0];
            float _Split_d853420c036441318b4758de0306ec8b_G_2 = _ScreenPosition_83424637c6684503b9d73d0153a660db_Out_0[1];
            float _Split_d853420c036441318b4758de0306ec8b_B_3 = _ScreenPosition_83424637c6684503b9d73d0153a660db_Out_0[2];
            float _Split_d853420c036441318b4758de0306ec8b_A_4 = _ScreenPosition_83424637c6684503b9d73d0153a660db_Out_0[3];
            float _Subtract_5167b06c256541438c4915925cea2ae3_Out_2;
            Unity_Subtract_float(_Multiply_62ef9066d0f043f1b190d50dd7fdb3e5_Out_2, _Split_d853420c036441318b4758de0306ec8b_A_4, _Subtract_5167b06c256541438c4915925cea2ae3_Out_2);
            float _Multiply_7e956687b5b24a93a389b65c3ece8fe2_Out_2;
            Unity_Multiply_float(_Property_5aea71ade7e74b02a9b5b04905061570_Out_0, _Subtract_5167b06c256541438c4915925cea2ae3_Out_2, _Multiply_7e956687b5b24a93a389b65c3ece8fe2_Out_2);
            float _Saturate_0691b124985d4119a2667b842f143a2c_Out_1;
            Unity_Saturate_float(_Multiply_7e956687b5b24a93a389b65c3ece8fe2_Out_2, _Saturate_0691b124985d4119a2667b842f143a2c_Out_1);
            float _Preview_f40620465f4844f2a9f8895194793694_Out_1;
            Unity_Preview_float(_Saturate_0691b124985d4119a2667b842f143a2c_Out_1, _Preview_f40620465f4844f2a9f8895194793694_Out_1);
            surface.Alpha = _Preview_f40620465f4844f2a9f8895194793694_Out_1;
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
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
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
