local table_insert = table.insert
local pairs = pairs
local type = type
local assert = assert

local lua_dispatcher = {}
lua_dispatcher.tables = {}
lua_dispatcher.errorTables = {}

function lua_dispatcher:binding(api, fun)
    assert(fun ~= nil, api..":lua_dispatcher:binding fun is null")
    if self.tables[api] == nil then
        self.tables[api] = {}
    end
    local msgTable = self.tables[api]

    for k, v in pairs(msgTable) do
        if v == fun then
            Logger.LogErrorFormat("重复绑定： %s %s", api, fun)
            return
        end --同一个函数只能绑定一次。
    end

    table_insert(msgTable, fun)
end

--只绑定一个全局响应函数
function lua_dispatcher:bindingOne(api, fun)
    if self.tables[api] == nil then
        self.tables[api] = {}
    end
    local msgTable = self.tables[api]
    for k, v in pairs(msgTable) do
        msgTable[k] = nil
    end
    table_insert(msgTable, fun)
end

function lua_dispatcher:unbinding(api, fun)
    local msgTable = self.tables[api]
    if msgTable then
        -- local len=#msgTable local funitem local reindex
        -- for i=1,len do	funitem=msgTable[i]	if funitem==fun then reindex=i end		end
        -- if reindex then table.remove(msgTable,reindex) end --msgTable[msgTable]=nil
        -- 这里没有remove，因为在事件分发时的callback回调中，调用unbinding会有问题
        for k, v in pairs(msgTable) do
            if v == fun then
                msgTable[k] = nil
                break
            end
        end
    end
end

function lua_dispatcher:distribute(api, ...)
    self:callHandle(api, ...)
end

function lua_dispatcher:callHandle(api, ...)
    local funTable = self.tables[api]
    if funTable then
        for k, v in pairs(funTable) do
            if type(v) == "function" then
                v(...)
            end
        end
    end
end

function lua_dispatcher:bindingError(code, fun)
    self.errorTables[code .. ""] = fun
end

function lua_dispatcher:unbindingError(code, fun)
    self.errorTables[code .. ""] = nil
end

--发送消息到服务端
function lua_dispatcher:send(api, content)
    -- local msg=Msg()
    -- msg:set_Type(api.Code)
    -- NetProtocalPaser:formatMessage(msg,api.Code,content)
    -- Net:Send(msg)
end

function lua_binding(api, fun)
    lua_dispatcher:binding(api, fun)
end

function lua_unbinding(api, fun)
    lua_dispatcher:unbinding(api, fun)
end

function lua_distribute(api, ...)
    lua_dispatcher:callHandle(api, ...)
end

--关闭
function lua_dispatcher:close()
    -- Net:Close()
end

return lua_dispatcher
