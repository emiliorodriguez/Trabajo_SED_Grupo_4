/*
 * entradas.c
 *
 *  Created on: Dec 6, 2025
 *      Author: danie
 */
#include "entradas.h"

#define TIEMPO_REBOTE 50

static volatile uint8_t flag_boton_pulsado=0; 				//variable local del fichero entrada
static volatile uint8_t flag_temp = 0;						//flag del temporzador de los botones

static volatile uint32_t ultima_interrupcion_valida = 0;	//Guardamos pulsacion válida
static volatile uint32_t tiempo_reaccion[4]={0};			//Guardamos los tiempos de reaccion

extern ADC_HandleTypeDef hadc1; 							//Creamos referencia a variable original
extern TIM_HandleTypeDef htim3; 							//Referencia a variable para timer de botones


void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin) //Se puede usar donde sea pero solamente una vez
{
	uint32_t tiempo_actual = HAL_GetTick();

	if ((tiempo_actual - ultima_interrupcion_valida) > TIEMPO_REBOTE)//Condicion para evitar rebotes
	{

				ultima_interrupcion_valida = tiempo_actual;//Recargamos la ultima interrupcion valida

				if(GPIO_Pin==GPIO_PIN_0)//Boton LED1 (VERDE)
				{
					tiempo_reaccion[0] = __HAL_TIM_GET_COUNTER(&htim3);//Lo primero de todo es capturar el tiempo
					flag_boton_pulsado=1;
				}
				else if(GPIO_Pin==GPIO_PIN_1)//Boton LED2 (ROJO)
				{
					tiempo_reaccion[1] = __HAL_TIM_GET_COUNTER(&htim3);//Lo primero de todo es capturar el tiempo
					flag_boton_pulsado=2;
				}
				else if(GPIO_Pin==GPIO_PIN_2)//Boton LED3 (AZUL)
				{
					tiempo_reaccion[2] = __HAL_TIM_GET_COUNTER(&htim3);//Lo primero de todo es capturar el tiempo
					flag_boton_pulsado=3;
				}
				else if(GPIO_Pin==GPIO_PIN_3)//Boton LED4 (AMARILLO)
				{
					tiempo_reaccion[3] = __HAL_TIM_GET_COUNTER(&htim3);//Lo primero de todo es capturar el tiempo
					flag_boton_pulsado=4;
				}
				else if(GPIO_Pin==GPIO_PIN_7)//Boton START (BLANCO)
				{
					flag_boton_pulsado=5;
				}
				else if(GPIO_Pin==GPIO_PIN_8)//Boton STOP (NEGRO)
				{
					flag_boton_pulsado=6;
				}
	}

}


void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)//Callback del temporizador
{
    if (htim->Instance == TIM3)
    {
			HAL_TIM_Base_Stop_IT(&htim3);// Paramos el reloj
			flag_temp = 1;//Ponemos el flag de que se ha acabado el tiempo a 1

    }
}


uint8_t LeerFlagTemp()//Función para informar del flag del temporizador
{
    return flag_temp;
}


void Limpiar_Flags()//Función de limpiar todos los flags
{
    flag_boton_pulsado = 0;
    flag_temp = 0;

    for(int i=0; i<4; i++) //Limpiamos tiempos
    {
    	tiempo_reaccion[i] = 0;
    }
}


void Limpiar_Btn()//Función de limpiar solo el boton
{
    flag_boton_pulsado = 0;
}


uint32_t Tiempo_pulsacion(uint8_t n_boton)//Devolvemos los tiempos de pulsación
{
	if(n_boton < 4)
	{
		return tiempo_reaccion[n_boton];
	}
	else
	{
		return 0;
	}
}


uint8_t LeerBoton() //Para que podamos devolver el flag de pulsacionn
{
    uint8_t aux = flag_boton_pulsado; // Guardamos el botón que llegó
    flag_boton_pulsado = 0;           // Borramos el flag para poder detectar más pulsaciones
    return aux;						  // Devolvemos la variable guardada
}


uint32_t LeerPotenciometro()//Devolvemos la lectura del potenciometro
{
	uint32_t valor_leido = 0;
	HAL_ADC_Start(&hadc1);//Iniciamos conversino de Analogico a Digital

	if (HAL_ADC_PollForConversion(&hadc1, 10) == HAL_OK) //Si tardamos menos de 10 ms en hacer la conversion pasamos el valro leido
	{
		valor_leido = HAL_ADC_GetValue(&hadc1);// Leemos el valor (0 a 4095). Ya que si nos vamos a la resolución en el main, es de 12 bits.
	}

	HAL_ADC_Stop(&hadc1);//Lo paramos para no estar consumiendo de más
	return valor_leido;
}


void Temporizador_Preparar(uint32_t ms)
{
    __HAL_TIM_SET_AUTORELOAD(&htim3, ms * 10);
    __HAL_TIM_SET_COUNTER(&htim3, 0);
}

void Temporizador_Iniciar()
{
    HAL_TIM_Base_Start_IT(&htim3);
}


void Temporizador_Parar()
{
    HAL_TIM_Base_Stop_IT(&htim3);
}




