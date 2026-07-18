{
  lib,
  fetchurl,
  innoextract,
  runtimeShell,
  stdenvNoCC,
  wineWow64Packages,
}:

let
  version = "6.4.1";
  tagVersion = lib.replaceStrings [ "." ] [ "_" ] version;
in
stdenvNoCC.mkDerivation rec {
  inherit version;
  pname = "iscc";

  src = fetchurl {
    url = "https://github.com/jrsoftware/issrc/releases/download/is-${tagVersion}/innosetup-${version}.exe";
    hash = "sha256-9Bdg4fGuFdIIm7arFi4hcguSrnUG7XBmezkgAGPWjjQ=";
  };

  nativeBuildInputs = [
    innoextract
    wineWow64Packages.stable
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp -r ./app/* "$out/bin"

    cat << 'EOF' > "$out/bin/iscc"
    #!${runtimeShell}
    export PATH=${wineWow64Packages.stable}/bin:$PATH
    export WINEDLLOVERRIDES="mscoree=" # disable mono

    # Solves PermissionError: [Errno 13] Permission denied: '/homeless-shelter/.wine'
    export HOME=$(mktemp -d)

    wineInputFile=$(${wineWow64Packages.stable}/bin/wine winepath -w $1)
    ${wineWow64Packages.stable}/bin/wine "$out/bin/ISCC.exe" "$wineInputFile"
    EOF

    substituteInPlace $out/bin/iscc \
      --replace "\$out" "$out"

    chmod +x "$out/bin/iscc"

    runHook postInstall
  '';

  dontBuild = true;
  # Stripping causes `$out/bin/Setup.e32` to lose something important and causes the built windows installers to not run on windows "This app can't run on your PC".
  # They worked in wine but not on real windows.
  dontStrip = 1;

  unpackPhase = ''
    runHook preUnpack

    innoextract $src

    runHook postUnpack
  '';

  meta = {
    description = "Compiler for Inno Setup, a tool for creating Windows installers";
    homepage = "https://jrsoftware.org/isinfo.php";
    changelog = "https://jrsoftware.org/files/is6-whatsnew.htm";
    license = lib.licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [ liberodark ];
    platforms = wineWow64Packages.stable.meta.platforms;
    mainProgram = "iscc";
  };
}
