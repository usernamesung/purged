--> credits to https://github.com/centerepic

local HookManager = {}
HookManager.__index = HookManager

local hooks = {}

function HookManager.new()
    local self = setmetatable({}, HookManager)
    self.hooks = {}
    return self
end

function HookManager:hookfunction(tbl, key, callback)
    if not tbl or not key or not callback then
        warn("HookManager: Invalid table, key, or callback provided")
        return
    end
    local oldFunc = tbl[key]
    if type(oldFunc) ~= "function" then
        warn("HookManager: The value at the given key is not a function")
        return
    end
    local hookId = tostring(tbl) .. "_" .. tostring(key) .. "_" .. tick()
    local hookedFunc = function(...)
        return callback(oldFunc, ...)
    end
    tbl[key] = hookedFunc
    self.hooks[hookId] = {
        type = "function",
        tbl = tbl,
        key = key,
        original = oldFunc,
        hooked = hookedFunc,
        callback = callback
    }
    return hookId, oldFunc
end

function HookManager:hookmetamethod(metatable, metamethod, callback)
    if not metatable or not metamethod or not callback then
        warn("HookManager: Invalid metatable, metamethod, or callback provided")
        return
    end
    
    local oldMetamethod
    local hookId = tostring(metatable) .. "_" .. metamethod .. "_" .. tick()
    
    oldMetamethod = hookmetamethod(metatable, metamethod, function(self, ...)
        return callback(oldMetamethod, self, ...)
    end)
    
    self.hooks[hookId] = {
        type = "metamethod",
        metatable = metatable,
        metamethod = metamethod,
        original = oldMetamethod,
        callback = callback
    }
    
    return hookId
end

function HookManager:unhook(hookId)
    local hook = self.hooks[hookId]
    if not hook then
        warn("HookManager: Hook not found:", hookId)
        return false
    end
    
    if hook.type == "metamethod" then
        hook.metatable[hook.metamethod] = hook.original
    elseif hook.type == "function" then
        hook.tbl[hook.key] = hook.original
    end
    
    self.hooks[hookId] = nil
    return true
end

function HookManager:unhookAll()
    for hookId, hook in pairs(self.hooks) do
        if hook.type == "metamethod" then
            hook.metatable[hook.metamethod] = hook.original
        end
    end
    
    self.hooks = {}
end

function HookManager:getHook(hookId)
    return self.hooks[hookId]
end

function HookManager:getAllHooks()
    return self.hooks
end

function HookManager:getHookCount()
    local count = 0
    for _ in pairs(self.hooks) do
        count = count + 1
    end
    return count
end

return HookManager 
