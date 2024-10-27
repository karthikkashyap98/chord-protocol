use "time"

class NumberGenerator is TimerNotify
  let _env: Env
  var _counter: U64
  var _limit: U64 = 4
  var _main: Main

  new iso create(env: Env, limit: U64, main: Main) =>
    _counter = 0
    _env = env
    _limit = limit
    _main = main

  fun ref _next(): String =>
    _counter = _counter + 1
    _main.sendMessage(_counter)
    _counter.string()

  fun ref apply(timer: Timer, count: U64): Bool =>
    if _counter >= _limit then 
      return false  
    end

    _env.out.print(_next())
    true