Shader "DragonCity2/VFX/Uv anim/Blend"
{
    Properties
    {
        _MainTex("DiffuseMap (ch1)", 2D) = "white" {}
        _MK("MaskMap (ch1) (red channel is alpha mask)", 2D) = "red" {}
        _LM("MaskMap 2 (ch1) (red channel is alpha mask)", 2D) = "red" {}
        _Overbright("Overbright", Float) = 1.0
        [Toggle(USE_VC)] _UseVC("Vertex Color multiply", Float) = 1
        [Toggle(USE_FOG)] _UseFog("Use Fog", Float) = 0

        [Space]
        [Header(Extra features for this variant)]
        [Header(Main layer scroll)]
        _ScrollMain("X/Y Speed Z/W Tiling",Vector) = (0,0,1,1)
        [Header(Secondary layer scroll)]
        [Toggle(USE_SECONDARY_LAYER)] _UseSecondaryLayer("Use Second Layer", Float) = 0
        _ScrollSec("X/Y Speed Z/W Tiling",Vector) = (0,0,1,1)

        [Toggle(DepthWrite)]_ZWrite("DepthWrite", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull mode", Int) = 2.0
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType"="Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        ZTest LEqual
        ZWrite [_ZWrite]
        Cull [_Cull]

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma shader_feature USE_FOG
            #pragma shader_feature USE_VC
            #pragma shader_feature USE_SECONDARY_LAYER

            #include "Assets/Resources/Shaders/Includes/Sh_UvAnim.hlsl"

            ENDHLSL
        }
    }
}
