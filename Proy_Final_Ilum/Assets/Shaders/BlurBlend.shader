Shader "Hidden/BlurBlend"
{
    Properties
    {
        _BlurSize ("Blur Size", Range(0, 1)) = 0.0
        _Blend ("Blend Amount", Range(0, 1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            float _BlurSize;
            float _Blend;

            half4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float2 uv = input.texcoord;
                
                half4 originalColor = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv);
                
                if (_BlurSize <= 0.001 && _Blend <= 0.001) 
                {
                    return originalColor;
                }

                float actualBlurRadius = _BlurSize * 10;
                float2 texelSize = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y) * actualBlurRadius;
                
                //box blur muestreamos el centro y sus 8 vecinos
                half4 blurredColor = 0;
                blurredColor += SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv + float2(-1, -1) * texelSize);
                blurredColor += SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv + float2( 0, -1) * texelSize);
                blurredColor += SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv + float2( 1, -1) * texelSize);
                blurredColor += SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv + float2(-1,  0) * texelSize);
                blurredColor += originalColor; //centro
                blurredColor += SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv + float2( 1,  0) * texelSize);
                blurredColor += SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv + float2(-1,  1) * texelSize);
                blurredColor += SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv + float2( 0,  1) * texelSize);
                blurredColor += SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv + float2( 1,  1) * texelSize);
                
                blurredColor /= 9.0;
                
                float autoBlurOpacity = saturate(_BlurSize);
                half4 baseImage = lerp(originalColor, blurredColor, autoBlurOpacity);

               return baseImage + (blurredColor * _Blend);
            }
            ENDHLSL
        }
    }
}