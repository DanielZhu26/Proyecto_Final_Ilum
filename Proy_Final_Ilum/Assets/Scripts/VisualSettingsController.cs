using UnityEngine;
using UnityEngine.UI;

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

    void Start()
    {
        //shadows
        if (mainDirectionalLight != null && shadowsToggle != null)
        {
            shadowsToggle.isOn = mainDirectionalLight.shadows != LightShadows.None;

            shadowsToggle.onValueChanged.AddListener(SetShadows);
        }

        //scanliness
        if (mortalSinMaterial != null && scanlinesToggle != null)
        {
            scanlinesToggle.isOn = mortalSinMaterial.GetFloat("_ScanlinesIntensity") > 0.5f;
            scanlinesToggle.onValueChanged.AddListener(SetScanlines);
        }

        //outlines
        if (outlinesMaterial != null && outlinesToggle != null)
        {
            outlinesToggle.isOn = outlinesMaterial.GetFloat("_OutlineIntensity") > 0.5f;
            outlinesToggle.onValueChanged.AddListener(SetOutlines);
        }

        //gradients
        if (mortalSinMaterial != null && gradientsToggle != null)
        {
            gradientsToggle.isOn = mortalSinMaterial.GetFloat("_GradientsEnabled") > 0.5f;
            gradientsToggle.onValueChanged.AddListener(SetGradients);
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
            mortalSinMaterial.SetFloat("_GradientsEnabled", isEnabled ? 1.0f : 0.0f);
    }

    void OnDestroy()
    {
        if (shadowsToggle != null) shadowsToggle.onValueChanged.RemoveListener(SetShadows);
        if (scanlinesToggle != null) scanlinesToggle.onValueChanged.RemoveListener(SetScanlines);
        if (outlinesToggle != null) outlinesToggle.onValueChanged.RemoveListener(SetOutlines);
        if (gradientsToggle != null) gradientsToggle.onValueChanged.RemoveListener(SetGradients);
    }
}