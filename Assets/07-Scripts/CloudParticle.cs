using UnityEngine;

public class CloudParticle : MonoBehaviour
{
    public ParticleSystem particleSystem;

    private void Update()
    {
        var particles = new ParticleSystem.Particle[particleSystem.particleCount];
        particleSystem.GetParticles(particles);

        foreach (var particle in particles)
        {
            //Fai cose con le particles
        }

        particleSystem.SetParticles(particles);
    }
}
