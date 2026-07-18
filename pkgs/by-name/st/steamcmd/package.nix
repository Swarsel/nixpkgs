{
  lib,
  fetchurl,
  coreutils,
  stdenvNoCC,
  steam-run,
  steamRoot ? "$HOME/.local/share/Steam",
}:
let
  srcs =
    let
      url =
        platform:
        "https://web.archive.org/web/20240521141411/https://steamcdn-a.akamaihd.net/client/installer/steamcmd_${platform}.tar.gz";
    in
    {
      x86_64-linux = fetchurl {
        hash = "sha256-zr8ARr/QjPRdprwJSuR6o56/QVXl7eQTc7V5uPEHHnw=";
        url = url "linux";
      };
    };
in
stdenvNoCC.mkDerivation {
  pname = "steamcmd";
  version = "20180104"; # According to steamcmd_linux.tar.gz mtime

  src =
    srcs.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");

  installPhase = ''
    mkdir -p $out/share/steamcmd
    find . -type f -exec install -Dm 755 "{}" "$out/share/steamcmd/{}" \;

    mkdir -p $out/bin
    substitute ${./steamcmd.sh} $out/bin/steamcmd \
      --subst-var out \
      --subst-var-by coreutils ${coreutils} \
      --subst-var-by steamRoot '${steamRoot}' \
      --subst-var-by steamRun ${
        if stdenvNoCC.hostPlatform.isLinux then (lib.getExe steam-run) else "exec"
      }
    chmod 0755 $out/bin/steamcmd
  '';

  dontBuild = true;

  # The source tarball does not have a single top-level directory.
  preUnpack = ''
    mkdir $name
    cd $name
    sourceRoot=.
  '';

  meta = {
    description = "Steam command-line tools";
    homepage = "https://developer.valvesoftware.com/wiki/SteamCMD";
    license = lib.licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [ tadfisher ];

    platforms = [
      "x86_64-linux"
    ];

    mainProgram = "steamcmd";
  };
}
