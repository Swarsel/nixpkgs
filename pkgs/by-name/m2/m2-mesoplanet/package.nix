{
  lib,
  stdenv,
  fetchFromGitHub,
  m2libc,
  mescc-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "m2-mesoplanet";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "oriansj";
    repo = "M2-Mesoplanet";
    rev = "Release_${finalAttrs.version}";
    hash = "sha256-hE7xvX84q3tk0XakveYDJhrhfBnpoItQs456NCzFfws=";
  };

  # Don't use vendored M2libc
  postPatch = ''
    rmdir M2libc
    ln -s ${m2libc}/include/M2libc M2libc
  '';

  doCheck = true;
  nativeCheckInputs = [ mescc-tools ];

  installPhase = ''
    runHook preInstall

    install -D bin/M2-Mesoplanet $out/bin/M2-Mesoplanet

    runHook postInstall
  '';

  checkTarget = "test";
  # Upstream overrides the optimisation to be -O0, which is incompatible with fortify. Let's disable it.
  hardeningDisable = [ "fortify" ];

  meta = {
    inherit (m2libc.meta) platforms;
    description = "Macro Expander Saving Our m2-PLANET";
    homepage = "https://github.com/oriansj/M2-Mesoplanet";
    license = lib.licenses.gpl3Only;
    mainProgram = "M2-Mesoplanet";
    teams = [ lib.teams.minimal-bootstrap ];
  };
})
