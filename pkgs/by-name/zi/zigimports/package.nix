{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  zig_0_13,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zigimports";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "tusharsadhwani";
    repo = "zigimports";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2cri+5mhhTQqlkv9db/3CQ3rCMq4yW4drMoRTZBhndE=";
  };

  nativeBuildInputs = [
    zig_0_13
  ];

  # Remove the system suffix on the program name.
  postInstall = ''
    mv $out/bin/zigimports{*,}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (zig_0_13.meta) platforms;
    description = "Automatically remove unused imports and globals from Zig files";
    homepage = "https://github.com/tusharsadhwani/zigimports";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jmbaur ];
    mainProgram = "zigimports";
  };
})
