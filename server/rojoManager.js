import { spawn } from 'child_process';
import path from 'path';
import { getProjectPaths } from './projectManager.js';

const rojoByProject = new Map();

function stablePortFor(name){
  // Base port 34872 plus a small stable offset per project
  let hash = 0;
  for (let i = 0; i < name.length; i++) hash = (hash * 31 + name.charCodeAt(i)) >>> 0;
  const offset = (hash % 3000); // 0..2999
  return 34872 + offset;
}

export function getRojoStatus(name){
  const p = rojoByProject.get(name);
  if (!p) return { running: false, port: stablePortFor(name) };
  return { running: true, pid: p.child.pid, port: p.port };
}

export function stopRojo(name){
  const rec = rojoByProject.get(name);
  if (rec) {
    try { rec.child.kill(); } catch {}
    rojoByProject.delete(name);
  }
}

export function startRojo(name){
  if (rojoByProject.has(name)) return getRojoStatus(name);
  const { base, rojoProject } = getProjectPaths(name);
  const cmd = process.platform === 'win32' ? 'rojo.exe' : 'rojo';
  const port = stablePortFor(name);
  const args = ['serve', '--bind', 'localhost', '--port', String(port), rojoProject];
  const child = spawn(cmd, args, { cwd: base, stdio: 'pipe' });
  const rec = { child, logs: [], port };
  child.stdout.on('data', d => rec.logs.push(d.toString()));
  child.stderr.on('data', d => rec.logs.push(d.toString()));
  child.on('exit', () => rojoByProject.delete(name));
  rojoByProject.set(name, rec);
  return getRojoStatus(name);
}

export function getRojoLogs(name, tail=200){
  const rec = rojoByProject.get(name);
  if (!rec) return [];
  return rec.logs.slice(-tail);
}


