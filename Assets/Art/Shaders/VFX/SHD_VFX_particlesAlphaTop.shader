// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "DragonCity2/VFX/sCG_Fx_particlesAlphaTop_BLEND" {
	Properties {
		_MainTex ("Diffuse map", 2D) = "white" {}
	}

	SubShader {
		// INI TAGS & PROPERTIES ------------------------------------------------------------------------------------------------------------------------------------

		Tags {
			//- HELP: http://docs.unity3d.com/Manual/SL-SubshaderTags.html

			//"Queue"="Background " 	// this render queue is rendered before any others. It is used for skyboxes and the like.
			//"Queue"="Geometry" 		// (default) - this is used for most objects. Opaque geometry uses this queue.
			//"Queue"="AlphaTest" 		// alpha tested geometry uses this queue.
			"Queue"="Transparent+10" 	// alpha blend pixels here!
			//"Queue"="Overlay" 		// Anything rendered last should go in overlays i.e. lens flares


			//- HELP: http://docs.unity3d.com/Manual/SL-PassTags.html

			"LightMode" = "UniversalForward" 			// Always rendered; no lighting is applied.
			//"LightMode" = "ForwardBase"		// Used in Forward rendering, ambient, main directional light and vertex/SH lights are applied.
			//"LightMode" = "ForwardAdd"		// Used in Forward rendering; additive per-pixel lights are applied, one pass per light.
			//"LightMode" = "Pixel"				// ??
			//"LightMode" = "PrepassBase"		// deferred only...
			//"LightMode" = "PrepassFinal"		// deferred only...
			//"LightMode" = "Vertex"			// Used in Vertex Lit rendering when object is not lightmapped; all vertex lights are applied.
			//"LightMode" = "VertexLMRGBM"		// VertexLMRGBM: Used in Vertex Lit rendering when object is lightmapped; on platforms where lightmap is RGBM encoded.
			//"LightMode" = "VertexLM"			// Used in Vertex Lit rendering when object is lightmapped; on platforms where lightmap is double-LDR encoded (generally mobile platforms and old dekstop GPUs).
			//"LightMode" = "ShadowCaster"		// Renders object as shadow caster.
			//"LightMode" = "ShadowCollector"	// Gathers object’s shadows into screen-space buffer for Forward rendering path.


			//"IgnoreProjector"="True"
		}

		//- HELP: http://docs.unity3d.com/Manual/SL-Blend.html

		Blend SrcAlpha OneMinusSrcAlpha 	// Alpha blending
		//Blend One One 					// Additive
		//Blend OneMinusDstColor One 		// Soft Additive (screen)
		//Blend DstColor Zero 				// Multiplicative

		Fog {Mode Off} // MODE: Off | Global | Linear | Exp | Exp

		//- HELP: http://docs.unity3d.com/Manual/SL-Pass.html

	    Lighting OFF 	//Turn vertex lighting on or off
	    ZWrite OFF	//Set depth writing mode
	    Cull OFF 		//Back | Front | Off = two sided
		ZTest Always  //Always = paint always front (Less | Greater | LEqual | GEqual | Equal | NotEqual | Always)
		//AlphaTest  	//(Less | Greater | LEqual | GEqual | Equal | NotEqual | Always) CutoffValue

		//ZTest Always

		// END TAGS & PROPERTIES ------------------------------------------------------------------------------------------------------------------------------------

		Pass
	    {
            HLSLPROGRAM
		    #pragma vertex vert
		    #pragma fragment frag
		    #pragma target 2.0

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

	        struct Attributes
            {
                half4 positionOS                : POSITION;
                half4 color                     : COLOR;
                half2 texcoord                  : TEXCOORD0;
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
            CBUFFER_END
		    TEXTURE2D(_MainTex);
		    SAMPLER(sampler_MainTex);

		    Varyings vert(Attributes input)
		    {
		        Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

			    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = vertexInput.positionCS;
			    output.texcoord = TRANSFORM_TEX(input.texcoord, _MainTex);
                output.color = input.color;

			    return output;
		    }

            half4 frag(Varyings IN) : COLOR
		    {
			    half4 Complete = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.texcoord);

			    half inverseVertexColorAlpha = (1.0 - IN.color.a);

			    half3 CombineColor = half3(IN.color.r - inverseVertexColorAlpha, IN.color.g - inverseVertexColorAlpha, IN.color.b - inverseVertexColorAlpha);

			    return half4(Complete.rgb * IN.color.rgb, Complete.a * IN.color.a);
		    }

		    ENDHLSL
        }
	}
}
