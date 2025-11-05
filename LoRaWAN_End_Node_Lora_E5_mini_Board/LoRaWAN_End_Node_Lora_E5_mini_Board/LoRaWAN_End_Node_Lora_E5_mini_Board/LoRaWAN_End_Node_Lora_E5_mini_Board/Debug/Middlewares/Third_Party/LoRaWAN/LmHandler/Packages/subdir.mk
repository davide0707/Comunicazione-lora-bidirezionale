################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/FragDecoder.c \
../Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpClockSync.c \
../Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpCompliance.c \
../Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpFirmwareManagement.c \
../Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpFragmentation.c \
../Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpPackagesRegistration.c \
../Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpRemoteMcastSetup.c 

OBJS += \
./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/FragDecoder.o \
./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpClockSync.o \
./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpCompliance.o \
./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpFirmwareManagement.o \
./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpFragmentation.o \
./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpPackagesRegistration.o \
./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpRemoteMcastSetup.o 

C_DEPS += \
./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/FragDecoder.d \
./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpClockSync.d \
./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpCompliance.d \
./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpFirmwareManagement.d \
./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpFragmentation.d \
./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpPackagesRegistration.d \
./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpRemoteMcastSetup.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/%.o Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/%.su Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/%.cyclo: ../Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/%.c Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DCORE_CM4 -DUSE_HAL_DRIVER -DSTM32WLE5xx -c -I../Core/Inc -I../LoRaWAN/App -I../LoRaWAN/Target -I"C:/Users/david/Downloads/CON SPI, FISICO/Wio-E5-mini_lorawan_end_node-main/Wio-E5-mini_lorawan_end_node-main/LoRaWAN_End_Node_WIOE5LEmini_FW1_3_1/Drivers/BSP/STM32WLxx_Nucleo" -I../Drivers/STM32WLxx_HAL_Driver/Inc -I../Drivers/STM32WLxx_HAL_Driver/Inc/Legacy -I../Utilities/trace/adv_trace -I../Utilities/misc -I../Utilities/sequencer -I../Utilities/timer -I../Utilities/lpm/tiny_lpm -I../Middlewares/Third_Party/LoRaWAN/LmHandler/Packages -I../Drivers/CMSIS/Device/ST/STM32WLxx/Include -I../Middlewares/Third_Party/LoRaWAN/Crypto -I../Middlewares/Third_Party/LoRaWAN/Mac/Region -I../Middlewares/Third_Party/LoRaWAN/Mac -I../Middlewares/Third_Party/LoRaWAN/LmHandler -I../Middlewares/Third_Party/LoRaWAN/Utilities -I../Middlewares/Third_Party/SubGHz_Phy -I../Middlewares/Third_Party/SubGHz_Phy/stm32_radio_driver -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Middlewares-2f-Third_Party-2f-LoRaWAN-2f-LmHandler-2f-Packages

clean-Middlewares-2f-Third_Party-2f-LoRaWAN-2f-LmHandler-2f-Packages:
	-$(RM) ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/FragDecoder.cyclo ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/FragDecoder.d ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/FragDecoder.o ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/FragDecoder.su ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpClockSync.cyclo ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpClockSync.d ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpClockSync.o ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpClockSync.su ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpCompliance.cyclo ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpCompliance.d ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpCompliance.o ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpCompliance.su ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpFirmwareManagement.cyclo ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpFirmwareManagement.d ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpFirmwareManagement.o ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpFirmwareManagement.su ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpFragmentation.cyclo ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpFragmentation.d ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpFragmentation.o ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpFragmentation.su ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpPackagesRegistration.cyclo ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpPackagesRegistration.d ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpPackagesRegistration.o ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpPackagesRegistration.su ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpRemoteMcastSetup.cyclo ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpRemoteMcastSetup.d ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpRemoteMcastSetup.o ./Middlewares/Third_Party/LoRaWAN/LmHandler/Packages/LmhpRemoteMcastSetup.su

.PHONY: clean-Middlewares-2f-Third_Party-2f-LoRaWAN-2f-LmHandler-2f-Packages

