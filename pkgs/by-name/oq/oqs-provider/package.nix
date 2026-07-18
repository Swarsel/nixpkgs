{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  liboqs,
  nix-update-script,
  openssl,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "oqs-provider";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "open-quantum-safe";
    repo = "oqs-provider";
    tag = finalAttrs.version;
    hash = "sha256-7nPYnlq6/GokWceHk1ZcnZo9A1z6LMtLBGM61zHvcyY=";
  };

  postPatch = ''
    echo ${finalAttrs.version} > VERSION
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    openssl
    liboqs
  ];

  configureFlags = [ "--with-modulesdir=$$out/lib/ossl-modules" ];
  doCheck = true;
  nativeCheckInputs = [ openssl.bin ];

  preInstall = ''
    mkdir -p "$out"
    for dir in "$out" "${openssl.out}"; do
      mkdir -p .install/"$(dirname -- "$dir")"
      ln -s "$out" ".install/$dir"
    done
    export DESTDIR="$(realpath .install)"
  '';

  enableParallelInstalling = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open Quantum Safe provider for OpenSSL (3.x)";
    homepage = "https://github.com/open-quantum-safe/oqs-provider";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rixxc ];
    platforms = lib.platforms.all;
  };
})
