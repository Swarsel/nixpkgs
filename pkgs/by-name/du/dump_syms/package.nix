{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  firefox-esr-unwrapped,
  firefox-unwrapped,
  openssl,
  pkg-config,
  rustPlatform,
  thunderbird-unwrapped,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dump_syms";
  version = "2.3.7";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "dump_syms";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fCplZFp+yONBd2HDDlX/6XcmnQFbsnVmiS5b8fqGOAE=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-guJgkcldcKvi3XWolAqyB5bFzlSMNQQMzri6axGJpLo=";

  checkFlags = [
    # Disable tests that require network access
    # ConnectError("dns error", Custom { kind: Uncategorized, error: "failed to lookup address information: Temporary failure in name resolution" })) }', src/windows/pdb.rs:725:56
    "--skip=windows::pdb::tests::test_ntdll"
    "--skip=windows::pdb::tests::test_oleaut32"
  ];

  __structuredAttrs = true;

  passthru.tests = {
    inherit firefox-esr-unwrapped firefox-unwrapped thunderbird-unwrapped;
  };

  meta = {
    description = "Command-line utility for parsing the debugging information the compiler provides in ELF or stand-alone PDB files";
    homepage = "https://github.com/mozilla/dump_syms/";
    changelog = "https://github.com/mozilla/dump_syms/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "dump_syms";
  };
})
