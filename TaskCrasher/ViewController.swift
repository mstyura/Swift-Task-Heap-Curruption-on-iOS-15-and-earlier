//
//  ViewController.swift
//  TaskCrasher
//
//  Created by Yury Yarashevich on 3.02.23.
//

import UIKit

func globalAsyncFunction() async {
  Task { // crash with libgmalloc enabled at this line on iOS <= 15.5
    
  }
}

class MyClass {
  func asyncFunction() async {
    Task { // crash with libgmalloc enabled at this line on iOS <= 15.5
      
    }
  }
  
  func syncFunction() {
    Task {
      
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
    ok3()
    // BUG: Uncomment any to cause crash with libgmalloc enabled
//    willCauseHeapCorruption1()
//    willCauseHeapCorruption2()
//    willCauseHeapCorruption3()
//    willCauseHeapCorruption4()
//    willCauseHeapCorruption5()
    willCauseHeapCorruption6();
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
      Task { // crash with libgmalloc enabled at this line on iOS <= 15.5
        
      }
    }
  }
  
  func willCauseHeapCorruption4() {
    runSendableClosure {
      Task { // crash with libgmalloc enabled at this line on iOS <= 15.5
      }
    }
  }
  
  func willCauseHeapCorruption5() {
    Task.detached {
      Task {
        
      }
    }
  }

  func willCauseHeapCorruption6() {
    Task {
      let c = MyClass()
      c.syncFunction()
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
    DispatchQueue.global().async {
      Task {
        
      }
    }
  }
  
  func ok3() {
    DispatchQueue.global().async {
      Task {
        Task {
          
        }
      }
    }
  }
}

