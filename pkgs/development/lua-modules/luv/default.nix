{
  lib,
  stdenv,
  fetchFromGitHub,
  buildLuarocksPackage,
  cmake,
  libuv,
  lua,
  luaOlder,
  nix-update-script,
  runCommand,
}:

buildLuarocksPackage rec {
  pname = "luv";
  version = "1.52.1-0";

  src = fetchFromGitHub {
    owner = "luvit";
    repo = "luv";
    rev = version;
    hash = "sha256-mU+Gvlpvp6iZE5IpXfTr+21QQ34vZk+tYhnr0b891qg=";
    # Need deps/lua-compat-5.3 only
    fetchSubmodules = true;
  };

  patches = [
    # Fails with "Uncaught Error: ./tests/test-dns.lua:164: assertion failed!"
    # and "./tests/test-tty.lua:19: bad argument #1 to 'is_readable' (Expected
    # uv_stream userdata)"
    ./disable-failing-tests.patch
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Fails with "Uncaught Error: ./tests/test-udp.lua:261: EHOSTUNREACH"
    ./disable-failing-darwin-tests.patch
  ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ libuv ];

  postConfigure = ''
    mv "$rockspecFilename" "$generatedRockspecFilename"
    rockspecFilename="$generatedRockspecFilename"
    substituteInPlace "$rockspecFilename" \
      --replace-fail 'version = "scm-0"' "version = \"$version\""
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck
    luarocks test
    runHook postInstallCheck
  '';

  __darwinAllowLocalNetworking = true;
  disabled = luaOlder "5.1";

  luarocksConfig.variables = {
    WITH_SHARED_LIBUV = "ON";
  };

  # to make sure we dont use bundled deps
  prePatch = ''
    rm -rf deps/lua deps/luajit deps/libuv
  '';

  rockspecFilename = "luv-scm-0.rockspec";

  passthru = {
    tests = {
      # Test libluv too
      inherit (lua.pkgs) libluv;

      test =
        runCommand "luv-${version}-test"
          {
            nativeBuildInputs = [ (lua.withPackages (ps: [ ps.luv ])) ];
          }
          ''
            lua <<EOF
            local uv = require("luv")
            assert(uv.fs_mkdir(assert(uv.os_getenv("out")), 493))
            print(uv.version_string())
            EOF
          '';
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Bare libuv bindings for lua";

    longDescription = ''
      This library makes libuv available to lua scripts. It was made for the luvit
      project but should usable from nearly any lua project.
    '';

    homepage = "https://github.com/luvit/luv";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ stasjok ];
    platforms = lua.meta.platforms;
  };
}
