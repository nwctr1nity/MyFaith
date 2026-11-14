// Renders the launcher icons from assets/icon/icon.svg:
//   node tool/render_icons.js assets/icon/icon.svg android/app/src/main/res <preview dir>
const { chromium } = require('playwright');
const fs = require('fs');
const [,, src, res] = process.argv;
const svg = fs.readFileSync(src, 'utf8');
// Text only: drop the background shape and its border, keep the defs.
const inner = svg.replace(/^[\s\S]*?<svg[^>]*>/, '').replace(/<\/svg>\s*$/, '');
const text = inner
  .replace(/<use xlink:href="#stroke0_1_8" fill="#37563B"\/>/, '')
  .replace(/<mask id="stroke1_1_8"[\s\S]*?<\/mask>/, '')
  .replace(/<path d="M366\.4 1024[\s\S]*?mask="url\(#stroke1_1_8\)"\/>/, '');
if (text.includes('#152D20')) throw new Error('border not removed');
// The 1024 design maps onto the 72dp area every launcher mask shows, in the
// middle of the 108dp adaptive canvas: 1024 * 1.5 = 1536, offset 256.
const fg = `<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="-256 -256 1536 1536" fill="none">${text}</svg>`;
const dens = { mdpi: 1, hdpi: 1.5, xhdpi: 2, xxhdpi: 3, xxxhdpi: 4 };
(async () => {
  const b = await chromium.launch();
  const page = await b.newPage();
  async function shot(markup, size, out) {
    await page.setViewportSize({ width: size, height: size });
    await page.setContent(`<style>html,body{margin:0;background:transparent}svg{display:block;width:${size}px;height:${size}px}</style>${markup}`);
    await page.screenshot({ path: out, omitBackground: true });
  }
  for (const [d, k] of Object.entries(dens)) {
    fs.mkdirSync(`${res}/mipmap-${d}`, { recursive: true });
    await shot(svg, Math.round(48 * k), `${res}/mipmap-${d}/ic_launcher.png`);
    await shot(fg, Math.round(108 * k), `${res}/mipmap-${d}/ic_launcher_foreground.png`);
  }
  await shot(svg, 512, process.argv[4] + '/full.png');
  await shot(`<div style="width:432px;height:432px;background:#37563B;border-radius:50%;overflow:hidden">${fg}</div>`.replace('<svg ', '<svg style="width:648px;height:648px;margin:-108px" '), 432, process.argv[4] + '/round.png');
  await b.close();
})();
