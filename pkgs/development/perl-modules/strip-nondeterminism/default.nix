{
  lib,
  stdenv,
  fetchFromGitLab,
  ArchiveCpio,
  ArchiveZip,
  SubOverride,
  buildPerlPackage,
  file,
  gitUpdater,
}:

buildPerlPackage rec {
  pname = "strip-nondeterminism";
  version = "1.14.1";

  src = fetchFromGitLab {
    owner = "reproducible-builds";
    repo = "strip-nondeterminism";
    rev = version;
    sha256 = "C/812td9BX1YRqFpD9QYgBfzE+biZeAKgxoNcxpb6UU=";
    domain = "salsa.debian.org";
  };

  outputs = [
    "out"
    "dev"
  ]; # no "devdoc"

  postPatch = ''
    substituteInPlace lib/File/StripNondeterminism.pm \
      --replace "exec('file'" "exec('${lib.getExe file}'"
  '';

  strictDeps = true;

  buildInputs = [
    ArchiveZip
    ArchiveCpio
    SubOverride
  ];

  postBuild = ''
    patchShebangs ./bin
  '';

  postInstall = ''
    # we don’t need the debhelper script
    rm $out/bin/dh_strip_nondeterminism
    rm $out/share/man/man1/dh_strip_nondeterminism.1
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck
    ($out/bin/strip-nondeterminism --help 2>&1 | grep -q "verbose") || (echo "'$out/bin/strip-nondeterminism --help' failed" && exit 1)
    runHook postInstallCheck
  '';

  passthru = {
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Perl module for stripping bits of non-deterministic information";
    homepage = "https://reproducible-builds.org/";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      pSub
      artturin
    ];

    mainProgram = "strip-nondeterminism";
  };
}
