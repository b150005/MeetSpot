import Foundation

// MARK: - Util

struct Util {
  /// 現在実行中のスレッドを出力する
  /// - Parameter point: 実行ポイント
  static func printCurrentThread(_ point: String) {
    let threadName: String = Thread.isMainThread ? "メイン" : "ワーカー"
    print("-- \(point): \(threadName)スレッド \(Thread.current.description) で実行中 --")
  }
  
  /// 実行開始と`sec`[秒]待機後の終了を通知する同期関数
  /// - Parameters:
  ///   - taskName: タスクの名称
  ///   - sec: 実行待機時間[秒]
  static func waitAndPrintSync(taskName: String, _ sec: Double = 1) {
    print("\(taskName): start waiting for \(sec)[s]")
    Thread.sleep(forTimeInterval: sec)
    print("\(taskName): end")
  }
  
  /// 実行開始と`sec`[秒]待機後の終了を通知する非同期関数
  /// - Parameters:
  ///   - taskName: タスクの名称
  ///   - sec: 実行待機時間[秒]
  static func waitAndPrintAsync(taskName: String, _ sec: Int = 1) async {
    print("\(taskName): start waiting for \(sec)[s]")
    try? await Task.sleep(until: .now + .seconds(sec), clock: .continuous)
    print("\(taskName): end")
  }
  
  /// プログラム実行時間(Program Execution Time; PET)を計測するオブジェクト
  struct PETTracker {
    /// `action`の実行時間を計測する
    /// - parameter action: 実行時間を計測するブロック
    static func track(_ action: () async -> Void) async {
      let start: Date = Date()
      await action()
      let end: Date = Date()
      
      let span: TimeInterval = end.timeIntervalSince(start)
      print("実行時間: \(span)[s]")
    }
  }
}

// MARK: - 直列実行と並列実行

/// async関数を直列・並列に実行する
func compareSerialWithParallel() {
  Util.printCurrentThread("①")
  
  Task.detached {
    Util.printCurrentThread("②")
    
    // 直列処理
    await Util.waitAndPrintAsync(taskName: "Serial-1")
    await Util.waitAndPrintAsync(taskName: "Serial-2")
    await Util.waitAndPrintAsync(taskName: "Serial-3")
    
    Util.printCurrentThread("③")
    
    // 並列処理
    async let first: Void = Util.waitAndPrintAsync(taskName: "Parallel-1")
    async let second: Void = Util.waitAndPrintAsync(taskName: "Parallel-2")
    async let third: Void = Util.waitAndPrintAsync(taskName: "Parallel-3")
    await (first, second, third)
    
    Util.printCurrentThread("④")
  }
  
  Util.printCurrentThread("⑤")
}

//compareSerialWithParallel()

// MARK: - エラーが発生しない同期関数を非同期関数でラップ

/// `completionHandler`を用いた従来の同期関数を`async`を用いた非同期関数で実行する(エラー送出なし)
func execCompletionHandlerInConcurrentContext() {
  /// `completionHandler`を用いた従来の同期関数
  /// - Parameters:
  ///   - taskName: タスクの名称
  ///   - completionHandler: 非同期で実行される無名関数
  @Sendable func oldAsync(taskName:String, completionHandler: @escaping () -> Void) {
    Util.waitAndPrintSync(taskName: taskName)
    completionHandler()
  }
  
  
  /// `async`を用いた新たな非同期関数
  /// - Parameter taskName: タスクの名称
  @Sendable func newAsync(taskName: String) async {
    return await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      oldAsync(taskName: taskName) {
        continuation.resume()
      }
    }
  }
  
  Task.detached {
    await newAsync(taskName: "Task")
  }
}

//execCompletionHandlerInConcurrentContext()

// MARK: - エラーが発生する同期関数を非同期関数でラップ

/// `completionHandler`を用いた従来の同期関数を`async`を用いた非同期関数で実行する(エラー送出あり)
func execCompletionHandlerThrowingErrorInConcurrentContext() {
  /// `completionHandler`を用いた従来の同期関数
  /// - Parameters:
  ///   - taskName: タスクの名称
  ///   - completionHandler: 非同期で実行される無名関数
  @Sendable func oldAsync(taskName: String, completionHandler: @escaping (Result<Void, any Error>) -> Void) {
    Util.waitAndPrintSync(taskName: taskName)
    completionHandler(.failure(NSError(domain: "TestError", code: -1)))
  }
  
  /// `async`を用いた新たな非同期関数
  /// - Parameter taskName: タスクの名称
  /// - Throws: `NSError`
  @Sendable func newAsync(taskName: String) async throws {
    return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
      oldAsync(taskName: taskName) { (result: Result<Void, any Error>) in
        continuation.resume(with: result)
      }
    }
  }
  
  Task.detached {
    do {
      try await newAsync(taskName: "Task")
    }
    catch {
      print(error.localizedDescription)
    }
  }
}

//execCompletionHandlerThrowingErrorInConcurrentContext()

// MARK: - データ競合を防ぐが競合状態は防げないActor

/// **データ競合**を防ぐが**競合状態**にはなりうるActor
actor UsernameCreator {
  /// キャッシュ
  private var cache: [Int : String] = [Int : String]()
  
  /// `userId`に紐づくユーザ名を取得する
  /// - Parameter userId: ユーザID
  /// - Returns: ユーザIDに紐づくユーザ名
  func username(userId: Int) async -> String {
    // キャッシュに保管されたusernameがあればそれを返却
    if let cached: String = cache[userId] {
      return cached
    }
    
    // キャッシュになければ半角スペース含めて10字のユーザ名を生成
    let randomizedUsername: String = await UsernameCreator.random(length: 10)
    
    // キャッシュに保管しusernameを返却
    cache[userId] = randomizedUsername
    return cache[userId]!
  }
  
  /// 指定文字数のランダムなユーザ名を生成する
  /// - Parameter length: ユーザ名のスペースを含む文字数
  /// - Returns: ランダムに生成されたユーザ名
  static func random(length: Int) async -> String {
    try? await Task.sleep(until: .now + .seconds(2), clock: .continuous)
    
    let uppercase: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let lowercase: String = "abcdefghijklmnopqrstuvwxyz"
    let spaceIndex: Int = length <= 1 ? -1 : Int.random(in: 2 ..< length)
    var username: String = ""
    
    for i in 1 ... length {
      switch i {
        case 1, spaceIndex + 1:
          username += String(uppercase.randomElement()!)
        case spaceIndex:
          username += " "
        default:
          username += String(lowercase.randomElement()!)
      }
    }
    
    return username
  }
}

/// 競合状態を発生させる
func causeRaceCondition() {
  let creator: UsernameCreator = UsernameCreator()
  Task.detached {
    print("Task A: \(await creator.username(userId: 1))")
  }
  
  Task.detached {
    print("Task B: \(await creator.username(userId: 1))")
  }
}

//causeRaceCondition()

// MARK: - なぜactorは競合状態を防げないのか

actor RaceConditionCauser {
  var num: Int = 0
  
  /// `num`が0であれば0以外の整数値、0でなければその値を返却する
  func updateIfNumEqualsZero() async -> Int {
    guard num == 0 else { return num }
    num = await generateIntExceptForZero()
    return num
  }
  
  func generateIntExceptForZero() async -> Int {
    try? await Task.sleep(until: .now + .seconds(2), clock: .continuous)
    return Int.random(in: 1...10)
  }
}

func causeRaceConditionSimply() {
  let causerActor = RaceConditionCauser()
  Task.detached {
    print("Task A: \(await causerActor.updateIfNumEqualsZero())")
  }
  
  Task.detached {
    print("Task B: \(await causerActor.updateIfNumEqualsZero())")
  }
}

//causeRaceConditionSimply()

// MARK: - 競合状態を防ぐTask

/// 競合状態を防ぐActor
actor UpdatedUsernameCreator {
  private enum CacheEntry {
    case inProgress(Task<String, Never>)
    case ready(String)
  }
  
  /// キャッシュ
  private var cache: [Int : CacheEntry] = [Int : CacheEntry]()
  
  /// `userId`に紐づくユーザ名を取得する
  /// - Parameter userId: ユーザID
  /// - Returns: ユーザIDに紐づくユーザ名
  func username(userId: Int) async -> String {
    // CacheEntryのキャッシュがあればそこからusernameを取得
    if let cached: CacheEntry = cache[userId] {
      switch cached {
        case .ready(let username):
          return username
        case .inProgress(let task):
          return await task.value
      }
    }
    
    // CacheEntryのキャッシュがなければキャッシュにTaskを追加
    let task: Task<String, Never> = Task {
      await UsernameCreator.random(length: 10)
    }
    
    // inProgress状態でキャッシュに保管
    cache[userId] = .inProgress(task)
    // Suspension Pointを設定することで他スレッドでのusername(userId:)を実行可能にする
    let username: String = await task.value
    cache[userId] = .ready(username)
    
    return username
  }
}

/// 競合状態が発生しない
func neverCauseRaceCondition() {
  let creator: UpdatedUsernameCreator = UpdatedUsernameCreator()
  
  Task.detached {
    print("Task A: \(await creator.username(userId: 1))")
  }
  
  Task.detached {
    print("Task B: \(await creator.username(userId: 1))")
  }
}

//neverCauseRaceCondition()

// MARK: - 非同期で要素をイテレートするAsyncSequence

/// イテレート処理を非同期で行う`AsyncSequence`
struct AlphabetAsyncSequence: AsyncSequence {
  /// `AsyncIteratorProtocol`に準拠する型エイリアス
  /// - note: ※ `AsyncIterator`という名前で宣言する場合は不要
  typealias AsyncIterator = AlphabetAsyncIterator
  
  /// シーケンスの要素の型エイリアス
  /// - note: `AsyncSequence.Element == AsyncSequence.AsyncIterator.Element`
  typealias Element = Character
  
  /// 全体集合となる文字列
  let input: String
  
  init(input: String) {
    self.input = input
  }
  
  /// `AsyncSequence`の次の要素を**非同期**で特定する`AsyncIterator`
  struct AlphabetAsyncIterator: AsyncIteratorProtocol {
    /// シーケンスの要素の型エイリアス
    /// - note: `AsyncSequence.Element == AsyncSequence.AsyncIterator.Element`
    typealias Element = Character
    
    /// 全体集合となる文字列
    let input: String
    
    static let alphabets: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    /// 現在の要素のインデックス番号
    var index: Int = 0
    
    init(input: String) {
      self.input = input
    }
    
    /// 次のアルファベットである要素を**非同期**で特定する
    /// - Returns: 次のアルファベット要素
    mutating func next() async -> Character? {
      var nextCharacter: Character?
      while index < input.count {
        let sliced: Character = input[String.Index(utf16Offset: index, in: input)]
        
        index += 1
        
        if AlphabetAsyncIterator.alphabets.contains(sliced) {
          nextCharacter = sliced
          Util.printCurrentThread("AlphabetAsyncIterator#next()")
          break
        }
      }
      
      return nextCharacter
    }
  }
  
  /// 次の要素を**非同期**で特定する`AsyncIterator`を生成する
  /// - Returns: `AlphabetAsyncIterator`
  func makeAsyncIterator() -> AlphabetAsyncIterator {
    return AlphabetAsyncIterator(input: input)
  }
}

/// イテレート処理を非同期で実行する
func iterateAsynchronously() {
  Task { @MainActor in
    for await alphabet in AlphabetAsyncSequence(input: "あA1いb2うC3") {
      print(alphabet)
    }
  }
}

//iterateAsynchronously()

// MARK: - 通常のfor文と何が違うのか

/// イテレート処理を同期で行う`Sequence`
struct AlphabetSequence: Sequence {
  typealias Iterator = AlphabetIterator
  typealias Element = Character
  let input: String
  
  init(input: String) {
    self.input = input
  }
  
  struct AlphabetIterator: IteratorProtocol {
    typealias Element = Character
    
    let input: String
    static let alphabets: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    var index: Int = 0
    
    init(input: String) {
      self.input = input
    }
    
    /// 次のアルファベットである要素を**同期**で特定する
    /// - Returns: 次のアルファベット要素
    mutating func next() -> Character? {
      var nextCharacter: Character?
      while index < input.count {
        let sliced: Character = input[String.Index(utf16Offset: index, in: input)]
        
        index += 1
        
        if AlphabetIterator.alphabets.contains(sliced) {
          nextCharacter = sliced
          Util.printCurrentThread("AlphabetIterator#next()")
          break
        }
      }
      
      return nextCharacter
    }
  }
  
  /// 次の要素を**同期**で特定する`AsyncIterator`を生成する
  /// - Returns: `AlphabetIterator`
  func makeIterator() -> AlphabetIterator {
    return AlphabetIterator(input: input)
  }
}

/// イテレート処理を同期で実行する
func iterateSynchronously() {
  Task { @MainActor in
    for alphabet in AlphabetSequence(input: "あA1いb2うC3") {
      print(alphabet)
    }
  }
}

//iterateSynchronously()

// MARK: - AsyncSequenceを生成するAsyncStream

// MARK: - エラーが発生しないAsyncSequenceを生成するAsyncStream

/// `AsyncStream`による非同期イテレート処理を実行する
func iterateWithAsyncStream() {
  /// `AsyncStream`を生成する
  /// - Returns: `AsyncStream`
  @Sendable func createAsyncStream() -> AsyncStream<Int> {
    return AsyncStream { (continuation: AsyncStream<Int>.Continuation) in
      Task.detached {
        for i in 0 ..< 10 {
          try? await Task.sleep(until: .now + .nanoseconds(100), clock: .continuous)
          // 要素を追加する
          continuation.yield(i)
        }
        // 要素の追加を終了する
        continuation.finish()
      }
      
      // 要素の追加終了時に呼び出されるコールバック処理
      continuation.onTermination = { (termination: AsyncStream<Int>.Continuation.Termination) in
        switch termination {
          case .cancelled:
            print("AsyncStream.Continuation is cancelled.")
          case .finished:
            print("AsyncStream.Continuation is finished.")
          @unknown default:
            fatalError()
        }
      }
    }
  }
  
  Task.detached {
    var result: [Int] = []
    for await i in createAsyncStream() {
      result.append(i)
    }
    print("AsyncStream is done. - Result: \(result)")
  }
}

//iterateWithAsyncStream()

// MARK: - エラーが発生するAsyncSequenceを生成するAsyncThrowingStream

/// `AsyncThrowingStream`による非同期イテレート処理を実行する
func iterateWithAsyncThrowingStream() {
  /// `AsyncThrowingStream`を生成する
  /// - Returns: `AsyncThrowingStream`
  @Sendable func createAsyncThrowingStream() -> AsyncThrowingStream<Int, any Error> {
    return AsyncThrowingStream { (continuation: AsyncThrowingStream<Int, any Error>.Continuation) in
      Task.detached {
        for i in 0 ..< 10 {
          // 要素を追加する
          continuation.yield(i)
          
          if i >= 5 {
            // 要素の追加を終了し、Errorをスローする
            continuation.finish(throwing: NSError(domain: "TestError", code: -1))
            break
          }
        }
      }
      
      // 要素の追加終了時に呼び出されるコールバック処理
      continuation.onTermination = { (termination: AsyncThrowingStream<Int, any Error>.Continuation.Termination) in
        switch termination {
          case .cancelled:
            print("AsyncThrowingStream.Continuation is cancelled.")
          case .finished:
            print("AsyncThrowingStream.Continuation is finished.")
          @unknown default:
            fatalError()
        }
      }
    }
  }
  
  Task.detached {
    var result: [Int] = []
    do {
      for try await i in createAsyncThrowingStream() {
        result.append(i)
      }
    }
    catch {
      print(error.localizedDescription)
    }
    print("AsyncThrowingStream is done. - Result: \(result)")
  }
}

//iterateWithAsyncThrowingStream()

// MARK: - Taskを階層化するTaskGroup

// MARK: - エラーが発生しないタスクを構造化するTaskGroup

/// `TaskGroup`によってタスクを並列実行する
func executeParallelTasksInTaskGroup() {
  Task.detached {
    await Util.PETTracker.track {
      await withTaskGroup(of: Void.self) { (group: inout TaskGroup<Void>) in
        let tasks: [String] = ["Task A", "Task B", "Task C"]
        for task in tasks {
          group.addTask {
            return await Util.waitAndPrintAsync(taskName: task)
          }
        }
        
        await group.waitForAll()
      }
    }
  }
}

//executeParallelTasksInTaskGroup()

// MARK: - エラーによってタスクをキャンセルするThrowingTaskGroup

func executeParallelTasksThrowingErrorInThrowingTaskGroup() {
  Task.detached {
    await Util.PETTracker.track {
      do {
        try await withThrowingTaskGroup(of: Void.self) { (group: inout ThrowingTaskGroup<Void, any Error>) in
          let tasks: [String] = ["Task A", "Task B", "Task C"]
          for task in tasks {
            group.addTask {
              if task == "Task C" {
                throw NSError(domain: "TestError", code: -1)
              }
              else {
                return await Util.waitAndPrintAsync(taskName: task)
              }
            }
          }
          try await group.waitForAll()
        }
      }
      catch {
        print(error.localizedDescription)
      }
    }
  }
}

//executeParallelTasksThrowingErrorInThrowingTaskGroup()

// MARK: - タスクがキャンセル状態かどうかを判別する

/// タスクのキャンセル状態を確認する
func checkIfTaskIsCancelled() {
  // 外部タスク: 内部タスクのキャンセル状態に応じて文字列を出力し、内部タスクがキャンセルされていなければその値を返却する
  let outer: Task<[Int], Never> = Task.detached {
    // 内部タスク: 1〜10000の整数値を1つずつ追加した配列を返却する
    let inner: Task<[Int], any Error> = Task.detached {
      var result: [Int] = []
      for i in 1...10000 {
        try Task.checkCancellation()
        result.append(i)
      }
      return result
    }
    
    // 内部タスクをキャンセル状態にする
    inner.cancel()
    
    if inner.isCancelled {
      print("Inner Task is cancelled.")
    }
    if Task.isCancelled {
      // 構造化されていないTaskはキャンセル状態が伝播しない
      print("Outer Task is cancelled.")
    }
    
    do {
      return try await inner.value
    }
    catch {
      print(error.localizedDescription)
      return [-1]
    }
  }
  
  Task {
    print("Outer Task returns \(await outer.value).")
  }
}

//checkIfTaskIsCancelled()

