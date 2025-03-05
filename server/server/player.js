class Player {
    constructor(id, x, y, direction, health, attack, defense, speed) {
        this.id = id;
        this.x = x;
        this.y = y;
        this.direction = direction;
        this.health = health;
        this.attack = attack;
        this.defense = defense;
        this.position = position;
        this.speed = speed;
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
        this.position = { x, y };
    }
    setDirection(direction) {
        this.direction = direction;
    }

    move(dx, dy, deltaTime) {
        this.x = Math.max(0, Math.min(1, this.x + this.speed * dx * deltaTime));
        this.y = Math.max(0, Math.min(1, this.y + this.speed * dy * deltaTime));
    }

    getStats() {
        return {
            health: this.health,
            attack: this.attack,
            defense: this.defense,
            position: this.position,
            speed: this.speed,
        };
    }


    toString() {
        return `Player [Health: ${this.health}, Attack: ${this.attack}, Defense: ${this.defense}, Position: (${this.position.x}, ${this.position.y}), Speed: ${this.speed}]`;
    }
}

export default Player;