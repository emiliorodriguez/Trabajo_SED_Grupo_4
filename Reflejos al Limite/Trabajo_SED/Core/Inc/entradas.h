/*
 * entradas.h
 *
 *  Created on: Dec 6, 2025
 *      Author: danie
 */

#ifndef INC_ENTRADAS_H_
#define INC_ENTRADAS_H_

#include "main.h"

uint8_t LeerBoton();
uint8_t LeerFlagTemp();

uint32_t LeerPotenciometro();
uint32_t Tiempo_pulsacion(uint8_t n_boton);

void Limpiar_Flags();
void Limpiar_Btn();
void Temporizador_Parar();
void Temporizador_Iniciar();
void Temporizador_Preparar(uint32_t ms);


#endif /* INC_ENTRADAS_H_ */
