using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Globalization; 

public class SliderBar : MonoBehaviour
{
    [Header("Ajustes del Slider")]
    public Slider mySlider;
    public TextMeshProUGUI myValueText;

    void Start()
    {
        UpdateText(mySlider.value);
        mySlider.onValueChanged.AddListener(UpdateText);
    }

    public void UpdateText(float value)
    {
        if (mySlider.wholeNumbers)
        {
            myValueText.text = value.ToString("F0", CultureInfo.InvariantCulture);
        }
        else
        {
            myValueText.text = value.ToString("F1", CultureInfo.InvariantCulture);
        }
    }
}