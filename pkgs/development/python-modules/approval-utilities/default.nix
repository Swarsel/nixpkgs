{
  lib,
  approvaltests,
  buildPythonPackage,
  setuptools,
  typing-extensions,
}:

buildPythonPackage {
  inherit (approvaltests) version src;
  pname = "approval-utilities";

  postPatch = ''
    mv setup/setup.approval_utilities.py setup.py
  ''
  + approvaltests.postPatch or "";

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    # used in approval_utilities/utilities/time_utilities.py
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "approval_utilities" ];

  meta = {
    description = "Utilities for your production code that work well with approvaltests";
    homepage = "https://github.com/approvals/ApprovalTests.Python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
