{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "publicsuffix-list";
  version = "0-unstable-2026-05-13";

  src = fetchFromGitHub {
    owner = "publicsuffix";
    repo = "list";
    rev = "e452c7058d6946bd76952b128c12f5ce87a5acb8";
    hash = "sha256-5D4RZAyJOL4hMU32Rmp3SYmjgqEtF36mZJr4YBG0k7E=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm0444 public_suffix_list.dat tests/test_psl.txt -t $out/share/publicsuffix

    runHook postInstall
  '';

  dontBuild = true;
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Cross-vendor public domain suffix database";
    homepage = "https://publicsuffix.org/";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
