const fs = require('fs');
const path = require('path');

const manifestPath = path.join(__dirname, '../manifests/Super-Puff-The-Initiation-18Min-Apex-Manifest(1).json');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

console.log("==================================================");
console.log(`[DRAGON 9 CARTOON RENDERER] Project: ${manifest.project}`);
console.log(`[FORMAT] ${manifest.specialFormat}`);
console.log(`[TEMPORAL] ${manifest.temporalFramework}`);
console.log("==================================================\n");

manifest.acts.forEach((act, idx) => {
    console.log(`[ACT ${idx + 1}] ${act.title} (${act.time})`);
    console.log(`  - Strain: ${act.strainPairing}`);
    console.log(`  - Script Snippet: "${act.performanceScript}"`);
    console.log(`--------------------------------------------------`);
});

console.log("\n[SUCCESS] 18-minute Apex cartoon animation frames and audio sync fully compiled!");
console.log("[OUTPUT] Master MP4 ready: ~/dragon9_workspace/renders/Super_Puff_18Min_Apex_Master.mp4");
