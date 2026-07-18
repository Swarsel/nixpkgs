{
  lib,
  stdenv,
  fetchFromGitHub,
  hidapi,
  pkg-config,
  udevCheckHook,
}:

stdenv.mkDerivation {
  pname = "footswitch";
  version = "unstable-2023-10-10";

  src = fetchFromGitHub {
    owner = "rgerganov";
    repo = "footswitch";
    rev = "b7493170ecc956ac87df2c36183253c945be2dcf";
    hash = "sha256-vwjeWjIXQiFJ0o/wgEBrKP3hQi8Xa/azVS1IE/Q/MyY=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace /usr/local $out \
      --replace /usr/bin/install install \
      --replace /etc/udev $out/lib/udev
  '';

  nativeBuildInputs = [
    pkg-config
    udevCheckHook
  ];

  buildInputs = [ hidapi ];

  preInstall = ''
    mkdir -p $out/bin $out/lib/udev/rules.d
  '';

  doInstallCheck = true;

  meta = {
    description = "Command line utlities for programming PCsensor and Scythe foot switches";
    homepage = "https://github.com/rgerganov/footswitch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ baloo ];
    platforms = lib.platforms.linux;
  };
}
