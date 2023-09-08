using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class test : MonoBehaviour
{
    public Vector2 uv;
    public int DivisionCount = 1;
    private void Update()
    {
        Vector2 dir = uv- new Vector2(0.5f,0.5f);
        float angle = Mathf.Atan2(dir.y,dir.x);
        angle = Mathf.Rad2Deg*angle;
        bool isPainted = false;
        if(angle<0 ) angle+=360;
        Debug.Log(angle);

        for (int i = 0;i< DivisionCount; i++)
        {
            float startAngle = i*360/DivisionCount;
            float endAngle = (i+1)*360/DivisionCount;

            if(angle > startAngle && angle < endAngle)
            {
                isPainted= true;
                break;
            }
        }
        
    }
}
