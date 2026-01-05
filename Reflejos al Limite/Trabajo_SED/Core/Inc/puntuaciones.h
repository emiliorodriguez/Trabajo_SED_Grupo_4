/*
 * puntuaciones.h
 *
 *  Created on: Dec 14, 2025
 *      Author: danie
 */

#ifndef INC_PUNTUACIONES_H_
#define INC_PUNTUACIONES_H_

#include "main.h" // Para tipos uint8_t, etc.

void Reinicio_Puntuaciones();
void Historico(); // Llamar solo una vez al arrancar el micro

float Acierto(uint8_t jugador, uint32_t pasos, uint32_t tiempo_limite);
float Fallo(uint8_t jugador);
float GetTotal(uint8_t jugador); // Para ver el total actual
float GetRecordActual();
float GetRecordHistorico();

uint8_t Ganador();
uint8_t NuevoRecord(); // Devuelve 1 si hemos batido el histórico



#endif /* INC_PUNTUACIONES_H_ */
