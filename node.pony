use "collections"

actor Node
    let _id: U64
    let _main: Main
    let _env: Env
    var _finger_table: Map[U64, Node] val
    var _fingerTableKeys: Array[U64] val = []
    var predecessor: U64 = 0

    new create(id: U64, main: Main, env: Env) =>
        _id = id
        _main = main
        _env = env
        _finger_table = Map[U64, Node]

    fun getId(): U64 =>
        _id

    be printId() =>
        _env.out.print("Someone triggered a print: " + _id.string())

    be setPredecessor(pre: U64) =>
        predecessor = pre
        _env.out.print("My ID: " + _id.string() + " Pred: " + predecessor.string())



    be setFingerTable(nodes: Map[U64, Node tag] val, fingerTableKeys: Array[U64] val) =>
        _finger_table = nodes
        _fingerTableKeys = fingerTableKeys


    be lookup(key: U64, hops: U64 = 0) =>
        _env.out.print("MyID: " + _id.string() + " Key: " + key.string() + " Hops: " + hops.string())
        try
            if (predecessor > _id) and (key <= _id) then 
                _main.notifyHops(hops)
                return
            end

            if (predecessor < key) and (key <= _id) then 
                _main.notifyHops(hops)
            elseif (_id < key) and (key <= _fingerTableKeys(0)?) then
                _main.notifyHops(hops + 1)
            else 
                let lastNodeKey: U64 = _fingerTableKeys(_fingerTableKeys.size() - 1)?
                var largestNode: Node = _finger_table(lastNodeKey)?


                for i in Range[USize](1, _fingerTableKeys.size()) do 
                    let currNodeKey = _fingerTableKeys(i-1)?
                    let nextNodeKey = _fingerTableKeys(i)?

                    if currNodeKey > nextNodeKey then
                        if (key < nextNodeKey) or (key >= currNodeKey) then 
                            largestNode = _finger_table(currNodeKey)?
                            break
                        end    
                    end
                    
                    if (currNodeKey <= key) and (key < nextNodeKey) then 
                        largestNode = _finger_table(currNodeKey)?
                        break
                    end
                end
                largestNode.lookup(key, hops + 1)
            end
        end