add_moduledirs("modules")

option("spriggit_path")
    set_category("spriggit")
    set_description("Path to Spriggit.CLI")
    on_check(function(option)
        import("core.project.config")
        import("lib.detect.find_tool")
        if config.readonly(option:fullname()) then
            return
        end
        local spriggit = find_tool("spriggit")
        if spriggit then
            option:set_value(spriggit.program)
        end
    end)
    after_check(function(option)
        import("lib.detect.find_tool")
        if not option:value() then
            return
        end
        if not find_tool("spriggit") then
            cprint("${color.warning}Spriggit.CLI not found in spriggit_path")
        end
    end)
option_end()
task("spriggit.serialize")
    on_run("serialize")

    set_menu {
        usage = "xmake spriggit.serialize [options]",
        description = "Serialize project",
        options = {
            {'t', "target",     "kv", nil, "Serialize plugin(s) from TARGET."},
            {nil, "install",    "k",  nil, "Read plugin from TARGET:installdir instead of TARGET:targetdir."},
            {'i', "inputpath",  "kv", nil, "Path to the Bethesda plugin if not from target."},
            {'o', "outputpath", "kv", nil, "Path to export plugin to if not from target."},
            {nil, "gamerel",    "kv", nil, ""},
            {nil, "pkgname",    "kv", nil, ""},
            {nil, "pkgver",     "kv", nil, ""},
        }
    }
task_end()

rule("spriggit")
    add_imports("lib.detect.find_tool")
    add_imports("spriggit")
    on_config(function(target)
        local srcdir = target:values("spriggit.srcdir")
        for _, v in ipairs(table.wrap(srcdir)) do
            local meta = spriggit.load_meta(v)
            if meta then
                target:add("installfiles", path.join(target:targetdir(), meta.ModKey))
                target:add("files", srcdir, {rule = "spriggit", always_added = true})
            end
        end
    end)

    on_buildcmd_file(function (target, batchcmds, sourcefile, opt)
        local spriggit_cli = assert(find_tool("spriggit"), "Spriggit.CLI not found")

        if os.isfile(sourcefile) then
            sourcefile = path.directory(sourcefile)
        end
        local meta = assert(spriggit.load_meta(sourcefile), "Failed to load meta from %s", sourcefile)

        local objectfile = path.join(target:targetdir(), meta.ModKey)
        local stampfile = objectfile .. ".spriggit.stamp"

        -- Guard against accidentally overwriting direct edits to the binary plugin.
        if os.isfile(objectfile) then
            assert(os.isfile(stampfile),
                "Refusing to deserialize over %s: missing guard stamp %s. Run `xmake serialize` first.", objectfile, stampfile)
            assert(os.mtime(objectfile) <= os.mtime(stampfile),
                "Refusing to deserialize over %s: plugin is newer than guard stamp. Run `xmake serialize` first.", objectfile)
        end

        table.insert(target:objectfiles(), objectfile)

        batchcmds:show_progress(opt.progress, "${color.build.object}Deserializing %s...", sourcefile)
        batchcmds:vrunv(spriggit_cli.program, {
            "deserialize",
            "-i", path(sourcefile),
            "-o", path(objectfile),
        })

        if is_host("windows") then
            local stampcmd = string.format("[IO.File]::WriteAllText('%s', (Get-Date).ToString('o'))", stampfile:gsub("'", "''"))
            batchcmds:vrunv("powershell", {"-NoProfile", "-Command", stampcmd})
        else
            batchcmds:vrunv("sh", {"-c", "date -u +%Y-%m-%dT%H:%M:%SZ > " .. os.args(stampfile)})
        end

        batchcmds:add_depfiles(os.files(path.join(sourcefile, "**")))
        batchcmds:set_depmtime(os.mtime(objectfile))
        batchcmds:set_depcache(target:dependfile(objectfile))
        target:add("installfiles", objectfile)
    end)
rule_end()
