{
  lib,
  stdenv,
  fetchFromGitHub,
  ffmpeg,
  gitUpdater,
  meson,
  ninja,
  pkg-config,
  vapoursynth,
  xxhash,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vapoursynth-bestsource";
  version = "13";

  src = fetchFromGitHub {
    owner = "vapoursynth";
    repo = "bestsource";
    tag = "R${finalAttrs.version}";
    hash = "sha256-c+FMFWICDS8Plj6GE2vvhWPmf56Vk10j41HUK1q20/U=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "vapoursynth_dep.get_variable(pkgconfig: 'libdir')" "get_option('libdir')"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    vapoursynth
    (ffmpeg.override { withLcms2 = true; })
    xxhash
  ];

  passthru.updateScript = gitUpdater {
    ignoredVersions = "*-RC*";
    rev-prefix = "R";
  };

  meta = {
    description = "Wrapper library around FFmpeg that ensures sample and frame accurate access to audio and video";
    homepage = "https://github.com/vapoursynth/bestsource";

    license = with lib.licenses; [
      mit
      wtfpl
      gpl2Plus
    ];

    maintainers = with lib.maintainers; [ snaki ];
    platforms = lib.platforms.all;
  };
})
