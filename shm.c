//
// Unix/macOS shared memory example in C
//
// Typical usage: 
//    shm server <msg>
//    shm client
//    shm delete
//

#include <sys/shm.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h> 
#include <unistd.h> 
#include <sys/errno.h>
#include <string.h>

void* init_shm(key_t memkey,int flags,int buffersize);
void dump(struct shmid_ds s);

int main(int argc, char** argv) 
{
    void *shared_mem = NULL;
    char* data = "UNIX ROCKS";
	int buffersize = 128;

	if (argc < 2 || strcmp(argv[1],"-?") == 0)
	{
		fprintf(stderr,"Usage: %s server <msg> | client | delete\n",argv[0]);
		exit(1);
	}


	//
	// generate an IPC identifier based on a file path and an id
	// 
	key_t memkey = ftok("/tmp",3);
	
	//
	// server creates and writes to the shared mem buffer
	//
	if (strcmp(argv[1],"server") == 0)
	{
		void* shared_mem = init_shm(memkey,IPC_CREAT | 0666,buffersize);

		char* msg = argv[2];
        printf("(server) Writing data=\"%s\" at addr=%p\n",msg, shared_mem);
		strncpy(shared_mem,msg,buffersize);
	}
	//
	// server reads from the shared mem buffer
	//
	else if (strcmp(argv[1],"client") == 0)
	{
		void* shared_mem = init_shm(memkey,0666,buffersize);

		char buf[buffersize];
		memset(buf,'0',buffersize);
		strncpy(buf,shared_mem,strlen(buf));
        printf("(client) Reading from addr=%p returned data=\"%s\"\n", shared_mem, buf);
	}
	//
	// tell the OS to delete this shared mem segment
	//
	else if (strcmp(argv[1],"delete") == 0)
	{
		int shmid =	shmget(memkey, 0, 0);
		if (shmid < 0)
        {
            perror("shmid");
            exit(1);
        }

		struct shmid_ds shmstat;
		int err =  shmctl(shmid,IPC_STAT,&shmstat);
		if (err < 0)
        {
            perror("shmctl IPC_STAT");
            exit(1);
        }

		dump(shmstat);

		err = shmctl(shmid,IPC_RMID,&shmstat);
		if (err < 0)
        {
            perror("shmctl IPC_RMID");
            exit(1);
        }

		printf("Shared memory segment %d deleted\n",shmid);
	}
	else
	{
		fprintf(stderr,"Specify server or client or delete\n");
		exit(1);
	}	

    return 0;
}


//
// get a shared memory area and attach it to our memory space
//
void* init_shm(key_t memkey,int flags,int buffersize)
{
		int shmid = 0;
		void* shared_mem = 0;

		shmid =	shmget(memkey, buffersize, flags);
		if (shmid < 0)
		{
			perror("shmid");
			exit(1);
		}

		shared_mem = shmat(shmid,0,0);
		if (shared_mem < 0)
		{
			perror("shmat");
			exit(1);
		}

		printf("Shared memory segment %d attached at %p\n",shmid,shared_mem);

		return shared_mem;
}


void dump(struct shmid_ds s)
{
	 printf("shm_segsz %lu\n",s.shm_segsz);
	 printf("shm_lpid %d\n",s.shm_lpid);
	 printf("shm_cpid %d\n",s.shm_cpid);
	 printf("shm_nattch %d\n",s.shm_nattch);
	 printf("shm_atime %ld\n",s.shm_atime);
	 printf("shm_dtime %ld\n",s.shm_dtime);
	 printf("shm_ctime %ld\n",s.shm_ctime);
}
