#include "delay.h"
#include <time.h>

 int delay(unsigned int seconds, unsigned long nano){
	struct timespec t1, t2;
	t1.tv_sec = seconds;
	t1.tv_nsec = nano; 
	return nanosleep(&t1,&t2);
}