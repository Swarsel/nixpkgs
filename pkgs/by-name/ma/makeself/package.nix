{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  pbzip2,
  which,
  zstd,
}:

stdenv.mkDerivation rec {
  pname = "makeself";
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "megastep";
    repo = "makeself";
    tag = "release-${version}";
    hash = "sha256-X35vdzsfAQWAHMvlQSxCeu7IgUNVvnOQaakS27SXlFA=";
    fetchSubmodules = true;
  };

  postPatch = "patchShebangs test";
  nativeBuildInputs = [ installShellFiles ];
  # Issue #110149: our default /bin/sh apparently has 32-bit math only
  # (attribute busybox-sandbox-shell), and that causes problems
  # when running these tests inside build, based on free disk space.
  doCheck = false;

  nativeCheckInputs = [
    which
    zstd
    pbzip2
  ];

  installPhase = ''
    runHook preInstall
    installManPage makeself.1
    install -Dm555 makeself.sh $out/bin/makeself
    install -Dm444 -t ${sharePath}/ README.md makeself-header.sh
    runHook postInstall
  '';

  checkTarget = "test";

  fixupPhase = ''
    sed -e "s|^HEADER=.*|HEADER=${sharePath}/makeself-header.sh|" -i $out/bin/makeself
  '';

  sharePath = "$out/share/${pname}";

  meta = {
    description = "Utility to create self-extracting packages";
    homepage = "https://makeself.io";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.wmertens ];
    platforms = lib.platforms.all;
    mainProgram = "makeself";
  };
}
