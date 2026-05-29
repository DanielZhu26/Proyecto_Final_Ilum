using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;


[System.Serializable]
public struct ColorPalette
{
    public string paletteName;
    public Color darkestColor; 
    public Color darkColor;   
    public Color lightColor;   
    public Color lightestColor;
}

public class VisualSettingsController : MonoBehaviour
{
    [Header("Sombras")]
    public Light mainDirectionalLight;
    public Toggle shadowsToggle;

    [Header("Scanlines")]
    public Material mortalSinMaterial; 
    public Toggle scanlinesToggle;

    [Header("Outlines")]
    public Material outlinesMaterial;
    public Toggle outlinesToggle;

    [Header("Gradients")]
    public Toggle gradientsToggle;
    public Slider pixelSizeSlider;
    public GameObject pixelSizeContainer;

    [Header("Blur/Blend")]
    public Material blurBlendMaterial;
    public Slider blurSlider;
    public Slider blendSlider;

    [Header("Grain")]
    public Slider grainSlider;

    [Header("Contrast")]
    public Slider contrastSlider;

    [Header("Brightness")]
    public Slider brightnessSlider;

    [Header("Saturation")]
    public Slider saturationSlider;

    [Header("Paletas de Color")]
    public ColorPalette[] availablePalettes; 

    void Start()
    {
        //shadows
        if (mainDirectionalLight != null && shadowsToggle != null)
        {
            shadowsToggle.isOn = mainDirectionalLight.shadows != LightShadows.None;

            shadowsToggle.onValueChanged.AddListener(SetShadows);
        }

        //outlines
        if (outlinesMaterial != null && outlinesToggle != null)
        {
            outlinesToggle.isOn = outlinesMaterial.GetFloat("_OutlineIntensity") > 0.5f;
            outlinesToggle.onValueChanged.AddListener(SetOutlines);
        }

        //blur y blend
        if (blurBlendMaterial != null && blurSlider != null && blendSlider != null)
        {
            blurSlider.value = blurBlendMaterial.GetFloat("_BlurSize");
            blendSlider.value = blurBlendMaterial.GetFloat("_Blend");

            // Escuchamos los cambios
            blurSlider.onValueChanged.AddListener(SetBlur);
            blendSlider.onValueChanged.AddListener(SetBlend);
        }

        if (mortalSinMaterial != null)
        {
            mortalSinMaterial.SetFloat("_PaletteEnabled", 0.0f);

            //scanlines
            if (scanlinesToggle != null)
            {
                scanlinesToggle.isOn = mortalSinMaterial.GetFloat("_ScanlinesIntensity") > 0.5f;
                scanlinesToggle.onValueChanged.AddListener(SetScanlines);
            }

            //gradients y pixel size
            if (gradientsToggle != null)
            {
                bool isGradientsOn = mortalSinMaterial.GetFloat("_GradientsEnabled") > 0.5f;
                gradientsToggle.isOn = isGradientsOn;
                gradientsToggle.onValueChanged.AddListener(SetGradients);

                if (pixelSizeContainer != null)
                {
                    pixelSizeContainer.SetActive(isGradientsOn);
                }
            }

            if (pixelSizeSlider != null)
            {
                pixelSizeSlider.value = mortalSinMaterial.GetFloat("_PixelSize");
                pixelSizeSlider.onValueChanged.AddListener(SetPixelSize);
            }

            //grain
            if (grainSlider != null)
            {
                grainSlider.value = mortalSinMaterial.GetFloat("_GrainIntensity");
                grainSlider.onValueChanged.AddListener(SetGrain);
            }

            //color grading
            if (contrastSlider != null)
            {
                contrastSlider.value = mortalSinMaterial.GetFloat("_Contrast");
                contrastSlider.onValueChanged.AddListener(SetContrast);
            }
            if (brightnessSlider != null)
            {
                brightnessSlider.value = mortalSinMaterial.GetFloat("_Brightness");
                brightnessSlider.onValueChanged.AddListener(SetBrightness);
            }
            if (saturationSlider != null)
            {
                saturationSlider.value = mortalSinMaterial.GetFloat("_Saturation");
                saturationSlider.onValueChanged.AddListener(SetSaturation);
            }
        }


    }

    //desactiva/activa las sombras en la luz principal
    private void SetShadows(bool isEnabled)
    {
        if (mainDirectionalLight != null)
        {
            mainDirectionalLight.shadows = isEnabled ? LightShadows.Soft : LightShadows.None;
        }
    }

    private void SetScanlines(bool isEnabled)
    {
        if (mortalSinMaterial != null)
        {
            mortalSinMaterial.SetFloat("_ScanlinesIntensity", isEnabled ? 1.0f : 0.0f);
        }
    }

    private void SetOutlines(bool isEnabled)
    {
        if (outlinesMaterial != null)
            outlinesMaterial.SetFloat("_OutlineIntensity", isEnabled ? 1.0f : 0.0f);
    }

    private void SetGradients(bool isEnabled)
    {
        if (mortalSinMaterial != null)
        {
            mortalSinMaterial.SetFloat("_GradientsEnabled", isEnabled ? 1.0f : 0.0f);
            mortalSinMaterial.SetFloat("_DitherEnabled", isEnabled ? 1.0f : 0.0f);
        }

        if (pixelSizeContainer != null)
        {
            pixelSizeContainer.SetActive(isEnabled);
        }
    }

    private void SetPixelSize(float value)
    {
        if (mortalSinMaterial != null)
        {
            mortalSinMaterial.SetFloat("_PixelSize", value);
        }
    }

    private void SetBlur(float value)
    {
        if (blurBlendMaterial != null)
        {
            blurBlendMaterial.SetFloat("_BlurSize", value);
        }
    }

    private void SetBlend(float value)
    {
        if (blurBlendMaterial != null)
        {
            blurBlendMaterial.SetFloat("_Blend", value);
        }
    }

    private void SetGrain(float value)
    {
        if (mortalSinMaterial != null)
        {
            mortalSinMaterial.SetFloat("_GrainIntensity", value);
        }
    }

    private void SetContrast(float value)
    {
        if (mortalSinMaterial != null)
        {
            mortalSinMaterial.SetFloat("_Contrast", value);
        }
    }

    private void SetBrightness(float value)
    {
        if (mortalSinMaterial != null)
        {
            mortalSinMaterial.SetFloat("_Brightness", value);
        }
    }

    private void SetSaturation(float value)
    {
        if (mortalSinMaterial != null)
        {
            mortalSinMaterial.SetFloat("_Saturation", value);
        }
    }

    private void SetPaletteToggle(bool isEnabled)
    {
        if (mortalSinMaterial != null)
        {
            mortalSinMaterial.SetFloat("_PaletteEnabled", isEnabled ? 1.0f : 0.0f);
        }
    }

    public void ApplyPalette(int index)
    {
        if (mortalSinMaterial != null && availablePalettes.Length > index)
        {
            ColorPalette chosenPalette = availablePalettes[index];

            mortalSinMaterial.SetColor("_Color0", chosenPalette.darkestColor);
            mortalSinMaterial.SetColor("_Color1", chosenPalette.darkColor);
            mortalSinMaterial.SetColor("_Color2", chosenPalette.lightColor);
            mortalSinMaterial.SetColor("_Color3", chosenPalette.lightestColor);

            mortalSinMaterial.SetFloat("_PaletteEnabled", 1.0f);
        }
    }

    public void DisablePalette()
    {
        if (mortalSinMaterial != null)
        {
            mortalSinMaterial.SetFloat("_PaletteEnabled", 0.0f);
        }
    }


    //limpiamos listeners
    void OnDestroy()
    {
        if (shadowsToggle != null) shadowsToggle.onValueChanged.RemoveListener(SetShadows);
        if (scanlinesToggle != null) scanlinesToggle.onValueChanged.RemoveListener(SetScanlines);
        if (outlinesToggle != null) outlinesToggle.onValueChanged.RemoveListener(SetOutlines);
        if (gradientsToggle != null) gradientsToggle.onValueChanged.RemoveListener(SetGradients);
        if (blurSlider != null) blurSlider.onValueChanged.RemoveListener(SetBlur);
        if (blendSlider != null) blendSlider.onValueChanged.RemoveListener(SetBlend);
        if (grainSlider != null) grainSlider.onValueChanged.RemoveListener(SetGrain);
        if (contrastSlider != null) contrastSlider.onValueChanged.RemoveListener(SetContrast);
        if (brightnessSlider != null) brightnessSlider.onValueChanged.RemoveListener(SetBrightness);
        if (saturationSlider != null) saturationSlider.onValueChanged.RemoveListener(SetSaturation);
    }
}