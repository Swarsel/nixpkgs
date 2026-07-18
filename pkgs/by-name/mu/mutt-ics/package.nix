{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "mutt-ics";
  version = "0.9.2";

  src = fetchPypi {
    inherit (finalAttrs) version;
    sha256 = "d44d4bec4e71c7f14df01b90fdb9563cdc784ece4250abfea5b0b675cfe85a50";
    pname = "mutt_ics";
  };

  build-system = with python3.pkgs; [ setuptools ];
  dependencies = with python3.pkgs; [ icalendar ];
  pyproject = true;
  pythonImportsCheck = [ "mutt_ics" ];

  meta = {
    description = "Tool to show calendar event details in Mutt";
    homepage = "https://github.com/dmedvinsky/mutt-ics";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mh182 ];
    mainProgram = "mutt-ics";
  };
})
