const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const CI_PROJECT_DIR = process.env.CI_PROJECT_DIR || process.cwd();

if (!GITHUB_TOKEN) {
    console.error('GITHUB_TOKEN env var is empty');
    process.exit(1);
}

const repoUrl = `https://x-access-token:${GITHUB_TOKEN}@github.com/akaptelinin/gitlab-github-mirror-test.git`;
const work = path.join(process.cwd(), 'temp_repo');

if (fs.existsSync(work)) {
    fs.rmSync(work, { recursive: true, force: true });
}
fs.mkdirSync(work);

process.chdir(work);

function run(cmd) {
    try {
        execSync(cmd, { stdio: 'inherit' });
    } catch (err) {
        process.exit(1);
    }
}

// Конфиг гита
run('git init');
run(`git config user.name "hook-bot"`);
run(`git config user.email "hook-bot@example.com"`);
run('git config --global credential.helper ""');

run(`git remote add origin ${repoUrl}`);
run('git fetch origin development');
run('git checkout -b development origin/development');

const conflictFile = 'dev_conflict.txt';
if (!fs.existsSync(conflictFile)) {
    run(`node ${path.join(CI_PROJECT_DIR, 'generate_dev_conflict.js')} ${conflictFile}`);
    run(`git add ${conflictFile}`);
    const now = new Date().toLocaleString('ru-RU', { timeZone: 'Europe/Moscow', hour12: false });
    run(`git commit -m "auto-conflict file generated. ${now}"`);
} else {
    console.log('dev_conflict.txt already exists, skip generation');
}

try {
    run('git push origin HEAD:development');
    console.log('push OK');
} catch {
    console.error('push failed (branch updated on remote or auth error)');
    process.exit(1);
}
