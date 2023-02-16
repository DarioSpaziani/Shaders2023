using UnityEngine;

public class ScannerUpdater : MonoBehaviour
{
    public Material scannerMaterial;

    private Vector3 spawnPosition = Vector3.zero;

    private void Update()
    {
        if(Input.GetKeyDown(KeyCode.Space))
        {
            scannerMaterial.SetFloat("_ScannerStartTimestamp", Time.time);
            spawnPosition = transform.position;
        }

        Vector3 offsetVector = spawnPosition - transform.position;
        scannerMaterial.SetVector("_ScannerSpawnOffset", new Vector3(offsetVector.x, offsetVector.z, 0));
    }
}
