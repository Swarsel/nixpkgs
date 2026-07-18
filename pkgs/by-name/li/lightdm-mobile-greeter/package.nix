{
  lib,
  fetchFromGitea,
  gtk3,
  libhandy_0,
  lightdm,
  lightdm-mobile-greeter,
  linkFarm,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "lightdm-mobile-greeter";
  version = "2022-10-30";

  src = fetchFromGitea {
    owner = "raatty";
    repo = "lightdm-mobile-greeter";
    rev = "8c8d6dfce62799307320c8c5a1f0dd5c8c18e4d3";
    hash = "sha256-SrAR2+An3BN/doFl/s8PcYZMUHLfVPXKZOo6ndO60nY=";
    domain = "git.raatty.club";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    gtk3
    libhandy_0
    lightdm
  ];

  cargoHash = "sha256-9beOnuyzr1vC511il3Yjy9OVcQ0ZP9RQ88eCzx3xLsA=";

  postInstall = ''
    mkdir -p $out/share/xgreeters
    substitute lightdm-mobile-greeter.desktop \
      $out/share/xgreeters/lightdm-mobile-greeter.desktop \
      --replace lightdm-mobile-greeter $out/bin/lightdm-mobile-greeter
  '';

  passthru.xgreeters = linkFarm "lightdm-mobile-greeter-xgreeters" [
    {
      name = "lightdm-mobile-greeter.desktop";
      path = "${lightdm-mobile-greeter}/share/xgreeters/lightdm-mobile-greeter.desktop";
    }
  ];

  meta = {
    description = "Simple log in screen for use on touch screens";
    homepage = "https://git.raatty.club/raatty/lightdm-mobile-greeter";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "lightdm-mobile-greeter";
  };
}
