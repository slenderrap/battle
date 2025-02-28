# Websockets

## NodeJS

Per fer anar **websockets** a NodeJS cal instal·lar el paquet *ws*. 

A més, la lliberia **utilsWebSockets.js** facilita la gestió dels WebSockets. Aquesta llibreria fa servir el paquet **uuid** per assignar identificadors als clients.

El paquet **ws** permet gestionar connexions a través del servidor NodeJS.

Els events més importants són:

- Quan comença una nova connexió amb un client
- Quan un client es desconnecta
- Quan es rep un nou missatge

La llibreria **utilsWebSockets** simplifica la gestió de *WebSockets* amb NodeJS. És un objecte que permet configurar **ws** de manera senzilla.

```javascript
const webSockets = require('./utilsWebSockets.js');
const ws = new webSockets();

// Inicialitzar servidor HTTP
const httpServer = app.listen(port, () => {
    console.log(`Servidor HTTP escoltant a: http://localhost:${port}`);
});

// Gestionar WebSockets
ws.init(httpServer, port);

// Com tractar una nova connexió a un client
ws.onConnection = (socket, id) => {
    if (debug) console.log("WebSocket client connected: " + id);

    let newClient = game.addClient(id);

    socket.send(JSON.stringify({
        type: "welcome",
        value: "Welcome to the server",
        id: id,
        gameState: game.getGameState()
    }));

    ws.broadcast(JSON.stringify({
        type: "newClient",
        id: id,
        clientData: newClient
    }));
};

// Què cal fer quan rebem un missatge
ws.onMessage = (socket, id, msg) => {
    if (debug) console.log(`New message from ${id}: ${msg.substring(0, 32)}...`);
    game.handleMessage(id, msg);
};

// Com tractar la desconnexió d'un client
ws.onClose = (socket, id) => {
    if (debug) console.log("WebSocket client disconnected: " + id);
    game.removeClient(id);
    ws.broadcast(JSON.stringify({ type: "disconnected", from: "server", id: id }));
};

// Gestionar el tancament del servidor
process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);

function shutDown() {
    console.log('Rebuda senyal de tancament, aturant el servidor...');
    httpServer.close();
    ws.end();
    gameLoop.stop();
    process.exit(0);
}
```

La llibreria permet identificar els clients a partir d'un identificador únic, i enviar missatges *privats* o de *broadcast*.

```javascript
ws.send(JSON.stringify({ type: "msg", from: "server", message: "hi" }));
ws.broadcast(JSON.stringify({ type: "msg", from: "server", message: "hi" }));
```

## Flutter

A flutter es poden fer connexions WebSockets cap a un servidor amb el paquet **web_socket_channel**.

A més, la llibreria **utils_websockets.dart** facilita la gestió dels WebSockets amb Flutter.

Des de **AppData**:

```dart
// Connectar amb el servidor
_wsHandler.connectToServer(
    _wsServer,
    _wsPort,
    _onWebSocketMessage,
    onError: _onWebSocketError,
    onDone: _onWebSocketClosed,
);

// Tracar els missatges rebuts
void _onWebSocketMessage(String message) {
}

// Tractar els errors
void _onWebSocketError(dynamic error) {
}

// Tractar les desconnexions
void _onWebSocketClosed() {
}
```

Per enviar missatges cap el servidor

```dart
_wsHandler.sendMessage(message);
```

# Exemple 0

## GameLoop al servidor

Les aplicacions en temps real, deixen que el servidor s'encarregui de la lògica sobre les dades, i esperen rebre la informació de l'estat en temps real.

En videojocs això es fa al **"GameLoop"** del joc, en jocs i programes online s'implementa un "GameLoop" al servidor. La llibreria **utilsGameLoop.js** ajuda a simplificar aquesta tasca.

```javascript
let gameLoop = new GameLoop();
gameLoop.run = (fps) => {
    game.updateGame(fps);
    ws.broadcast(JSON.stringify({ type: "update", gameState: game.getGameState() }));
};
gameLoop.start();
```

Bàsicament: 

- S'ha d'instanciar l'objecte de la llibreria 
- Definir què farà el servidor a cada bucle *(loop)*
- Iniciar el loop 

La funció **run** s'executa contínuament, s'intenta executar, tants cops per segon com està definit a:

```javascript
TARGET_FPS = 35;
```

## GameLogic

Per simplificar la configuració i codi del servidor, tota la lògica de funcionament de l'aplicació està a **gameLogic.js**.

És bàsicament l'únic codi que heu de tocar i adaptar a les vostres aplicacions:

A **GameLogic**

- Es defineixen les dades de la vostra aplicació
- Es defineix què passa quan es connecten/desconnecten clients
- Es tracten els missatges que es reben dels clients
- S'executa **updateGame** cada pocs millisegons per actualitzar l'estat de l'aplicació
- S'envien missatges als clients amb el nou estat de l'aplicació (privats o broadcast)