-- If already defined, return
if _constants and _constants.configurable_nukes then
  return _constants
end

local Log = require("libs.log.log")

local constants = {}

local depth = function ()
    local self = { depth = 0 }
    local get = function () return self.depth end
    local increment = function () self.depth = self.depth + 1 end
    local decrement = function () self.depth = self.depth - 1 end
    local reset = function () self.depth = 0 end

    return {
        get = get,
        increment = increment,
        decrement = decrement,
        reset = reset,
    }
end

constants.table = {
    calls = 0,
    file = {
        prefix = "configurable-nukes/",
        postfix = ".json",
    },
    depth = depth(),
    SPACING = "    ",
    traverse_find  = function (t_name, data, found_data, path, optionals)
        Log.debug("constants.table.traverse_find")
        Log.info(t_name)
        Log.info(data)
        Log.info(found_data)
        Log.info(path)
        Log.info(optionals)

        if (t_name == nil or type(t_name) ~= "string" or #(string.gsub(t_name, " ", "")) <= 0) then return end
        if (data == nil or type(data) ~= "table") then data = storage end
        if (found_data == nil or type(found_data) ~= "table") then found_data = {} end
        if (path == nil or type(path) ~= "string") then path = "storage" end

        constants.table.calls = 0
        local depth = depth()

        -- log(type(optionals.max_depth))
        -- log(tostring(optionals.max_depth))

        local do_traverse; do_traverse = function (t_name, data, found_data, path, optionals)
            if (constants.table.calls > 2 ^ 16) then return end

            -- if (type(optionals.max_depth) == "number" and depth.get() > optionals.max_depth) then return else log("depth = " .. depth.get()) end

            constants.table.calls = constants.table.calls + 1
            -- log("calls = " .. constants.table.calls)
            depth.increment()


            local t_return = { data = nil, name = path, return_val = 0, depth = 2 ^ 8 - 1 }

            local should_return; should_return = function (_t_return, optionals)
                -- if (type(optionals.max_depth) == "number" and depth.get() > optionals.max_depth) then return else log("depth = " .. depth.get()) end

                if (type(_t_return) == "table") then
                    if (_t_return.do_return) then
                        -- log("1")
                        depth.reset()
                        return _t_return
                    elseif (_t_return.return_val and t_return.return_val and _t_return.return_val > t_return.return_val) then
                        -- log("2")
                        -- log(serpent.block(_t_return))
                        t_return = _t_return
                        -- log(serpent.block(_t_return))
                        return false
                    elseif (not t_return.return_val) then
                        t_return = _t_return
                        return false
                    end
                end
                return false
            end

            -- if (not found_data[data]) then
            if (not found_data[data] or found_data[data] and found_data[data].depth > depth.get()) then
                if (not found_data[data]) then found_data[data] = {} end
                found_data[data].depth = depth.get()

                for k, v in pairs(data) do
                    if (type(v) == "table") then
                        if (optionals.parsed_name) then
                            -- if (path .. "." .. tostring(k) == t_name or (path .. "." .. tostring(k)):find(t_name, 1, true)) then
                            if (path .. "." .. tostring(k)):find(t_name, 1, true) then
                                depth.reset()
                                -- log("1.1")
                                return { data = v, name = path .. "." .. tostring(k), do_return = true }
                            end
                            -- if (   optionals.parsed_name.reversed.t[tostring(k)]
                            -- log(serpent.block(k))
                            if (  (optionals.parsed_name.step.t[tostring(k)] and depth.get() == optionals.parsed_name.step.a[optionals.parsed_name.step.t[tostring(k)]])
                                or optionals.parsed_name.t[path .. "." .. tostring(k)]
                                or optionals.parsed_name.reversed.t[path .. "." .. tostring(k)]) then

                                -- log(tostring(k))
                                -- log("2.1")

                                -- local _t_return = constants.table.traverse_find(t_name, v, found_data, path .. "." .. tostring(k), optionals)
                                local _t_return = do_traverse(t_name, v, found_data, path .. "." .. tostring(k), optionals)
                                if (should_return(_t_return, optionals)) then return should_return(_t_return, optionals) end

                                -- log(serpent.block(k))
                                -- log(serpent.block(optionals.parsed_name.reversed.t))
                                -- log(serpent.block(optionals.parsed_name.reversed.t[k]))
                                return { data = v, name = path .. "." .. tostring(k), return_val = optionals.parsed_name.reversed.t[k], depth = depth.get() }
                            end
                        end
                        if (tostring(k) == t_name or path .. "." .. tostring(k) == t_name) then depth.reset(); return { data = v, name = path .. "." .. tostring(k) , do_return = true, depth = depth.get() } end
                        -- local _t_return = constants.table.traverse_find(t_name, v, found_data, path .. "." .. tostring(k), optionals)
                        local _t_return = do_traverse(t_name, v, found_data, path .. "." .. tostring(k), optionals)
                        if (should_return(_t_return, optionals)) then return should_return(_t_return, optionals) end
                    end
                end
            end

            depth.decrement()
            return t_return
        end
        return do_traverse(t_name, data, found_data, path, optionals)
    end,
    traverse_print  = function (data, file_name, found_data, optionals)
        Log.debug("constants.table.traverse_print")
        Log.info(data)
        Log.info(file_name)
        Log.info(found_data)
        Log.info(optionals)

        if (data == nil or type(data) ~= "table") then return -1 end
        if (file_name == nil or type(file_name) ~= "string") then return -1 end
        if (found_data == nil or type(found_data) ~= "table") then found_data = {} end

        optionals = type(optionals) == "table" and optionals or { max_depth = 4 }

        constants.table.calls = 0
        local depth = depth()
        -- depth.reset()
        if (not file_name:find(constants.table.file.prefix, 1)) then file_name = constants.table.file.prefix .. file_name end
        if (not file_name:find(constants.table.file.postfix, -5)) then file_name = file_name .. constants.table.file.postfix end

        -- log(type(optionals.max_depth))
        -- log(tostring(optionals.max_depth))

        local do_traverse; do_traverse = function(data, file_name, found_data, optionals)

            if (type(optionals.max_depth) == "number" and depth.get() > optionals.max_depth) then return --[[else log("depth = " .. depth.get())]] end

            if (depth.get() == 0) then
                -- constants.table.calls = 0
                helpers.write_file(file_name, "{")
            end
            if (constants.table.calls > 2 ^ 16) then return end
            constants.table.calls = constants.table.calls + 1
            -- log("calls = " .. constants.table.calls)
            depth.increment()
            if (data == nil or type(data) ~= "table") then return nil end
            if (found_data == nil or type(found_data) ~= "table") then found_data = {} end

            local t = nil

            if (not found_data[data] or found_data[data] and found_data[data].depth > depth.get()) then
                if (not found_data[data]) then found_data[data] = {} end
                found_data[data].depth = depth.get()
                t = {}

                for k, v in pairs(data) do
                    if (type(v) ~= "table") then
                        if (next(data, k)) then
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "\"" .. tostring(k) .. "\": " .. serpent.block(v) .. ",", true)
                        else
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "\"" .. tostring(k) .. "\": " .. serpent.block(v), true)
                        end
                    else
                        local func; func = function (data, file_name, found_data, optionals)
                            if (type(optionals.max_depth) == "number" and depth.get() > optionals.max_depth) then return --[[else log("depth = " .. depth.get())]] end

                            if (constants.table.calls > 2 ^ 16) then return end
                            constants.table.calls = constants.table.calls + 1

                            -- local traversed_t = constants.table.traverse_print(data, file_name, found_data)
                            local traversed_t = do_traverse(data, file_name, found_data, optionals)

                            for i, j in pairs(traversed_t) do
                                if (type(j) ~= "table") then
                                    if (next(traversed_t, i)) then
                                        helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get() - 1) .. "\"" .. tostring(i) .. "\": " .. serpent.block(j) .. ",", true)
                                    else
                                        helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get() - 1) .. "\"" .. tostring(i) .. "\": " .. serpent.block(j), true)
                                    end
                                else
                                    helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "\"" .. tostring(i) .. "\" : {", true)
                                    depth.increment()
                                    func(j, file_name, found_data, optionals)
                                    depth.decrement()
                                    if (next(traversed_t, i)) then
                                        helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "},", true)
                                    else
                                        helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "}", true)
                                    end
                                end
                            end
                        end

                        helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "\"" .. tostring(k) .. "\": {", true)

                        func(v, file_name, found_data, optionals)

                        if (next(data, k)) then
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "},", true)
                        else
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "}", true)
                        end
                    end
                end
            else
                -- log("found existing table at depth " .. depth.get())

                t = {}

                depth.increment()
                for k, v in pairs(data) do
                    if (type(v) ~= "table") then
                        if (next(data, k)) then
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get() - 1) .. "\"" .. tostring(k) .. "\" : " .. serpent.block(v) .. ",", true)
                        else
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get() - 1) .. "\"" .. tostring(k) .. "\" : " .. serpent.block(v), true)
                        end
                    else
                        if (next(data, k)) then
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get() - 1) .. "\"" .. tostring(k) .. "\" : \"more-enemies_placeholder\",", true)
                        else
                            helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get() - 1) .. "\"" .. tostring(k) .. "\" : \"more-enemies_placeholder\"", true)
                        end
                    end
                end
                depth.decrement()
            end

            depth.decrement()
            if (depth.get() == 0) then helpers.write_file(file_name, "\n" .. string.rep(constants.table.SPACING, depth.get()) .. "}", true) end

            return t
        end
        return do_traverse(data, file_name, found_data, optionals)
    end,
}

constants.configurable_nukes = true

local _constants = constants

return constants