#include <time.h>

 int delay(unsigned long nano, unsigned int seconds){
	struct timespec t1, t2;
	t1.tv_sec = seconds;
	t1.tv_nsec = nano; 
	return nanosleep(t1,t2);
}