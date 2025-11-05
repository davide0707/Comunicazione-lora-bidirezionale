################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../LoRaWAN/Target/frag_decoder_if.c \
../LoRaWAN/Target/radio_board_if.c 

OBJS += \
./LoRaWAN/Target/frag_decoder_if.o \
./LoRaWAN/Target/radio_board_if.o 

C_DEPS += \
./LoRaWAN/Target/frag_decoder_if.d \
./LoRaWAN/Target/radio_board_if.d 


# Each subdirectory must supply rules for building sources it contributes
LoRaWAN/Target/%.o LoRaWAN/Target/%.su LoRaWAN/Target/%.cyclo: ../LoRaWAN/Target/%.c LoRaWAN/Target/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DCORE_CM4 -DUSE_HAL_DRIVER -DSTM32WLE5xx -c -I../Core/Inc -I../LoRaWAN/App -I../LoRaWAN/Target -I"C:/Users/david/Downloads/CON SPI, FISICO/Wio-E5-mini_lorawan_end_node-main/Wio-E5-mini_lorawan_end_node-main/LoRaWAN_End_Node_WIOE5LEmini_FW1_3_1/Drivers/BSP/STM32WLxx_Nucleo" -I../Drivers/STM32WLxx_HAL_Driver/Inc -I../Drivers/STM32WLxx_HAL_Driver/Inc/Legacy -I../Utilities/trace/adv_trace -I../Utilities/misc -I../Utilities/sequencer -I../Utilities/timer -I../Utilities/lpm/tiny_lpm -I../Middlewares/Third_Party/LoRaWAN/LmHandler/Packages -I../Drivers/CMSIS/Device/ST/STM32WLxx/Include -I../Middlewares/Third_Party/LoRaWAN/Crypto -I../Middlewares/Third_Party/LoRaWAN/Mac/Region -I../Middlewares/Third_Party/LoRaWAN/Mac -I../Middlewares/Third_Party/LoRaWAN/LmHandler -I../Middlewares/Third_Party/LoRaWAN/Utilities -I../Middlewares/Third_Party/SubGHz_Phy -I../Middlewares/Third_Party/SubGHz_Phy/stm32_radio_driver -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-LoRaWAN-2f-Target

clean-LoRaWAN-2f-Target:
	-$(RM) ./LoRaWAN/Target/frag_decoder_if.cyclo ./LoRaWAN/Target/frag_decoder_if.d ./LoRaWAN/Target/frag_decoder_if.o ./LoRaWAN/Target/frag_decoder_if.su ./LoRaWAN/Target/radio_board_if.cyclo ./LoRaWAN/Target/radio_board_if.d ./LoRaWAN/Target/radio_board_if.o ./LoRaWAN/Target/radio_board_if.su

.PHONY: clean-LoRaWAN-2f-Target

