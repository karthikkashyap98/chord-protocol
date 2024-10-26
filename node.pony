use "collections"

actor Node
    let _id: U64
    let _main: Main
    let _env: Env
    var _finger_table: Map[U64, Node] val

    new create(id: U64, main: Main, env: Env) =>
        _id = id
        _main = main
        _env = env
        _finger_table = Map[U64, Node]

    fun getId(): U64 =>
        _id

    be printId() =>
        _env.out.print("Someone triggered a print: " + _id.string())

    be setFingerTable(nodes: Map[U64, Node tag] val) =>
        _finger_table = nodes
        _env.out.print("Nodes set for " + _id.string())
        // for nodeId in nodes.keys() do
        //     _env.out.print(nodeId.string())
        // end

