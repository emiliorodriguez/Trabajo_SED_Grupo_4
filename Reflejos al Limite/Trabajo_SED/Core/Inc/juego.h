/*
 * juego.h
 *
 *  Created on: Dec 7, 2025
 *      Author: danie
 */

#ifndef INC_JUEGO_H_
#define INC_JUEGO_H_

#include "main.h"
#include "entradas.h"
#include "salidas.h"
#include"puntuaciones.h"
#include "lcd.h"

#include <stdlib.h> //Para rand()
#include <stdio.h>



enum estado {INICIO, LEDS, RESULTADOS};

void Juego();
void Reiniciar_Bolsa();
void Finalizando();
void Penalizacion(uint8_t btn);
void Aumento(uint8_t btn, uint32_t tlim);

uint8_t LED_Elegido();
uint32_t Tiempo_Limite();

float Restamos(uint8_t pulsacion);
float Sumamos(uint8_t pulsacion, uint32_t tlim);


#endif /* INC_JUEGO_H_ */
