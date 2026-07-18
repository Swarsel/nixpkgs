{
  lib,
  stdenv,
  fetchgit,
  nss,
  openssl,
  pkg-config,
}:
let
  url = "https://chromium.googlesource.com/chromiumos/platform/vboot_reference";
  branch = "release-R145-16552.B";
in
stdenv.mkDerivation {
  pname = "futility";
  version = "0-${branch}";

  src = fetchgit {
    inherit url;
    rev = "refs/heads/${branch}";
    hash = "sha256-LctTKkf8nTVcrErMiAkvSCYkZnBoTYjqxWj0xADi0Q4=";
  };

  postPatch = ''
    patchShebangs ./scripts
    substituteInPlace ./scripts/getversion.sh \
      --replace-fail "unknown" "${branch}"
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    nss
  ];

  makeFlags = [
    "UB_DIR=$(out)/bin"
    "USE_FLASHROM=0"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ "HAVE_MACOS=1" ];

  buildFlags = "futil";
  installTargets = "futil_install";

  meta = {
    description = "ChromeOS firmware utility";
    homepage = url;
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ungeskriptet ];
    badPlatforms = lib.platforms.darwin;
    mainProgram = "futility";
    teams = [ lib.teams.android ];
  };
}
