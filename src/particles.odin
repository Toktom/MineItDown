package mineitdown

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

Particle :: struct {
    position:    rl.Vector2,
    velocity:    rl.Vector2,
    color:       rl.Color,
    size:        f32,
    rotation:    f32,
    rotation_vel: f32,
    life:        f32,
    active:      bool,
    texture_rect: rl.Rectangle,
}

ParticleEmitter :: struct {
    particles:    [dynamic]Particle,
    position:     rl.Vector2,
    duration:     f32,
    timer:        f32,
    active:       bool,
}

emitters: [dynamic]ParticleEmitter

init_particles :: proc() {
    emitters = make([dynamic]ParticleEmitter)
}

create_block_break_effect :: proc(x, y: int, texture_name: string) {
    if texture_name == "" {
        return
    }
    
    screen_pos := convert_grid_to_screen({x, y})
    emitter := ParticleEmitter{
        position = {screen_pos.x + CELL_SIZE/2, screen_pos.y + CELL_SIZE/2},
        duration = 0.8,
        timer = 0.0,
        active = true,
    }
    
    // Create particle grid (4x4 for 16 fragments)
    fragment_size := CELL_SIZE / 3
    source_rect, exists := get_texture_source_rect(texture_name)
    
    if !exists {
        return
    }
    
    fragment_source_width := source_rect.width / 3
    fragment_source_height := source_rect.height / 3
    
    for i in 0..<9 {
        row := i / 3
        col := i % 3
        
        // Calculate source rectangle for this fragment
        fragment_source := rl.Rectangle{
            source_rect.x + f32(col) * fragment_source_width,
            source_rect.y + f32(row) * fragment_source_height,
            fragment_source_width,
            fragment_source_height,
        }
        
        // Calculate starting position
        pos_x := screen_pos.x + f32(col) * fragment_size
        pos_y := screen_pos.y + f32(row) * fragment_size
        // Random velocity outward from center
        angle := rand.float32_range(0, 2 * 3.14159)
        speed := rand.float32_range(20, 60)
        vel_x := speed * math.cos(angle)
        vel_y := speed * math.sin(angle)
        
        particle := Particle{
            position = {pos_x, pos_y},
            velocity = {vel_x, vel_y},
            color = rl.WHITE,
            size = fragment_size,
            rotation = 0,
            rotation_vel = rand.float32_range(-5, 5),
            life = rand.float32_range(0.5, 0.8),
            active = true,
            texture_rect = fragment_source,
        }
        
        append(&emitter.particles, particle)
    }
    
    append(&emitters, emitter)
}

update_particles :: proc(dt: f32) {
    for i := 0; i < len(emitters); i += 1 {
        if !emitters[i].active {
            continue
        }
        
        emitters[i].timer += dt
        if emitters[i].timer >= emitters[i].duration {
            emitters[i].active = false
            delete(emitters[i].particles)
            ordered_remove(&emitters, i)
            i -= 1
            continue
        }
        
        for j := 0; j < len(emitters[i].particles); j += 1 {
            if !emitters[i].particles[j].active {
                continue
            }
            
            // Update particle position
            emitters[i].particles[j].position.x += emitters[i].particles[j].velocity.x * dt
            emitters[i].particles[j].position.y += emitters[i].particles[j].velocity.y * dt
            
            // Add some gravity
            emitters[i].particles[j].velocity.y += 50 * dt
            
            // Update rotation
            emitters[i].particles[j].rotation += emitters[i].particles[j].rotation_vel * dt
            
            // Update lifetime and fade out
            emitters[i].particles[j].life -= dt
            if emitters[i].particles[j].life <= 0 {
                emitters[i].particles[j].active = false
            } else {
                // Fade out
                alpha := u8(255.0 * (emitters[i].particles[j].life / 0.8))
                emitters[i].particles[j].color.a = alpha
            }
        }
    }
}

draw_particles :: proc() {
    for i := 0; i < len(emitters); i += 1 {
        if !emitters[i].active {
            continue
        }
        
        for j := 0; j < len(emitters[i].particles); j += 1 {
            if !emitters[i].particles[j].active {
                continue
            }
            
            particle := emitters[i].particles[j]
            
            // Create destination rectangle
            dest := rl.Rectangle{
                particle.position.x, 
                particle.position.y, 
                particle.size, 
                particle.size,
            }
            
            // Draw the fragment with rotation
            origin := rl.Vector2{particle.size/2, particle.size/2}
            rl.DrawTexturePro(
                atlas.texture, 
                particle.texture_rect, 
                dest, 
                origin, 
                particle.rotation * 57.2958, // Convert radians to degrees
                particle.color
            )
        }
    }
}

cleanup_particles :: proc() {
    for i := 0; i < len(emitters); i += 1 {
        delete(emitters[i].particles)
    }
    delete(emitters)
}
