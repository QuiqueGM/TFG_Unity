Shader "socialPointCG/URP/UI/RenderTargetReceiver_URP"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _MaskTex ("Mask", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0

        [HideInInspector] _BCSHTintColor ("BCSH Tint Color", Color) = (1,1,1,1)
        [HideInInspector] _GradientIdx ("Photoshop Gradient Idx", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #pragma multi_compile __ UNITY_UI_ALPHACLIP

            #pragma shader_feature SHADER_MODULE_BCSH
            #pragma shader_feature FORCED_ALPHA

            struct Attributes
            {
                half4 positionOS : POSITION;
                half4 color    : COLOR;
                half2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                half4 positionCS                : SV_POSITION;
                half4 color                     : COLOR;
                half3 positionWS                : TEXCOORD0;
                half2 texcoord                  : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
			half4 _MainTex_ST;
            half4 _Color;
            CBUFFER_END
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
            TEXTURE2D(_MaskTex);
			SAMPLER(sampler_MaskTex);

            half4 _TextureSampleAdd;
            half4 _BCSHTintColor;

            #ifdef SHADER_MODULE_BCSH
            #include "Assets/Resources/Shaders/Includes/ShaderModuleBCSH.hlsl"
            #endif

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = vertexInput.positionCS;
                output.positionWS = vertexInput.positionWS;
                output.texcoord = TRANSFORM_TEX(input.texcoord, _MainTex);
                output.color = input.color * _Color;

                return output;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = (SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
                half4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, IN.texcoord);

                color.a *= mask.a;

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                #ifdef SHADER_MODULE_BCSH
                ApplyModuleBCSH_half(color, _BCSHTintColor, color);
                #endif

                #ifdef FORCED_ALPHA
                color.a = 1;
                #endif

                return color;
            }
            ENDHLSL
        }
    }
}
