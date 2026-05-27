Shader "Hidden/MortalSinFilter"
{
    Properties
    {
        //scanlines
        _ScanlinesIntensity ("Scanlines Intensity", Range(0, 1)) = 1.0

        //gradient
        _GradientsEnabled ("Gradients Enabled", Range(0, 1)) = 0.0
        _GradientSteps ("Gradient Steps", Float) = 4.0
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

            
            float _ScanlinesIntensity;

            float _GradientsEnabled;
            float _GradientSteps;

            half4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float2 uv = input.texcoord;
                
                //obtenemos el color original del juego
                half4 color = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv);

                //gradient posterizacion
                float3 posterizedColor = floor(color.rgb * _GradientSteps) / _GradientSteps;

                color.rgb = lerp(color.rgb, posterizedColor, _GradientsEnabled);
                
                //scanlines: usamos _ScreenParams.y para que las lineas sean del tamaño de 1 pixel
                //multiplicamos usamos el seno para crear un patron de ondas horizontales
                float wave = sin(uv.y * _ScreenParams.y * 2.5);
                float waveNormalized = (wave + 1.0) * 0.5;
                
                //remapeamos la onda para que oscurezca un poco
                float scanlineMultiplier = lerp(0.6, 1.0, waveNormalized);
                
                //si _ScanlinesIntensity es 0 usamos 1.0 (sin efecto) y si es 1 usamos el patron
                float finalScanline = lerp(1.0, scanlineMultiplier, _ScanlinesIntensity);

                color *= finalScanline;
                
                return color;
            }
            ENDHLSL
        }
    }
}