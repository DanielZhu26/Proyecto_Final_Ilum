Shader "Hidden/MortalSinFilter"
{
    Properties
    {
        _PixelSize ("Pixel Size", Range(1, 10)) = 3.0

        //scanlines
        _ScanlinesIntensity ("Scanlines Intensity", Range(0, 1)) = 1.0

        //gradient
        _GradientsEnabled ("Gradients Enabled", Range(0, 1)) = 0.0
        _GradientSteps ("Gradient Steps", Float) = 4.0
        _DitherEnabled ("Dithering Enabled", Range(0, 1)) = 0.0
        _DitherSpread ("Dither Spread", Float) = 1.0

        //grain
        _GrainIntensity ("Grain Intensity", Range(0, 1)) = 0.0

        //ajustes color
       _Contrast ("Contrast", Range(0, 1)) = 0.5
       _Brightness ("Brightness", Range(0, 1)) = 0.5
       _Saturation ("Saturation", Range(0, 1)) = 0.5

       //paleta de colores
       _PaletteEnabled ("Palette Enabled", Range(0, 1)) = 0.0
       _Color0 ("Darkest Color", Color) = (0, 0, 0, 1)
       _Color1 ("Dark Color", Color) = (0.3, 0.1, 0.1, 1)
       _Color2 ("Light Color", Color) = (0.8, 0.2, 0.2, 1)
       _Color3 ("Lightest Color", Color) = (1, 1, 1, 1)

       //luz
       _LumaThreshold1 ("Shadow Cutoff", Range(0.0, 1.0)) = 0.25
       _LumaThreshold2 ("Midtone Cutoff", Range(0.0, 1.0)) = 0.50
       _LumaThreshold3 ("Highlight Cutoff", Range(0.0, 1.0)) = 0.75
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

            float _PixelSize;
            
            float _ScanlinesIntensity;

            float _GradientsEnabled;
            float _GradientSteps;
            float _DitherEnabled;
            float _DitherSpread;

            float _GrainIntensity;

            float _Contrast;
            float _Brightness;
            float _Saturation;

            float _PaletteEnabled;
            half4 _Color0;
            half4 _Color1;
            half4 _Color2;
            half4 _Color3;

            float _LumaThreshold1;
            float _LumaThreshold2;
            float _LumaThreshold3;

            //ruido aleatorio
            float rand(float2 uv)
            {
                //formula para sacar numeros pseudorandom
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            //crea el patron de "puntitos" en la pantalla.
            float Bayer2x2(int2 pixelPos)
            {
                int x = pixelPos.x % 2;
                int y = pixelPos.y % 2;
                float bayerValues[4] = { 0.0, 0.5, 0.75, 0.25 };
                return bayerValues[x + (y * 2)] - 0.5;
            }

            half4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float2 uv = input.texcoord;
                
                float pSize = max(1.0, floor(_PixelSize));
                float2 virtualResolution = _ScreenParams.xy / pSize;
                // Redondeamos las coordenadas UV para forzar la lectura en bloques cuadrados
                float2 pixelatedUV = floor(uv * virtualResolution) / virtualResolution;
                
                // Calculamos el índice exacto (X, Y) del "píxel gordo" para los demás efectos
                int2 virtualPixelPos = int2(pixelatedUV.x * virtualResolution.x, pixelatedUV.y * virtualResolution.y);

                //obtenemos el color original del juego
                half4 color = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, pixelatedUV);

                //dithering
                float ditherPattern = Bayer2x2(virtualPixelPos) * _DitherSpread;
                float3 ditheredColor = color.rgb + (ditherPattern * _DitherEnabled);
                color.rgb = lerp(color.rgb, ditheredColor, _DitherEnabled);

                //gradient posterizacion
                float3 posterizedColor = floor(color.rgb * _GradientSteps) / _GradientSteps;
                color.rgb = lerp(color.rgb, posterizedColor, _GradientsEnabled);

                //calculamos la luminosidad final despues del Dither y Gradients
                float finalLum = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
                
                //asignamos el color dependiendo de en que escalon caiga la luz 
                float3 palettedColor = _Color0.rgb;
                palettedColor = lerp(palettedColor, _Color1.rgb, step(_LumaThreshold1, finalLum));
                palettedColor = lerp(palettedColor, _Color2.rgb, step(_LumaThreshold2, finalLum));
                palettedColor = lerp(palettedColor, _Color3.rgb, step(_LumaThreshold3, finalLum));
                
                color.rgb = lerp(color.rgb, palettedColor, _PaletteEnabled); 

                //convertimos el 0.5 del slider en el 1.0 real para q se vea bien en el slider
                float actualBrightness = _Brightness * 2.0;
                float actualContrast = _Contrast * 2.0;
                float actualSaturation = _Saturation * 2.0;
                //brillo
                color.rgb *= actualBrightness;
                
                //contraste
                color.rgb = lerp(half3(0.5, 0.5, 0.5), color.rgb, actualContrast);
                
                //saturacion
                //pesos del ojo humano para el rojo verde y azul que suman 1 xq no vemos 
                //todos los colores con la misma intensidad
                float luminance = dot(color.rgb, float3(0.2126, 0.7152, 0.0722));
                color.rgb = lerp(half3(luminance, luminance, luminance), color.rgb, actualSaturation);

                color.rgb = saturate(color.rgb);

                //scanlines: usamos _ScreenParams.y para que las lineas sean del tamaño de 1 pixel
                //multiplicamos usamos el seno para crear un patron de ondas horizontales
                float wave = sin(uv.y * _ScreenParams.y * 2.5);
                float waveNormalized = (wave + 1.0) * 0.5;
                
                //remapeamos la onda para que oscurezca un poco
               float scanlineMultiplier = (virtualPixelPos.y % 2 == 0) ? 0.6 : 1.0;
                
                //si _ScanlinesIntensity es 0 usamos 1.0 (sin efecto) y si es 1 usamos el patron
                float finalScanline = lerp(1.0, scanlineMultiplier, _ScanlinesIntensity);
                color *= finalScanline;

                //grain: generamos un valor aleatorio animado por el tiempo y se lo sumamos al colo final en pantalla 
                float noise = rand(pixelatedUV + _Time.y);
                float grainNoise = (noise - 0.5) * 0.5;
                color.rgb += grainNoise * _GrainIntensity;

                return color;
            }
            ENDHLSL
        }
    }
}