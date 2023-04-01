
Shader "DragonCity2/VFX/Fresnel"
{
	Properties
	{
		_Texture("Texture", 2D) = "black" {}
		_FresnelContrast("Fresnel Contrast", Float) = 1
		_EmissiveFactor("Emissive Factor", Float) = 1
		[Enum(UnityEngine.Rendering.CullMode)]_Culling("Culling", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" "RenderType"="Transparent" }
		LOD 100

		CGINCLUDE
		#pragma target 2.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		Cull [_Culling]
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		Offset 0 , 0

		Pass
		{
			Name "Unlit"
            Tags { "LightMode" = "UniversalForward" }
			HLSLPROGRAM

			#pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

            //user defined variables

            TEXTURE2D(_Texture);            SAMPLER(sampler_Texture);

            CBUFFER_START(UnityPerMaterial)
            uniform half _Culling;
			uniform half _EmissiveFactor;
			uniform half _FresnelContrast;
			uniform half4 _Texture_ST;
			CBUFFER_END

            struct Attributes
            {
                half4 vertex            : POSITION;
				half4 color             : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				half3 ase_normal        : NORMAL;
				half4 ase_texcoord      : TEXCOORD0;
            };

            struct Varyings
            {
                half4 positionCS        : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				half4 ase_texcoord      : TEXCOORD0;
				half4 ase_texcoord1     : TEXCOORD1;
				half4 ase_texcoord2     : TEXCOORD2;
				half4 ase_color         : COLOR;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
				UNITY_TRANSFER_INSTANCE_ID(input, output);



				half4 vertex = input.vertex;
				half3 ase_worldPos = mul(unity_ObjectToWorld, vertex).xyz;
				output.ase_texcoord.xyz = ase_worldPos;
				half3 ase_worldNormal = TransformObjectToWorldDir(input.ase_normal);
				output.ase_texcoord1.xyz = ase_worldNormal;

				output.ase_texcoord2.xy = input.ase_texcoord.xy;
				output.ase_color = input.color;

				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord.w = 0;
				output.ase_texcoord1.w = 0;
				output.ase_texcoord2.zw = 0;
				half3 vertexValue =  float3(0,0,0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertex.xyz = vertexValue;
				#else
				vertex.xyz += vertexValue;
				#endif



                VertexPositionInputs vertexInput = GetVertexPositionInputs(vertex.xyz);

                output.positionCS = vertexInput.positionCS;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
				half4 finalColor;
				half3 ase_worldPos = input.ase_texcoord.xyz;
				half3 ase_worldViewDir = GetWorldSpaceNormalizeViewDir(ase_worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				half3 ase_worldNormal = input.ase_texcoord1.xyz;
				half fresnelNdotV1 = dot( ase_worldNormal, ase_worldViewDir );
				half fresnelNode1 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV1, _FresnelContrast ) );
				half3 temp_cast_0 = (fresnelNode1).xxx;
				half2 uv_Texture = input.ase_texcoord2.xy * _Texture_ST.xy + _Texture_ST.zw;
				half4 tex2DNode6 = SAMPLE_TEXTURE2D(_Texture, sampler_Texture, uv_Texture);
				half3 lerpResult13 = lerp( temp_cast_0 , (tex2DNode6).rgb , tex2DNode6.r);
				half lerpResult18 = lerp( fresnelNode1 , 1.0 , tex2DNode6.r);
				half4 appendResult9 = (half4(( _EmissiveFactor * ( lerpResult13 * (input.ase_color).rgb ) ) , ( lerpResult18 * input.ase_color.a )));

				finalColor = appendResult9;

				return finalColor;
            };

            ENDHLSL
		}
	}

	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100

		CGINCLUDE
		#pragma target 2.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		Cull [_Culling]
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		Offset 0 , 0

		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
		//only defining to not throw compilation error over Unity 5.5
		#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				half3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
			};

			uniform half _Culling;
			uniform half _EmissiveFactor;
			uniform half _FresnelContrast;
			uniform sampler2D _Texture;
			uniform half4 _Texture_ST;

			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord.xyz = ase_worldPos;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_color = v.color;

				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.zw = 0;
				float3 vertexValue =  float3(0,0,0) ;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				float3 ase_worldPos = i.ase_texcoord.xyz;
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float fresnelNdotV1 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode1 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV1, _FresnelContrast ) );
				half3 temp_cast_0 = (fresnelNode1).xxx;
				float2 uv_Texture = i.ase_texcoord2.xy * _Texture_ST.xy + _Texture_ST.zw;
				half4 tex2DNode6 = tex2D( _Texture, uv_Texture );
				float3 lerpResult13 = lerp( temp_cast_0 , (tex2DNode6).rgb , tex2DNode6.r);
				float lerpResult18 = lerp( fresnelNode1 , 1.0 , tex2DNode6.r);
				float4 appendResult9 = (half4(( _EmissiveFactor * ( lerpResult13 * (i.ase_color).rgb ) ) , ( lerpResult18 * i.ase_color.a )));


				finalColor = appendResult9;
				return finalColor;
			}
			ENDCG
		}
	}

	CustomEditor "ASEMaterialInspector"
}
