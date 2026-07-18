{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  tkinter,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "async-tkinter-loop";
  version = "0.10.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-y4gDOXXk4z1gAQVeB+/gOzia4SfICJiXV47pdaEQRp4=";
    pname = "async_tkinter_loop";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    tkinter
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "async_tkinter_loop" ];
  pythonRemoveDeps = [ "asyncio" ];

  meta = {
    description = "Implementation of asynchronous mainloop for tkinter, the use of which allows using async handler functions";
    homepage = "https://github.com/insolor/async-tkinter-loop";
    changelog = "https://github.com/insolor/async-tkinter-loop/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ AngryAnt ];
  };
}
