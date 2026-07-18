{
  lib,
  stdenv,
  erlang,
  gitMinimal,
  perl,
  wget,
  which,
  writeText,
}:

{
  name,
  src,
  version,
  beamDeps ? [ ],
  buildFlags ? [ ],
  buildInputs ? [ ],
  buildPhase ? null,
  compilePorts ? false,
  configurePhase ? null,
  enableDebugInfo ? false,
  installPhase ? null,
  meta ? { },
  postPatch ? "",
  setupHook ? null,
  ...
}@attrs:

let
  debugInfoFlag = lib.optionalString (enableDebugInfo || erlang.debugInfo) "+debug_info";

  shell =
    drv:
    stdenv.mkDerivation {
      buildInputs = [ drv ];
      name = "interactive-shell-${drv.name}";
    };

  pkg =
    self:
    stdenv.mkDerivation (
      attrs
      // {
        inherit version;
        inherit src;

        buildInputs = buildInputs ++ [
          erlang
          perl
          which
          gitMinimal
          wget
        ];

        propagatedBuildInputs = beamDeps;

        buildFlags = [
          "SKIP_DEPS=1"
        ]
        ++ lib.optional (enableDebugInfo || erlang.debugInfo) ''ERL_OPTS="$ERL_OPTS +debug_info"''
        ++ buildFlags;

        buildPhase =
          if buildPhase == null then
            ''
              runHook preBuild

              make $buildFlags "''${buildFlagsArray[@]}"

              runHook postBuild
            ''
          else
            buildPhase;

        installPhase =
          if installPhase == null then
            ''
              runHook preInstall

              mkdir -p $out/lib/erlang/lib/${name}
              cp -r ebin $out/lib/erlang/lib/${name}/
              cp -r src $out/lib/erlang/lib/${name}/

              if [ -d include ]; then
                cp -r include $out/lib/erlang/lib/${name}/
              fi

              if [ -d priv ]; then
                cp -r priv $out/lib/erlang/lib/${name}/
              fi

              if [ -d doc ]; then
                cp -r doc $out/lib/erlang/lib/${name}/
              fi

              runHook postInstall
            ''
          else
            installPhase;

        app_name = name;

        configurePhase =
          if configurePhase == null then
            ''
              runHook preConfigure

              # We shouldnt need to do this, but it seems at times there is a *.app in
              # the repo/package. This ensures we start from a clean slate
              make SKIP_DEPS=1 clean

              runHook postConfigure
            ''
          else
            configurePhase;

        dontStrip = true;
        name = "${name}-${version}";

        setupHook =
          if setupHook == null then
            writeText "setupHook.sh" ''
              addToSearchPath ERL_LIBS "$1/lib/erlang/lib"
            ''
          else
            setupHook;

        passthru = {
          inherit beamDeps;
          env = shell self;
          packageName = name;
        };
      }
    );
in
lib.fix pkg
