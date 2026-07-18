{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  manuf, # remove when buildPythonPackage supports finalAttrs
  pytestCheckHook,
  runCommand,
  wireshark-cli,
}:

buildPythonPackage rec {
  pname = "manuf";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "coolbho3k";
    repo = "manuf";
    rev = "${version}";
    hash = "sha256-3CFs3aqwE8rZPwU1QBqAGxNHT5jg7ymG12yBD56gTNI=";
  };

  patches = [
    # Do update while building package from wireshark-cli
    ./internal_db_update_nix.patch
    # Fix MANUF_URL for external db update functionality (https://github.com/coolbho3k/manuf/issues/34)
    ./fix_manuf_url.patch
  ];

  postPatch = ''
    ${lib.getExe wireshark-cli} -G manuf > manuf/manuf
    cat ${wireshark-cli}/share/wireshark/wka >> manuf/manuf
  '';

  nativeBuildInputs = [ wireshark-cli ];
  nativeCheckInputs = [ pytestCheckHook ];
  disabledTests = [ "test_update_update" ];
  format = "setuptools";
  pythonImportsCheck = [ "manuf" ];

  passthru.tests = {
    testMacAddress = runCommand "${pname}-test" { } ''
      ${lib.getExe manuf} BC:EE:7B:00:00:00 > $out
      [ "$(cat $out | tr -d '\n')" = "Vendor(manuf='ASUSTekC', manuf_long='ASUSTek COMPUTER INC.', comment=None)" ]
    '';
  };

  meta = {
    description = "Parser library for Wireshark's OUI database";
    homepage = "https://github.com/coolbho3k/manuf";

    license = with lib.licenses; [
      lgpl3Plus
      asl20
    ];

    maintainers = with lib.maintainers; [ dsuetin ];
    platforms = lib.platforms.linux;
    mainProgram = "manuf";
  };
}
