using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterMovement : MonoBehaviour
{
    float speed = 5;
    Vector2 input = default;

    private void Update()
    {
        float horiz = 0;
        float vert = 0;
        if(Input.GetKey(KeyCode.D))
        {
            horiz++;
        }
        if (Input.GetKey(KeyCode.A))
        {
            horiz--;
        }
        if (Input.GetKey(KeyCode.W))
        {
            vert++;
        }
        if (Input.GetKey(KeyCode.S))
        {
            vert--;
        }
        input = new Vector2(horiz, vert);
    }

    private void FixedUpdate()
    {
        transform.position += speed * Time.fixedDeltaTime * new Vector3(input.x, 0, input.y);
    }
}
