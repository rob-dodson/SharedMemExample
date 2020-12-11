//
//  main.swift
//  SharedMem
//
//  Created by Robert Dodson on 12/10/20.
//

import Foundation


let data       : String = "UNIX ROCKS!!"
let buffersize : Int = 128
let id         : Int32 = 3
let memkey     : key_t = ftok("/tmp",id) // coordination point for this share mem segment
var server     : Bool = false
var client     : Bool = true
var delete     : Bool = false



for argument in CommandLine.arguments
{
    switch argument
    {
    case "server":
        server = true
        client = false
        delete = false
        
    case "client":
        server = false
        client = true
        delete = false
        
    case "delete":
        server = false
        client = false
        delete = true
        
    case "-?":
        print("Usage: server | client | delete")
        exit(1)
        
    default:
        print(argument)
    }
}


if server == true
{
    if let shared_mem : UnsafeMutableRawPointer = init_shm(memkey: memkey, flags: IPC_CREAT | 0o666, buffersize: buffersize)
    {
        print("(server) Writing data=\(data) at addr=\(shared_mem)");
        shared_mem.copyMemory(from: data, byteCount: data.count)
    }
}
else if client == true
{
    if let shared_mem : UnsafeMutableRawPointer = init_shm(memkey: memkey, flags: 0o666, buffersize: buffersize)
    {
        let bytes = shared_mem.bindMemory(to:UInt8.self, capacity: buffersize)
       
        let str = String.init(cString: bytes)
        print("(server) Reading data=\(str) at addr=\(shared_mem)");
    }
}
else if delete == true
{
    let shmid = shmget(memkey, 0, 0);
    if shmid < 0
    {
        perror("shmid");
        exit(1);
    }

    let shmstat = UnsafeMutablePointer<__shmid_ds_new>.allocate(capacity: 1)
    let err1 =  shmctl(shmid,IPC_STAT,shmstat);
    if err1 < 0
    {
        perror("shmctl IPC_STAT");
        exit(1);
    }

    let err2 = shmctl(shmid,IPC_RMID,shmstat);
    if err2 < 0
    {
        perror("shmctl IPC_RMID");
        exit(1);
    }

    print("Shared memory segment \(shmid) deleted");
}



func init_shm(memkey:key_t,flags:Int32,buffersize:Int) -> UnsafeMutableRawPointer?
{
    let shmid = shmget(memkey,buffersize,flags);
    if shmid < 0
    {
        perror("shmid")
        exit(1)
    }

    let shared_mem = shmat(shmid,nil,SHM_RND);
    if shared_mem == nil
    {
        perror("shmat")
        exit(1)
    }
    
    print("Shared memory segment \(shmid) at \(shared_mem!)")
    
    return shared_mem;
}

