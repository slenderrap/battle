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

fs.readFile('game_data.json', 'utf8', (err, data) => {
    if (err) {
        console.log("Error al leer json", err);
        return;
    }
    const json = JSON.parse(data);
});

const Player = require('./player.js');

class GameLogic {
    

    constructor() {
        this.players = new Map();
        this.zones = []; // Initialize empty, will be populated when file is read
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
                let otherPlayer = null;
                let AttackingPlayerX = player.x;
                let AttackingPlayerY = player.y;
                if (player.direction === "none") break;
                let directionVector = DIRECTIONS[player.direction];
                if (!directionVector) break;
                for (let p of this.players.values()) {
                    if (p.id === id) continue;
                    if (p.x === AttackingPlayerX + directionVector.dx && p.y === AttackingPlayerY + directionVector.dy) {
                        otherPlayer = p;
                        break;
                    }
                }
                break;
            case "heal":
                this.healPlayer(player, data.amount);
                break;
            default:
                break;
          }
        } catch (error) {}
    }


    // Blucle de joc (funció que s'executa contínuament)
    updateGame(fps) {
        let deltaTime = 1 / fps;
        // Actualitzar la posició dels clients
        this.players.forEach(player => {
            let moveVector = player.direction;
            if (!moveVector || player.direction.dx === 0 && player.direction.dy === 0)
                return;
            // Mover el client
            player.move(moveVector.dx, moveVector.dy, deltaTime);
        });
    }

    // Obtenir una posició on no hi h ha ni objectes ni jugadors
    getInitialPosition() {
        const isFirstPlayer = this.players.size === 0;
        const x = isFirstPlayer ? 1 : MAP_SIZE.width - 2;
        const y = Math.floor(Math.random() * (MAP_SIZE.height - 2)) + 1;
        return { x, y };
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
                    return false;
                }
            }
        }
        console.log(`Coordenadas (${x}, ${y}) no están dentro de ninguna zona de agua o rocas`);
        return true;
    }
}

module.exports = GameLogic;



