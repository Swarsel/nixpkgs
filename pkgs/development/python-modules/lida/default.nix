{
  lib,
  altair,
  basemap,
  basemap-data-hires,
  buildPythonPackage,
  fastapi,
  fetchPypi,
  geopandas,
  geopy,
  kaleido,
  llmx,
  matplotlib,
  matplotlib-venn,
  networkx,
  numpy,
  pandas,
  peacasso,
  plotly,
  plotnine,
  pydantic,
  python-multipart,
  scipy,
  seaborn,
  setuptools,
  setuptools-scm,
  statsmodels,
  typer,
  uvicorn,
  wordcloud,
}:

buildPythonPackage rec {
  pname = "lida";
  version = "0.0.14";

  # No releases or tags are available in https://github.com/microsoft/lida
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/az6hS8rNPxb8cDiz9SOyUBi/X48r9prJNFUnx1wPHM=";
  };

  patches = [
    # The upstream places the data path under the py file's own directory.
    # However, since `/nix/store` is read-only, we patch it to the user's home directory.
    ./rw_data.patch
  ];

  # require network
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    altair
    fastapi
    geopandas
    kaleido
    llmx
    matplotlib
    matplotlib-venn
    networkx
    numpy
    pandas
    plotly
    plotnine
    pydantic
    python-multipart
    scipy
    seaborn
    statsmodels
    typer
    uvicorn
    wordcloud
  ];

  optional-dependencies = {
    infographics = [
      peacasso
    ];

    tools = [
      basemap
      basemap-data-hires
      geopy
    ];

    transformers = [
      llmx
    ];

    web = [
      fastapi
      uvicorn
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "lida" ];

  meta = {
    description = "Automatic Generation of Visualizations and Infographics using Large Language Models";
    homepage = "https://github.com/microsoft/lida";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "lida";
  };
}
