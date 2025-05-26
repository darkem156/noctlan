import express from 'express';
import http from 'http';
import WebSocket, { WebSocketServer } from 'ws';
import app from './app';

const port = app.get('port') || 3000;

// Crear servidor HTTP desde Express
const server = http.createServer(app);

// Crear servidor WebSocket ligado al servidor HTTP
const wss = new WebSocketServer({ server, path: '/metrics' });

interface Paciente {
  id: number;
  nombre: string;
  ritmoCardiaco: number;
  respiracion: number;
  ruido: number;
}

// Simulación simple de pacientes con camas asignadas
const pacientesConCama: Paciente[] = [
  { id: 1, nombre: 'Emmanuel', ritmoCardiaco: 70, respiracion: 15, ruido: 30 },
  { id: 2, nombre: 'Emma', ritmoCardiaco: 65, respiracion: 14, ruido: 35 },
  { id: 3, nombre: 'Sayk', ritmoCardiaco: 72, respiracion: 16, ruido: 40 },
];

// Función para simular cambios en métricas
function actualizarMetricas() {
  pacientesConCama.forEach(p => {
    p.ritmoCardiaco = 0//60 + Math.floor(Math.random() * 40);
    p.respiracion = 0//10 + Math.floor(Math.random() * 10);
    p.ruido = 1//Math.floor(Math.random() * 100);
  });
}

// Broadcast a todos los clientes conectados
function broadcastMetricas() {
  const mensaje = JSON.stringify({ pacientes: pacientesConCama });
  wss.clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(mensaje);
    }
  });
}

// Al conectar un cliente
wss.on('connection', ws => {
  console.log('Cliente WebSocket conectado');

  // Mandar datos iniciales
  ws.send(JSON.stringify({ pacientes: pacientesConCama }));

  // (Opcional) manejar mensajes recibidos del cliente
  ws.on('message', message => {
    console.log('Mensaje recibido del cliente:', message.toString());
  });

  ws.on('close', () => {
    console.log('Cliente WebSocket desconectado');
  });
});

// Actualizar y enviar métricas cada 1 segundo
setInterval(() => {
  actualizarMetricas();
  broadcastMetricas();
}, 1000);

// Finalmente iniciar el servidor HTTP (Express + WS)
server.listen(port, () => {
  console.log(`Server on port ${port}`);
});
