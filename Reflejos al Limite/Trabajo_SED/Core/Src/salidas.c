/*
 * salidas.c
 *
 *  Created on: Dec 6, 2025
 *      Author: danie
 */
#include"salidas.h"
#include"entradas.h"

static uint32_t tick_final_sonido = 0;

uint16_t buffer_onda[2] = {4095, 0};

extern TIM_HandleTypeDef htim2;//Referencia a la variable original
extern DAC_HandleTypeDef hdac; //Referencia a variable original


void Encender_Led(uint8_t n)
{
	HAL_GPIO_WritePin(GPIOD, GPIO_PIN_12 | GPIO_PIN_13 | GPIO_PIN_14 | GPIO_PIN_15, GPIO_PIN_RESET);

	switch (n){
		case 1:
				HAL_GPIO_WritePin(GPIOD, GPIO_PIN_12, GPIO_PIN_SET);
			break;
		case 2:
				HAL_GPIO_WritePin(GPIOD, GPIO_PIN_13, GPIO_PIN_SET);
			break;
		case 3:
				HAL_GPIO_WritePin(GPIOD, GPIO_PIN_14, GPIO_PIN_SET);
			break;
		case 4:
				HAL_GPIO_WritePin(GPIOD, GPIO_PIN_15, GPIO_PIN_SET);
			break;
	}
}


void Apagar_Led()
{
	HAL_GPIO_WritePin(GPIOD, GPIO_PIN_12 | GPIO_PIN_13 | GPIO_PIN_14 | GPIO_PIN_15, GPIO_PIN_RESET);
}


void Inicio_Sonido(uint32_t frecuencia)
{
    __HAL_TIM_SET_AUTORELOAD(&htim2, frecuencia);
    __HAL_TIM_SET_COUNTER(&htim2, 0);

    HAL_TIM_Base_Start(&htim2);
    HAL_DAC_Start_DMA(&hdac, DAC_CHANNEL_1, (uint32_t*)buffer_onda, 2, DAC_ALIGN_12B_R);
}

void Detener_Sonido()//Cortamos el sonido de golpe
{
    HAL_DAC_Stop_DMA(&hdac, DAC_CHANNEL_1); //Detenemos el envio de datos al zumbador
    //No se añade Base_Stop ya que sería hacer algo extra

    HAL_GPIO_WritePin(GPIOD, GPIO_PIN_10, GPIO_PIN_RESET); //Se limpia el LED rojo
	HAL_GPIO_WritePin(GPIOD, GPIO_PIN_8, GPIO_PIN_RESET); //Se limpia el LED verde
}

void Actualizar_Sonido()//Condicion para que el sonido dure lo que dure
{
	if (tick_final_sonido != 0 && HAL_GetTick() >= tick_final_sonido) //Si está sonando y
	{
	        HAL_DAC_Stop_DMA(&hdac, DAC_CHANNEL_1); //Detenemos el envio de datos al zumbador
	        HAL_TIM_Base_Stop(&htim2);//Paramos el TIM2

	        //Garantizamos que el led de bien o mal se encienda el mismo tiempo que el pitido
	        HAL_GPIO_WritePin(GPIOD, GPIO_PIN_10, GPIO_PIN_RESET); //Se limpia el LED rojo
			HAL_GPIO_WritePin(GPIOD, GPIO_PIN_8, GPIO_PIN_RESET); //Se limpia el LED verde

	        tick_final_sonido = 0;
	    }
}

void Generar_Sonido(uint32_t tono, uint32_t duracion)
{
		Detener_Sonido();//Para poder interrumpir sonidos

		if (tono < 300) //Si el tono es menor a 300 encendemos led rojo
		{
			HAL_GPIO_WritePin(GPIOD, GPIO_PIN_10, GPIO_PIN_SET); // LED Verde/OK
		}

		else // Si es mayor entonces encendemos el verde
		{
			HAL_GPIO_WritePin(GPIOD, GPIO_PIN_8, GPIO_PIN_SET);  // LED Rojo/Error
		}

		Inicio_Sonido(tono);//Encendemos de nuevo una nota
	    tick_final_sonido = HAL_GetTick() + duracion;
}


void Sonido_Ganar()// Sonido agudo y rápido
{
    Generar_Sonido(150, 200);
}


void Sonido_Perder()// Sonido grave y largo
{
	Generar_Sonido(400, 300);

}

