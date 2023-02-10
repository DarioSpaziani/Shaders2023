using UnityEngine;
using UnityEngine.UI;

public class SliderScript : MonoBehaviour
{
    public Slider slider = null;
    public Material material = null;

    private const string _valueKey = "_Value";

    private void Awake()
    {
        slider.onValueChanged.AddListener(ValueChanged);
    }

    private void Update()
    {
        slider.value = (Mathf.Sin(Time.time / 2) + 1) / 2;
    }

    private void ValueChanged(float currValue)
    {
        material.SetFloat(_valueKey, currValue);
    }
}
