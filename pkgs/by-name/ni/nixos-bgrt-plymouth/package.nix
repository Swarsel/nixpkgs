{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "nixos-bgrt-plymouth";
  version = "0-unstable-2024-10-25";

  src = fetchFromGitHub {
    owner = "helsinki-systems";
    repo = "plymouth-theme-nixos-bgrt";
    rev = "9b3913c38212463f3e21e8e805eead8f332215fa";
    hash = "sha256-VmNATLInItV2uMYJgpo8ywBUtfiqgcspPkRL9ws5zag=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plymouth/themes/nixos-bgrt
    cp -r $src/{*.plymouth,images} $out/share/plymouth/themes/nixos-bgrt/
    substituteInPlace $out/share/plymouth/themes/nixos-bgrt/*.plymouth --replace '@IMAGES@' "$out/share/plymouth/themes/nixos-bgrt/images"

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "BGRT theme with a spinning NixOS logo";
    homepage = "https://github.com/helsinki-systems/plymouth-theme-nixos-bgrt";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
