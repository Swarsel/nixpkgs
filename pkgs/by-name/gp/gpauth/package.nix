{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  perl,
  pkg-config,
  rustPlatform,
  webkitgtk_4_1,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gpauth";
  version = "2.6.4";

  src = fetchFromGitHub {
    owner = "yuezk";
    repo = "GlobalProtect-openconnect";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cFzQhogahw4/LXI6B9K2xxkMitbHfZg/3/00UORiGEE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    perl
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    webkitgtk_4_1
  ];

  cargoHash = "sha256-9O9DHkn2ZG3SOnqjd5xYTNTTJ3w6yj0bs9Nl7m+rg64=";
  buildAndTestSubdir = "apps/gpauth";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI for GlobalProtect VPN, based on OpenConnect, supports the SSO authentication method";

    longDescription = ''
      A CLI for GlobalProtect VPN, based on OpenConnect, supports the SSO
      authentication method. Inspired by gp-saml-gui.

      The CLI version is always free and open source in this repo. It has almost
      the same features as the GUI version.
    '';

    homepage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}";
    changelog = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}/blob/${finalAttrs.src.rev}/changelog.md";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      binary-eater
      booxter
      m1dugh
    ];

    platforms = with lib.platforms; linux ++ darwin;
  };
})
