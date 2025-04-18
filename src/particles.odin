package mineitdown

import "core:math/rand"
import rl "vendor:raylib"
import "core:math"

Particle :: struct {
    pos:      rl.Vector2,
    vel:      rl.Vector2,
    size:     f32,
    color:    rl.Color,
    lifetime: f32,
    max_life: f32,
    active:   bool,
}

particle_pool: [dynamic]Particle

init_particles :: proc() {
    clear_particles()
    reserve(&particle_pool, MAX_PARTICLES)
}

clear_particles :: proc() {
    if len(particle_pool) > 0 {
        clear(&particle_pool)
    }
}

update_particles :: proc() {
    dt := rl.GetFrameTime()
    
    i := 0
    for i < len(particle_pool) {
        if !particle_pool[i].active {
            unordered_remove(&particle_pool, i)
            continue
        }
        
        // Update particle position and lifetime
        particle_pool[i].pos.x += particle_pool[i].vel.x * dt
        particle_pool[i].pos.y += particle_pool[i].vel.y * dt
        particle_pool[i].lifetime -= dt
        
        // Deactivate if lifetime is over
        if particle_pool[i].lifetime <= 0 {
            particle_pool[i].active = false
        }
        
        i += 1
    }
}

render_particles :: proc() {
    for particle in particle_pool {
        if particle.active {
            // Fade out as lifetime decreases
            alpha := u8(255.0 * (particle.lifetime / particle.max_life))
            color := particle.color
            color.a = alpha
            
            particle_square := rl.Rectangle {
                particle.pos.x - particle.size / 2,
                particle.pos.y - particle.size / 2,
                particle.size,
                particle.size,
            }

            rl.DrawRectangleRec(particle_square, color)
        }
    }
}

emit_block_damage_particles :: proc(block_pos: Vec2i, count: int = 8) {
    center := grid_to_screen_center(block_pos)
    color := rl.Color{85, 86, 93, 255}
    
    for i in 0..<count {
        if len(particle_pool) >= MAX_PARTICLES {
            return
        }
        
        angle := rand.float32_range(0, 2 * 3.14159)
        speed := rand.float32_range(60, 150)
        
        particle := Particle {
            pos = center,
            vel = {speed * math.cos(angle), speed * math.sin(angle)},
            size = rand.float32_range(20, 25),
            color = color,
            lifetime = rand.float32_range(0.3, 0.7),
            max_life = rand.float32_range(0.3, 0.7),
            active = true,
        }
        
        append(&particle_pool, particle)
    }
}
