using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LerpCamera : MonoBehaviour
{
    private Vector3 startPos;

    private void Start()
    {
        startPos = transform.position - Vector3.up*3;
    }

    private void Update()
    {
        transform.position = startPos + Mathf.Sin(Time.fixedTime/5) * 3 * Vector3.up;
    }
}
