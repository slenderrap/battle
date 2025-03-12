'use strict';
import Player from './Player.js';
const fs = require('fs');
const SPEED = 0.2;
const INITIAL_HEALTH = 100;
const INITIAL_ATTACK = 10;
const INITIAL_DEFENSE = 5;
const MAP_SIZE = { width: 20, height: 20 };

const DIRECTIONS = {
    "up":         { dx: 0, dy: -1 },
    "upLeft":     { dx: -1, dy: -1 },
    "left":       { dx: -1, dy: 0 },
    "downLeft":   { dx: -1, dy: 1 },
    "down":       { dx: 0, dy: 1 },
    "downRight":  { dx: 1, dy: 1 },
    "right":      { dx: 1, dy: 0 },
    "upRight":    { dx: 1, dy: -1 },
    "none":       { dx: 0, dy: 0 }
};

fs.readFile('game_data.json', 'utf8', (err, data) => {
if (err) {
    console.log("Error al leer json", err);
    return;
}
const json = JSON.parse(data);



class GameLogic {
    constructor() {
        this.players = new Map();
        this.zones = json.zones;
    }

    // Es connecta un client/jugador
    addClient(id) {
        let pos = this.getValidPosition();
        const newPlayer = new Player(
            id,
            pos.x, 
            pos.y,
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
                let direction = DIRECTIONS[data.direction];
                if (direction) {
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
                for (p of this.players.values()) {
                    if (p.id === id) continue;
                    if (p.x === AttackingPlayerX + directionVector.dx && p.y === AttackingPlayerY + directionVector.dy) {
                        otherPlayer = p;
                        break;
                    }
                }
                if (!otherPlayer) break;
                otherPlayer.takeDamage(player.attack);
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
            let moveVector = DIRECTIONS[player.direction];
            if (moveVector === "none")
                return;
            // Mover el client
            player.move(moveVector.dx, moveVector.dy, deltaTime);
        });
    }

    // Obtenir una posició on no hi h ha ni objectes ni jugadors
    getValidPosition() {
        const isFirstPlayer = this.players.size === 0;
        const x = isFirstPlayer ? 1 : MAP_SIZE.width - 2;
        const y = Math.floor(Math.random() * (MAP_SIZE.height - 2)) + 1;
        return { x, y };
    }

    // Retorna l'estat del joc (per enviar-lo als clients/jugadors)
    getGameState() {
        return {
            players: Array.from(this.players.values())
        };
    }

    checkZone(x, y) {
        for (const zone of this.zones) {
            if (
                x >= zone.x && x <= zone.x + zone.width && 
                y >= zone.y && y <= zone.y + zone.height    
            ) {
                if (zone.type.includes("stone") || zone.type.includes("water")) {
                    console.log(`Coordenadas (${x}, ${y}) están dentro de la zona: ${zone.type}`);
                    return;
                }
            }
        }
        console.log(`Coordenadas (${x}, ${y}) no están dentro de ninguna zona de agua o rocas`);
    }
    
}

module.exports = GameLogic;
