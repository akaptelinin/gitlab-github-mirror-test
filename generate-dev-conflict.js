const fs = require('fs');
const { execSync } = require('child_process');
const crypto = require('crypto');

function randomString(len = 32) {
    return crypto.randomBytes(len)
        .toString('base64')
        .replace(/[^a-zA-Z0-9]/g, '')
        .substring(0, len);
}

function main(outFile = 'dev_conflict.txt') {
    const UID = crypto.randomUUID();
    const Timestamp = new Date().toISOString().replace('T', ' ').substring(0, 19);
    let Hash = '';
    try {
        Hash = execSync('git rev-parse HEAD').toString().trim();
    } catch {
        Hash = '(no git hash)';
    }

    const lines = [];
    lines.push('############################################################');
    lines.push('#   WARNING: DEVELOPMENT BRANCH WAS RECREATED');
    lines.push('############################################################');
    lines.push(`Branch unique ID : ${UID}`);
    lines.push(`Creation date    : ${Timestamp}`);
    lines.push(`Commit hash      : ${Hash}`);
    lines.push('############################################################');
    lines.push('');

    for (let i = 1; i <= 50; ++i) {
        lines.push(`Instruction #${i} - update local branch:`);
        lines.push(`  git checkout master`);
        lines.push(`  git branch -D development`);
        lines.push(`  git fetch origin`);
        lines.push(`  git checkout development`);
        lines.push(`Conflict line #${i} - ${randomString(32)}`);
        lines.push('############################################################');
        lines.push('#   If you see this file your local branch is outdated!');
        lines.push('#   Please update before pushing.');
        lines.push('############################################################');
    }

    fs.writeFileSync(outFile, lines.join('\n'), { encoding: 'utf8' });
}

if (require.main === module) {
    main(process.argv[2] || 'dev_conflict.txt');
}
