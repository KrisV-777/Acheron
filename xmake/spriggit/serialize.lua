import("core.project.config")
import("core.project.project")
import("core.base.option")
import("core.base.json")
import("lib.detect.find_tool")
import("utils.progress")

local function _write_guard_stamp(plugin_path)
    local stampfile = plugin_path .. ".spriggit.stamp"
    io.writefile(stampfile, os.date("!%Y-%m-%dT%H:%M:%SZ"))
end

local function _do_serialize(opt)
    local spriggit = assert(find_tool("spriggit"), "Spriggit.CLI not defined")

    local args = {
        "serialize",
        "-i", opt.inputpath,
        "-o", opt.outputpath,
        -- "-u"
    }

    if opt.gamerel then
        table.insert(args, "-g")
        table.insert(args, opt.gamerel)
    end
    if opt.pkgname then
        table.insert(args, "-p")
        table.insert(args, opt.pkgname)
    end
    if opt.pkgver then
        table.insert(args, "-v")
        table.insert(args, opt.pkgver)
    end

    cprint("${color.build.object}Serializing %s...", opt.inputpath)
    os.vrunv(spriggit.program, args)
    _write_guard_stamp(opt.inputpath)
end

local function _do_target(target, opt)
    import("spriggit")
    local targetdir = opt.install and target:installdir() or target:targetdir()

    local srcdir = target:values("spriggit.srcdir")
    for _, dir in ipairs(table.wrap(srcdir)) do
        local opt = table.clone(opt)
        local meta = assert(spriggit.load_meta(dir), "Failed to load spriggit meta from: " .. dir)

        opt.outputpath = dir
        opt.inputpath = path.join(targetdir, meta.ModKey)
        opt.gamerel = opt.gamerel or meta.GameRelease
        opt.pkgname = opt.pkgname or meta.PackageName
        opt.pkgver = opt.pkgver or meta.Version

        _do_serialize(opt)
    end
end

-- {'t', "target",     "kv", nil, "Serialize plugin(s) from TARGET."},
-- {nil, "install",    "k",  nil, "Read plugin from TARGET:installdir instead of TARGET:targetdir."},
-- {'i', "inputpath",  "kv", nil, "Path to the Bethesda plugin if not from target."},
-- {'o', "outputpath", "kv", nil, "Path to export plugin to if not from target."},
-- {'g', "gamerel",    "kv", nil, ""},
-- {'p', "pkgname",    "kv", nil, ""},
-- {'v', "pkgver",     "kv", nil, ""},

function main()
    local opt = {}
    config.load()
    opt.spriggit = assert(find_tool("spriggit"), "Spriggit.CLI not defined")

    opt.target = opt.target or option.get("target")
    opt.install = opt.install or option.get("install")
    opt.inputpath = opt.inputpath or option.get("inputpath")
    opt.outputpath = opt.outputpath or option.get("outputpath")
    opt.gamerel = opt.gamerel or option.get("gamerel")
    opt.pkgname = opt.pkgname or option.get("pkgname")
    opt.pkgver = opt.pkgver or option.get("pkgver")

    assert(opt.target or (opt.inputpath and opt.outputpath),
        "Must specify one of target or inputpath and outputpath")
    assert(not (opt.target and opt.outputpath),
        "Cannot specify both target and outputpath")
    if opt.target then
        local target = assert(project.target(opt.target), "Target not found: " .. opt.target)
        assert(not opt.install or target:installdir(), "No installdir for target")

        _do_target(target, opt)
    else
        _do_serialize(opt)
    end

end
