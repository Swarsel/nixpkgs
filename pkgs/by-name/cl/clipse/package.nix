{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  libpng,
  libx11,
  libxi,
  libxkbcommon,
  libxtst,
  pkg-config,
  xclip,
  xinput,
  xkbcomp,
  xkbutils,
  xsel,
  enableWayland ? stdenv.hostPlatform.isLinux,
  enableX11 ? false,
}:

assert lib.assertMsg (
  stdenv.hostPlatform.isLinux -> (lib.xor enableX11 enableWayland)
) "Exactly one of enableWayland, enableX11 must be true";

buildGoModule (finalAttrs: {
  pname = "clipse${lib.optionalString enableX11 "-x11"}";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "savedra1";
    repo = "clipse";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iDMHEhYuxspBYG54WivnVj2GfMxAc5dcrjNxtAMhsck=";
  };

  strictDeps = true;

  nativeBuildInputs = lib.optionals enableX11 [
    pkg-config
  ];

  buildInputs = lib.optionals enableX11 [
    libpng
    libx11
    libxi
    libxkbcommon
    libxtst
    xclip
    xinput
    xkbcomp
    xkbutils
    xsel
  ];

  vendorHash = "sha256-LxwST4Zjxq6Fwc47VeOdv19J3g/DHZ7Fywp2ZvVR06I=";

  env = {
    CGO_ENABLED = if enableX11 || stdenv.hostPlatform.isDarwin then "1" else "0";
  };

  __structuredAttrs = true;
  proxyVendor = true;

  tags =
    if stdenv.hostPlatform.isDarwin then
      [ "darwin" ]
    else if enableWayland then
      [ "wayland" ]
    else if enableX11 then
      [ "linux" ]
    else
      [ ];

  meta = {
    description = "Useful clipboard manager TUI for Unix";
    homepage = "https://github.com/savedra1/clipse";
    changelog = "https://github.com/savedra1/clipse/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      magicquark
      savedra1
    ];

    mainProgram = "clipse";
  };
})
