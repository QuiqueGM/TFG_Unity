// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Test/SHD_ENV_CubempToCube"
{
    Properties
    {
        _Cubemap ("Cubemap", Cube) = "" {}
    }

    SubShader
    {
        Pass
        {
            Cull Front 

            CGPROGRAM
 
            #pragma vertex vert  
            #pragma fragment frag
 
            uniform samplerCUBE _Cubemap;  
 
            struct vertexInput {
            float4 vertex : POSITION;
            };
            struct vertexOutput {
            float4 pos : SV_POSITION;
            float3 texDir : TEXCOORD0;
            };
 
            vertexOutput vert(vertexInput input)
            {
            vertexOutput output;
 
            output.texDir = input.vertex;
            output.pos = UnityObjectToClipPos(input.vertex);
            return output;
            }
 
            float4 frag(vertexOutput input) : COLOR
            {
            return texCUBE(_Cubemap, input.texDir);
            }
 
            ENDCG
        }
    }
}
