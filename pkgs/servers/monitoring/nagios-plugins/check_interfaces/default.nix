{
  lib,
  stdenv,
  fetchurl,
  net-snmp,
  nix-update-script,
  versionCheckHook,
}:
stdenv.mkDerivation rec {
  pname = "check_interfaces";
  version = "1.4.4";

  src = fetchurl {
    url = "https://github.com/NETWAYS/check_interfaces/releases/download/v${version}/check_interfaces-${version}.tar.gz";
    hash = "sha256-sQ2lee2gxyrl455tumMJ4EbKc8mYEDXl18Wik6daf5Q=";
  };

  buildInputs = [ net-snmp ];
  configureFlags = [ "--libexecdir=${placeholder "out"}/bin" ];

  postInstall = ''
    # Remove unnecessary header files
    rm --recursive $out/include
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  enableParallelBuilding = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Icinga check plugin for network hardware interfaces";
    homepage = "https://github.com/NETWAYS/check_interfaces/";
    changelog = "https://github.com/NETWAYS/check_interfaces/releases/tag/v${version}";
    license = with lib.licenses; [ gpl2Only ];
    maintainers = with lib.maintainers; [ jwillikers ];
    platforms = lib.platforms.unix;
    mainProgram = "check_interfaces";
  };
}
