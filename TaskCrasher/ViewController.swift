//
//  ViewController.swift
//  TaskCrasher
//
//  Created by Yury Yarashevich on 3.02.23.
//

import UIKit

func globalAsyncFunction() async {
  Task { // crash with libgmalloc enabled at this line on iOS < 16
    
  }
}

class MyClass {
  func asyncFunction() async {
    Task { // crash with libgmalloc enabled at this line on iOS < 16
      
    }
  }
  
  func syncFunction() {
    Task { // crash with libgmalloc enabled at this line on iOS < 16
      
    }
  }
}

func runSendableClosure(_ closure: @Sendable @escaping () -> Void) {
  closure()
}

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    ok0()
    ok1()
    ok2()
    // BUG: Uncomment any to cause crash with libgmalloc enabled
//    mayCauseHeapCorruption1()
//    mayCauseHeapCorruption2()
//    willCauseHeapCorruption1()
//    willCauseHeapCorruption2()
//    willCauseHeapCorruption3()
//    willCauseHeapCorruption4()
//    willCauseHeapCorruption5()
//    willCauseHeapCorruption6()
//    willCauseHeapCorruption7()
  }

  func willCauseHeapCorruption1() {
    Task {
      await globalAsyncFunction()
    }
  }
  
  func willCauseHeapCorruption2() {
    Task {
      let c = MyClass()
      await c.asyncFunction()
    }
  }

  func willCauseHeapCorruption3() {
    @globalActor
    struct MyGlobalActor {
      private actor ActorImpl { }

      public static let shared: some Actor = ActorImpl()
    }

    Task { @MyGlobalActor in
      Task { // crash with libgmalloc enabled at this line on iOS < 16
        
      }
    }
  }
  
  func willCauseHeapCorruption4() {
    runSendableClosure {
      Task { // crash with libgmalloc enabled at this line on iOS < 16
      }
    }
  }
  
  func willCauseHeapCorruption5() {
    Task.detached {
      Task {
        print("Hello")
      }
    }
  }

  func willCauseHeapCorruption6() {
    Task {
      let c = MyClass()
      c.syncFunction()
    }
  }
  
  func willCauseHeapCorruption7() {
    actor MyActor {
      func createTask() {
        Task { // crash with libgmalloc enabled at this line on iOS < 16
          
        }
      }
    }
    Task {
      let a = MyActor()
      await a.createTask()
    }
  }

  func mayCauseHeapCorruption1() {
    DispatchQueue.global().async {
      Task {
        
      }
    }
  }
  
  func mayCauseHeapCorruption2() {
    DispatchQueue.global().async {
      Task {
        Task {
          
        }
      }
    }
  }

  func ok0() {
    Task {
      
    }
  }

  func ok1() {
    Task {
      Task {
        
      }
    }
  }

  func ok2() {
    Task.detached {
      let context = 12
      Task {
        print("Hello: \(context)")
      }
    }
  }
}

