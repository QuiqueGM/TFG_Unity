Shader "socialPointCG/URP/General/Unlit_Shadows"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _ShadowStrength("Shadow Strength", Range(0, 1)) = 0.5

        [HideInInspector] _BCSHTintColor ("BCSH Tint Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _SHADOWS_SOFT

            #pragma shader_feature SHADER_MODULE_BCSH
            #pragma shader_feature SHADER_MODULE_BCSH_ADD_UNIFORMS

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #ifdef SHADER_MODULE_BCSH
            #define SHADER_MODULE_BCSH_ADD_UNIFORMS
            #include "Assets/Resources/Shaders/Includes/ShaderModuleBCSH.hlsl"
            #endif

            struct Attributes
            {
                half4 positionOS : POSITION;
                half2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                half4 positionCS               : SV_POSITION;
                half3 positionWS               : TEXCOORD0;
                half2 uv                       : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
			half4 _MainTex_ST;
            CBUFFER_END
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);

            half4 _BCSHTintColor;
            half _ShadowStrength;

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = vertexInput.positionCS;
                output.positionWS = vertexInput.positionWS;
                output.uv = input.texcoord;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);

            #ifdef _MAIN_LIGHT_SHADOWS
                VertexPositionInputs vertexInput = (VertexPositionInputs)0;
                vertexInput.positionWS = input.positionWS;

                float4 shadowCoord = GetShadowCoord(vertexInput);
                half shadowAttenutation = MainLightRealtimeShadow(shadowCoord);
                color.rgb = lerp(color.rgb, color.rgb * 0.5, (1.0 - shadowAttenutation) * color.a * _ShadowStrength);
            #endif

            #ifdef SHADER_MODULE_BCSH
                ApplyModuleBCSH_half(color, _BCSHTintColor, color);
            #endif

                return color;
            }
            ENDHLSL
        }
    }

    Fallback "Universal Render Pipeline/UnLit"
}
