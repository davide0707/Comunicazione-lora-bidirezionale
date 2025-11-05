################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../Core/Startup/startup_stm32wle5jcix.s 

OBJS += \
./Core/Startup/startup_stm32wle5jcix.o 

S_DEPS += \
./Core/Startup/startup_stm32wle5jcix.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Startup/%.o: ../Core/Startup/%.s Core/Startup/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m4 -g3 -DDEBUG -c -I"C:/Users/david/Downloads/CON SPI, FISICO/Wio-E5-mini_lorawan_end_node-main/Wio-E5-mini_lorawan_end_node-main/LoRaWAN_End_Node_WIOE5LEmini_FW1_3_1/Drivers/BSP/STM32WLxx_Nucleo" -I"C:/Users/david/Downloads/CON SPI, FISICO/Wio-E5-mini_lorawan_end_node-main/Wio-E5-mini_lorawan_end_node-main/LoRaWAN_End_Node_WIOE5LEmini_FW1_3_1/Drivers/CMSIS/Include" -I"C:/Users/david/Downloads/CON SPI, FISICO/Wio-E5-mini_lorawan_end_node-main/Wio-E5-mini_lorawan_end_node-main/LoRaWAN_End_Node_WIOE5LEmini_FW1_3_1/Drivers/CMSIS" -x assembler-with-cpp -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@" "$<"

clean: clean-Core-2f-Startup

clean-Core-2f-Startup:
	-$(RM) ./Core/Startup/startup_stm32wle5jcix.d ./Core/Startup/startup_stm32wle5jcix.o

.PHONY: clean-Core-2f-Startup

