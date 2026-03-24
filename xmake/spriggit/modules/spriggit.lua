---@class SpriggitMeta
---@field PackageName string
---@field Version string
---@field GameRelease string
---@field ModKey string

---@param f string
---@return SpriggitMeta?
local function _load_meta_yaml(f)
    local meta = {}
    -- Lazy "parsing"
    for line in io.lines(f) do
        local k, v = line:match("^ ? ?(%w+):%s*(.+)$")
        if k == "PackageName" and not meta.PackageName then
            meta.PackageName = v
        elseif k == "Version" and not meta.Version then
            meta.Version = v
        elseif k == "GameRelease" and not meta.GameRelease then
            meta.GameRelease = v
        elseif k == "ModKey" and not meta.ModKey then
            meta.ModKey = v
        end
        if meta.PackageName and meta.Version and meta.GameRelease and meta.ModKey then
            return meta
        end
    end

    return nil
end

---@param f string
---@return SpriggitMeta?
local function _load_meta_json(f)
    import("core.base.json")
    local meta = assert(json.loadfile(f), "Failed to load spriggit meta file: " .. f)
    local res = {}

    if meta.SpriggitSource then
        res.PackageName = meta.SpriggitSource.PackageName
        res.Version = meta.SpriggitSource.Version
    else
        res.PackageName = meta.PackageName
        res.Version = meta.Version
    end
    res.GameRelease = meta.GameRelease
    res.ModKey = meta.ModKey

    if res.PackageName and res.Version and res.GameRelease and res.ModKey then
        return res
    end
    return nil
end

---@param f string
---@return SpriggitMeta?
local function _load_meta_file(f)
    if path.extension(f) == ".json" then
        return _load_meta_json(f)
    elseif path.extension(f) == ".yaml" then
        return _load_meta_yaml(f)
    end
    return nil
end

---Load spriggit meta 
---@param p string Path to spriggit meta file or source directory
---@return SpriggitMeta?
function load_meta(p)
    if os.isfile(p) then
        return _load_meta_file(p)
    elseif os.isdir(p) then
        local files = {"spriggit-meta.json", "RecordData.yaml", "RecordData.json"}
        for _, f in ipairs(files) do
            f = path.join(p, f)
            if os.isfile(f) then
                local meta = _load_meta_file(f)
                if meta then
                    return meta
                end
            end
        end
    end
    return nil
end
