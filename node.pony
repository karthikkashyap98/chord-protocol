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
        _env.out.print("My Id: " + _id.string() + " Finger Table Size " + _finger_table.size().string())

        for nodeId in fingerTableKeys.keys() do
            try 
                _env.out.print("My Id: " + _id.string() + " Hash Table Entry: " + fingerTableKeys(nodeId)?.string())
            end
        end


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

                // if lastNodeKey <= key then 
                //     largestNode.lookup(key, hops + 1)
                // else 
                for i in Range[USize](1, _fingerTableKeys.size()) do 
                    // _env.out.print("My ID: " + _id.string() + " Finger Table Key: " + _fingerTableKeys(i)?.string())
                    let currNodeKey = _fingerTableKeys(i-1)?
                    let nextNodeKey = _fingerTableKeys(i)?

                    if currNodeKey > nextNodeKey then
                        if (key < nextNodeKey) or (key >= currNodeKey) then 
                            largestNode = _finger_table(currNodeKey)?
                            break
                        end    
                    end
                    
                    // Cur = 8 , Key = 9, nextNode = 10
                    if (currNodeKey <= key) and (key < nextNodeKey) then 
                        largestNode = _finger_table(currNodeKey)?
                        break
                    end
                end
                // end
                largestNode.lookup(key, hops + 1)
            end
        end

        // // Get sorted keys from finger table
        // let keys = Array[U64]
        // for k in _finger_table.keys() do
        //     keys.push(k)
        // end

        // Sort[Array[U64], U64](keys)



        // // Find the closest preceding node
        // var pickedNode: U64 = 0
        // var next_node: (Node tag | None) = None
        // for k in keys.values() do
        //     if k > _id then
        //         // If we're looking for a key past our ID
        //         if key > _id then
        //             // Forward only if this finger is closer to key than we are
        //             if k <= key then
        //                 next_node = try _finger_table(k)? else None end
        //                 pickedNode = k
        //                 break
        //             end
        //         else
        //             // Key is less than our ID, take first finger greater than us
        //             next_node = try _finger_table(k)? else None end
        //             pickedNode = k
        //             break
        //         end
        //     elseif key <= k then
        //         // If we found a finger that's past the key
        //         next_node = try _finger_table(k)? else None end
        //         pickedNode = k
        //         break
        //     end
        // end

        // // If we haven't found a suitable next node, take the first one (wrapping around)
        // if next_node is None then
        //     _env.out.print("// If we haven't found a suitable next node, take the first one (wrapping around)")
        //     try
        //         next_node = _finger_table(keys(keys.size()-1)?)?
        //     end
        // end

        // _env.out.print("My Id: " + _id.string() + " Picked: " + pickedNode.string() + " Looking for: " + key.string())

        // // Forward the lookup
        // match next_node
        // | let n: Node tag =>
        //     n.lookup(key, hops + 1)
        // else
        //     _env.out.print("Error: No suitable node found in finger table")
        // end