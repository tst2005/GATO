# an in-memory Lua file system

ch1. minimal directory structure

ch2. think about file, hardlink and node

ch3. dir and getnode

ch4. mkdir : add a directory into another

ch5. special rootdir

ch6. paths

ch7. chroot and mount point


# ch1. minimal directory structure

* one directory
* ```
d = {}
d["."] = d
```

# 2 directories

* a parent directory
* ```
parent = {}
parent["."] = parent
```

* a child directory
* ```
child = {}
child["."] = child
```

* link them together
* ```
parent["CHILD"]=child
child[".."]=parent
```

# object VS index

* ```
d = {}
d.tree = {}
d.tree["."] = d
```

* ```
before : d["CHILD"]
after  : d.tree["CHILD"]
```

* foo/bar/baz
* ```
before : d1["foo"]["bar"]["baz"]
after  : d1.tree["foo"].tree["bar"].tree["baz"]
```

# ch2. think about file, hardlink and node

* file != directory, but ...
* common part : (mainly) hardlink
 * generic name for common part ? a node
* node
 * node -> dir
 * node -> file

# node and hardlink

```
local node = class("node")
function node:init()
        self.hardcount = 1
end
-- create a hardlink of (dir|file)<what> named <name> into (dir)<self>
function node:hardlink(name, what) [...] end
function node:unhardlink(name) [...] end

```

# ch3. dir and getnode

* ```
local dir = class("dir", nil, node_class)
function dir:init(parentdir)
        self.tree = {}
        self:hardlink(".", self)
        if parentdir then
                self:hardlink("..", parentdir)
        end
end
```

* ```
function node:getnode(t)
        return cur.tree[name]
end
function node:__div(t) [...] end
```

# sample
* ```
child = parent.tree["CHILD"]
```
* ```
child = parent:getnode("CHILD")
```
* ```
child = parent / "CHILD"
```
* foo/bar/baz
* ```
baz = foo.tree["bar"].tree["baz"]
```
* ```
baz = foo:getnode("bar"):getnode("baz")
```
* ```
baz = foo / "bar" / "baz"
```

# ch4. mkdir : add a directory into another

```
local dir = require "memfs.dir"
 
local d = dir(nil)
local dd = dir(d)
d.tree["CHILD"]=dd
 
dd.tree[".."] == d
d.tree["CHILD"] == dd
```

# mkdir, rmdir

* mkdir
* ```
function dir:mkdir(name)
        if self.tree[name] then
                error("already exists", 2)
        end
        local d = instance(dir,self)       -- new directory d
        self.tree[name] = d                -- add d
        return d
end
```

* rmdir
* ```
function dir:rmdir(name)
        if not self.tree[name] then
                error("not exists", 2)
        end
        self.tree[name]:unhardlink("..")
--      self.tree[name]:unhardlink(".") -- hmm no
        self.tree[name] = nil
        return nil
end
```

#




* 
* 
*       To be continue ...
