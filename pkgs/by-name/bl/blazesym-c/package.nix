{
  lib,
  fetchFromGitHub,
  elfutils,
  nix-update-script,
  pkg-config,
  rustPlatform,
  zlib,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "blazesym-c";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "libbpf";
    repo = "blazesym";
    tag = "capi-v${finalAttrs.version}";
    hash = "sha256-IdeY9FCGziYN9glnvQJu2oa5ogdXb6D9QcY2MRnq7vA=";
  };

  cargoHash = "sha256-fsvdhahTKxjrrH9z6m1k3cTkXfMUZXZNZlYRi3tgTlA=";

  nativeCheckInputs = [
    pkg-config
    elfutils
    zlib
  ];

  postInstall = ''
    install -Dm644 capi/include/blazesym.h "$out/include/blazesym.h"
  '';

  cargoBuildFlags = [
    "--package"
    "blazesym-c"
  ];

  cargoTestFlags = [
    "--no-run"
    "--package"
    "blazesym-c"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^capi-v([0-9.]+)$"
    ];
  };

  meta = {
    description = "C language bindings for the blazesym library";
    homepage = "https://github.com/libbpf/blazesym";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ aaronjheng ];
    platforms = lib.platforms.linux;
  };
})
