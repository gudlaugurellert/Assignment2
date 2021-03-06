///*
// Author: Eli Birgisson
// s2956190
// Griffith University
// Trimester 1, 2017
// 3420ICT Systems Programming
// Assignment 2
// Milestone 3 - Random 16bit Number Generator
// */

import Foundation

class StorageHandler {
  typealias StructP = UnsafeMutablePointer<InputStruct>
  
  // producer open "dev/random" and creates random numbers
  // then the number is passed into the put_buffer function
  func producer(strukkt: UnsafeMutableRawPointer) {

    let sp: StructP = strukkt.assumingMemoryBound(to: InputStruct.self)
    
    var randNum: UInt16 = 0

    let path = "/dev/random"
    let fd = open(path, O_RDONLY)

    if fd != -1 {
      
      // While the exitFlag is false, create random numbers
      while (!sp.pointee.exitFlag.pointee) {
        
        let r = read(fd, &randNum, MemoryLayout<UInt16>.size)
        
        sp.pointee.sem3.pointee.procure()
        sp.pointee.sem1.pointee.procure()
        
        put_buffer(number: randNum, strukkt: strukkt)
        
        if (r != 2) { print("some error with read() ?") }
        
        sp.pointee.sem1.pointee.vacate()
        sp.pointee.sem2.pointee.vacate()
        
      }
    } else {
      print("error opening /dev/random")
    }
    
    close(fd)
  }

  func put_buffer(number: UInt16, strukkt: UnsafeMutableRawPointer) {

    let sp: StructP = strukkt.assumingMemoryBound(to: InputStruct.self)
    
    if(sp.pointee.numberBuffer.pointee.count < sp.pointee.max.pointee) {
      sp.pointee.numberBuffer.pointee.append(number)
    }
  }

  func get_buffer(strukkt: UnsafeMutableRawPointer) -> UInt16 {

    let sp: StructP = strukkt.assumingMemoryBound(to: InputStruct.self)
    
    let oldestNumber = sp.pointee.numberBuffer.pointee.removeFirst()
    
    return oldestNumber
  }
}
