        .syntax unified
	
	      .include "efm32gg.s"

	/////////////////////////////////////////////////////////////////////////////
	//
        // Exception vector table
        // This table contains addresses for all exception handlers
	//
	/////////////////////////////////////////////////////////////////////////////
	
        .section .vectors
	
	      .long   stack_top               /* Top of Stack                 */
	      .long   _reset                  /* Reset Handler                */
	      .long   dummy_handler           /* NMI Handler                  */
	      .long   dummy_handler           /* Hard Fault Handler           */
	      .long   dummy_handler           /* MPU Fault Handler            */
	      .long   dummy_handler           /* Bus Fault Handler            */
	      .long   dummy_handler           /* Usage Fault Handler          */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* SVCall Handler               */
	      .long   dummy_handler           /* Debug Monitor Handler        */
	      .long   dummy_handler           /* Reserved                     */
	      .long   dummy_handler           /* PendSV Handler               */
	      .long   dummy_handler           /* SysTick Handler              */

	      /* External Interrupts */
	      .long   dummy_handler
	      .long   gpio_handler            /* GPIO even handler */
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   gpio_handler            /* GPIO odd handler */
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler
	      .long   dummy_handler

	      .section .text
		
		

	/////////////////////////////////////////////////////////////////////////////
	//
	// Reset handler
        // The CPU will start executing here after a reset
	//
	/////////////////////////////////////////////////////////////////////////////

	      .globl  _reset
	      .type   _reset, %function
          .thumb_func
_reset: 

	//ENABLE GPIO CONTROLLER
										
	ldr r1, =CMU_BASE					// load CMU base address
	ldr r2, [r1, #CMU_HFPERCLKEN0]		// load current value of HFPERCLK ENABLE
	mov r3, #1							// set bit for GPIO clk 
	lsl r3, r3, #CMU_HFPERCLKEN0_GPIO	// left shit bit 13 times to enable GPIO clock
	orr r2, r2, r3						// use logical operation OR to write bit to r2 value
	str r2, [r1, #CMU_HFPERCLKEN0]		// store in memory


	//ACTIVATE LED BIT

	ldr r1, =GPIO_PA_BASE				// load GPIO base address for leds
	
	mov r2, #0x2						// sets high drive strength
	str r2, [r1, #GPIO_CTRL] 		

	mov r3, #0x55555555					// turns on output for GPIO-pins 
	str r3, [r1, #GPIO_MODEH] 

	mov r4, #0x00000000					// sets output to on (on equals off)
	str r4, [r1, #GPIO_DOUT] 

	//ACTIVATE BUTTON INPUT

	ldr r2, =GPIO_PC_BASE					// load GPIO base address for buttons

	mov r3, #0x33333333					// set pins 0-7 to input mode
	str r3, [r2, #GPIO_MODEL]
	mov r4, #0xff						// enable pull up mode
	str r4, [r2, #GPIO_DOUT]

	//ACTIVATE INTERRUPT HANDLER

	ldr r1, =GPIO_BASE
	mov r2, #0x22222222
	str r2, [r1, #GPIO_EXTIPSELL]
	
	mov r2, #0xff
	str r2, [r1, #GPIO_EXTIFALL]
	str r2, [r1, #GPIO_EXTIRISE]

	str r2, [r1, #GPIO_IEN]

	ldr r2, =0x802
	ldr r3, =ISER0
	str r2, [r3]

	ldr r6, =SCR
	mov r7, #6
	str r7, [r6]
	
	wfi
	
	/////////////////////////////////////////////////////////////////////////////
	//
	// GPIO handler
	// The CPU will jump here when there is a GPIO interrupt
	//
	/////////////////////////////////////////////////////////////////////////////
	
        .thumb_func
gpio_handler:
	ldr r1, =GPIO_BASE
	ldr r2, =GPIO_PA_BASE
	ldr r3, =GPIO_PC_BASE
	
	ldr r4, [r1, #GPIO_IF]  // load the source of the interrupt
	str r4, [r1, #GPIO_IFC] //clear interrupt
	
	ldr r5, [r3, #GPIO_DIN]
	lsl r5, r5,  #8
	str r5, [r2, #GPIO_DOUT]

	bx lr


	
	/////////////////////////////////////////////////////////////////////////////
	
        .thumb_func
dummy_handler:  
        b .  // do nothing

