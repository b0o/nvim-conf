import fs from "fs/promises";
import path from "path";

const getMainExport = async (packageJsonPath) => {
  const packageJson = JSON.parse(await fs.readFile(packageJsonPath, "utf-8"));
  const mainExport = Object.keys(packageJson.exports).find((key) => key === ".");
  if (mainExport) {
    if (typeof packageJson.exports[mainExport] === "string") {
      return packageJson.exports[mainExport];
    }
    const mainExportPath = packageJson.exports[mainExport].default
      || packageJson.exports[mainExport].import
      || packageJson.exports[mainExport].require;
    if (mainExportPath) {
      return mainExportPath;
    }
  }
  if (packageJson.main) {
    return packageJson.main;
  }
  if (packageJson.module) {
    return packageJson.module;
  }
  return undefined;
};

const resolveImportPath = async (pluginName) => {
  try {
    await import(pluginName);
    return pluginName;
  } catch (e) {}

  const dataHome = process.env.XDG_DATA_HOME || path.join(process.env.HOME, "/.local/share");

  const candidates = [
    path.join(dataHome, "pnpm/global/5/node_modules", pluginName),
    // TODO: npm
    // TODO: yarn
    // TODO: asdf
  ];
  for (const p of candidates) {
    try {
      await fs.stat(p);
      const mainExport = await getMainExport(path.join(p, "package.json"));
      if (mainExport) {
        const mainExportPath = path.join(p, mainExport);
        return mainExportPath;
      }
    } catch (e) {}
  }
};

export default {
  plugins: (await Promise.all([
    "@prettier/plugin-xml",
  ].map(resolveImportPath))).filter(Boolean),
};
