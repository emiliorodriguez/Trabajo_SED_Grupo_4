/*
 * salidas.h
 *
 *  Created on: Dec 6, 2025
 *      Author: danie
 */

#ifndef INC_SALIDAS_H_
#define INC_SALIDAS_H_

#include "main.h"

void Encender_Led(uint8_t n);
void Inicio_Sonido(uint32_t frecuencia);
void Generar_Sonido(uint32_t tono, uint32_t duracion);

void Apagar_Led();
void Sonido_Ganar();
void Sonido_Perder();
void Actualizar_Sonido();
void Detener_Sonido();


#endif /* INC_SALIDAS_H_ */
