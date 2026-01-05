/*
 * juego.c
 *
 *  Created on: Dec 7, 2025
 *      Author: danie
 */
#include "juego.h"

#define TIEMPO_FACIL 4000 // 4 segundos
#define TIEMPO_DIFICIL  250 // 0.25 segundos
#define TIEMPO_RONDAS 3000 //3 segundos
#define TIEMPO_FIN 5000 //5 segundos
#define TIEMPO_ESPERA 1000 //1 segundo
#define TIEMPO_GANADOR 2000 //2 segundo
#define TIEMPO_PARTIDA 30000//30 segundos

static uint8_t indice = 4; //Variable para sacar leds
static uint8_t estado=INICIO; //Estados del juego
static uint8_t ronda=0; //ronda en la que estamos

static uint32_t tiempo_espera=0;

static char buffer[20];

extern TIM_HandleTypeDef htim3;
extern TIM_HandleTypeDef htim2;


void Juego()
{
	uint8_t boton_pulsado = LeerBoton();
	static uint8_t sub_estado_inicio=0;

	switch (estado){

		case INICIO:

			Actualizar_Sonido();//Para parar los sonidos en caso de apagado

			if (sub_estado_inicio==0)
				{
					if(boton_pulsado==5)
					{
						lcd_clear();
						lcd_enviar("LISTOS...", 0, 0);

						tiempo_espera=HAL_GetTick();
						sub_estado_inicio=1;
					}
				}

			else if (sub_estado_inicio == 1)
				{
					if (HAL_GetTick()-tiempo_espera >= TIEMPO_ESPERA)// Comprobamos si ha pasado 1 seg para que se vea el mensaje
					{
						lcd_enviar("YA!        ", 0, 0);
						srand(HAL_GetTick()); //Reiniciamos la semilla
						Reiniciar_Bolsa(); //Reiniciamos el inidice de la bolsa
						Reinicio_Puntuaciones(); //Reiniciamos las puntuaciones
						Limpiar_Flags(); //Limpiamos tiempos y botones

						ronda=0; //Reiniciamos las rondas
						sub_estado_inicio=0;
						estado=LEDS; //Pasamos al estado LEDS
					}
				}

		break;



		case LEDS:

			if (ronda < 3) //Jugamos hasta completar las 3 rondas
			{


				//1. Lógica de espera entre rondas--------------------------------------------------------------------------------
				ronda++;

				if(ronda>1)
				{
					lcd_clear();
					sprintf(buffer, "RONDA %d", ronda);
					lcd_enviar(buffer, 0, 0);
				}

				uint32_t espera_rondas = HAL_GetTick();

				while (HAL_GetTick()-espera_rondas < TIEMPO_RONDAS)//Esperamos 3 segundos hasta empezar la siguiente ronda
				{
					Actualizar_Sonido();//Para que se termine el sonido en caso de pulsar algo

					uint8_t boton_ahora=LeerBoton();

					if (boton_ahora == 6)//Por si queremos acabar antes
					{
						Detener_Sonido();		//Cortamos lo que esté sonando
						Apagar_Led();			//Apagamos todos los leds
						Temporizador_Parar(); 	//Paramos temporizador
						Finalizando();			//Finalizamos

						return;					//Salimos de la funcion completa
					}
					else if (boton_ahora >= 1 && boton_ahora <= 4)//Si pulsamos en el tiempo de espera se penaliza
					{
						Penalizacion(boton_ahora);
						Limpiar_Flags();
					}


				}
				//----------------------------------------------------------------------------------------------------------------



				//2. Lógica de ronda activa---------------------------------------------------------------------------------------
				uint32_t espera_partida=HAL_GetTick();

				while (HAL_GetTick()-espera_partida < TIEMPO_PARTIDA)//Comienza la ronda
				{


					//2.1. Logica de espera entre encendido de leds---------------------------------
					uint32_t pausa_corta = HAL_GetTick();

					while(HAL_GetTick()-pausa_corta < TIEMPO_ESPERA)//Esperamos 1 segundo hasta el encendido del siguiente led
					{
						Actualizar_Sonido();

						uint8_t boton_ahora = LeerBoton();

						if(boton_ahora == 6 ) //Por si se quiere finalizar antes
						 {
							 Detener_Sonido();
							 Apagar_Led();
							 Temporizador_Parar();
							 Finalizando();

							 return;
						 }

						else if(boton_ahora >= 1 && boton_ahora <= 4) //Si se pulsa antes del encedido se penaliza
						 {
							 Penalizacion(boton_ahora);
							 Limpiar_Flags();
						 }


					}
					//------------------------------------------------------------------------------



					//2.2. Logica de encendido de leds y puntuaciones-------------------------------
					uint8_t LED=LED_Elegido();
					uint32_t tiempo_limite=Tiempo_Limite(); //Tiempo que se queda encendido un led (Lo variamos con el potenciometro)

					/*lcd_clear();
					sprintf(buffer, "VELOCIDAD: %li", tiempo_limite);
					lcd_enviar(buffer, 1, 0);*/

					Temporizador_Preparar(tiempo_limite);//Preparamos los temporizadores
					Limpiar_Flags();//Limpiamos flags
					Encender_Led(LED);//Encendemos leds
					Temporizador_Iniciar(); //Comenzamos el temporizador

					uint8_t turno_terminado=0;
					uint8_t puntuado=0;

					while (turno_terminado == 0)//Mientras no termine el turno
					{

						Actualizar_Sonido();

						uint8_t boton_ahora = LeerBoton();

						if (boton_ahora == 6 ) //Si queremos salir en mitad de la partida
						{
							Detener_Sonido();
							Apagar_Led();
							Temporizador_Parar();
							Finalizando();

							return;
						}



						else if (boton_ahora >= 1 && boton_ahora <= 4) //Si hay pulsacion de boton
						{
							if (boton_ahora==LED) //Si coincide con el led
							{
								if(puntuado == 0) //Vemos si ya ha puntuado
								{
									Aumento(LED,tiempo_limite);
									puntuado  = 1;//Termina el turno
								}

							}
							else//Si no ha coincidido
							{
								Penalizacion(boton_ahora);
								Limpiar_Btn();
							}
						}


						if (LeerFlagTemp()==1)//Si ha terminado el tiempo
						{
							Apagar_Led();
							Temporizador_Parar();

							if (puntuado==0)
							{
								Penalizacion(LED);
							}

							Limpiar_Flags();
							turno_terminado= 1;//Termina el turno
						}

					}
					//-----------------------------------------------------------------------------

				}
			}


			else//Hemos completado las tres rondas
			{
				estado=RESULTADOS;//Pasamos a ver los reusltados
			}

		break;



		case RESULTADOS:

			Actualizar_Sonido(); //Para que terminen sonidos de antes

			if (sub_estado_inicio ==0)
			{
				uint8_t ganador=Ganador();

				static uint8_t pantalla=0;
				static uint32_t ultima_actualizacion=0;

				if (HAL_GetTick()-ultima_actualizacion > TIEMPO_GANADOR)//Mostramos dos segundos el ganador y otros dos segundos el record
				{
					lcd_clear();

						if (pantalla== 0)
						{
							if(GetTotal(ganador-1) > 0) // Muestra Ganador
							{
								 sprintf(buffer, "GANADOR: J%d", ganador);
								 lcd_enviar(buffer, 0, 0);
								 sprintf(buffer, "MAX: %.2f PTS", GetTotal(ganador-1));
								 lcd_enviar(buffer, 1, 0);
							}

							else //Por si nadie ganó
							{
								 lcd_enviar("NADIE GANO", 0, 0);
							}

							pantalla = 1;
						}

						else
						{
							float record = GetRecordHistorico();

							if (NuevoRecord() == 1 && record < 9000)//Nuevo record
							{
								lcd_enviar("!!NUEVO RECORD!!", 0, 0);
								sprintf(buffer, "T: %.0f ms", record);
								lcd_enviar(buffer, 1, 0);
							}

							else//Record antiguo
							{
								lcd_enviar("RECORD HIST:", 0, 0);

								if(record < 9000)
								{
									sprintf(buffer, "%.0f ms", record);
								}

								else
								{
									sprintf(buffer, "---"); // Si nadie ha jugado nunca
								}

								lcd_enviar(buffer, 1, 0);
							}

							pantalla = 0;
						}

					 ultima_actualizacion = HAL_GetTick();
				}

				if(boton_pulsado==5)//Si queremos jugar de nuevo
				{
					lcd_clear();
					lcd_enviar("LISTOS...", 0, 0);

					tiempo_espera = HAL_GetTick();
					sub_estado_inicio = 1;
				}

				if (boton_pulsado==6)//Volvemos al inicio
				{
					Finalizando();
				}

			}

			else if (sub_estado_inicio== 1)
			{
				if (HAL_GetTick()-tiempo_espera>= TIEMPO_ESPERA)// Comprobamos si ha pasado 1 seg
				{
					lcd_enviar("YA!        ", 0, 0);
					srand(HAL_GetTick()); //Reiniciamos la semilla
					Reiniciar_Bolsa(); //Reiniciamos el inidice de la bolsa
					Reinicio_Puntuaciones(); //Reiniciamos las puntuaciones
					Limpiar_Flags(); //Limpiamos tiempos y botones

					ronda=0; //Reiniciamos las rondas
					sub_estado_inicio=0;
					estado=LEDS; //Pasamos al estado LEDS
				}
			}

		break;
	}
}

uint32_t Tiempo_Limite()//Tiempo de espera entre cambio de leds (Es una forma de que haya un cambio lineal al variar el potenciometro)
{
    uint32_t lectura_adc = LeerPotenciometro();//Leemos el potenciometro
    uint32_t rango = TIEMPO_FACIL - TIEMPO_DIFICIL;// rango de dificultad
    uint32_t tiempo_a_restar = (lectura_adc * rango) / 4095;    // Aplicamos la fórmula para variacion lineal
    return TIEMPO_FACIL - tiempo_a_restar; //  Calculamos el tiempo de espera entre cambio de leds
}


uint8_t LED_Elegido() //Fucnion para elegir LED
{
	static uint8_t led[4]={1,2,3,4};//Array de leds

	if (indice >= 4)
	{
		for (int i=3; i>0;i--)
		{
			int j= rand() % (i + 1); // Elegimos una posición al azar
			uint8_t temp= led[i];
			led[i]= led[j];//Intercambiamos posiciones
			led[j]= temp;
		}
		indice=0; // Reseteamos el índice para empezar a sacar desde el 0
	}
	return led[indice++];//Vamos devolviendo la secuencia cuando se llama a la funcion. Cuando se llega a 4 se vuelve a meter en el if
}

void Reiniciar_Bolsa()
{
	indice = 4; //Esto forzará un barajado nuevo la próxima vez que pidas un LED
}


void Finalizando() //Logica de apagado
{
	 lcd_clear();
	 lcd_enviar("FINALIZANDO", 0, 0);

	 tiempo_espera = HAL_GetTick();

	 while(HAL_GetTick()-tiempo_espera<TIEMPO_FIN)//Esperamos 5 seg. Aqui da igual el bloqueo ya que podemos salir de el y porque estamoa acabando.
	 {
		 HAL_GPIO_WritePin(GPIOD, GPIO_PIN_12 | GPIO_PIN_13 | GPIO_PIN_14 | GPIO_PIN_15, GPIO_PIN_SET); //No usamos Encender Led ya que solo se enciende uno
	 }

	 Apagar_Led();

	 estado = INICIO;
	 lcd_enviar("PRESIONA START", 0, 0);

}


float Restamos(uint8_t pulsacion)
{
	return Fallo(pulsacion - 1);
}

float Sumamos(uint8_t pulsacion, uint32_t tlim)
{
	return Acierto(pulsacion - 1, Tiempo_pulsacion(pulsacion - 1), tlim);//Sumamos puntuacion

}

void Penalizacion(uint8_t btn)
{

	lcd_clear();
	sprintf(buffer, "J%d MAL %.1f", btn, Restamos(btn));
	lcd_enviar(buffer, 0, 0);
	lcd_enviar("PENALIZACION", 1, 0);
	Sonido_Perder();

}

void Aumento(uint8_t btn, uint32_t tlim)
{
	float t_ms = (Tiempo_pulsacion(btn - 1)) / 10.0f; // Calculamos ms

	lcd_clear();
	sprintf(buffer, "J%d OK! +%.2f", btn, Sumamos(btn,tlim));
	lcd_enviar(buffer, 0, 0);
	sprintf(buffer, "T: %.0fms", t_ms);
	lcd_enviar(buffer, 1, 0);
	Sonido_Ganar();

}

