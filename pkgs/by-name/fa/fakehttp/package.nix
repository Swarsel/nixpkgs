{
  lib,
  stdenv,
  fetchFromGitHub,
  libmnl,
  libnetfilter_queue,
  libnfnetlink,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fakehttp";
  version = "0.9.18";

  src = fetchFromGitHub {
    owner = "MikeWang000000";
    repo = "FakeHTTP";
    tag = finalAttrs.version;
    hash = "sha256-XjWveBsRJq5iNpk3e9lmVKMoB3q5tr4OiNY+kYEqtEE=";
  };

  buildInputs = [
    libnetfilter_queue
    libnfnetlink
    libmnl
  ];

  makeFlags = [
    "CROSS_PREFIX=${stdenv.cc.targetPrefix}"
    "VERSION=${finalAttrs.version}"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  installFlags = [ "PREFIX=$(out)" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Obfuscate all your TCP connections into HTTP protocol";
    homepage = "https://github.com/MikeWang000000/FakeHTTP";
    changelog = "https://github.com/MikeWang000000/FakeHTTP/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.linux;
    mainProgram = "fakehttp";
  };
})
