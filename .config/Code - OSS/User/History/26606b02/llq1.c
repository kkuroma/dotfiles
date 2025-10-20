#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

extern int exec(char*, char**);

int
sys_fork(void)
{
  return fork();
}

int sys_clone(void)
{
  int fn, stack, arg;
  argint(0, &fn);
  argint(1, &stack);
  argint(2, &arg);
  return clone((void (*)(void*))fn, (void*)stack, (void*)arg);
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  if (n == 0) {
    yield();
    return 0;
  }
  acquire(&tickslock);
  ticks0 = ticks;
  myproc()->sleepticks = n;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  myproc()->sleepticks = -1;
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// remain system call, changes remaining time to new time
int sys_remain(void) {
  int new_time;
  struct proc *curproc = myproc();

  // get new arg and check if time is a positive integer
  if(argint(0, &new_time) < 0)
    return -1;
  if(new_time <= 0)
    return -1;
  
  // set time to new time
  int old_time = curproc->completion_time;
  curproc->completion_time = new_time;
  
  // if new time > old time, reschedule
  if(new_time > old_time) {
    yield();  // Invoke scheduler
  }
  
  return 0;
}

// exec2 system call, changes the completiuon of the current process to `time_to_complete` and then `exec` the new program.
int sys_exec2(void) {
  int time_to_complete;
  char *path, **argv;
  struct proc *curproc = myproc();
  
  // get arguments and validate 
  if(argint(0, &time_to_complete) < 0)
    return -1;
  if(argstr(1, &path) < 0)
    return -1;
  if(argptr(2, (void*)&argv, sizeof(char*)) < 0)
    return -1;
  if(time_to_complete <= 0)
    return -1;
  
  // set time to time to complete
  int old_time = curproc->completion_time;
  curproc->completion_time = time_to_complete;
  
  // call exec, two outcomes 1) exec suceeds, we dont return here 2) exec fails, restore old time
  int result = exec(path, argv);
  curproc->completion_time = old_time;
  return result;
}

// give_cpu system call, yields cpu and set skip flag
int sys_give_cpu(void) {
  struct proc *curproc = myproc();
  curproc->skip_in_scheduler = 1;
  yield();
  curproc->skip_in_scheduler = 0;
  return 0;
}