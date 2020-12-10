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
let server     : Bool = true
let client     : Bool = false


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

