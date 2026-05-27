Shader "Hidden/MortalSinOutlines"
{
    Properties
    {
        _OutlineIntensity ("Outline Intensity", Range(0, 1)) = 1.0
        _OutlineThickness ("Outline Thickness", Float) = 2.0
        _DepthThreshold ("Depth Threshold", Float) = 1.0
        _MaxDistance ("Fade Distance", Float) = 30.0
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            float _OutlineIntensity;
            float _OutlineThickness;
            float _DepthThreshold;
            float _MaxDistance;

            half4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float2 uv = input.texcoord;
                
                //leer el color 
                half4 color = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv);
                
              float dCenterRaw = SampleSceneDepth(uv);

                // anti-cielo
                if (dCenterRaw < 0.00001) 
                {
                    return color;
                }

                float2 texelSize = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y) * _OutlineThickness;

                float dUpRaw     = SampleSceneDepth(uv + float2(0.0, texelSize.y));
                float dDownRaw   = SampleSceneDepth(uv + float2(0.0, -texelSize.y));
                float dLeftRaw   = SampleSceneDepth(uv + float2(-texelSize.x, 0.0));
                float dRightRaw  = SampleSceneDepth(uv + float2(texelSize.x, 0.0));

                //convertir a metros reales
                float dCenter = LinearEyeDepth(dCenterRaw, _ZBufferParams);
                float dUp     = LinearEyeDepth(dUpRaw, _ZBufferParams);
                float dDown   = LinearEyeDepth(dDownRaw, _ZBufferParams);
                float dLeft   = LinearEyeDepth(dLeftRaw, _ZBufferParams);
                float dRight  = LinearEyeDepth(dRightRaw, _ZBufferParams);
                
                //calcular el salto total
                float edge = abs(dCenter - dUp) + abs(dCenter - dDown) + abs(dCenter - dLeft) + abs(dCenter - dRight);
                
                //multiplicamos dCenter por sí mismo para compensar la perspectiva exagerada del suelo
               float adjustedThreshold = _DepthThreshold * (dCenter * dCenter * 0.01 + 0.05);

                float isEdge = step(adjustedThreshold, edge);
                
                //si estamos a la mitad de la distancia maxima empieza a borrar las lineas suavemente
               float distanceFade = 1.0 - smoothstep(_MaxDistance * 0.5, _MaxDistance, dCenter);
                
                isEdge *= _OutlineIntensity * distanceFade;
                
                return lerp(color, half4(0, 0, 0, 1), isEdge);
            }
            ENDHLSL
        }
    }
}