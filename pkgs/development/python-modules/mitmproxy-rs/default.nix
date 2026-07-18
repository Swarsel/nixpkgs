{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  mitmproxy,
  mitmproxy-linux,
  mitmproxy-macos,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "mitmproxy-rs";
  version = "0.12.8";

  src = fetchFromGitHub {
    owner = "mitmproxy";
    repo = "mitmproxy_rs";
    tag = "v${version}";
    hash = "sha256-UKvag65KP58/4lZzbwR1sM90z8TOw/0BY3NTLZ4LKxM=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  # not packaged yet
  # ++ lib.optionals stdenv.hostPlatform.isWindows [ mitmproxy-windows ]
  # repo has no python tests
  doCheck = false;
  buildAndTestSubdir = "mitmproxy-rs";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-P6tVyv38hgf5mdUHdHwGwgrM1/7qf15YnhulBqsN5eg=";
  };

  dependencies =
    lib.optionals stdenv.hostPlatform.isLinux [ mitmproxy-linux ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ mitmproxy-macos ];

  pyproject = true;
  pythonImportsCheck = [ "mitmproxy_rs" ];

  meta = {
    inherit (mitmproxy.meta) maintainers;
    description = "Rust bits in mitmproxy";
    homepage = "https://github.com/mitmproxy/mitmproxy_rs";

    changelog = "https://github.com/mitmproxy/mitmproxy_rs/blob/${src.rev}/CHANGELOG.md#${
      lib.replaceStrings [ "." ] [ "" ] version
    }";

    license = lib.licenses.mit;
  };
}
