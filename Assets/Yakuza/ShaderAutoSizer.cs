using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[ExecuteInEditMode]
public class ShaderAutoSizer : MonoBehaviour
{
    private Image _image;
    private RectTransform _rectTransform;

    private void Start()
    {
        _rectTransform = GetComponent<RectTransform>();
        _image = GetComponent<Image>();
    }

    private void Update()
    {
        var lossyScale = _rectTransform.lossyScale;
        _image.material.SetFloat("_ScreenX",_rectTransform.rect.width * lossyScale.x);
        _image.material.SetFloat("_ScreenY",_rectTransform.rect.height * lossyScale.y);
    }
}
