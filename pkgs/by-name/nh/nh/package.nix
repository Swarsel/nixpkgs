{
  lib,
  makeBinaryWrapper,
  nh-unwrapped,
  nix-output-monitor,
  symlinkJoin,
}:
let
  unwrapped = nh-unwrapped;
  runtimeDeps = [
    nix-output-monitor
  ];
in
symlinkJoin {
  inherit (unwrapped) version;
  pname = "nh";

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  postBuild = ''
    wrapProgram $out/bin/nh \
      --prefix PATH : ${lib.makeBinPath runtimeDeps}
  '';

  paths = [
    unwrapped
  ];

  meta = {
    inherit (unwrapped.meta)
      changelog
      description
      homepage
      license
      mainProgram
      maintainers
      ;

    # To prevent builds on hydra
    hydraPlatforms = [ ];
    # prefer wrapper over the package
    priority = (unwrapped.meta.priority or lib.meta.defaultPriority) - 1;
  };
}
