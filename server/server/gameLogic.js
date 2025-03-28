'use strict';
const fs = require('fs');
const SPEED = 1.2;
const INITIAL_HEALTH = 100;
const INITIAL_ATTACK = 10;
const INITIAL_DEFENSE = 5;
const MAP_SIZE = { width: 32, height: 16 };

const DIRECTIONS = {
    "up":         { dx: 0, dy: -1 },
    "left":       { dx: -1, dy: 0 },
    "down":       { dx: 0, dy: 1 },
    "right":      { dx: 1, dy: 0 },
    "none":       { dx: 0, dy: 0 },
};
const Player = require('./player.js');

class GameLogic {
    

    constructor() {
        this.players = new Map();
        this.zones = [];
        this.loadZones();
    }

    loadZones() {
        let json = require('./game_data.json');
        this.zones = json.levels[0].zones;
        for (let zone of this.zones) {
            zone.x /= 16;
            zone.y /= 16;
            zone.width /= 16;
            zone.height /= 16;
        }
        console.log(this.zones.length);
    }

    // Es connecta un client/jugador
    addClient(id) {
        let { x, y } = this.getInitialPosition();
        const newPlayer = new Player(
            id,
            x, 
            y,
            DIRECTIONS["none"],
            INITIAL_HEALTH,  
            INITIAL_ATTACK,  
            INITIAL_DEFENSE, 
            SPEED 
        );
        
        this.players.set(id, newPlayer);
        return newPlayer;
    }

    // Es desconnecta un client/jugador
    removeClient(id) {
        this.players.delete(id);
    }

    // Tractar un missatge d'un client/jugador
    handleMessage(id, msg) {
        try {
          let obj = JSON.parse(msg);
          if (!obj.type) return;
          let player = this.players.get(id);
          if (!player) return;
          let data = obj.data;
          switch (obj.type) {
            case "direction":
                if (!player.isPlayerAlive()) break;
                console.log("Received direction message from client: " + data.direction);
                let direction = DIRECTIONS[data.direction];
                if (direction) {
                    const previusDirection = player.direction;
                    if (previusDirection.dx === direction.dx && previusDirection.dy === direction.dy) {
                        // Keep the same direction
                        break;
                    }
                    player.setDirection(direction);
                }
                break;
            case "attack":
                if (!player.isPlayerAlive()) break;
                if (player.attackDelay > 0) break;
                let otherPlayer = null;
                let AttackingPlayerX = player.x;
                let AttackingPlayerY = player.y;
                console.log(AttackingPlayerX, AttackingPlayerY);
                let directionVector = player.watchDirection;
                console.log(JSON.stringify(directionVector));
                if (!directionVector) break;
                for (let p of this.players.values()) {
                    console.log(p.x, p.y, AttackingPlayerX + directionVector.dx, AttackingPlayerY + directionVector.dy);
                    if (p.id === id) continue;
                    if (p.x === AttackingPlayerX + directionVector.dx && p.y === AttackingPlayerY + directionVector.dy) {
                        otherPlayer = p;
                        break;
                    }
                }
                if (otherPlayer) {
                    console.log("Attacking player " + otherPlayer.id);
                    otherPlayer.takeDamage(player.attack);
                }
                break;
            default:
                break;
          }
        } catch (error) {}
    }

    movePlayer(player, moveVector) {
        if (!moveVector || player.direction.dx === 0 && player.direction.dy === 0)
            return;
        console.log("Moving player " + player.id + " to " + (player.x + moveVector.dx) + ", " + (player.y + moveVector.dy));
        if (!this.checkZone(player.x + moveVector.dx, player.y + moveVector.dy) != 0) {
            player.direction = DIRECTIONS["none"];
            player.nextDirection = null;
            return;
        }
        player.move(moveVector.dx, moveVector.dy, 1);
    }

    // Blucle de joc (funció que s'executa contínuament)
    updateGame(fps) {
        let deltaTime = 1 / fps;
        // Actualitzar la posició dels clients
        this.players.forEach(player => {
            player.attackDelay -= deltaTime;
            this.movePlayer(player, player.direction);
            if (this.checkZone(player.x, player.y) == 2) {
                player.heal(1);
            }
        });
    }

    // Obtenir una posició on no hi h ha ni objectes ni jugadors
    getInitialPosition() {
        while (true) {
            const isFirstPlayer = this.players.size === 0;
            const x = isFirstPlayer ? 1 : MAP_SIZE.width - 2;
            const y = Math.floor(Math.random() * (MAP_SIZE.height - 2)) + 1;
            if (this.checkZone(x, y) != 0) return { x, y };
        }
    }

    // Retorna l'estat del joc (sense el objecte del client amb id playerId)
    getGameState(playerId) {
        return {
            clientPlayer: this.players.get(playerId),
            otherPlayers: Array.from(this.players.values()).filter(player => player.id !== playerId)
        };
    }

    checkZone(x, y) {
        for (const zone of this.zones) {
            if (
                x >= zone.x && x <= zone.x + zone.width && 
                y >= zone.y && y <= zone.y + zone.height    
            ) {
                if (zone.type.includes("stone") || zone.type.includes("water") || zone.type.includes("tree")) {
                    console.log(`Coordenadas (${x}, ${y}) están dentro de la zona: ${zone.type}`);
                    return 0;
                }
                if (zone.type.includes("heal")) {
                    return 2;
                }
                if (zone.type.includes("moab")) {
                    return 3;
                }
            }
        }
        console.log(`Coordenadas (${x}, ${y}) no están dentro de ninguna zona`);
        return 1;
    }


}

module.exports = GameLogic;



