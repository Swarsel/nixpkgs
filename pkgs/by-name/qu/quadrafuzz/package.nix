{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cairo,
  lv2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "quadrafuzz";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "jpcima";
    repo = "quadrafuzz";
    tag = "v${finalAttrs.version}";
    sha256 = "1kjsf7il9krihwlrq08gk2xvil4b4q5zd87nnm103hby2w7ws7z1";
    fetchSubmodules = true;
  };

  postPatch = ''
    patchShebangs ./dpf/utils/generate-ttl.sh
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    boost
    cairo
    lv2
  ];

  makeFlags = [
    "PREFIX=$(out)"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/lv2
    cp -r bin/quadrafuzz.lv2/ $out/lib/lv2
    runHook postInstall
  '';

  meta = {
    description = "Multi-band fuzz distortion plugin";
    homepage = "https://github.com/jpcima/quadrafuzz";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
    broken = (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
  };
})
