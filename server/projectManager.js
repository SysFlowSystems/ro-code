import path from 'path';
import fs from 'fs-extra';
import chokidar from 'chokidar';

const watchersByProject = new Map();

export function getProjectsRoot(){
  // Workspace root assumed as process.cwd()
  return path.join(process.cwd(), 'projects');
}

export async function listProjects(){
  const root = getProjectsRoot();
  await fs.ensureDir(root);
  const names = (await fs.readdir(root, { withFileTypes: true }))
    .filter(d => d.isDirectory())
    .map(d => d.name);
  return names;
}

export function getProjectPaths(name){
  const base = path.join(getProjectsRoot(), name);
  return {
    base,
    src: path.join(base, 'src'),
    generated: path.join(base, 'generated'),
    exports: path.join(base, 'exports'),
    rojoProject: path.join(base, 'default.project.json')
  };
}

export async function ensureProject(name, template){
  const { base, src, generated, exports: exportsDir, rojoProject } = getProjectPaths(name);
  await fs.ensureDir(base);
  await fs.ensureDir(src);
  await fs.ensureDir(generated);
  await fs.ensureDir(exportsDir);

  // Roblox folder structure inside src
  await fs.ensureDir(path.join(src, 'ReplicatedStorage', 'Fractured'));
  await fs.ensureDir(path.join(src, 'ServerScriptService'));
  await fs.ensureDir(path.join(src, 'ServerStorage', 'Fractured'));
  await fs.ensureDir(path.join(src, 'StarterPlayer', 'StarterPlayerScripts'));
  await fs.ensureDir(path.join(src, 'StarterGui'));

  // Write project rojo file
  const rojoContent = {
    name,
    tree: {
      ReplicatedStorage: {
        Fractured: { $path: 'src/ReplicatedStorage/Fractured' }
      },
      ServerScriptService: { $path: 'src/ServerScriptService' },
      ServerStorage: { $path: 'src/ServerStorage' },
      StarterPlayer: {
        StarterPlayerScripts: { $path: 'src/StarterPlayer/StarterPlayerScripts' }
      },
      StarterGui: { $path: 'src/StarterGui' }
    }
  };
  await fs.writeJson(rojoProject, rojoContent, { spaces: 2 });

  if (template) {
    await applyTemplate(name, template);
  }

  await ensureWatcher(name);
}

export async function ensureWatcher(name){
  if (watchersByProject.has(name)) return;
  const { generated, src } = getProjectPaths(name);
  await fs.ensureDir(generated);
  await fs.ensureDir(src);

  const watcher = chokidar.watch(generated, { ignoreInitial: true, depth: 10 });
  watcher.on('all', async (event, filePath) => {
    try {
      const rel = path.relative(generated, filePath);
      const dest = path.join(src, rel);
      if (event === 'add' || event === 'change') {
        await fs.ensureDir(path.dirname(dest));
        await fs.copy(filePath, dest);
      } else if (event === 'unlink') {
        await fs.remove(dest);
      }
    } catch (e) {
      // Silent fail: watcher errors shouldn't crash server
      // eslint-disable-next-line no-console
      console.warn('Watcher error', e.message);
    }
  });
  watchersByProject.set(name, watcher);
}

export async function stopWatcher(name){
  const w = watchersByProject.get(name);
  if (w) { await w.close(); watchersByProject.delete(name); }
}

export function suggestRobloxPathForFile(file){
  const lower = (file.filename || '').toLowerCase();
  if (lower.endsWith('.client.lua')) return path.join('StarterPlayer', 'StarterPlayerScripts', file.filename);
  if (lower.endsWith('.server.lua')) return path.join('ServerScriptService', file.filename);
  if (lower.endsWith('.lua')) return path.join('ServerScriptService', file.filename.replace(/\.lua$/, '.server.lua'));
  return path.join('ReplicatedStorage', 'Fractured', file.filename || `AI_${Date.now()}.txt`);
}

export async function saveFilesToProject(name, files){
  const { src } = getProjectPaths(name);
  const saved = [];
  for (const file of files) {
    const safeName = (file.filename || `AI_${Date.now()}.txt`).replace(/[^a-zA-Z0-9_.\-/]/g, '_');
    const relPath = file.path
      ? file.path.replace(/^\/+/, '')
      : suggestRobloxPathForFile({ filename: safeName });
    const dest = path.join(src, relPath);
    await fs.ensureDir(path.dirname(dest));
    await fs.writeFile(dest, file.content ?? '', 'utf8');
    saved.push({ relPath, bytes: Buffer.byteLength(file.content ?? '', 'utf8') });
  }
  return saved;
}

async function writeTemplateFiles(name, entries){
  const { src } = getProjectPaths(name);
  for (const e of entries) {
    const dest = path.join(src, e.path);
    await fs.ensureDir(path.dirname(dest));
    await fs.writeFile(dest, e.content, 'utf8');
  }
}

export async function applyTemplate(name, template){
  const lower = String(template || '').toLowerCase();
  if (lower === 'horror') {
    await writeTemplateFiles(name, [
      { path: 'ServerScriptService/HorrorMain.server.lua', content: HORROR_MAIN },
      { path: 'StarterPlayer/StarterPlayerScripts/HorrorClient.client.lua', content: HORROR_CLIENT }
    ]);
  } else if (lower === 'simulator') {
    await writeTemplateFiles(name, [
      { path: 'ServerScriptService/Simulator.server.lua', content: SIMULATOR_MAIN }
    ]);
  } else if (lower === 'tycoon') {
    await writeTemplateFiles(name, [
      { path: 'ServerScriptService/Tycoon.server.lua', content: TYCOON_MAIN }
    ]);
  }
}

const HORROR_MAIN = `-- Horror game server bootstrap
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Remotes = Instance.new('Folder')
Remotes.Name = 'Remotes'
Remotes.Parent = ReplicatedStorage

print('Horror template server started')
`;

const HORROR_CLIENT = `-- Horror game client bootstrap
print('Horror template client loaded')
`;

const SIMULATOR_MAIN = `-- Simulator template server
print('Simulator template server started')
`;

const TYCOON_MAIN = `-- Tycoon template server
print('Tycoon template server started')
`;


