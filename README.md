# SWC Performance Degradation Reproduction

This project contains scripts and configuration to reproduce and measure performance degradation in [SWC](https://swc.rs/) when using plugins.

## Project Structure

- `generate-files.js` — script to generate a large number of React component files in the `src/` directory for benchmarking.
- `template.jsx` — template for generated React components.
- `src/` — directory where test files are generated.
- `swc-old/` — SWC setup with an older version (1.3.95) and plugin configuration.
- `swc-new/` — SWC setup with a newer version (1.13.1) and plugin configuration.
- `run_swc.sh` — shell script to run SWC builds with different versions and plugin options.

## Prerequisites

- [Node.js](https://nodejs.org/) (v16 or higher recommended)
- [npm](https://www.npmjs.com/)

## Install Dependencies

To install all dependencies for both SWC versions, run:

```sh
npm run install:deps
```

## Generate Test Files

To generate a large number of test files in the `src/` directory (by default, 100,000 files):

```sh
npm run generate-files
```

This will clear the `src/` directory and populate it with generated React components for benchmarking.

## Run Performance Tests

You can run SWC builds with or without the plugin, and with the old or new SWC version. Use the following commands:

- **Old SWC, without_plugin:**
  ```sh
  npm run build:old:without_plugin
  ```
- **Old SWC, with_plugin:**
  ```sh
  npm run build:old:with_plugin
  ```
- **New SWC, without_plugin:**
  ```sh
  npm run build:new:without_plugin
  ```
- **New SWC, with_plugin:**
  ```sh
  npm run build:new:with_plugin
  ```

Each command will print the SWC version and the execution time for the build.

## Notes

- The `src/` directory is generated and not tracked by git.
- The `dist/` and `node_modules/` directories are also ignored by git.
- You can adjust the number of generated files by editing the `FILES_TOTAL` constant in `generate-files.js`.

---

Feel free to open issues or contribute improvements for more accurate benchmarking or additional scenarios.
