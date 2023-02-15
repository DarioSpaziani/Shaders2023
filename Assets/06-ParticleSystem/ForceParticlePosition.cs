using UnityEngine;

public class ForceParticlePosition : MonoBehaviour
{
    public enum Axis
    {
        X,
        Y,
        Z
    }

    [SerializeField] Axis axis = Axis.Y;
    [SerializeField] float worldValue = 0;
    [SerializeField] ParticleSystem particleSystem = null;

    private void Update()
    {
        if(particleSystem)
        {
            ParticleSystem.Particle[] particles = new ParticleSystem.Particle[particleSystem.particleCount];
            particleSystem.GetParticles(particles);

            for(int i = particles.Length - 1; i >= 0; i--)
            {
                particles[i].position = 
                    new Vector3(
                        axis == Axis.X ? worldValue : particles[i].position.x,
                        axis == Axis.Y ? worldValue : particles[i].position.y,
                        axis == Axis.Z ? worldValue : particles[i].position.z);
            }

            particleSystem.SetParticles(particles);
        }
    }
}
