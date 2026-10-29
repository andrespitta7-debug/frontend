import http from 'k6/http';
import { check, sleep } from 'k6';

// ========================================================================
// SysQuest — Script de Pruebas de Estrés y Rendimiento (k6)
// Evalúa concurrencia sobre Edge Functions de Supabase y API Gateway Kong.
// ========================================================================

export const options = {
  stages: [
    { duration: '30s', target: 20 },  // Rampa de subida: hasta 20 estudiantes concurrentes
    { duration: '1m', target: 50 },   // Carga sostenida: 50 estudiantes en simultáneo
    { duration: '30s', target: 100 }, // Pico de estrés: 100 peticiones concurrentes
    { duration: '30s', target: 0 },   // Rampa de bajada
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'], // 95% de las peticiones deben responder en < 2 segundos (ISO 25010)
    http_req_failed: ['rate<0.05'],    // Menos del 5% de fallos tolerados
  },
};

const BASE_URL = __ENV.SUPABASE_URL || 'https://jctulgfdweeurqbmugot.supabase.co';
const ANON_KEY = __ENV.SUPABASE_ANON_KEY || 'TU_ANON_KEY_AQUI';

export default function () {
  const headers = {
    'Content-Type': 'application/json',
    'apikey': ANON_KEY,
  };

  // 1. Simular consulta de Swagger UI / documentación OpenAPI
  const resSwagger = http.get(`${BASE_URL}/functions/v1/swagger-ui`, { headers });
  check(resSwagger, {
    'swagger status es 200': (r) => r.status === 200,
  });

  // 2. Simular consulta de quest completa (lectura recurrente de combate)
  const payloadQuest = JSON.stringify({
    id_quest: '00000000-0000-0000-0000-000000000001',
  });

  const resQuest = http.post(
    `${BASE_URL}/functions/v1/obtener-quest-completa`,
    payloadQuest,
    { headers }
  );

  check(resQuest, {
    'obtener-quest status es 200 o 401': (r) => r.status === 200 || r.status === 401,
    'tiempo respuesta quest < 1.5s': (r) => r.timings.duration < 1500,
  });

  sleep(1);
}
