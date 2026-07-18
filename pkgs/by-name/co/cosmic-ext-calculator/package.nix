# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Lily Foster <lily@lily.flowers>
# Portions of this code are adapted from nixos-cosmic
# https://github.com/lilyinstarlight/nixos-cosmic
{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  just,
  libcosmicAppHook,
  libqalculate,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-ext-calculator";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "calculator";
    tag = finalAttrs.version;
    hash = "sha256-qPo+Qi6P0m3rNA6Qo6iNsgzGyirPqzXk4nj3OG6IuZ0=";
  };

  # TODO: Remove in the next release
  patches = [
    (fetchpatch {
      hash = "sha256-amSB+67rwCUqfqOTFGCkInvoZmA//wAR0viuvNdPkuc=";
      url = "https://github.com/cosmic-utils/calculator/commit/fc176a8d5d8af7fd808d450a78635432db6b64e6.patch";
    })
  ];

  nativeBuildInputs = [
    libcosmicAppHook
    just
  ];

  cargoHash = "sha256-Pq1E4O6lZMe+wKJgQKDBmgdsJJsJTyK0FDXU53n+Di4=";

  preFixup = ''
    libcosmicAppWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ libqalculate ]}
    )
  '';

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-ext-calculator"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Calculator for the COSMIC Desktop Environment";
    homepage = "https://github.com/cosmic-utils/calculator";
    changelog = "https://github.com/cosmic-utils/calculator/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-calculator";
  };
})
