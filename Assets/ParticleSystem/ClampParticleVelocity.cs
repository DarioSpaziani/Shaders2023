using UnityEngine;

public class ClampParticleVelocity : MonoBehaviour
{
    [SerializeField] float maxMagnitude = 1;
    [SerializeField] ParticleSystem particleSystem = null;

    private void Update()
    {
        if(particleSystem)
        {
            ParticleSystem.Particle[] particles = new ParticleSystem.Particle[particleSystem.particleCount];
            particleSystem.GetParticles(particles);

            for(int i = particles.Length - 1; i >= 0; i--)
            {
                particles[i].velocity = particles[i].velocity.magnitude > maxMagnitude ?
                    particles[i].velocity = particles[i].velocity.normalized * maxMagnitude : particles[i].velocity;
            }

            particleSystem.SetParticles(particles);
        }
    }
}
