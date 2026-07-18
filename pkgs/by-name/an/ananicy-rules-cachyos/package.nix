{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "ananicy-rules-cachyos";
  version = "0-unstable-2026-07-11";

  src = fetchFromGitHub {
    owner = "CachyOS";
    repo = "ananicy-rules";
    rev = "c59d59711268395b324fa5d4af149f2f94f17b4f";
    hash = "sha256-+hDuzZtsKkoP5mD0VmzO/mXNjP0RPLz+hzK2XFUBvpc=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/etc/ananicy.d
    rm README.md LICENSE
    cp -r * $out/etc/ananicy.d
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  passthru.updateScript = unstableGitUpdater {
    hardcodeZeroVersion = true;
  };

  meta = {
    description = "CachyOS' ananicy-rules meant to be used with ananicy-cpp";
    homepage = "https://github.com/CachyOS/ananicy-rules";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      artturin
      johnrtitor
    ];

    platforms = lib.platforms.linux;
  };
}
