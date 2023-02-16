using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMove : MonoBehaviour
{
    public float speed = 10;

    void Update()
    {
        float horizontal = 0;
        float vertical = 0;

        if (Input.GetKey(KeyCode.D))
        {
            horizontal++;
        }
        if (Input.GetKey(KeyCode.A))
        {
            horizontal--;
        }
        if (Input.GetKey(KeyCode.W))
        {
            vertical++;
        }
        if (Input.GetKey(KeyCode.S))
        {
            vertical--;
        }

        transform.position += new Vector3(horizontal, 0, vertical) * speed * Time.deltaTime;
    }
}
