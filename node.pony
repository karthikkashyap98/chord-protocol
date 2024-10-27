use "collections"

actor Node
    let _id: U64
    let _main: Main
    let _env: Env
    var _finger_table: Map[U64, Node] val
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

        _env.out.print("My Id: " + _id.string() + " My Pre: " + predecessor.string())


    be setFingerTable(nodes: Map[U64, Node tag] val) =>
        _finger_table = nodes
        for nodeId in nodes.keys() do
            _env.out.print("My Id: " + _id.string() + " Hash Table Entry: " + nodeId.string())
        end


    // be lookup(key: U64, hops: U64 = 0) =>
        // TODO:
        // if key belongs to me, dont forward
        // update main actor with hops

        // Search for appropriate node in the finger table 
        // Use linear or binary search 

        // Forward the lookup to that node, increment hops counter
        // before sending it
        // node.lookup(key, hops + 1)