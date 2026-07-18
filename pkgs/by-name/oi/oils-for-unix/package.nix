{
  lib,
  stdenv,
  fetchurl,
  readline,
  symlinkJoin,
  withReadline ? true,
}:

let
  readline-all = symlinkJoin {
    name = "readline-all";

    paths = [
      readline
      readline.dev
    ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "oils-for-unix";
  version = "0.37.0";

  src = fetchurl {
    url = "https://oils.pub/download/oils-for-unix-${finalAttrs.version}.tar.gz";
    hash = "sha256-9NQdIKBSPbz71LojH4Lt8lsI1JZdZbxx/LVmZtZ0MAA=";
  };

  postPatch = ''
    patchShebangs _build
  '';

  strictDeps = true;
  buildInputs = lib.optional withReadline readline;

  configureFlags = [
    "--datarootdir=${placeholder "out"}"
  ]
  ++ lib.optionals withReadline [
    "--with-readline"
    "--readline=${readline-all}"
  ];

  # As of 0.19.0 the build generates an error on MacOS (using clang version 16.0.6 in the builder),
  # whereas running it outside of Nix with clang version 15.0.0 generates just a warning. The shell seems to
  # work just fine though, so we disable the error here.
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-error=incompatible-function-pointer-types";

  buildPhase = ''
    runHook preBuild

    _build/oils.sh

    runHook postBuild
  '';

  preInstall = ''
    mkdir -p $out/bin
  '';

  installPhase = ''
    runHook preInstall

    ./install

    runHook postInstall
  '';

  passthru =
    let
      mkShell =
        shellName:
        symlinkJoin {
          name = "oils-for-unix-${shellName}-${finalAttrs.version}";
          paths = [ finalAttrs.finalPackage ];
          passthru.shellPath = "/bin/${shellName}";

          meta = finalAttrs.meta // {
            mainProgram = shellName;
          };
        };
    in
    {
      osh = mkShell "osh";
      ysh = mkShell "ysh";
    };

  meta = {
    description = "Unix shell with JSON-compatible structured data. It's our upgrade path from bash to a better language and runtime";

    longDescription = ''
      This package installs both `osh` and `ysh`. To use one as a login shell,
      select one of `pkgs.oils-for-unix.osh`, `pkgs.oils-for-unix.ysh`.
    '';

    homepage = "https://www.oils.pub/";
    changelog = "https://www.oils.pub/release/${finalAttrs.version}/changelog.html";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      mkg20001
      melkor333
    ];

    platforms = lib.platforms.all;
  };
})
