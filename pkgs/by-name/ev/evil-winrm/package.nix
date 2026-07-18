{
  lib,
  stdenv,
  fetchFromGitHub,
  bundlerEnv,
  bundlerUpdateScript,
  krb5,
  makeWrapper,
  writeText,
  sslLegacyProvider ? false,
}:
let
  rubyEnv = bundlerEnv {
    gemfile = ./Gemfile;
    gemset = ./gemset.nix;
    lockfile = ./Gemfile.lock;
    name = "evil-winrm";
  };
  openssl_conf = writeText "openssl.conf" ''
    openssl_conf = openssl_init

    [openssl_init]
    providers = provider_sect

    [provider_sect]
    default = default_sect
    legacy = legacy_sect

    [default_sect]
    activate = 1

    [legacy_sect]
    activate = 1
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "evil-winrm";
  version = "3.7";

  src = fetchFromGitHub {
    owner = "Hackplayers";
    repo = "evil-winrm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jr8glS732UvSt+qFkhhLFZUB7OIRpRj3SzXm6mVikrE=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    rubyEnv.wrappedRuby
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp evil-winrm.rb $out/bin/evil-winrm
  '';

  postFixup = lib.optionalString sslLegacyProvider ''
    wrapProgram $out/bin/evil-winrm \
      --prefix OPENSSL_CONF : "${openssl_conf}" \
      --prefix LD_LIBRARY_PATH : ${krb5.lib}/lib
  '';

  passthru.updateScript = bundlerUpdateScript "evil-winrm";

  meta = {
    description = "WinRM shell for hacking/pentesting";
    homepage = "https://github.com/Hackplayers/evil-winrm";
    changelog = "https://github.com/Hackplayers/evil-winrm/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.lgpl3Plus;
    mainProgram = "evil-winrm";
  };
})
