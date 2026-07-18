{
  lib,
  stdenv,
  linuxPackages_latest,
  man,
  python3,
}:

stdenv.mkDerivation {
  inherit (linuxPackages_latest.kernel) version src;
  pname = "linux-manual";

  postPatch = ''
    # Releases up to including 6.19.3 still use scripts/kernel-doc.py, but it
    # has been moved to tools/docs with 7.0-rc1.
    patchShebangs --build \
      tools/docs \
      scripts/kernel-doc.py
  '';

  nativeBuildInputs = [ python3 ];

  buildPhase = ''
    runHook preBuild

    # avoid Makefile because it checks for unnecessary Python dependencies
    KBUILD_BUILD_TIMESTAMP="$(date -u -d "@$SOURCE_DATE_EPOCH")" \
    tools/docs/sphinx-build-wrapper mandocs

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/man"
    cp -r output/man "$out/share/man/man9"

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ man ];

  installCheckPhase = ''
    runHook preInstallCheck

    # Check for well‐known man page
    man -M "$out/share/man" -P cat 9 kmalloc >/dev/null

    runHook postInstallCheck
  '';

  dontConfigure = true;

  meta = {
    description = "Linux kernel API manual pages";
    homepage = "https://kernel.org/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ mvs ];
    platforms = lib.platforms.linux;
  };
}
