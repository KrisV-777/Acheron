set_xmakever("2.9.5")

-- Globals
PROJECT_NAME = "Acheron"
PROJECT_VERSION = "1.8.0"

-- Project
set_project(PROJECT_NAME)
set_version(PROJECT_VERSION)
set_languages("cxx23")
set_license("apache-2.0")
set_warnings("allextra", "error")

-- Includes
includes("xmake/dotenv")
includes("xmake/papyrus")
includes("xmake/spriggit")
add_moduledirs("xmake/modules")

-- Options
option("version")
    set_default("2")
    set_description("Game Version to build for: 0: VR, 1: V1.5.97, 2: V1.6.1170")
option_end()

option("papyrus_include")
    set_category("papyrus")
    set_description("Path to papyrus include directories",
                    'Defaults to: "%XSE_TES5_MODS_PATH%"')
    on_check(function(option)
        import("dotenv.check")(option, {"$(env XSE_TES5_MODS_PATH)"})
    end)
option_end()

option("papyrus_gamesource")
    set_category("papyrus")
    set_description('Path to directory containing game\'s "Source\\Scripts"',
                    'Defaults to: "%XSE_TES5_GAME_PATH%\\Data"')
    on_check(function(option)
        import("dotenv.check")(option, {"$(env XSE_TES5_GAME_PATH)", "Data"})
    end)
option_end()

option("auto_install")
    set_category("install")
    set_description("Automatically trigger an install after successful build",
                    "Only if 'install_path' is set")
    set_default(false)
    after_check("dotenv.check")
option_end()

option("install_path")
    set_category("install")
    set_description("Set default installation path for commands and auto_install",
                    'Defaults to: "%XSE_TES5_MODS_PATH%\\Acheron"')
    on_check(function(option)
        import("dotenv.check")(option, {"$(env XSE_TES5_MODS_PATH)", "Acheron"})
    end)
option_end()

option("build_assets")
    set_category("build")
    set_description("Enable 'assets' target")
    set_default(true)
option("build_dll")
    set_category("build")
    set_description("Enable '" .. PROJECT_NAME .. "' target")
    set_default(true)
option("build_papyrus")
    set_category("build")
    set_description("Enable 'papyrus' target")
    set_default(true)
option("build_spriggit")
    set_category("build")
    set_description("Enable 'Acheron.esm' target")
    set_default(true)

-- ensure dotenv is loaded before imported options
option("papyrus_path")
    add_deps("dotenv")
option("spriggit_path")
    add_deps("dotenv")

-- hide commonlibsse-ng options
option("rex_ini")
    set_showmenu(false)
option("rex_json")
    set_showmenu(false)
option("rex_toml")
    set_showmenu(false)
option("skse_xbyak")
    set_showmenu(false)
option("tests")
    set_showmenu(false)
option_end()

-- Dependencies & Includes
-- https://github.com/xmake-io/xmake-repo/tree/dev
add_requires("yaml-cpp", "magic_enum", "nlohmann_json", "simpleini")

local v = get_config("version")
if v == "0" then
    -- includes("lib/CommonLibVR/xmake.lua")
    add_defines("SKYRIM_SUPPORT_VR")
elseif v == "1" then
    includes("lib/CommonLibSSE/xmake.lua")
    set_config("skyrim_ae", false)
else
    includes("lib/CommonLibSSE/xmake.lua")
    set_config("skyrim_ae", true)
end

-- policies
set_policy("package.requires_lock", true)
set_policy("check.auto_ignore_flags", false)

-- rules
add_rules("mode.debug", "mode.release")

if is_mode("debug") then
    add_defines("DEBUG")
    set_optimize("none")
elseif is_mode("release") then
    add_defines("NDEBUG")
    set_optimize("fastest")
    set_symbols("debug")
end

set_config("skse_xbyak", true)

rule("common")
    after_config(function(target)
        -- after_config to ensure install_path overwrites value set by
        -- commonlibsse-ng.plugin
        import("core.project.config")
        local install_path = config.get("install_path")
        if install_path then
            target:set("installdir", install_path, {readonly = true})
        end
    end)

    after_build(function(target)
        import("core.project.config")
        import("core.base.task")
        local auto_install = config.get("auto_install")
        local install_path = config.get("install_path")
        if auto_install and install_path and target:name() ~= "commonlibsse-ng" then
            task.run("install", {target = target:name()})
        end
    end)

    on_install(function(target)
        local srcfiles, dstfiles = target:installfiles()
        if srcfiles and dstfiles then
            for idx, srcfile in ipairs(srcfiles) do
                os.vcp(srcfile, dstfiles[idx], {copy_if_different = true})
            end
        end
    end)
rule_end()
add_rules("common")

-- Target
target(PROJECT_NAME)
    -- Dependencies
    add_packages("yaml-cpp", "magic_enum", "nlohmann_json", "simpleini")

    -- CommonLibSSE
    add_deps("commonlibsse")
    add_rules("commonlibsse.plugin", {
        name = PROJECT_NAME,
        author = "KrisV777",
        description = "A death alternative framework for Skyrim SE."
        })

    -- Source files
    set_pcxxheader("src/PCH.h")
    add_files("src/**.cpp")
    add_headerfiles("src/**.h")
    add_includedirs("src")

    -- flags
    add_cxxflags(
        "cl::/cgthreads4",
        "cl::/diagnostics:caret",
        "cl::/external:W0",
        "cl::/fp:contract",
        "cl::/fp:except-",
        "cl::/guard:cf-",
        "cl::/Zc:enumTypes",
        "cl::/Zc:preprocessor",
        "cl::/Zc:templateScope",
        "cl::/utf-8"
        )
    -- flags (cl: warnings -> errors)
    add_cxxflags("cl::/we4715") -- `function` : not all control paths return a value
    -- flags (cl: disable warnings)
    add_cxxflags(
        "cl::/wd4068", -- unknown pragma 'clang'
        "cl::/wd4201", -- nonstandard extension used : nameless struct/union
        "cl::/wd4265" -- 'type': class has virtual functions, but its non-trivial destructor is not virtual; instances of this class may not be destructed correctly
        )

    -- Conditional flags
    if is_mode("debug") then
        add_cxxflags("cl::/bigobj")
    elseif is_mode("release") then
        add_cxxflags("cl::/Zc:inline", "cl::/JMC-", "cl::/Ob3")
    end

    on_load(function(target)
        local clib = target:rule("commonlibsse-ng.plugin")
        if clib then
            -- disable unwanted events
            clib:set("install", nil)
            clib:set("package", nil)
            clib:set("build_after", nil)
        end
        
        local v = get_config("version")
        if v == "0" then
            print("Building plugin for Skyrim VR")
        elseif v == "1" then
            print("Building plugin for Skyrim SE v1.5.97")
        else
            print("Building plugin for Skyrim SE v1.6.1170")
        end
    end)

    -- Post Build
    after_build(function (target)
        os.vcp(target:targetfile(), "dist/SKSE/Plugins")
        os.vcp(target:symbolfile(), "dist/SKSE/Plugins")
    end)
target_end()

target("papyrus")
    set_enabled(get_config("build_papyrus"))
    set_kind("object")
    set_targetdir("dist/Scripts")
    set_basename("Acheron")

    --avoid rebuild on mode change
    set_policy("build.intermediate_directory", false)
    add_rules("papyrus")

    add_files("dist/Source/Scripts/*.psc")
    add_includedirs("dist/Source/Scripts")
    add_includedirs("$(papyrus_include)/SkyUI SDK/Source/Scripts")
    add_includedirs("$(papyrus_gamesource)/Source/Scripts")

    on_load(function(target)
        import("core.project.config")

        if not config.get("papyrus_include") then
            cprint("${color.warning}papyrus_include is not defined")
        end
        if not config.get("papyrus_gamesource") then
            cprint("${color.warning}papyrus_gamesource is not defined")
        end
    end)

    before_build(function(target)
        import("core.project.config")
        assert(config.get("papyrus_include"), "papyrus_include is not defined")
        assert(config.get("papyrus_gamesource"), "papyrus_gamesource is not defined")
    end)
target_end()

target("Acheron.esm")
    set_enabled(get_config("build_spriggit"))
    set_kind("object")
    set_targetdir("dist")

    --avoid rebuild on mode change
    set_policy("build.intermediate_directory", false)

    add_rules("spriggit")
    set_values("spriggit.srcdir", "res")
target_end()

target("assets")
    set_enabled(get_config("build_assets"))
    set_kind("phony")

    add_installfiles("dist/(Interface/Acheron/**)")
    add_installfiles("dist/(Interface/Translations/*.txt)")
    add_installfiles("dist/(SKSE/CustomConsole/*.yml)")
    add_installfiles("dist/(SKSE/Acheron/**)")
target_end()

task("serialize")
    on_run(function()
        import("core.base.option")
        import("core.base.task")
        import("core.project.config")

        task.run("config")

        local inputpath = path.join("dist", "Acheron.esm")
        if option.get("install") then
            local installdir = option.get("installdir") or config.get("install_path")
            assert(installdir, "install_path is not defined and --installdir was not provided")
            inputpath = path.join(installdir, "Acheron.esm")
        end

        assert(os.isfile(inputpath), "Missing plugin file: " .. inputpath)

        task.run("spriggit.serialize", {
            inputpath = inputpath,
            outputpath = "res",
            gamerel = "SkyrimSE",
            pkgname = "Spriggit.Yaml.Skyrim",
            pkgver = "0.40",
        })
    end)

    set_menu {
        shortname = 's',
        usage = "xmake serialize [-i | <srcfile>]",
        description = "Serialize Acheron.esm",
        options = {
            {'i', "install",    "k",  nil, "Serialize from installdir." },
            {'o', "installdir", "kv", nil, "Override the install directory."},
        }
    }
task_end()

includes("@builtin/xpack")

xpack("papyrus-extender")
    set_formats("zip")
    set_extension(".7z")
    set_basename("Acheron - V$(version)")
    add_targets(PROJECT_NAME, "papyrus", "assets", "Acheron.esm")
    on_installcmd(function(package, batchcmds)
        local installdir = package:installdir()
        local install = import("test_ln")() and batchcmds.ln or batchcmds.cp
        for _, v in pairs(package:targets()) do
            srcfiles, dstfiles = v:installfiles(installdir)
            for idx, srcfile in ipairs(srcfiles) do
                install(batchcmds, path.absolute(srcfile), dstfiles[idx])
            end
        end
    end)

