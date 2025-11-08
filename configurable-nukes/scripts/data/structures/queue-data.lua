local Log_Stub = require("__TheEckelmonster-core-library__.libs.log.log-stub")
local _Log = Log
if (not script or not _Log or mods) then _Log = Log_Stub end

local Data = require("scripts.data.data")

local queue_data = {}

queue_data.type = "queue-data"

function queue_data:new(o, data)
    _Log.debug("queue_data:new")
    _Log.info(o)
    _Log.info(data)

    local index = data and (data.index or data.tick) or 1

    local defaults = {
        type = self.type,
        name = data and data.name or "queue_data",
        count = 0,
        data_array = {},
        data_table = Data:new({
            name = data and data.name or "queue_data_table_" .. index,
            type = data and data.type or "queue_data_table",
            t = {},
        }),
        first = nil,
        index = index,
        last = nil,
        limit = data and data.limit or 2 ^ 8,
    }

    local obj = o or defaults

    for k, v in pairs(defaults) do
        if (obj[k] == nil and type(v) ~= "function") then
            obj[k] = v
        end
    end

    obj = Data:new(obj)

    setmetatable(obj, self)
    self.__index = self

    return obj
end

function queue_data:next(data)
    _Log.debug("queue_data:next")

    if (data == nil or type(data) ~= "table") then return end
    if (not data.order or type(data.order) ~= "string") then data.order = "first" end
    if (data.maintain == nil or type(data.maintain) ~= "boolean") then data.maintain = true end

    local return_val = nil
    local first = function (data)
        if (type(self.first) == "table") then
            return_val = self.first
            if (not data.maintain) then
                return_val.next = nil
                return_val.prev = nil

                self.data_table.t[1] = nil

                local i = 2
                while i <= #self.data_array do
                    if (i < 1) then break end

                    if (self.data_table.t[i]) then
                        self.data_table.t[i].index = i - 1
                        self.data_table.t[i - 1] = self.data_table.t[i]
                        self.data_table.t[i] = nil
                    end

                    i = i + 1
                end

                if (self.count > 0) then self.count = self.count - 1 end
                table.remove(self.data_array, return_val.index or 1)

                local i = return_val.index or 1
                while i <= #self.data_array do
                    if (i < 1) then break end
                    self.data_array[i].index = self.data_array[i].index and self.data_array[i].index - 1 or i or 1
                    i = i + 1
                end

                self.first = self.data_array[1]
                if (self.first) then self.first.prev = nil end
                self.last = self.data_array[self.count]
                if (self.last) then self.last.next = nil end
            end
        end
    end

    local last = function (data)
        if (type(self.last) == "table") then
            return_val = self.last
            if (not data.maintain) then
                return_val.next = nil
                return_val.prev = nil

                table.remove(self.data_array)

                self.data_table.t[self.count] = nil

                if (self.count > 0) then self.count = self.count - 1 end

                self.first = self.data_array[1]
                if (self.first) then self.first.prev = nil end
                self.last = self.data_array[self.count]
                if (self.last) then self.last.next = nil end
            end
        end
    end

    if (type(data.order) == "string") then
        if (data.order == "last") then
            last(data)
        else
            first(data)
        end
    else
        first(data)
    end

    return return_val
end

function queue_data:remove(data)
    _Log.debug("queue_data:remove")
    _Log.info(data)

    if (self == nil or type(self) ~= "table") then return -1 end
    if (data == nil or type(data) ~= "table") then return -1 end
    if (data.data == nil or type(data.data) ~= "table") then return -1 end
    if (not data.mode or data.mode and type(data.mode) ~= "string") then data.mode = "single" end

    local _data = data.data

    local data_to_remove = nil
    if (((      self.data_table.t[_data.created] ~= nil or self.data_table.t[_data.index] ~= nil)
            and (
                    self.data_table.t[_data.created] and self.data_array[self.data_table.t[_data.created].index] ~= nil
                or
                    self.data_table.t[_data.index] and self.data_array[self.data_table.t[_data.index].index] ~= nil
            )
        ))
    then

        data_to_remove = self.data_table.t[_data.index] and  self.data_array[self.data_table.t[_data.index].index]

        local index =   self.data_table.t[_data.index] and self.data_table.t[_data.index].index

        if (self.count <= 1) then
            --[[
                There was only one element
                -> Nothing will remain after removing it
                -> Hence setting first & last to nil
            ]]
            self.first = nil
            self.last = nil
        end

        local prev = data_to_remove.prev
        local _next = data_to_remove.next

        if (prev ~= nil and type(prev) == "table") then prev.next = _next end
        if (_next ~= nil and type(_next) == "table") then _next.prev = prev end
        if (data_to_remove == self.first and type(self.first) == "table") then
            self.first = self.first.next
        elseif (data_to_remove == self.last and type(self.last) == "table") then
            self.last = self.last.prev
        end

        if (self.data_array[index] and self.data_table.t[index]) then
            self.data_table.t[index] = nil
            table.remove(self.data_array, index)

            if (self.count >= 1) then self.count = self.count - 1 end
        end

        local i = index

        while i <= #self.data_array do
            if (i < 1) then break end
            self.data_array[i].index = i

            i = i + 1
        end

        i = index

        local new_t = {}

        i = 1
        for _, v in pairs(self.data_table.t) do
            new_t[i] = v
            new_t[i].index = i
            new_t[i].data.index = i
            i = i + 1
        end
        self.first = self.data_array[1]
        self.last = self.data_array[self.count]

        self.data_table.t = new_t
    end

    return data_to_remove
end

function queue_data:enqueue(data)
    _Log.debug("queue_data:enqueue")
    _Log.info(data)

    if (self.limit and self.count >= 1 + self.limit * 1.5 --[[TODO: Make this configurable]]) then return { valid = false } end

    if (type(data) ~= "table") then return -1 end
    if (data.data == nil or type(data.data) == "function") then return -1 end

    local _data = data.data

    if (self.first == nil or self.last == nil or self.count == 0) then
        self.first = _data
        self.last = _data
        self.data_array = {}
        self.data_table = Data:new({ type = "queue_data_table", name = "queue_data_table_" .. game.tick, t = {},})
        self.count = 1
    else
        -- Enqueue the data

        if (self.first ~= self.last) then
            local last_prev = self.last
            last_prev.next = _data
            _data.prev = last_prev
            self.last = _data
            _data.next = nil

            if (self.last.next) then
                self.last.next = nil
            end
            if (self.first.prev) then
                self.first.prev = nil
            end
        else
            self.last.next = _data
            _data.prev = self.last
            self.last = _data

            if (self.last.next) then
                self.last.next = nil
            end
            if (self.first.prev) then
                self.first.prev = nil
            end
        end
        self.count = self.count + 1
    end

    local index = nil

    _data.index = self.count
    index = _data.index
    table.insert(self.data_array, _data)

    if (self.data_table.t[index]) then
        local k, v = next(self.data_table.t, index - 1)

        while k or (not k and v) do
            if (type(k) == "number") then
                if (k and k < 1) then break end
                if (self.data_array[k] ~= nil and type(self.data_array[k]) == "table" and self.data_array[k].index) then
                    self.data_array[k].index = self.data_array[k].index - 1
                end
            end

            if (k) then k, v = next(self.data_table.t, k) end
        end

        if (self.count > 1) then
            table.remove(self.data_array, self.data_array[index] and self.data_array[index].index or index)
        end
    end

    self.data_table.t[index] = { index = index, data = _data, }

    return _data, 1
end

function queue_data:dequeue(data)
    _Log.debug("queue_data:dequeue")
    _Log.info(data)

    return self:next(data)
end

setmetatable(queue_data, Data)
queue_data.__index = queue_data
return queue_data