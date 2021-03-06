/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================
  definicion de funciones del scheduler
*/

#include "sched.h"
  #include "i386.h"

unsigned short sched_proximo_indice() {
  return 0;
}

void start_zombie(u8 player, u8 class, u32 y) {
	printf(3,0,"star zombie: %d %d %d",(unsigned int)player,(unsigned int)class,(unsigned int)y);
	breakpoint();
	tss* free_tss = get_free_tss(player,class);
	if(free_tss != 0){
		page_directory* pd =  mmu_inicializar_dir_zombie(player, class, y);
		breakpoint();
		init_tss(free_tss, (u32) pd, ZOMBIE_VIRTUAL, ZOMBIE_VIRTUAL + PAGE_SIZE, (0x48| 3), (0x58 | 3), 0x202);
		breakpoint();
	}
}