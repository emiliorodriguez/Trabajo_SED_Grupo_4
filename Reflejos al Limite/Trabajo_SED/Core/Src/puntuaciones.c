/*
 * puntuaciones.c
 *
 *  Created on: Dec 14, 2025
 *      Author: danie
 */

#include "puntuaciones.h"

static float puntuaciones[4]={0.0f};//Puntiaciones de los jugadores
static float record_actual_ms=9999.0f; //Record de partiida
static float record_historico_ms=9999.0f; // Este persiste entre partidas


void Historico() //Funcion donde guardamos el histórico
{
    record_historico_ms=9999.0f;
}


void Reinicio_Puntuaciones()// Reiniciamos las puntuaciones
{
    for(int i=0; i<4; i++) {
    	puntuaciones[i]=0.0f;
    }
    record_actual_ms=9999.0f;//Reiniciamos record de la partida
}


float Acierto(uint8_t jugador, uint32_t pasos, uint32_t tiempo_limite)//Cuanto más rápido se pulse el boton más puntuacion se recibe
{
    float tiempo_tardado=((float)pasos)/10.0f; // Como cada paso es 0.1 ms se divide entre 10
    float puntos=1.0f-(tiempo_tardado/(float)tiempo_limite);//La puntuacion va de 0 a 1 en función de lo bueno que sea el jugador

	if (tiempo_tardado <record_actual_ms) //Actualizar Récord de Partida (si se supera)
	{
		record_actual_ms=tiempo_tardado;
	}

	if (tiempo_tardado< record_historico_ms) //Actualizar Récord Histórico (Si se supera)
	{
		record_historico_ms=tiempo_tardado;
	}

    if (puntos<0.0f) //No hay puntuacion negativa
    {
    	puntos=0.0f;
    }

    puntuaciones[jugador]+=puntos;

    return puntos;//Devolvemos los puntos sumados
}


float Fallo(uint8_t jugador)//Fallos de los jugadores
{
    puntuaciones[jugador]-=0.5f;//Restamos 0.5 por fallo

    if (puntuaciones[jugador]< 0) //No hay puntuacion negativa
    {
    	puntuaciones[jugador]= 0;
    }

    return -0.5f;
}


float GetTotal(uint8_t jugador)//Funciona para obtener el total de puntos
{
    return puntuaciones[jugador];
}


uint8_t Ganador()//Se muestra el ganador
{
    float max = 0;
    uint8_t ganador = 0; // 0 significa empate

    for(int i=0;i<4;i++) {
        if (puntuaciones[i]>= max) {//No hay posibilidad de empate
        	max =puntuaciones[i];
            ganador = i + 1; // Devolvemos 1-4 para los LEDs
        }
    }
    return ganador;
}


float GetRecordActual()//Obtenemos record de la partida
{
	return record_actual_ms;
}


float GetRecordHistorico()//Obtenemos record historico
{
	return record_historico_ms;
}


uint8_t NuevoRecord()//Funcion para ver si hemos hecho record
{
	if(record_actual_ms ==record_historico_ms)//Si el valor actual es igual al histórico es porque lo acabamos de batir
	{
		return 1;
	}
	return 0;
}

