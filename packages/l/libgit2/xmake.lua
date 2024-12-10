package("libgit2")
    set_homepage("https://libgit2.org/")
    set_description("A cross-platform, linkable library implementation of Git that you can use in your application.")
    set_license("GPL-2.0-only")

    set_urls("https://github.com/libgit2/libgit2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libgit2/libgit2.git")

    add_configs("ssh", {description = "Enable SSH support", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    add_configs("https", {description = "Select crypto backend.", default = (is_plat("windows", "mingw") and "winhttp" or "openssl"), type = "string", values = {"winhttp", "openssl", "mbedtls"}})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    elseif is_plat("windows", "mingw") then
        add_syslinks("ole32", "rpcrt4", "winhttp", "ws2_32", "user32", "crypt32", "advapi32")
    elseif is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation", "Security")
        add_syslinks("iconv", "z")
    end

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    end

    add_deps("pcre2", "llhttp")
    if not is_plat("macosx", "iphoneos") then
        add_deps("zlib")
    end

    on_install("!wasm", function (package)
        if package:is_plat("android") then
            for _, file in ipairs(os.files("src/**.txt")) do
                if path.basename(file) == "CMakeLists" then
                    io.replace(file, "C_STANDARD 90", "C_STANDARD 99", {plain = true})
                end
            end
        elseif package:is_plat("windows") then
            local configs = {}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            import("package.tools.cmake").install(package, configs)
        end

        
