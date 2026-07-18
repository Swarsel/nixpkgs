{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  obs-studio,
}:

stdenv.mkDerivation rec {
  pname = "obs-source-record";
  version = "0.4.8";

  src = fetchFromGitHub {
    owner = "exeldro";
    repo = "obs-source-record";
    rev = version;
    sha256 = "sha256-EykXa+7iVTnyCbT8rmadF3OP9Dmc1A4zxi4RukhuZ8s=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ obs-studio ];
  cmakeFlags = [ "-DBUILD_OUT_OF_TREE=On" ];
  env.NIX_CFLAGS_COMPILE = toString [ "-Wno-error=deprecated-declarations" ];

  postInstall = ''
    rm -rf $out/{data,obs-plugins}
  '';

  meta = {
    inherit (obs-studio.meta) platforms;
    description = "OBS Studio plugin to make sources available to record via a filter";
    homepage = "https://github.com/exeldro/obs-source-record";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      robbins
      shackra
    ];
  };
}
