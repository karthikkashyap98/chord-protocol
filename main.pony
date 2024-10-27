use "collections"
use "random"
use "time"

actor Main
    let _env: Env
    var numNodes: U64 = 0
    var numRequests: U64 = 0
    var networkSize: U64 = 0
    var fingerTableSize: U64 = 0
    let nodes: Map[U64, Node] = Map[U64, Node]
    let picked: Set[USize] = Set[USize]
    var convergenceCount: U64 = 0
    var totalHops: U64 = 0

    new create(env: Env) =>
        _env = env
        try
            parse_args()?
            setup()
        else
            usage()
        end
    
    fun ref parse_args() ? =>
        if _env.args.size() != 3 then
            error    
        end

        numNodes = _env.args(1)?.u64()?
        numRequests = _env.args(2)?.u64()?

    fun usage() =>
        _env.out.print(
            """
            Invalid command line arguments
            The program takes 3 command line arguments
            ./project3 numNodes numRequests
                numNodes  - number of actor nodes
                numRequests  - number of requests per node
            """
        )


    fun ref create_network() =>
        let interval: F64 = networkSize.f64() / numNodes.f64()
        
        var i: U64 = 0
        while i < numNodes do
            let position = (i.f64() * interval).round().u64()
            let new_node = Node(position, this, _env)

            nodes(position) = new_node

            if i != 0 then 
                var pre: U64 = ((i.f64() - 1) * interval).round().u64()
                try nodes(position)?.setPredecessor(pre) end
            end


            i = i + 1
        end
        var predOfFirstNode = ((i.f64() - 1) * interval).round().u64()

        try nodes(0)?.setPredecessor(predOfFirstNode) end


        _env.out.print("Finger table size: " + fingerTableSize.string())

        for nodeId in nodes.keys() do
            let fingerTable: Map[U64, Node] iso = Map[U64, Node]
            

            var j: U64 = 0
            while j < fingerTableSize do
                let jump = U64(1) << j  // 2^j
                let targetId = (nodeId + jump) % networkSize
                
                let successor_id = find_successor(targetId)

                try
                    fingerTable(successor_id) = nodes(successor_id)?
                end
                
                j = j + 1
            end

            try
                nodes(nodeId)?.setFingerTable(consume fingerTable)
            end
        end



    fun ref get_network_size(): U64 =>
        var size: U64 = 1
        var count: U64 = 0
        while size <= numNodes do
            size = size * 2
            count = count + 1
        end
        fingerTableSize = count
        size


    fun ref find_successor(id: U64): U64 =>
        var successor_id = id
        
        while not nodes.contains(successor_id) do
            successor_id = (successor_id + 1) % networkSize
        end
        
        successor_id

    fun generateMessages() =>

        let rand = Rand(Time.nanos())
        var i: U64 = 0
        while i < numRequests do
            let random_value = rand.int(numNodes-1)
            picked.add(random_value.usize())
            i = i + 1
        end


    be notifyHops(hops': U64) =>
        totalHops = totalHops + hops'
        convergenceCount = convergenceCount + 1
        if convergenceCount == (numNodes * numRequests) then
            // Calculate Average
            let average: F64 = totalHops.f64() / convergenceCount.f64()
            _env.out.print("Average hops is: " + average.string())
        end
        



    fun ref setup() =>
        networkSize = get_network_size()
        _env.out.print("*** Building the network of size: *** " + networkSize.string())

        create_network()

        generateMessages()


    be display(message: String) =>
        _env.out.print(message)