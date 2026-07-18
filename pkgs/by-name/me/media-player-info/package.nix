{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  pkg-config,
  python3,
  systemd,
  udev,
  udevCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "media-player-info";
  version = "26";

  src = fetchFromGitLab {
    owner = "media-player-info";
    repo = "media-player-info";
    rev = finalAttrs.version;
    hash = "sha256-VoMr5Lxy6u/BA/9t65/S8AW41YU0FLp6eftYUVdoMjY=";
    domain = "gitlab.freedesktop.org";
  };

  postPatch = ''
    patchShebangs ./tools
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    python3
    udevCheckHook
  ];

  buildInputs = [
    udev
    systemd
  ];

  configureFlags = [ "--with-udevdir=${placeholder "out"}/lib/udev" ];
  doInstallCheck = true;

  meta = {
    description = "Repository of data files describing media player capabilities";
    homepage = "https://www.freedesktop.org/wiki/Software/media-player-info/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
  };
})
