import("lib.detect.find_program")
import("lib.detect.find_programver")
import("core.cache.detectcache")
import("core.project.config")
import("core.base.semver")

function _vioexecv(program, argv)
    -- make temporary output and error file
    local outfile = os.tmpfile()
    local errfile = os.tmpfile()
    local opt = {}
    opt.try = true
    opt.outfile = outfile
    opt.errfile = errfile

    -- run command
    local ok, errors = os.vexecv(program, argv, table.join(opt, {stdout = outfile, stderr = errfile}))
    if ok == nil then
        local cmd = program
        if argv then
            cmd = cmd .. " " .. os.args(argv)
        end
        errors = string.format("cannot runv(%s), %s", cmd, errors and errors or "unknown reason")
    end

    -- get output and error data
    local outdata = io.readfile(outfile)
    local errdata = io.readfile(errfile)

    -- remove the temporary output and error file
    os.rm(outfile)
    os.rm(errfile)
    return ok, outdata, errdata, errors
end

function _check(program)
    local ok, stdout, stderr, errors = _vioexecv(program, {"--version"})
    assert(ok ~= nil, errors)
    assert(stderr:startswith("Spriggit.CLI"), "Unexpected output: " .. stderr:match("^[^\r\n]*"))
    return true
end

function main(opt)
    opt = opt or {}

    opt.paths = table.wrap(opt.paths)
    opt.check = _check

    table.insert(opt.paths, os.getenv("SPRIGGIT_PATH") or nil)
    table.insert(opt.paths, config.get("spriggit_path") or nil)

    local program = find_program("Spriggit.CLI", opt)

    local version = nil
    if program and opt.version then
        opt.command = function()
            local ok, _, errs, errors = _vioexecv(program, {"--version"})
            assert(ok ~= nil, errors)
            return errs
        end
        version = find_programver(program, opt)
    end

    return program, version
end