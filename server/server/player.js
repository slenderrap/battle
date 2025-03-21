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
        this.nextDirection = null;
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
        if (this.direction.dx != 0 || this.direction.dy != 0) {
            console.log("Direction already set, reserving for next move");
            this.nextDirection = direction;
            return;
        }
        console.log("Setting direction to: " + direction);
        this.direction = direction;
        if (direction.dx > 0) {
            this.subX = 0.75;
        } else if (direction.dx < 0) {
            this.subX = -0.75;
        }
        if (direction.dy > 0) {
            this.subY = 0.75;
        } else if (direction.dy < 0) {
            this.subY = -0.75;
        }
    }
    
    move(dx, dy, deltaTime) {
        // Accumulate the movement
        this.subX += this.speed * dx * deltaTime;
        this.subY += this.speed * dy * deltaTime;
        
        // Apply movement when accumulation is >= 1 or <= -1
        if (Math.abs(this.subX) >= 1) {
            console.log("Moving player " + this.id + ", " + this.subX + ", " + this.subY);
            this.x += Math.trunc(this.subX);
            this.subX -= Math.trunc(this.subX);
            if (this.nextDirection) {
                this.direction = this.nextDirection;
                this.nextDirection = null;
            }
        }
        if (Math.abs(this.subY) >= 1) {
            console.log("Moving player " + this.id + ", " + this.subX + ", " + this.subY);
            this.y += Math.trunc(this.subY);
            this.subY -= Math.trunc(this.subY);
            this.hasMoved = true;
            if (this.nextDirection) {
                this.direction = this.nextDirection;
                this.nextDirection = null;
            }
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

module.exports = Player;