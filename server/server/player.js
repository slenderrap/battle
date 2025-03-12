class Player {
    constructor(id, x, y, direction, health, attack, defense, speed) {
        this.id = id;
        this.x = x;
        this.y = y;
        this.direction = direction;
        this.health = health;
        this.attack = attack;
        this.defense = defense;
        this.speed = speed;
        this.subX = 0;
        this.subY = 0;
    }

    takeDamage(amount) {
        const damage = Math.max(0, amount - this.defense);
        this.health = Math.max(0, this.health - damage);
        return this.health;
    }

    heal(amount) {
        this.health += amount;
        return this.health;
    }

    isAlive() {
        return this.health > 0;
    }

    setPosition(x, y) {
        this.x = Math.round(x);
        this.y = Math.round(y);
    }

    setDirection(direction) {
        this.direction = direction;
    }
    
    move(dx, dy, deltaTime) {
        // Accumulate the movement
        this.subX += this.speed * dx * deltaTime;
        this.subY += this.speed * dy * deltaTime;
        
        // Apply movement when accumulation is >= 1 or <= -1
        if (Math.abs(this.subX) >= 1) {
            this.x += Math.trunc(this.subX);
            this.subX -= Math.trunc(this.subX);
        }
        if (Math.abs(this.subY) >= 1) {
            this.y += Math.trunc(this.subY);
            this.subY -= Math.trunc(this.subY);
        }
    }

    getStats() {
        return {
            health: this.health,
            attack: this.attack,
            defense: this.defense,
            x: this.x,
            y: this.y,
            speed: this.speed,
        };
    }

        toString() {
        return `Player [Health: ${this.health}, Attack: ${this.attack}, Defense: ${this.defense}, Position: (${this.x}, ${this.y}), Speed: ${this.speed}]`;
    }
}

export default Player;