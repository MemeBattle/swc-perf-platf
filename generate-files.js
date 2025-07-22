const fs = require("fs");
const path = require("path");

const ROOT = path.join(__dirname, "src");
const FILES_TOTAL = 100000;
const FILES_PER_DIR = 10; // f0.jsx ... f9.jsx
const DIRS_PER_DIR = 10; // d0 ... d9
const TEMPLATE_PATH = path.join(__dirname, "template.jsx");

function pad(num, size) {
  let s = num + "";
  while (s.length < size) s = "0" + s;
  return s;
}

function getComponentName(index) {
  return `F${index}`;
}

function getFilePathByIndex(index) {
  // Convert index to path using the new scheme (10 files per level, 10 folders)
  let parts = [];
  let n = index;
  while (n >= FILES_PER_DIR) {
    parts.unshift("d" + (n % DIRS_PER_DIR));
    n = Math.floor(n / DIRS_PER_DIR);
  }
  const fileName = `f${n}.jsx`;
  return path.join(ROOT, ...parts, fileName);
}

function getDirPathByIndex(index) {
  let parts = [];
  let n = index;
  while (n >= FILES_PER_DIR) {
    parts.unshift("d" + (n % DIRS_PER_DIR));
    n = Math.floor(n / DIRS_PER_DIR);
  }
  return path.join(ROOT, ...parts);
}

function generateFileContent(componentName) {
  // Use template, change component name
  const template = fs.readFileSync(TEMPLATE_PATH, "utf8");
  // Replace function Component with function FXXXXX and export default Component
  return template
    .replace(/function Component/g, `function ${componentName}`)
    .replace(/export default Component/g, `export default ${componentName}`);
}

function main() {
  let created = 0;
  for (let i = 0; i < FILES_TOTAL; i++) {
    const filePath = getFilePathByIndex(i);
    if (!fs.existsSync(filePath)) {
      const dir = path.dirname(filePath);
      fs.mkdirSync(dir, { recursive: true });
      const componentName = getComponentName(i);
      const content = generateFileContent(componentName);
      fs.writeFileSync(filePath, content, "utf8");
      created++;
      if (created % 1000 === 0) {
        console.log(`Files created: ${created}`);
      }
    }
  }
  console.log(`Done! Total files created: ${created}`);
}

main();
