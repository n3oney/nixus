{inputs, ...}: {
  osModules = [inputs.impurity.nixosModules.impurity];

  combinedManager.osExtraPassedArgs = {
    impurity = "impurity";
  };
  os.impurity.configRoot = inputs.self;
  os.environment.variables.IMPURITY_PATH = "/home/neoney/nixus";
}
