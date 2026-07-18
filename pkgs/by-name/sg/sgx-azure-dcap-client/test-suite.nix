{
  lib,
  gtest,
  makeWrapper,
  sgx-azure-dcap-client,
}:
sgx-azure-dcap-client.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    # Missing `#include <array>`
    ./tests-missing-includes.patch

    # gtest no longer supports c++14. Use c++17.
    ./tests-cpp-version.patch
  ];

  nativeBuildInputs = old.nativeBuildInputs ++ [
    makeWrapper
    gtest
  ];

  buildFlags = [
    "tests"
  ];

  installPhase = ''
    runHook preInstall

    install -D ./src/Linux/tests "$out/bin/tests"

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/tests" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ sgx-azure-dcap-client ]}"
  '';
})
