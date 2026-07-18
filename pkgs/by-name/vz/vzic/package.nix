{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  glib,
  libical,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vzic";
  version = "0-unstable-2024-06-04";

  src = fetchFromGitHub {
    owner = "libical";
    repo = "vzic";
    rev = "354296149e65ca31932c514fddb7435cb47671e9";
    hash = "sha256-L6BIHr3tfw51AoSvZMlP3HWEWXfEaPa8nq1aJOqcNkE=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail 'pkg-config' "$PKG_CONFIG"
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    glib
    libical
  ];

  env = {
    OLSON_DIR = "tzdata2024a";
    PRODUCT_ID = "-//NixOS//NONSGML Citadel calendar//EN";
    TZID_PREFIX = "/NixOS/Olson_%D_1/";
  };

  # no install rule in Makefile
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/vtimezone
    ${stdenv.hostPlatform.emulator buildPackages} ./vzic --output-dir $out/share/vtimezone
    install -Dm744 vzic $out/bin/vzic

    runHook postInstall
  '';

  meta = {
    description = "Program to convert the IANA timezone database files into VTIMEZONE files compatible with the iCalendar specification";
    homepage = "https://github.com/libical/vzic";
    changelog = "https://github.com/libical/vzic/blob/${finalAttrs.src.rev}/ChangeLog";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.unix;
    mainProgram = "vzic";
    broken = !stdenv.hostPlatform.emulatorAvailable buildPackages;
  };
})
