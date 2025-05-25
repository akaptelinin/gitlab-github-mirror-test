const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const RemoteRepo = process.env.REMOTE_REPO || 'https://<GitHub token with Content: Read and Write>@github.com/akaptelinin/gitlab-github-mirror-test.git';
const GitlabRepo = process.env.GITLAB_REPO || 'http://localhost:8929/root/gitlab-github-mirror-test.git';
const GitlabUser = process.env.GITLAB_USER || 'root';
const GitlabPass = process.env.GITLAB_PASS || '<GitLab token or password>';
const IntervalSec = parseInt(process.env.INTERVAL_SEC || '60', 10);

const tempDir = path.join(require('os').tmpdir(), 'repo-mirror-tmp');

function urlEncode(str) {
    return encodeURIComponent(str);
}

function color(text, colorCode) {
    return `\x1b[${colorCode}m${text}\x1b[0m`;
}
function writeErr(msg) { console.error(color(msg, 31)); }
function writeOk(msg) { console.log(color(msg, 32)); }

function sleep(ms) {
    return new Promise(res => setTimeout(res, ms));
}

async function main() {
    while (true) {
        const startTime = new Date().toLocaleTimeString('ru-RU', { hour12: false });
        console.log('');
        console.log(`----- MIRROR START (${startTime}) -----`);

        if (fs.existsSync(tempDir)) {
            fs.rmSync(tempDir, { recursive: true, force: true });
        }

        try {
            execSync(`git clone --mirror "${RemoteRepo}" "${tempDir}"`, { stdio: 'inherit' });
        } catch {
            writeErr(`Error: failed to clone ${RemoteRepo}`);
            await sleep(IntervalSec * 1000);
            continue;
        }

        if (!fs.existsSync(path.join(tempDir, 'config'))) {
            writeErr(`Error: failed to clone ${RemoteRepo} (no config)`);
            await sleep(IntervalSec * 1000);
            continue;
        }

        const encodedPass = urlEncode(GitlabPass);
        let repoUrl = GitlabRepo.replace(/^https?:\/\//, '');
        const pushUrl = `http://${GitlabUser}:${encodedPass}@${repoUrl}`;

        process.chdir(tempDir);

        try {
            execSync(`git remote set-url --push origin "${pushUrl}"`, { stdio: 'inherit' });
        } catch {
            writeErr('Error: failed to set GitLab remote');
            process.chdir(__dirname);
            await sleep(IntervalSec * 1000);
            continue;
        }

        try {
            execSync(`git fetch -p origin`, { stdio: 'inherit' });
        } catch {
            writeErr('Error: fetch failed');
            process.chdir(__dirname);
            await sleep(IntervalSec * 1000);
            continue;
        }

        try {
            execSync(`git push --mirror`, { stdio: 'inherit' });
        } catch {
            writeErr('Error: push failed');
            process.chdir(__dirname);
            await sleep(IntervalSec * 1000);
            continue;
        }

        process.chdir(__dirname);
        writeOk('Mirror sync completed successfully');

        if (fs.existsSync(tempDir)) {
            fs.rmSync(tempDir, { recursive: true, force: true });
        }

        console.log(`Waiting ${IntervalSec} seconds...`);
        await sleep(IntervalSec * 1000);
    }
}

main();
