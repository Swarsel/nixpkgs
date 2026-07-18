{
  lib,
  freerdp,
  kirigami-addons,
  mkKdeDerivation,
  openssl,
  pam,
  pkg-config,
  qtwayland,
  replaceVars,
}:
mkKdeDerivation {
  pname = "krdp";

  patches = [
    (replaceVars ./hardcode-openssl-path.patch {
      openssl = lib.getExe openssl;
    })
  ];

  # Hardcoded as QString, which is UTF-16 so Nix can't pick it up automatically
  postFixup = ''
    mkdir -p $out/nix-support
    echo "${lib.getExe openssl}" > $out/nix-support/depends
  '';

  extraBuildInputs = [
    qtwayland

    kirigami-addons

    freerdp
    pam
  ];

  extraNativeBuildInputs = [ pkg-config ];
}
