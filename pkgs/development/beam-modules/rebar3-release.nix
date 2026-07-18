{
  lib,
  stdenv,
  erlang,
  openssl,
  rebar3WithPlugins,
}:

{
  pname,
  releaseType,
  src,
  version,
  beamDeps ? [ ],
  buildInputs ? [ ],
  buildPhase ? null,
  buildPlugins ? [ ],
  checkouts ? null,
  configurePhase ? null,
  installPhase ? null,
  meta ? { },
  profile ? "default",
  setupHook ? null,
  ...
}@attrs:

let
  shell =
    drv:
    stdenv.mkDerivation {
      buildInputs = [ drv ];
      name = "interactive-shell-${drv.pname}";
    };

  customPhases = lib.filterAttrs (_: v: v != null) {
    inherit
      setupHook
      configurePhase
      buildPhase
      installPhase
      ;
  };

  # When using the `beamDeps` argument, it is important that we use
  # `rebar3WithPlugins` here even when there are no plugins. The vanilla
  # `rebar3` package is an escript archive with bundled dependencies which can
  # interfere with those in the app we are trying to build. `rebar3WithPlugins`
  # doesn't have this issue since it puts its own deps last on the code path.
  rebar3 = rebar3WithPlugins {
    plugins = buildPlugins;
  };

  pkg =
    assert beamDeps != [ ] -> checkouts == null;
    self:
    stdenv.mkDerivation (
      attrs
      // {

        inherit version pname;
        inherit src;

        buildInputs =
          buildInputs
          ++ [
            erlang
            rebar3
            openssl
          ]
          ++ beamDeps;

        env = (attrs.env or { }) // {
          REBAR_IGNORE_DEPS = beamDeps != [ ];
        };

        buildPhase = ''
          runHook preBuild
          HOME=. DEBUG=1 rebar3 as ${profile} ${if releaseType == "escript" then "escriptize" else "release"}
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          dir=${if releaseType == "escript" then "bin" else "rel"}
          mkdir -p "$out/$dir" "$out/bin"
          cp -R --preserve=mode "_build/${profile}/$dir" "$out"
          ${lib.optionalString (
            releaseType == "release"
          ) "find $out/rel/*/bin -type f -executable -exec ln -s -t $out/bin {} \\;"}
          runHook postInstall
        '';

        # Release will generate a binary which will cause a read null byte failure, see #261354
        postInstall = lib.optionalString (releaseType == "escript") ''
          for dir in $out/rel/*/erts-*; do
            echo "ERTS found in $dir - removing references to erlang to reduce closure size"
            for f in $dir/bin/{erl,start}; do
              substituteInPlace "$f" --replace "${erlang}/lib/erlang" "''${dir/\/erts-*/}"
            done
          done
        '';

        configurePhase = ''
          runHook preConfigure
          ${lib.optionalString (checkouts != null) "cp --no-preserve=all -R ${checkouts}/_checkouts ."}
          runHook postConfigure
        '';

        # ensure we strip any native binaries (eg. NIFs, ports)
        stripDebugList = lib.optional (releaseType == "release") "rel";

        passthru = (
          {
            env = shell self;
            packageName = pname;
          }
          // (if attrs ? passthru then attrs.passthru else { })
        );

        meta = {
          inherit (erlang.meta) platforms;
        }
        // meta;
      }
      // customPhases
    );
in
lib.fix pkg
