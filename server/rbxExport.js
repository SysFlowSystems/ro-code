import path from 'path';
import fs from 'fs-extra';
import { getProjectPaths } from './projectManager.js';

// Minimal .rbxmx exporter: wraps plain Lua files into ModuleScript/Script items with Source
// This is a simplistic XML writer sufficient for basic export

function xmlEscape(text){
  return String(text)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

function scriptItemXml(className, name, source){
  const escaped = xmlEscape(source);
  return `  <Item class="${className}" referent="RBX${Math.floor(Math.random()*1e9)}">
    <Properties>
      <string name="Name">${xmlEscape(name)}</string>
      <ProtectedString name="Source">${escaped}</ProtectedString>
    </Properties>
  </Item>`;
}

export async function exportProjectToRbxmx(projectName){
  const { src, exports: exportsDir } = getProjectPaths(projectName);
  const files = await collectLuaFiles(src);
  const items = [];
  for (const f of files){
    const source = await fs.readFile(f.full, 'utf8');
    const className = f.base.toLowerCase().endsWith('.client.lua')
      ? 'LocalScript'
      : 'Script';
    items.push(scriptItemXml(className, f.base.replace(/\.lua$/, ''), source));
  }
  const xml = `<?xml version="1.0" encoding="utf-8"?>
<roblox version="4">
${items.join('\n')}
</roblox>`;
  const out = path.join(exportsDir, `${projectName}.rbxmx`);
  await fs.ensureDir(path.dirname(out));
  await fs.writeFile(out, xml, 'utf8');
  return { out, count: items.length };
}

async function collectLuaFiles(root){
  const out = [];
  async function walk(dir){
    const entries = await fs.readdir(dir, { withFileTypes: true });
    for (const e of entries){
      const full = path.join(dir, e.name);
      if (e.isDirectory()) await walk(full);
      else if (/\.lua$/i.test(e.name)) out.push({ full, base: e.name });
    }
  }
  await walk(root);
  return out;
}


